-- Spawns for the Warlock Pet Renamer NPC (entry 200002)
-- Locations matched from custom_spawns.sql

SET @Entry = 200002;

START TRANSACTION;

DELETE FROM `creature` WHERE `id` = @Entry
    AND `position_x` IN (-8933.52, 1784.03)
    AND `position_y` IN (967.673, -4357.46);

INSERT INTO `creature` (`id`, `map`, `zoneId`, `areaId`, `spawnMask`, `phaseMask`, `equipment_id`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`, `wander_distance`, `currentwaypoint`, `curhealth`, `curmana`, `MovementType`, `npcflag`, `unit_flags`, `dynamicflags`, `ScriptName`, `VerifiedBuild`, `CreateObject`, `Comment`) VALUES
(@Entry, 0, 0, 0, 1, 1, 0, -8933.52, 967.673, 117.179, 4.65933, 300, 0, 0, 12600, 0, 0, 0, 0, 0, '', NULL, 0, NULL),
(@Entry, 1, 0, 0, 1, 1, 0, 1784.03, -4357.46, -14.3048, 0.137393, 300, 0, 0, 12600, 0, 0, 0, 0, 0, '', NULL, 0, NULL);

COMMIT;
