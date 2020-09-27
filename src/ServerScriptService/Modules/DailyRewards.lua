local DailyRewards = {}

--// Services
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Folders
local Modules = ServerScriptService:WaitForChild("Modules")
local UIComponents = ReplicatedStorage:WaitForChild("UIComponents")

--// Modules
local timeHandler = require(Modules:WaitForChild("TimeHandler"))
local Data = require(Modules:WaitForChild("Init"))
local DailyRewardUI = require(UIComponents:WaitForChild("DailyRewardUI"))

local function checkPremium(player)
    if player.MembershipType == Enum.MembershipType.Premium then
        return true
    else
        return false
    end
end

local function checkGroup(player)
    if player:IsInGroup(6273742) then
        return true
    else
        return false
    end
end

local function redeemReward(player)
    if checkPremium(player)  then
        --// Give extra
        print("User has premium")
    end
    if checkGroup(player) then
        --// Give Extra
        print("User is in the group")
    end
    --// Check consecutive days played
    local dataObj = Data:Get(player) or Data.new(player)
    local consecutiveDays = dataObj.ConsecutiveVisits:Get()
    if consecutiveDays == 25 then
        print("25 days total")
        --// Give player knife
    end
    --// Give main reward
    --DailyRewardUI.new(player, 100, 100, true, consecutiveDays)
end

--// Methods
function DailyRewards:GiveReward(player)
    --// Check if they can redeem the daily reward as backup
    local canRedeem = timeHandler:ComparePlayerJoin(player)
    --// Prevent them from redeeming reward again
    if canRedeem then
        redeemReward(player)
    else
        return "Unsuccessful"
    end
end

return DailyRewards