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
    if(IsValid( ply:GetWeapon( class ) )) then
        tempString = "Buy ammo for "
    end
    weapon_icon.OpenMenu = function()
        local menu = DermaMenu()
        menu:AddOption( tempString..cost.." points", function() RunConsoleCommand ( "vipd_buy", TEMP, class ) end )
        local affordable = cost * PERM_MODIFIER <= availablePoints
        print("VplyWeapons: "..tostring(vply.weapons[vipd_weapon.class]))
        print("Max: "..tostring(vipd_weapon.max_permanent))
        local test = vply.weapons[vipd_weapon.class] < vipd_weapon.max_permanent
        local test2 = vipd_weapon.max_permanent > 0
        local can_be_permanent = vply.weapons[vipd_weapon.class] < vipd_weapon.max_permanent and vipd_weapon.max_permanent > 0
        if affordable and can_be_permanent then
            menu:AddOption( "Buy Permanent for "..(cost * PERM_MODIFIER).." points", function() RunConsoleCommand ( "vipd_buy", "perm", class ) end )
        end
        menu:Open()
    end
    weapon_icon.DoClick = weapon_icon.OpenMenu
end

local function InitWeaponStore( icon, window )
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
        notification.AddLegacy("You have no points you can't buy anything!", NOTIFY_ERROR, 10)
        return
    end
    for class, vipd_weapon in SortedPairsByMemberValue( VipdWeapons, "cost", true ) do
        if(vipd_weapon.cost > 0 and Vply.points >= vipd_weapon.cost) then
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

local function VipdWeaponStoreRefresh()
    if(VipdWeaponStore) then
        --TODO: Don't just remove, refresh
        VipdWeaponStore:Remove()
    end
end

hook.Add( "OnContextMenuOpen", "VipdWeaponStoreRefresh", VipdWeaponStoreRefresh )
