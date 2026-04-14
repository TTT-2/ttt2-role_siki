local L = LANG.GetLanguageTableReference("tr")

-- GENERAL ROLE LANGUAGE STRINGS
L[SIDEKICK.name] = "Yardımcı"
L["target_" .. SIDEKICK.name] = "Yardımcı"
L["ttt2_desc_" .. SIDEKICK.name] = [[Şimdi bir Yardımcısın. Yeni takım arkadaşınızın raundu kazanmasına yardım et!]]
L["body_found_" .. SIDEKICK.abbr] = "Onlar bir Yardımcıydı."
L["search_role_" .. SIDEKICK.abbr] = "Bu kişi bir Yardımcıydı!"

-- OTHER ROLE LANGUAGE STRINGS
L["weapon_sidekickdeagle_name"] = "Yardımcı Deagle'ı"
L["weapon_sidekickdeagle_desc"] = "Bir oyuncuyu Yardımcın yapmak için vurun."

L["ttt2_siki_shot"] = "{name} adlı oyuncuyu Yardımcın olarak başarıyla vurdun!"
L["ttt2_siki_were_shot"] = "{name} tarafından bir Yardımcı olarak vuruldun!"
L["ttt2_siki_sameteam"] = "Kendi takımından birini Yardımcın olarak vuramazsın!"
L["ttt2_siki_ply_killed"] = "Yardımcı Deagle bekleme süreniz {amount} saniye azaltıldı."
L["ttt2_siki_recharged"] = "Yardımcı Deagle'ınız yeniden doldu."

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
