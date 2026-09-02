-- Spawns for the Warlock Pet Renamer NPC (entry 200002)
-- Locations matched from custom_spawns.sql

SET @Entry = 200002;
SET @GUID1 = 5300833;
SET @GUID2 = 5300835;

START TRANSACTION;

DELETE FROM `creature` WHERE `guid` IN (@GUID1, @GUID2);
DELETE FROM `creature_addon` WHERE `guid` IN (@GUID1, @GUID2);

INSERT INTO `creature` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnMask`, `phaseMask`, `equipment_id`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`, `wander_distance`, `currentwaypoint`, `curhealth`, `curmana`, `MovementType`, `npcflag`, `unit_flags`, `dynamicflags`, `ScriptName`, `VerifiedBuild`, `CreateObject`, `Comment`) VALUES
(@GUID1, @Entry, 0, 0, 0, 1, 1, 0, -8933.52, 967.673, 117.179, 4.65933, 300, 0, 0, 12600, 0, 0, 0, 0, 0, '', NULL, 0, NULL),
(@GUID2, @Entry, 1, 0, 0, 1, 1, 0, 1784.03, -4357.46, -14.3048, 0.137393, 300, 0, 0, 12600, 0, 0, 0, 0, 0, '', NULL, 0, NULL);

COMMIT;
