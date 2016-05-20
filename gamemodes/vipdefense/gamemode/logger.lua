log_levels = { }
log_levels.vTRACE = { name = "TRACE: ", value = 0 }
log_levels.vDEBUG = { name = "DEBUG: ", value = 1 }
log_levels.vINFO = { name = "INFO: ", value = 2 }
log_levels.vWARN = { name = "WARN: ", value = 3 }
log_levels.vERROR = { name = "ERROR: ", value = 4 }
log_levels.broadcast_log = true

VipdLogLevel = log_levels.vDEBUG
VipdFileLogLevel = log_levels.vDEBUG
local Timestamp = os.time()
if not file.Exists( "vipdefense", "DATA" ) then file.CreateDir("vipdefense") end
LogFile = "vipdefense\\log-"..os.date( "%Y-%m-%d" , Timestamp )..".txt"

function VipdLog(level, msg)
    if level.value >= VipdLogLevel.value then
        if type(msg) == "table" then
            print(level.name .. " Table:")
            PrintTable(msg)
        elseif type(msg) == "string" then
            if level.value >= log_levels.vINFO.value and log_levels.broadcast_log then
                if level.value >= log_levels.vERROR.value then
                    BroadcastError(msg)
                    if DefenseSystem then StopDefenseSystem() end
                else
                    BroadcastNotify(msg)
                end
            else
                print(msg)
            end
        else
            BroadcastError("Unknown log message: " .. tostring(msg))
        end
    end
    if level.value >= VipdFileLogLevel.value and type(msg) == "string" then
        msg = level.name..msg
        file.Append(LogFile, msg.."\n")
    end
end

--Shortcut log functions
function vTRACE(msg)
    VipdLog(log_levels.vTRACE, msg)
end

function vDEBUG(msg)
    VipdLog(log_levels.vDEBUG, msg)
end

function vINFO(msg)
    VipdLog(log_levels.vINFO, msg)
end

function vWARN(msg)
    VipdLog(log_levels.vWARN, msg)
end

function vERROR(msg)
    VipdLog(log_levels.vERROR, msg)
end
