local shop = {}
shop.__index = shop

--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local DataStoreService = game:GetService("DataStoreService")
local MarketplaceService = game:GetService("MarketplaceService")

--// Folders
local shared = ReplicatedStorage:WaitForChild("Shared")
local events = ReplicatedStorage:WaitForChild("Events")
local itemModels = ReplicatedStorage:WaitForChild("ItemModels")

--// Modules
local viewport = require(shared:WaitForChild("ViewportClass"))
local maid = require(shared:WaitForChild("Maid"))

--// Events
local queryStoreData = events:WaitForChild("QueryStoreData")
local gamepassPurchase = events:WaitForChild("GamepassPurchase")
local shopChange = events:WaitForChild("ShopChanged")
local requestDailyStore = events:WaitForChild("RequestDailyStore")

--// Globals
local knives
local guns
local sprays
local gamepasses
local footer
local tabs = {
    ["Knives"] = function()
        shop:ShowKnives()
    end,
    ["Guns"] = function()
        shop:ShowGuns()
    end,
    ["Sprays"] = function()
        shop:ShowSprays()
    end,
    ["Gamepasses"] = function()
        shop:ShowGamepasses()
    end
}
local connection
local repData
local shopItemViewport
local fovTween
local storeContainer = queryStoreData:InvokeServer()

--// Locals
local camera = game.Workspace.CurrentCamera
local random = Random.new()
local invPanel = script.Parent:WaitForChild("InventoryPanel")


--// Panels table
local shopPanels = {}

