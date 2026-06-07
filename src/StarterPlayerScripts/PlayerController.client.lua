-- Bewegung, Kamera und lokale Spielersteuerung (Client)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

camera.CameraType = Enum.CameraType.Custom

-- Doppeltap-Ausweichen: merkt sich letzten Tap pro Richtungstaste
local lastTap = { W = 0, A = 0, S = 0, D = 0 }
local DOUBLE_TAP_WINDOW = 0.3
local isDodging = false
local DODGE_DURATION = 0.4

local directionKeys = {
	[Enum.KeyCode.W] = "W",
	[Enum.KeyCode.A] = "A",
	[Enum.KeyCode.S] = "S",
	[Enum.KeyCode.D] = "D",
}

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	local dir = directionKeys[input.KeyCode]
	if dir then
		local now = tick()
		if now - lastTap[dir] <= DOUBLE_TAP_WINDOW and not isDodging then
			-- Ausweichen auslösen
			isDodging = true
			local character = localPlayer.Character
			if character then
				local humanoid = character:FindFirstChildOfClass("Humanoid")
				if humanoid then
					-- Kurze Unverwundbarkeits-Phase signalisieren
					local root = character:FindFirstChild("HumanoidRootPart")
					if root then
						-- Visuelles Feedback (Transparenz)
						for _, part in ipairs(character:GetDescendants()) do
							if part:IsA("BasePart") then
								part.Transparency = 0.5
							end
						end
					end
				end
			end

			task.delay(DODGE_DURATION, function()
				isDodging = false
				local character = localPlayer.Character
				if character then
					for _, part in ipairs(character:GetDescendants()) do
						if part:IsA("BasePart") then
							part.Transparency = 0
						end
					end
				end
			end)
		end
		lastTap[dir] = now
	end
end)
