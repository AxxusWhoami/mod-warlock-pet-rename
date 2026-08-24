-- Module strings for mod-warlock-pet-rename
-- Moves all hardcoded gossip and system messages into module_string / module_string_locale
-- The {} placeholder in strings 4, 5, 7, 9 is replaced at runtime with the configured cost

SET @MODULE = 'mod-warlock-pet-rename';

START TRANSACTION;

DELETE FROM `module_string` WHERE `module` = @MODULE;
DELETE FROM `module_string_locale` WHERE `module` = @MODULE;

-- String IDs:
-- 1  WARLOCKS ONLY
-- 2  PLEASE SUMMON YOUR PET
-- 3  Current pet: {}
-- 4  Rename current pet ({cost})
-- 5  Type in your desired pet name in the next popup! Cost: {cost}
-- 6  Nevermind...
-- 7  Confirm: Rename pet to '{}' for {cost}?
-- 8  Cancel
-- 9  You don't have enough gold. The rename costs {cost}.
-- 10 You must wait a moment before renaming your pet again.
-- 11 infernal
-- 12 imp
-- 13 felhunter
-- 14 voidwalker
-- 15 succubus
-- 16 doomguard
-- 17 felguard
-- 18 unknown

INSERT INTO `module_string` (`module`, `id`, `string`) VALUES
(@MODULE, 1,  '|cffb50505WARLOCKS ONLY|r'),
(@MODULE, 2,  '|cffb50505PLEASE SUMMON YOUR PET|r'),
(@MODULE, 3,  'Current pet: {}'),
(@MODULE, 4,  'Rename current pet ({})'),
(@MODULE, 5,  'Type in your desired pet name in the next popup! Cost: {}'),
(@MODULE, 6,  'Nevermind...'),
(@MODULE, 7,  'Confirm: Rename pet to \'{}\' for {}?'),
(@MODULE, 8,  'Cancel'),
(@MODULE, 9,  'You don\'t have enough gold. The rename costs {}.'),
(@MODULE, 10, 'You must wait a moment before renaming your pet again.'),
(@MODULE, 11, 'infernal'),
(@MODULE, 12, 'imp'),
(@MODULE, 13, 'felhunter'),
(@MODULE, 14, 'voidwalker'),
(@MODULE, 15, 'succubus'),
(@MODULE, 16, 'doomguard'),
(@MODULE, 17, 'felguard'),
(@MODULE, 18, 'unknown');

INSERT INTO `module_string_locale` (`module`, `id`, `locale`, `string`) VALUES
-- koKR
(@MODULE, 1,  'koKR', '|cffb50505흑마술사 전용|r'),
(@MODULE, 2,  'koKR', '|cffb50505소환수를 소환해 주세요|r'),
(@MODULE, 3,  'koKR', '현재 소환수: {}'),
(@MODULE, 4,  'koKR', '현재 소환수 이름 변경 ({})'),
(@MODULE, 5,  'koKR', '다음 팝업에서 원하는 소환수 이름을 입력하세요! 비용: {}'),
(@MODULE, 6,  'koKR', '취소...'),
(@MODULE, 7,  'koKR', '확인: 소환수 이름을 \'{}\'(으)로 변경하시겠습니까? 비용: {}?'),
(@MODULE, 8,  'koKR', '취소'),
(@MODULE, 9,  'koKR', '골드가 부족합니다. 이름 변경 비용은 {}입니다.'),
(@MODULE, 10, 'koKR', '소환수 이름을 다시 변경하려면 잠시 기다려야 합니다.'),
(@MODULE, 11, 'koKR', '지옥정령'),
(@MODULE, 12, 'koKR', '임프'),
(@MODULE, 13, 'koKR', '지옥사냥개'),
(@MODULE, 14, 'koKR', '공허의 수호자'),
(@MODULE, 15, 'koKR', '서큐버스'),
(@MODULE, 16, 'koKR', '파멸의 수호자'),
(@MODULE, 17, 'koKR', '지옥수호병'),
(@MODULE, 18, 'koKR', '알 수 없음'),

-- frFR
(@MODULE, 1,  'frFR', '|cffb50505DÉMONISTES UNIQUEMENT|r'),
(@MODULE, 2,  'frFR', '|cffb50505VEUILLEZ INVOQUER VOTRE FAMILIER|r'),
(@MODULE, 3,  'frFR', 'Familier actuel : {}'),
(@MODULE, 4,  'frFR', 'Renommer le familier actuel ({})'),
(@MODULE, 5,  'frFR', 'Saisissez le nom de familier souhaité dans la fenêtre suivante ! Coût : {}'),
(@MODULE, 6,  'frFR', 'Peu importe...'),
(@MODULE, 7,  'frFR', 'Confirmer : Renommer le familier en \'{}\' pour {} ?'),
(@MODULE, 8,  'frFR', 'Annuler'),
(@MODULE, 9,  'frFR', 'Vous n\'avez pas assez d\'or. Le changement de nom coûte {}.'),
(@MODULE, 10, 'frFR', 'Vous devez attendre un moment avant de renommer votre familier à nouveau.'),
(@MODULE, 11, 'frFR', 'infernal'),
(@MODULE, 12, 'frFR', 'diablotin'),
(@MODULE, 13, 'frFR', 'chasseur corrompu'),
(@MODULE, 14, 'frFR', 'marche-void'),
(@MODULE, 15, 'frFR', 'succube'),
(@MODULE, 16, 'frFR', 'gardien de doomguard'),
(@MODULE, 17, 'frFR', 'garde funeste'),
(@MODULE, 18, 'frFR', 'inconnu'),

