-- Nahkampf: Linksklick auf einen NPC schickt AttackMelee ans Server
-- Server prüft Range + Cooldown; E-Taste ist für Spezialangriff reserviert

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local localPlayer = Players.LocalPlayer
local mouse = localPlayer:GetMouse()

local AttackMelee = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("AttackMelee")

-- Toolbox → Animations → Free → "R15 punch" / "ninja attack" → ID hier eintragen
local PUNCH_ANIM_ID = "rbxassetid://PUNCH_ID_HIER"

local ATTACK_RANGE = 10
local COOLDOWN     = 0.8
local canAttack    = true

-- Animation einmalig laden und cachen
local punchTrack
local function getPunchTrack()
	if punchTrack then return punchTrack end
	local char = localPlayer.Character
	if not char then return end
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
	if not animator then return end
	if PUNCH_ANIM_ID == "rbxassetid://PUNCH_ID_HIER" then return end  -- Platzhalter

	local anim = Instance.new("Animation")
	anim.AnimationId = PUNCH_ANIM_ID
	punchTrack = animator:LoadAnimation(anim)
	punchTrack.Priority = Enum.AnimationPriority.Action
	return punchTrack
end

-- Track bei neuem Character zurücksetzen
localPlayer.CharacterAdded:Connect(function()
	punchTrack = nil
end)

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
	playSlashVFX(mouse.Hit.Position)

	local track = getPunchTrack()
	if track then track:Play() end

	task.delay(COOLDOWN, function() canAttack = true end)
end)
