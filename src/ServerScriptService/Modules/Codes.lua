local codes = {}

--// Services
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Folders
local modules = ServerScriptService.Modules
local shared = ReplicatedStorage:WaitForChild("Shared")
local uiComponents = shared:WaitForChild("UIComponents")
local uiEvents = uiComponents:WaitForChild("UIEvents")

--// Modules
local data = require(modules:WaitForChild("Init"))
local statIncrementer = modules:WaitForChild("StatIncrementer")

--// Events
local addInventoryPanel = uiEvents:WaitForChild("AddInventoryPanel")

--// Local functions
local function checkForItem(plr, item, category)
    local plrDataStore = data:Get(plr)
    if not table.find(plrDataStore[category]:Get(), item) then
        local ItemData = plrDataStore[category]:Get()
        table.insert(ItemData, item)
        plrDataStore[category]:Set(ItemData)
        addInventoryPanel:FireClient(plr, item, category)
        return false
    end
end

local function checkForCodeRedeemed(plr, code)
    local plrDataStore = data:Get(plr)
    if not table.find(plrDataStore.CodesRedeemed1:Get(), code) then
        print("Code is not found in the datastore")
        local CodeData = plrDataStore.CodesRedeemed1:Get()
        table.insert(CodeData, code)
        plrDataStore.CodesRedeemed1:Set(CodeData)
        return false
    else return true
    end
end

local codesTable = {
    ["CHEEKY"] = function(plr)
        --// Init the datastore
        local plrData = data:Get(plr)
        checkForItem(plr, "CheekyStab", "Knives")
    end,
}

function codes:Redeem(plr, code)
    if codesTable[code] then
        if not checkForCodeRedeemed(plr, code) then
            codesTable[code](plr)
            return true
        else
            return false
        end
    end
end

return codes