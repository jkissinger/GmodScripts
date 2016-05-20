vipd_enemy_teams = { }
table.insert(vipd_enemy_teams, { name = "Zombies", outside = false, inside = true })
table.insert(vipd_enemy_teams, { name = "Antlions", outside = true, inside = false })
--table.insert(vipd_enemy_teams, { name = "Overwatch", outside = true, inside = true })
--table.insert(vipd_enemy_teams, { name = "Aliens", outside = true, inside = true })
vipd_npcs = { }
vipd_weapons = { }
vipd_weapons["none"] = { name = "No weapon" }
vipd_weapons["weapon_fists"] = { name = "Fists", init = true }
vipd_weapons["weapon_physcannon"] = { name = "Gravity Gun", tier = 1, npcValue = 1, cost = 10 }
vipd_weapons["weapon_stunstick"] = { name = "Stunstick", tier = 1, npcValue = 1, cost = 15 }
vipd_weapons["weapon_crowbar"] = { name = "Crowbar", tier = 1, npcValue = 1, cost = 20 }
vipd_weapons["weapon_pistol"] = { name = "Pistol", tier = 2, npcValue = 2, cost = 10 }
vipd_weapons["weapon_shotgun"] = { name = "Shotgun", tier = 3, npcValue = 8, cost = 25 }
vipd_weapons["weapon_smg1"] = { name = "SMG", tier = 4, npcValue = 4, cost = 20 }
vipd_weapons["weapon_357"] = { name = "Magnum", tier = 5, npcValue = 4, cost = 25 }
vipd_weapons["weapon_ar2"] = { name = "AR2 Rifle", tier = 6, npcValue = 10, cost = 40 }
vipd_weapons["weapon_frag"] = { name = "Frag", tier = 7, npcValue = 5, cost = 60 }
vipd_weapons["weapon_crossbow"] = { name = "Crossbow", tier = 8, npcValue = 10, cost = 60 }
vipd_weapons["weapon_rpg"] = { name = "RPG", tier = 9, npcValue = 15, cost = 100 }
vipd_weapons["weapon_slam"] = { name = "Slam", cost = 80 }
vipd_weapons["weapon_medkit"] = { name = "Medkit", cost = 500 }
vipd_weapons["weapon_physgun"] = { name = "Physgun", cost = 2000 }

-- Disabled weapons
vipd_weapons["weapon_bugbait"] = { name = "Bugbait" }
vipd_weapons["manhack_welder"] = { name = "Manhack Welder" }
vipd_weapons["gmod_camera"] = { name = "Gmod Camera" }
vipd_weapons["gmod_tool"] = { name = "Gmod Tool" }
vipd_weapons["weapon_possessor"] = { name = "Possessor" }

-- ================
-- =    Items     =
-- ================
vipd_weapons["item_battery"] = { name = "Suit Battery", cost = 5, max_permanent = 7 }
vipd_weapons["item_healthkit"] = { name = "Health Kit", cost = 15, max_permanent = 0 }

-- ===========
-- = Zombies =
-- ===========
vipd_npcs["npc_headcrab"] = { name = "Headcrab", value = 1, team = "Zombies"}
vipd_npcs["npc_zombie_torso"] = { name = "Zombie Torso", value = 2, team = "Zombies"}
vipd_npcs["npc_zombie"] = { name = "Zombie", value = 2, team = "Zombies"}
vipd_npcs["npc_fastzombie_torso"] = { name = "Fast Zombie Torso", value = 3, team = "Zombies"}
vipd_npcs["npc_headcrab_fast"] = { name = "Headcrab Fast", value = 2, team = "Zombies"}
vipd_npcs["npc_headcrab_black"] = { name = "Headcrab Poison", value = 3, team = "Zombies"}
vipd_npcs["npc_fastzombie"] = { name = "Fast Zombie", value = 6, team = "Zombies"}
vipd_npcs["npc_poisonzombie"] = { name = "Poison Zombie", value = 12, team = "Zombies"}
vipd_npcs["npc_zombine"] = { name = "Zombine", value = 10, team = "Zombies"}

-- =============
-- = Antlions =
-- =============
vipd_npcs["npc_antlion"] = { name = "Antlion", value = 4, team = "Antlions"}
vipd_npcs["npc_antlionguard"] = { name = "Antlion Guard", value = 40, team = "Antlions"}

-- =============
-- = Overwatch =
-- =============
vipd_npcs["npc_metropolice"] = { name = "Metro Police", value = 2, team = "Overwatch"}
vipd_npcs["npc_combine_s"] = { name = "Combine Soldier", value = 4, team = "Overwatch"}
vipd_npcs["CombineElite"] = { name = "Combine Elite", value = 10, team = "Overwatch"}
vipd_npcs["npc_strider"] = { name = "Strider", value = 40, team = "Overwatch", flying = true}
vipd_npcs["CombinePrison"] = { name = "Combine Prison Guard", value = 5, team = "Overwatch"}
vipd_npcs["PrisonShotgunner"] = { name = "Combine Prison Shotgunner", value = 5, team = "Overwatch"}
vipd_npcs["ShotgunSoldier"] = { name = "Combine Shotgun Soldier", value = 10, team = "Overwatch"}
vipd_npcs["npc_cscanner"] = { name = "Camera Scanner", value = 1, team = "disabled" }
vipd_npcs["npc_clawscanner"] = { name = "Camera Scanner", value = 1, team = "disabled" }
vipd_npcs["npc_combinegunship"] = { name = "Combine Gunship", value = 70, team = "Overwatch", flying = true}
vipd_npcs["npc_helicopter"] = { name = "Combine Helicopter", value = 60, team = "Overwatch", flying = true }
vipd_npcs["npc_manhack"] = { name = "Manhack", value = 6, team = "Overwatch", flying = true}

-- =========
-- = Aliens =
-- =========
vipd_npcs["npc_vortigaunt"] = { name = "Evil Vortigaunt", value = 15, team = "Aliens"}
vipd_npcs["VortigauntSlave"] = { name = "Vortigaunt Slave", value = 4, team = "Aliens"}
vipd_npcs["npc_stalker"] = { name = "Stalker", value = 10, team = "Aliens"}

-- =============
-- = Animals =
-- =============
vipd_npcs["npc_crow"] = { name = "Crow", value = 1, team = "Animals"}
vipd_npcs["npc_pigeon"] = { name = "Pigeon", value = 1, team = "Animals"}
vipd_npcs["npc_seagull"] = { name = "Seagull", value = 1, team = "Animals"}

-- ==============
-- = Do not use =
-- ==============
vipd_npcs["npc_barnacle"] = { name = "Barnacle", value = 1, team = "do_not_use"}
vipd_npcs["npc_citizen"] = { name = "Citizen", value = -10, team = "do_not_use" }
-- These will likely be detected as "killed" after despawning so don't use since they can't be killed anyway
vipd_npcs["npc_combinedropship"] = { name = "Combine Dropship", value = 1, team = "do_not_use"}
-- spawned by poison zombies
vipd_npcs["npc_headcrab_poison"] = { name = "Headcrab Poison", value = 3, team = "do_not_use"}

vipd_vips = {
    { name = "Elsa", class = "npc_elsa" },
    { name = "Anna", class = "npc_anna" },
    { name = "", class = "npc_alyx" },
    { name = "", class = "npc_gman" },
    { name = "", class = "npc_barney" },
    { name = "", class = "npc_eli" }
}
