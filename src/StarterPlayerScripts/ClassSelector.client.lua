-- Klassenauswahl-UI beim Spielstart (Client)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- RemoteEvent um gewählte Klasse an Server zu senden
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local SelectClass = RemoteEvents:WaitForChild("SelectClass")

local CLASS_DATA = {
	{ Id = "Kenshi",   DisplayName = "Kenshi",   Icon = "⚔️", Description = "Tank · Kiai-Schrei lähmt Gegner" },
	{ Id = "Kassha",   DisplayName = "Kassha",   Icon = "🏹", Description = "Distanzkampf · Feuerpfeil entzündet Rätsel" },
	{ Id = "Kaze",     DisplayName = "Kaze",     Icon = "🌪️", Description = "Scout · Windschritt überwindet Fallen" },
	{ Id = "Kunoichi", DisplayName = "Kunoichi", Icon = "🧪", Description = "Support · Heilrauch heilt das Team" },
}

local selectedClass = nil
local confirmButton  -- forward declaration, wird weiter unten erstellt

-- UI erstellen
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ClassSelector"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local background = Instance.new("Frame")
background.Size = UDim2.fromScale(1, 1)
background.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
background.BackgroundTransparency = 0.3
background.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 60)
title.Position = UDim2.new(0, 0, 0.1, 0)
title.BackgroundTransparency = 1
title.Text = "Wähle deinen Ninja"
title.TextColor3 = Color3.fromRGB(220, 180, 80)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = background

-- Klassen-Buttons
local buttonContainer = Instance.new("Frame")
buttonContainer.Size = UDim2.new(0.8, 0, 0.4, 0)
buttonContainer.Position = UDim2.new(0.1, 0, 0.3, 0)
buttonContainer.BackgroundTransparency = 1
buttonContainer.Parent = background

local layout = Instance.new("UIGridLayout")
layout.CellSize = UDim2.new(0.23, 0, 1, 0)
layout.CellPadding = UDim2.new(0.02, 0, 0, 0)
layout.Parent = buttonContainer

for _, classData in ipairs(CLASS_DATA) do
	local btn = Instance.new("TextButton")
	btn.Name = classData.Id
	btn.Text = classData.Icon .. "\n" .. classData.DisplayName .. "\n\n" .. classData.Description
	btn.TextColor3 = Color3.fromRGB(240, 240, 240)
	btn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
	btn.TextScaled = true
	btn.Font = Enum.Font.Gotham
	btn.AutoButtonColor = false

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = btn

	btn.MouseButton1Click:Connect(function()
		selectedClass = classData.Id

		-- Alle Buttons zurücksetzen
		for _, child in ipairs(buttonContainer:GetChildren()) do
			if child:IsA("TextButton") then
				child.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
			end
		end

		-- Gewählten Button hervorheben
		btn.BackgroundColor3 = Color3.fromRGB(80, 60, 20)

		-- Bestätigungs-Button aktivieren
		confirmButton.Active = true
		confirmButton.BackgroundColor3 = Color3.fromRGB(180, 140, 30)
	end)

	btn.Parent = buttonContainer
end

-- Bestätigen-Button
confirmButton = Instance.new("TextButton")
confirmButton.Name = "ConfirmButton"
confirmButton.Size = UDim2.new(0.3, 0, 0.08, 0)
confirmButton.Position = UDim2.new(0.35, 0, 0.78, 0)
confirmButton.Text = "Ninja wählen"
confirmButton.TextColor3 = Color3.fromRGB(20, 20, 20)
confirmButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
confirmButton.TextScaled = true
confirmButton.Font = Enum.Font.GothamBold
confirmButton.Active = false
confirmButton.Parent = background

local confirmCorner = Instance.new("UICorner")
confirmCorner.CornerRadius = UDim.new(0, 8)
confirmCorner.Parent = confirmButton

confirmButton.MouseButton1Click:Connect(function()
	if not selectedClass or not confirmButton.Active then return end

	SelectClass:FireServer(selectedClass)

	-- UI ausblenden
	TweenService:Create(background, TweenInfo.new(0.5), { BackgroundTransparency = 1 }):Play()
	task.delay(0.6, function()
		screenGui:Destroy()
	end)
end)
