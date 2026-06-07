-- Down-State Client: Bewegung, PlatformStand-Visual und Sound

local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local localPlayer = Players.LocalPlayer
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local PlayerDowned = RemoteEvents:WaitForChild("PlayerDowned")

-- Tod-Animation client-seitig deaktivieren bei jedem neuen Character
local function setupCharacterClient(character)
	local humanoid = character:WaitForChild("Humanoid")
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
end

localPlayer.CharacterAdded:Connect(setupCharacterClient)
if localPlayer.Character then
	setupCharacterClient(localPlayer.Character)
end

-- Eigenen Prompt ausblenden
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

-- Sound am ausgeknockte Spieler abspielen (hörbar für alle in der Nähe)
local function playDownSound(character)
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end
	local sound = Instance.new("Sound")
	-- Sound-ID: Toolbox → Audio → "hurt" suchen → Free → ID aus Properties kopieren
	sound.SoundId            = "rbxassetid://HIER_ID_EINFUEGEN"
	sound.Volume             = 1
	sound.RollOffMaxDistance = 40
	sound.Parent             = root
	sound:Play()
	Debris:AddItem(sound, 3)
end

PlayerDowned.OnClientEvent:Connect(function(userId, isDownNow)

	-- Sound für alle Clients (egal wer down geht)
	local target = Players:GetPlayerByUserId(userId)
	if target and target.Character and isDownNow then
		playDownSound(target.Character)
	end

	-- Bewegung + Visual nur für den eigenen Spieler
	if userId ~= localPlayer.UserId then return end

	local char = localPlayer.Character
	local h    = char and char:FindFirstChildOfClass("Humanoid")
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not h or not root then return end

	if isDownNow then
		h.WalkSpeed     = 0
		h.JumpHeight    = 0
		h.PlatformStand = true   -- legt Charakter flach, stoppt Lauf-Animation
		hideOwnPrompt(root)
	else
		h.PlatformStand = false  -- Charakter steht auf
		h.WalkSpeed     = 16
		h.JumpHeight    = 7.2
		root.Anchored   = false  -- Sicherheitsnetz
	end
end)
