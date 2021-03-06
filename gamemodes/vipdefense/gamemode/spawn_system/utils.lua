function GetDispositionString(victim, attacker)
    local disposition = victim:Disposition(attacker)
    if disposition == D_ER then
        return "Error"
    elseif disposition == D_HT then
        return "Hate"
    elseif disposition == D_FR then
        return "Friendly"
    elseif disposition == D_LI then
        return "Like"
    elseif disposition == D_NE then
        return "Neutral"
    else
        return "Unknown (" .. disposition .. ")"
    end
end

-- Entity Functions
function IsFriendly(victim, attacker)
    if IsValid(victim) then
        local disposition = victim:Disposition(attacker)
        if disposition == D_ER then
            vINFO("Victim [" .. victim:GetName() .. "] had ERROR disposition to [" .. attacker:GetName() .. "]")
            return false
        elseif disposition == D_HT then
            return false
        elseif disposition == D_FR then
            return true
        elseif disposition == D_LI then
            return true
        elseif disposition == D_NE then
            vINFO("Victim [" .. victim:GetName() .. "] had NEUTRAL disposition to [" .. attacker:GetName() .. "]")
            return false
        else
            vWARN("Victim [" .. victim:GetName() .. "] had UNKNOWN[" .. tostring(disposition) .. "] disposition to [" .. attacker:GetName() .. "]")
            return false
        end
    else
        return false
    end
end

function IsAlive(npc)
    return npc and IsValid(npc) and npc:IsSolid() and npc:IsNPC()
end

function IsVipdNpc(ent)
    return ent ~= nil and ent.team ~= nil and ent.team.name ~= nil
end

function IsEnemy(ent)
    return IsVipdNpc(ent) and not IsAlly(ent)
end

function IsAlly(ent)
    return IsVipdNpc(ent) and (ent.team.name == VipdAllyTeam.name or ent.team.name == VipdVipTeam.name)
end

-- Convenience Functions
function GetVipdNpcs()
    local npcs = { }
    for key, ent in pairs(ents.GetAll()) do
        if ent.team then
            table.insert(npcs, ent)
        end
    end
    return npcs
end

function GetNpcListByTeam(team)
    local team_members = { }
    for class, npc in pairs(vipd_npcs) do
        if npc.teamname == team.name then
            table.insert(team_members, npc)
        end
    end
    return team_members
end

local function GetVipdNpcByClass(EntClass)
    if vipd_npcs[EntClass] then
        return vipd_npcs[EntClass]
    end
    for key, npc in pairs(vipd_npcs) do
        if npc.class == EntClass then
            return npc
        end
    end
end

function GetNpcData(NPC)
    local name = NPC.VipdName
    local vipd_npc = vipd_npcs[name]
    if vipd_npc then
        vDEBUG("VipdName worked for " .. name)
        return vipd_npc
    end

    name = NPC:GetKeyValues()["vipdname"]
    vipd_npc = vipd_npcs[name]
    if vipd_npc then
        vINFO("KeyValues worked for " .. vipd_npc.name)
        return vipd_npc
    end

    local npc_model = NPC:GetModel()
    vipd_npc = NpcsByModel[npc_model]
    if vipd_npc then
        if DefenseSystem then
            vINFO("Model worked for " .. vipd_npc.name .. " Model: " .. npc_model)
        end
        return vipd_npc
    end

    local npc_class = NPC:GetClass()
    vipd_npc = GetVipdNpcByClass(npc_class)
    if vipd_npc then
        return vipd_npc
    end

    if not vipd_npc then
        vipd_npc = { name = npc_class, value = 0 }
        vWARN("NPC class: " .. npc_class .. " is not defined in the config!")
    end
    return vipd_npc
end
