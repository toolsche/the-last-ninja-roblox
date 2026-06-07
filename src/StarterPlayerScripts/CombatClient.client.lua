-- Kampf-Eingaben erfassen und via RemoteEvents an Server senden

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local localPlayer = Players.LocalPlayer

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local PlayerAttack = RemoteEvents:WaitForChild("PlayerAttack")
local UseSpecial = RemoteEvents:WaitForChild("UseSpecial")
local RevivePlayer = RemoteEvents:WaitForChild("RevivePlayer")

local SPECIAL_COOLDOWN = 30
local lastSpecialTime = -SPECIAL_COOLDOWN

-- Nächstes Ziel per Raycast bestimmen
local function getTargetInFront(range)
	local character = localPlayer.Character
	if not character then return nil end
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return nil end

	local origin = root.Position
	local direction = root.CFrame.LookVector * range

	local rayParams = RaycastParams.new()
	rayParams.FilterDescendantsInstances = { character }
	rayParams.FilterType = Enum.RaycastFilterType.Exclude

	local result = workspace:Raycast(origin, direction, rayParams)
	if result and result.Instance then
		local model = result.Instance:FindFirstAncestorOfClass("Model")
		if model and model:FindFirstChildOfClass("Humanoid") then
			return model
		end
	end
	return nil
end

-- Linke Maustaste → leichter Angriff
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		local target = getTargetInFront(6)
		if target then
			PlayerAttack:FireServer(target.Name, "Light")
		end

	elseif input.KeyCode == Enum.KeyCode.E then
		local target = getTargetInFront(6)
		if target then
			PlayerAttack:FireServer(target.Name, "Heavy")
		end

	elseif input.KeyCode == Enum.KeyCode.F then
		local now = tick()
		if now - lastSpecialTime >= SPECIAL_COOLDOWN then
			lastSpecialTime = now
			UseSpecial:FireServer()
		end

	elseif input.KeyCode == Enum.KeyCode.R then
		-- Revive: sucht ausgeknockte Teamkollegen in der Nähe
		local character = localPlayer.Character
		if not character then return end
		local root = character:FindFirstChild("HumanoidRootPart")
		if not root then return end

		local REVIVE_RANGE = 5
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= localPlayer and player.Character then
				local otherRoot = player.Character:FindFirstChild("HumanoidRootPart")
				if otherRoot then
					local dist = (root.Position - otherRoot.Position).Magnitude
					if dist <= REVIVE_RANGE then
						RevivePlayer:FireServer(player.UserId)
						break
					end
				end
			end
		end
	end
end)
