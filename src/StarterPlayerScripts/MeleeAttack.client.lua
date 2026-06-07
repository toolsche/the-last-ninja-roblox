-- Nahkampf: Linksklick auf einen NPC schickt AttackMelee ans Server
-- Server prüft Range + Cooldown; E-Taste ist für Spezialangriff reserviert

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local localPlayer = Players.LocalPlayer
local mouse = localPlayer:GetMouse()

local AttackMelee = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("AttackMelee")

local ATTACK_RANGE = 10
local COOLDOWN     = 0.8
local canAttack    = true

-- Neon-Aufblitz am Trefferpunkt
local function playSlashVFX(position)
	local part = Instance.new("Part")
	part.Shape        = Enum.PartType.Ball
	part.Size         = Vector3.new(3, 3, 3)
	part.Position     = position
	part.Anchored     = true
	part.CanCollide   = false
	part.Material     = Enum.Material.Neon
	part.Color        = Color3.fromRGB(255, 120, 0)
	part.Transparency = 0
	part.Parent       = workspace

	TweenService:Create(part, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Transparency = 1,
		Size = Vector3.new(6, 6, 6),
	}):Play()
	Debris:AddItem(part, 0.35)
end

-- Arm-Schwung via Motor6D.Transform (Heartbeat überschreibt Animate-Script)
local function swingArm()
	local char = localPlayer.Character
	if not char then return end

	-- R6: Right Shoulder im Torso
	local rs
	local torso = char:FindFirstChild("Torso")
	if torso then rs = torso:FindFirstChild("Right Shoulder") end

	-- R15: RightShoulder im RightUpperArm
	if not rs then
		local rua = char:FindFirstChild("RightUpperArm")
		if rua then rs = rua:FindFirstChild("RightShoulder") end
	end

	if not rs then return end

	local elapsed = 0
	local duration = 0.25
	local conn
	conn = RunService.Heartbeat:Connect(function(dt)
		elapsed = elapsed + dt
		local t = math.min(elapsed / duration, 1)

		-- Vorwärts-Schwung in erster Hälfte, zurück in zweiter
		local angle
		if t < 0.5 then
			angle = -math.pi * 0.65 * (t * 2)
		else
			angle = -math.pi * 0.65 * (1 - (t - 0.5) * 2)
		end

		rs.Transform = CFrame.Angles(0, 0, angle)

		if elapsed >= duration then
			rs.Transform = CFrame.new()
			conn:Disconnect()
		end
	end)
end

mouse.Button1Down:Connect(function()
	if not canAttack then return end

	local target = mouse.Target
	if not target then return end

	local model = target:FindFirstAncestorOfClass("Model")
	if not model then return end
	if not model:FindFirstChildOfClass("Humanoid") then return end
	if model == localPlayer.Character then return end

	local char = localPlayer.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	local targetRoot = model:FindFirstChild("HumanoidRootPart")
	if not root or not targetRoot then return end
	if (root.Position - targetRoot.Position).Magnitude > ATTACK_RANGE then return end

	canAttack = false
	AttackMelee:FireServer(model)
	task.spawn(swingArm)
	playSlashVFX(mouse.Hit.Position)

	task.delay(COOLDOWN, function() canAttack = true end)
end)
