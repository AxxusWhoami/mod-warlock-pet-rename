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

    static std::unordered_map<uint64, int64> _lastRenameByPlayer;
    static std::unordered_map<uint64, std::string> _proposedName;
    static std::mutex _renameMutex;

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

        std::string oldName = pet->GetName();
        if (oldName == name)
            return;

        if (player->GetMoney() < RENAME_COST_COPPER)
        {
            ChatHandler(player->GetSession()).SendSysMessage("You don't have enough gold. The rename costs 15 Gold.");
            return;
        }

        if (!TryStartRename(player))
        {
            ChatHandler(player->GetSession()).SendSysMessage("You must wait a moment before renaming your pet again.");
            return;
        }

        uint32 petNumber = pet->GetCharmInfo()->GetPetNumber();

        player->ModifyMoney(-static_cast<int32>(RENAME_COST_COPPER));
        pet->SetName(name);
        player->CastSpell(pet, VISUAL_FEEDBACK_SPELL_ID, true);

        CharacterDatabasePreparedStatement* stmt = CharacterDatabase.GetPreparedStatement(CHAR_UPD_CHAR_PET_NAME);
        stmt->SetData(0, name);
        stmt->SetData(1, player->GetGUID().GetCounter());
        stmt->SetData(2, petNumber);
        CharacterDatabase.Execute(stmt);

        LOG_DEBUG("entities.pet.renamer", "Player {} renamed pet #{} from '{}' to '{}' for 15 gold",
            player->GetName(), petNumber, oldName, name);

        // UNIT_FIELD_PET_NAME_TIMESTAMP is a 32-bit protocol field and cannot be widened;
        // the per-player cooldown above uses 64-bit time, so rate limiting stays correct past 2038.
        pet->SetUInt32Value(UNIT_FIELD_PET_NAME_TIMESTAMP, uint32(GameTime::GetGameTime().count()));
    }

    static std::string GetPetInfo(const Pet* pet)
    {
        std::string type = "unknown";
        switch (pet->GetEntry())
        {
            case NPC_INFERNAL:
                type = "infernal";
                break;
            case NPC_IMP:
                type = "imp";
                break;
            case NPC_FELHUNTER:
                type = "felhunter";
                break;
            case NPC_VOIDWALKER:
                type = "voidwalker";
                break;
            case NPC_SUCCUBUS:
                type = "succubus";
                break;
            case NPC_DOOMGUARD:
                type = "doomguard";
                break;
            case NPC_FELGUARD:
                type = "felguard";
                break;
        }

        return pet->GetName() + " (" + type + ")";
    }
public:
    npc_warlock_pet_renamer() : CreatureScript("npc_warlock_pet_renamer")
    {
    }

    bool OnGossipHello(Player* player, Creature* creature) override
    {
        {
            std::lock_guard<std::mutex> lock(_renameMutex);
            _proposedName.erase(player->GetGUID().GetCounter());
        }

        if (player->getClass() != CLASS_WARLOCK)
            AddGossipItemFor(player, GOSSIP_ICON_CHAT, "|cffb50505WARLOCKS ONLY|r", GOSSIP_SENDER_MAIN, GOSSIP_ACTION_INFO_DEF);
        else
        {
            Pet* pet = GetAllowedPetForRename(player);
            if (!pet)
                AddGossipItemFor(player, GOSSIP_ICON_CHAT, "|cffb50505PLEASE SUMMON YOUR PET|r", GOSSIP_SENDER_MAIN, GOSSIP_ACTION_INFO_DEF);
            else
            {
                AddGossipItemFor(player, GOSSIP_ICON_CHAT, "Current pet: " + GetPetInfo(pet), GOSSIP_SENDER_MAIN, GOSSIP_ACTION_INFO_DEF);
                AddGossipItemFor(player, GOSSIP_ICON_TALK, "Rename current pet (15 Gold)", GOSSIP_SENDER_MAIN, GOSSIP_ACTION_INFO_DEF + 3, "Type in your desired pet name in the next popup! Cost: 15 Gold", 0, true);
            }
        }

        AddGossipItemFor(player, GOSSIP_ICON_CHAT, "Nevermind...", GOSSIP_SENDER_MAIN, GOSSIP_ACTION_INFO_DEF + 1);
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
            std::lock_guard<std::mutex> lock(_renameMutex);
            _proposedName.erase(player->GetGUID().GetCounter());
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
            AddGossipItemFor(player, GOSSIP_ICON_CHAT, "Confirm: Rename pet to '" + name + "' for 15 Gold?", GOSSIP_SENDER_MAIN, GOSSIP_ACTION_INFO_DEF + 4);
            AddGossipItemFor(player, GOSSIP_ICON_CHAT, "Cancel", GOSSIP_SENDER_MAIN, GOSSIP_ACTION_INFO_DEF + 5);
            SendGossipMenuFor(player, DEFAULT_GOSSIP_MESSAGE, creature->GetGUID());
            return true;
        }

        CloseGossipMenuFor(player);
        return true;
    }
};

std::unordered_map<uint64, int64> npc_warlock_pet_renamer::_lastRenameByPlayer;
std::unordered_map<uint64, std::string> npc_warlock_pet_renamer::_proposedName;
std::mutex npc_warlock_pet_renamer::_renameMutex;

void AddSC_npc_warlock_pet_renamer()
{
    new npc_warlock_pet_renamer();
}
