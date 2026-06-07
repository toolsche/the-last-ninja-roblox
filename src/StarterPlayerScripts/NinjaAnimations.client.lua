-- Ninja-Animationen: ersetzt die Standard-Roblox-Animationen
-- IDs aus der Toolbox (Animations → Free → "ninja") hier eintragen

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

-- Animation-IDs hier anpassen
-- Toolbox → Animations → Free → gewünschte Animation suchen → ID kopieren
local ANIM_IDS = {
	idle  = "rbxassetid://IDLE_ID_HIER",    -- Ninja-Idle (stehend)
	walk  = "rbxassetid://WALK_ID_HIER",    -- Ninja-Walk
	run   = "rbxassetid://RUN_ID_HIER",     -- Ninja-Run
	jump  = "rbxassetid://JUMP_ID_HIER",    -- Ninja-Jump (optional)
}

local function applyNinjaAnimations(character)
	-- Das Animate-Script im Character enthält alle Standard-Animations-IDs
	local animate = character:WaitForChild("Animate", 5)
	if not animate then return end

	-- Idle ersetzen
	if ANIM_IDS.idle ~= "rbxassetid://IDLE_ID_HIER" then
		local idleAnim = animate:FindFirstChild("idle")
		if idleAnim then
			local a1 = idleAnim:FindFirstChild("Animation1")
			if a1 then a1.AnimationId = ANIM_IDS.idle end
		end
	end

	-- Walk ersetzen
	if ANIM_IDS.walk ~= "rbxassetid://WALK_ID_HIER" then
		local walkAnim = animate:FindFirstChild("walk")
		if walkAnim then
			local a1 = walkAnim:FindFirstChild("Animation1")
			if a1 then a1.AnimationId = ANIM_IDS.walk end
		end
	end

	-- Run ersetzen
	if ANIM_IDS.run ~= "rbxassetid://RUN_ID_HIER" then
		local runAnim = animate:FindFirstChild("run")
		if runAnim then
			local a1 = runAnim:FindFirstChild("Animation1")
			if a1 then a1.AnimationId = ANIM_IDS.run end
		end
	end

	-- Jump ersetzen
	if ANIM_IDS.jump ~= "rbxassetid://JUMP_ID_HIER" then
		local jumpAnim = animate:FindFirstChild("jump")
		if jumpAnim then
			local a1 = jumpAnim:FindFirstChild("Animation1")
			if a1 then a1.AnimationId = ANIM_IDS.jump end
		end
	end
end

localPlayer.CharacterAdded:Connect(applyNinjaAnimations)
if localPlayer.Character then
	applyNinjaAnimations(localPlayer.Character)
end
