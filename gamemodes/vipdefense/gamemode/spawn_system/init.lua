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

    --TODO: add hook to trigger this when the convar pointsperlevel changes
    LevelTable = { }
    for i=1, MaxLevel, 1 do
        local base = GetLevelInterval() * i
        local modifier = GetLevelInterval() * 0.2
        local levelBase = i * i * modifier
        local points = math.floor(base + levelBase)
        table.insert(LevelTable, points)
    end
end