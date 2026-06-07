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

	local root = character:FindFirstChild("HumanoidRootPart")
	if root then
		local att = root:FindFirstChild("ReviveAttachment")
		if att then att:Destroy() end
		root.Anchored = false
	end

	local h = character:FindFirstChildOfClass("Humanoid")
	if h then
		isDown.Value   = false
		h.WalkSpeed    = 16
		h.JumpHeight   = 7.2
		h.Health       = REVIVE_HP
		h:ChangeState(Enum.HumanoidStateType.Running)
	end

	print(("[Down] %s gerettet von %s"):format(target.Name, reviver.Name))
	PlayerDowned:FireAllClients(target.UserId, false)
end

local function setupCharacter(player, character)
	local humanoid = character:WaitForChild("Humanoid")
	local root     = character:WaitForChild("HumanoidRootPart")

	-- Verhindert automatischen Tod zuverlässig
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)

	local isDown = Instance.new("BoolValue")
	isDown.Name   = "IsDown"
	isDown.Value  = false
	isDown.Parent = character

	-- Heartbeat: Sicherheitsnetz – hält HP bei 1 solange down
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
			isDown.Value       = true
			humanoid.Health    = 1      -- synchron, kein defer
			humanoid.WalkSpeed = 0
			humanoid.JumpHeight = 0
			root.Anchored      = true

			-- Attachment + Prompt ZUERST erstellen
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

			-- DANN Event feuern (Attachment ist jetzt bereits vorhanden)
			PlayerDowned:FireAllClients(player.UserId, true)
			print(("[Down] %s ist ausgeknockt!"):format(player.Name))

			-- 30s bis echter Tod
			downTimers[player.UserId] = task.delay(DOWN_DURATION, function()
				if isDown.Value then
					root.Anchored = false
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
