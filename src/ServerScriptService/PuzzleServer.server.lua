-- Rätsel-Zustände verwalten (Server-autoritativ)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PuzzleSystem = require(ReplicatedStorage.Modules.PuzzleSystem)

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local PuzzleStateChanged = RemoteEvents:WaitForChild("PuzzleStateChanged")

-- Alle aktiven Rätsel dieser Session
-- [puzzleId] = PuzzleState
local activePuzzles = {}

-- Rätsel registrieren (wird beim Zonen-Load aufgerufen)
local function registerPuzzle(puzzleId, puzzleType, requiredPlayers)
	activePuzzles[puzzleId] = PuzzleSystem.NewPuzzleState(puzzleId, puzzleType, requiredPlayers)
	print(("[PuzzleServer] Rätsel registriert: %s (%s, %d Spieler nötig)"):format(
		puzzleId, puzzleType, requiredPlayers
	))
end

-- Spieler betritt eine Rätsel-Zone (via TouchPart oder Proximity Prompt)
local function onPlayerEnterPuzzleZone(player, puzzleId)
	local puzzle = activePuzzles[puzzleId]
	if not puzzle or puzzle.Solved then return end

	PuzzleSystem.PlayerEntered(puzzle, player.UserId)
	print(("[PuzzleServer] %s betritt Rätsel %s (%d/%d Spieler)"):format(
		player.Name, puzzleId, #puzzle.ActivePlayers, puzzle.RequiredPlayers
	))

	-- Prüfen ob Anforderung erfüllt
	if PuzzleSystem.CheckRequirement(puzzle) then
		puzzle.Solved = true
		print(("[PuzzleServer] Rätsel gelöst: %s"):format(puzzleId))
		PuzzleStateChanged:FireAllClients(puzzleId, true)
	else
		PuzzleStateChanged:FireAllClients(puzzleId, false, #puzzle.ActivePlayers, puzzle.RequiredPlayers)
	end
end

-- Spieler verlässt eine Rätsel-Zone
local function onPlayerLeavePuzzleZone(player, puzzleId)
	local puzzle = activePuzzles[puzzleId]
	if not puzzle or puzzle.Solved then return end

	PuzzleSystem.PlayerLeft(puzzle, player.UserId)
	PuzzleStateChanged:FireAllClients(puzzleId, false, #puzzle.ActivePlayers, puzzle.RequiredPlayers)
end

-- Beispiel-Registrierungen für Zone 1 (Ninjato-Garten)
-- Diese werden in der finalen Version durch Zonen-Loader ersetzt
registerPuzzle("Garden_MainGate",    PuzzleSystem.PuzzleType.PRESSURE_PLATES, 2)
registerPuzzle("Garden_TorchBridge", PuzzleSystem.PuzzleType.TORCH_IGNITE,    2)

return {
	RegisterPuzzle         = registerPuzzle,
	OnPlayerEnterPuzzleZone = onPlayerEnterPuzzleZone,
	OnPlayerLeavePuzzleZone = onPlayerLeavePuzzleZone,
}
