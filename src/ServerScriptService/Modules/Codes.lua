local codes = {}

--// Services
local ServerScriptService = game:GetService("ServerScriptService")

--// Folders
local modules = ServerScriptService.Modules

--// Modules
local data = modules:WaitForChild("Init")
local statIncrementer = modules:WaitForChild("StatIncrementer")

--// Local functions
local function checkForItem(plr, item)
    local plrDataStore = dataProfile:Get(plr)
    if table.find(plrDataStore.Knives:Get(), item) then
        plrDataStore.EquippedKnife:Set(item)
        return true
    elseif table.find(plrDataStore.Guns:Get(), item) then
        print("Gun equipped")
        plrDataStore.EquippedGun:Set(item)
        return true
    elseif table.find(plrDataStore.Sprays:Get(), item) then
        plrDataStore.EquippedSpray:Set(item)
        return true
    else
        return false
    end
end

local function checkForCodeRedeemed(plr, code)
    local plrDataStore = data:Get(plr)
    if table.find(plrDataStore.CodesRedeemed:Get(), code) then
        local CodeData = plrDataStore.CodesRedeemed:Get()
        table.insert(CodeData, code)
        plrDataStore.CodesRedeemed:Set(CodeData)
    end
end

local codesTable = {
    ["CHEEKY"] = function(plr)
        --// Init the datastore
        local plrData = data:Get(plr)
        checkForItem(plr, "CheekyStab")
    end
}

function codes.Redeem(plr, code)
    if codesTable[code] then
        if checkForCodeRedeemed(plr, code) then
            codesTable[code](plr)
        end
    end
end

return codes