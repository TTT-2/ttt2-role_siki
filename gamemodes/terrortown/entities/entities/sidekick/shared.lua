if SERVER then
	AddCSLuaFile()

	resource.AddFile("materials/vgui/ttt/dynamic/roles/icon_siki.vmt")
end

local protectionTime = CreateConVar("ttt2_siki_protection_time", 1, {FCVAR_NOTIFY, FCVAR_ARCHIVE})

local plymeta = FindMetaTable("Player")
if not plymeta then return end

-- important to add roles with this function,
-- because it does more than just access the array ! e.g. updating other arrays
-- this role doesn't have a team
InitCustomRole("SIDEKICK", { -- first param is access for ROLES array => SIDEKICK or ROLES["SIDEKICK"]
		color = Color(0, 0, 0, 255), -- ...
		dkcolor = Color(0, 0, 0, 255), -- ...
		bgcolor = Color(255, 255, 255, 255), -- ...
		abbr = "siki", -- abbreviation
		defaultEquipment = SPECIAL_EQUIPMENT, -- here you can set up your own default equipment
		surviveBonus = 1, -- bonus multiplier for every survive while another player was killed
		scoreKillsMultiplier = 5, -- multiplier for kill of player of another team
		scoreTeamKillsMultiplier = -16, -- multiplier for teamkill
		preventWin = true,
		notSelectable = true, -- role cant be selected!
		disableSync = true -- just sync if body got found or round is over
	},
	{
		shopFallback = SHOP_FALLBACK_TRAITOR
})

hook.Add("TTTUlxDynamicRCVars", "TTTUlxDynamicSikiCVars", function(tbl)
	tbl[ROLE_SIDEKICK] = tbl[ROLE_SIDEKICK] or {}

	table.insert(tbl[ROLE_SIDEKICK], {cvar = "ttt2_siki_protection_time", slider = true, min = 0, max = 60, desc = "Protection Time for new Sidekick (Def. 1)"})
end)

-- if sync of roles has finished
if CLIENT then
	hook.Add("TTT2FinishedLoading", "SikiInitT", function()
		-- setup here is not necessary but if you want to access the role data, you need to start here
		-- setup basic translation !
		LANG.AddToLanguage("English", SIDEKICK.name, "Sidekick")
		LANG.AddToLanguage("English", "target_" .. SIDEKICK.name, "Sidekick")
		LANG.AddToLanguage("English", "ttt2_desc_" .. SIDEKICK.name, [[You need to win with your mate!]])
		LANG.AddToLanguage("English", "body_found_" .. SIDEKICK.abbr, "This was a Sidekick...")
		LANG.AddToLanguage("English", "search_role_" .. SIDEKICK.abbr, "This person was a Sidekick!")

		---------------------------------

		-- maybe this language as well...
		LANG.AddToLanguage("Deutsch", SIDEKICK.name, "Sidekick")
		LANG.AddToLanguage("Deutsch", "target_" .. SIDEKICK.name, "Sidekick")
		LANG.AddToLanguage("Deutsch", "ttt2_desc_" .. SIDEKICK.name, [[Du musst mit deinem Mate gewinnen!]])
		LANG.AddToLanguage("Deutsch", "body_found_" .. SIDEKICK.abbr, "Er war ein Sidekick...")
		LANG.AddToLanguage("Deutsch", "search_role_" .. SIDEKICK.abbr, "Diese Person war ein Sidekick!")
	end)
end

function GetDarkenColor(color)
	if not istable(color) then return end
	local col = table.Copy(color)
	-- darken color
	for _, v in ipairs{"r", "g", "b"} do
		col[v] = col[v] - 60
		if col[v] < 0 then
			col[v] = 0
		end
	end

	col.a = 255

	return col
end

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
		if v:GetSubRole() == ROLE_SIDEKICK and v:GetSidekickMate() == self then
			table.insert(tmp, v)
		end
	end

	if #tmp == 0 then
		tmp = nil
	end

	return tmp
end

function HealPlayer(ply)
	ply:SetHealth(ply:GetMaxHealth())
end

