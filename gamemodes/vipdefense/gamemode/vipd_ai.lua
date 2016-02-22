--Thinking
function VipdThink ()
    if ThinkCounter < 200 then
        ThinkCounter = ThinkCounter + 1
    else
        for k, npc in pairs (ents.GetAll ()) do
            if npc.isCitizen then
                local percent = math.random (100)
                if percent <= 20 then
                    if string.match(npc:GetModel(), "female") then
                        npc:EmitSound ("vo/npc/female01/help01.wav", SNDLVL_95dB, 100, 1, CHAN_VOICE)
                    else
                        npc:EmitSound ("vo/npc/male01/help01.wav", SNDLVL_95dB, 100, 1, CHAN_VOICE)
                    end
                end
            end
        end
        ThinkCounter = 0
    end
end

hook.Add ("Think", "Vipd think", VipdThink)