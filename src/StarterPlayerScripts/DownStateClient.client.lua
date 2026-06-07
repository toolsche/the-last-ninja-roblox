-- Down-State Client: Bewegung, visuelle Zustände und Sound des EIGENEN Spielers

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local localPlayer = Players.LocalPlayer
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local PlayerDowned = RemoteEvents:WaitForChild("PlayerDowned")

-- Dead-State client-seitig deaktivieren damit keine Tod-Animation abgespielt wird
local function setupCharacterClient(character)
	local humanoid = character:WaitForChild("Humanoid")
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
end

localPlayer.CharacterAdded:Connect(setupCharacterClient)
if localPlayer.Character then
	setupCharacterClient(localPlayer.Character)
end

-- Eigenen Prompt ausblenden (Attachment ist schon vorhanden wenn Event ankommt)
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
		h.WalkSpeed     = 0
		h.JumpHeight    = 0
		h.PlatformStand = true    -- Charakter legt sich hin, Lauf-Animation stoppt

		-- Treffsound
		local sound = Instance.new("Sound")
		sound.SoundId  = "rbxassetid://131070686"   -- klassischer Roblox-Hurt-Sound
		sound.Volume   = 1
		sound.Parent   = root
		sound:Play()
		game:GetService("Debris"):AddItem(sound, 3)

		hideOwnPrompt(root)
	else
		h.PlatformStand = false   -- Charakter steht auf
		h.WalkSpeed     = 16      -- GameManager setzt Klassen-Speed beim nächsten Spawn
		h.JumpHeight    = 7.2
		root.Anchored   = false   -- Sicherheitsnetz falls Server-Anchor noch aktiv
	end
end)
