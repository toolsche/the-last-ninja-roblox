-- Gegner spawnen und KI-Tick

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClassDefinitions = require(ReplicatedStorage.Modules.ClassDefinitions)
local EnemyAI = require(ReplicatedStorage.Modules.EnemyAI)

local AI_TICK_RATE = 0.5  -- Sekunden zwischen KI-Updates

-- Spawnt Gegner für eine Zone mit Skalierung nach Spieleranzahl
local function spawnEnemiesForZone(zoneFolder, enemyConfigs)
	local playerCount = math.clamp(#Players:GetPlayers(), 2, 4)
	local scale = ClassDefinitions.GetDifficultyScale(playerCount)

	for _, config in ipairs(enemyConfigs) do
		local scaledCount = math.floor(config.Count * scale.EnemyCountMultiplier)
		for i = 1, scaledCount do
			-- TODO: Gegner-Modell aus ReplicatedStorage klonen und in Zone platzieren
			-- local enemy = ReplicatedStorage.Enemies[config.Type]:Clone()
			-- enemy.Parent = zoneFolder
			-- Humanoid HP skalieren: enemy.Humanoid.MaxHealth *= scale.EnemyHPMultiplier
			print(("[EnemySpawner] Spawn %s #%d in %s (HP: %d%%)"):format(
				config.Type, i, zoneFolder.Name, scale.EnemyHPMultiplier * 100
			))
		end
	end
end

-- KI-Tick: läuft für alle aktiven Gegner
local function runAITick()
	local playerList = {}
	for _, player in ipairs(Players:GetPlayers()) do
		if player.Character then
			table.insert(playerList, {
				Player    = player,
				Position  = player.Character:GetPivot().Position,
				HPPercent = (player.Character:FindFirstChildOfClass("Humanoid") and
					player.Character.Humanoid.Health / player.Character.Humanoid.MaxHealth) or 1,
				IsDown    = false,  -- TODO: aus GameManager holen
				IsReviving = false,
			})
		end
	end

	if #playerList == 0 then return end

	-- Isolation berechnen: Spieler ist isoliert wenn > 15 Studs von allen anderen entfernt
	for _, pData in ipairs(playerList) do
		local minDist = math.huge
		for _, other in ipairs(playerList) do
			if other ~= pData then
				local dist = (pData.Position - other.Position).Magnitude
				if dist < minDist then minDist = dist end
			end
		end
		pData.IsIsolated = minDist > EnemyAI.EnemyStats.Archer.IsolationThreshold
	end

	-- TODO: über alle aktiven Gegner iterieren und State-Machine updaten
end

-- KI-Loop starten
task.spawn(function()
	while true do
		task.wait(AI_TICK_RATE)
		runAITick()
	end
end)

return {
	SpawnEnemiesForZone = spawnEnemiesForZone,
}
