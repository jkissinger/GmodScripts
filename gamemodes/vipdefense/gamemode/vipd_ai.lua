--Thinking
local function GetClosestPlayer (npc)
    local closestDistance = minSpawnDistance - 100 --So that a citizen doesn't spawn and run to the player immediately
    local closestPlayer = nil
    for k, ply in pairs(player.GetAll()) do
        local distance = npc:GetPos():Distance(ply:GetPos())
        if distance < closestDistance then
            closestDistance = distance
            closestPlayer = ply
        end
    end
    return closestPlayer
end

function VipdThink ()
    if ThinkCounter < 100 then
        ThinkCounter = ThinkCounter + 1
    else
        for k, npc in pairs (ents.GetAll ()) do
            if npc.isCitizen and npc:IsSolid () then
                -- Call for help
                local percent = math.random (100)
                if percent <= 10 then
                    if string.match (npc:GetModel (), "female") then
                        npc:EmitSound ("vo/npc/female01/help01.wav", SNDLVL_95dB, 100, 1, CHAN_VOICE)
                    else
                        npc:EmitSound ("vo/npc/male01/help01.wav", SNDLVL_95dB, 100, 1, CHAN_VOICE)
                    end
                end
                -- Move to closest player
                local ply = GetClosestPlayer (npc)
                if ply ~= nil then
                    npc:SetLastPosition (ply:GetPos () )
                    npc:SetSchedule (SCHED_FORCED_GO_RUN)
                end
            end
        end
        ThinkCounter = 0
    end
end

hook.Add ("Think", "Vipd think", VipdThink)