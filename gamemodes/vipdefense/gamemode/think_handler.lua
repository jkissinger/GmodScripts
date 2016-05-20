local HudCounter = 0
local HudUpdate = 10

local function VipdThink()
    HudCounter = HudCounter + 1
    if HudCounter % HudUpdate == 0 then VipdHudUpdate() end
    if LevelSystem then LevelSystemThink() end
    if DefenseSystem then SpawnSystemThink() end
end

hook.Add("Think", "Vipd think", VipdThink)