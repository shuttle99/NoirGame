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

--// Constants
TimeHandler.initDate = os.date("%j")

--// Module functions
function TimeHandler:CheckDayChanged()
    --// Check is the date changed
    local isDateChanged = os.date("%j") ~= TimeHandler.initDate

    --// Cache the new date
    TimeHandler.initDate = os.date("%j")

    --// Reset player's daily reward eligibility
    if isDateChanged then
        DailyRewards:ResetEligibility()
    end

    --// Return true if day changed, false otherwise
    return isDateChanged
end

return TimeHandler