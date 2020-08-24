local replicatedStorage = game:GetService("ReplicatedStorage")
local UIComponents = replicatedStorage:WaitForChild("UIComponents")
local timer = require(UIComponents:WaitForChild("Timer"))
local shop = require(UIComponents:WaitForChild("Shop"))
local inventory = require(UIComponents:WaitForChild("Inventory"))
local plr = game.Players.LocalPlayer
local uiEvents = UIComponents:WaitForChild("UIEvents")
local connection

--// Folders
local shared = replicatedStorage:WaitForChild("Shared")
local itemModels = replicatedStorage:WaitForChild("ItemModels")

--// Modules
local viewport = require(shared:WaitForChild("ViewportClass"))
local spectate = require(UIComponents.Spectate)
local exp = require(UIComponents.ExperienceBar)

--// Timer Events
local mainTimer = timer.new(plr)
local timerUpdateEvent = uiEvents:WaitForChild("TimerUpdateEvent")


--Update timer text
timerUpdateEvent.OnClientEvent:Connect(function(value)
	mainTimer:Update(value)
end)

--// Role Events
local roleNotification = uiEvents:WaitForChild("RoleNotification")

--// Role Notification
roleNotification.OnClientEvent:Connect(function(title, text)
	game:GetService("StarterGui"):SetCore("SendNotification", {
	    Title = title;
	    Text = text;
	    Duration = 5;
	})
end)

--// Shop Events
local enableShop = uiEvents:WaitForChild("EnableShop")
local disableShop = uiEvents:WaitForChild("DisableShop")
local enableShopBinded = uiEvents:WaitForChild("BindedShopEnable")
local disableShopBinded = uiEvents:WaitForChild("BindedShopDisable")

--// Shop Init
local newShop = shop.new(plr)
enableShop.OnClientEvent:Connect(function()
	newShop:Enable()
end)
disableShop.OnClientEvent:Connect(function()
	newShop:Disable()
end)

enableShopBinded.Event:Connect(function()
	newShop:Enable()
end)

disableShopBinded.Event:Connect(function()
	newShop:Disable()
end)

--// Inventory Events
local enableInventory = uiEvents:WaitForChild("EnableInventory")
local disableInventory = uiEvents:WaitForChild("DisableInventory")
local addInventoryPanel = uiEvents:WaitForChild("AddInventoryPanel")

--// Inventory elements
local inventoryPanel = UIComponents:WaitForChild("InventoryPanel")

--// Shop Init
local newInventory = inventory.new(plr)

--// Shop Inventory
addInventoryPanel.OnClientEvent:Connect(function(item, category)
	local newPanel = inventoryPanel:Clone()
	newPanel.Parent = newInventory.ui.InventoryBG:FindFirstChild(category)
	viewport.new(itemModels:WaitForChild(item), newPanel.ViewportFrame, true)
end)


enableInventory.OnClientEvent:Connect(function()
	newInventory:Enable()
end)

disableInventory.OnClientEvent:Connect(function()
	newInventory:Disable()
end)

--// Spectate events
local enableSpectate = uiEvents.EnableSpectate
local disableSpectate = uiEvents.DisableSpectate
local updateSpectate = uiEvents.UpdateSpectate
local newSpectate

--// Spectate Init
enableSpectate.OnClientEvent:Connect(function(plrList)
	print("Enabled the spectate UI")
	if newSpectate then
		print("Previous spectate UI disabled")
		newSpectate:Destroy()
	end
	for _, v in pairs(plrList) do
		print(v.Name .. " is the pre-object character name")
	end
	newSpectate = spectate.new(plr, plrList)
	print("Spectate UI Enabled")
	newSpectate:Enable()
end)

updateSpectate.OnClientEvent:Connect(function(plrToRemove)
	print("Spectate updated")
	if newSpectate then
		newSpectate:RemovePlayer(plrToRemove)
	end
end)

disableSpectate.OnClientEvent:Connect(function()
	print("Spectate UI disabled")
	if newSpectate then
		newSpectate:Destroy()
		newSpectate = nil
	end
end)

--// Load event
local loadEvent = uiEvents:WaitForChild("LoadEvent")

--// Load object
local loadingScreen = require(UIComponents:WaitForChild("LoadingMap"))

loadEvent.OnClientEvent:Connect(function()
	loadingScreen.new(plr)
end)

--// Experience events
exp.new(plr)