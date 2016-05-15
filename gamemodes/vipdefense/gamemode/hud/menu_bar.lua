local function VipdMenuPopulate()
    local startMenu = VipdMenu:AddOption( "Start VIP Defense", function() RunConsoleCommand ( "vipd_start" ) end )
    startMenu:SetIcon( "icon16/accept.png" )

    local tpLastMenu = VipdMenu:AddOption( "Teleport to last spot", function() RunConsoleCommand ( "vipd_tpold" ) end )
    tpLastMenu:SetIcon( "icon16/accept.png" )

    if(IsValid(LocalPlayer()) and LocalPlayer():IsAdmin()) then
        local stopMenu = VipdMenu:AddOption( "Stop VIP Defense", function() RunConsoleCommand ( "vipd_stop" ) end )
        stopMenu:SetIcon( "icon16/accept.png" )

        local freezeMenu = VipdMenu:AddOption( "Freeze Players", function() RunConsoleCommand ( "vipd_freeze" ) end )
        freezeMenu:SetIcon( "icon16/accept.png" )

        local enableSpawnMenu = VipdMenu:AddOption( "Teleport All", function() RunConsoleCommand ( "vipd_tpall" ) end )
        enableSpawnMenu:SetIcon( "icon16/accept.png" )
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
