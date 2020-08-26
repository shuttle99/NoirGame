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

--// CameraEvent
local fixFOV = uiEvents:WaitForChild("FixFOV")

--// Shop Inventory
addInventoryPanel.OnClientEvent:Connect(function(item, category)
	local newPanel = inventoryPanel:Clone()
	newPanel.Parent = newInventory.ui.InventoryBG:FindFirstChild(category)
	viewport.new(itemModels:WaitForChild(item), newPanel.ViewportFrame, true)
end)

fixFOV.OnClientEvent:Connect(function()
	local camera = game.Workspace.CurrentCamera
	camera.FieldOfView = 70
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

--// Code UI
local codes = require(UIComponents:WaitForChild("CodeUI"))
local disableCodeUI = uiEvents:WaitForChild("DisableCodeUI")
local enableCodeUI = uiEvents:WaitForChild("EnableCodeUI")

local codeUI = codes.new(plr)

--// Code Events
disableCodeUI.OnClientEvent:Connect(function()
	codeUI:Disable()
end)

enableCodeUI.OnClientEvent:Connect(function()
	codeUI:Enable()
end)

--// Experience events
exp.new(plr)

--// AFK Button
local plrUI = plr.PlayerGui:WaitForChild("GameUI")
local AFK = plrUI:WaitForChild("AFKButton")

AFK.MouseButton1Click:Connect(function()
	if plr:FindFirstChild("AFK") then
		plr.AFK:Destroy()
	else
		local afkValue = Instance.new("BoolValue")
		afkValue.Name = "AFK"
		afkValue.Parent = plr
	end
end)

local events = replicatedStorage:WaitForChild("Events")

local enableProximity = events:WaitForChild("EnableProximity")
local disableProximity = events:WaitForChild("DisableProximity")

local staticFrame = plrUI:WaitForChild("ProximityFrame")
local enabled = false

local TweenService = game:GetService("TweenService")
local firstTween
local secondTween

--// Static Handler
enableProximity.OnClientEvent:Connect(function()
	if not enabled then
		enabled = true
		staticFrame.Visible = true

		firstTween = TweenService:Create(staticFrame[1], TweenInfo.new(.1), {ImageTransparency = 0.8})
		firstTween:Play()

		firstTween.Completed:Wait()
		while staticFrame.Visible do
			wait(.1)
			for i = 3, 1, -1 do
				print(i)
				for _, element in pairs(staticFrame:GetChildren()) do
					element.ImageTransparency = 1
				end
				staticFrame[i].ImageTransparency = 0.8
				wait(.1)
			end
		end
	end
end)

disableProximity.OnClientEvent:Connect(function()
	enabled = false
	staticFrame.Visible = false
	for _, element in pairs(staticFrame:GetChildren()) do
		secondTween = TweenService:Create(element, TweenInfo.new(0.3), {ImageTransparency = 1})
		secondTween:Play()
	end
end)