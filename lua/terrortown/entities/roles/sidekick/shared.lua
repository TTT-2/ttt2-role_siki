if SERVER then
	AddCSLuaFile()

	util.AddNetworkString("TTT2SikiSyncClasses")

	resource.AddFile("materials/vgui/ttt/dynamic/roles/icon_siki.vmt")

	CreateConVar("ttt2_siki_protection_time", 1, {FCVAR_NOTIFY, FCVAR_ARCHIVE})
	CreateConVar("ttt2_siki_mode", 1, {FCVAR_NOTIFY, FCVAR_ARCHIVE})
end

local plymeta = FindMetaTable("Player")
if not plymeta then return end

ROLE.Base = "ttt_role_base"

function ROLE:PreInitialize()
	self.color = Color(0, 0, 0, 255)

	self.abbr = "siki"
	self.surviveBonus = 1
	self.scoreKillsMultiplier = 5
	self.scoreTeamKillsMultiplier = -16
	self.preventWin = true
	self.notSelectable = true
	self.disableSync = true
	self.preventFindCredits = true
	self.preventKillCredits = true
	self.preventTraitorAloneCredits = true

	self.defaultEquipment = SPECIAL_EQUIPMENT

	self.conVarData = {
		credits = 1, -- the starting credits of a specific role
		shopFallback = SHOP_FALLBACK_TRAITOR
	}
end

function ROLE:Initialize()
	if CLIENT then
		-- Role specific language elements
		LANG.AddToLanguage("English", SIDEKICK.name, "Sidekick")
		LANG.AddToLanguage("English", "target_" .. SIDEKICK.name, "Sidekick")
		LANG.AddToLanguage("English", "ttt2_desc_" .. SIDEKICK.name, [[You need to win with your mate!]])
		LANG.AddToLanguage("English", "body_found_" .. SIDEKICK.abbr, "This was a Sidekick...")
		LANG.AddToLanguage("English", "search_role_" .. SIDEKICK.abbr, "This person was a Sidekick!")

		LANG.AddToLanguage("Italiano", SIDEKICK.name, "Spalla")
		LANG.AddToLanguage("Italiano", "target_" .. SIDEKICK.name, "Spalla")
		LANG.AddToLanguage("Italiano", "ttt2_desc_" .. SIDEKICK.name, [[Devi vincere con il tuo compagno!]])
		LANG.AddToLanguage("Italiano", "body_found_" .. SIDEKICK.abbr, "Era una Spalla...")
		LANG.AddToLanguage("Italiano", "search_role_" .. SIDEKICK.abbr, "Questa persona era una Spalla!")
	
		LANG.AddToLanguage("Deutsch", SIDEKICK.name, "Kumpane")
		LANG.AddToLanguage("Deutsch", "target_" .. SIDEKICK.name, "Kumpane")
		LANG.AddToLanguage("Deutsch", "ttt2_desc_" .. SIDEKICK.name, [[Du musst mit deinem Mate gewinnen!]])
		LANG.AddToLanguage("Deutsch", "body_found_" .. SIDEKICK.abbr, "Er war ein Kumpane!")
		LANG.AddToLanguage("Deutsch", "search_role_" .. SIDEKICK.abbr, "Diese Person war ein Kumpane!")
	end
end

