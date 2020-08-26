local gamepasses = {}

--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local MarketplaceService = game:GetService("MarketplaceService")

--// Folders
local modules = ServerScriptService:WaitForChild("Modules")
local events = ReplicatedStorage:WaitForChild("Events")
local uiComponents = ReplicatedStorage.UIComponents
local uiEvents = uiComponents.UIEvents
local addInventoryPanel = uiEvents.AddInventoryPanel

--// Modules
local dataProfile = require(modules.Init)

--// Events
local giveTag = events:WaitForChild("GiveTag")

local function checkForItem(plr, item)
    print(plr.Name)
    local plrDataStore = dataProfile:Get(plr)
    if table.find(plrDataStore.Knives:Get(), item) then
        --plrDataStore.EquippedKnife:Set(item)
        return true
    elseif table.find(plrDataStore.Guns:Get(), item) then
        --plrDataStore.EquippedGun:Set(item)
        return true
    elseif table.find(plrDataStore.Sprays:Get(), item) then
        --plrDataStore.EquippedSpray:Set(item)
        return true
    else
        return false
    end
end

local function giveItem(item, category, plr)
    local plrDataStore = dataProfile:Get(plr)
    if not checkForItem(plr, item) then
        if category == "Knives" then
            local KnifeData = plrDataStore.Knives:Get()
            table.insert(KnifeData, item)
            plrDataStore.Knives:Set(KnifeData)
        elseif category == "Guns" then
            local GunData = plrDataStore.Guns:Get()
            table.insert(GunData, item)
            plrDataStore.Guns:Set(GunData)
        elseif category == "Sprays" then
            local SprayData = plrDataStore.Sprays:Get()
            table.insert(SprayData, item)
            plrDataStore.Sprays:Set(SprayData)
        end
        addInventoryPanel:FireClient(plr, item, category)
    end
end

--// Gamepass container
local passTable = {
    --// Golden pass from previous game
    [10505111] = function(plr)
        --// Init the user's dataProfile
        giveItem("GoldenKnife", "Knives", plr)
        giveItem("GoldenRevolver", "Guns", plr)
        giveItem("GoldSpray", "Sprays", plr)
        local goldenValue = Instance.new("BoolValue")
        goldenValue.Name = "Golden"
        goldenValue.Parent = plr
    end,

    --// Current build version of the golden pass
    [11292412] = function(plr)
        --// Init the user's dataProfile
        giveItem("GoldenKnife", "Knives", plr)
        giveItem("GoldenRevolver", "Guns", plr)
        giveItem("GoldSpray", "Sprays", plr)
        local goldenValue = Instance.new("BoolValue")
        goldenValue.Name = "Golden"
        goldenValue.Parent = plr
    end,

    --// VIP from current game
    [10544262] = function(plr)
        if not plr:FindFirstChild("VIP") then
            print("User is vip")
            giveItem("FuturisticKunai", "Knives",plr)
            local vipValue = Instance.new("BoolValue")
            vipValue.Name = "VIP"
            vipValue.Parent = plr
        end
    end,

    --// VIP from current build
    [11292444] = function(plr)
        if not plr:FindFirstChild("VIP") then
            print("User is vip")
            giveItem("FuturisticKunai", "Knives",plr)
            local vipValue = Instance.new("BoolValue")
            vipValue.Name = "VIP"
            vipValue.Parent = plr
        end
    end
}

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(plr, id, successful)
    if successful then
        passTable[id](plr)
    end
end)

function gamepasses:CheckForPasses(plr)
    for i, func in pairs(passTable) do
        if MarketplaceService:UserOwnsGamePassAsync(plr.UserId, i) then
            func(plr)
        end
    end
end

function gamepasses:CheckForPass(plr, id)
    if MarketplaceService:UserOwnsGamepassAsync(plr.UserId, id) then
        passTable[id](plr)
    end
end

return gamepasses