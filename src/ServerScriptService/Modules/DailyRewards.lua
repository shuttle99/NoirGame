local DailyRewards = {}

print("Required 1")

--// Services
local ServerScriptService = game:GetService("ServerScriptService")

--// Folders
local Modules = ServerScriptService:WaitForChild("Modules")

--// Modules
local timeHandler = require(Modules:WaitForChild("TimeHandler"))

print("Required")

--// Methods
function DailyRewards:GiveReward(player)
    --// Check if they can redeem the daily reward as backup
    local canRedeem = timeHandler:ComparePlayerJoin(player)
    --// Prevent them from redeeming reward again
    if canRedeem then
        print("Successfully redeemed!")
    else
        print("Unsuccessful redemption attempt.")
    end
end

DailyRewards.Rewards = {
    [1] = {
        ["Icon"] = "",
        ["Redeem"] = function()
            print("Hello")
        end
    }
}

return DailyRewards