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

-- Spieler ist ausgeknockt → Eintrag rot färben
PlayerDowned.OnClientEvent:Connect(function(userId)
	local frame = teamFrames[userId]
	if frame then
		frame.BackgroundColor3 = Color3.fromRGB(80, 20, 20)
		local label = frame:FindFirstChildOfClass("TextLabel")
		if label then
			local player = Players:GetPlayerByUserId(userId)
			label.Text = (player and player.Name or "?") .. " – AUSGEKNOCKT"
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
