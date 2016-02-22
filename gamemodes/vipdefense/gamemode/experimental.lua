function Teleport (ply, cmd, arguments)
    if not arguments [1] or not arguments [2] then
        PrintTable (player.GetAll ())
    else
        local idFrom = tonumber(arguments[1])
        local idTo = tonumber(arguments[2])
        VipdLog (vINFO, "from: '" .. idFrom .. "' to: '" .. idTo.."'")
        local plyFrom = player.GetAll ()[idFrom]
        local plyTo = player.GetAll ()[idTo]
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

function PrintNPCs ()
    PrintTable (list.Get ("NPC"))
end

function FreezePlayers ()
    if Frozen then Frozen = false else Frozen = true end
    for k, ply in pairs (player.GetAll () ) do
        ply:Freeze (Frozen)
    end
end



