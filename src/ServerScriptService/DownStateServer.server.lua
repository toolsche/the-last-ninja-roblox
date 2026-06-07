-- Down-State und Revive-Mechanik (Server-autoritativ)

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
		-- Root wieder beweglich machen
		root.Anchored = false
	end

	local h = character:FindFirstChildOfClass("Humanoid")
	if h then
		isDown.Value   = false
		h.WalkSpeed    = 16
		h.JumpHeight   = 7.2
		h.Health       = REVIVE_HP
	end

	print(("[Down] %s wurde von %s gerettet!"):format(target.Name, reviver.Name))
	PlayerDowned:FireAllClients(target.UserId, false)
end

local function setupCharacter(player, character)
	local humanoid = character:WaitForChild("Humanoid")
	local root     = character:WaitForChild("HumanoidRootPart")

	local isDown = Instance.new("BoolValue")
	isDown.Name   = "IsDown"
	isDown.Value  = false
	isDown.Parent = character

	-- Heartbeat: hält HP bei 1 solange Spieler down ist (Sicherheitsnetz)
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
			isDown.Value = true

			-- Health im nächsten Frame zurücksetzen (zuverlässiger als im Callback)
			task.defer(function()
				if humanoid.Health <= 0 then
					humanoid.Health = 1
				end
			end)

			-- Root einfrieren statt WalkSpeed zu manipulieren
			root.Anchored  = true
			humanoid.WalkSpeed = 0
			humanoid.JumpHeight = 0

			print(("[Down] %s ist ausgeknockt!"):format(player.Name))
			PlayerDowned:FireAllClients(player.UserId, true)

			-- ProximityPrompt 3 Studs über dem Kopf
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

			-- 30s bis echter Tod
			downTimers[player.UserId] = task.delay(DOWN_DURATION, function()
				if isDown.Value then
					print(("[Down] %s wurde nicht rechtzeitig gerettet."):format(player.Name))
					root.Anchored = false
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
