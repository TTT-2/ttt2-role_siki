SWEP.Base = "weapon_tttbase"

SWEP.Spawnable = true
SWEP.AutoSpawnable = false
SWEP.AdminSpawnable = true

SWEP.HoldType = "pistol"

SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

if SERVER then
	AddCSLuaFile()

	resource.AddFile("materials/vgui/ttt/icon_sidekickdeagle.vmt")

	util.AddNetworkString("tttSidekickMSG")
	util.AddNetworkString("tttSidekickRefillCDReduced")
	util.AddNetworkString("tttSidekickDeagleRefilled")
else
	hook.Add("Initialize", "TTTInitSikiDeagleLang", function()
		LANG.AddToLanguage("English", "ttt2_weapon_sidekickdeagle_desc", "Shoot a player to make him your sidekick.")
		LANG.AddToLanguage("Deutsch", "ttt2_weapon_sidekickdeagle_desc", "Schieße auf einen Spieler, um ihn zu deinem Sidekick zu machen.")
	end)

	SWEP.PrintName = "Sidekick Deagle"
	SWEP.Author = "Alf21"

	SWEP.Slot = 7

	SWEP.ViewModelFOV = 54
	SWEP.ViewModelFlip = false

	SWEP.Category = "Deagle"
	SWEP.Icon = "vgui/ttt/icon_sidekickdeagle.vtf"
	SWEP.EquipMenuData = {
		type = "Weapon",
		desc = "ttt2_weapon_sidekickdeagle_desc"
	}
end

-- dmg
SWEP.Primary.Delay = 1
SWEP.Primary.Recoil = 6
SWEP.Primary.Automatic = false
SWEP.Primary.NumShots = 1
SWEP.Primary.Damage = 1
SWEP.Primary.Cone = 0.00001
SWEP.Primary.Ammo = ""
SWEP.Primary.ClipSize = 1
SWEP.Primary.ClipMax = 1
SWEP.Primary.DefaultClip = 1

-- some other stuff
SWEP.InLoadoutFor = nil
SWEP.AllowDrop = true
SWEP.IsSilent = false
SWEP.NoSights = false
SWEP.UseHands = true
SWEP.Kind = WEAPON_EXTRA
SWEP.CanBuy = {}
SWEP.LimitedStock = true
SWEP.globalLimited = true
SWEP.NoRandom = true

-- view / world
SWEP.ViewModel = "models/weapons/cstrike/c_pist_deagle.mdl"
SWEP.WorldModel = "models/weapons/w_pist_deagle.mdl"
SWEP.Weight = 5
SWEP.Primary.Sound = Sound("Weapon_Deagle.Single")

SWEP.IronSightsPos = Vector(-6.361, -3.701, 2.15)
SWEP.IronSightsAng = Vector(0, 0, 0)

SWEP.notBuyable = true

local function SidekickDeagleRefilled(wep)
	if not IsValid(wep) then return end

	local text = LANG.GetTranslation("ttt2_siki_recharged")
	MSTACK:AddMessage(text)

	STATUS:RemoveStatus("ttt2_sidekick_deagle_reloading")
	net.Start("tttSidekickDeagleRefilled")
	net.WriteEntity(wep)
	net.SendToServer()
end

function SWEP:OnDrop()
	self:Remove()
end

function SWEP:PrimaryAttack()
	if CLIENT and self:CanPrimaryAttack() and GetConVar("ttt2_siki_deagle_refill"):GetBool() then
		local initialCD = GetConVar("ttt2_siki_deagle_refill_cd"):GetInt()

		STATUS:AddTimedStatus("ttt2_sidekick_deagle_reloading", initialCD) 
		timer.Create("ttt2_sidekick_deagle_refill_timer", initialCD, 1, function()
			SidekickDeagleRefilled(self)
		end)
	end

	self.BaseClass.PrimaryAttack(self)
end

function SWEP:OnRemove()
	if CLIENT then STATUS:RemoveStatus("ttt2_sidekick_deagle_reloading") end
end

function ShootSidekick(target, dmginfo)
	local attacker = dmginfo:GetAttacker()

	if not attacker:IsPlayer() or not target:IsPlayer() or not IsValid(attacker:GetActiveWeapon())
		or not attacker:IsTerror() or not IsValid(target) or not target:IsTerror() then return end

	if target:GetSubRole() == ROLE_JACKAL or target:GetSubRole() == ROLE_SIDEKICK then
		attacker:PrintMessage(HUD_PRINTTALK, "You can't shoot a Jackal/Sidekick as Sidekick!")
		return
	end

	AddSidekick(target, attacker)

	net.Start("tttSidekickMSG")

	net.WriteEntity(target)

	net.Send(attacker)

