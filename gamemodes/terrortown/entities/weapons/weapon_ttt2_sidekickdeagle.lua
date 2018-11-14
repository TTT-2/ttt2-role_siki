SWEP.Base = "weapon_tttbase"

SWEP.MinPlayers = 1

SWEP.Spawnable = true
SWEP.AutoSpawnable = false
SWEP.AdminSpawnable = true

SWEP.HoldType = "pistol"

SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

if SERVER then
	AddCSLuaFile()

	resource.AddFile("materials/vgui/ttt/icon_sidekickdeagle.vmt")
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
SWEP.Primary.Damage = 0
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

-- view / world
SWEP.ViewModel = "models/weapons/cstrike/c_pist_deagle.mdl"
SWEP.WorldModel = "models/weapons/w_pist_deagle.mdl"
SWEP.Weight = 5
SWEP.Primary.Sound = Sound("Weapon_Deagle.Single")

SWEP.IronSightsPos = Vector(-6.361, -3.701, 2.15)
SWEP.IronSightsAng = Vector(0, 0, 0)

function SWEP:OnDrop()
	self:Remove()
end

function SWEP:ShootBullet(dmg, recoil, numbul, cone)
	if SIDEKICK then
		self:SendWeaponAnim(self.PrimaryAnim)

		self.Owner:MuzzleFlash()
		self.Owner:SetAnimation(PLAYER_ATTACK1)

		if not IsFirstTimePredicted() then return end

		local bullet = {}
		bullet.Num = 1
		bullet.Src = self.Owner:GetShootPos()
		bullet.Dir = self.Owner:GetAimVector()
		bullet.Spread = Vector(0.00001, 0.00001, 0)
		bullet.Force = 0
		bullet.Damage = dmg

		if SERVER then
			bullet.Callback = function(atk, tr, dmginfo)
				local target = tr.Entity

				if target and IsValid(target) and target:IsPlayer() and target:IsTerror() and target:IsActive() then
					dmginfo:ScaleDamage(0)

					AddSidekick(target, atk)
				end
			end
		end

		self.Owner:FireBullets(bullet)
	end
end

-- auto add sidekick weapon into jackal shop
hook.Add("LoadedFallbackShops", "SidekickDeagleAddToShop", function()
	if JACKAL and SIDEKICK and JACKAL.fallbackTable then
		AddWeaponIntoFallbackTable("weapon_ttt2_sidekickdeagle", JACKAL)
	end
end)
