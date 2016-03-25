function Teleport(ply, cmd, arguments)
    if not arguments or not arguments [1] or not arguments [2] then
        PrintTable (player.GetAll ())
    else
        local plyFrom = VipdGetPlayer(arguments[1])
        local plyTo = VipdGetPlayer(arguments[2])
        if not plyFrom then
            VipdLog (vWARN, "Unable to find player: "..arguments[1])
        elseif not plyTo then
            VipdLog (vWARN, "Unable to find player: "..arguments[2])
        else
            VipdLog (vINFO, "Teleporting " .. plyFrom:Name () .. " to where " .. plyTo:Name () .. " is looking.")
            local vStart = plyTo:GetShootPos ()
            local vForward = plyTo:GetAimVector ()
            local trace = { }
            trace.start = vStart
            trace.endpos = vStart + vForward * 2048
            trace.filter = plyTo
            tr = util.TraceLine (trace)
            Position = tr.HitPos
            Normal = tr.HitNormal
            Position = Position + Normal * 32
            plyFrom:SetPos (Position)
        end
    end
end

function PrintNpcs ()
    PrintTable (list.Get ("NPC"))
end

function PrintWeapons ()
    for key, weapon in pairs(weapons.GetList()) do
        VipdLog(vDEBUG, "Class: "..weapon.ClassName)
        if weapon.Primary then
            VipdLog(vDEBUG, "  Primary Ammo: "..tostring(weapon.Primary.Ammo).." ClipSize: "..tostring(weapon.Primary.ClipSize))
        end
        if weapon.Secondary then
            VipdLog(vDEBUG, "  Secondary Ammo: "..tostring(weapon.Secondary.Ammo).." ClipSize: "..tostring(weapon.Secondary.ClipSize))
        end
    end
end

function MapNodes ()
    local numNodes = 0
    vipd_nodegraph = GetVipdNodegraph ()
    if vipd_nodegraph and vipd_nodegraph.nodes then
        numNodes = #vipd_nodegraph.nodes
    end
    VipdLog(vINFO,game.GetMap().." has "..numNodes.." nodes.")
end

function FreezePlayers ()
    if Frozen then Frozen = false else Frozen = true end
    for k, ply in pairs (player.GetAll () ) do
        ply:Freeze (Frozen)
    end
end

local function GetNPCSchedule( npc )
    for s = 0, LAST_SHARED_SCHEDULE-1 do
        if ( npc:IsCurrentSchedule( s ) ) then return s end
    end
    return 0
end

local function LogNPCStatus(npc)
    local name = npc:GetClass()
    VipdLog(vDEBUG, name.." state: "..npc:GetNPCState())
    VipdLog(vDEBUG, name.." schedule: "..GetNPCSchedule(npc))
    for c = 0, 100 do
        if ( npc:HasCondition( c ) ) then
            VipdLog(vDEBUG, name.." has "..npc:ConditionName( c ).." = "..c )
        end
    end
    local caps = npc:CapabilitiesGet()
    if IsBitSet(caps, CAP_AUTO_DOORS) then VipdLog(vDEBUG, name.." can open auto doors") end
    if IsBitSet(caps, CAP_OPEN_DOORS) then VipdLog(vDEBUG, name.." can open manual doors") end
    if IsBitSet(caps, CAP_MOVE_GROUND ) then VipdLog(vDEBUG, name.." can move on the ground") end
    if IsBitSet(caps, CAP_MOVE_FLY ) then VipdLog(vDEBUG, name.." can fly") end
    if IsBitSet(caps, CAP_SQUAD ) then VipdLog(vDEBUG, name.." can form squads") end
    if IsBitSet(caps, CAP_FRIENDLY_DMG_IMMUNE ) then VipdLog(vDEBUG, name.." has friendly fire disabled") end
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
        local tr = util.TraceLine (trace)
        if tr.Hit then
            VipdLog(vDEBUG, "Trace hit texture: "..tr.HitTexture.." world: "..tostring(tr.HitWorld).. " entity: "..tr.Entity:GetClass())
            --Trace back down
            local traceBack = { }
            traceBack.start = tr.HitPos
            traceBack.endpos = npc:EyePos()
            traceBack.filter = { }
            table.insert(traceBack.filter, tr.Entity) -- Ignore the entity we hit on the way up
            table.insert(traceBack.filter, npc) -- Ignore the npc itself
            tr = util.TraceLine(traceBack)
            if tr.Hit then
                VipdLog(vDEBUG, "REVERSE - Trace hit texture: "..tr.HitTexture.." world: "..tostring(tr.HitWorld).. " entity: "..tr.Entity:GetClass())
                VipdLog(vDEBUG, "End: " .. tostring(traceBack.endpos).." Hit: "..tostring(tr.HitPos))
            else
                VipdLog(vDEBUG, "REVERSE - Trace hit nothing!")
            end
        else
            VipdLog(vDEBUG, "Trace hit nothing!")
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
        VipdLog(vINFO, "Experimental NPC ("..victim:GetClass()..") killed by " ..killer)
    end
end

function Spawn(idName, className)
    local ply = VipdGetPlayer (idName)
    local vStart = ply:GetShootPos ()
    local vForward = ply:GetAimVector ()
    local trace = { }
    trace.start = vStart
    trace.endpos = vStart + vForward * 2048
    trace.filter = ply
    local tr = util.TraceLine (trace)
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

local function GivePlayerRandomTierWeapon(ply, level, grade)
    local tier = GetWeightedRandomTier() + grade
    if level == 1 then tier = 1 end
    local newWeapon = GetWeaponForTier(ply, tier)
    if tier > MaxTier then
        GiveBonuses(ply, GetGrade(ply) - MaxTier)
    end
    GiveWeaponAndAmmo(ply, newWeapon, 3)
end

--=====--
--Hooks--
--=====--

hook.Add( "OnNPCKilled", "VipdDefenseExperimentalKilled", ExperimentalKillConfirm)
