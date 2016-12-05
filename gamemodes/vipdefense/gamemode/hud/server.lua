util.AddNetworkString("vipd_hud_init")
util.AddNetworkString("vipd_hud")
util.AddNetworkString("vipd_menu")

function VipdUpdateClientStore()
    net.Start("vipd_hud_init")
    net.WriteTable(vipd_weapons)
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
    if TaggedEnemy and IsValid(TaggedEnemy) then
        local feet_pos = TaggedEnemy:GetPos()
        local eye_pos = TaggedEnemy:EyePos()
        local z = math.floor((eye_pos.z - feet_pos.z) / 2) + feet_pos.z
        tagged_enemy_pos = Vector(eye_pos.x, eye_pos.y, z)
    end
    local tagged_ally_pos = nil
    if TaggedAlly and IsValid(TaggedAlly) then
        local feet_pos = TaggedAlly:GetPos()
        local eye_pos = TaggedAlly:EyePos()
        local z = math.floor((eye_pos.z - feet_pos.z) / 2) + feet_pos.z
        tagged_ally_pos = Vector(eye_pos.x, eye_pos.y, z)
    end
    local netTable = {
        ["TotalEnemies"] = TotalEnemies,
        ["DeadEnemies"] = DeadEnemies,
        ["MaxEnemies"] = MAX_NPCS,
        ["CurrentEnemies"] = CurrentNpcs,
        ["AliveAllies"] = AliveAllies,
        ["DeadAllies"] = DeadAllies,
        ["RescuedAllies"] = RescuedAllies,
        ["VipName"] = VipName,
        ["ActiveSystem"] = DefenseSystem,
        ["VipdPlayers"] = vipd_players,
        ["VipdTaggedEnemyPosition"] = tagged_enemy_pos,
        ["VipdTaggedAllyPosition"] = tagged_ally_pos
    }
    UpdateClientHud(netTable)
end
