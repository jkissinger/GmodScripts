DeriveGamemode("sandbox")

GM.Name = "VIP Defense"
GM.Author = "Eruza"
GM.Email = "N/A"
GM.Website = "N/A"

local vipd_spawnmenu = CreateConVar( "vipd_spawnmenu", "0", FCVAR_REPLICATED )

-- Has to be shared because getconvar is shared and spawnmenu is client
function GM:SpawnMenuOpen()
    if vipd_spawnmenu:GetBool() then
        return true
    end
    --    notification.AddLegacy("The SpawnMenu is disabled", NOTIFY_ERROR, 5)
    --    notification.AddLegacy("You are at: " .. tostring(LocalPlayer():GetPos()), NOTIFY_GENERIC, 5)
    VipdRadar = not VipdRadar
    if VipdRadar then
        notification.AddLegacy("Radar Enabled", NOTIFY_GENERIC, 5)
    else
        notification.AddLegacy("Radar Disabled", NOTIFY_GENERIC, 5)
    end
    return false
end

hook.Add( "GUIMousePressed", "DisableContextClicking", function () if not vipd_spawnmenu:GetBool() then return true end end )