end


if SERVER then
	hook.Add("ScalePlayerDamage", "SidekickHitReg", function(ply, hitgroup, dmginfo)
		local attacker = dmginfo:GetAttacker()
		if GetRoundState() ~= ROUND_ACTIVE or not attacker or not IsValid(attacker)
			or not attacker:IsPlayer() or not IsValid(attacker:GetActiveWeapon()) then return end

		local weap = attacker:GetActiveWeapon()

		if weap:GetClass() ~= "weapon_ttt2_sidekickdeagle" then return end

		ShootSidekick(ply, dmginfo)
		weap:Remove()
		dmginfo:SetDamage(0)
		return true
	end)

	hook.Add("PlayerDeath", "SidekickDeagleRefillReduceCD", function(victim, inflictor, attacker)
		if IsValid(attacker) and attacker:HasWeapon("weapon_ttt2_sidekickdeagle") and GetConVar("ttt2_siki_deagle_refill"):GetBool() then
			net.Start("tttSidekickRefillCDReduced")
			net.Send(attacker)	
		end
	end)
end


-- auto add sidekick weapon into jackal shop
hook.Add("LoadedFallbackShops", "SidekickDeagleAddToShop", function()
	if JACKAL and SIDEKICK and JACKAL.fallbackTable then
		AddWeaponIntoFallbackTable("weapon_ttt2_sidekickdeagle", JACKAL)
	end
end)

if CLIENT then
	hook.Add("TTT2FinishedLoading", "InitSikiMsgText", function()
		LANG.AddToLanguage("English", "ttt2_siki_shot", "Successfully shot {name} as Sidekick!")
		LANG.AddToLanguage("Deutsch", "ttt2_siki_shot", "Erfolgreich {name} als Sidekick geschossen!")

		LANG.AddToLanguage("English", "ttt2_siki_ply_killed", "Your Sidekick Deagle Cooldown was reduced by {amount} seconds.")
		LANG.AddToLanguage("Deutsch", "ttt2_siki_ply_killed", "Deine Sidekick Deagle Wartezeit wurde um {amount} Sekunden reduziert.")

		LANG.AddToLanguage("English", "ttt2_siki_recharged", "Your Sidekick Deagle has been recharged.")
		LANG.AddToLanguage("Deutsch", "ttt2_siki_recharged", "Deine Sidekick Deagle wurde wieder aufgefüllt.")
	end)

	hook.Add("Initialize", "ttt_sidekick_deagle_reloading", function() 
		STATUS:RegisterStatus("ttt2_sidekick_deagle_reloading", {
			hud = Material("vgui/ttt/hud_icon_deagle.png"),
			type = "bad",

			DrawInfo = function(self) return tostring(math.Round(math.max(0, self.displaytime - CurTime()))) end
		})
	end)

	net.Receive("tttSidekickMSG", function(len)
		local target = net.ReadEntity()

		if not target or not IsValid(target) then return end

		local text = LANG.GetParamTranslation("ttt2_siki_shot", {name = target:GetName()})
		MSTACK:AddMessage(text)
	end)

	net.Receive("tttSidekickRefillCDReduced", function()
		if not timer.Exists("ttt2_sidekick_deagle_refill_timer") then return end

		local timeLeft = timer.TimeLeft("ttt2_sidekick_deagle_refill_timer")
		local newTime = math.max(timeLeft - GetConVar("ttt2_siki_deagle_refill_cd_per_kill"):GetInt(), 0.1)
		local wep = LocalPlayer():GetWeapon("weapon_ttt2_sidekickdeagle")
		timer.Adjust("ttt2_sidekick_deagle_refill_timer", newTime, 1, function() SidekickDeagleRefilled(wep) end)

		if STATUS.active["ttt2_sidekick_deagle_reloading"] then
			STATUS.active["ttt2_sidekick_deagle_reloading"].displaytime = CurTime() + newTime
		end

		local text = LANG.GetParamTranslation("ttt2_siki_ply_killed", {amount = GetConVar("ttt2_siki_deagle_refill_cd_per_kill"):GetInt()})
		MSTACK:AddMessage(text)
		chat.PlaySound()
	end)
else
	net.Receive("tttSidekickDeagleRefilled", function()
		local wep = net.ReadEntity()
		wep:SetClip1(1)
	end)
end
