JsonSettingsDir = "vipdefense\\json_settings"
JsonWeaponSettings = JsonSettingsDir .. "\\weapons.txt"
JsonNpcSettings = JsonSettingsDir .. "\\npcs.txt"

local function PersistWeapons()
    vDEBUG("Writing weapon settings to disk.")
    file.CreateDir(JsonSettingsDir)
    file.Write(JsonWeaponSettings, util.TableToJSON(vipd_weapons, true))
end

local function PersistNpcs()
    vDEBUG("Writing NPC settings to disk.")
    file.CreateDir(JsonSettingsDir)
    file.Write(JsonNpcSettings, util.TableToJSON(vipd_npcs, true))
end

function PersistSettings()
    PersistNpcs()
    PersistWeapons()
end

function LoadPersistedData()
    vDEBUG("Reading settings from disk.")
    local weapon_settings = file.Read(JsonWeaponSettings, "DATA")
    if weapon_settings then
        vipd_weapons = util.JSONToTable(weapon_settings)
        vDEBUG("Loaded weapons from disk.")
    end
    local npc_settings = file.Read(JsonNpcSettings, "DATA")
    if npc_settings then
        vipd_npcs = util.JSONToTable(npc_settings)
        vDEBUG("Loaded NPCs from disk.")
    end
end

local function ValidateDefaultWeaponValues(vipd_weapon)
    if vipd_weapon.class == nil then
        vipd_weapon.class = "UNKNOWN"
    end
    if vipd_weapon.name == nil then
        vipd_weapon.name = vipd_weapon.class
    end
    if vipd_weapon.name == "Scripted Weapon" then
        vipd_weapon.name = vipd_weapon.class
    end
    if vipd_weapon.npcValue == nil then
        vipd_weapon.npcValue = 0
    end
    if vipd_weapon.consumable == nil then
        vipd_weapon.consumable = false
    end
    if vipd_weapon.spawnable == nul then
        vipd_weapon.spawnable = true
    end
    if vipd_weapon.max_permanent == nil then
        vipd_weapon.max_permanent = 1
    end
    if vipd_weapon.mincost == nil then
        vipd_weapon.mincost = GLOBAL_MIN_COST
    end
    if vipd_weapon.maxcost == nil then
        vipd_weapon.maxcost = GLOBAL_MAX_COST
    end
    if vipd_weapon.points_spent == nil then
        vipd_weapon.points_spent = 0
    end
    if vipd_weapon.give_on_spawn == nil then
        vipd_weapon.give_on_spawn = false
    end
    if vipd_weapon.override == nil then
        vipd_weapon.override = false
    end
    if vipd_weapon.cost == nil or vipd_weapon.cost < GLOBAL_MIN_COST then
        vipd_weapon.cost = GLOBAL_MIN_COST
    end
    if vipd_weapon.enabled == nil then
        vipd_weapon.enabled = true
    end
end

function ValidateWeapons()
    for class, vipd_weapon in pairs(vipd_weapons) do
        vipd_weapon.class = class
        -- Find the weapon in GMod
        local swep = weapons.Get(class)
        if swep == nil then
            swep = list.Get("Weapon")[class]
        end
        if swep == nil then
            swep = list.Get("SpawnableEntities")[class]
        end

        -- Use the data to update values
        if swep ~= nil then
            vipd_weapon.name = swep.PrintName
            if swep.Primary then
                vipd_weapon.primary_ammo = swep.Primary.Ammo
            end
            if swep.Secondary then
                vipd_weapon.secondary_ammo = swep.Secondary.Ammo
            end
            vipd_weapon.spawnable = true
        elseif class ~= "none" and not vipd_weapon.override then
            if vipd_weapon.spawnable then
                vDEBUG("Could not find " .. class .. " in gmod's list, removing it.")
                vipd_weapon.spawnable = false
            end
        end

        ValidateDefaultWeaponValues(vipd_weapon)
    end
end

local function ValidateDefaultNpcValues(vipd_npc)
    if vipd_npc.class == nil then
        vipd_npc.class = "UNKNOWN"
    end
    if vipd_npc.name == nil then
        vipd_npc.name = vipd_npc.class
    end
    if vipd_npc.model == nil then
        vipd_npc.model = vipd_npc.class
    end
    if vipd_npc.override == nil then
        vipd_npc.override = false
    end
    if vipd_npc.spawnable == nil then
        vipd_npc.spawnable = true
    end
    if vipd_npc.enabled == nil then
        vipd_npc.enabled = true
    end
    if vipd_npc.calibration == nil then
        vipd_npc.calibration = -1
    end
    if vipd_npc.value == nil then
        vipd_npc.value = 1
    end
end

function ValidateNpcs()
    for class, vipd_npc in pairs(vipd_npcs) do
        vipd_npc.class = class
        local snpc = list.Get("NPC")[vipd_npc.class]
        if snpc == nil then
            if not vipd_npc.override and vipd_npc.spawnable then
                vDEBUG("Could not find " .. class .. " in gmod's list, removing it.")
                vipd_npc.spawnable = false
            end
        else
            if snpc.Name then
                vipd_npc.name = snpc.Name
            end
            if snpc.Model then
                vipd_npc.model = snpc.Model
            end
            vipd_npc.spawnable = true
        end
        ValidateDefaultNpcValues(vipd_npc)
    end
end

function ToggleWeapon(name, enabled)
    local weapon = GetWeaponByNameOrClass(name)
    if weapon then
        weapon.enabled = enabled
        vDEBUG("Set weapon [" .. name .. "] enabled to " .. tostring(enabled))
        AdjustWeaponCosts()
    else
        vINFO("Could not find weapon by name or class [" .. name .. "]")
    end
end