--// Constructor
function shop.new(plr)
    local self = setmetatable({
        plr = plr,
        ui = script.Parent:WaitForChild("ShopUI"):Clone(),
        panel = script.Parent:WaitForChild("ShopPanel"),
        openButton = script.Parent:WaitForChild("ShopOpenButton"):Clone(),
        open = false,
        debounce = false,
        enabled = false,
        replicatedData = game.ReplicatedStorage.ReplicatedData:FindFirstChild(plr.UserId),

        _toggleCashPurchase = script.Parent.UIEvents:WaitForChild("ToggleCashPurchase"),
        _maid = maid.new()
    }, shop)

    --// Get player's replicated data folder
    repData = ReplicatedStorage:WaitForChild("ReplicatedData"):WaitForChild(self.plr.UserId)

    --// Set variables for accessing pages of shop
    knives = self.ui.ShopFrame.ShopBG.Knives
    guns = self.ui.ShopFrame.ShopBG.Guns
    sprays = self.ui.ShopFrame.ShopBG.Sprays
    gamepasses = self.ui.ShopFrame.ShopBG.Gamepasses
    footer = self.ui.ShopFrame.Footer

    self:Init()

    --// Gamepass purchase handler
    for _, item in pairs(gamepasses:GetChildren()) do
        if item:IsA("Frame") then
            if MarketplaceService:UserOwnsGamePassAsync(plr.UserId, item.GamepassID.Value) then
                item:Destroy()
            else
                --// Show description on hovering
                item:WaitForChild("PurchaseButton").MouseEnter:Connect(function()
                    local tween = TweenService:Create(item:WaitForChild("Description"), TweenInfo.new(0.5, Enum.EasingStyle.Back), {BackgroundTransparency = 0.5, TextTransparency = 0})
                    local purchaseSizeTween = TweenService:Create(item.PurchaseButton, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Size = UDim2.fromOffset(210, 60)})
                    tween:Play()
                    purchaseSizeTween:Play()
                end)
                item:WaitForChild("PurchaseButton").MouseLeave:Connect(function()
                    local tween = TweenService:Create(item:WaitForChild("Description"), TweenInfo.new(0.5, Enum.EasingStyle.Back), {BackgroundTransparency = 1, TextTransparency = 1})
                    local purchaseSizeTween = TweenService:Create(item.PurchaseButton, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Size = UDim2.fromOffset(200, 50)})
                    purchaseSizeTween:Play()
                    tween:Play()
                end)
                --// Handle purchase
                item:WaitForChild("PurchaseButton").MouseButton1Click:Connect(function()
                    MarketplaceService:PromptGamePassPurchase(plr, item.GamepassID.Value)
                end)
            end
        end
    end

    --// If the player owns all gamepasses, display empty label
    gamepasses.ChildRemoved:Connect(function()
        if #gamepasses:GetChildren() == 2 then
            gamepasses.EmptyLabel.Visible = true
        end
    end)

    --// Fires when gamepass is purchased
    gamepassPurchase.OnClientEvent:Connect(function(id)
        for _, item in pairs(gamepasses:GetChildren()) do
            --// Remove gamepass from table when purchased
            if item:FindFirstChild("GamepassID") then
                if tostring(item.GamepassID.Value) == tostring(id) then
                    item:Destroy()
                end
            end
        end
    end)

    --// Handle visual effects for item panels
    for itemName, itemPanel in pairs(shopPanels) do
        --// Tween viewport frame when hovered over
        itemPanel.MouseEnter:Connect(function()
            local tween = TweenService:Create(itemPanel, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {BackgroundTransparency = .9})
            local viewportTween = TweenService:Create(itemPanel.ViewportFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Size = UDim2.fromScale(1.15, 1.15), Position = UDim2.fromScale(-0.075, -0.075)})
            tween:Play()
            viewportTween:Play()
        end)
        --// Restore position when player's mosue leaves
        itemPanel.MouseLeave:Connect(function()
            local tween = TweenService:Create(itemPanel, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {BackgroundTransparency = .7})
            local viewportTween = TweenService:Create(itemPanel.ViewportFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Size = UDim2.fromScale(1, 1), Position = UDim2.fromScale(0, 0)})
            tween:Play()
            viewportTween:Play()
        end)

        --// Fires when a player clicks an item in the shop
        itemPanel.MouseButton1Click:Connect(function()
            --// Check for gamepass tag, if so prompt purchase not purchase screen
            for i, category in pairs(storeContainer) do
                if category[itemName] then
                    --// Check if the item is not purchaseable, if it isn't, don't show it
                    if not category[itemName].Gamepass then
                        --// Stop rendering the current viewport in purchase page to prevent showing both items
                        if shopItemViewport then
                            shopItemViewport:Derender()
                        end
                        self.ui.ShopFrame.Footer.Visible = false
                        local purchasePage = self.ui.ShopFrame.PurchasePage

                        --//Item has been clicked, send to purchase page and use data to visualize, verify that data on server
                        purchasePage.Visible = true
                        self:HidePages()

                        --// Set text in purchase PurchasePage
                        purchasePage.InfoFrame.ItemName.Text = category[itemName].Name
                        purchasePage.InfoFrame.DescContainer.Description.Text = category[itemName].Description
                        purchasePage.InfoFrame.Price.Text = category[itemName].Price
                        shopItemViewport = viewport.new(itemPanel.ViewportFrame:FindFirstChildOfClass("Model"), purchasePage.ItemFrame, true)

                        --// Handle the back button MouseButton1Click
                        connection = purchasePage.BackButton.MouseButton1Click:Connect(function()
                            self.ui.ShopFrame.Footer.Visible = true
                            purchasePage.Visible = false
                            purchasePage.InfoFrame.PurchaseButton.Text = "Purchase"
                            tabs[i]()
                            connection:Disconnect()
                        end)

                        --// Handle visual effects for player hovering over back button
                        purchasePage.BackButton.MouseEnter:Connect(function()
                            local backTween = TweenService:Create(purchasePage.BackButton, TweenInfo.new(0.5), {BackgroundTransparency = 0, TextColor3 = Color3.fromRGB(114, 114, 114)})
                            backTween:Play()
                        end)
                        purchasePage.BackButton.MouseLeave:Connect(function()
                            local backTween = TweenService:Create(purchasePage.BackButton, TweenInfo.new(0.5), {BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(255, 255, 255)})
                            backTween:Play()
                        end)
                        --// Handle purchase button visual effects
                        purchasePage.InfoFrame.PurchaseButton.MouseEnter:Connect(function()
                            local purchaseTween = TweenService:Create(purchasePage.InfoFrame.PurchaseButton, TweenInfo.new(0.5), {BackgroundTransparency = 0, TextColor3 = Color3.fromRGB(255, 255, 255)})
                            purchaseTween:Play()
                        end)
                        purchasePage.InfoFrame.PurchaseButton.MouseLeave:Connect(function()
                            local purchaseTween = TweenService:Create(purchasePage.InfoFrame.PurchaseButton, TweenInfo.new(0.5), {BackgroundTransparency = 0.6, TextColor3 = Color3.fromRGB(255, 255, 255)})
                            purchaseTween:Play()
                        end)

                        --// Handle clicks on the purchase PurchasePage
                        connection = purchasePage.InfoFrame.PurchaseButton.MouseButton1Click:Connect(function()
                            --// Check that player successfully purchased item
                            if events.ItemPurchase:InvokeServer(i, itemName) then
                                --// Make inventory panel
                                local clonePanel = invPanel:Clone()
                                clonePanel.Parent = self.plr.PlayerGui.GameUI.InventoryFrame.InventoryBG[i]
                                viewport.new(itemModels[itemName], clonePanel.ViewportFrame, true)
                                --// Set text to item purchased!
                                purchasePage.InfoFrame.PurchaseButton.Text = "Item Purchased!"
                            else
                                --// If they can't afford it, ask user to purchase cash
                                self._toggleCashPurchase:Fire(self.plr, true)
                            end
                        end)
                    else
                        --// Item requires gamepasses
                        MarketplaceService:PromptGamePassPurchase(plr, category[itemName].Gamepass)
                    end
                end
            end
        end)
    end
    return self
