util.AddNetworkString("vipd_hud_init")
util.AddNetworkString("vipd_hud")
util.AddNetworkString("vipd_menu")

function VipdHudInit(netTable)
    net.Start("vipd_hud_init")
    net.WriteTable(netTable)
    net.Broadcast()
end

local function UpdateClientHud(netTable)
    net.Start("vipd_hud")
    net.WriteTable(netTable)
    net.Broadcast()
end

function VipdHudUpdate()
    local enemy_display = CurrentNpcs
    if CurrentNpcs == 0 then
        if #vipd.Nodes > 0 then enemy_display = TotalEnemies - DeadEnemies end
    end
    local vipd_players = { }
    for k, ply in pairs(player.GetAll()) do
        local vply = GetVply(ply:Name())
        local p = { }
        p.points = GetAvailablePoints(ply)
        p.level = GetLevel(ply)
        p.grade = GetGrade(ply)
        p.weapons = vply.weapons
        vipd_players[ply:Name()] = p
    end
    local tagged_enemy_pos = nil
    if TAGGED_ENEMY and IsValid(TAGGED_ENEMY) then
        local feet_pos = TAGGED_ENEMY:GetPos()
        local eye_pos = TAGGED_ENEMY:EyePos()
        local z = math.floor((eye_pos.z - feet_pos.z) / 2) + feet_pos.z
        tagged_enemy_pos = Vector(eye_pos.x, eye_pos.y, z)
    end
    local netTable = {
        ["TotalEnemies"] = TotalEnemies,
        ["DeadEnemies"] = DeadEnemies,
        ["MaxEnemies"] = MaxNpcs,
        ["CurrentEnemies"] = CurrentNpcs,
        ["TotalFriendlys"] = TotalFriendlys,
        ["DeadFriendlys"] = DeadFriendlys,
        ["RescuedFriendlys"] = RescuedFriendlys,
        ["VipName"] = VipName,
        ["ActiveSystem"] = DefenseSystem,
        ["VipdPlayers"] = vipd_players,
        ["VipdWeapons"] = Weapons,
        ["VipdTaggedEnemyPosition"] = tagged_enemy_pos
    }
    UpdateClientHud(netTable)
end