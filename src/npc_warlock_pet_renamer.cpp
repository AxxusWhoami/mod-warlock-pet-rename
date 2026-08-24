/*
 * Credits: silviu20092
 */

#include "ScriptMgr.h"
#include "ScriptedGossip.h"
#include "Player.h"
#include "Pet.h"
#include "DatabaseEnv.h"
#include "GameTime.h"
#include "Chat.h"
#include "Log.h"
#include "ObjectMgr.h"

#include <algorithm>
#include <cctype>
#include <mutex>
#include <string>
#include <unordered_map>

class npc_warlock_pet_renamer : public CreatureScript
{
private:
    static constexpr int VISUAL_FEEDBACK_SPELL_ID = 46331;
    static constexpr int64 RENAME_COOLDOWN_SECONDS = 30;
    static constexpr uint32 RENAME_COST_COPPER = 15 * 10000;

    // module_string IDs (see data/sql/db-world/updates/WPR_2024_03_28_01.sql)
    enum ModuleStringId
    {
        STR_WARLOCKS_ONLY            = 1,
        STR_SUMMON_PET               = 2,
        STR_CURRENT_PET              = 3,
        STR_RENAME_PET               = 4,
        STR_RENAME_POPUP             = 5,
        STR_NEVERMIND                = 6,
        STR_CONFIRM_RENAME           = 7,
        STR_CANCEL                   = 8,
        STR_NOT_ENOUGH_GOLD          = 9,
        STR_COOLDOWN                 = 10,
        STR_PET_TYPE_INFERNAL        = 11,
        STR_PET_TYPE_IMP             = 12,
        STR_PET_TYPE_FELHUNTER       = 13,
        STR_PET_TYPE_VOIDWALKER      = 14,
        STR_PET_TYPE_SUCCUBUS        = 15,
        STR_PET_TYPE_DOOMGUARD       = 16,
        STR_PET_TYPE_FELGUARD        = 17,
        STR_PET_TYPE_UNKNOWN         = 18,
    };

    static constexpr const char* MODULE_NAME = "mod-warlock-pet-rename";

    static std::unordered_map<uint64, int64> _lastRenameByPlayer;
    static std::unordered_map<uint64, std::string> _proposedName;
    static std::mutex _renameMutex;

    static std::string GetModuleString(uint32 id, Player* player = nullptr)
    {
        uint32 locale = player ? player->GetSession()->GetSessionDbLocaleIndex() : DEFAULT_LOCALE;
        return sObjectMgr->GetAcoreStringForModule(MODULE_NAME, id, locale);
    }

    static std::string GetModuleStringFmt(uint32 id, Player* player, const std::string& arg)
    {
        std::string fmt = GetModuleString(id, player);
        size_t pos = fmt.find("{}");
        if (pos != std::string::npos)
            fmt.replace(pos, 2, arg);
        return fmt;
    }

    static bool TryStartRename(Player* player)
    {
        int64 now = GameTime::GetGameTime().count();
        uint64 playerGuid = player->GetGUID().GetCounter();

        std::lock_guard<std::mutex> lock(_renameMutex);

        for (auto it = _lastRenameByPlayer.begin(); it != _lastRenameByPlayer.end(); )
        {
            if ((now - it->second) >= RENAME_COOLDOWN_SECONDS)
                it = _lastRenameByPlayer.erase(it);
            else
                ++it;
        }

        auto it = _lastRenameByPlayer.find(playerGuid);
        if (it != _lastRenameByPlayer.end())
            return false;

        _lastRenameByPlayer[playerGuid] = now;
        return true;
    }

    static Pet* GetAllowedPetForRename(Player* player)
    {
        Pet* pet = player->GetPet();
        if (!pet)
            return nullptr;

        return pet->IsPet() && pet->GetOwnerGUID() == player->GetGUID() && pet->GetCharmInfo() != nullptr ? pet : nullptr;
    }

    static void NormalizeName(std::string& name)
    {
        if (name.empty())
            return;

        std::transform(name.begin(), name.end(), name.begin(), [](unsigned char c) { return std::tolower(c); });
        name[0] = std::toupper(static_cast<unsigned char>(name[0]));
    }

