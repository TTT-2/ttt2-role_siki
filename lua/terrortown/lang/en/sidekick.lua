local L = LANG.GetLanguageTableReference("en")

-- GENERAL ROLE LANGUAGE STRINGS
L[SIDEKICK.name] = "Sidekick"
L["target_" .. SIDEKICK.name] = "Sidekick"
L["ttt2_desc_" .. SIDEKICK.name] = [[You are now a Sidekick. Help your new teammate win the round!]]
L["body_found_" .. SIDEKICK.abbr] = "They were a Sidekick."
L["search_role_" .. SIDEKICK.abbr] = "This person was a Sidekick!"

L["weapon_sidekickdeagle_name"] = "Sidekickdeagle"
L["weapon_sidekickdeagle_desc"] = "Shoot a player to make him your Sidekick."

L["ttt2_siki_shot"] = "Successfully shot {name} as your Sidekick!"
L["ttt2_siki_were_shot"] = "You were shot as a Sidekick by {name}!"
L["ttt2_siki_sameteam"] = "You can't shoot someone from your own team as Sidekick!"
L["ttt2_siki_ply_killed"] = "Your Sidekick Deagle cooldown was reduced by {amount} seconds."
L["ttt2_siki_recharged"] = "Your Sidekick Deagle has been recharged."