if SERVER then
	util.AddNetworkString("TTT_HealPlayer")
	util.AddNetworkString("TTT2SyncSikiColor")

	function AddSidekick(target, attacker)
		if target:IsSidekick() or attacker:IsSidekick() then return end

		target:SetNWEntity("binded_sidekick", attacker)
		target:SetRole(ROLE_SIDEKICK, attacker:GetTeam())

		target.mateSubRole = attacker:GetSubRole()

		target.sikiTimestamp = os.time()
		target.sikiIssuer = attacker

		SendFullStateUpdate()
	end

	hook.Add("PlayerShouldTakeDamage", "SikiProtectionTime", function(ply, atk)
		local pTime = protectionTime:GetInt()

		if pTime > 0 and IsValid(atk) and atk:IsPlayer()
		and ply:IsActive() and atk:IsActive()
		and atk:IsSidekick() and atk.sikiIssuer == ply
		and atk.sikiTimestamp + pTime >= os.time() then
			return false
		end
	end)

	hook.Add("EntityTakeDamage", "SikiEntTakeDmg", function(target, dmginfo)
		local attacker = dmginfo:GetAttacker()

		if target:IsPlayer() and IsValid(attacker) and attacker:IsPlayer()
		and (target:Health() - dmginfo:GetDamage()) <= 0
		and hook.Run("TTT2SIKIAddSidekick", attacker, target)
		then
			dmginfo:ScaleDamage(0)

			AddSidekick(target, attacker)
			HealPlayer(target)

			-- do this clientside as well
			net.Start("TTT_HealPlayer")
			net.Send(target)
		end
	end)

	hook.Add("PlayerDisconnected", "SikiPlyDisconnected", function(discPly)
		local sikis, mate

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

					local newRole = siki.mateSubRole or (IsValid(mate) and mate:GetSubRole())
					if newRole then
						siki:SetRole(newRole, TEAM_NOCHANGE)

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

					local newRole = siki.mateSubRole or ply:GetSubRole()
					if newRole then
						siki:SetRole(newRole, TEAM_NOCHANGE)

						SendFullStateUpdate()
					end

					if #sikis == 1 then -- a player can just be binded with one player as sidekick
						AddSidekick(ply, siki)
					end
				end
			end
		end

		local mate = ply:GetSidekickMate() -- Is Sidekick?

		if IsValid(mate) and not ply.lastMateSubRole then
			ply.lastMateSubRole = ply.mateSubRole or mate:GetSubRole()
		end
	end)

	hook.Add("TTT2OverrideDisabledSync", "SikiAllowTeammateSync", function(ply, p)
		if IsValid(p) and p:GetSubRole() == ROLE_SIDEKICK and ply:IsInTeam(p) and (not ply:GetSubRoleData().unknownTeam or ply == p:GetSidekickMate()) then
			return true
		end
	end)

	hook.Add("TTTBodyFound", "SikiSendLastColor", function(ply, deadply, rag)
		if IsValid(deadply) and deadply:GetSubRole() == ROLE_SIDEKICK then
			net.Start("TTT2SyncSikiColor")
			net.WriteString(deadply:EntIndex())
			net.WriteUInt(deadply.mateSubRole, ROLE_BITS)
			net.WriteUInt(deadply.lastMateSubRole, ROLE_BITS)
			net.Broadcast()
		end
	end)

	-- fix that innos can see their sikis
	hook.Add("TTT2SpecialRoleSyncing", "TTT2SikiInnoSyncFix", function(ply, tmp)
		local rd = ply:GetSubRoleData()
		local sikis = ply:GetSidekicks()

		if rd.unknownTeam and sikis then
			for _, siki in ipairs(sikis) do
				if IsValid(siki) and siki:IsInTeam(ply) then
					tmp[siki] = {ROLE_SIDEKICK, ply:GetTeam()}
				end
			end
		end
	end)
else -- CLIENT
	net.Receive("TTT_HealPlayer", function()
		HealPlayer(LocalPlayer())
	end)

	net.Receive("TTT2SyncSikiColor", function()
		local ply = Entity(net.ReadString())

		if IsValid(ply) and ply:IsPlayer() then
			ply.mateSubRole = net.ReadUInt(ROLE_BITS)
			ply.lastMateSubRole = net.ReadUInt(ROLE_BITS)
		end
	end)

	local function tmpfnc(ply, mate, colorTable)
		if IsValid(mate) and mate:IsPlayer() then
			return table.Copy(mate:GetSubRoleData()[colorTable])
		elseif ply.mateSubRole then
			return table.Copy(GetRoleByIndex(ply.mateSubRole)[colorTable])
		end
	end
	
	local function GetDarkenMateColor(ply, colorTable)
		ply = ply or LocalPlayer()

		if IsValid(ply) and ply.GetSubRole and ply:GetSubRole() and ply:GetSubRole() == ROLE_SIDEKICK then
			local col
			local deadSubRole = ply.lastMateSubRole
			local mate = ply:GetSidekickMate()

			if not ply:Alive() and deadSubRole then
				if IsValid(mate) and mate:IsPlayer() and mate:IsInTeam(ply) and not mate:GetSubRoleData().unknownTeam then
					col = tmpfnc(ply, mate, colorTable)
				else
					col = table.Copy(GetRoleByIndex(deadSubRole)[colorTable])
				end
			else
				col = tmpfnc(ply, mate, colorTable)
			end
			
			return GetDarkenColor(col)
		end
	end

	-- Modify colors
	hook.Add("TTT2ModifyRoleColor", "SikiModifyRoleColor", function(ply)
		return GetDarkenMateColor(ply, "color")
	end)

	hook.Add("TTT2ModifyRoleDkColor", "SikiModifyRoleDkColor", function(ply)
		return GetDarkenMateColor(ply, "dkcolor")
	end)

	hook.Add("TTT2ModifyRoleBgColor", "SikiModifyRoleBgColor", function(ply)
		return GetDarkenMateColor(ply, "bgcolor")
	end)
	
	hook.Add("TTT2ModifyBodyFoundRoleColor", "SikiModifyBodyFoundRoleIcon", function(nick)
		local ply = nil
		for _, v in ipairs(player.GetAll()) do
			if v:Nick() == nick then
				ply = v
			end
		end	
		
		if IsValid(ply) then
			return ply:GetRoleColor()
		end
	end)
end

hook.Add("TTTPrepareRound", "SikiPrepareRound", function()
	for _, ply in ipairs(player.GetAll()) do
		ply.mateSubRole = nil
		ply.lastMateSubRole = nil

		if SERVER then
			ply:SetNWEntity("binded_sidekick", nil)
		end
	end
end)