    static bool ValidateProposedName(Player* player, Pet* pet, std::string& name)
    {
        NormalizeName(name);

        PetNameInvalidReason res = ObjectMgr::CheckPetName(name);
        if (res != PET_NAME_SUCCESS)
        {
            player->GetSession()->SendPetNameInvalid(res, name, nullptr);
            return false;
        }

        if (sObjectMgr->IsReservedName(name))
        {
            player->GetSession()->SendPetNameInvalid(PET_NAME_RESERVED, name, nullptr);
            return false;
        }

        if (sObjectMgr->IsProfanityName(name))
        {
            player->GetSession()->SendPetNameInvalid(PET_NAME_PROFANE, name, nullptr);
            return false;
        }

        if (pet->GetName() == name)
            return false;

        return true;
    }

    static void ExecuteRename(Player* player, const std::string& name)
    {
        if (player->getClass() != CLASS_WARLOCK)
            return;

        Pet* pet = GetAllowedPetForRename(player);
        if (!pet)
            return;

        std::string validatedName = name;
        if (!ValidateProposedName(player, pet, validatedName))
            return;

        std::string oldName = pet->GetName();
        if (oldName == validatedName)
            return;

        if (player->GetMoney() < RENAME_COST_COPPER)
        {
            ChatHandler(player->GetSession()).SendSysMessage(GetModuleString(STR_NOT_ENOUGH_GOLD, player));
            return;
        }

        if (!TryStartRename(player))
        {
            ChatHandler(player->GetSession()).SendSysMessage(GetModuleString(STR_COOLDOWN, player));
            return;
        }

        uint32 petNumber = pet->GetCharmInfo()->GetPetNumber();

        player->ModifyMoney(-static_cast<int32>(RENAME_COST_COPPER));
        pet->SetName(validatedName);
        player->CastSpell(pet, VISUAL_FEEDBACK_SPELL_ID, true);

        CharacterDatabasePreparedStatement* stmt = CharacterDatabase.GetPreparedStatement(CHAR_UPD_CHAR_PET_NAME);
        stmt->SetData(0, validatedName);
        stmt->SetData(1, player->GetGUID().GetCounter());
        stmt->SetData(2, petNumber);
        CharacterDatabase.DirectExecute(stmt);

        LOG_DEBUG("entities.pet.renamer", "Player {} renamed pet #{} from '{}' to '{}' for 15 gold",
            player->GetName(), petNumber, oldName, validatedName);

        pet->SetUInt32Value(UNIT_FIELD_PET_NAME_TIMESTAMP, uint32(GameTime::GetGameTime().count()));
    }

    static std::string GetPetTypeString(const Pet* pet, Player* player)
    {
        switch (pet->GetEntry())
        {
            case NPC_INFERNAL:
                return GetModuleString(STR_PET_TYPE_INFERNAL, player);
            case NPC_IMP:
                return GetModuleString(STR_PET_TYPE_IMP, player);
            case NPC_FELHUNTER:
                return GetModuleString(STR_PET_TYPE_FELHUNTER, player);
            case NPC_VOIDWALKER:
                return GetModuleString(STR_PET_TYPE_VOIDWALKER, player);
            case NPC_SUCCUBUS:
                return GetModuleString(STR_PET_TYPE_SUCCUBUS, player);
            case NPC_DOOMGUARD:
                return GetModuleString(STR_PET_TYPE_DOOMGUARD, player);
            case NPC_FELGUARD:
                return GetModuleString(STR_PET_TYPE_FELGUARD, player);
            default:
                return GetModuleString(STR_PET_TYPE_UNKNOWN, player);
        }
    }

    static std::string GetPetInfo(const Pet* pet, Player* player)
    {
        return pet->GetName() + " (" + GetPetTypeString(pet, player) + ")";
    }
public:
    npc_warlock_pet_renamer() : CreatureScript("npc_warlock_pet_renamer")
    {
    }

    static void ClearProposedName(uint64 guid)
    {
        std::lock_guard<std::mutex> lock(_renameMutex);
        _proposedName.erase(guid);
    }