-- deDE
(@MODULE, 1,  'deDE', '|cffb50505NUR HEXENMEISTER|r'),
(@MODULE, 2,  'deDE', '|cffb50505BITTE BESCHWÖRT EUER HAUSTIER|r'),
(@MODULE, 3,  'deDE', 'Aktuelles Haustier: {}'),
(@MODULE, 4,  'deDE', 'Aktuelles Haustier umbenennen ({})'),
(@MODULE, 5,  'deDE', 'Gebt den gewünschten Haustiernamen im nächsten Popup ein! Kosten: {}'),
(@MODULE, 6,  'deDE', 'Vergiss es...'),
(@MODULE, 7,  'deDE', 'Bestätigen: Haustier in \'{}\' umbenennen für {}?'),
(@MODULE, 8,  'deDE', 'Abbrechen'),
(@MODULE, 9,  'deDE', 'Ihr habt nicht genug Gold. Die Umbenennung kostet {}.'),
(@MODULE, 10, 'deDE', 'Ihr müsst einen Moment warten, bevor ihr euer Haustier wieder umbenennt.'),
(@MODULE, 11, 'deDE', 'Höllenbestie'),
(@MODULE, 12, 'deDE', 'Wichtel'),
(@MODULE, 13, 'deDE', 'Teufelsjäger'),
(@MODULE, 14, 'deDE', 'Leerwandler'),
(@MODULE, 15, 'deDE', 'Sukkubus'),
(@MODULE, 16, 'deDE', 'Verdammniswache'),
(@MODULE, 17, 'deDE', 'Teufelswache'),
(@MODULE, 18, 'deDE', 'unbekannt'),

-- zhCN
(@MODULE, 1,  'zhCN', '|cffb50505仅限术士|r'),
(@MODULE, 2,  'zhCN', '|cffb50505请召唤你的宠物|r'),
(@MODULE, 3,  'zhCN', '当前宠物：{}'),
(@MODULE, 4,  'zhCN', '重命名当前宠物（{}）'),
(@MODULE, 5,  'zhCN', '在下一个弹出窗口中输入你想要的宠物名字！费用：{}'),
(@MODULE, 6,  'zhCN', '算了...'),
(@MODULE, 7,  'zhCN', '确认：将宠物重命名为'{}'，花费{}？'),
(@MODULE, 8,  'zhCN', '取消'),
(@MODULE, 9,  'zhCN', '你没有足够的金币。重命名需要{}。'),
(@MODULE, 10, 'zhCN', '你需要等一会儿才能再次重命名你的宠物。'),
(@MODULE, 11, 'zhCN', '地狱火'),
(@MODULE, 12, 'zhCN', '小鬼'),
(@MODULE, 13, 'zhCN', '地狱猎犬'),
(@MODULE, 14, 'zhCN', '虚空行者'),
(@MODULE, 15, 'zhCN', '魅魔'),
(@MODULE, 16, 'zhCN', '末日守卫'),
(@MODULE, 17, 'zhCN', '恶魔守卫'),
(@MODULE, 18, 'zhCN', '未知'),

-- zhTW
(@MODULE, 1,  'zhTW', '|cffb50505僅限術士|r'),
(@MODULE, 2,  'zhTW', '|cffb50505請召喚你的寵物|r'),
(@MODULE, 3,  'zhTW', '當前寵物：{}'),
(@MODULE, 4,  'zhTW', '重新命名當前寵物（{}）'),
(@MODULE, 5,  'zhTW', '在下一個彈出視窗中輸入你想要的寵物名字！費用：{}'),
(@MODULE, 6,  'zhTW', '算了...'),
(@MODULE, 7,  'zhTW', '確認：將寵物重新命名為'{}'，花費{}？'),
(@MODULE, 8,  'zhTW', '取消'),
(@MODULE, 9,  'zhTW', '你沒有足夠的金幣。重新命名需要{}。'),
(@MODULE, 10, 'zhTW', '你需要等一會兒才能再次重新命名你的寵物。'),
(@MODULE, 11, 'zhTW', '地獄火'),
(@MODULE, 12, 'zhTW', '小鬼'),
(@MODULE, 13, 'zhTW', '地獄獵犬'),
(@MODULE, 14, 'zhTW', '虛空行者'),
(@MODULE, 15, 'zhTW', '魅魔'),
(@MODULE, 16, 'zhTW', '末日守衛'),
(@MODULE, 17, 'zhTW', '惡魔守衛'),
(@MODULE, 18, 'zhTW', '未知'),

