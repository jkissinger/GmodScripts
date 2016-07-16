function InitSystemGlobals()
    vipd = { }
    vipd.Players = { }
    vipd.Nodes = { }
    --These have to be global cause they're used by the HUD, even if the defense system is inactive
    CurrentNpcs = 0
    AliveAllies = 0
    TotalEnemies = 0
    DeadAllies = 0
    RescuedAllies = 0
    DeadEnemies = 0

    --TODO: Get rid of levels and grades?
    LevelTable = { }
    for i=1, MaxLevel, 1 do
        local base = GetLevelInterval() * i
        local modifier = GetLevelInterval() * 0.2
        local levelBase = i * i * modifier
        local points = math.floor(base + levelBase)
        table.insert(LevelTable, points)
    end
end

--==============--
--Initialization--
--==============--

local function ResetMap()
    InitSystemGlobals()
    NextNodes = { }
    UsedNodes = { }
    game.CleanUpMap(false, {} )
    for k, ply in pairs(player.GetAll()) do
        ResetVply(ply:Name())
        ply:SetHealth(100)
        ply:SetArmor(0)
        VipdLoadout(ply)
        AddPoints(ply, INITIAL_POINTS)
    end
end

function InitDefenseSystem( ply )
    if DefenseSystem then return end
    if not ValidConfig then
        vWARN("Fix the config before attempting to start the invasion!")
        return
    end
    if IsValid(ply) then
        ResetMap()
        GetNodes()
        if #vipd.Nodes < 50 then
            DefenseSystem = false
            BroadcastError("Can't init invasion because "..game.GetMap().." has less than 50 AI nodes! (" .. #vipd.Nodes .. ")")
        else
            MsgCenter("Initializing invasion.")
            InitializeNodes()
        end
    end
end

function StopDefenseSystem()
    vINFO("Shutting down invasion.")
    DefenseSystem = false
    ResetMap()
end
