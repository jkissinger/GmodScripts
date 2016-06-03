function InitSystemGlobals()
    vipd = { }
    vipd.Players = { }
    vipd.Nodes = { }
    --These have to be global cause they're used by the HUD, even if the defense system is inactive
    CurrentNpcs = 0
    TotalFriendlys = 0
    TotalEnemies = 0
    DeadFriendlys = 0
    RescuedFriendlys = 0
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
    end
end

function InitDefenseSystem( ply )
    if DefenseSystem then return end
    if IsValid(ply) then
        ResetMap()
        GetNodes()
        if #vipd.Nodes < 50 then
            DefenseSystem = false
            BroadcastError("Can't init invasion because "..game.GetMap().." has less than 50 AI nodes!")
        else
            TotalEnemies = #vipd.Nodes
            MsgCenter("Initializing invasion.")
            InitializeNodes()
        end
    end
end

function StopDefenseSystem()
    MsgCenter("Shutting down invasion.")
    DefenseSystem = false
    ResetMap()
end