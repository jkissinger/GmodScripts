--Spawn system
local SpawnSystemCounter = 0
local SpawnSystemInterval = 20
local CallForHelpInterval = 40
local LocationInterval = 100
local CheckNpcInterval = 120
local RagdollRemoval = 500

--=======--
--  HUD  --
--=======--

local function CheckTaggedEnemy(npc, tag_enemy)
    if tag_enemy then npc.isTaggedEnemy = true end
    if npc.isTaggedEnemy then TAGGED_ENEMY = npc end
    return false
end

--=============--
-- Maintenance --
--=============--

local function RemoveRagdolls()
    local models = { }
    models["models/combine_strider.mdl"] = true
    for key, entity in pairs(ents.GetAll()) do
        if entity:GetClass() == "prop_ragdoll" and models[entity:GetModel()] then
            entity:Remove()
        end
        if entity:GetClass() == "prop_ragdoll" and entity:IsSolid() then
            vTRACE("Solid ragdoll found removing it: "..entity:GetModel())
            --entity:Remove()
        end
    end
end

--===========--
--Spawn Logic--
--===========--

local function CalculateMaxNpcs()
    local maxPer = NpcsPerPlayer * #player.GetAll()
    if maxPer > MaxNpcs then
        return MaxNpcs
    else
        return maxPer
    end
end

local function CheckNpcs()
    local maxNpcs = CalculateMaxNpcs()
    vTRACE("Checking npcs, total: "..maxNpcs.." current: "..CurrentNpcs)
    if CurrentNpcs < maxNpcs then
        if #vipd.Nodes < 1 then return end
        local node = GetNextNode()
        if node then
            local npc = SpawnNpc(node)
            if not npc then
                vWARN("Spawning NPC failed!")
            end
        else
            vWARN("No valid NPC nodes found!")
        end
    end
end

--=======--
-- Think --
--=======--

local function DoThink()
    local tag_enemy = not TAGGED_ENEMY
    TAGGED_ENEMY = nil
    local total_current_enemies = 0
    local total_current_friendlies = 0
    for k, npc in pairs(GetVipdNpcs()) do
        local is_valid_npc = npc and IsValid(npc) and npc:IsSolid() and npc:IsNPC()
        local is_valid_vipd_npc = is_valid_npc and (npc.isEnemy or npc.isFriendly)
        if is_valid_vipd_npc then
            SetBehavior(npc)
            if npc.isEnemy then
                tag_enemy = CheckTaggedEnemy(npc, tag_enemy)
                total_current_enemies = total_current_enemies + 1
            elseif npc.isFriendly then
                total_current_friendlies = total_current_friendlies + 1
            end
            if SpawnSystemCounter % CallForHelpInterval == 0 and npc.isFriendly then CallForHelp(npc) end
            if SpawnSystemCounter % LocationInterval == 0 then CheckLocation(npc) end
        end
    end
    CurrentNpcs = total_current_enemies + total_current_friendlies
    if SpawnSystemCounter % CheckNpcInterval == 0 then CheckNpcs() end
    if SpawnSystemCounter % RagdollRemoval == 0 then RemoveRagdolls() end
end

function SpawnSystemThink()
    SpawnSystemCounter = SpawnSystemCounter + 1
    if SpawnSystemCounter % SpawnSystemInterval then DoThink() end
end
