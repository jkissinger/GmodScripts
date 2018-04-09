VipdIgnoredAddons = { }

local function VipdErrorHandler(str, realm, addontitle, addonid)
    if (isstring(addonid)) then
        for id, title in pairs(VipdIgnoredAddons) do
            if id == addonid then
                vDEBUG("Addon [" .. tostring(addontitle) .. ", " .. tostring(addonid) .. "] caused an error")
                return
            end
        end
    end

    vWARN("Addon [" .. tostring(addontitle) .. ", " .. tostring(addonid) .. "] caused an error")
end

hook.Add("OnLuaError", "VipdErrorHAndler", VipdErrorHandler)