    bool OnGossipHello(Player* player, Creature* creature) override
    {
        ClearProposedName(player->GetGUID().GetCounter());

        if (player->getClass() != CLASS_WARLOCK)
            AddGossipItemFor(player, GOSSIP_ICON_CHAT, GetModuleString(STR_WARLOCKS_ONLY, player), GOSSIP_SENDER_MAIN, GOSSIP_ACTION_INFO_DEF);
        else
        {
            Pet* pet = GetAllowedPetForRename(player);
            if (!pet)
                AddGossipItemFor(player, GOSSIP_ICON_CHAT, GetModuleString(STR_SUMMON_PET, player), GOSSIP_SENDER_MAIN, GOSSIP_ACTION_INFO_DEF);
            else
            {
                AddGossipItemFor(player, GOSSIP_ICON_CHAT, GetModuleStringFmt(STR_CURRENT_PET, player, GetPetInfo(pet, player)), GOSSIP_SENDER_MAIN, GOSSIP_ACTION_INFO_DEF);
                AddGossipItemFor(player, GOSSIP_ICON_TALK, GetModuleString(STR_RENAME_PET, player), GOSSIP_SENDER_MAIN, GOSSIP_ACTION_INFO_DEF + 3, GetModuleString(STR_RENAME_POPUP, player), 0, true);
            }
        }

        AddGossipItemFor(player, GOSSIP_ICON_CHAT, GetModuleString(STR_NEVERMIND, player), GOSSIP_SENDER_MAIN, GOSSIP_ACTION_INFO_DEF + 1);
        SendGossipMenuFor(player, DEFAULT_GOSSIP_MESSAGE, creature->GetGUID());
        return true;
    }

    bool OnGossipSelect(Player* player, Creature* creature, uint32 /*sender*/, uint32 action) override
    {
        if (action == GOSSIP_ACTION_INFO_DEF)
        {
            ClearGossipMenuFor(player);
            return OnGossipHello(player, creature);
        }
        else if (action == GOSSIP_ACTION_INFO_DEF + 1)
        {
            CloseGossipMenuFor(player);
            return true;
        }
        else if (action == GOSSIP_ACTION_INFO_DEF + 4)
        {
            uint64 guid = player->GetGUID().GetCounter();
            std::string name;
            {
                std::lock_guard<std::mutex> lock(_renameMutex);
                auto it = _proposedName.find(guid);
                if (it != _proposedName.end())
                {
                    name = it->second;
                    _proposedName.erase(it);
                }
            }

            if (!name.empty())
                ExecuteRename(player, name);

            CloseGossipMenuFor(player);
            return true;
        }
        else if (action == GOSSIP_ACTION_INFO_DEF + 5)
        {
            ClearProposedName(player->GetGUID().GetCounter());
            CloseGossipMenuFor(player);
            return true;
        }

        CloseGossipMenuFor(player);
        return false;
    }

    bool OnGossipSelectCode(Player* player, Creature* creature, uint32 /*sender*/, uint32 action, const char* code) override
    {
        if (action == GOSSIP_ACTION_INFO_DEF + 3)
        {
            if (player->getClass() != CLASS_WARLOCK)
            {
                CloseGossipMenuFor(player);
                return true;
            }

            Pet* pet = GetAllowedPetForRename(player);
            if (!pet)
            {
                CloseGossipMenuFor(player);
                return true;
            }

            if (!code)
            {
                CloseGossipMenuFor(player);
                return true;
            }

            std::string name(code);
            if (!ValidateProposedName(player, pet, name))
            {
                CloseGossipMenuFor(player);
                return true;
            }

            {
                std::lock_guard<std::mutex> lock(_renameMutex);
                _proposedName[player->GetGUID().GetCounter()] = name;
            }

            ClearGossipMenuFor(player);
            AddGossipItemFor(player, GOSSIP_ICON_CHAT, GetModuleStringFmt(STR_CONFIRM_RENAME, player, name), GOSSIP_SENDER_MAIN, GOSSIP_ACTION_INFO_DEF + 4);
            AddGossipItemFor(player, GOSSIP_ICON_CHAT, GetModuleString(STR_CANCEL, player), GOSSIP_SENDER_MAIN, GOSSIP_ACTION_INFO_DEF + 5);
            SendGossipMenuFor(player, DEFAULT_GOSSIP_MESSAGE, creature->GetGUID());
            return true;
        }

        CloseGossipMenuFor(player);
        return true;
    }
};

class WarlockPetRenamerPlayerScript : public PlayerScript
{
public:
    WarlockPetRenamerPlayerScript() : PlayerScript("WarlockPetRenamerPlayerScript")
    {
    }

    void OnLogout(Player* player) override
    {
        npc_warlock_pet_renamer::ClearProposedName(player->GetGUID().GetCounter());
    }
};

std::unordered_map<uint64, int64> npc_warlock_pet_renamer::_lastRenameByPlayer;
std::unordered_map<uint64, std::string> npc_warlock_pet_renamer::_proposedName;
std::mutex npc_warlock_pet_renamer::_renameMutex;

void AddSC_npc_warlock_pet_renamer()
{
    new npc_warlock_pet_renamer();
    new WarlockPetRenamerPlayerScript();
}
