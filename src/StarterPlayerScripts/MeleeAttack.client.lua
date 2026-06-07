-- Nahkampf: Linksklick auf einen NPC schickt AttackMelee ans Server
-- Server prüft Range + Cooldown; E-Taste ist für Spezialangriff reserviert

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local localPlayer = Players.LocalPlayer
local mouse = localPlayer:GetMouse()

local AttackMelee = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("AttackMelee")

local ATTACK_RANGE = 10
local COOLDOWN     = 0.8
local canAttack    = true

-- Kurzer Slash-Aufblitz am Trefferpunkt
local function playSlashVFX(position)
	local slash = Instance.new("Part")
	slash.Size        = Vector3.new(3, 3, 0.05)
	slash.CFrame      = CFrame.new(position) * CFrame.Angles(0, math.random() * math.pi, math.random() * math.pi)
	slash.Anchored    = true
	slash.CanCollide  = false
	slash.CanQuery    = false
	slash.CanTouch    = false
	slash.Material    = Enum.Material.Neon
	slash.Color       = Color3.fromRGB(220, 220, 255)
	slash.Transparency = 0.3
	slash.Parent      = workspace

	TweenService:Create(slash, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
		Transparency = 1,
		Size = Vector3.new(5, 5, 0.05),
	}):Play()
	Debris:AddItem(slash, 0.3)
end

-- Rechten Arm kurz nach vorne schwingen (R6 Motor6D)
local function swingArm()
	local char = localPlayer.Character
	if not char then return end
	local torso = char:FindFirstChild("Torso")
	if not torso then return end
	local rs = torso:FindFirstChild("Right Shoulder")
	if not rs then return end

	local base = rs.C0
	rs.C0 = base * CFrame.Angles(0, 0, -math.pi * 0.65)
	task.wait(0.12)
	rs.C0 = base * CFrame.Angles(0, 0, math.pi * 0.15)
	task.wait(0.1)
	rs.C0 = base
end

mouse.Button1Down:Connect(function()
	if not canAttack then return end

	local target = mouse.Target
	if not target then return end

	-- Prüfen ob das getroffene Part zu einem NPC-Modell gehört
	local model = target:FindFirstAncestorOfClass("Model")
	if not model then return end
	if not model:FindFirstChildOfClass("Humanoid") then return end
	if model == localPlayer.Character then return end

	-- Grobe Range-Prüfung client-seitig (Server verifiziert nochmal)
	local char = localPlayer.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	local targetRoot = model:FindFirstChild("HumanoidRootPart")
	if not root or not targetRoot then return end
	if (root.Position - targetRoot.Position).Magnitude > ATTACK_RANGE then return end

	canAttack = false
	AttackMelee:FireServer(model)

	-- Visuelle Effekte (nur lokal)
	task.spawn(swingArm)
	playSlashVFX(mouse.Hit.Position)

	task.delay(COOLDOWN, function() canAttack = true end)
end)
