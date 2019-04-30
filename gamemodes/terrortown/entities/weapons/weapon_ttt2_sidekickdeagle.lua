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
SWEP.Kind = WEAPON_EQUIP2
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

function SWEP:OnDrop()
	self:Remove()
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
		dmginfo:SetDamage(0)
		return true
	end)
end


-- auto add sidekick weapon into jackal shop
hook.Add("LoadedFallbackShops", "SidekickDeagleAddToShop", function()
	if JACKAL and SIDEKICK and JACKAL.fallbackTable then
		AddWeaponIntoFallbackTable("weapon_ttt2_sidekickdeagle", JACKAL)
	end
end)

if CLIENT then
	net.Receive("tttSidekickMSG", function(len)
		local target = net.ReadEntity()

		if not target or not IsValid(target) then return end

		chat.AddText(Color(0, 255, 255),"Successfully shot ", Color(255, 0, 0), target:GetName(), Color(0, 255, 255), " as Sidekick")

	end)
end
