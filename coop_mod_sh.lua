AddCSLuaFile()

-- Control use of spawn menu
hook.Add("SpawnMenuOpen", "SandboxBaby", DisallowSpawnMenu)
hook.Add("OnSpawnMenuOpen", "NoSpawnMenuForYou", DisallowSpawnMenu)
hook.Add("SpawnMenuEnabled", "DisableSpawnMenuOKAY", DisallowSpawnMenu)

function DisallowSpawnMenu()
    return false
end