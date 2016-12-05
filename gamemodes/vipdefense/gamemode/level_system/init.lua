local function ValidateWeapons()
    for key, weapon in pairs(list.Get("Weapon")) do
        local vipd_wep = vipd_weapons[key]
        if(weapon.Spawnable and vipd_wep == nil) then
            vDEBUG("Spawnable weapon not in vipd_weapons: " .. key .. " adding it with default value: " .. DEFAULT_WEAPON_COST)
            vipd_weapons[key] = { class = key, name = weapon.PrintName, npcValue = 0, cost = DEFAULT_WEAPON_COST, override = false }
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
        if not vipd_weapon.cost then vipd_weapon.cost = 0 end
        if not vipd_weapon.npcValue then vipd_weapon.npcValue = 0 end
        if not vipd_weapon.class then vipd_weapon.class = class end
        if not vipd_weapon.max_permanent then vipd_weapon.max_permanent = 1 end
        if not vipd_weapon.temp_buys then vipd_weapon.temp_buys = 0 end
        if not vipd_weapon.perm_buys then vipd_weapon.perm_buys = 0 end
        if not vipd_weapon.init then vipd_weapon.init = false end
        if not vipd_weapon.consumable then vipd_weapon.consumable = false end
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
end
