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
    VipdClientPlayers = netTable.VipdPlayers
end )

net.Receive ("vipd_hud_init", function ()
    local netTable = net.ReadTable ()
    VipdWeapons = netTable
end )

--w

local function GetLocalVply()
    return VipdClientPlayers[LocalPlayer():Name()]
end

local function GetLocalName()
    return LocalPlayer():Name()
end

function VIPDHUD()
    local vply = GetLocalVply()
    if not vply then return end
    local boxTopY = ScrH() - 185
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
    draw.SimpleText (vply.points, "DermaLarge", boxLeftX + 110, boxTopY + 5, Color (255, 215, 0, 255))
    -- Player Level
    boxLeftX = boxLeftX + boxWidth + 10
    draw.RoundedBox (4, boxLeftX, boxTopY, boxWidth, boxHeight, Color (0, 0, 0, 150))
    draw.SimpleText ("LEVEL", "DermaDefaultBold", boxLeftX + 14, boxTopY + 13, Color (255, 215, 0, 255))
    draw.SimpleText (vply.level, "DermaLarge", boxLeftX + 110, boxTopY + 5, Color (255, 215, 0, 255))
    -- Player Grade
    boxLeftX = boxLeftX + boxWidth + 10
    draw.RoundedBox (4, boxLeftX, boxTopY, boxWidth, boxHeight, Color (0, 0, 0, 150))
    draw.SimpleText ("WEAPON GRADE", "DermaDefaultBold", boxLeftX + 14, boxTopY + 13, Color (255, 215, 0, 255))
    draw.SimpleText (vply.grade, "DermaLarge", boxLeftX + 110, boxTopY + 5, Color (255, 215, 0, 255))

    if VipdRadar then
        local local_pos = LocalPlayer():EyePos()
        local enemy_pos = vply.enemy_position
        if enemy_pos then
            cam.Start3D()
            local beam_color = Color( 0, 255, 0, 255 )
            local texcoord = math.Rand( 0, 1 )
            local distance = local_pos:Distance(enemy_pos)
            local adjusted_pos = local_pos - Vector(0, 0, 50)
            local end_texcoord = texcoord + distance / 128
            local Laser = Material( "cable/redlaser" )
            render.SetMaterial( Laser )
            render.DrawBeam( adjusted_pos, enemy_pos, 16, texcoord, end_texcoord, beam_color )
            cam.End3D()
        end
    end
end

function OpenTeleportMenu()
    local TeleportMenu = DermaMenu()

    for name, player in pairs (VipdClientPlayers) do
        if name ~= GetLocalName() then
            local teleportSubmenu = TeleportMenu:AddOption( name, function() RunConsoleCommand( "vipd_tp", name ) end )
            teleportSubmenu:SetIcon( "icon16/accept.png" )
        end
    end

    TeleportMenu:Open()
end

local function VipdMenuPopulate()
    local startMenu = VipdMenu:AddOption( "Start VIP Defense", function() RunConsoleCommand( "vipd_start" ) end )
    startMenu:SetIcon( "icon16/accept.png" )

    local tpLastMenu = VipdMenu:AddOption( "Teleport to last spot", function() RunConsoleCommand( "vipd_tpold" ) end )
    tpLastMenu:SetIcon( "icon16/accept.png" )

    if (IsValid(LocalPlayer()) and LocalPlayer():IsAdmin()) then
        local stopMenu = VipdMenu:AddOption( "Stop VIP Defense", function() RunConsoleCommand( "vipd_stop" ) end )
        stopMenu:SetIcon( "icon16/accept.png" )

        local freezeMenu = VipdMenu:AddOption( "Freeze Players", function() RunConsoleCommand( "vipd_freeze" ) end )
        freezeMenu:SetIcon( "icon16/accept.png" )

        -- Make this a sub menu
        local handicapMenu = VipdMenu:AddOption( "Set Handicap", function() RunConsoleCommand( "vipd_handicap" ) end )
        handicapMenu:SetIcon( "icon16/accept.png" )
    end
end

