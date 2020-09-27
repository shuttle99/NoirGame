local statIncrementer = {}

--// Services
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")

--// Folders
local modules = ServerScriptService.Modules
local uiComponents = ReplicatedStorage:WaitForChild("UIComponents")
local uiEvents = uiComponents:WaitForChild("UIEvents")

--// Events
local expUpdate = uiEvents:WaitForChild("ExpUpdate")
local toggleGold = uiEvents:WaitForChild("ToggleGold")

--// Modules
local ds = require(modules.Init)
local gamepasses = require(modules.Gamepasses)

local function getLevel(xp)
    return ((math.sqrt(625+100*xp)-25)/50)
end

function statIncrementer:GiveCoins(amt, plr)
    if plr then
        local plrDataStore = ds:Get(plr)
        if not plrDataStore then return end
        if plr:FindFirstChild("VIP") then
            plrDataStore.Cash:Increment(amt * 2)
        else
            plrDataStore.Cash:Increment(amt)
        end
    end
end

function statIncrementer:RemoveCoins(amt, plr)
    if plr then
        local plrDataStore = ds:Get(plr)
        if not plrDataStore then return end
        plrDataStore.Cash:Increment(-amt)
    end
end

function statIncrementer:GiveExp(amt, plr)
    if plr then
        --// Datastore init
        local plrDataStore = ds:Get(plr)
        if not plrDataStore then return end
        --// Increment experience
        plrDataStore.Experience:Increment(amt)

        --// Set new level
        local level = getLevel(plrDataStore.Experience:Get())
        plrDataStore.Level:Set(math.floor(level))

        --// Make visual updates
        expUpdate:FireClient(plr, amt, level)
    end
end

function statIncrementer:GiveTickets(amt, plr)
    if plr then
        local plrDataStore = ds:Get(plr)
        if not plrDataStore then return end
        --// Premium check
        if plr.MembershipType == Enum.MembershipType.Premium then
            plrDataStore.Tickets:Increment(amt * 2)
        else
            plrDataStore.Tickets:Increment(amt)
        end
    end
end

toggleGold.OnServerInvoke = function(plr, enabled, category)
    if plr then
        local plrDataStore = ds:Get(plr)
        if not plrDataStore then return end
        if plr:FindFirstChild("Golden")then
            --// Toggle the golden category when UI button is clicked
            plrDataStore["Golden" .. category]:Set(enabled)
            return true
        else 
            MarketplaceService:PromptGamePassPurchase(plr, 10505111)
            return false
        end
    end
end

return statIncrementer