hook.Add("TTTUlxDynamicRCVars", "TTTUlxDynamicSikiCVars", function(tbl)
	tbl[ROLE_SIDEKICK] = tbl[ROLE_SIDEKICK] or {}

	table.insert(tbl[ROLE_SIDEKICK], {cvar = "ttt2_siki_protection_time", slider = true, min = 0, max = 60, desc = "Protection Time for new Sidekick (Def. 1)"})
	table.insert(tbl[ROLE_SIDEKICK], {cvar = "ttt2_siki_mode", checkbox = true, desc = "Normal mode for the Sidekick (Def. 1). 1 = Sidekick -> Jackal. 2 = Sidekick receive targets"})
	table.insert(tbl[ROLE_SIDEKICK], {cvar = "ttt2_siki_deagle_refill", checkbox = true, desc = "The Sidekick Deagle can be refilled when you missed a shot. (Def. 1)"})
	table.insert(tbl[ROLE_SIDEKICK], {cvar = "ttt2_siki_deagle_refill_cd", slider = true, min = 1, max = 300, desc = "Seconds to Refill (Def. 120)"})
	table.insert(tbl[ROLE_SIDEKICK], {cvar = "ttt2_siki_deagle_refill_cd_per_kill", slider = true, min = 1, max = 300, desc = "CD Reduction per Kill (Def. 60)"})
end)

if SERVER then
	function ROLE:GiveRoleLoadout(ply, isRoleChange)
		if not GetGlobalBool("ttt2_classes") or not GetGlobalBool("ttt2_heroes") then return end
		if not TTTH then return end

		ply:GiveEquipmentWeapon("weapon_ttt_crystalknife")
	end

	function ROLE:RemoveRoleLoadout(ply, isRoleChange)
		if not GetGlobalBool("ttt2_classes") or not GetGlobalBool("ttt2_heroes") then return end
		if not TTTH then return end

		ply:StripWeapon("weapon_ttt_crystalknife")
	end
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

local function tmpfnc(ply, mate, colorTable)
	if IsValid(mate) and mate:IsPlayer() then
		if colorTable == "dkcolor" then
			return table.Copy(mate:GetRoleDkColor())
		elseif colorTable == "bgcolor" then
			return table.Copy(mate:GetRoleBgColor())
		elseif colorTable == "color" then
			return table.Copy(mate:GetRoleColor())
		end
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
		local credits = target:GetCredits()
		target:SetDefaultCredits()
		target:SetCredits(target:GetCredits() + credits)

		target.mateSubRole = attacker:GetSubRole()

		target.sikiTimestamp = os.time()
		target.sikiIssuer = attacker

		timer.Simple(0.1, SendFullStateUpdate)
	end

	hook.Add("PlayerShouldTakeDamage", "SikiProtectionTime", function(ply, atk)
		local pTime = GetConVar("ttt2_siki_protection_time"):GetInt()

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
			local enabled = GetConVar("ttt2_siki_mode"):GetBool()

			for _, siki in ipairs(sikis) do
				if IsValid(siki) and siki:IsPlayer() and siki:IsActive() then
					siki:SetNWEntity("binded_sidekick", nil)

					if enabled then
						local newRole = siki.mateSubRole or (IsValid(mate) and mate:GetSubRole())
						if newRole then
							siki:SetRole(newRole, TEAM_NOCHANGE)

							SendFullStateUpdate()
						end
					end
				end
			end
		end
	end)

	hook.Add("PostPlayerDeath", "PlayerDeathChangeSiki", function(ply)
		if GetConVar("ttt2_siki_mode"):GetBool() then
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
							ply.spawn_as_sidekick = siki
						end
					end
				end
			end
		end

		local mate = ply:GetSidekickMate() -- Is Sidekick?

		if not IsValid(mate) or ply.lastMateSubRole then return end

		ply.lastMateSubRole = ply.mateSubRole or mate:GetSubRole()
	end)

	hook.Add("PlayerSpawn", "PlayerSpawnsAsSidekick", function(ply)
		if not ply.spawn_as_sidekick then return end

		AddSidekick(ply, ply.spawn_as_sidekick)

		ply.spawn_as_sidekick = nil
	end)

	hook.Add("TTT2OverrideDisabledSync", "SikiAllowTeammateSync", function(ply, p)
		if IsValid(p) and p:GetSubRole() == ROLE_SIDEKICK and ply:IsInTeam(p) and (not ply:GetSubRoleData().unknownTeam or ply == p:GetSidekickMate()) then
			return true
		end
	end)

	hook.Add("TTTBodyFound", "SikiSendLastColor", function(ply, deadply, rag)
		if not IsValid(deadply) or deadply:GetSubRole() ~= ROLE_SIDEKICK then return end

		net.Start("TTT2SyncSikiColor")
		net.WriteString(deadply:EntIndex())
		net.WriteUInt(deadply.mateSubRole, ROLE_BITS)
		net.WriteUInt(deadply.lastMateSubRole, ROLE_BITS)
		net.Broadcast()
	end)

	-- fix that innos can see their sikis
	hook.Add("TTT2SpecialRoleSyncing", "TTT2SikiInnoSyncFix", function(ply, tmp)
		local rd = ply:GetSubRoleData()
		local sikis = ply:GetSidekicks()

		if not rd.unknownTeam or not sikis then return end

		for _, siki in ipairs(sikis) do
			if IsValid(siki) and siki:IsInTeam(ply) then
				tmp[siki] = {ROLE_SIDEKICK, ply:GetTeam()}
			end
		end
	end)
