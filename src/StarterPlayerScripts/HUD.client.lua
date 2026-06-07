-- HUD: eigene HP, Cooldown-Anzeige und Teamstatus aller Mitspieler

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local PlayerDowned = RemoteEvents:WaitForChild("PlayerDowned")

-- HUD-Root erstellen
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HUD"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- HP-Balken (unten links)
local hpContainer = Instance.new("Frame")
hpContainer.Size = UDim2.new(0.25, 0, 0.06, 0)
hpContainer.Position = UDim2.new(0.02, 0, 0.88, 0)
hpContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
hpContainer.Parent = screenGui
Instance.new("UICorner", hpContainer).CornerRadius = UDim.new(0, 6)

local hpBar = Instance.new("Frame")
hpBar.Name = "HPBar"
hpBar.Size = UDim2.fromScale(1, 1)
hpBar.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
hpBar.Parent = hpContainer
Instance.new("UICorner", hpBar).CornerRadius = UDim.new(0, 6)

local hpLabel = Instance.new("TextLabel")
hpLabel.Size = UDim2.fromScale(1, 1)
hpLabel.BackgroundTransparency = 1
hpLabel.Text = "HP: 100 / 100"
hpLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
hpLabel.TextScaled = true
hpLabel.Font = Enum.Font.GothamBold
hpLabel.Parent = hpContainer

-- Spezial-Cooldown (unten links, unter HP)
local specialLabel = Instance.new("TextLabel")
specialLabel.Size = UDim2.new(0.25, 0, 0.04, 0)
specialLabel.Position = UDim2.new(0.02, 0, 0.95, 0)
specialLabel.BackgroundTransparency = 1
specialLabel.Text = "[F] Spezial – bereit"
specialLabel.TextColor3 = Color3.fromRGB(220, 180, 80)
specialLabel.TextScaled = true
specialLabel.Font = Enum.Font.Gotham
specialLabel.Parent = screenGui

-- Team-Status (oben rechts)
local teamContainer = Instance.new("Frame")
teamContainer.Size = UDim2.new(0.2, 0, 0.3, 0)
teamContainer.Position = UDim2.new(0.78, 0, 0.02, 0)
teamContainer.BackgroundTransparency = 1
teamContainer.Parent = screenGui

local teamLayout = Instance.new("UIListLayout")
teamLayout.Padding = UDim.new(0, 6)
teamLayout.Parent = teamContainer

-- Teamkollegen-Einträge dynamisch erstellen/aktualisieren
local teamFrames = {}

local function updateTeamDisplay()
	for _, existing in pairs(teamFrames) do
		existing:Destroy()
	end
	teamFrames = {}

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= localPlayer then
			local frame = Instance.new("Frame")
			frame.Size = UDim2.new(1, 0, 0, 36)
			frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
			frame.Parent = teamContainer
			Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

			local label = Instance.new("TextLabel")
			label.Size = UDim2.fromScale(1, 1)
			label.BackgroundTransparency = 1
			label.Text = player.Name .. " – ❤️"
			label.TextColor3 = Color3.fromRGB(200, 200, 200)
			label.TextScaled = true
			label.Font = Enum.Font.Gotham
			label.Parent = frame

			teamFrames[player.UserId] = frame
		end
	end
end

-- Downed-Overlay für den lokalen Spieler
local downOverlay = Instance.new("Frame")
downOverlay.Size = UDim2.fromScale(1, 1)
downOverlay.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
downOverlay.BackgroundTransparency = 0.5
downOverlay.Visible = false
downOverlay.ZIndex = 10
downOverlay.Parent = screenGui

local downLabel = Instance.new("TextLabel")
downLabel.Size = UDim2.new(1, 0, 0, 80)
downLabel.Position = UDim2.new(0, 0, 0.4, 0)
downLabel.BackgroundTransparency = 1
downLabel.Text = "AUSGEKNOCKT\nTeamkollege muss dich retten! (R)"
downLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
downLabel.TextScaled = true
downLabel.Font = Enum.Font.GothamBold
downLabel.ZIndex = 11
downLabel.Parent = downOverlay

