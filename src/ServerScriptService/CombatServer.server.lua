-- Server-autoritativer Nahkampf: Range + Cooldown Validierung
-- Schaden nur auf NPCs (keine Spieler-gegen-Spieler Schäden)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AttackMelee = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("AttackMelee")

local ATTACK_DAMAGE = 25
local ATTACK_RANGE  = 12   -- etwas großzügiger als Client wegen Netzwerklatenz
local COOLDOWN      = 0.8

local cooldowns = {}

AttackMelee.OnServerEvent:Connect(function(player, targetModel)
	-- Cooldown
	local now = tick()
	if cooldowns[player.UserId] and now - cooldowns[player.UserId] < COOLDOWN then return end
	cooldowns[player.UserId] = now

	-- Ziel validieren
	if not targetModel or not targetModel.Parent then return end
	local humanoid = targetModel:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return end

	-- Nur NPCs angreifbar, keine Spieler
	if Players:GetPlayerFromCharacter(targetModel) then return end

	-- Range-Prüfung server-seitig
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	local targetRoot = targetModel:FindFirstChild("HumanoidRootPart")
	if not root or not targetRoot then return end
	if (root.Position - targetRoot.Position).Magnitude > ATTACK_RANGE then return end

	humanoid:TakeDamage(ATTACK_DAMAGE)
	print(("[Combat] %s trifft %s (-%d HP)"):format(player.Name, targetModel.Name, ATTACK_DAMAGE))
end)

Players.PlayerRemoving:Connect(function(player)
	cooldowns[player.UserId] = nil
end)
