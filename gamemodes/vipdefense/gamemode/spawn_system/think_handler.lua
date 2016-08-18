--Spawn system
local SpawnSystemCounter = 0
local SpawnSystemInterval = 20
local CallForHelpInterval = 40
local LocationInterval = 100

--=======--
--  HUD  --
--=======--

local function CheckTaggedEnemy(npc, tag_enemy)
    if tag_enemy then npc.isTaggedEnemy = true end
    if npc.isTaggedEnemy then TaggedEnemy = npc end
    return false
end

local function CheckTaggedAlly(npc, tag_ally)
    if tag_ally then npc.isTaggedAlly = true end
    if npc.isTaggedAlly then TaggedAlly = npc end
    return false
end

--=============--
-- Maintenance --
--=============--

function RemoveRagdolls()
    if not DefenseSystem then return end
    for key, entity in pairs(ents.GetAll()) do
        if entity:GetClass() == "prop_ragdoll" and entity:IsSolid() and NpcsByModel[entity:GetModel()] then
            if not entity.counter then entity.counter = 0 end
            if entity.counter < 3 then entity.counter = entity.counter + 1 end
            if entity.counter > 3 then
                vINFO("Solid ragdoll found removing it: "..entity:GetModel())
                entity:Remove()
            end
        end
    end
end

--========--
--Gameplay--
--========--

function GiveHealthHandicap()
    if not DefenseSystem then return end
    for key, ply in pairs(player.GetAll()) do
        local vply = GetVply(ply:Name())
        GiveBonuses(ply, vply.handicap - 1)
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

local function SpawnNewNpcs()
    local maxNpcs = CalculateMaxNpcs()
    vTRACE("Checking npcs, total: "..maxNpcs.." current: "..CurrentNpcs)
    if CurrentNpcs < maxNpcs then
        local node = GetNextNode()
        if node and node.team then
            if not SpawnNpc(node) then vWARN("Spawning NPC failed!") end
        else
            vWARN("No valid NPC nodes found! Congrats you win!")
        end
    end
end

--=======--
-- Think --
--=======--
function AllySpeak()
    if not DefenseSystem then return end
    for k, npc in pairs(GetVipdNpcs()) do
        if IsAlly(npc) and IsAlive(npc) and (npc:HasCondition(32) or npc:HasCondition(55)) then
            local percent = math.random(100)
            if percent <= 40 then AllySay(npc, "help01") end
        end
    end
end

function ValidateLocations()
    if not DefenseSystem then return end
    for k, npc in pairs(GetVipdNpcs()) do
        if IsAlive(npc) then
            CheckLocation(npc)
        end
    end
end

function CheckNpcCount()
    if not DefenseSystem then return end
    local tag_enemy = not TaggedEnemy
    TaggedEnemy = nil
    local tag_ally = not TaggedAlly
    TaggedAlly = nil
    local total_current_enemies = 0
    local total_current_friendlies = 0
    for k, npc in pairs(GetVipdNpcs()) do
        if IsAlive(npc) then
            if IsEnemy(npc) then
                tag_enemy = CheckTaggedEnemy(npc, tag_enemy)
                total_current_enemies = total_current_enemies + 1
            elseif IsAlly(npc) then
                tag_ally = CheckTaggedAlly(npc, tag_ally)
                total_current_friendlies = total_current_friendlies + 1
            end
        end
    end
    CurrentNpcs = total_current_enemies + total_current_friendlies
    AliveAllies = total_current_friendlies
    SpawnNewNpcs()
end
