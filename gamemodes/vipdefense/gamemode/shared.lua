DeriveGamemode( "sandbox" )

GM.Name = "VIP Defense"
GM.Author = "Eruza"
GM.Email = "N/A"
GM.Website = "N/A"

--Has to be shared because getconvar is shared and spawnmenu is client
function GM:SpawnMenuOpen()
	local spawnMenu =  GetConVar( "vipd_spawnmenu" )
	if spawnMenu:GetString() == "1" then
        return true
    end
    notification.AddLegacy( "The SpawnMenu is disabled", NOTIFY_ERROR, 5 )
    return false
end