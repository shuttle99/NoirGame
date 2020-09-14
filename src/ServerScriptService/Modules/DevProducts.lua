local devProducts = {}

--// Services
local ServerScriptService = game:GetService("ServerScriptService")
local MarketplaceService = game:GetService("MarketplaceService")
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

--// Folders
local modules = ServerScriptService:WaitForChild("Modules")

--// Modules
local statIncrementer = require(modules:WaitForChild("StatIncrementer"))
local chanceHandler = require(modules:WaitForChild("ChanceHandler"))

-- Data store for tracking purchases that were successfully processed
local purchaseHistoryStore = DataStoreService:GetDataStore("PurchaseHistory")

--// Product function table
local products = {
    --// 100 CASH dev product
    [1082626880] = function(plr)
        statIncrementer:GiveCoins(800, plr)
        return "Transaction Completed"
	end
	
	--// Guarantee murderer for next round
	--[[["guaranteeMurderer"] = function(plr)
		chanceHandler:SetPlayerChance(plr, "Murderer", 10000000000)
		return "Transaction Completed"
	end,
	--// Guarantee vigilante for next round
	["guaranteeVigilante"] = function(plr)
		chanceHandler:SetPlayerChance(plr, "Vigilante", 10000000000)
		return "Transaction Completed"
	end,
	--// Guarantee vandal for next round
	["guaranteeVandal"] = function(plr)
		chanceHandler:SetPlayerChance(plr, "Vandal", 10000000000)
		return "Transaction Completed"
	end,
	--// Increment murderer chance
	["incrementMurderer"] = function(plr)
		chanceHandler:IncreasePlayerChance(plr, "Murderer", 5)
	end,
	--// Increment Vigilante chance
	["incrementVigilante"] = function(plr)
		chanceHandler:IncreasePlayerChance(plr, "Vigilante", 5)
	end,
	--// Increment Vandal chance
	["incrementVandal"] = function(plr)
		chanceHandler:IncreasePlayerChance(plr, "Vandal", 5)
	end]]
}

--// Local functions
-- The core 'ProcessReceipt' callback function
local function processReceipt(receiptInfo)
 
	-- Determine if the product was already granted by checking the data store  
	local playerProductKey = receiptInfo.PlayerId .. "_" .. receiptInfo.PurchaseId
	local purchased = false
	local success, errorMessage = pcall(function()
		purchased = purchaseHistoryStore:GetAsync(playerProductKey)
	end)
	-- If purchase was recorded, the product was already granted
	if success and purchased then
		return Enum.ProductPurchaseDecision.PurchaseGranted
	elseif not success then
		error("Data store error:" .. errorMessage)
	end
 
	-- Find the player who made the purchase in the server
	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not player then
		-- The player probably left the game
		-- If they come back, the callback will be called again
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	
	-- Look up handler function from 'productFunctions' table above
	local handler = products[receiptInfo.ProductId]
 
	-- Call the handler function and catch any errors
	local success, result = pcall(handler, player)
	if not success or not result then
		warn("Error occurred while processing a product purchase")
		print("\nProductId:", receiptInfo.ProductId)
		print("\nPlayer:", player)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
 
	-- Record transaction in data store so it isn't granted again
	local success, errorMessage = pcall(function()
		purchaseHistoryStore:SetAsync(playerProductKey, true)
	end)
	if not success then
		error("Cannot save purchase data: " .. errorMessage)
	end
 
	-- IMPORTANT: Tell Roblox that the game successfully handled the purchase
	return Enum.ProductPurchaseDecision.PurchaseGranted
end
 
-- Set the callback; this can only be done once by one script on the server! 
MarketplaceService.ProcessReceipt = processReceipt

function devProducts:PurchaseProduct(plr, id)
    MarketplaceService:PromptProductPurchase(plr, id)
end

return devProducts