function Teleport (ply, cmd, arguments)
    if not arguments [1] or not arguments [2] then
        PrintTable (player.GetAll ())
    else
        local plyFrom = VipdGetPlayer(arguments[1])
        local plyTo = VipdGetPlayer(arguments[2])
        if plyFrom == nil then
            VipdLog (vWARN, "Unable to find player: "..arguments[1])
        elseif plyTo == nil then
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

function FreezePlayers ()
    if Frozen then Frozen = false else Frozen = true end
    for k, ply in pairs (player.GetAll () ) do
        ply:Freeze (Frozen)
    end
end



