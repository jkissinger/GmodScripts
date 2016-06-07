-- Global values
RegisteredNpcCount = 0
RegisteredWeaponCount = 0
NpcsByModel = { }
LowestValueGroundNPC = 1000
LowestValueFlyingNPC = 1000
TaggedEnemy = nil
TaggedAlly = nil

-- ===========================
-- = Configuration Constants =
-- ===========================
-- These are likely to become ConVars or more likely console commands to change them
-- == Level System Constants ==
LevelSystem = true
MaxLevel = 200
MaxTier = 0
-- == Spawn System Constants ==
VALID_CONFIG = false
MIN_SPAWN_DISTANCE = 800 -- Minimum distance to spawn from players
MAX_NPCS = 3
MAX_DISTANCE = 500000
MAX_NPCS_PER_PLAYER = 10
MIN_NPC_VALUE = 3
PVP_ENABLED = CreateConVar( "vipd_pvp", "0", FCVAR_REPLICATED )
NODES_PER_GROUP = 500
VIPD_ALLY_CHANCE = 10 --Chance a group is ally
VIPD_VIP_CHANCE = 5
MAX_GROUP_SIZE = 30
GROUP_DISTANCE = 2000
-- == Utility Constants ==
VIPD_LOADOUT_OVERRIDE = false
TELEPORT_COOLDOWN = 30
SOUND_TYPE_HELP = 0
SOUND_TYPE_THANKS = 1