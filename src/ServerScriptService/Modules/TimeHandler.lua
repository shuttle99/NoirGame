--CheekyVisuals
--9/14/2020
--Handles time & date operations in game

local TimeHandler = {}

--// Services
local ServerScriptService = game:GetService("ServerScriptService")

--// Folders
local Modules = ServerScriptService:WaitForChild("Modules")

--// Modules
<<<<<<< HEAD
local DailyRewards = require(Modules:WaitForChild("DailyRewards"))
=======
>>>>>>> ShopDaily
local Data = require(Modules:WaitForChild("Init"))

--// Constants
TimeHandler.initDate = os.date("%j")
<<<<<<< HEAD
=======
TimeHandler.previousDate = os.date("%j") - 1
>>>>>>> ShopDaily

--// Module functions
function TimeHandler:CheckDayChanged()
    --// Check is the date changed
    local isDateChanged = os.date("%j") ~= TimeHandler.initDate
    --// Cache the new date
    TimeHandler.initDate = os.date("%j")
<<<<<<< HEAD

=======
    TimeHandler.previousDate = os.date("%j") - 1
>>>>>>> ShopDaily
    --// Return true if day changed, false otherwise
    return isDateChanged
end

function TimeHandler:ComparePlayerJoin(player)
<<<<<<< HEAD
    local plrData = Data:Get(player) or Data.new(player)
    if TimeHandler.initDate ~= plrData.VisitDay:Get() then
=======
    print(TimeHandler.initDate .. " is the current date")
    local plrData = Data:Get(player) or Data.new(player)
    if TimeHandler.initDate ~= plrData.VisitDay:Get() then
        if plrData.VisitDay:Get() - 1 == TimeHandler.previousDate then
            plrData.ConsecutiveVisits:Increment(1)
        else
            plrData.ConsecutiveVisits:Set(0)
        end
>>>>>>> ShopDaily
        return true
    else
        return false
    end
end

return TimeHandler