end

if CLIENT then
	net.Receive("TTT_HealPlayer", function()
		HealPlayer(LocalPlayer())
	end)

	net.Receive("TTT2SyncSikiColor", function()
		local ply = Entity(net.ReadString())

		if not IsValid(ply) or not ply:IsPlayer() then return end

		ply.mateSubRole = net.ReadUInt(ROLE_BITS)
		ply.lastMateSubRole = net.ReadUInt(ROLE_BITS)
		ply:SetRoleColor(COLOR_BLACK)
	end)

	-- Modify colors
	hook.Add("TTT2ModifyRoleDkColor", "SikiModifyRoleDkColor", function(ply)
		return GetDarkenMateColor(ply, "dkcolor")
	end)

	hook.Add("TTT2ModifyRoleBgColor", "SikiModifyRoleBgColor", function(ply)
		return GetDarkenMateColor(ply, "bgcolor")
	end)
end

--modify role colors on both client and server
hook.Add("TTT2ModifyRoleColor", "SikiModifyRoleColor", function(ply)
	return GetDarkenMateColor(ply, "color")
end)

hook.Add("TTTPrepareRound", "SikiPrepareRound", function()
	for _, ply in ipairs(player.GetAll()) do
		ply.mateSubRole = nil
		ply.lastMateSubRole = nil
		ply.spawn_as_sidekick = nil

		if SERVER then
			ply:SetNWEntity("binded_sidekick", nil)
		end
	end
end)

-- SIDEKICK HITMAN FUNCTION
if SERVER then
	hook.Add("TTT2CheckCreditAward", "TTTCSidekickMod", function(victim, attacker)
		if IsValid(attacker) and attacker:IsPlayer() and attacker:IsActive() and attacker:GetSubRole() == ROLE_SIDEKICK and not GetConVar("ttt2_siki_mode"):GetBool() then
			return false -- prevent awards
		end
	end)

	-- CLASSES syncing
	hook.Add("TTT2UpdateSubrole", "TTTCSidekickMod", function(siki, oldRole, role)
		if not TTTC or not siki:IsActive() or role ~= ROLE_SIDEKICK or GetConVar("ttt2_siki_mode"):GetBool() then return end

		for _, ply in ipairs(player.GetAll()) do
			net.Start("TTT2SikiSyncClasses")
			net.WriteEntity(ply)
			net.WriteUInt(ply:GetCustomClass() or 0, CLASS_BITS)
			net.Send(siki)
		end
	end)

	include("target.lua")
end

if CLIENT then
	net.Receive("TTT2SikiSyncClasses", function(len)
		local target = net.ReadEntity()
		if not IsValid(target) then return end

		local hr = net.ReadUInt(CLASS_BITS)
		if hr == 0 then
			hr = nil
		end

		target:SetClass(hr)
	end)
end
