-- Gegenstandssystem: Aufheben, Inventar, Teilen mit Teamkollegen

local ItemSystem = {}

ItemSystem.ItemType = {
	HEALTH_HERB  = "HealthHerb",    -- Heilt 50 HP
	KEY          = "Key",            -- Öffnet Türen/Truhen
	SHURIKEN     = "Shuriken",
	FIRE_ARROW   = "FireArrow",
	SMOKE_BOMB   = "SmokeBomb",
	POISON_BOMB  = "PoisonBomb",
}

ItemSystem.ItemData = {
	HealthHerb = { DisplayName = "Heilkraut",    StackSize = 3, HealAmount = 50 },
	Key        = { DisplayName = "Schlüssel",     StackSize = 1 },
	Shuriken   = { DisplayName = "Shuriken",      StackSize = 10 },
	FireArrow  = { DisplayName = "Feuerpfeil",    StackSize = 5 },
	SmokeBomb  = { DisplayName = "Rauchbombe",    StackSize = 3 },
	PoisonBomb = { DisplayName = "Giftbombe",     StackSize = 3 },
}

-- Erstellt ein leeres Inventar
function ItemSystem.NewInventory()
	return {}
end

-- Fügt einen Gegenstand zum Inventar hinzu; gibt true zurück bei Erfolg
function ItemSystem.AddItem(inventory, itemType, amount)
	amount = amount or 1
	local data = ItemSystem.ItemData[itemType]
	if not data then return false end

	if inventory[itemType] then
		local newCount = inventory[itemType] + amount
		inventory[itemType] = math.min(newCount, data.StackSize)
	else
		inventory[itemType] = math.min(amount, data.StackSize)
	end
	return true
end

-- Entfernt einen Gegenstand; gibt true zurück bei Erfolg
function ItemSystem.RemoveItem(inventory, itemType, amount)
	amount = amount or 1
	if not inventory[itemType] or inventory[itemType] < amount then
		return false
	end
	inventory[itemType] = inventory[itemType] - amount
	if inventory[itemType] <= 0 then
		inventory[itemType] = nil
	end
	return true
end

-- Gibt zurück wie viele Gegenstände eines Typs vorhanden sind
function ItemSystem.GetCount(inventory, itemType)
	return inventory[itemType] or 0
end

return ItemSystem