-- Down-State: Overlay, Bewegung und Teamanzeige
local downStateConn = nil  -- StateChanged-Guard, solange Spieler down ist

PlayerDowned.OnClientEvent:Connect(function(userId, isDownNow)

	if userId == localPlayer.UserId then
		local char = localPlayer.Character
		local h    = char and char:FindFirstChildOfClass("Humanoid")
		local root = char and char:FindFirstChild("HumanoidRootPart")

		downOverlay.Visible = isDownNow

		if isDownNow then
			if h then
				-- Alle "Hinlegen"-States deaktivieren
				h:SetStateEnabled(Enum.HumanoidStateType.Dead,        false)
				h:SetStateEnabled(Enum.HumanoidStateType.FallingDown,  false)
				h:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,      false)
				h.WalkSpeed  = 0
				h.JumpHeight = 0

				-- Guard: falls trotzdem ein Lieg-State auftritt, sofort zurück
				if downStateConn then downStateConn:Disconnect() end
				downStateConn = h.StateChanged:Connect(function(_, new)
					if new == Enum.HumanoidStateType.Dead
					or new == Enum.HumanoidStateType.FallingDown
					or new == Enum.HumanoidStateType.Ragdoll then
						task.defer(function()
							if h then h:ChangeState(Enum.HumanoidStateType.GettingUp) end
						end)
					end
				end)
			end

			-- Physikalisches Umwerfen durch andere Spieler verhindern
			if root then root.Anchored = true end

			-- Eigenen Prompt ausblenden
			if root then
				local function disableIn(att)
					local prompt = att:FindFirstChildOfClass("ProximityPrompt")
						or att:WaitForChild("ProximityPrompt", 2)
					if prompt then prompt.Enabled = false end
				end
				local att = root:FindFirstChild("ReviveAttachment")
				if att then
					disableIn(att)
				else
					local conn
					conn = root.ChildAdded:Connect(function(child)
						if child.Name == "ReviveAttachment" then
							conn:Disconnect()
							disableIn(child)
						end
					end)
				end
			end

		else
			-- Guard stoppen und Zustände wiederherstellen
			if downStateConn then
				downStateConn:Disconnect()
				downStateConn = nil
			end
			if h then
				h:SetStateEnabled(Enum.HumanoidStateType.Dead,        true)
				h:SetStateEnabled(Enum.HumanoidStateType.FallingDown,  true)
				h:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,      true)
				h.WalkSpeed  = 16
				h.JumpHeight = 7.2
			end
			if root then root.Anchored = false end
		end
	end

	-- Teamanzeige aktualisieren
	local frame = teamFrames[userId]
	if frame then
		frame.BackgroundColor3 = isDownNow
			and Color3.fromRGB(80, 20, 20)
			or  Color3.fromRGB(20, 20, 30)
		local label = frame:FindFirstChildOfClass("TextLabel")
		local p = Players:GetPlayerByUserId(userId)
		if label and p then
			label.Text = isDownNow
				and (p.Name .. " – AUSGEKNOCKT")
				or  (p.Name .. " – ❤️")
		end
	end
end)

-- HP des lokalen Spielers aktualisieren
RunService.Heartbeat:Connect(function()
	local character = localPlayer.Character
	if not character then return end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	local hp = math.floor(humanoid.Health)
	local maxHp = math.floor(humanoid.MaxHealth)
	local ratio = hp / math.max(maxHp, 1)

	hpBar.Size = UDim2.fromScale(ratio, 1)
	hpLabel.Text = ("HP: %d / %d"):format(hp, maxHp)
end)

Players.PlayerAdded:Connect(updateTeamDisplay)
Players.PlayerRemoving:Connect(updateTeamDisplay)
updateTeamDisplay()
