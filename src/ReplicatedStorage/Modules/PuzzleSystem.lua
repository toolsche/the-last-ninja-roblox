-- Rätsel-Zustände und Typen für alle Co-op-Rätsel

local PuzzleSystem = {}

-- Rätseltypen
PuzzleSystem.PuzzleType = {
	PRESSURE_PLATES = "PressurePlates",   -- Simultane Druckplatten
	TORCH_IGNITE    = "TorchIgnite",      -- Fernzünd-Rätsel (Kassha)
	BOOST_JUMP      = "BoostJump",        -- Kenshi boosted Kaze
	DISTRACTION     = "Distraction",      -- Ablenkungsmanöver
	CHAIN           = "Chain",            -- Kettenrätsel A→B→alle
}

-- Erstellt einen neuen Rätsel-State
function PuzzleSystem.NewPuzzleState(puzzleId, puzzleType, requiredPlayers)
	return {
		Id             = puzzleId,
		Type           = puzzleType,
		RequiredPlayers = requiredPlayers or 2,
		ActivePlayers  = {},   -- UserIds der aktuell beteiligten Spieler
		Solved         = false,
		Progress       = 0,    -- 0–1 für fortlaufende Rätsel
	}
end

-- Gibt zurück ob genügend Spieler aktiv sind
function PuzzleSystem.CheckRequirement(puzzleState)
	return #puzzleState.ActivePlayers >= puzzleState.RequiredPlayers
end

-- Spieler betritt einen Rätselbereich
function PuzzleSystem.PlayerEntered(puzzleState, userId)
	if not table.find(puzzleState.ActivePlayers, userId) then
		table.insert(puzzleState.ActivePlayers, userId)
	end
end

-- Spieler verlässt einen Rätselbereich
function PuzzleSystem.PlayerLeft(puzzleState, userId)
	local index = table.find(puzzleState.ActivePlayers, userId)
	if index then
		table.remove(puzzleState.ActivePlayers, index)
	end
end

return PuzzleSystem
