--CheekyVisuals
--9/14/2020
--Handles time & date operations in game

local TimeHandler = {}

--// Constants
local initDate = os.date("%j")

--// Event connections
function TimeHandler:CheckDayChanged()
    --// Check is the date changed
    local isDateChanged = os.date("%j") ~= initDate

    --// Cache the new date
    initDate = os.date("%j")

    --// Return true if day changed, false otherwise
    return isDateChanged
end

return TimeHandler