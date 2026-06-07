-- Wächter-NPC: patrouilliert, erkennt Spieler, greift an
-- Dieses Script sitzt direkt im Guard-Modell (nicht in ServerScriptService)

local Players = game:GetService("Players")

local model      = script.Parent
local humanoid   = model:WaitForChild("Humanoid")
local rootPart   = model:WaitForChild("HumanoidRootPart")

local DETECTION_RANGE  = 20    -- Studs bis Spieler erkannt wird
local ATTACK_RANGE     = 4     -- Studs bis Angriff ausgelöst wird
local ATTACK_DAMAGE    = 15    -- HP Schaden pro Treffer
local ATTACK_COOLDOWN  = 1.5   -- Sekunden zwischen Angriffen
local PATROL_RADIUS    = 8     -- Wie weit der Wächter vom Spawn patrouilliert
local PATROL_WAIT      = 2     -- Sekunden Pause zwischen Patrouillenpunkten

-- Patrouillenpunkte um den Spawn herum
local spawnPos = rootPart.Position
local patrolPoints = {
	spawnPos + Vector3.new( PATROL_RADIUS, 0, 0),
	spawnPos + Vector3.new( PATROL_RADIUS, 0, PATROL_RADIUS),
	spawnPos + Vector3.new(0, 0,  PATROL_RADIUS),
	spawnPos,
}
local patrolIndex   = 1
local lastAttackTime = 0

-- Nächsten lebenden Spieler innerhalb der Erkennungsreichweite finden
local function findNearestPlayer()
	local nearest, nearestDist = nil, DETECTION_RANGE
	for _, player in ipairs(Players:GetPlayers()) do
		local char = player.Character
		if char then
			local root = char:FindFirstChild("HumanoidRootPart")
			local h    = char:FindFirstChildOfClass("Humanoid")
			if root and h and h.Health > 0 then
				local dist = (rootPart.Position - root.Position).Magnitude
				if dist < nearestDist then
					nearestDist = dist
					nearest     = player
				end
			end
		end
	end
	return nearest
end

-- Schaden am Zielspieler anwenden
local function attackPlayer(player)
	local char = player.Character
	if not char then return end
	local h = char:FindFirstChildOfClass("Humanoid")
	if h and h.Health > 0 then
		h:TakeDamage(ATTACK_DAMAGE)
		print(("[Guard] Greift %s an! (-%d HP)"):format(player.Name, ATTACK_DAMAGE))
	end
end

-- Haupt-KI-Loop
while true do
	task.wait(0.1)

	-- Toter Wächter hört auf
	if humanoid.Health <= 0 then
		print("[Guard] Besiegt.")
		break
	end

	local target = findNearestPlayer()

	if target then
		-- Spieler in Reichweite → verfolgen oder angreifen
		local targetRoot = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
		if targetRoot then
			local dist = (rootPart.Position - targetRoot.Position).Magnitude
			if dist <= ATTACK_RANGE then
				-- Stehen bleiben und angreifen
				humanoid:MoveTo(rootPart.Position)
				local now = tick()
				if now - lastAttackTime >= ATTACK_COOLDOWN then
					lastAttackTime = now
					attackPlayer(target)
				end
			else
				-- Spieler verfolgen
				humanoid:MoveTo(targetRoot.Position)
			end
		end
	else
		-- Kein Spieler in der Nähe → patrouillieren
		local goal = patrolPoints[patrolIndex]
		humanoid:MoveTo(goal)
		if (rootPart.Position - goal).Magnitude < 2 then
			task.wait(PATROL_WAIT)
			patrolIndex = patrolIndex % #patrolPoints + 1
		end
	end
end
