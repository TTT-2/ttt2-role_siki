if SERVER then
	AddCSLuaFile()
end

local sikiMat
local indicator_siki_col

local plymeta = FindMetaTable("Player")
if not plymeta then return end

function plymeta:IsSidekick()
	return self:GetNWEntity("binded_sidekick") ~= nil
end

function plymeta:GetSidekickMate()
	return self:GetNWEntity("binded_sidekick")
end

if SERVER then
	resource.AddFile("materials/vgui/ttt/icon_siki.vmt")
	resource.AddFile("materials/vgui/ttt/sprite_siki.vmt")
else
	local indicator_siki_col = Color(255, 255, 255, 130)
end

hook.Add("Initialize", "TTT2InitCRoleSiki", function()
	-- important to add roles with this function,
	-- because it does more than just access the array ! e.g. updating other arrays
	AddCustomRole("SIDEKICK", { -- first param is access for ROLES array => ROLES.SIDEKICK or ROLES["SIDEKICK"]
		color = Color(0, 0, 0, 255), -- ...
		dkcolor = Color(0, 0, 0, 255), -- ...
		bgcolor = Color(0, 0, 0, 200), -- ...
		name = "sidekick", -- just a unique name for the script to determine
		printName = "Sidekick", -- The text that is printed to the player, e.g. in role alert
		abbr = "siki", -- abbreviation
		shop = true, -- can the role access the [C] shop ?
		team = "sikis", -- the team name: roles with same team name are working together
		defaultEquipment = SPECIAL_EQUIPMENT, -- here you can set up your own default equipment 
		surviveBonus = 1, -- bonus multiplier for every survive while another player was killed
		scoreKillsMultiplier = 5, -- multiplier for kill of player of another team
		scoreTeamKillsMultiplier = -16, -- multiplier for teamkill
		preventWin = true,
		notSelectable = true -- role cant be selected !
	},
	{
		shopFallback = SHOP_FALLBACK_TRAITOR
	})
end)

-- if sync of roles has finished
if CLIENT then
    hook.Add("TTT2_FinishedSync", "SikiInitT", function(ply, first)
        if first then -- just on client and first init !
			sikiMat = Material("vgui/ttt/sprite_" .. ROLES.SIDEKICK.abbr)

            -- setup here is not necessary but if you want to access the role data, you need to start here
            -- setup basic translation !
            LANG.AddToLanguage("English", ROLES.SIDEKICK.name, "Sidekick")
            LANG.AddToLanguage("English", "target_" .. ROLES.SIDEKICK.name, "Sidekick")
            LANG.AddToLanguage("English", "ttt2_desc_" .. ROLES.SIDEKICK.name, [[You need to win with your mate!]])
            LANG.AddToLanguage("English", "body_found_" .. ROLES.SIDEKICK.abbr, "This was a Sidekick...")
            LANG.AddToLanguage("English", "search_role_" .. ROLES.SIDEKICK.abbr, "This person was a Sidekick!")
            
            ---------------------------------

            -- maybe this language as well...
            LANG.AddToLanguage("Deutsch", ROLES.SIDEKICK.name, "Sidekick")
            LANG.AddToLanguage("Deutsch", "target_" .. ROLES.SIDEKICK.name, "Sidekick")
            LANG.AddToLanguage("Deutsch", "ttt2_desc_" .. ROLES.SIDEKICK.name, [[Du musst mit deinem Mate gewinnen!]])
            LANG.AddToLanguage("Deutsch", "body_found_" .. ROLES.SIDEKICK.abbr, "Er war ein Sidekick...")
            LANG.AddToLanguage("Deutsch", "search_role_" .. ROLES.SIDEKICK.abbr, "Diese Person war ein Sidekick!")
        end
    end)
end

function HealPlayer(ply)
    ply:SetHealth(ply:GetMaxHealth())
end
    
hook.Add("TTT2_SearchBodyRole", "SikiSBS", function(ply)
	if ply:GetRole() ~= ROLES.SIDEKICK.index then return end

    local bindedPlayer = ply:GetSidekickMate()
    
    if bindedPlayer and IsValid(bindedPlayer) and bindedPlayer:IsPlayer() then
        return bindedPlayer:GetRoleData().index
    end
end)

