function Teleport(ply, cmd, arguments)
    if not arguments [1] or not arguments [2] then
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

function PrintNPCs ()
    PrintTable (list.Get ("NPC"))
end

function PrintEntities ()
    PrintTable(ents.GetAll())
end

function FreezePlayers ()
    if Frozen then Frozen = false else Frozen = true end
    for k, ply in pairs (player.GetAll () ) do
        ply:Freeze (Frozen)
    end
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
            --if not tr.HitSky then VipdLog(vDEBUG, "Trace hit texture: "..tr.HitTexture.." world: "..tostring(tr.HitWorld).. " entity: "..tostring(tr.Entity:GetClass())) end
            if tr.HitSky then
                --Trace back down
                local traceBack = { }
                traceBack.start = tr.HitPos - Vector(0, 0, 500)
                traceBack.endpos = npc:EyePos()
                traceBack.filter = { }
                table.insert(traceBack.filter, game.GetWorld())
                table.insert(traceBack.filter, npc)
                tr = util.TraceLine(traceBack)
                if tr.Hit then
                    VipdLog(vDEBUG, "REVERSE - Trace hit texture: "..tr.HitTexture.." world: "..tostring(tr.HitWorld).. " entity: "..tr.Entity:GetClass())
                    VipdLog(vDEBUG, "End: " .. tostring(traceBack.endpos).." Hit: "..tostring(tr.HitPos))
                end
            end
        else
            VipdLog(vDEBUG, "Trace hit nothing!")
        end
    end
end
