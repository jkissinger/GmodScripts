function GetVipdNpcs()
    local npcs = { }
    for key, ent in pairs(ents.GetAll()) do
        if ent.team then table.insert(npcs, ent) end
    end
    return npcs
end

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
    if vipd_npc then
        vINFO("Method VipdName worked for " .. vipd_npc.name)
        return vipd_npc
    end

    local name = NPC:GetKeyValues()["vipdname"]
    local vipd_npc = vipd_npcs[name]
    if vipd_npc then
        vINFO("Method KeyValues worked for " .. vipd_npc.name)
        return vipd_npc
    end

    local npc_model = NPC:GetModel()
    local vipd_npc = NpcsByModel[npc_model]
    if vipd_npc then
        vINFO("Method NpcByModel worked for " .. vipd_npc.name)
        return vipd_npc
    end

    local npc_class = NPC:GetClass()
    vipd_npc = GetVipdNpcByClass(npc_class)
    if vipd_npc then
        vINFO("Method NpcByClass worked for " .. vipd_npc.name)
        return vipd_npc
    end
    
    if not vipd_npc then
        vipd_npc = { name = npc_class, value = 0}
        vWARN("NPC class: ".. npc_class .. " is not defined in the config!")
    end
    return vipd_npc
end
