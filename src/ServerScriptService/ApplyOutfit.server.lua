-- Erzwingt Ninja-Outfit unabhängig vom Avatar-System
-- ChildAdded-Wächter ersetzt Avatar-Kleidung sofort wenn sie lädt

local Players = game:GetService("Players")

local SHIRT = "rbxassetid://9572296491"
local PANTS = "rbxassetid://9572296491"

local function forceClothing(character)
	local ourShirt, ourPants

	local function replaceClothing(child)
		if child:IsA("Shirt") and child ~= ourShirt then
			child:Destroy()
			if not ourShirt or not ourShirt.Parent then
				ourShirt = Instance.new("Shirt")
				ourShirt.ShirtTemplate = SHIRT
				ourShirt.Parent = character
			end
		elseif child:IsA("Pants") and child ~= ourPants then
			child:Destroy()
			if not ourPants or not ourPants.Parent then
				ourPants = Instance.new("Pants")
				ourPants.PantsTemplate = PANTS
				ourPants.Parent = character
			end
		end
	end

	-- Bereits geladene Kleidung ersetzen
	for _, v in ipairs(character:GetChildren()) do
		replaceClothing(v)
	end

	-- Zukünftige Kleidung (Avatar-System lädt async) abfangen
	character.ChildAdded:Connect(replaceClothing)
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(forceClothing)
end)

for _, player in ipairs(Players:GetPlayers()) do
	if player.Character then
		forceClothing(player.Character)
	end
end
