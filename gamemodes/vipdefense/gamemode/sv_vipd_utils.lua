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

function IsBitSet(val, hasBit)
    return bit.band(val, hasBit) == hasBit
end

function CitizenSay(npc, sound)
    if string.match (npc:GetModel (), "female") then
        npc:EmitSound ("vo/npc/female01/"..sound..".wav", SNDLVL_95dB, 100, 1, CHAN_VOICE)
    else
        npc:EmitSound ("vo/npc/male01/"..sound..".wav", SNDLVL_95dB, 100, 1, CHAN_VOICE)
    end
end

function VipdGetPlayer (idName)
    local ply = nil
    if tonumber(idName) ~= nil then
        idName = tonumber (idName)
        ply = player.GetAll ()[idName]
    end
    if ply == nil then
        for k, p in pairs(player.GetAll()) do
            if p:Name() == idName then ply = p end
        end
    end
    return ply
end

function GetClosestPlayer (pos, maxDistance, minDistance)
    local closestPlayer = nil
    for k, ply in pairs(player.GetAll()) do
        local distance = pos:Distance(ply:GetPos())
        if distance < maxDistance and distance > minDistance then
            maxDistance = distance
            closestPlayer = ply
        end
    end
    return closestPlayer
end