net.Receive ("gmod_notification", function ()
    local msg = net.ReadString ()
    local level = net.ReadInt (8)
    local msgType = NOTIFY_GENERIC
    if level == 2 then msgType = NOTIFY_ERROR end
    notification.AddLegacy (msg, msgType, 10)
    surface.PlaySound ("buttons/button15.wav")
end )

net.Receive ("vipd_hud", function ()
    local netTable = net.ReadTable ()
    EnemiesLeft = netTable.EnemiesLeft
    TotalFriendlys = netTable.TotalFriendlys
    DeadFriendlys = netTable.DeadFriendlys
    RescuedFriendlys = netTable.RescuedFriendlys
    VipName = netTable.VipName
    ActiveSystem = netTable.ActiveSystem
    Players = netTable.VipdPlayers
end )

function VIPDHUD ()
    if not Players then return end
    local Player = Players[LocalPlayer ():Name ()]
    if not Player then return end
    local boxTopY = ScrH () - 185
    local boxLeftX = 33
    local boxHeight = 40
    local boxWidth = 175
    local barSpace = 3
    local barHeight = math.floor((boxHeight - barSpace * 2) / 3)
    if ActiveSystem then
        -- Wave status
        draw.RoundedBox (4, boxLeftX, boxTopY, boxWidth, boxHeight, Color (0, 0, 0, 150))
        draw.SimpleText ("ENEMIES", "DermaDefaultBold", boxLeftX + 14, boxTopY + 13, Color (255, 0, 0, 255))
        draw.SimpleText (EnemiesLeft, "DermaLarge", boxLeftX + 110, boxTopY + 5, Color (255, 0, 0, 255))
        -- Friendly Status
        boxLeftX = boxLeftX + boxWidth + 10
        local percentAlive = (TotalFriendlys - DeadFriendlys - RescuedFriendlys) / TotalFriendlys
        surface.SetDrawColor( Color( 255, 255, 0, 255 ) )
        surface.DrawOutlinedRect( boxLeftX, boxTopY, boxWidth, barHeight )
        surface.DrawRect( boxLeftX, boxTopY, boxWidth * percentAlive, barHeight )
        local percentRescued = RescuedFriendlys / TotalFriendlys
        boxTopY = boxTopY + barSpace + barHeight
        surface.SetDrawColor( Color( 0, 255, 0, 255 ) )
        surface.DrawOutlinedRect( boxLeftX, boxTopY, boxWidth, barHeight)
        surface.DrawRect( boxLeftX, boxTopY, boxWidth * percentRescued, barHeight )
        local percentDead = DeadFriendlys / TotalFriendlys
        boxTopY = boxTopY + barSpace + barHeight
        surface.SetDrawColor( Color( 255, 0, 0, 255 ) )
        surface.DrawOutlinedRect( boxLeftX, boxTopY, boxWidth, barHeight)
        surface.DrawRect( boxLeftX, boxTopY, boxWidth * percentDead, barHeight )
    end
    boxTopY = ScrH () - 140
    boxLeftX = 33
    -- Player Points
    draw.RoundedBox (4, boxLeftX, boxTopY, boxWidth, boxHeight, Color (0, 0, 0, 150))
    draw.SimpleText ("POINTS", "DermaDefaultBold", boxLeftX + 14, boxTopY + 13, Color (255, 215, 0, 255))
    draw.SimpleText (Player.points, "DermaLarge", boxLeftX + 110, boxTopY + 5, Color (255, 215, 0, 255))
    -- Player Level
    boxLeftX = boxLeftX + boxWidth + 10
    draw.RoundedBox (4, boxLeftX, boxTopY, boxWidth, boxHeight, Color (0, 0, 0, 150))
    draw.SimpleText ("LEVEL", "DermaDefaultBold", boxLeftX + 14, boxTopY + 13, Color (255, 215, 0, 255))
    draw.SimpleText (Player.level, "DermaLarge", boxLeftX + 110, boxTopY + 5, Color (255, 215, 0, 255))
    -- Player Grade
    boxLeftX = boxLeftX + boxWidth + 10
    draw.RoundedBox (4, boxLeftX, boxTopY, boxWidth, boxHeight, Color (0, 0, 0, 150))
    draw.SimpleText ("WEAPON GRADE", "DermaDefaultBold", boxLeftX + 14, boxTopY + 13, Color (255, 215, 0, 255))
    draw.SimpleText (Player.grade, "DermaLarge", boxLeftX + 110, boxTopY + 5, Color (255, 215, 0, 255))
end

hook.Add ("HUDPaint", "VIPDHUD", VIPDHUD)