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
    local tagged_friendly_pos = nil
    if TAGGED_FRIENDLY and IsValid(TAGGED_FRIENDLY) then
        local feet_pos = TAGGED_FRIENDLY:GetPos()
        local eye_pos = TAGGED_FRIENDLY:EyePos()
        local z = math.floor((eye_pos.z - feet_pos.z) / 2) + feet_pos.z
        tagged_friendly_pos = Vector(eye_pos.x, eye_pos.y, z)
    end
    local netTable = {
        ["TotalEnemies"] = TotalEnemies,
        ["DeadEnemies"] = DeadEnemies,
        ["MaxEnemies"] = MAX_NPCS,
        ["CurrentEnemies"] = CurrentNpcs,
        ["TotalFriendlys"] = TotalFriendlys,
        ["DeadFriendlys"] = DeadFriendlys,
        ["RescuedFriendlys"] = RescuedFriendlys,
        ["VipName"] = VipName,
        ["ActiveSystem"] = DefenseSystem,
        ["VipdPlayers"] = vipd_players,
        ["VipdWeapons"] = Weapons,
        ["VipdTaggedEnemyPosition"] = tagged_enemy_pos,
        ["VipdTaggedFriendlyPosition"] = tagged_friendly_pos
    }
    UpdateClientHud(netTable)
end
