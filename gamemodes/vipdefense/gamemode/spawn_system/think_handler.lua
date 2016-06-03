--Spawn system
local SpawnSystemCounter = 0
local SpawnSystemInterval = 20
local CallForHelpInterval = 40
local LocationInterval = 100
local CheckNpcInterval = 200
local RagdollRemoval = 500

--=======--
--  HUD  --
--=======--

local function CheckTaggedEnemy(npc, tag_enemy)
    if tag_enemy then npc.isTaggedEnemy = true end
    if npc.isTaggedEnemy then TAGGED_ENEMY = npc end
    return false
end

local function CheckTaggedFriendly(npc, tag_friendly)
    if tag_friendly then npc.isTaggedFriendly = true end
    if npc.isTaggedFriendly then TAGGED_FRIENDLY = npc end
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
    local maxPer = MAX_NPCS_PER_PLAYER * #player.GetAll()
    if maxPer > MAX_NPCS then
        return MAX_NPCS
    else
        return maxPer
    end
end

local function CheckNpcs()
    local maxNpcs = CalculateMaxNpcs()
    vTRACE("Checking npcs, total: "..maxNpcs.." current: "..CurrentNpcs)
    if CurrentNpcs < maxNpcs then
        local node = GetNextNode()
        if node then
            if not SpawnNpc(node) then vWARN("Spawning NPC failed!") end
        else
            vWARN("No valid NPC nodes found! Congrats you win!")
        end
    end
end

--=======--
-- Think --
--=======--

local function DoThink()
    local tag_enemy = not TAGGED_ENEMY
    TAGGED_ENEMY = nil
    local tag_friendly = not TAGGED_FRIENDLY
    TAGGED_FRIENDLY = nil
    local total_current_enemies = 0
    local total_current_friendlies = 0
    for k, npc in pairs(GetVipdNpcs()) do
        local is_valid_npc = npc and IsValid(npc) and npc:IsSolid() and npc:IsNPC()
        local is_valid_vipd_npc = is_valid_npc and npc.team
        if is_valid_vipd_npc then
            --SetBehavior(npc)
            if IsEnemy(npc) then
                tag_enemy = CheckTaggedEnemy(npc, tag_enemy)
                total_current_enemies = total_current_enemies + 1
            elseif IsFriendly(npc) then
                tag_friendly = CheckTaggedFriendly(npc, tag_friendly)
                total_current_friendlies = total_current_friendlies + 1
            end
            if SpawnSystemCounter % CallForHelpInterval == 0 and IsFriendly(npc) then CallForHelp(npc) end
            if SpawnSystemCounter % LocationInterval == 0 then CheckLocation(npc) end
        end
    end
    CurrentNpcs = total_current_enemies + total_current_friendlies
    TotalFriendlys = total_current_friendlies
    if SpawnSystemCounter % CheckNpcInterval == 0 then CheckNpcs() end
    if SpawnSystemCounter % RagdollRemoval == 0 then RemoveRagdolls() end
end

function SpawnSystemThink()
    SpawnSystemCounter = SpawnSystemCounter + 1
    if SpawnSystemCounter % SpawnSystemInterval then DoThink() end
end
