SET @Entry = 200002;
SET @Name = "Lucius Sombra";
SET @Subname = "Rename Master";

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
(@Entry, 'koKR', '루시우스 솜브라', '이름 변경 대가', 0),
(@Entry, 'frFR', 'Lucius Sombra', 'Maître des renoms', 0),
(@Entry, 'deDE', 'Lucius Sombra', 'Meister der Umbenennung', 0),
(@Entry, 'zhCN', '卢修斯·索姆布拉', '改名大师', 0),
(@Entry, 'zhTW', '盧修斯·索姆布拉', '改名大師', 0),
(@Entry, 'esES', 'Lucius Sombra', 'Maestro de renombre', 0),
(@Entry, 'esMX', 'Lucius Sombra', 'Maestro de renombre', 0),
(@Entry, 'ruRU', 'Люций Сомбра', 'Мастер переименования', 0)
ON DUPLICATE KEY UPDATE
    `Name` = VALUES(`Name`),
    `Title` = VALUES(`Title`),
    `VerifiedBuild` = VALUES(`VerifiedBuild`);

COMMIT;
