if SERVER then
	AddCSLuaFile()
end

local plymeta = FindMetaTable("Player")
if not plymeta then return end

function plymeta:IsSidekick()
	return IsValid(self:GetNWEntity("binded_sidekick", nil))
end

function plymeta:GetSidekickMate()
	local data = self:GetNWEntity("binded_sidekick", nil)
	
	if IsValid(data) then
		return data
	end
end

function plymeta:GetSidekicks()
	local tmp = {}

	for _, v in ipairs(player.GetAll()) do
		if v:GetRole() == ROLES.SIDEKICK.index then
			if v:GetSidekickMate() == self then
				table.insert(tmp, v)
			end
		end
	end
	
	if #tmp == 0 then
		tmp = nil
	end
	
	return tmp
end

if SERVER then
	resource.AddFile("materials/vgui/ttt/icon_siki.vmt")
	resource.AddFile("materials/vgui/ttt/sprite_siki.vmt")
end

hook.Add("Initialize", "TTT2InitCRoleSiki", function()
	-- important to add roles with this function,
	-- because it does more than just access the array ! e.g. updating other arrays
	AddCustomRole("SIDEKICK", { -- first param is access for ROLES array => ROLES.SIDEKICK or ROLES["SIDEKICK"]
		color = Color(0, 0, 0, 255), -- ...
		dkcolor = Color(0, 0, 0, 255), -- ...
		bgcolor = Color(0, 0, 0, 200), -- ...
		name = "sidekick", -- just a unique name for the script to determine
		abbr = "siki", -- abbreviation
		team = "sikis", -- the team name: roles with same team name are working together
		defaultEquipment = SPECIAL_EQUIPMENT, -- here you can set up your own default equipment 
		surviveBonus = 1, -- bonus multiplier for every survive while another player was killed
		scoreKillsMultiplier = 5, -- multiplier for kill of player of another team
		scoreTeamKillsMultiplier = -16, -- multiplier for teamkill
		preventWin = true,
		notSelectable = true, -- role cant be selected!
		avoidTeamIcons = true -- prevent default team icons
	},
	{
		shopFallback = SHOP_FALLBACK_TRAITOR
	})
end)

