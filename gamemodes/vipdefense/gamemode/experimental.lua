function Teleport(ply, cmd, arguments)
    if not arguments or not arguments [1] then
        Notify(ply, "Invalid arguments!")
    else
        local plyTo = VipdGetPlayer(arguments[1])
        local vply = GetVply(ply:Name())
        if not plyTo then
            vWARN("Unable to find player: "..arguments[2])
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

function PrintNpcs()
    PrintTable(list.Get("NPC"))
end

function PrintWeapons()
    for key, weapon in pairs(weapons.GetList()) do
        vDEBUG("Class: "..weapon.ClassName)
        if weapon.Primary then
            vDEBUG("  Primary Ammo: "..tostring(weapon.Primary.Ammo).." ClipSize: "..tostring(weapon.Primary.ClipSize))
        end
        if weapon.Secondary then
            vDEBUG("  Secondary Ammo: "..tostring(weapon.Secondary.Ammo).." ClipSize: "..tostring(weapon.Secondary.ClipSize))
        end
        if weapon.ViewModel then
            vDEBUG("  View Model: "..tostring(weapon.ViewModel))
        end
        if weapon.WorldModel then
            vDEBUG("  World Model: "..tostring(weapon.WorldModel))
        end
    end
    PrintTable(weapons.Get("weapon_fists"))
end

function PrintWeapons2()
    for key, weapon in pairs(list.Get("Weapon")) do
        local vipd_wep = vipd_weapons[key]
        if(weapon.Spawnable and vipd_wep == nil) then
            vDEBUG("Spawnable weapon not in vipd_weapons: " .. key)
        end
    end
    for class, weapon in pairs(vipd_weapons) do
        local swep = weapons.Get( class )
        if swep == nil then
            vDEBUG(class.." not found in weapons.Get")
            swep = list.Get("Weapon")[class]
        end
        if swep == nil then
            vDEBUG(class.." not found in either weapons list")
            swep = list.Get("SpawnableEntities")[name]
        end
        if swep == nil then
            vDEBUG("Could not find "..class.." in gmod's list.")
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

function FreezePlayers( ply )
    if IsValid(ply) and ply:IsAdmin() then
        if Frozen then Frozen = false else Frozen = true end
        for k, ply in pairs(player.GetAll() ) do
            ply:Freeze(Frozen)
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

function DebugAI()
    for key, npc in pairs(GetVipdNpcs()) do LogNPCStatus(npc) end
end

function PrintMaterialAbove()
    for key, npc in pairs(GetEnemies()) do
        local vStart = npc:GetPos()
        local trace = { }
        trace.start = vStart
        trace.endpos = vStart + Vector(0,0,MaxDistance)
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

local function ExperimentalKillConfirm(victim, ply, inflictor)
    if victim.isExperimental then
        local killer = "Unknown"
        if IsValid(ply) and ply:IsPlayer() then
            killer = ply:Name()
        elseif IsValid(ply) then
            killer = ply:GetClass()
        end
        vINFO("Experimental NPC("..victim:GetClass()..") killed by " ..killer)
    end
end

function Spawn(idName, className)
    local ply = VipdGetPlayer(idName)
    local vStart = ply:GetShootPos()
    local vForward = ply:GetAimVector()
    local trace = { }
    trace.start = vStart
    trace.endpos = vStart + vForward * 2048
    trace.filter = ply
    local tr = util.TraceLine(trace)
    local Position = tr.HitPos
    local Normal = tr.HitNormal
    Position = Position + Normal * 32
    local Angles = ply:EyeAngles()
    Angles.yaw = Angles.yaw + 180 -- Rotate it 180 degrees in my favour
    Angles.roll = 0
    Angles.pitch = 0
    local Health = 100
    local Weapon = "none"
    Weapon = GetWeapon(className, 100)
    local Team = "Experimental"
    local NPC = VipdSpawnNPC(className, Position, Angles, Health, Weapon, Team)
    NPC.isExperimental = true
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

--=====--
--Hooks--
--=====--

hook.Add( "OnNPCKilled", "VipdDefenseExperimentalKilled", ExperimentalKillConfirm)