if SERVER then
    util.AddNetworkString("TTT_HealPlayer")
    util.AddNetworkString("TTT_SendMateRole")

    BINDED_PLAYER = {}
    
    function AddSidekick(target, attacker)
		if BINDED_PLAYER[target] then return end
	
        BINDED_PLAYER[target] = attacker
        
        attacker:SetNWEntity("binded_sidekick", target)
        
        target:UpdateRole(ROLES.SIDEKICK.index)
        target:SetDefaultCredits()
        
        SendFullStateUpdate()
    end
    
    function SendMateRole(siki, mate)
        if not IsValid(siki) or not siki:IsPlayer() then return end
        
        if not IsValid(mate) or not mate:IsPlayer() then return end
    
        siki.mateRole = mate.mateRole or mate:GetRole() -- if mate is sidekick too, give him the role of its mate
        
        net.Start("TTT_SendMateRole")
        net.WriteUInt(siki.mateRole - 1, ROLE_BITS)
        net.Send(siki)
    end
    
    hook.Add("TTT2_SendFullStateUpdate", "SikiFullStateUpdate", function()
        for _, ply in pairs(player.GetAll()) do
            if ply:GetRole() == ROLES.SIDEKICK.index then
                local mate = BINDED_PLAYER[ply]
                
                if mate and IsValid(mate) then
                    if IsValid(mate) and mate:IsPlayer() then
                        SendRoleListMessage(ROLES.SIDEKICK.index, {ply:EntIndex()}, mate)
                        SendRoleListMessage(mate:GetRole(), {mate:EntIndex()}, ply)
        
						SendMateRole(ply, mate)
                    end
                end
            end
        end
    end)
    
    hook.Add("EntityTakeDamage", "SikiEntTakeDmg", function(target, dmginfo)
        local attacker = dmginfo:GetAttacker()
    
        if target:IsPlayer() and IsValid(attacker) and attacker:IsPlayer() then
            if (target:Health() - dmginfo:GetDamage()) <= 0 and hook.Run("TTT2_SIKI_CanAttackerSidekick", attacker, target) then
                dmginfo:ScaleDamage(0)
                
                local tName = "FreezeSidekickForInit_" .. target:SteamID()
                    
                if not timer.Exists(tName) then
                    target:Freeze(true)
                    
                    timer.Create(tName, 1, 1, function() 
                        target:Freeze(false)
                    end)
                end
                
                AddSidekick(target, attacker)
        
                HealPlayer(target)
                
                -- do this clientside as well
                net.Start("TTT_HealPlayer")
                net.Send(target)
            end
        end
    end)
    
	--[[
    hook.Add("PlayerDeath", "SikiPlayerDeath", function(victim, infl, attacker)
        if not IsValid(victim) or not victim:IsPlayer() then return end
        
        local siki = victim:GetNWEntity("binded_sidekick")
        
        if not IsValid(siki) or not siki:IsPlayer() then return end
    end)
	]]--
    
    hook.Add("PlayerDisconnected", "SikiPlyDisconnected", function(discPly)
        local tmpSK
        
        for siki, ply in pairs(BINDED_PLAYER) do
            if siki == discPly then
                tmpSK = siki
            elseif ply == discPly then
                tmpSK = siki
                
                siki:SetNWEntity("binded_sidekick", nil)
				
				siki:UpdateRole(siki.mateRole or (IsValid(discPly) and discPly:GetRole()))
            end
            
            if tmpSK then
                break
            end
        end
        
        if tmpSK then
            BINDED_PLAYER[tmpSK] = nil
        end
    end)
    
    hook.Add("TTTPrepareRound", "SikiBeginRound", function()
        for siki, ply in pairs(BINDED_PLAYER) do
            siki.mateRole = nil
            
            ply:SetNWEntity("binded_sidekick", nil)
        end
        
        BINDED_PLAYER = {}
    end)
    
    hook.Add("TTTEndRound", "SikiEndRound", function()
        for _, ply in pairs(BINDED_PLAYER) do
            ply:SetNWEntity("binded_sidekick", nil)
        end
        
        BINDED_PLAYER = {}
    end)

	hook.Add("TTT2_ModifyWinningAlives", "SidekickModifyWinningAlives", function(alive)
		for _, ply in pairs(player.GetAll()) do
			if ply:GetRole() == ROLES.SIDEKICK.index and ply:IsActive() then
                local role
                local tly = BINDED_PLAYER[ply]
                
                if tly and IsValid(tly) then
                    role = tly:GetRole()
                end
                
                role = ply.mateRole or role
                
                if role then
                    alive[role] = true
                end
			end
		end
	end)
    
    hook.Add("TTT2_PostPlayerCanHearPlayersVoice", "SikiPPCHPV", function(listener, speaker)
        if BINDED_PLAYER[listener] == speaker or BINDED_PLAYER[speaker] == listener then
            if speaker:IsActive() then
                if speaker[speaker:GetRoleData().team .. "_gvoice"] then
                    return true, loc_voice:GetBool()
                elseif listener:IsActive() then
                    return true, false
                else
                    -- unless [TEAM]_gvoice is true, normal innos can't hear speaker
                    return false, false
                end
            end
        end
    end)

    hook.Add("TTT2_ScoringGettingRole", "SikiSGR", function(ply)
        if IsValid(ply) and ply:GetRole() == ROLES.SIDEKICK.index then
            local tly = BINDED_PLAYER[ply]
            
            if tly and IsValid(tly) and not ply.mateRole then
                return tly:GetRoleData()
            end
            
            return GetRoleByIndex(ply.mateRole)
        end
    end)
	
	hook.Add("TTT2_ModifyScoringEvent", "SikiModifyScoringEvent", function(event, data)
		if event.id == EVENT_KILL then
			local victim = data.victim
			local attacker = data.attacker
			
			if IsValid(victim) and victim:IsPlayer() and victim:IsSidekick() and victim.mateRole then
				event.vic.r = victim.mateRole
			end
			
			if IsValid(attacker) and attacker:IsPlayer() and attacker:IsSidekick() and attacker.mateRole then
				event.att.r = attacker.mateRole
			end
		end
	end)
