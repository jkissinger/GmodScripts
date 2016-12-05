local function InitSystemGlobals()
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

local function ValidateConfig()
    local ground_inside = false
    local ground_outside = false
    local flying_inside = false
    local flying_outside = false

    for key, vipd_team in pairs(vipd_enemy_teams) do
        if not vipd_team.disabled then
            for keytwo, vipd_npc in pairs(GetNpcListByTeam(vipd_team)) do
                if vipd_npc.value <= MIN_NPC_VALUE then
                    if not vipd_npc.flying and vipd_team.inside then ground_inside = true end
                    if not vipd_npc.flying and vipd_team.outside then ground_outside = true end
                    if vipd_npc.flying and vipd_team.inside then flying_inside = true end
                    if vipd_npc.flying and vipd_team.outside then flying_outside = true end
                end
            end
        end
    end
    local msg = "No enemy with a value less than or equal to the minimum (" .. MIN_NPC_VALUE .. ") is configured "
    if not ground_inside then vWARN(msg .. " for a ground node inside!") end
    if not ground_outside then vWARN(msg .. " for a ground node outside!") end
    if not flying_inside then vWARN(msg .. " for a flying node inside!") end
    if not flying_outside then vWARN(msg .. " for a flying node outside!") end

    return ground_inside and ground_outside-- and flying_inside and flying_outside
end

function InitializeSpawnSystem()
    vINFO("Initializing Spawn System")
    InitSystemGlobals()
end

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

function StartDefenseSystem( ply )
    if DefenseSystem then return end
    if not ValidateConfig() then
        vWARN("Fix the config before attempting to start the invasion!")
        return
    end
    if IsValid(ply) then
        ResetMap()
        GetNodes()
        if #vipd.Nodes < 50 then
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
