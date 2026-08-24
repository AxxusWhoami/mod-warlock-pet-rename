SET @Entry = 200002;
SET @Name = "Funcionario Pútrido";
SET @Subname = "Registro civil de demonios";

START TRANSACTION;

DELETE FROM `creature_template_model` WHERE `CreatureID` = @Entry;
DELETE FROM `creature_template` WHERE `entry` = @Entry;
DELETE FROM `creature_template_locale` WHERE `entry` = @Entry;

INSERT INTO `creature_template` (`entry`, `name`, `subname`, `IconName`, `gossip_menu_id`, `minlevel`, `maxlevel`, `exp`, `faction`, `npcflag`, `rank`, `dmgschool`, `baseattacktime`, `rangeattacktime`, `unit_class`, `unit_flags`, `type`, `type_flags`, `lootid`, `pickpocketloot`, `skinloot`, `AIName`, `MovementType`, `HoverHeight`, `RacialLeader`, `movementId`, `RegenHealth`, `flags_extra`, `ScriptName`) VALUES
(@Entry, @Name, @Subname, null, 0, 80, 80, 2, 35, 1, 0, 0, 2000, 0, 1, 2147483648, 7, 138936390, 0, 0, 0, '', 0, 1, 0, 0, 1, 0, 'npc_warlock_pet_renamer')
ON DUPLICATE KEY UPDATE
    `name` = VALUES(`name`),
    `subname` = VALUES(`subname`),
    `IconName` = VALUES(`IconName`),
    `gossip_menu_id` = VALUES(`gossip_menu_id`),
    `minlevel` = VALUES(`minlevel`),
    `maxlevel` = VALUES(`maxlevel`),
    `exp` = VALUES(`exp`),
    `faction` = VALUES(`faction`),
    `npcflag` = VALUES(`npcflag`),
    `rank` = VALUES(`rank`),
    `dmgschool` = VALUES(`dmgschool`),
    `baseattacktime` = VALUES(`baseattacktime`),
    `rangeattacktime` = VALUES(`rangeattacktime`),
    `unit_class` = VALUES(`unit_class`),
    `unit_flags` = VALUES(`unit_flags`),
    `type` = VALUES(`type`),
    `type_flags` = VALUES(`type_flags`),
    `lootid` = VALUES(`lootid`),
    `pickpocketloot` = VALUES(`pickpocketloot`),
    `skinloot` = VALUES(`skinloot`),
    `AIName` = VALUES(`AIName`),
    `MovementType` = VALUES(`MovementType`),
    `HoverHeight` = VALUES(`HoverHeight`),
    `RacialLeader` = VALUES(`RacialLeader`),
    `movementId` = VALUES(`movementId`),
    `RegenHealth` = VALUES(`RegenHealth`),
    `flags_extra` = VALUES(`flags_extra`),
    `ScriptName` = VALUES(`ScriptName`);

INSERT INTO `creature_template_model` (`CreatureID`, `Idx`, `CreatureDisplayID`, `DisplayScale`, `Probability`, `VerifiedBuild`) VALUES (@Entry, 0, 19646, 1, 1, 0)
ON DUPLICATE KEY UPDATE
    `CreatureDisplayID` = VALUES(`CreatureDisplayID`),
    `DisplayScale` = VALUES(`DisplayScale`),
    `Probability` = VALUES(`Probability`),
    `VerifiedBuild` = VALUES(`VerifiedBuild`);

-- Locales: koKR, frFR, deDE, zhCN, zhTW, esES, esMX, ruRU
DELETE FROM `creature_template_locale` WHERE `entry` = @Entry;
INSERT INTO `creature_template_locale` (`entry`, `locale`, `Name`, `Title`, `VerifiedBuild`) VALUES
(@Entry, 'koKR', '부패한 관리', '악마 호적 사무소', 0),
(@Entry, 'frFR', 'Fonctionnaire Putride', 'Registre civil des démons', 0),
(@Entry, 'deDE', 'Fauliger Beamter', 'Standesamt für Dämonen', 0),
(@Entry, 'zhCN', '腐朽官员', '恶魔户籍登记处', 0),
(@Entry, 'zhTW', '腐朽官員', '惡魔戶籍登記處', 0),
(@Entry, 'esES', 'Funcionario Pútrido', 'Registro civil de demonios', 0),
(@Entry, 'esMX', 'Funcionario Pútrido', 'Registro civil de demonios', 0),
(@Entry, 'ruRU', 'Гнилостный Чиновник', 'Реестр демонов', 0)
ON DUPLICATE KEY UPDATE
    `Name` = VALUES(`Name`),
    `Title` = VALUES(`Title`),
    `VerifiedBuild` = VALUES(`VerifiedBuild`);

COMMIT;
