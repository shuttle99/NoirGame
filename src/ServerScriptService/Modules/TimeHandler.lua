--CheekyVisuals
--9/14/2020
--Handles time & date operations in game

local TimeHandler = {}

--// Services
local ServerScriptService = game:GetService("ServerScriptService")

--// Folders
local Modules = ServerScriptService:WaitForChild("Modules")

--// Modules
local Data = require(Modules:WaitForChild("Init"))

--// Constants
TimeHandler.initDate = os.date("%j")
TimeHandler.previousDate = os.date("%j") - 1

--// Module functions
function TimeHandler:CheckDayChanged()
    --// Check is the date changed
    local isDateChanged = os.date("%j") ~= TimeHandler.initDate
    --// Cache the new date
    TimeHandler.initDate = os.date("%j")
    TimeHandler.previousDate = os.date("%j") - 1
    --// Return true if day changed, false otherwise
    return isDateChanged
end

function TimeHandler:ComparePlayerJoin(player)
    print(TimeHandler.initDate .. " is the current date")
    local plrData = Data:Get(player) or Data.new(player)
    if TimeHandler.initDate ~= plrData.VisitDay:Get() then
        if plrData.VisitDay:Get() - 1 == TimeHandler.previousDate then
            plrData.ConsecutiveVisits:Increment(1)
        else
            plrData.ConsecutiveVisits:Set(0)
        end
        return true
    else
        return false
    end
end

return TimeHandler