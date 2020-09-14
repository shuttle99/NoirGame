local DailyRewards = {}

--// Services
local ServerScriptService = game:GetService("ServerScriptService")

--// Folders
local Modules = ServerScriptService:WaitForChild("Modules")

--// Modules
local data = require(Modules:WaitForChild("Init"))

--// Methods
function DailyRewards:GiveReward(player)
    --// Init player data
    local dataObj = data:Get(player) or data.new(player)

    --// Check if they can redeem the daily reward as backup
    local canRedeem = dataObj.CanRedeemDailyReward:Get()

    --// Prevent them from redeeming reward again
    if canRedeem then
        --// In the future, add redemption rewards
        dataObj.CanRedeemDaily:Set(false)
        print("Successfully redeemed!")
    else
        print("Unsuccessful redemption attempt.")
    end
end

function DailyRewards:ResetEligibility()
    local players = game.Players:GetPlayers()

    for _, player in pairs(players) do
        --// Init player data
        local dataObj = data:Get(player) or data.new(player)

        --// Reset eligibility
        dataObj.CanRedeemDaily:Set(true)
    end
end

return DailyRewards