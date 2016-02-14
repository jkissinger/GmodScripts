DeriveGamemode("sandbox")

GM.Name = "VIP Defense"
GM.Author = "Eruza"
GM.Email = "N/A"
GM.Website = "N/A"

local vipd_spawnmenu = CreateConVar( "vipd_spawnmenu", "0", FCVAR_REPLICATED )
CreateConVar( "vipd_pointsperlevel", "10", FCVAR_REPLICATED )
CreateConVar ("vipd_levelspergrade", "5", FCVAR_REPLICATED)

-- Shared constants
MaxLevel = 50

-- Has to be shared because getconvar is shared and spawnmenu is client
function GM:SpawnMenuOpen()
    if vipd_spawnmenu:GetBool() then
        return true
    end
    notification.AddLegacy("The SpawnMenu is disabled", NOTIFY_ERROR, 5)
    notification.AddLegacy("You are at: " .. tostring(LocalPlayer():GetPos()), NOTIFY_GENERIC, 5)
    return false
end