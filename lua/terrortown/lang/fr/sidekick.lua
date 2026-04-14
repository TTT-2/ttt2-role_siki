local L = LANG.GetLanguageTableReference("fr")

-- GENERAL ROLE LANGUAGE STRINGS
L[SIDEKICK.name] = "Acolyte"
L["target_" .. SIDEKICK.name] = "Acolyte"
L["ttt2_desc_" .. SIDEKICK.name] = [[Vous êtes un Acolyte. Aidez votre nouveau coéquipier à remporter la manche!]]
L["body_found_" .. SIDEKICK.abbr] = "C'était un Acolyte."
L["search_role_" .. SIDEKICK.abbr] = "Cette personne était un Acolyte!"

-- OTHER ROLE LANGUAGE STRINGS
L["weapon_sidekickdeagle_name"] = "Deagle de l'Acolyte"
L["weapon_sidekickdeagle_desc"] = "Tirez sur un joueur pour qu'il devienne votre Acolyte."

L["ttt2_siki_shot"] = "Votre tir a réussi à faire de {name} votre Acolyte!"
L["ttt2_siki_were_shot"] = "Vous avez été converti en Acolyte par {name}!"
L["ttt2_siki_sameteam"] = "Vous ne pouvez pas tirer sur quelqu'un de votre propre team en tant qu'Acolyte!"
L["ttt2_siki_ply_killed"] = "Le rechargement de votre Deagle d'Acolyte a été réduit de {amount} secondes."
L["ttt2_siki_recharged"] = "Votre Deagle d'Acolyte a été rechargé."

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
