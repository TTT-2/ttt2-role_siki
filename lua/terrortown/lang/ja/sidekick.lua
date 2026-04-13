local L = LANG.GetLanguageTableReference("ja")

-- GENERAL ROLE LANGUAGE STRINGS
L[SIDEKICK.name] = "Sidekick"
L["target_" .. SIDEKICK.name] = "Sidekick"
L["ttt2_desc_" .. SIDEKICK.name] = [[あなたはSidekickだ。主人を守り、勝利へ導こう！]]
L["body_found_" .. SIDEKICK.abbr] = "奴はSidekickだったようだな。"
L["search_role_" .. SIDEKICK.abbr] = "こいつはSidekickだったようだな！"

-- OTHER ROLE LANGUAGE STRINGS
L["weapon_sidekickdeagle_name"] = "Sidekick Deagle"
L["weapon_sidekickdeagle_desc"] = "誰かに撃つとその人が自分の仲間、Sidekickになる。"

L["ttt2_siki_shot"] = "{name}をSidekickにした！"
L["ttt2_siki_were_shot"] = "{name}にSidekickにされた！"
L["ttt2_siki_sameteam"] = "Sidekickのように、自分の陣営の者の誰かは撃つことはできないぞ！"
L["ttt2_siki_ply_killed"] = "Sidekickのクールダウン終了まで{amount}秒"
L["ttt2_siki_recharged"] = "Sidekick Deagleがもう一回使えるようになったぞ。"

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
