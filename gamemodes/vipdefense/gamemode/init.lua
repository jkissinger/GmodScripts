AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )
include( "loadout.lua" )
include( "level_system.lua" )

function GM:Initialize()
	print( "Initializing VIP Defense")
	RunConsoleCommand("sbox_noclip", "0")
    RunConsoleCommand("sbox_godmode", "0")
    RunConsoleCommand("sbox_playershurtplayers", "0")
    RunConsoleCommand("sbox_weapons", "0")
end