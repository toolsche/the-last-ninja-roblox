-- Down-State und Revive-Mechanik (Server-autoritativ)
-- Spieler stirbt nicht sofort, sondern liegt 30 Sekunden am Boden.
-- Ein Teamkollege kann ihn in 3 Sekunden wiederbeleben (R-Taste).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local RevivePlayer = RemoteEvents:WaitForChild("RevivePlayer")
local PlayerDowned = RemoteEvents:WaitForChild("PlayerDowned")

local DOWN_DURATION = 30   -- Sekunden bis echter Tod
local REVIVE_TIME   = 3    -- Sekunden zum Wiederbeleben
local REVIVE_RANGE  = 6    -- Studs maximale Distanz
local REVIVE_HP     = 50   -- HP nach Wiederbelebung

local downTimers  = {}     -- [userId] = task handle
local reviveTasks = {}     -- [targetUserId] = task handle

local function setupCharacter(player, character)
	local humanoid = character:WaitForChild("Humanoid")

	-- Automatischen Tod deaktivieren
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)

	local isDown = Instance.new("BoolValue")
	isDown.Name   = "IsDown"
	isDown.Value  = false
	isDown.Parent = character

	humanoid.HealthChanged:Connect(function(hp)
		if hp <= 0 and not isDown.Value then
			isDown.Value       = true
			humanoid.Health    = 1
			humanoid.WalkSpeed = 0
			humanoid.JumpPower = 0

			print(("[Down] %s ist ausgeknockt!"):format(player.Name))
			PlayerDowned:FireAllClients(player.UserId, true)

			-- 30s bis echter Tod
			downTimers[player.UserId] = task.delay(DOWN_DURATION, function()
				if isDown.Value then
					humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
					humanoid.Health = 0
				end
			end)
		end
	end)
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		task.wait(0.5)
		setupCharacter(player, character)
	end)
end)

for _, player in ipairs(Players:GetPlayers()) do
	if player.Character then
		task.wait(0.5)
		setupCharacter(player, player.Character)
	end
end

-- Revive-Anfrage vom Client
RevivePlayer.OnServerEvent:Connect(function(reviver, targetUserId)
	local target = Players:GetPlayerByUserId(targetUserId)
	if not target or not target.Character then return end

	local isDown = target.Character:FindFirstChild("IsDown")
	if not isDown or not isDown.Value then return end

	local rRoot = reviver.Character and reviver.Character:FindFirstChild("HumanoidRootPart")
	local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
	if not rRoot or not tRoot then return end
	if (rRoot.Position - tRoot.Position).Magnitude > REVIVE_RANGE then return end

	if reviveTasks[targetUserId] then return end

	print(("[Down] %s revived %s... (3s)"):format(reviver.Name, target.Name))

	reviveTasks[targetUserId] = task.delay(REVIVE_TIME, function()
		reviveTasks[targetUserId] = nil

		if not reviver.Character then return end
		rRoot = reviver.Character:FindFirstChild("HumanoidRootPart")
		if not rRoot or (rRoot.Position - tRoot.Position).Magnitude > REVIVE_RANGE then
			print("[Down] Revive abgebrochen – zu weit weg")
			return
		end

		if downTimers[targetUserId] then
			task.cancel(downTimers[targetUserId])
			downTimers[targetUserId] = nil
		end

		local h = target.Character:FindFirstChildOfClass("Humanoid")
		if h then
			isDown.Value   = false
			h.Health       = REVIVE_HP
			h.WalkSpeed    = 16
			h.JumpPower    = 50
		end

		print(("[Down] %s wurde gerettet!"):format(target.Name))
		PlayerDowned:FireAllClients(targetUserId, false)
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	if downTimers[player.UserId] then
		task.cancel(downTimers[player.UserId])
	end
end)
