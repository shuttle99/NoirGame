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
    local plrDataStore = ds:Get(plr)
    if plr:FindFirstChild("VIP") then
        plrDataStore.Cash:Increment(amt * 2)
    else
        plrDataStore.Cash:Increment(amt)
    end
end

function statIncrementer:RemoveCoins(amt, plr)
    local plrDataStore = ds:Get(plr)
    plrDataStore.Cash:Increment(-amt)
end

function statIncrementer:GiveExp(amt, plr)
    --// Datastore init
    local plrDataStore = ds:Get(plr)

    --// Increment experience
    plrDataStore.Experience:Increment(amt)

    --// Set new level
    local level = getLevel(plrDataStore.Experience:Get())
    plrDataStore.Level:Set(math.floor(level))

    --// Make visual updates
    expUpdate:FireClient(plr, amt, level)
end

function statIncrementer:GiveTickets(amt, plr)
    local plrDataStore = ds:Get(plr)

    if plr.MembershipType == Enum.MembershipType.Premium then
        plrDataStore.Tickets:Increment(amt * 2)
    else
        plrDataStore.Tickets:Increment(amt)
    end
end

toggleGold.OnServerInvoke = function(plr, enabled, category)
    local plrDataStore = ds:Get(plr)
    if plr:FindFirstChild("Golden") then
        --// Toggle the golden category when UI button is clicked
        plrDataStore["Golden" .. category]:Set(enabled)
        return true
    else 
        MarketplaceService:PromptGamePassPurchase(plr, 10505111) 
        return false
    end
end

return statIncrementer