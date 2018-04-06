local function VipdWeaponIcon(class, vipd_weapon, availablePoints, StorePanel)
    local cost = vipd_weapon.cost
    local vply = GetLocalVply()
    if not vply.weapons[vipd_weapon.class] then
        vply.weapons[vipd_weapon.class] = 0
    end
    local material = "entities/" .. class .. ".png"

    local weapon_icon = vgui.Create("ContentIcon", StorePanel)
    weapon_icon:SetMaterial(material)
    weapon_icon:AlignLeft()
    weapon_icon:AlignTop()
    weapon_icon:SetName(vipd_weapon.name .. " $" .. cost)

    local ply = LocalPlayer()
    local tempString = "Buy Temporary for "
    if (IsValid(ply:GetWeapon(class))) then
        tempString = "Buy ammo for "
    end
    weapon_icon.OpenMenu = function()
        local menu = DermaMenu()
        if cost <= availablePoints then
            menu:AddOption(tempString .. cost .. " points", function()
                RunConsoleCommand("vipd_buy", TEMP, class)
            end)
            local affordable = cost * PERM_MODIFIER <= availablePoints
            local can_be_permanent = vply.weapons[vipd_weapon.class] < vipd_weapon.max_permanent and vipd_weapon.max_permanent > 0
            if affordable and can_be_permanent then
                menu:AddOption("Buy Permanent for " .. (cost * PERM_MODIFIER) .. " points", function()
                    RunConsoleCommand("vipd_buy", PERM, class)
                end)
            end
        else
            if not LocalPlayer():IsAdmin() then
                weapon_icon:SetEnabled(false)
            end
            weapon_icon:SetTextColor(Color(255, 0, 0))
        end
        if LocalPlayer():IsAdmin() then
            menu:AddOption("Disable", function()
                RunConsoleCommand("vipd_enable_weapon", class, "false")
            end)
            menu:AddOption("Admin purchase free for debugging", function()
                RunConsoleCommand("vipd_buy", DEBUG_PURCHASE, class)
            end)
        end
        menu:Open()
    end
    weapon_icon.DoClick = weapon_icon.OpenMenu
end

local function InitWeaponStore(icon, window)
    VipdWeaponStore = window
    local windowWidth, windowHeight = window:GetSize()
    local ScrollPanel = window:Add("DScrollPanel")
    ScrollPanel:SetSize(window:GetSize())
    local StorePanel = ScrollPanel:Add("DIconLayout")
    StorePanel:Dock(LEFT)
    StorePanel:SetWorldClicker(true)
    StorePanel:SetBorder(8)
    StorePanel:SetSpaceX(8)
    StorePanel:SetSpaceY(8)
    StorePanel:SetWide(windowWidth)
    StorePanel:SetLayoutDir(TOP)

    local Vply = GetLocalVply()
    for class, vipd_weapon in SortedPairsByMemberValue(VipdWeapons, "cost", true) do
        VipdWeaponIcon(class, vipd_weapon, Vply.points, StorePanel)
    end
end

list.Set("DesktopWindows", "VipdWeaponStore", {

    title = "Weapon Store",
    icon = "spawnicons/models/avengers/iron man/mark7_player.png",
    width = 980,
    height = 700,
    onewindow = true,
    init = InitWeaponStore
})

local function VipdWeaponStoreRefresh()
    if VipdWeaponStore then
        --TODO: Don't just remove, refresh
        VipdWeaponStore:Remove()
    end
end

hook.Add("OnContextMenuOpen", "VipdWeaponStoreRefresh", VipdWeaponStoreRefresh)