local function VipdWeaponStoreRefresh()
    if (VipdWeaponStore) then
        --TODO: Don't just remove, refresh
        VipdWeaponStore:Remove()
    end
end

hook.Add ("HUDPaint", "VIPDHUD", VIPDHUD)
hook.Add( "PopulateMenuBar", "DisplayOptions_Vipd", function( menubar ) VipdMenu = menubar:AddOrGetMenu( "VIP Defense" ) end )
hook.Add( "OnContextMenuOpen", "VipdWeaponStoreRefresh", VipdWeaponStoreRefresh )
hook.Add( "InitPostEntity", "VipdMenuPopulate", VipdMenuPopulate )

local function VipdWeaponIcon(class, vipd_weapon, availablePoints, StorePanel)
    local cost = vipd_weapon.cost
    local vply = GetLocalVply()
    if not vply.weapons[vipd_weapon.class] then vply.weapons[vipd_weapon.class] = 0 end
    local material = "entities/" .. class .. ".png"

    local weapon_icon = vgui.Create( "ContentIcon", StorePanel )
    weapon_icon:SetMaterial( material )
    weapon_icon:SetName( vipd_weapon.name )

    local ply = LocalPlayer()
    local tempString = "Buy Temporary for "
    if (IsValid( ply:GetWeapon( class ) )) then
        tempString = "Buy ammo for "
    end
    -- Add functionality
    weapon_icon.OpenMenu = function()
        local menu = DermaMenu()
        menu:AddOption( tempString..cost.." points", function() RunConsoleCommand( "vipd_buy", TEMP, class ) end )
        local affordable = cost * PERM_MODIFIER <= availablePoints
        local can_be_permanent = vply.weapons[class] < vipd_weapon.max_permanent and vipd_weapon.max_permanent > 0
        if affordable and can_be_permanent then
            menu:AddOption( "Buy Permanent for "..(cost * PERM_MODIFIER).." points", function() RunConsoleCommand( "vipd_buy", "perm", class ) end )
        end
        menu:Open()
    end
    weapon_icon.DoClick = weapon_icon.OpenMenu
end

local function InitWeaponStore ( icon, window )
    VipdWeaponStore = window
    local windowWidth, windowHeight = window:GetSize()
    local ScrollPanel = window:Add( "DScrollPanel" )
    ScrollPanel:SetSize( window:GetSize() )
    local StorePanel = ScrollPanel:Add( "DIconLayout" )
    StorePanel:Dock( LEFT )
    StorePanel:SetWorldClicker( true )
    StorePanel:SetBorder( 8 )
    StorePanel:SetSpaceX( 8 )
    StorePanel:SetSpaceY( 8 )
    StorePanel:SetWide( windowWidth )
    StorePanel:SetLayoutDir( TOP )

    local Vply = GetLocalVply()
    if Vply.points == 0 then
        VipdWeaponStore:Remove()
        notification.AddLegacy ("You have no points you can't buy anything!", NOTIFY_ERROR, 10)
        return
    end
    for class, vipd_weapon in SortedPairsByMemberValue( VipdWeapons, "cost", true ) do
        if (vipd_weapon.cost > 0 and Vply.points >= vipd_weapon.cost) then
            VipdWeaponIcon(class, vipd_weapon, Vply.points, StorePanel)
        end
    end
end


list.Set( "DesktopWindows", "VipdWeaponStore", {

        title       = "Weapon Store",
        icon        = "spawnicons/models/avengers/iron man/mark7_player.png",
        width       = 960,
        height      = 700,
        onewindow   = true,
        init        = InitWeaponStore
} )

list.Set( "DesktopWindows", "VipdSuicide", {

        title       = "Let it go!",
        icon        = "spawnicons/models/player_elsa.png",
        init        = function(  )

            RunConsoleCommand( "kill" )

        end
} )


list.Set( "DesktopWindows", "VipdTeleport", {

        title       = "Teleport",
        icon        = "spawnicons/models/player_anna.png",
        init        = OpenTeleportMenu
} )
