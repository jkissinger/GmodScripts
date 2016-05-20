local LevelSystemCounter = 0
local LevelSystemInterval = 25
local SavePosInterval = 75

local function SavePos()
    for k, ply in pairs(player.GetAll()) do
        local vply = GetVply(ply:Name())
        vply.PreviousPos2 = vply.PreviousPos1
        vply.PreviousPos1 = ply:GetPos()
    end
end

local function DoThink()
    if LevelSystemCounter % SavePosInterval == 0 then SavePos() end
end

function LevelSystemThink()
    LevelSystemCounter = LevelSystemCounter + 1
    if LevelSystemCounter % LevelSystemInterval then DoThink() end
end
