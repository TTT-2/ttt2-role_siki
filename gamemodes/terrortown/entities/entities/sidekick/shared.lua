if SERVER then
	AddCSLuaFile()

	resource.AddFile("materials/vgui/ttt/icon_siki.vmt")
	resource.AddFile("materials/vgui/ttt/sprite_siki.vmt")
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
		bgcolor = Color(0, 0, 0, 200), -- ...
		name = "sidekick", -- just a unique name for the script to determine
		abbr = "siki", -- abbreviation
		defaultEquipment = SPECIAL_EQUIPMENT, -- here you can set up your own default equipment
		surviveBonus = 1, -- bonus multiplier for every survive while another player was killed
		scoreKillsMultiplier = 5, -- multiplier for kill of player of another team
		scoreTeamKillsMultiplier = -16, -- multiplier for teamkill
		preventWin = true,
		notSelectable = true -- role cant be selected!
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

	function AddSidekick(target, attacker)
		if target:IsSidekick() or attacker:IsSidekick() then return end

		target:SetNWEntity("binded_sidekick", attacker)
		target:UpdateRole(ROLE_SIDEKICK, attacker:GetTeam())
		target:SetDefaultCredits()

		target.mateSubRole = attacker:GetSubRole()

		target.sikiTimestamp = os.time()
		target.sikiIssuer = attacker

		SendFullStateUpdate()
	end

	hook.Add("EntityTakeDamage", "SikiEntTakeDmg", function(target, dmginfo)
		local attacker = dmginfo:GetAttacker()
		local pTime = protectionTime:GetInt()

		if pTime > 0 and IsValid(target) and IsValid(attacker) and target:IsPlayer() and attacker:IsPlayer() and target:IsActive() and attacker:IsActive() and attacker:IsSidekick() and attacker.sikiIssuer == target and attacker.sikiTimestamp + pTime >= os.time() then return end

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
						siki:UpdateRole(newRole, TEAM_NOCHANGE)
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

					local newRole = siki.mateSubRole or ply:GetSubRole()
					if newRole then
						siki:UpdateRole(newRole, TEAM_NOCHANGE)
						siki:SetDefaultCredits()

						SendFullStateUpdate()
					end

					if #sikis == 1 then -- a player can just be binded with one player as sidekick
						AddSidekick(ply, siki)
					end
				end
			end
		end
	end)

	hook.Add("TTTPrepareRound", "SikiPrepareRound", function()
		for _, ply in ipairs(player.GetAll()) do
			ply.mateSubRole = nil

			ply:SetNWEntity("binded_sidekick", nil)
		end
	end)
else -- CLIENT
	net.Receive("TTT_HealPlayer", function()
		HealPlayer(LocalPlayer())
	end)

	local function GetDarkenMateColor(ply)
		ply = ply or LocalPlayer()

		if IsValid(ply) and ply.GetSubRole and ply:GetSubRole() and ply:GetSubRole() == ROLE_SIDEKICK then
			local mate = ply:GetSidekickMate()

			if IsValid(mate) and mate:IsPlayer() then
				local col = table.Copy(mate:GetSubRoleData().color)

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

	-- Modify colors
	hook.Add("TTTScoreboardRowColorForPlayer", "ModifySikiSBColor", GetDarkenMateColor)
	hook.Add("TTT2ModifyWeaponColors", "SikiModifyWeaponColors", GetDarkenMateColor)
	hook.Add("TTT2ModifyRoleBGColor", "SikiModifyRoleBGColor", GetDarkenMateColor)

	hook.Add("TTT2ModifyRoleIconColor", "SikiModifyRoleIconColors", function(ply)
		local col = GetDarkenMateColor(ply)

		if col then
			col.a = 130

			return col
		end
	end)
end