end

--// Initialize the icons and viewports for the shop when player joins
function shop:Init()
    --// Render the elements of each shop page
    for _, tab in pairs(footer:GetChildren()) do
        if tab:IsA("TextButton") then
            if tab.Name ~= "Gamepasses" then
                for item, _ in pairs(storeContainer[tab.Name]) do
                    local newPanel = self.panel:Clone()
                    newPanel.Parent = self.ui.ShopFrame.ShopBG[tab.Name]
                    viewport.new(game.ReplicatedStorage.ItemModels[item], newPanel.ViewportFrame, true)
                    shopPanels[item] =  newPanel
                end
            end
            --// Handle visual
            tab.MouseEnter:Connect(function()
                local tabTween = TweenService:Create(tab, TweenInfo.new(0.5), {TextSize = 43, BackgroundTransparency = 0, TextColor3 = Color3.fromRGB(114, 114, 114)})
                tabTween:Play()
            end)
            tab.MouseLeave:Connect(function()
                local tabTween = TweenService:Create(tab, TweenInfo.new(0.5), {TextSize = 40, BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(255, 255, 255)})
                tabTween:Play()
            end)
            --// Show the corresponding tab when a footer button is clicked
            tab.MouseButton1Click:Connect(function()
                tabs[tab.Name]()
            end)
        end
    end
 
    --// Get datastore of current day
    local function getDailyStoreData()
        return requestDailyStore:InvokeServer()
    end

    --[[Implement icons for daily store when jasper sends assets]]--

    --// Show the first data for the daily shop when player joins
    print(getDailyStoreData()[os.date("%j")])

    --// Handle the daily shop reset
    shopChange.OnClientEvent:Connect(function()
        print(getDailyStoreData()[os.date("%j")])
    end)

    --// Set the ui parent to the player and enable it
    self.ui.Parent = self.plr.PlayerGui
    self:Enable()
end

