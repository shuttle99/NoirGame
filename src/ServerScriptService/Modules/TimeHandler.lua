--CheekyVisuals
--9/14/2020
--Handles time & date operations in game

local TimeHandler = {}

--// Services
local ServerScriptService = game:GetService("ServerScriptService")

--// Folders
local Modules = ServerScriptService:WaitForChild("Modules")

--// Modules
local DailyRewards = require(Modules:WaitForChild("DailyRewards"))
local Data = require(Modules:WaitForChild("Init"))

--// Constants
TimeHandler.initDate = os.date("%j")

--// Module functions
function TimeHandler:CheckDayChanged()
    --// Check is the date changed
    local isDateChanged = os.date("%j") ~= TimeHandler.initDate
    --// Cache the new date
    TimeHandler.initDate = os.date("%j")

    --// Return true if day changed, false otherwise
    return isDateChanged
end

function TimeHandler:ComparePlayerJoin(player)
    local plrData = Data:Get(player) or Data.new(player)
    if TimeHandler.initDate ~= plrData.VisitDay:Get() then
        return true
    else
        return false
    end
end

return TimeHandler