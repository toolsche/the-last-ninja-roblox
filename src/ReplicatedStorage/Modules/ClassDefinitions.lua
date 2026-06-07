-- Klassen-Stats und Fähigkeitsdefinitionen für alle vier Ninja-Klassen

local ClassDefinitions = {}

ClassDefinitions.Classes = {
	Kenshi = {
		DisplayName = "Kenshi",
		Description = "Schwertkämpfer – Tank der Frontlinie",
		MaxHP = 150,
		WalkSpeed = 14,
		PrimaryWeapon = "Katana",
		SecondaryWeapon = "Shuriken",
		Special = {
			Name = "Kiai-Schrei",
			Description = "Lähmt alle Gegner in einem Radius kurz",
			Cooldown = 30,
			Radius = 15,
			StunDuration = 2.5,
		},
	},

	Kassha = {
		DisplayName = "Kassha",
		Description = "Bogenschützin – Distanzkampf und Fackelrätsel",
		MaxHP = 100,
		WalkSpeed = 15,
		PrimaryWeapon = "Bogen",
		SecondaryWeapon = "Feuerpfeil",
		Special = {
			Name = "Feuerpfeil",
			Description = "Entzündet Fackeln aus großer Distanz",
			Cooldown = 30,
			Range = 80,
			FireDuration = 5,
		},
	},

	Kaze = {
		DisplayName = "Kaze",
		Description = "Windninja – Scout mit höchster Beweglichkeit",
		MaxHP = 90,
		WalkSpeed = 22,
		PrimaryWeapon = "Nunchaku",
		SecondaryWeapon = "Rauchbombe",
		Special = {
			Name = "Windschritt",
			Description = "Teleportiert kurz vorwärts, überwindet Fallen",
			Cooldown = 30,
			TeleportDistance = 18,
		},
	},

	Kunoichi = {
		DisplayName = "Kunoichi",
		Description = "Giftmeisterin – Support und Heilung",
		MaxHP = 100,
		WalkSpeed = 16,
		PrimaryWeapon = "Kusarigama",
		SecondaryWeapon = "Giftbombe",
		Special = {
			Name = "Heilrauch",
			Description = "Heilt alle Teamkollegen in der Nähe",
			Cooldown = 30,
			Radius = 12,
			HealAmount = 40,
		},
	},
}

-- Schwierigkeitsskalierung nach Spieleranzahl
ClassDefinitions.DifficultyScale = {
	[2] = { EnemyHPMultiplier = 0.70, EnemyCountMultiplier = 0.60, BossPhases = 2 },
	[3] = { EnemyHPMultiplier = 0.85, EnemyCountMultiplier = 0.80, BossPhases = 2 },
	[4] = { EnemyHPMultiplier = 1.00, EnemyCountMultiplier = 1.00, BossPhases = 3 },
}

function ClassDefinitions.GetClass(className)
	return ClassDefinitions.Classes[className]
end

function ClassDefinitions.GetDifficultyScale(playerCount)
	return ClassDefinitions.DifficultyScale[playerCount] or ClassDefinitions.DifficultyScale[4]
end

return ClassDefinitions
