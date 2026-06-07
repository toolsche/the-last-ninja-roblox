-- Down-State und Revive-Mechanik (Server-autoritativ)
-- Spieler stirbt nicht sofort, sondern liegt 30 Sekunden am Boden.
-- ProximityPrompt erscheint automatisch über dem ausgeknockte Spieler.
-- Teamkollege hält R 3 Sekunden gedrückt → Wiederbelebung.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local PlayerDowned = RemoteEvents:WaitForChild("PlayerDowned")

local DOWN_DURATION = 30   -- Sekunden bis echter Tod
local REVIVE_HP     = 50   -- HP nach Wiederbelebung

local downTimers = {}      -- [userId] = task handle

local function revivePlayer(target, reviver)
	local character = target.Character
	if not character then return end

	local isDown = character:FindFirstChild("IsDown")
	if not isDown or not isDown.Value then return end

	-- Down-Timer stoppen
	if downTimers[target.UserId] then
		task.cancel(downTimers[target.UserId])
		downTimers[target.UserId] = nil
	end

	-- ProximityPrompt entfernen
	local root = character:FindFirstChild("HumanoidRootPart")
	if root then
		local prompt = root:FindFirstChildOfClass("ProximityPrompt")
		if prompt then prompt:Destroy() end
	end

	-- Spieler wiederbeleben
	local h = character:FindFirstChildOfClass("Humanoid")
	if h then
		isDown.Value   = false
		h.Health       = REVIVE_HP
		h.WalkSpeed    = 16
		h.JumpPower    = 50
	end

	print(("[Down] %s wurde von %s gerettet!"):format(target.Name, reviver.Name))
	PlayerDowned:FireAllClients(target.UserId, false)
end

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

			-- ProximityPrompt über dem Spieler platzieren
			local root = character:FindFirstChild("HumanoidRootPart")
			if root then
				local prompt = Instance.new("ProximityPrompt")
				prompt.ActionText       = "Wiederbeleben"
				prompt.ObjectText       = player.Name
				prompt.KeyboardKeyCode  = Enum.KeyCode.R
				prompt.HoldDuration     = 3     -- 3 Sekunden halten
				prompt.MaxActivationDistance = 6
				prompt.RequiresLineOfSight   = false
				prompt.Parent = root

				-- Wird ausgelöst wenn Teamkollege R 3 Sekunden hält
				prompt.Triggered:Connect(function(reviverPlayer)
					if reviverPlayer ~= player then
						revivePlayer(player, reviverPlayer)
					end
				end)
			end

			-- 30s bis echter Tod
			downTimers[player.UserId] = task.delay(DOWN_DURATION, function()
				if isDown.Value then
					print(("[Down] %s wurde nicht rechtzeitig gerettet."):format(player.Name))
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

Players.PlayerRemoving:Connect(function(player)
	if downTimers[player.UserId] then
		task.cancel(downTimers[player.UserId])
		downTimers[player.UserId] = nil
	end
end)
