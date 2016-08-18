DeriveGamemode("sandbox")

GM.Name = "VIP Defense"
GM.Author = "Eruza"
GM.Email = "N/A"
GM.Website = "N/A"

local vipd_spawnmenu = CreateConVar( "vipd_spawnmenu", "0", FCVAR_REPLICATED )

local function IsAdmin()
    return IsValid(LocalPlayer()) and LocalPlayer():IsAdmin()
end

local function Permissible()
    if vipd_spawnmenu:GetInt() == 2 then
        return true
    elseif vipd_spawnmenu:GetInt() == 1 and IsAdmin() then
        return true
    end
end

-- Has to be shared because getconvar is shared and spawnmenu is client
function GM:SpawnMenuOpen()
    if Permissible() then return true end
    VipdRadar = VipdRadar + 1
    if VipdRadar > 2 then VipdRadar = 0 end
    if VipdRadar == 1 then
        notification.AddLegacy("Radar set to Enemies", NOTIFY_GENERIC, 5)
    elseif VipdRadar == 2 then
        notification.AddLegacy("Radar set to Allies", NOTIFY_GENERIC, 5)
    else
        notification.AddLegacy("Radar Disabled", NOTIFY_GENERIC, 5)
    end
    return false
end

hook.Add( "GUIMousePressed", "DisableContextClicking",
    function()
        if not (Permissible() or IsAdmin()) then return true end
    end
)