else -- CLIENT
    net.Receive("TTT_HealPlayer", function()
        HealPlayer(LocalPlayer())
    end)
    
    net.Receive("TTT_SendMateRole", function()
        local role = net.ReadUInt(ROLE_BITS) + 1
        
        LocalPlayer().mateRole = role
    end)
    
    hook.Add("TTTPrepareRound", "SikiBeginRound", function()
        LocalPlayer().mateRole = nil
    end)
    
    hook.Add("TTT2_PreventAccessShop", "SikiPreventShop", function(ply)
        -- prevent sidekick of serialkiller is able to shop
        if ply:GetRole() == ROLES.SIDEKICK.index and (
			ROLES.SERIALKILLER or
			ROLES.JACKAL
		) then
            local bindedPlayer = ply:GetNWEntity("binded_sidekick")
        
            if bindedPlayer and IsValid(bindedPlayer) and bindedPlayer:IsPlayer() and (
				ROLES.SERIALKILLER and bindedPlayer:GetRole() == ROLES.SERIALKILLER.index or
				ROLES.JACKAL and bindedPlayer:GetRole() == ROLES.JACKAL.index
			) then
                return true
            end
        end
    end)
    
	-- TODO everytime visible
    hook.Add("PostDrawTranslucentRenderables", "PostDrawSikiTransRend", function()
		local dir, pos
		
        local client = LocalPlayer()
		local trace = client:GetEyeTrace(MASK_SHOT)
		local ent = trace.Entity

		if not IsValid(ent) or ent.NoTarget or not ent:IsPlayer() or not ent.GetRole or not ent:GetRole() or ent:GetRole() <= 0 then return end -- sometimes strange things happens... -- gmod, u know
		
		if client:IsActive() and (client:GetRole() == ROLES.SIDEKICK.index and client:GetSidekickMate() == ent or ent:GetRole() == ROLES.SIDEKICK.index) then
			dir = (client:GetForward() * -1)

			pos = ent:GetPos()
			pos.z = pos.z + 74

			if ent ~= client then
				if ent:IsActive() then
					if sikiMat then
						render.SetMaterial(sikiMat)
						render.DrawQuadEasy(pos, dir, 8, 8, indicator_siki_col, 180)
					end
				end
			end
		end
    end)
end
