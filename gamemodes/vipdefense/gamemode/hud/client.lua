net.Receive("gmod_notification", function()
    local msg = net.ReadString()
    local level = net.ReadInt(8)
    local msgType = NOTIFY_GENERIC
    if level == 2 then
        msgType = NOTIFY_ERROR
    end
    notification.AddLegacy(msg, msgType, 10)
    surface.PlaySound("buttons/button15.wav")
end)

net.Receive("vipd_hud", function()
    local netTable = net.ReadTable()
    TotalEnemies = netTable.TotalEnemies
    DeadEnemies = netTable.DeadEnemies
    MaxEnemies = netTable.MaxEnemies
    CurrentEnemies = netTable.CurrentEnemies
    AliveAllies = netTable.AliveAllies
    DeadAllies = netTable.DeadAllies
    RescuedAllies = netTable.RescuedAllies
    ActiveSystem = netTable.ActiveSystem
    VipdClientPlayers = netTable.VipdPlayers
    VipdTaggedEnemyPosition = netTable.VipdTaggedEnemyPosition
    VipdTaggedAllyPosition = netTable.VipdTaggedAllyPosition
end)

net.Receive("vipd_send_nodegraph", function()
    VipdNodeLinks = ReadCompressedTable()
end)

net.Receive("vipd_hud_init", function()
    local netTable = net.ReadTable()
    VipdWeapons = netTable
end)

function GetLocalVply()
    return VipdClientPlayers[LocalPlayer():Name()]
end

local function GetLocalName()
    return LocalPlayer():Name()
end

local function DrawNodeGraph()
    if VipdNodeLinks then
        cam.Start3D()
        local beam_color = Color(0, 0, 255, 255)
        local texcoord = 0
        for k, link in pairs(VipdNodeLinks) do
            local init_pos = link.src
            local end_pos = link.dest
            local distance = init_pos:Distance(end_pos)
            local adjusted_pos = init_pos - Vector(0, 0, 40)
            local end_texcoord = texcoord + distance / 128
            local Laser = Material("cable/redlaser")
            render.SetMaterial(Laser)
            render.DrawBeam(adjusted_pos, end_pos, 16, texcoord, end_texcoord, beam_color)
        end
        cam.End3D()
    end
end

