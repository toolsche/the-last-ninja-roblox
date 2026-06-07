-- Erzwingt Ninja-Outfit für alle Spieler unabhängig vom Avatar
-- Avatar-Appearance lädt asynchron nach CharacterAdded → daher task.wait(1)

local Players = game:GetService("Players")

local SHIRT_ID = 9572296491
local PANTS_ID = 9572296491

local function applyNinjaOutfit(character)
	local humanoid = character:WaitForChild("Humanoid")
	task.wait(1)  -- Avatar-Appearance lädt asynchron; 1s reicht für Studio + Live
	local desc = humanoid:GetAppliedDescription()
	desc.Shirt = SHIRT_ID
	desc.Pants  = PANTS_ID
	humanoid:ApplyDescription(desc)
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		applyNinjaOutfit(character)
	end)
end)

for _, player in ipairs(Players:GetPlayers()) do
	if player.Character then
		task.spawn(applyNinjaOutfit, player.Character)
	end
end
