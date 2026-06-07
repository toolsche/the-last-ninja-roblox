-- Waffen-Logik: Schaden, Reichweite und Wurfwaffen (geteilt zwischen Client und Server)

local WeaponSystem = {}

WeaponSystem.WeaponStats = {
	Katana = {
		LightDamage = 18,
		HeavyDamage = 45,
		Range = 5,
		LightCooldown = 0.4,
		HeavyCooldown = 1.2,
	},
	Bogen = {
		LightDamage = 22,
		HeavyDamage = 22,
		Range = 60,
		LightCooldown = 0.8,
		HeavyCooldown = 0.8,
		ProjectileSpeed = 80,
	},
	Nunchaku = {
		LightDamage = 12,
		HeavyDamage = 28,
		Range = 4,
		LightCooldown = 0.25,
		HeavyCooldown = 0.8,
	},
	Kusarigama = {
		LightDamage = 15,
		HeavyDamage = 35,
		Range = 8,
		LightCooldown = 0.5,
		HeavyCooldown = 1.0,
	},
}

WeaponSystem.ThrowableStats = {
	Shuriken    = { Damage = 20, Range = 40, Speed = 60, MaxCount = 10 },
	Feuerpfeil  = { Damage = 15, Range = 80, Speed = 70, MaxCount = 5, IgnitesObjects = true },
	Rauchbombe  = { Damage = 0,  Range = 25, Speed = 30, MaxCount = 3, BlindDuration = 4 },
	Giftbombe   = { Damage = 8,  Range = 20, Speed = 30, MaxCount = 3, PoisonDuration = 6, PoisonTickDamage = 5 },
}

-- Combo-Finisher: ausgelöst wenn zwei Spieler denselben Gegner in kurzem Zeitfenster treffen
WeaponSystem.ComboFinisher = {
	TimeWindow = 1.5,
	DamageMultiplier = 2.5,
	EffectName = "ComboFinisherEffect",
}

function WeaponSystem.GetWeaponStats(weaponName)
	return WeaponSystem.WeaponStats[weaponName]
end

function WeaponSystem.GetThrowableStats(throwableName)
	return WeaponSystem.ThrowableStats[throwableName]
end

-- Gibt zurück ob zwei Treffer-Zeitstempel ein Combo-Fenster bilden
function WeaponSystem.IsComboWindow(timestamp1, timestamp2)
	return math.abs(timestamp1 - timestamp2) <= WeaponSystem.ComboFinisher.TimeWindow
end

return WeaponSystem