-- esES
(@MODULE, 1,  'esES', '|cffb50505SOLO BRUJOS|r'),
(@MODULE, 2,  'esES', '|cffb50505POR FAVOR, INVOCAD A VUESTRA MASCOTA|r'),
(@MODULE, 3,  'esES', 'Mascota actual: {}'),
(@MODULE, 4,  'esES', 'Renombrar la mascota actual ({})'),
(@MODULE, 5,  'esES', '¡Escribe el nombre deseado para tu mascota en la siguiente ventana! Coste: {}'),
(@MODULE, 6,  'esES', 'No importa...'),
(@MODULE, 7,  'esES', 'Confirmar: ¿Renombrar la mascota a \'{}\' por {}?'),
(@MODULE, 8,  'esES', 'Cancelar'),
(@MODULE, 9,  'esES', 'No tienes suficiente oro. El renombrado cuesta {}.'),
(@MODULE, 10, 'esES', 'Debes esperar un momento antes de renombrar a tu mascota de nuevo.'),
(@MODULE, 11, 'esES', 'infernal'),
(@MODULE, 12, 'esES', 'diablillo'),
(@MODULE, 13, 'esES', 'sabueso vil'),
(@MODULE, 14, 'esES', 'abisario'),
(@MODULE, 15, 'esES', 'súcubo'),
(@MODULE, 16, 'esES', 'guardia maldito'),
(@MODULE, 17, 'esES', 'guardia vil'),
(@MODULE, 18, 'esES', 'desconocido'),

-- esMX
(@MODULE, 1,  'esMX', '|cffb50505SOLO BRUJOS|r'),
(@MODULE, 2,  'esMX', '|cffb50505POR FAVOR, INVOCAD A VUESTRA MASCOTA|r'),
(@MODULE, 3,  'esMX', 'Mascota actual: {}'),
(@MODULE, 4,  'esMX', 'Renombrar la mascota actual ({})'),
(@MODULE, 5,  'esMX', '¡Escribe el nombre deseado para tu mascota en la siguiente ventana! Coste: {}'),
(@MODULE, 6,  'esMX', 'No importa...'),
(@MODULE, 7,  'esMX', 'Confirmar: ¿Renombrar la mascota a \'{}\' por {}?'),
(@MODULE, 8,  'esMX', 'Cancelar'),
(@MODULE, 9,  'esMX', 'No tienes suficiente oro. El renombrado cuesta {}.'),
(@MODULE, 10, 'esMX', 'Debes esperar un momento antes de renombrar a tu mascota de nuevo.'),
(@MODULE, 11, 'esMX', 'infernal'),
(@MODULE, 12, 'esMX', 'diablillo'),
(@MODULE, 13, 'esMX', 'sabueso vil'),
(@MODULE, 14, 'esMX', 'abisario'),
(@MODULE, 15, 'esMX', 'súcubo'),
(@MODULE, 16, 'esMX', 'guardia maldito'),
(@MODULE, 17, 'esMX', 'guardia vil'),
(@MODULE, 18, 'esMX', 'desconocido'),

-- ruRU
(@MODULE, 1,  'ruRU', '|cffb50505ТОЛЬКО ДЛЯ ЧЕРНОКНИЖНИКОВ|r'),
(@MODULE, 2,  'ruRU', '|cffb50505ПОЖАЛУЙСТА, ПРИЗОВИТЕ ВАШЕГО ПИТОМЦА|r'),
(@MODULE, 3,  'ruRU', 'Текущий питомец: {}'),
(@MODULE, 4,  'ruRU', 'Переименовать текущего питомца ({})'),
(@MODULE, 5,  'ruRU', 'Введите желаемое имя питомца в следующем окне! Стоимость: {}'),
(@MODULE, 6,  'ruRU', 'Неважно...'),
(@MODULE, 7,  'ruRU', 'Подтвердить: Переименовать питомца в \'{}\' за {}?'),
(@MODULE, 8,  'ruRU', 'Отмена'),
(@MODULE, 9,  'ruRU', 'У вас недостаточно золота. Переименование стоит {}.'),
(@MODULE, 10, 'ruRU', 'Вы должны немного подождать, прежде чем снова переименовать питомца.'),
(@MODULE, 11, 'ruRU', 'инфернал'),
(@MODULE, 12, 'ruRU', 'бес'),
(@MODULE, 13, 'ruRU', 'охотник Скверны'),
(@MODULE, 14, 'ruRU', 'пустотник'),
(@MODULE, 15, 'ruRU', 'суккуб'),
(@MODULE, 16, 'ruRU', 'страж ужаса'),
(@MODULE, 17, 'ruRU', 'страж Скверны'),
(@MODULE, 18, 'ruRU', 'неизвестно');

COMMIT;
