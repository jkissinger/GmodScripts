include( "shared.lua" )

net.Receive( "gmod_notification", function()
    local msg = net.ReadString()
	notification.AddLegacy( msg, NOTIFY_GENERIC, 10 )
    surface.PlaySound( "buttons/button15.wav" )
end )