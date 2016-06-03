-- Global values
RegisteredNpcCount = 0
RegisteredWeaponCount = 0
NpcsByModel = { }

-- ===========================
-- = Configuration Constants =
-- ===========================
-- These are likely to become ConVars
-- Level System
LevelSystem = true
MaxLevel = 200
MaxTier = 0
-- Spawn System
MIN_SPAWN_DISTANCE = 800 -- Minimum distance to spawn from players
MAX_NPCS = 20
MAX_DISTANCE = 500000
MAX_NPCS_PER_PLAYER = 10
TELEPORT_COOLDOWN = 30
TAGGED_ENEMY = nil
TAGGED_FRIENDLY = nil
IS_ENEMY_TAGGED = nil
PVP_ENABLED = CreateConVar( "vipd_pvp", "0", FCVAR_REPLICATED )
NODES_PER_GROUP = 500
--Chance a group is friendly
VIPD_FRIENDLY_CHANCE = 10
--Chance a friendly is a VIP
VIPD_VIP_CHANCE = 10
MAX_GROUP_SIZE = 30
GROUP_DISTANCE = 2000
--
VIPD_LOADOUT_OVERRIDE = false
