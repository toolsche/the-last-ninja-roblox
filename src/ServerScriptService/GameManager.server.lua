-- Rundenstart, Zonenübergänge und globaler Spielzustand (Server-autoritativ)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClassDefinitions = require(ReplicatedStorage.Modules.ClassDefinitions)

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local SelectClass = RemoteEvents:WaitForChild("SelectClass")

-- [userId] = { Class, MaxHP, IsDown }
local playerData = {}

-- Wendet Klassen-Stats (HP, Walkspeed) auf den Character an
local function applyClassToCharacter(character, classDef)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	humanoid.MaxHealth = classDef.MaxHP
	humanoid.Health    = classDef.MaxHP
	humanoid.WalkSpeed = classDef.WalkSpeed

	print(("[GameManager] Stats gesetzt: HP=%d, Speed=%d"):format(classDef.MaxHP, classDef.WalkSpeed))
end

-- Spieler hat eine Klasse gewählt
SelectClass.OnServerEvent:Connect(function(player, className)
	local classDef = ClassDefinitions.GetClass(className)
	if not classDef then
		warn(("[GameManager] Unbekannte Klasse: %s"):format(tostring(className)))
		return
	end

	playerData[player.UserId] = {
		Class  = className,
		MaxHP  = classDef.MaxHP,
		IsDown = false,
	}

	print(("[GameManager] %s spielt als %s (HP:%d Speed:%d)"):format(
		player.Name, classDef.DisplayName, classDef.MaxHP, classDef.WalkSpeed
	))

	-- Sofort am aktuellen Character anwenden
	if player.Character then
		applyClassToCharacter(player.Character, classDef)
	end

	-- Auch nach jedem Respawn erneut anwenden
	player.CharacterAdded:Connect(function(character)
		-- Kurz warten bis Humanoid vollständig geladen ist
		task.wait(0.1)
		applyClassToCharacter(character, classDef)
	end)
end)

-- Aufräumen wenn Spieler das Spiel verlässt
Players.PlayerRemoving:Connect(function(player)
	playerData[player.UserId] = nil
end)

-- Öffentliche Hilfsfunktion für andere Scripts
local GameManager = {}

function GameManager.GetPlayerData(userId)
	return playerData[userId]
end

function GameManager.SetPlayerDown(userId, isDown)
	if playerData[userId] then
		playerData[userId].IsDown = isDown
	end
end

return GameManager
