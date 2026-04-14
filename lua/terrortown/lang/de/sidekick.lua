local L = LANG.GetLanguageTableReference("de")

-- GENERAL ROLE LANGUAGE STRINGS
L[SIDEKICK.name] = "Kumpane"
L["target_" .. SIDEKICK.name] = "Kumpane"
L["ttt2_desc_" .. SIDEKICK.name] = [[Du musst mit deinem Mate gewinnen!]]
L["body_found_" .. SIDEKICK.abbr] = "Er war ein Kumpane!"
L["search_role_" .. SIDEKICK.abbr] = "Diese Person war ein Kumpane!"

-- OTHER ROLE LANGUAGE STRINGS
L["weapon_sidekickdeagle_name"] = "Kumpanendeagle"
L["weapon_sidekickdeagle_desc"] = "Schieße auf einen Spieler, um ihn zu deinem Kumpanen zu machen."

L["ttt2_siki_shot"] = "Erfolgreich {name} zu deinem Kumpanen geschossen!"
L["ttt2_siki_were_shot"] = "Du wurdest von {name} zu einem Kumpanen geschossen!"
L["ttt2_siki_sameteam"] = "Du kannst niemanden aus deinem eigenen Team zum Kumpanen schießen!"
L["ttt2_siki_ply_killed"] = "Deine Sidekick Deagle Wartezeit wurde um {amount} Sekunden reduziert."
L["ttt2_siki_recharged"] = "Deine Sidekick Deagle wurde wieder aufgefüllt."

L["label_siki_preventFindCredits"] = "Verhindere, dass Kumpanen Ausrüstungspunkte in Körpern finden können"
L["label_siki_protection_time"] = "Schutzzeit für neue Kumpanen"
L["help_siki_mode"] = [[
Was passiert, wenn ein Spieler ein Kumpane wird?

Modus 0: Kumpane wird nicht zu seinem ehemaligen Teamkameraden und kann nicht alleine gewinnen, aber erhält Ziele.
Modus 1: Kumpane wird bei deren Tod zu seinem ehemaligen Teamkameraden.
Modus 2: Kumpane wird nicht zu seinem ehemaligen Teamkameraden, kann aber alleine gewinnen und erhält Ziele.]]
L["label_siki_mode"] = "Welcher Modus soll aktiv sein?"
L["label_siki_mode_0"] = "Modus 0"
L["label_siki_mode_1"] = "Modus 1"
L["label_siki_mode_2"] = "Modus 2"
L["label_siki_deagle_refill"] = "Die Kumpanendeagle kann wieder aufgefüllt werden, wenn du einen Schuss verpasst hast."
L["label_siki_deagle_refill_cd"] = "Sekunden bis zum Auffüllen"
L["label_siki_deagle_refill_cd_per_kill"] = "Wartezeitsreduktion pro Kill"
