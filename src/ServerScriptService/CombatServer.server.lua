-- Autoritativer Kampf-Server: Schadensberechnung, Down-State, Combo-Finisher

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WeaponSystem = require(ReplicatedStorage.Modules.WeaponSystem)

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local PlayerAttack = RemoteEvents:WaitForChild("PlayerAttack")
local PlayerDowned = RemoteEvents:WaitForChild("PlayerDowned")

-- Speichert den letzten Treffer pro Gegner für Combo-Finisher-Erkennung
-- [enemyId] = { userId, timestamp }
local lastHits = {}

local DOWN_DURATION = 30  -- Sekunden bis Spieler stirbt wenn nicht revived

-- Verarbeitet einen Angriff vom Client
local function onPlayerAttack(player, targetId, attackType)
	-- Sicherheitscheck: Spieler darf nur im aktiven Spielzustand angreifen
	if not player.Character then return end

	local weapon = player.Character:FindFirstChild("EquippedWeapon")
	if not weapon then return end

	local weaponName = weapon.Value
	local stats = WeaponSystem.GetWeaponStats(weaponName)
	if not stats then return end

	local damage = attackType == "Heavy" and stats.HeavyDamage or stats.LightDamage

	-- Combo-Finisher prüfen
	local now = tick()
	local last = lastHits[targetId]
	if last and last.UserId ~= player.UserId and WeaponSystem.IsComboWindow(last.Timestamp, now) then
		damage = damage * WeaponSystem.ComboFinisher.DamageMultiplier
		print(("[CombatServer] COMBO FINISHER! %s + %s → %d Schaden"):format(
			Players:GetPlayerByUserId(last.UserId).Name, player.Name, damage
		))
		lastHits[targetId] = nil
	else
		lastHits[targetId] = { UserId = player.UserId, Timestamp = now }
	end

	-- Schaden auf Ziel anwenden
	local target = game.Workspace:FindFirstChild(tostring(targetId))
	if target then
		local humanoid = target:FindFirstChildOfClass("Humanoid")
		if humanoid and humanoid.Health > 0 then
			humanoid:TakeDamage(damage)
		end
	end
end

-- Spieler wird ausgeknockt (kein sofortiger Tod)
local function onPlayerDown(player)
	print(("[CombatServer] %s ist ausgeknockt!"):format(player.Name))
	PlayerDowned:FireAllClients(player.UserId)

	-- Down-Timer: nach DOWN_DURATION stirbt der Spieler wenn nicht revived
	task.delay(DOWN_DURATION, function()
		if player and player.Character then
			local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
			if humanoid and humanoid.Health <= 0 then
				-- Spieler wurde nicht revived — Game Over Check
				print(("[CombatServer] %s wurde nicht rechtzeitig revived"):format(player.Name))
			end
		end
	end)
end

PlayerAttack.OnServerEvent:Connect(onPlayerAttack)