--// Make the shop visible and play animation
function shop:Render()
    if not self.debounce then
        --// Set currency to player's amount
        self.ui.ShopFrame.Currency:WaitForChild("Cash").Amount.Text = self.replicatedData:WaitForChild("Cash").Value

        --// Tween in the cash purchase element when rendered
        for _, element in pairs(self.ui.ShopFrame.Currency.Cash:GetChildren()) do
            local elementTween
            if element:IsA("TextButton") then
                elementTween = TweenService:Create(element, TweenInfo.new(0.5), {TextTransparency = 0, BackgroundTransparency = 0})
                elementTween:Play()
            elseif element:IsA("TextLabel") then
                elementTween = TweenService:Create(element, TweenInfo.new(0.5), {TextTransparency = 0})
                elementTween:Play()
            elseif element:IsA("ImageLabel") then
                elementTween = TweenService:Create(element, TweenInfo.new(0.5), {ImageTransparency = 0})
                elementTween:Play()
            end
        end

        --// Set the cash page's text when the user's cash amount changes
        self._maid:GiveTask(self.replicatedData.Cash.Changed:Connect(function()
            self.ui.ShopFrame.Currency.Cash.Amount.Text = self.replicatedData.Cash.Value
        end))

        --// If a user clicks the + button on the cash page, they are prompted with the dev products screen
        self._maid:GiveTask(self.ui.ShopFrame.Currency.Cash.BuyMore.MouseButton1Click:Connect(function()
            self._toggleCashPurchase:Fire(self.plr, true)
        end))

        --// Show the footer
        self.ui.ShopFrame.Footer.Visible = true
        --// Set debounce for opening the shop
        self.debounce = true
        --// Hide players
        for _, player in pairs(game.Players:GetPlayers()) do
            local char = player.Character or player.CharacterAdded:Wait()
            char.Parent = game.ReplicatedStorage
        end
        --// Show the UI and set it to open
        self.ui.Enabled = true
        self.open = true

        --// Tween camera to proper view
        local cameraTween = TweenService:Create(camera, TweenInfo.new(.5), {CFrame = CFrame.new(game.Workspace.StoreCamPart.Position, game.Workspace.Store.Position)})
        fovTween = TweenService:Create(camera, TweenInfo.new(.5), {FieldOfView = 32})
        cameraTween:Play()
        camera.CameraType = Enum.CameraType.Scriptable
        camera.Focus = game.Workspace.Store.CFrame
        cameraTween.Completed:Wait()

        --// Tween FOV to zoom it
        fovTween:Play()

        --// Tween in the beams
        for _, v in pairs(game.Workspace.Store:GetChildren()) do
            if v.Name == "Beam" then
                v.Enabled = true
                local beamTween = TweenService:Create(v, TweenInfo.new(.5), {LightInfluence = 0})
                beamTween:Play()
            end
        end

        --// Tween in UI elements of shop
        local frameTween = TweenService:Create(self.ui.ShopFrame, TweenInfo.new(.5), {BackgroundTransparency = 0.8})
        local headerTween = TweenService:Create(self.ui.ShopFrame.Header, TweenInfo.new(.5), {TextTransparency = 0})
        frameTween:Play()
        headerTween:Play()
        for _, element in pairs(self.ui.ShopFrame.Footer:GetChildren()) do
            if element:IsA("TextButton") then
                local footerTween = TweenService:Create(element, TweenInfo.new(0.5), {TextTransparency = 0})
                footerTween:Play()
            end
        end

        --// Show knives page by default
        self:ShowKnives()
        --// Wait for everything to tween in
        headerTween.Completed:Wait()
        --// Allow the user to close the shop
        self.debounce = false
        
        while self.open do
            --// Hide players here in future
            for _, player in pairs(game.Players:GetPlayers()) do
                local char = player.Character or player.CharacterAdded:Wait()
                char.Parent = game.ReplicatedStorage
            end

            local tapeA = game.Workspace.Lobby.Projector.TapeA
            local tapeB = game.Workspace.Lobby.Projector.TapeB
            local tapeATween = TweenService:Create(tapeA, TweenInfo.new(.1), {Orientation = tapeA.Orientation + Vector3.new(0,0,8)})
            local tapeBTween = TweenService:Create(tapeB, TweenInfo.new(.1), {Orientation = tapeB.Orientation + Vector3.new(0,0,5)})
            local beamInfluence = random:NextNumber(0, .45)
            --// Set the beams to flicker
            for _, beam in pairs(game.Workspace.Store:GetChildren()) do
                if beam.Name == "Beam" then
                    beam.LightInfluence = beamInfluence
                end
            end
            --// Rotate the tape parts
            tapeATween:Play()
            tapeBTween:Play()
            tapeBTween.Completed:Wait()
        end
    end
end

