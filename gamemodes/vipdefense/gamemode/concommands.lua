function PvpToggle(ply, cmd, arguments)
    if IsAdmin(ply) then
        PvpEnabled = not PvpEnabled
        SetPlayerHurtPlayer()
        if PvpEnabled then
            BroadcastNotify("PVP has been enabled!")
        else
            BroadcastNotify("PVP has been disabled!")
        end
    end
end

function TeleportAll(ply, cmd, arguments)
    if IsAdmin(ply) then
        for k, player in pairs(player.GetAll()) do
            vINFO("Teleporting " .. player:Name() .. " to " .. ply:Name())
            player:SetPos(ply:GetPos())
        end
    else
        Notify(ply, "That command is only for admins")
    end
end

function VipdEnableWeapon(ply, cmd, arguments)
    if not arguments or not arguments[1] then
        Notify(ply, "Invalid arguments!")
    else
        if IsAdmin(ply) then
            local enabled = arguments[2]
            if enabled == nil or enabled == "true" then
                enabled = true
            else
                enabled = false
            end
            ToggleWeapon(arguments[1], enabled)
        else
            Notify(ply, "That command is only for admins")
        end
    end
end

function VipdDropWeapon(ply, cmd, arguments)
    if IsValid(ply) and ply:IsValid() then
        ply:DropWeapon(ply:GetActiveWeapon())
    end
end