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

	util.AddNetworkString("tttSidekickMSG_attacker")
	util.AddNetworkString("tttSidekickMSG_target")
	util.AddNetworkString("tttSidekickRefillCDReduced")
	util.AddNetworkString("tttSidekickDeagleRefilled")
	util.AddNetworkString("tttSidekickDeagleMiss")
	util.AddNetworkString("tttSidekickSameTeam")
end

if CLIENT then
	SWEP.PrintName = "Sidekick Deagle"
	SWEP.Author = "Alf21"

	SWEP.ViewModelFOV = 54
	SWEP.ViewModelFlip = false

	SWEP.Category = "Deagle"
	SWEP.Icon = "vgui/ttt/icon_sidekickdeagle.vtf"
	SWEP.EquipMenuData = {
		type = "item_weapon",
		name = "weapon_sidekickdeagle_name",
		desc = "weapon_sidekickdeagle_desc"
	}
end

-- dmg
SWEP.Primary.Delay = 1
SWEP.Primary.Recoil = 6
SWEP.Primary.Automatic = false
SWEP.Primary.NumShots = 1
SWEP.Primary.Damage = 0
SWEP.Primary.Cone = 0.00001
SWEP.Primary.Ammo = ""
SWEP.Primary.ClipSize = 1
SWEP.Primary.ClipMax = 1
SWEP.Primary.DefaultClip = 1

-- some other stuff
SWEP.InLoadoutFor = nil
SWEP.AllowDrop = false
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

local ttt2_sidekick_deagle_refill_conv = CreateConVar("ttt2_siki_deagle_refill", 1, {FCVAR_NOTIFY, FCVAR_ARCHIVE})
local ttt2_sidekick_deagle_refill_cd_conv = CreateConVar("ttt2_siki_deagle_refill_cd", 120, {FCVAR_NOTIFY, FCVAR_ARCHIVE})
local ttt2_siki_deagle_refill_cd_per_kill_conv = CreateConVar("ttt2_siki_deagle_refill_cd_per_kill", 60, {FCVAR_NOTIFY, FCVAR_ARCHIVE})

local function SidekickDeagleRefilled(wep)
	if not IsValid(wep) then return end

	local text = LANG.GetTranslation("ttt2_siki_recharged")
	MSTACK:AddMessage(text)

	STATUS:RemoveStatus("ttt2_sidekick_deagle_reloading")
	net.Start("tttSidekickDeagleRefilled")
	net.WriteEntity(wep)
	net.SendToServer()
end

local function SidekickDeagleCallback(attacker, tr, dmg)
	if CLIENT then return end

	local target = tr.Entity

	--invalid shot return
	if not GetRoundState() == ROUND_ACTIVE or not IsValid(attacker) or not attacker:IsPlayer() or not attacker:IsTerror() then return end

	--no/bad hit: (send message), start timer and return
	if not IsValid(target) or not target:IsPlayer() or not target:IsTerror() or target:IsInTeam(attacker) then
		if IsValid(target) and target:IsPlayer() and target:IsTerror() and target:IsInTeam(attacker) then
			net.Start("tttSidekickSameTeam")
			net.Send(attacker)
		end

		if ttt2_sidekick_deagle_refill_conv:GetBool() then
			net.Start("tttSidekickDeagleMiss")
			net.Send(attacker)
		end

		return
	end

	local deagle = attacker:GetWeapon("weapon_ttt2_sidekickdeagle")
	if IsValid(deagle) then
		deagle:Remove()
	end

	AddSidekick(target, attacker)

	net.Start("tttSidekickMSG_attacker")
	net.WriteEntity(target)
	net.Send(attacker)

	net.Start("tttSidekickMSG_target")
	net.WriteEntity(attacker)
	net.Send(target)

	return true
end

function SWEP:OnDrop()
	self:Remove()
end

function SWEP:ShootBullet(dmg, recoil, numbul, cone)
	cone = cone or 0.01

	local bullet = {}
	bullet.Num = 1
	bullet.Src = self:GetOwner():GetShootPos()
	bullet.Dir = self:GetOwner():GetAimVector()
	bullet.Spread = Vector(cone, cone, 0)
	bullet.Tracer = 0
	bullet.TracerName = self.Tracer or "Tracer"
	bullet.Force = 10
	bullet.Damage = 0
	bullet.Callback = SidekickDeagleCallback

	self:GetOwner():FireBullets(bullet)

	self.BaseClass.ShootBullet(self, dmg, recoil, numbul, cone)
