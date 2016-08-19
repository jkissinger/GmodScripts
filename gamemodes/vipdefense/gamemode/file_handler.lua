if not file.Exists( "vipdefense", "DATA" ) then file.CreateDir("vipdefense") end
WeaponSettingsFile = "vipdefense\\weapon_settings.dat"
NpcSettingsFile = "vipdefense\\npc_settings.dat"

local function PersistWeapons()
    vDEBUG("Writing weapon settings to disk.")
    file.Write( WeaponSettingsFile, "Class, Name, NPC Value, Player Cost, Override, Initialized, Consumable\n" )
    for class, weapon in pairs(vipd_weapons) do
        local line = weapon.class .. "," .. weapon.name .. "," .. weapon.npcValue .. "," .. weapon.cost .. "," .. tostring(weapon.override)
        line = line .. "," .. tostring(weapon.init) .. "," .. tostring(weapon.consumable)
        line = line .. "\n"
        file.Append(WeaponSettingsFile, line)
    end
end

local function PersistNpcs()
    vDEBUG("Writing NPC settings to disk.")
    file.Write( NpcSettingsFile, "Class, Name\n" )
    for class, npc in pairs(vipd_npcs) do
        local line = npc.class .. "," .. npc.name
        line = line .. "\n"
        file.Append(NpcSettingsFile, line)
    end

end

function PersistSettings()
    PersistNpcs()
    PersistWeapons()
end

function ReadWeaponsFromDisk()
    vDEBUG("Reading settings from disk.")
    local settings = file.Read(WeaponSettingsFile, "DATA")
    local lines = string.Split( settings, "\n" )
    -- Remove header line
    table.remove(lines, 1)
    for k, line in pairs(lines) do
        local props = string.Split( line, "," )
        local r_class = props[1]
        local r_name = props[2]
        local r_npc_value = props[3]
        local r_cost = props[4]
        local r_override = props[5]
        local r_init = props[6]
        local r_consumable = props[7]
        if r_class and r_name and r_npc_value and r_cost then
            if not vipd_weapons[r_class] then vipd_weapons[r_class] = { class = r_class } end
            local weapon = vipd_weapons[r_class]
            weapon.name = r_name
            weapon.npcValue = tonumber(r_npc_value)
            weapon.cost = tonumber(r_cost)
            weapon.override = r_override == "true"
            weapon.init = r_init  == "true"
            weapon.consumable = r_consumable == "true"
            vDEBUG("Loaded weapon: Class=" .. r_class .. " Name=" .. r_name .. "NPC Value=" .. tonumber(r_npc_value) .. " Cost=" .. tonumber(r_cost))
        end
    end
end
