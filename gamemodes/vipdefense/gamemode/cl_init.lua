include ("shared.lua")
include ("sh_vipd_utils.lua")

-- Client global vars
waveTotal = 0
VipHealth = 0
VipName = "VIP"
WaveIsInProgress = false
CurrentWave = 1

net.Receive ("gmod_notification", function ()
    local msg = net.ReadString ()
    local level = net.ReadInt (8)
    local msgType = NOTIFY_GENERIC
    if level == 2 then msgType = NOTIFY_ERROR end
    notification.AddLegacy (msg, msgType, 10)
    surface.PlaySound ("buttons/button15.wav")
end )

net.Receive ("wave_update", function ()
    local netTable = net.ReadTable ()
    waveTotal = netTable.waveTotal
    VipHealth = netTable.VipHealth
    VipName = netTable.VipName
    WaveIsInProgress = netTable.WaveIsInProgress
    CurrentWave = netTable.CurrentWave
end )

function VIPDHUD ()
    --print("WaveInProgress: "..tostring(WaveIsInProgress).." cWave: "..CurrentWave)
    local vipTitle = VipName
    if vipTitle == "" then vipTitle = "VIP" end
    local boxTopY = ScrH () - 140
    local boxLeftX = 33
    local boxHeight = 40
    local boxWidth = 160
    if WaveIsInProgress or CurrentWave > 1 then
        -- Wave status
        draw.RoundedBox (4, boxLeftX, boxTopY, boxWidth, boxHeight, Color (0, 0, 0, 150))
        draw.SimpleText ("ENEMIES", "DermaDefaultBold", boxLeftX + 14, boxTopY + 13, Color (255, 0, 0, 255))
        draw.SimpleText (waveTotal, "DermaLarge", boxLeftX + 110, boxTopY + 5, Color (255, 0, 0, 255))
        -- VIP Status
        local VipHealthColor = Color (255, 215, 0, 255)
        if VipHealth < 30 then VipHealthColor = Color (255, 0, 0, 150) end
        boxLeftX = boxLeftX + boxWidth + 10
        draw.RoundedBox (4, boxLeftX, boxTopY, boxWidth, boxHeight, Color (0, 0, 0, 150))
        draw.SimpleText (VipName, "DermaDefaultBold", boxLeftX + 14, boxTopY + 13, Color (255, 215, 0, 255))
        draw.SimpleText (VipHealth, "DermaLarge", boxLeftX + 110, boxTopY + 5, VipHealthColor)
    end
    -- Other Hud Items test
    -- Player Level
    boxLeftX = boxLeftX + boxWidth + 10
    draw.RoundedBox (4, boxLeftX, boxTopY, boxWidth, boxHeight, Color (0, 0, 0, 150))
    draw.SimpleText ("LEVEL", "DermaDefaultBold", boxLeftX + 14, boxTopY + 13, Color (255, 215, 0, 255))
    draw.SimpleText (GetLevel (LocalPlayer ()), "DermaLarge", boxLeftX + 110, boxTopY + 5, Color (255, 215, 0, 255))
    -- Player Grade
    boxLeftX = boxLeftX + boxWidth + 10
    draw.RoundedBox (4, boxLeftX, boxTopY, boxWidth, boxHeight, Color (0, 0, 0, 150))
    draw.SimpleText ("WEAPON GRADE", "DermaDefaultBold", boxLeftX + 14, boxTopY + 13, Color (255, 215, 0, 255))
    draw.SimpleText (GetGrade (LocalPlayer ()), "DermaLarge", boxLeftX + 110, boxTopY + 5, Color (255, 215, 0, 255))
end

hook.Add ("HUDPaint", "VIPDHUD", VIPDHUD)