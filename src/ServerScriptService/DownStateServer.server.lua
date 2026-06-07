-- Down-State und Revive-Mechanik (Server-autoritativ)
-- Der Server verhindert den Tod und verwaltet Timer + Prompt.
-- Bewegungsblockierung wird clientseitig im HUD-Script gehandhabt,
-- da der Owner-Client Server-Änderungen an WalkSpeed nicht zuverlässig übernimmt.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local PlayerDowned = RemoteEvents:WaitForChild("PlayerDowned")

local DOWN_DURATION = 30
local REVIVE_HP     = 50

local downTimers = {}

local function revivePlayer(target, reviver)
	local character = target.Character
	if not character then return end

	local isDown = character:FindFirstChild("IsDown")
	if not isDown or not isDown.Value then return end

	if downTimers[target.UserId] then
		task.cancel(downTimers[target.UserId])
		downTimers[target.UserId] = nil
	end

	-- Prompt entfernen
	local root = character:FindFirstChild("HumanoidRootPart")
	if root then
		local att = root:FindFirstChild("ReviveAttachment")
		if att then att:Destroy() end
	end

	local h = character:FindFirstChildOfClass("Humanoid")
	if h then
		isDown.Value = false
		h.Health     = REVIVE_HP
		-- WalkSpeed/JumpHeight werden clientseitig im HUD-Script wiederhergestellt
	end

	print(("[Down] %s gerettet von %s"):format(target.Name, reviver.Name))
	-- false = wieder lebendig; Client stellt Bewegung wieder her
	PlayerDowned:FireAllClients(target.UserId, false)
end

local function setupCharacter(player, character)
	local humanoid = character:WaitForChild("Humanoid")

	-- Serverseitig Tod verhindern
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)

	local isDown = Instance.new("BoolValue")
	isDown.Name   = "IsDown"
	isDown.Value  = false
	isDown.Parent = character

	-- Heartbeat-Sicherheitsnetz: hält HP bei 1 solange down
	local heartbeatConn
	heartbeatConn = RunService.Heartbeat:Connect(function()
		if not isDown.Value then
			heartbeatConn:Disconnect()
			return
		end
		if humanoid.Health <= 0 then
			humanoid.Health = 1
		end
	end)

	humanoid.HealthChanged:Connect(function(hp)
		if hp <= 0 and not isDown.Value then
			isDown.Value    = true
			humanoid.Health = 1  -- synchron zurücksetzen

			-- Attachment + Prompt erstellen bevor Event gefeuert wird
			local root = character:FindFirstChild("HumanoidRootPart")
			if root then
				local att = Instance.new("Attachment")
				att.Name     = "ReviveAttachment"
				att.Position = Vector3.new(0, 3, 0)
				att.Parent   = root

				local prompt = Instance.new("ProximityPrompt")
				prompt.ActionText            = "Wiederbeleben"
				prompt.ObjectText            = player.Name
				prompt.KeyboardKeyCode       = Enum.KeyCode.R
				prompt.HoldDuration          = 3
				prompt.MaxActivationDistance = 8
				prompt.RequiresLineOfSight   = false
				prompt.Parent = att

				prompt.Triggered:Connect(function(reviverPlayer)
					if reviverPlayer ~= player then
						revivePlayer(player, reviverPlayer)
					end
				end)
			end

			-- true = ausgeknockt; Client blockiert Bewegung selbst
			PlayerDowned:FireAllClients(player.UserId, true)
			print(("[Down] %s ist ausgeknockt!"):format(player.Name))

			-- 30s bis echter Tod
			downTimers[player.UserId] = task.delay(DOWN_DURATION, function()
				if isDown.Value then
					print(("[Down] %s nicht gerettet – stirbt"):format(player.Name))
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
