--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

--// Folders
local shared = ReplicatedStorage.Shared
local events  = ReplicatedStorage.Events
local modules = ServerScriptService.Modules
local classes = modules.Classes

--// Modules
local storeContainer = require(shared.StoreContainer)
local dataProfile = require(modules.Init)
local codes = require(modules.Codes)
local devProducts = require(modules.DevProducts)

--// Events
local purchaseItem = events.ItemPurchase
local itemOwned = events.CheckForItemOwned
local redeemCode = events.RedeemCode
local purchaseDevProduct = events.PurchaseDevProduct

function checkForItem(plr, item)
    local plrDataStore = dataProfile:Get(plr)
    if table.find(plrDataStore.Knives:Get(), item) then
        plrDataStore.EquippedKnife:Set(item)
        return true
    elseif table.find(plrDataStore.Guns:Get(), item) then
        plrDataStore.EquippedGun:Set(item)
        return true
    elseif table.find(plrDataStore.Sprays:Get(), item) then
        plrDataStore.EquippedSpray:Set(item)
        return true
    else
        return false
    end
end

--// Event Handlers
purchaseItem.OnServerInvoke = function(plr, category, item)
    local plrDataStore = dataProfile:Get(plr)
    local cash = plrDataStore.Cash:Get()

    if cash >= storeContainer[category][item].Price then
        if not checkForItem(plr, item) then
            plrDataStore.Cash:Increment(-storeContainer[category][item].Price)
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
            return true
        else
            return false
        end
    end
end

--// Redeem code
redeemCode.OnServerInvoke = function(plr, code)
    if codes:Redeem(plr, code) == true then
        return true
    else
        return false
    end
end

--// Purchase dev product
purchaseDevProduct.OnServerEvent:Connect(function(plr, id)
    devProducts:PurchaseProduct(plr, id)
end)

itemOwned.OnServerInvoke = checkForItem
