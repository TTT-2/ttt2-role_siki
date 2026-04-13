local L = LANG.GetLanguageTableReference("it")

-- GENERAL ROLE LANGUAGE STRINGS
L[SIDEKICK.name] = "Aiutante"
L["target_" .. SIDEKICK.name] = "Aiutante"
L["ttt2_desc_" .. SIDEKICK.name] = [[Devi vincere con il tuo compagno!]]
L["body_found_" .. SIDEKICK.abbr] = "Era un Aiutante..."
L["search_role_" .. SIDEKICK.abbr] = "Questa persona era un Aiutante!"

-- OTHER ROLE LANGUAGE STRINGS
L["weapon_sidekickdeagle_name"] = "Deagle Aiutante"
L["weapon_sidekickdeagle_desc"] = "Spara ad una persona per farla diventare tuo Aiutante."

L["ttt2_siki_shot"] = "Convertito correttamente a {name} come tuo Aiutante!"
L["ttt2_siki_were_shot"] = "Sei stato convertito come Aiutante da {name}!"
L["ttt2_siki_sameteam"] = "Non puoi convertire qualcuno del tuo stesso team come Aiutante!"
L["ttt2_siki_ply_killed"] = "E' stato ridotto il tempo di ricarica della Deagle Aiutante di {amount}s."
L["ttt2_siki_recharged"] = "La tua Deagle Aiutante si è ricaricata."

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