--// Plays the animation to to hide the shop
function shop:Derender()
    self.open = false
    --// Show characters again
    for _, player in pairs(game.Players:GetPlayers()) do
        local char = player.Character or player.CharacterAdded:Wait()
        char.Parent = workspace
    end
    --// Disable the beams
    for _, v in pairs(game.Workspace.Store:GetChildren()) do
        if v.Name == "Beam" then
            v.Enabled = false
        end
    end
    --// Hide purchase page if user has it open
    self.ui.ShopFrame.PurchasePage.Visible = false
    --// Hide UI elements
    self.ui.ShopFrame.BackgroundTransparency = 1
    self.ui.ShopFrame.Header.TextTransparency = 1
    for _, element in pairs(self.ui.ShopFrame.Footer:GetChildren()) do
        if element:IsA("TextButton") then
            element.TextTransparency = 1
        end
    end
    --// Reset camera view and field of view
    camera.CameraType = Enum.CameraType.Custom
    local character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
    camera.CameraSubject = character:WaitForChild("Humanoid")
    camera.FieldOfView = 70
    --// Disable the UI
    self.ui.Enabled = false
    --// Hide all pages
    self:HidePages()
    --// Allow the user to open the UI once again
    self.debounce = false
end

--// Prevents user from opening the shop
function shop:Disable()
    if self.enabled then
        self.enabled = false
        self._maid:DoCleaning()
        camera.FieldOfView = 70
        self.openButton.Parent = nil
        self:Derender()
        if fovTween then
            fovTween:Cancel()
        end
    end
end

--// Allows the user to open the shop
function shop:Enable()
    if not self.enabled then
        self.enabled = true
        self.openButton.Parent = self.plr.PlayerGui.GameUI
        self._maid:GiveTask(self.openButton.MouseButton1Click:Connect(function()
            if self.open and not self.debounce then
                self:Derender()
            else
                self:Render()
            end
        end))
    end
end

local function tweenOver(frame, direction)
    if direction == "in" then
        frame.Position = UDim2.fromScale(1,0)
        local tween = TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Position = UDim2.fromScale(0, 0)})
        tween:Play()
    else
        local tween = TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.fromScale(-1, 0)})
        tween:Play()
    end
end

--// Show the knives shop menu
function shop:ShowKnives()
    --// Convert string table into normal dictionary
    local data = HttpService:JSONDecode(repData.Knives.Value)
    --// Destroy any knives acquired between the last time the player opened the shop
    for _, item in pairs(data) do
        if shopPanels[item] then
            shopPanels[item]:Destroy()
        end
    end
    --// If player owns all knives show the empty label
    if #knives:GetChildren() == 2 then
        knives.EmptyLabel.Visible = true
    end
    --// Show knives page
    knives.Visible = true
    --// Tween away all other pages
    tweenOver(gamepasses)
    tweenOver(sprays)
    tweenOver(guns)
    --// Tween in knives page
    tweenOver(knives, "in")
end

--// Show the gun shop menu
function shop:ShowGuns()
    local data = HttpService:JSONDecode(repData.Guns.Value)
    for _, item in pairs(data) do
        if shopPanels[item] then
            shopPanels[item]:Destroy()
        end
    end

    guns.Visible = true
    tweenOver(knives)
    tweenOver(gamepasses)
    tweenOver(sprays)
    tweenOver(guns, "in")

    if #guns:GetChildren() == 2 then
        guns.EmptyLabel.Visible = true
    end
end

--// Show the gamepass shop menu
function shop:ShowGamepasses()
    gamepasses.Visible = true
    tweenOver(knives)
    tweenOver(guns)
    tweenOver(sprays)
    tweenOver(gamepasses, "in")

    if #gamepasses:GetChildren() == 2 then
        gamepasses.EmptyLabel.Visible = true
    end
end

--// Show the sprays shop menu
function shop:ShowSprays()
    local data = HttpService:JSONDecode(repData.Sprays.Value)
    for _, item in pairs(data) do
        if shopPanels[item] then
            shopPanels[item]:Destroy()
        end
    end

    sprays.Visible = true
    tweenOver(knives)
    tweenOver(gamepasses)
    tweenOver(guns)
    tweenOver(sprays, "in")

    if #sprays:GetChildren() == 2 then
        sprays.EmptyLabel.Visible = true
    end
end

--// Show the character shop menu
function shop:ShowCharacters()
    print("No functionality as of now.")
end

--// Hide all tabs
function shop:HidePages()
    knives.Visible = false
    guns.Visible = false
    gamepasses.Visible = false
    sprays.Visible = false
end

return shop