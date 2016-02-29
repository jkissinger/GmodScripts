local function CalculateMaxNpcs()
    local maxPer = NpcsPerPlayer * #player.GetAll()
    if maxPer > MaxNpcs then
        return MaxNpcs
    else
        return maxPer
    end
end

function CheckNpcs()
    if not DefenseSystem or #vipd.Nodes == 0 then return end
    for i = currentNpcs+1, CalculateMaxNpcs() do
        local node = GetNextNode()
        if node then
            if SpawnNpc(node) then
                currentNpcs = currentNpcs + 1
            else
                VipdLog(vWARN, "Spawning NPC failed!")
            end
        else
            VipdLog(vWARN, "No valid NPC nodes found!")
        end
    end
end