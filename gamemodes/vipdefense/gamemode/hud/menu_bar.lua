local function VipdMenuPopulate()

    local tpLastMenu = VipdMenu:AddOption( "Teleport to last spot", function() RunConsoleCommand ( "vipd_tpold" ) end )
    tpLastMenu:SetIcon( "icon16/accept.png" )

    local dropWeaponMenu = VipdMenu:AddOption( "Drop your current weapon", function() RunConsoleCommand ( "vipd_dropweapon" ) end )
    dropWeaponMenu:SetIcon( "icon16/accept.png" )

    if(IsValid(LocalPlayer()) and LocalPlayer():IsAdmin()) then
        local startMenu = VipdMenu:AddOption( "Start VIP Defense", function() RunConsoleCommand ( "vipd_start" ) end )
        startMenu:SetIcon( "icon16/accept.png" )

        local stopMenu = VipdMenu:AddOption( "Stop VIP Defense", function() RunConsoleCommand ( "vipd_stop" ) end )
        stopMenu:SetIcon( "icon16/accept.png" )

        local startMenu = VipdMenu:AddOption( "Start NPC Calibration", function() RunConsoleCommand ( "vipd_start_calibration" ) end )
        startMenu:SetIcon( "icon16/accept.png" )

        local startMenu = VipdMenu:AddOption( "Stop NPC Calibration", function() RunConsoleCommand ( "vipd_stop_calibration" ) end )
        startMenu:SetIcon( "icon16/accept.png" )

        local freezeMenu = VipdMenu:AddOption( "Freeze Players", function() RunConsoleCommand ( "vipd_freeze" ) end )
        freezeMenu:SetIcon( "icon16/accept.png" )

        local enableSpawnMenu = VipdMenu:AddOption( "Teleport All Players to you", function() RunConsoleCommand ( "vipd_tpall" ) end )
        enableSpawnMenu:SetIcon( "icon16/accept.png" )

        local teleportToTaggedEnemy = VipdMenu:AddOption( "Teleport to Tagged Enemy", function() RunConsoleCommand ( "vipd_tp", "TAGGED" ) end )
        teleportToTaggedEnemy:SetIcon( "icon16/accept.png" )
        --
        --        local disableSpawnMenu = VipdMenu:AddOption( "Disable Spawn Menu", function() RunConsoleCommand ( "vipd_spawnmenu", "0" ) end )
        --        disableSpawnMenu:SetIcon( "icon16/accept.png" )
        --
        --        local adminSpawnMenu = VipdMenu:AddOption( "Admin Only Spawn Menu", function() RunConsoleCommand ( "vipd_spawnmenu", "1" ) end )
        --        adminSpawnMenu:SetIcon( "icon16/accept.png" )
        --
        --        local enableSpawnMenu = VipdMenu:AddOption( "Enable Spawn Menu", function() RunConsoleCommand ( "vipd_spawnmenu", "2" ) end )
        --        enableSpawnMenu:SetIcon( "icon16/accept.png" )

        --        -- Make this a sub menu
        --        local handicapMenu = VipdMenu:AddOption( "Set Handicap", function() RunConsoleCommand ( "vipd_handicap" ) end )
        --        handicapMenu:SetIcon( "icon16/accept.png" )
    end
end

hook.Add( "PopulateMenuBar", "DisplayOptions_Vipd", function( menubar ) VipdMenu = menubar:AddOrGetMenu( "VIP Defense" ) end )
hook.Add( "InitPostEntity", "VipdMenuPopulate", VipdMenuPopulate )