function VIPDHUD()
    local vply = GetLocalVply()
    if not vply then
        return
    end
    local boxInitTopY = ScrH() - 185
    local boxLeftX = 33
    local boxHeight = 40
    local boxWidth = 175
    local barSpace = 3
    local barHeight = math.floor((boxHeight - barSpace * 2) / 3)
    if ActiveSystem then
        SystemWasActive = true
        local boxTopY = boxInitTopY
        -- Wave Status
        local percentSpawned = CurrentEnemies / MaxEnemies
        local percentKilled = DeadEnemies / TotalEnemies
        local percentRemaining = (TotalEnemies - DeadEnemies) / TotalEnemies

        surface.SetDrawColor(Color(255, 255, 0, 255))
        surface.DrawOutlinedRect(boxLeftX, boxTopY, boxWidth, barHeight)
        surface.DrawRect(boxLeftX, boxTopY, boxWidth * percentRemaining, barHeight)

        boxTopY = boxTopY + barSpace + barHeight
        surface.SetDrawColor(Color(0, 255, 0, 255))
        surface.DrawOutlinedRect(boxLeftX, boxTopY, boxWidth, barHeight)
        surface.DrawRect(boxLeftX, boxTopY, boxWidth * percentKilled, barHeight)

        boxTopY = boxTopY + barSpace + barHeight
        surface.SetDrawColor(Color(255, 0, 0, 255))
        surface.DrawOutlinedRect(boxLeftX, boxTopY, boxWidth, barHeight)
        surface.DrawRect(boxLeftX, boxTopY, boxWidth * percentSpawned, barHeight)
        -- Ally Status
        boxTopY = boxInitTopY
        boxLeftX = boxLeftX + boxWidth + 10
        local TotalAllies = AliveAllies + DeadAllies + RescuedAllies
        local percentAlive = (TotalAllies - DeadAllies - RescuedAllies) / TotalAllies
        surface.SetDrawColor(Color(255, 255, 0, 255))
        surface.DrawOutlinedRect(boxLeftX, boxTopY, boxWidth, barHeight)
        surface.DrawRect(boxLeftX, boxTopY, boxWidth * percentAlive, barHeight)
        local percentRescued = RescuedAllies / TotalAllies
        boxTopY = boxTopY + barSpace + barHeight
        surface.SetDrawColor(Color(0, 255, 0, 255))
        surface.DrawOutlinedRect(boxLeftX, boxTopY, boxWidth, barHeight)
        surface.DrawRect(boxLeftX, boxTopY, boxWidth * percentRescued, barHeight)
        local percentDead = DeadAllies / TotalAllies
        boxTopY = boxTopY + barSpace + barHeight
        surface.SetDrawColor(Color(255, 0, 0, 255))
        surface.DrawOutlinedRect(boxLeftX, boxTopY, boxWidth, barHeight)
        surface.DrawRect(boxLeftX, boxTopY, boxWidth * percentDead, barHeight)
    elseif SystemWasActive and CurrentEnemies == 0 then
        surface.PlaySound("npc/overwatch/radiovoice/hero.wav")
        SystemWasActive = false
    end
    boxTopY = ScrH() - 140
    boxLeftX = 33
    -- Player Points
    draw.RoundedBox(4, boxLeftX, boxTopY, boxWidth, boxHeight, Color(0, 0, 0, 150))
    draw.SimpleText("POINTS", "DermaDefaultBold", boxLeftX + 14, boxTopY + 13, Color(255, 215, 0, 255))
    draw.SimpleText(vply.points, "DermaLarge", boxLeftX + 110, boxTopY + 5, Color(255, 215, 0, 255))
    -- Player Level
    boxLeftX = boxLeftX + boxWidth + 10
    draw.RoundedBox(4, boxLeftX, boxTopY, boxWidth, boxHeight, Color(0, 0, 0, 150))
    draw.SimpleText("LEVEL", "DermaDefaultBold", boxLeftX + 14, boxTopY + 13, Color(255, 215, 0, 255))
    draw.SimpleText(vply.level, "DermaLarge", boxLeftX + 110, boxTopY + 5, Color(255, 215, 0, 255))
    -- Player Grade
    boxLeftX = boxLeftX + boxWidth + 10
    draw.RoundedBox(4, boxLeftX, boxTopY, boxWidth, boxHeight, Color(0, 0, 0, 150))
    draw.SimpleText("WEAPON GRADE", "DermaDefaultBold", boxLeftX + 14, boxTopY + 13, Color(255, 215, 0, 255))
    draw.SimpleText(vply.grade, "DermaLarge", boxLeftX + 110, boxTopY + 5, Color(255, 215, 0, 255))

    if VipdRadar == 1 then
        local local_pos = LocalPlayer():EyePos()
        if VipdTaggedEnemyPosition then
            cam.Start3D()
            local beam_color = Color(0, 255, 255, 255)
            local texcoord = 0
            local distance = local_pos:Distance(VipdTaggedEnemyPosition)
            local adjusted_pos = local_pos - Vector(0, 0, 40)
            local end_texcoord = texcoord + distance / 128
            local Laser = Material("cable/redlaser")
            render.SetMaterial(Laser)
            render.DrawBeam(adjusted_pos, VipdTaggedEnemyPosition, 16, texcoord, end_texcoord, beam_color)
            cam.End3D()
        end
    elseif VipdRadar == 2 then
        local local_pos = LocalPlayer():EyePos()
        if VipdTaggedAllyPosition then
            cam.Start3D()
            local beam_color = Color(255, 0, 255, 255)
            local texcoord = 1
            local distance = local_pos:Distance(VipdTaggedAllyPosition)
            local adjusted_pos = local_pos - Vector(0, 0, 40)
            local end_texcoord = texcoord + distance / 128
            local Laser = Material("cable/hydra")
            render.SetMaterial(Laser)
            render.DrawBeam(adjusted_pos, VipdTaggedAllyPosition, 16, texcoord, end_texcoord, beam_color)
            cam.End3D()
        end
    end
    DrawNodeGraph()
end

function OpenTeleportMenu()
    local TeleportMenu = DermaMenu()

    for name, player in pairs(VipdClientPlayers) do
        if name ~= GetLocalName() then
            local teleportSubmenu = TeleportMenu:AddOption(name, function()
                RunConsoleCommand("vipd_tp", name)
            end)
            teleportSubmenu:SetIcon("icon16/accept.png")
        end
    end

    TeleportMenu:Open()
end

hook.Add("HUDPaint", "VIPDHUD", VIPDHUD)

list.Set("DesktopWindows", "VipdSuicide", {

    title = "Let it go!",
    icon = "spawnicons/models/player_elsa.png",
    init = function()

        RunConsoleCommand("kill")

    end
})

list.Set("DesktopWindows", "VipdTeleport", {

    title = "Teleport",
    icon = "spawnicons/models/player_anna.png",
    init = OpenTeleportMenu
})
