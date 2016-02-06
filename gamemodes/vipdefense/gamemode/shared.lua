DeriveGamemode( "sandbox" )

GM.Name = "VIP Defense"
GM.Author = "Eruza"
GM.Email = "N/A"
GM.Website = "N/A"

--Has to be shared because getconvar is shared and spawnmenu is client
function GM:SpawnMenuOpen()
	local spawnMenu =  GetConVar( "vipd_spawnmenu" )
	return spawnMenu:GetString() == "1"
end