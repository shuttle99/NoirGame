--CheekyVisuals
--9/14/2020
--Handles time & date operations in game

local TimeHandler = {}

--// Constants
TimeHandler.initDate = os.date("%j")

--// Event connections
function TimeHandler:CheckDayChanged()
    --// Check is the date changed
    local isDateChanged = os.date("%j") ~= TimeHandler.dofilenitDate

    --// Cache the new date
    TimeHandler.initDate = os.date("%j")

    --// Return true if day changed, false otherwise
    return isDateChanged
end

return TimeHandler