function GetNpcListByTeam(team)
    local team_members = { }
    for class, npc in pairs(vipd_npcs) do
        if npc.teamname == team.name then table.insert(team_members, npc) end
    end
    return team_members
end

local function GetVipdNpcByClass(EntClass)
    if vipd_npcs[EntClass] then return vipd_npcs[EntClass] end
    for key, npc in pairs(vipd_npcs) do
        if npc.class == EntClass then return npc end
    end
end

function GetNpcData(NPC)
    local name = NPC.VipdName
    local vipd_npc = vipd_npcs[name]
    if vipd_npc then return vipd_npc end

    local npc_model = NPC:GetModel()
    local npc_data = NpcsByModel[npc_model]
    local npc_class = NPC:GetClass()
    if not npc_data then npc_data = GetVipdNpcByClass(npc_class) end
    if not npc_data then
        npc_data = { name = npc_class, value = 0}
        vWARN("NPC class: ".. npc_class .. " is not defined in the config!")
    end
    vWARN("It didn't work for " .. npc_data.name)
    return npc_data
end
