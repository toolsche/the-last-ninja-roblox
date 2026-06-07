-- Down-State Client: verwaltet Bewegung und Zustände des EIGENEN Spielers
-- Getrennt vom HUD damit die Zuständigkeiten klar sind

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local localPlayer = Players.LocalPlayer
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local PlayerDowned = RemoteEvents:WaitForChild("PlayerDowned")

-- Dead-State bei jedem neuen Character client-seitig deaktivieren
-- (verhindert Tod-Animation wenn Health kurz 0 wird)
local function setupCharacterClient(character)
	local humanoid = character:WaitForChild("Humanoid")
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
end

localPlayer.CharacterAdded:Connect(setupCharacterClient)
if localPlayer.Character then
	setupCharacterClient(localPlayer.Character)
end

-- Eigenen Prompt ausblenden: Attachment ist bereits vorhanden wenn Event ankommt
local function hideOwnPrompt(root)
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

PlayerDowned.OnClientEvent:Connect(function(userId, isDownNow)
	if userId ~= localPlayer.UserId then return end

	local char = localPlayer.Character
	local h    = char and char:FindFirstChildOfClass("Humanoid")
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not h or not root then return end

	if isDownNow then
		root.Anchored  = true
		h.WalkSpeed    = 0
		h.JumpHeight   = 0
		hideOwnPrompt(root)
	else
		root.Anchored  = false
		h.WalkSpeed    = 16    -- GameManager setzt Klassen-Speed beim nächsten Spawn
		h.JumpHeight   = 7.2
	end
end)
