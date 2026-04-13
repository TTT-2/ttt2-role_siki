local L = LANG.GetLanguageTableReference("ru")

-- GENERAL ROLE LANGUAGE STRINGS
L[SIDEKICK.name] = "Сообщник"
L["target_" .. SIDEKICK.name] = "Сообщник"
L["ttt2_desc_" .. SIDEKICK.name] = [[Теперь вы сообщник! Помогите своему новому товарищу выиграть раунд!]]
L["body_found_" .. SIDEKICK.abbr] = "Он был сообщником."
L["search_role_" .. SIDEKICK.abbr] = "Этот человек был сообщником!"

-- OTHER ROLE LANGUAGE STRINGS
L["weapon_sidekickdeagle_name"] = "Deagle сообщника"
L["weapon_sidekickdeagle_desc"] = "Выстрелите в игрока, чтобы сделать его своим сообщником."

L["ttt2_siki_shot"] = "Успешное попадание в {name} с превращением в сообщника!"
L["ttt2_siki_were_shot"] = "{name} попадает в вас и делает сообщником!"
L["ttt2_siki_sameteam"] = "Вы не можете стрелять в кого-либо из своей команды, будучи сообщником!"
L["ttt2_siki_ply_killed"] = "Перезарядка Deagle сообщника была сокращена на {amount} сек."
L["ttt2_siki_recharged"] = "Ваш Deagle сообщника перезарядился."

--L["label_siki_preventFindCredits"] = "Prevent Sidekicks from finding credits in bodies"
--L["label_siki_protection_time"] = "Protection Time for new Sidekick"
--L["help_siki_mode"] = [[
--What happens when a player becomes a Sidekick?

--Mode 0: Sidekick doesn't become his former teammate and can't win alone, but gets targets.
--Mode 1: Sidekick becomes his former teammate upon their death. 
--Mode 2: Sidekick doesn't become his former teammate but can win alone and gets targets.]]
--L["label_siki_mode"] = "Which mode should be active?"
--L["label_siki_mode_0"] = "Mode 0"
--L["label_siki_mode_1"] = "Mode 1"
--L["label_siki_mode_2"] = "Mode 2"
--L["label_siki_deagle_refill"] = "The Sidekick Deagle can be refilled when you missed a shot."
--L["label_siki_deagle_refill_cd"] = "Seconds to Refill"
--L["label_siki_deagle_refill_cd_per_kill"] = "CD Reduction per Kill"
