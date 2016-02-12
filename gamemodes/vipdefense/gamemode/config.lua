vipd_weapons = {
    -- Having weapons with the same value is fine, but players may never be given one of them
    -- There CANNOT be gaps, every value from 1 to the highest listed must be present
    ["weapon_stunstick"] = { name = "Stunstick", value = 0, npcValue = 1 },
    ["weapon_crowbar"] = { name = "Crowbar", value = 0, npcValue = 1 },
    ["weapon_pistol"] = { name = "Pistol", value = 1, npcValue = 2 },
    ["weapon_shotgun"] = { name = "Shotgun", value = 2, npcValue = 8 },
    ["weapon_smg1"] = { name = "SMG", value = 3, npcValue = 4 },
    ["weapon_357"] = { name = "Magnum", value = 4, npcValue = 4 },
    ["weapon_ar2"] = { name = "AR2 Rifle", value = 5, npcValue = 10 },
    ["weapon_frag"] = { name = "Frag", value = 6, npcValue = 0 },
    ["weapon_crossbow"] = { name = "Crossbow", value = 7, npcValue = 10 },
    ["weapon_rpg"] = { name = "RPG", value = 8, npcValue = 15 }
}

vipd_npc_teams = {
    { name = "Zombies", minValue = 1 },
    { name = "Antlions", minValue = 5 },
    { name = "Combine", minValue = 7 }
}

vipd_npcs = {
    -- NPCs that must be killed by RPG's cannot have a score less than 3 * RPG value + 4
    ["npc_headcrab"] = { name = "Headcrab", value = 1, team = "Zombies", model = "", useWeapons = false },
    ["npc_zombie_torso"] = { name = "Zombie Torso", value = 2, team = "Zombies", model = "", useWeapons = false },
    ["npc_barnacle"] = { name = "Barnacle", value = 1, team = "do_not_use", model = "", useWeapons = false },
    ["npc_zombie"] = { name = "Zombie", value = 2, team = "Zombies", model = "", useWeapons = false },
    ["npc_fastzombie_torso"] = { name = "Fast Zombie Torso", value = 3, team = "Zombies", model = "", useWeapons = false },
    ["npc_manhack"] = { name = "Manhack", value = 3, team = "Combine", model = "", useWeapons = false },
    ["npc_headcrab_fast"] = { name = "Headcrab Fast", value = 2, team = "Zombies", model = "", useWeapons = false },
    ["npc_headcrab_poison"] = { name = "Headcrab Poison", value = 3, team = "Zombies", model = "", useWeapons = false },
    ["npc_antlion"] = { name = "Antlion", value = 5, team = "Antlions", model = "", useWeapons = false },
    ["npc_fastzombie"] = { name = "Fast Zombie", value = 5, team = "Zombies", model = "", useWeapons = false },
    ["npc_poisonzombie"] = { name = "Poison Zombie", value = 10, team = "Zombies", model = "", useWeapons = false },
    ["npc_metropolice"] = { name = "Metro Police", value = 1, team = "Combine", model = "", useWeapons = true },
    ["npc_combine_s"] = { name = "Combine", value = 3, team = "Combine", model = "", useWeapons = true }
}

vipd_vips = {
    { name = "Elsa", class = "npc_elsa" },
    { name = "Anna", class = "npc_anna" },
    { name = "", class = "npc_alyx" },
    { name = "", class = "npc_gman" },
    { name = "", class = "npc_barney" },
    { name = "", class = "npc_eli" }
}

-- npc_stalker
-- npc_rollermine
-- npc_sniper
-- npc_vortigaunt
-- npc_antlionguard
-- npc_strider
-- npc_helicopter
-- npc_combinegunship