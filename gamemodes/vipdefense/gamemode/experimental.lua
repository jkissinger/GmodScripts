function Teleport (idFrom, idTo)
    if idFrom == nil or idTo == nil then
        PrintTable (player.GetAll ())
    else
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



