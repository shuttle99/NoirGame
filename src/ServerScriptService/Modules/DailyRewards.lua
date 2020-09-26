local DailyRewards = {}

--// Services
local ServerScriptService = game:GetService("ServerScriptService")

--// Folders
local Modules = ServerScriptService:WaitForChild("Modules")

--// Modules
local timeHandler = require(Modules:WaitForChild("TimeHandler"))
local Data = require(Modules:WaitForChild("Init"))

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
        ["Redeem"] = function(player) --// Give player 100 cash
            local dataObj = Data:Get(player) or Data.new(player)
            dataObj.Cash:Increment(100)
        end
    }
}

return DailyRewards