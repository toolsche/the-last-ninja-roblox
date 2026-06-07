-- Rundenstart, Zonenübergänge und globaler Spielzustand (Server-autoritativ)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClassDefinitions = require(ReplicatedStorage.Modules.ClassDefinitions)

local GameManager = {}

-- Spielzustand
local gameState = {
	Phase = "Lobby",     -- Lobby | Playing | GameOver | Victory
	CurrentZone = 1,
	PlayerData = {},     -- [userId] = { Class, HP, MaxHP, Inventory, IsDown }
}

local MIN_PLAYERS = 2
local MAX_PLAYERS = 4

-- Spieler betritt das Spiel
local function onPlayerAdded(player)
	if #Players:GetPlayers() > MAX_PLAYERS then
		player:Kick("Das Spiel unterstützt maximal 4 Spieler.")
		return
	end
	print(("[GameManager] %s ist beigetreten (%d/%d Spieler)"):format(
		player.Name, #Players:GetPlayers(), MAX_PLAYERS
	))
end

-- Spieler verlässt das Spiel
local function onPlayerRemoving(player)
	gameState.PlayerData[player.UserId] = nil
	print(("[GameManager] %s hat das Spiel verlassen"):format(player.Name))
end

-- Klasse einem Spieler zuweisen (aufgerufen nach Klassenauswahl)
function GameManager.AssignClass(player, className)
	local classDef = ClassDefinitions.GetClass(className)
	if not classDef then
		warn(("[GameManager] Unbekannte Klasse: %s"):format(className))
		return false
	end

	gameState.PlayerData[player.UserId] = {
		Class   = className,
		HP      = classDef.MaxHP,
		MaxHP   = classDef.MaxHP,
		IsDown  = false,
	}

	print(("[GameManager] %s spielt als %s"):format(player.Name, classDef.DisplayName))
	return true
end

-- Startet das Spiel wenn genügend Spieler eine Klasse gewählt haben
function GameManager.TryStartGame()
	local readyCount = 0
	for _ in pairs(gameState.PlayerData) do
		readyCount = readyCount + 1
	end

	if readyCount >= MIN_PLAYERS and gameState.Phase == "Lobby" then
		gameState.Phase = "Playing"
		print(("[GameManager] Spiel startet mit %d Spielern!"):format(readyCount))
		-- TODO: Zone 1 laden, Spawn-Punkte setzen
	end
end

-- Zonenübergang
function GameManager.TransitionToZone(zoneNumber)
	gameState.CurrentZone = zoneNumber
	print(("[GameManager] Übergang zu Zone %d"):format(zoneNumber))
	-- TODO: aktuelle Zone entladen, neue Zone laden, Spieler teleportieren
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

return GameManager