end

function SWEP:OnRemove()
	if CLIENT then
		STATUS:RemoveStatus("ttt2_sidekick_deagle_reloading")

		timer.Stop("ttt2_sidekick_deagle_refill_timer")
	end
end

function ShootSidekick(target, dmginfo)
	local attacker = dmginfo:GetAttacker()

	if not attacker:IsPlayer() or not target:IsPlayer() or not IsValid(attacker:GetActiveWeapon())
		or not attacker:IsTerror() or not IsValid(target) or not target:IsTerror() then return end

	if target:GetSubRole() == ROLE_JACKAL or target:GetSubRole() == ROLE_SIDEKICK then
		return
	end

	AddSidekick(target, attacker)

	net.Start("tttSidekickMSG_attacker")
	net.WriteEntity(target)
	net.Send(attacker)

	net.Start("tttSidekickMSG_target")
	net.WriteEntity(attacker)
	net.Send(target)
end


if SERVER then
	hook.Add("PlayerDeath", "SidekickDeagleRefillReduceCD", function(victim, inflictor, attacker)
		if IsValid(attacker) and attacker:IsPlayer() and attacker:HasWeapon("weapon_ttt2_sidekickdeagle") and ttt2_sidekick_deagle_refill_conv:GetBool() then
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
	hook.Add("Initialize", "ttt_sidekick_init_status", function()
		STATUS:RegisterStatus("ttt2_sidekick_deagle_reloading", {
			hud = Material("vgui/ttt/hud_icon_deagle.png"),
			type = "bad"
		})
	end)

	net.Receive("tttSidekickMSG_attacker", function(len)
		local target = net.ReadEntity()
		if not IsValid(target) then return end

		local text = LANG.GetParamTranslation("ttt2_siki_shot", {name = target:GetName()})
		MSTACK:AddMessage(text)
	end)

	net.Receive("tttSidekickMSG_target", function(len)
		local attacker = net.ReadEntity()
		if not IsValid(attacker) then return end

		local text = LANG.GetParamTranslation("ttt2_siki_were_shot", {name = attacker:GetName()})
		MSTACK:AddMessage(text)
	end)

	net.Receive("tttSidekickRefillCDReduced", function()
		if not timer.Exists("ttt2_sidekick_deagle_refill_timer") or not LocalPlayer():HasWeapon("weapon_ttt2_sidekickdeagle") then return end

		local timeLeft = timer.TimeLeft("ttt2_sidekick_deagle_refill_timer") or 0
		local newTime = math.max(timeLeft - ttt2_siki_deagle_refill_cd_per_kill_conv:GetInt(), 0.1)

		local wep = LocalPlayer():GetWeapon("weapon_ttt2_sidekickdeagle")
		if not IsValid(wep) then return end

		timer.Adjust("ttt2_sidekick_deagle_refill_timer", newTime, 1, function()
			if not IsValid(wep) then return end

			SidekickDeagleRefilled(wep)
		end)

		if STATUS.active["ttt2_sidekick_deagle_reloading"] then
			STATUS.active["ttt2_sidekick_deagle_reloading"].displaytime = CurTime() + newTime
		end

		local text = LANG.GetParamTranslation("ttt2_siki_ply_killed", {amount = ttt2_siki_deagle_refill_cd_per_kill_conv:GetInt()})
		MSTACK:AddMessage(text)
		chat.PlaySound()
	end)

	net.Receive("tttSidekickDeagleMiss", function()
		local client = LocalPlayer()
		if not IsValid(client) or not client:IsTerror() or not client:HasWeapon("weapon_ttt2_sidekickdeagle") then return end

		local wep = client:GetWeapon("weapon_ttt2_sidekickdeagle")
		if not IsValid(wep) then return end

		local initialCD = ttt2_sidekick_deagle_refill_cd_conv:GetInt()

		STATUS:AddTimedStatus("ttt2_sidekick_deagle_reloading", initialCD, true)

		timer.Create("ttt2_sidekick_deagle_refill_timer", initialCD, 1, function()
			if not IsValid(wep) then return end

			SidekickDeagleRefilled(wep)
		end)
	end)

	net.Receive("tttSidekickSameTeam", function()
		MSTACK:AddMessage(LANG.GetTranslation("ttt2_siki_sameteam"))
	end)
else
	net.Receive("tttSidekickDeagleRefilled", function()
		local wep = net.ReadEntity()

		if not IsValid(wep) then return end

		wep:SetClip1(1)
	end)
end
