local function ValidateWeapons()
    for key, weapon in pairs(list.Get("Weapon")) do
        local vipd_wep = vipd_weapons[key]
        if(weapon.Spawnable and vipd_wep == nil) then
            vINFO("Spawnable weapon not in vipd_weapons: " .. key .. " adding it with default value: " .. DEFAULT_WEAPON_COST)
            AddWeapon(key, weapon.PrintName, 0, DEFAULT_WEAPON_COST, false, false, false, GLOBAL_MIN_COST, GLOBAL_MAX_COST)
        end
    end
    for class, weapon in pairs(vipd_weapons) do
        local swep = weapons.Get( class )
        if swep == nil then
            swep = list.Get("Weapon")[class]
        end
        if swep == nil then
            swep = list.Get("SpawnableEntities")[class]
        end
        if swep == nil and class ~= "none" and not weapon.override then
            vDEBUG("Could not find "..class.." in gmod's list, removing it.")
            vipd_weapons[class] = nil
        end
    end
end

local function ValidateNpcs()
    for key, npc in pairs(list.Get("NPC")) do
        local vipd_npc = vipd_npcs[key]
        if not vipd_npc then
            local class = npc.Class
            vDEBUG("Spawnable NPC not in vipd_npcs: " .. key .. " | " .. class)
        end
    end
    for class, npc in pairs(vipd_npcs) do
        local snpc = list.Get("NPC")[class]
        if snpc == nil and not npc.override then
            vDEBUG("Could not find "..class.." in gmod's list, removing it.")
            vipd_npcs[class] = nil
        end
    end
end

local function GetDataFromGmod(vipd_weapon)
    local class = vipd_weapon.class
    local swep = weapons.Get( class )
    if swep == nil then
        swep = list.Get("Weapon")[class]
    end
    if swep == nil then
        swep = list.Get("SpawnableEntities")[name]
    end
    if swep ~= nil then
        vipd_weapon.name = swep.PrintName
        if swep.Primary then vipd_weapon.primary_ammo = swep.Primary.Ammo end
        if swep.Secondary then vipd_weapon.secondary_ammo = swep.Secondary.Ammo end
    end
    if not vipd_weapon.name then vipd_weapon.name = class end
    if not vipd_weapon.override then vipd_weapon.override = false end
end

function InitializeLevelSystem()
    vINFO("Initializing Level System")
    ReadWeaponsFromDisk()
    for class, vipd_weapon in pairs(vipd_weapons) do
        RegisteredWeaponCount = RegisteredWeaponCount + 1
        if vipd_weapon.cost == nil then vipd_weapon.cost = 0 end
        if vipd_weapon.npcValue == nil then vipd_weapon.npcValue = 0 end
        if vipd_weapon.class == nil then vipd_weapon.class = class end
        if vipd_weapon.max_permanent == nil then vipd_weapon.max_permanent = 1 end
        if vipd_weapon.temp_buys == nil then vipd_weapon.temp_buys = 0 end
        if vipd_weapon.perm_buys == nil then vipd_weapon.perm_buys = 0 end
        if vipd_weapon.init == nil then vipd_weapon.init = false end
        if vipd_weapon.consumable == nil then vipd_weapon.consumable = false end
        if vipd_weapon.mincost == nil then vipd_weapon.mincost = GLOBAL_MIN_COST end
        if vipd_weapon.maxcost == nil then vipd_weapon.maxcost = GLOBAL_MAX_COST end
        GetDataFromGmod(vipd_weapon)
        if vipd_weapon.cost > 0 then StoreInventoryCount = StoreInventoryCount + 1 end
    end
    for key, vipd_npc in pairs(vipd_npcs) do
        RegisteredNpcCount = RegisteredNpcCount + 1
        vipd_npc.gmod_class = key
        vipd_npc.class = key
        local gmod_npc = list.Get("NPC")[key]
        if gmod_npc then
            if gmod_npc.Class then vipd_npc.class = gmod_npc.Class end
            if gmod_npc.Name then vipd_npc.name = gmod_npc.Name end
            if gmod_npc.Model then
                NpcsByModel[gmod_npc.Model] = { name = vipd_npc.name, value = vipd_npc.value }
                vDEBUG("Associated "..vipd_npc.name.." with model "..gmod_npc.Model)
            end
        end
    end
    ValidateWeapons()
    ValidateNpcs()
    PersistSettings()
    NormalizeWeaponCostDistribution()
    PersistSettings()
end
