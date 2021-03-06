function Teleport(ply, cmd, arguments)
    if PvpEnabled then Notify(ply, "No teleporting when PVP is enabled!") return end
    if not arguments or not arguments [1] then
        Notify(ply, "Invalid arguments!")
    else
        local plyTo = VipdGetPlayer(arguments[1])
        local vply = GetVply(ply:Name())
        if not plyTo then
            if arguments[1] == "TAGGED" and ply:IsAdmin() and TaggedEnemy then
                ply:SetPos(TaggedEnemy:GetPos())
            else
                vWARN("Unable to find player: "..arguments[1])
            end
        elseif vply.TeleportCooldown then
            Notify(ply, "You have to wait to teleport again!")
        else
            vply.TeleportCooldown = true
            timer.Simple(TELEPORT_COOLDOWN, function() if(IsValid(ply) ) then vply.TeleportCooldown = false end end )
            vINFO("Teleporting " .. ply:Name() .. " to " .. plyTo:Name())
            ply:SetPos(plyTo:GetPos())
        end
    end
end

function MapNodes()
    local numNodes = 0
    vipd_nodegraph = GetVipdNodegraph()
    if vipd_nodegraph and vipd_nodegraph.nodes then
        numNodes = #vipd_nodegraph.nodes
    end
    vINFO(game.GetMap().." has "..numNodes.." nodes.")
end

function FreezePlayers( admin )
    if IsValid(admin) and admin:IsAdmin() then
        if Frozen then Frozen = false else Frozen = true end
        for k, ply in pairs(player.GetAll() ) do
            if not ply:IsAdmin() then
                ply:Freeze(Frozen)
                local frozen_msg = " froze you!"
                if not Frozen then frozen_msg = " unfroze you!" end
                MsgCenter(admin:Name()..frozen_msg)
            end
        end
    end
end

local function GetNPCSchedule( npc )
    for s = 0, LAST_SHARED_SCHEDULE-1 do
        if( npc:IsCurrentSchedule( s ) ) then return s end
    end
    return 0
end

local function LogNPCStatus(npc)
    local name = npc:GetClass()
    vDEBUG(name.." at "..tostring(npc:GetPos()))
    vDEBUG(name.." state: "..npc:GetNPCState())
    vDEBUG(name.." schedule: "..GetNPCSchedule(npc))
    for c = 0, 100 do
        if( npc:HasCondition( c ) ) then
            vDEBUG(name.." has "..npc:ConditionName( c ).." = "..c )
        end
    end
    local caps = npc:CapabilitiesGet()
    if IsBitSet(caps, CAP_AUTO_DOORS) then vDEBUG(name.." can open auto doors") end
    if IsBitSet(caps, CAP_OPEN_DOORS) then vDEBUG(name.." can open manual doors") end
    if IsBitSet(caps, CAP_MOVE_GROUND ) then vDEBUG(name.." can move on the ground") end
    if IsBitSet(caps, CAP_MOVE_FLY ) then vDEBUG(name.." can fly") end
    if IsBitSet(caps, CAP_SQUAD ) then vDEBUG(name.." can form squads") end
    if IsBitSet(caps, CAP_FRIENDLY_DMG_IMMUNE ) then vDEBUG(name.." has friendly fire disabled") end
end

function GetEnemies()
    local enemies = { }
    for key, ent in pairs(ents.GetAll()) do
        if IsEnemy(ent.team) then table.insert(enemies, ent) end
    end
    return enemies
end

function PrintMaterialAbove()
    for key, npc in pairs(GetEnemies()) do
        local vStart = npc:GetPos()
        local trace = { }
        trace.start = vStart
        trace.endpos = vStart + Vector(0,0,MAX_DISTANCE)
        trace.filter = npc
        local tr = util.TraceLine(trace)
        if tr.Hit then
            vDEBUG("Trace hit texture: "..tr.HitTexture.." world: "..tostring(tr.HitWorld).. " entity: "..tr.Entity:GetClass())
            --Trace back down
            local traceBack = { }
            traceBack.start = tr.HitPos
            traceBack.endpos = npc:EyePos()
            traceBack.filter = { }
            table.insert(traceBack.filter, tr.Entity) -- Ignore the entity we hit on the way up
            table.insert(traceBack.filter, npc) -- Ignore the npc itself
            tr = util.TraceLine(traceBack)
            if tr.Hit then
                vDEBUG("REVERSE - Trace hit texture: "..tr.HitTexture.." world: "..tostring(tr.HitWorld).. " entity: "..tr.Entity:GetClass())
                vDEBUG("End: " .. tostring(traceBack.endpos).." Hit: "..tostring(tr.HitPos))
            else
                vDEBUG("REVERSE - Trace hit nothing!")
            end
        else
            vDEBUG("Trace hit nothing!")
        end
    end
end

function FindDoors()
    for key, ent in pairs(ents.GetAll()) do
        local model = ent:GetModel()
        local model_string = tostring(model)
        if model and string.match(model_string, "door") then
            local is_solid = ent:IsSolid()
            local has_physics = IsValid(ent:GetPhysicsObject())
            vINFO("Found door at " .. tostring(ent:GetPos()) .. " with solid " .. tostring(is_solid) .. " and physics " .. tostring(has_physics))
            if has_physics then vINFO("Physics name: " .. ent:GetPhysicsObject():GetName()) end
            local flare = ents.Create("env_flare")
            flare:SetPos(ent:GetPos())
            flare:Spawn()
            flare:Activate()
        end
    end
end

function PrintImages()
    for key, vipd_weapon in pairs(vipd_weapons) do

    end
    local material = "materials/VGUI/entities/*.*"
    local files, directories = file.Find( material, "GAME" )
    PrintTable(files)
    PrintTable(directories)
    vINFO(material .. " Files: " .. #files .. " Dirs: " .. #directories)
    if file.Exists( "materials/VGUI/entities/weapon_pistol.vtf", "GAME" ) then
        vINFO("The pistol png exists!")
    end
    if file.Exists( "entities", "GAME" ) then
        vINFO("The entities directory exists!")
    end
    if file.Exists("sound/vo/sick.mp3", "GAME") then
        vINFO("Sound files exist")
    end
end

--=======--
--Archive--
--=======--

local function GivePlayerAmmo(ply, level, grade)
    local playerWeapons = { }
    for k, weapon in pairs(ply:GetWeapons()) do
        local class = weapon:GetClass()
        local tier = vipd_weapons[class].tier
        if not playerWeapons[tier] then
            playerWeapons[tier] = { }
        end
        table.insert(playerWeapons[tier], weapon)
    end
    for k, weapon in pairs(playerWeapons) do
    -- 1 clip of highest tier weapon
    end
end
