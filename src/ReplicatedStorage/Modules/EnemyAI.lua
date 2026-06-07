-- Gegner-Verhalten und co-op-bewusste KI-Typen

local EnemyAI = {}

EnemyAI.EnemyType = {
	GUARD        = "Guard",       -- Patrouilliert, greift nächsten Spieler an
	ARCHER       = "Archer",      -- Zielt auf isolierte/verwundete Spieler
	ELITE_NINJA  = "EliteNinja",  -- Schneidet Revive-Versuche ab
	SHAMAN       = "Shaman",      -- Beschwört Minions wenn Spieler zu eng beieinander
}

EnemyAI.EnemyStats = {
	Guard = {
		BaseHP = 80, Damage = 15, Speed = 12,
		DetectionRange = 20, AttackRange = 4,
	},
	Archer = {
		BaseHP = 60, Damage = 20, Speed = 10,
		DetectionRange = 40, AttackRange = 35,
		PreferIsolatedTarget = true,
		IsolationThreshold = 15,
	},
	EliteNinja = {
		BaseHP = 120, Damage = 25, Speed = 18,
		DetectionRange = 25, AttackRange = 5,
		InterruptsRevive = true,
	},
	Shaman = {
		BaseHP = 100, Damage = 10, Speed = 8,
		DetectionRange = 30, AttackRange = 6,
		MinionSummonCooldown = 15,
		ClusterThreshold = 10,  -- beschwört Minions wenn Spieler näher als X beieinander
	},
}

EnemyAI.State = {
	PATROL   = "Patrol",
	CHASE    = "Chase",
	ATTACK   = "Attack",
	RETREAT  = "Retreat",
}

-- Wählt das beste Ziel basierend auf Gegnertyp und Spieler-Zustand
function EnemyAI.SelectTarget(enemyType, players)
	if enemyType == EnemyAI.EnemyType.ARCHER then
		-- Bevorzugt isolierte oder verwundete Spieler
		local bestTarget = nil
		local bestScore = -math.huge
		for _, player in ipairs(players) do
			local score = 0
			if player.IsIsolated then score = score + 100 end
			if player.HPPercent < 0.4 then score = score + 50 end
			if score > bestScore then
				bestScore = score
				bestTarget = player
			end
		end
		return bestTarget or players[1]
	elseif enemyType == EnemyAI.EnemyType.ELITE_NINJA then
		-- Zielt auf ausgeknockte Spieler oder den, der grade revived
		for _, player in ipairs(players) do
			if player.IsDown or player.IsReviving then
				return player
			end
		end
	end
	-- Standard: nächster Spieler (nach Entfernung sortiert, Index 1 = nächster)
	return players[1]
end

return EnemyAI
