local ThinkCounter = 0
ThinkFunctions = { }
table.insert(ThinkFunctions, { interval = 10, func = function() VipdHudUpdate() end })
-- Level System
table.insert(ThinkFunctions, { interval = 75, func = function() SavePos() end })
-- Spawn System
table.insert(ThinkFunctions, { interval = 200, func = function() CheckNpcCount() end })
table.insert(ThinkFunctions, { interval = 300, func = function() AllySpeak() end })
table.insert(ThinkFunctions, { interval = 400, func = function() ValidateLocations() end })
table.insert(ThinkFunctions, { interval = 500, func = function() GiveHealthHandicap() end })
table.insert(ThinkFunctions, { interval = 600, func = function() RemoveRagdolls() end })
table.insert(ThinkFunctions, { interval = 1000, func = function() CheckSpawnSystemFinished() end })

local max_interval = 0
for key, trigger in pairs(ThinkFunctions) do
    if trigger.interval > max_interval then max_interval = trigger.interval end
end

local function VipdThink()
    ThinkCounter = ThinkCounter + 1
    for key, value in pairs(ThinkFunctions) do
        if ThinkCounter % value.interval == 0 then value.func() end
    end
    if ThinkCounter > max_interval then ThinkCounter = 0 end
end

hook.Add("Think", "Vipd think", VipdThink)