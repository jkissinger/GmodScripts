include("shared.lua")

-- Client global vars
waveTotal = 0
vipHealth = 0
vipName = "VIP"

net.Receive("gmod_notification", function()
    local msg = net.ReadString()
    local level = net.ReadInt(8)
    local msgType = NOTIFY_GENERIC
    if level == 2 then msgType = NOTIFY_ERROR end
    notification.AddLegacy(msg, msgType, 10)
    surface.PlaySound("buttons/button15.wav")
end )

net.Receive("wave_update", function()
    local netTable = net.ReadTable(8)
    waveTotal = netTable.waveTotal
    vipHealth = netTable.vipHealth
    vipName = netTable.vipName
end )

function hud()
    local vipTitle = vipName
    if vipTitle == "" then vipTitle = "VIP" end
    local boxTopY = ScrH() - 140
    local boxLeftX = 33
    local boxHeight = 40
    local boxWidth = 150
    -- Wave status
    draw.RoundedBox(4, boxLeftX, boxTopY, boxWidth, boxHeight, Color(0, 0, 0, 150))
    draw.SimpleText("WAVE", "DermaDefaultBold", boxLeftX + 14, boxTopY + 13, Color(255, 0, 0, 255))
    draw.SimpleText(waveTotal, "DermaLarge", boxLeftX + 100, boxTopY + 5, Color(255, 0, 0, 255))
    -- VIP Status
    boxTopY = boxTopY - boxHeight - 10
    draw.RoundedBox(4, boxLeftX, boxTopY, boxWidth, boxHeight, Color(0, 0, 0, 150))
    draw.SimpleText(vipName, "DermaDefaultBold", boxLeftX + 14, boxTopY + 13, Color(255, 215, 0, 255))
    draw.SimpleText(vipHealth, "DermaLarge", boxLeftX + 100, boxTopY + 5, Color(255, 215, 0, 255))
end 

hook.Add("HUDPaint", "VIPDHUD", hud)