-- if sync of roles has finished
if CLIENT then
    hook.Add("TTT2_FinishedSync", "SikiInitT", function(ply, first)
        if first then -- just on client and first init !
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
    
hook.Add("TTT2_ModifyRole", "SikiSBS", function(ply)
	if ply:GetRole() ~= ROLES.SIDEKICK.index then return end

    local bindedPlayer = ply:GetSidekickMate()
    if bindedPlayer and IsValid(bindedPlayer) and bindedPlayer:IsPlayer() then
        return bindedPlayer:GetRoleData()
    end
end)

if SERVER then
    util.AddNetworkString("TTT_HealPlayer")
    util.AddNetworkString("TTT_SendMateRole")
    
    function AddSidekick(target, attacker)
		if target:IsSidekick() or attacker:IsSidekick() then return end
        
        target:SetNWEntity("binded_sidekick", attacker)
        target:UpdateRole(ROLES.SIDEKICK.index)
        target:SetDefaultCredits()
        
        SendFullStateUpdate()
    end
    
    function SendMateRole(siki, mate)
        if not IsValid(siki) or not siki:IsPlayer() then return end
        
        if not IsValid(mate) or not mate:IsPlayer() then return end
    
        siki.mateRole = mate:GetRole()
        
        net.Start("TTT_SendMateRole")
        net.WriteUInt(siki.mateRole - 1, ROLE_BITS)
        net.Send(siki)
    end
    
    hook.Add("TTT2_SendFullStateUpdate", "SikiFullStateUpdate", function()
        for _, ply in ipairs(player.GetAll()) do
            if ply:GetRole() == ROLES.SIDEKICK.index then
                local mate = ply:GetSidekickMate()
                if IsValid(mate) and mate:IsPlayer() and mate:IsActive() then
					SendRoleListMessage(ROLES.SIDEKICK.index, {ply:EntIndex()}, mate)
					SendRoleListMessage(mate:GetRole(), {mate:EntIndex()}, ply)
					
					SendMateRole(ply, mate)
                end
            end
        end
    end)
    
    hook.Add("EntityTakeDamage", "SikiEntTakeDmg", function(target, dmginfo)
        local attacker = dmginfo:GetAttacker()
    
        if target:IsPlayer() and IsValid(attacker) and attacker:IsPlayer() then
            if (target:Health() - dmginfo:GetDamage()) <= 0 and hook.Run("TTT2_SIKI_CanAttackerSidekick", attacker, target) then
                dmginfo:ScaleDamage(0)
                
                AddSidekick(target, attacker)
                HealPlayer(target)
                
                -- do this clientside as well
                net.Start("TTT_HealPlayer")
                net.Send(target)
            end
        end
    end)
    
    hook.Add("PlayerDisconnected", "SikiPlyDisconnected", function(discPly)
		local sikis
		local mate
		
		if discPly:IsSidekick() then
			sikis = {discPly}
			mate = discPly:GetSidekickMate()
		else
			sikis = discPly:GetSidekicks()
			mate = discPly
		end
		
		if sikis then
			for _, siki in ipairs(sikis) do
				if IsValid(siki) and siki:IsPlayer() and siki:IsActive() then
					siki:SetNWEntity("binded_sidekick", nil)
					
					local newRole = siki.mateRole or (IsValid(mate) and mate:GetRole())
					if newRole then
						siki:UpdateRole(newRole)
						siki:SetDefaultCredits()

						SendFullStateUpdate()
					end
				end
			end
		end
    end)
	
	hook.Add("PostPlayerDeath", "PlayerDeathChangeSiki", function(ply)
		local sikis = ply:GetSidekicks()
		if sikis then
			for _, siki in ipairs(sikis) do
				if IsValid(siki) and siki:IsActive() then
					siki:SetNWEntity("binded_sidekick", nil)
					
					local newRole = siki.mateRole or ply:GetRole()
					if newRole then
						siki:UpdateRole(newRole)
						siki:SetDefaultCredits()
						
						SendFullStateUpdate()
					end
					
					if #sikis == 1 then -- a player can just bind with one player as a sidekick
						AddSidekick(ply, siki)
					end
				end
			end
		end
	end)
    
    hook.Add("TTTPrepareRound", "SikiPrepareRound", function()
        for _, ply in ipairs(player.GetAll()) do
            ply.mateRole = nil
            
            ply:SetNWEntity("binded_sidekick", nil)
        end
    end)

	hook.Add("TTT2_ModifyWinningAlives", "SidekickModifyWinningAlives", function(alive)
		for _, ply in ipairs(player.GetAll()) do
            local tly = ply:GetSidekickMate()
				
			if ply:IsActive() and tly then
                local role
                
                if IsValid(tly) then
                    role = tly:GetRole()
                end
                
                role = ply.mateRole or role
                
                if role then
                    alive[role] = true
                end
			end
		end
	end)
    
	--[[
    hook.Add("TTT2_PostPlayerCanHearPlayersVoice", "SikiPPCHPV", function(listener, speaker)
        if listener:GetSidekickMate() == speaker or speaker:GetSidekickMate() == listener then
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
	]]--
	
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
    
    hook.Add("TTTPrepareRound", "SikiPrepareRound", function()
        LocalPlayer().mateRole = nil
    end)
    
    hook.Add("TTT2_PreventAccessShop", "SikiPreventShop", function(ply)
        -- prevent sidekick of serialkiller is able to shop
        if ply:GetRole() == ROLES.SIDEKICK.index and (
			ROLES.SERIALKILLER or
			ROLES.JACKAL
		) then
            local bindedPlayer = ply:GetSidekickMate()
            if bindedPlayer and IsValid(bindedPlayer) and bindedPlayer:IsPlayer() and (
				ROLES.SERIALKILLER and bindedPlayer:GetRole() == ROLES.SERIALKILLER.index or
				ROLES.JACKAL and bindedPlayer:GetRole() == ROLES.JACKAL.index
			) then
                return true
            end
        end
    end)
	
	local function GetDarkenMateColor(ply)
		if IsValid(ply) then
			if ply.GetRole and ply:GetRole() and ply:GetRole() == ROLES.SIDEKICK.index then
				local mate = ply:GetSidekickMate()
				
				if IsValid(mate) and mate:IsPlayer() then
					local col = table.Copy(mate:GetRoleData().color)
					
					-- darken color
					for _, v in ipairs{"r", "g", "b"} do
						col[v] = col[v] - 45
						if col[v] < 0 then
							col[v] = 0
						end
					end
					
					col.a = 255
				
					return col
				end
			end
		end
	end
    
	hook.Add("TTTScoreboardRowColorForPlayer", "ModifySikiSBColor", function(ply)
		local col = GetDarkenMateColor(ply)
		
		if col then
			return col
		end
	end)
	
	hook.Add("TTT2ModifyWeaponColors", "SikiModifyWeaponColors", function()
		local col = GetDarkenMateColor(LocalPlayer())
		
		if col then
			return col
		end
	end)
	
	hook.Add("TTT2ModifyRoleBGColor", "SikiModifyRoleBGColor", function()
		local col = GetDarkenMateColor(LocalPlayer())
		
		if col then
			return col
		end
	end)
	
    hook.Add("PostDrawTranslucentRenderables", "PostDrawSikiTransRend", function()
		local client = LocalPlayer()

		if client:IsActive() then
			dir = (client:GetForward() * -1)

			for _, ply in ipairs(player.GetAll()) do
				local role = ply:GetRole()
				
				if ply ~= client and ply:IsActive() then
					if client:GetRole() == ROLES.SIDEKICK.index and client:GetSidekickMate() == ply then
						pos = ply:GetPos()
						pos.z = (pos.z + 74)
						
						if indicator_mat_tbl[role] then
							render.SetMaterial(indicator_mat_tbl[role])
							render.DrawQuadEasy(pos, dir, 8, 8, indicator_col, 180)
						end
					elseif ply:GetRole() == ROLES.SIDEKICK.index and ply:GetSidekickMate() == client then
						pos = ply:GetPos()
						pos.z = (pos.z + 74)
						
						if indicator_mat_tbl[role] then
							render.SetMaterial(indicator_mat_tbl[role])
							render.DrawQuadEasy(pos, dir, 8, 8, client:GetRoleData().color, 180)
						end
					end
				end
			end
		end
    end)
end
