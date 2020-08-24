local codes = {}

--// Services
local ServerScriptService = game:GetService("ServerScriptService")

--// Folders
local modules = ServerScriptService.Modules

--// Modules
local data = require(modules:WaitForChild("Init"))
local statIncrementer = modules:WaitForChild("StatIncrementer")

--// Local functions
local function checkForItem(plr, item, category)
    local plrDataStore = data:Get(plr)
    if not table.find(plrDataStore[category]:Get(), item) then
        local ItemData = plrDataStore[category]:Get()
        table.insert(ItemData, item)
        plrDataStore[category]:Set(ItemData)
        return false
    end
end

local function checkForCodeRedeemed(plr, code)
    local plrDataStore = data:Get(plr)
    if not table.find(plrDataStore.CodesRedeemed:Get(), code) then
        print("Code is not found in the datastore")
        local CodeData = plrDataStore.CodesRedeemed:Get()
        table.insert(CodeData, code)
        plrDataStore.CodesRedeemed:Set(CodeData)
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
    ["TWIISTED"] = function(plr)
        print("Code twisted has been added")
    end
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