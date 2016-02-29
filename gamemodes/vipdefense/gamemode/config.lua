vipd_weapons = {
    -- Having weapons with the same tier is fine, but players may never be given one of them
    -- There CANNOT be gaps, every tier from 1 to the highest listed must be present
    ["none"] = { name = "No weapon", tier = 0, npcValue = 0 },
    ["weapon_stunstick"] = { name = "Stunstick", tier = 0, npcValue = 1 },
    ["weapon_crowbar"] = { name = "Crowbar", tier = 0, npcValue = 1 },
    ["weapon_pistol"] = { name = "Pistol", tier = 1, npcValue = 2 },
    ["weapon_shotgun"] = { name = "Shotgun", tier = 2, npcValue = 8 },
    ["weapon_smg1"] = { name = "SMG", tier = 3, npcValue = 4 },
    ["weapon_357"] = { name = "Magnum", tier = 4, npcValue = 4 },
    ["weapon_ar2"] = { name = "AR2 Rifle", tier = 5, npcValue = 10 },
    ["weapon_frag"] = { name = "Frag", tier = 6, npcValue = 5 },
    ["weapon_crossbow"] = { name = "Crossbow", tier = 7, npcValue = 10 },
    ["weapon_rpg"] = { name = "RPG", tier = 8, npcValue = 15 }
}

vipd_enemy_teams = {
    { name = "Zombies", outside = false, inside = true }
    ,{ name = "Antlions", outside = true, inside = false }
    ,{ name = "Overwatch", outside = true, inside = true }
--,{ name = "Other", outside = false, inside = true }
}

vipd_npcs = {
    ["npc_headcrab"] = { name = "Headcrab", value = 1, team = "Zombies"},
    ["npc_zombie_torso"] = { name = "Zombie Torso", value = 2, team = "Zombies"},
    ["npc_barnacle"] = { name = "Barnacle", value = 1, team = "do_not_use"},
    ["npc_zombie"] = { name = "Zombie", value = 2, team = "Zombies"},
    ["npc_fastzombie_torso"] = { name = "Fast Zombie Torso", value = 3, team = "Zombies"},
    ["npc_manhack"] = { name = "Manhack", value = 3, team = "Overwatch", flying = true},
    ["npc_headcrab_fast"] = { name = "Headcrab Fast", value = 2, team = "Zombies"},
    ["npc_headcrab_black"] = { name = "Headcrab Poison", value = 3, team = "Zombies"},
    ["npc_headcrab_poison"] = { name = "Headcrab Poison", value = 3, team = "do_not_use"},
    ["npc_antlion"] = { name = "Antlion", value = 5, team = "Antlions"},
    ["npc_fastzombie"] = { name = "Fast Zombie", value = 6, team = "Zombies"},
    ["npc_poisonzombie"] = { name = "Poison Zombie", value = 12, team = "Zombies"},
    ["npc_zombine"] = { name = "Zombine", value = 10, team = "Zombies"},
    ["npc_metropolice"] = { name = "Metro Police", value = 2, team = "Overwatch"},
    ["npc_combine_s"] = { name = "Combine Soldier", value = 4, team = "Overwatch"},
    ["npc_antlionguard"] = { name = "Antlion Guard", value = 30, team = "Antlions"},
    ["npc_vortigaunt"] = { name = "Evil Vortigaunt", value = 15, team = "Other"},
    ["CombineElite"] = { name = "Combine Elite", value = 8, team = "Overwatch"},
    ["npc_strider"] = { name = "Strider", value = 40, team = "Overwatch", flying = true},
    ["npc_stalker"] = { name = "Stalker", value = 10, team = "Other"},
    ["CombinePrison"] = { name = "Combine Prison Guard", value = 3, team = "Overwatch"},
    ["Elite_Strider"] = { name = "Elite Strider", value = 50, team = "Overwatch", flying = true},
    ["PrisonShotgunner"] = { name = "Combine Prison Shotgunner", value = 5, team = "Overwatch"},
    ["ShotgunSoldier"] = { name = "Combine Shotgun Soldier", value = 8, team = "Overwatch"},
    ["npc_combinegunship"] = { name = "Combine Gunship", value = 70, team = "Overwatch", flying = true},
    ["npc_helicopter"] = { name = "Combine Helicopter", value = 60, team = "Overwatch", flying = true },
    ["npc_citizen"] = { name = "Citizen", value = -10, team = "do_not_use" }
}

vipd_vips = {
    { name = "Elsa", class = "npc_elsa" },
    { name = "Anna", class = "npc_anna" },
    { name = "", class = "npc_alyx" },
    { name = "", class = "npc_gman" },
    { name = "", class = "npc_barney" },
    { name = "", class = "npc_eli" }
}
