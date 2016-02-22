-- Networking utils

util.AddNetworkString("gmod_notification")

function Error(ply, msg)
    SendNotification(ply, msg, 2)
end

function Notify(ply, msg)
    SendNotification(ply, msg, 1)
end

function BroadcastError(msg)
    for k, ply in pairs(player.GetAll()) do
        Error(ply, msg)
    end
end

function BroadcastNotify(msg)
	for k, ply in pairs(player.GetAll()) do
        Notify(ply, msg)
    end
end

function SendNotification (ply, msg, level)
    VipdLog (vDEBUG, "Notify level "..level.." to " ..ply:Name()..": ".. msg)
    net.Start("gmod_notification")
    net.WriteString(msg)
    net.WriteInt(level, 8)
    net.Send(ply)
end

-- Messaging utils

function MsgPlayer (ply, msg)
    VipdLog (vDEBUG, "Message: " .. ply:Name () .. msg)
    ply:PrintMessage(HUD_PRINTTALK, msg)
end

function MsgCenter (msg)
    VipdLog (vDEBUG, "Center Message: " .. msg)
    PrintMessage(HUD_PRINTCENTER, msg)
end

-- Other

function GenerateNavmesh ()
    if not navmesh.IsLoaded () then
        VipdLog (vINFO, "Generating new navmesh...")
        navmesh.BeginGeneration ()
    else
        BroadcastNotify("This map already has a navmesh loaded!")
    end
end

