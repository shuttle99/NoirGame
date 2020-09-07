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
local storeContainer = require(shared:WaitForChild("StoreContainer"))

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
local initShop = uiEvents:WaitForChild("ShopInit")

--// Shop Init
local newShop

initShop.OnClientEvent:Connect(function()
	newShop = shop.new(plr)
end)

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
	if newSpectate then
		newSpectate:Destroy()
	end
	newSpectate = spectate.new(plr, plrList)
	newSpectate:Enable()
end)

updateSpectate.OnClientEvent:Connect(function(plrToRemove)
	if newSpectate then
		newSpectate:RemovePlayer(plrToRemove)
	end
end)

disableSpectate.OnClientEvent:Connect(function()
	if newSpectate then
		newSpectate:Destroy()
		newSpectate = nil
	end
end)

--// Load event
local loadEvent = uiEvents:WaitForChild("LoadEvent")

--// Load object
local loadingScreen = require(UIComponents:WaitForChild("LoadingMap"))
local loadingScreenObject
loadEvent.OnClientEvent:Connect(function(enable)
	if enable then
		loadingScreenObject = loadingScreen.new(plr)
		loadingScreenObject:Show()
	elseif enable == false then
		loadingScreenObject:Hide()
	end
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
		secondTween:Cancel()
		staticFrame.Visible = true

		firstTween = TweenService:Create(staticFrame[1], TweenInfo.new(.1), {ImageTransparency = 0.8})

		firstTween:Play()

		firstTween.Completed:Wait()
		while staticFrame.Visible do
			wait(.1)
			for i = 3, 1, -1 do
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
	print("Disabled")
	enabled = false
	for _, element in pairs(staticFrame:GetChildren()) do
		secondTween = TweenService:Create(element, TweenInfo.new(0.3), {ImageTransparency = 1})
		secondTween:Play()
	end
	staticFrame.Visible = false
end)

--// Twitch UI
local twitchLive = uiEvents:WaitForChild("TwitchLive")

twitchLive.OnClientEvent:Connect(function()
	local twitchFrame = plrUI:WaitForChild("TwitchFrame")
	twitchFrame.Visible = true
	twitchFrame.ExitButton.MouseButton1Click:Connect(function()
		twitchFrame.Visible = false
	end)
end)

--// Win screen handler
local winEvent = uiEvents:WaitForChild("VictoryScreen")

winEvent.OnClientEvent:Connect(function(winCondition)
	local background = plrUI:WaitForChild("BackgroundImage")
	background.ImageTransparency = 1
	background.Visible = true
	
	local backgroundTween = TweenService:Create(background, TweenInfo.new(1.5), {ImageTransparency = 0})
	backgroundTween:Play()
	backgroundTween.Completed:Wait()
	
	local winScreen = plrUI:WaitForChild(winCondition)
	winScreen.Position = UDim2.fromScale(0.5, -0.5)
	winScreen.Visible = true
	winScreen:TweenPosition(UDim2.fromScale(0.5, 0.5), Enum.EasingDirection.InOut, Enum.EasingStyle.Quint, 1.5)

	wait(2.5)

	winScreen:TweenPosition(UDim2.fromScale(0.5, 1.5), Enum.EasingDirection.InOut, Enum.EasingStyle.Quint, 1)
	backgroundTween = TweenService:Create(background, TweenInfo.new(1.5), {ImageTransparency = 1})
	backgroundTween:Play()
	backgroundTween.Completed:Wait()
	background.Visible = false
	winScreen.Visible = false
end)

--// Dev products
local cashPurchaseFrame = require(UIComponents:WaitForChild("PurchaseCash"))
local toggleCashPurchase = uiEvents:WaitForChild("ToggleCashPurchase")
local purchaseDevProduct = events:WaitForChild("PurchaseDevProduct")

local plrCashFrame = cashPurchaseFrame.new(plr)

toggleCashPurchase.Event:Connect(function(enable)
	if enable then
		plrCashFrame:Show()
	elseif not enable then
		plrCashFrame:Hide()
	end
end)

--// Players remaining
local playersRemaining = plrUI:WaitForChild("PlayersLeft")
local togglePlayersRemaining = uiEvents:WaitForChild("TogglePlayersRemaining")
local updatePlayersRemaining = uiEvents:WaitForChild("UpdatePlayersRemaining")

togglePlayersRemaining.OnClientEvent:Connect(function(visible, playersLeft)
	if visible then
		playersRemaining.Text = "Innocents remaining: " .. playersLeft
	end
	playersRemaining.Visible = visible
end)

updatePlayersRemaining.OnClientEvent:Connect(function(playersLeft)
	playersRemaining.Text = "Innocents remaining: " .. playersLeft
end)

--// How to play
local replicatedData = replicatedStorage:WaitForChild("ReplicatedData")
local plrData = replicatedData:WaitForChild(plr.UserId)
local howToPlay = plrUI:WaitForChild("HowToPlay")

if plrData.Visits.Value == 0 then
	howToPlay.Visible = true

	howToPlay.ExitButton.MouseButton1Click:Connect(function()
		howToPlay.Visible = false
	end)
end
