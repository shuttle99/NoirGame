local shop = {}
shop.__index = shop

--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
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

    repData = ReplicatedStorage:WaitForChild("ReplicatedData"):WaitForChild(self.plr.UserId)
    knives = self.ui.ShopFrame.ShopBG.Knives
    guns = self.ui.ShopFrame.ShopBG.Guns
    sprays = self.ui.ShopFrame.ShopBG.Sprays
    gamepasses = self.ui.ShopFrame.ShopBG.Gamepasses
    footer = self.ui.ShopFrame.Footer

    self:Init()

    for _, item in pairs(gamepasses:GetChildren()) do
        if item:IsA("Frame") then
            if MarketplaceService:UserOwnsGamePassAsync(plr.UserId, item.GamepassID.Value) then
                item:Destroy()
            else
                item:WaitForChild("PurchaseButton").MouseButton1Click:Connect(function()
                    MarketplaceService:PromptGamePassPurchase(plr, item.GamepassID.Value)
                end)
            end
        end
    end

    gamepasses.ChildRemoved:Connect(function()
        if #gamepasses:GetChildren() == 2 then
            gamepasses.EmptyLabel.Visible = true
        end
    end)

    gamepassPurchase.OnClientEvent:Connect(function(id)
        print("Purchase")
        for _, item in pairs(gamepasses:GetChildren()) do
            if item:FindFirstChild("GamepassID") then
                print(id)
                print(item.GamepassID.Value)
                if tostring(item.GamepassID.Value) == tostring(id) then
                    item:Destroy()
                end
            end
        end
    end)

    for itemName, itemPanel in pairs(shopPanels) do
        itemPanel.MouseButton1Click:Connect(function()
            --// Check for gamepass tag, if so prompt purchase not purchase screen
            for i, category in pairs(storeContainer) do
                if category[itemName] then
                    if not category[itemName].Gamepass then
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

                        --// Handle clicks on the purchase PurchasePage
                        connection = purchasePage.InfoFrame.PurchaseButton.MouseButton1Click:Connect(function()
                            if events.ItemPurchase:InvokeServer(i, itemName) then
                                local clonePanel = invPanel:Clone()
                                clonePanel.Parent = self.plr.PlayerGui.GameUI.InventoryFrame.InventoryBG[i]
                                viewport.new(itemModels[itemName], clonePanel.ViewportFrame, true)
                                purchasePage.InfoFrame.PurchaseButton.Text = "Item Purchased!"
                            end
                        end)
                    --// Item requires gamepasses
                    else
                        MarketplaceService:PromptGamePassPurchase(plr, category[itemName].Gamepass)
                    end
                end
            end
        end)
    end
    return self
end

--// USE A MAID IN UR CODE TO MANAGE MEMORY LEAKS
--// Initialize the icons and viewports for the shop when player joins
function shop:Init()
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
            tab.MouseButton1Click:Connect(function()
                tabs[tab.Name]()
            end)
        end
    end

    self.ui.Parent = self.plr.PlayerGui
    self:Enable()
end

--// Make the shop visible and play animation
function shop:Render()
    if not self.debounce then

        --// Set currency to player's amount
        self.ui.ShopFrame.Currency:WaitForChild("Cash").Amount.Text = self.replicatedData:WaitForChild("Cash").Value

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

        self._maid:GiveTask(self.replicatedData.Cash.Changed:Connect(function()
            self.ui.ShopFrame.Currency.Cash.Amount.Text = self.replicatedData.Cash.Value
        end))

        self._maid:GiveTask(self.ui.ShopFrame.Currency.Cash.BuyMore.MouseButton1Click:Connect(function()
            self._toggleCashPurchase:Fire(self.plr, true)
        end))

        self.ui.ShopFrame.Footer.Visible = true
        self.debounce = true
        for _, player in pairs(game.Players:GetPlayers()) do
            local char = player.Character or player.CharacterAdded:Wait()
            char.Parent = game.ReplicatedStorage
        end

        self.ui.Enabled = true
        self.open = true
        local cameraTween = TweenService:Create(camera, TweenInfo.new(.5), {CFrame = CFrame.new(game.Workspace.StoreCamPart.Position, game.Workspace.Store.Position)})
        fovTween = TweenService:Create(camera, TweenInfo.new(.5), {FieldOfView = 32})
        cameraTween:Play()
        camera.CameraType = Enum.CameraType.Scriptable
        camera.Focus = game.Workspace.Store.CFrame
        cameraTween.Completed:Wait()
        fovTween:Play()
        for _, v in pairs(game.Workspace.Store:GetChildren()) do
            if v.Name == "Beam" then
                v.Enabled = true
                local beamTween = TweenService:Create(v, TweenInfo.new(.5), {LightInfluence = 0})
                beamTween:Play()
            end
        end

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

        self:ShowKnives()
        headerTween.Completed:Wait()
        self.debounce = false

        while self.open do
            --// Hide players here in future
            for _, player in pairs(game.Players:GetPlayers()) do
                local char = player.Character or player.CharacterAdded:Wait()
                char.Parent = game.ReplicatedStorage
            end

            local tapeA = game.Workspace.Projector.TapeA
            local tapeB = game.Workspace.Projector.TapeB
            local tapeATween = TweenService:Create(tapeA, TweenInfo.new(.1), {Orientation = tapeA.Orientation + Vector3.new(0,0,8)})
            local tapeBTween = TweenService:Create(tapeB, TweenInfo.new(.1), {Orientation = tapeB.Orientation + Vector3.new(0,0,5)})
            local beamInfluence = random:NextNumber(0, .45)
            for _, beam in pairs(game.Workspace.Store:GetChildren()) do
                if beam.Name == "Beam" then
                    beam.LightInfluence = beamInfluence
                end
            end
            tapeATween:Play()
            tapeBTween:Play()
            tapeBTween.Completed:Wait()
        end
    end
end

--// Plays the animation to to hide the shop
function shop:Derender()
    self.open = false
    for _, player in pairs(game.Players:GetPlayers()) do
        local char = player.Character or player.CharacterAdded:Wait()
        char.Parent = workspace
    end

    for _, v in pairs(game.Workspace.Store:GetChildren()) do
        if v.Name == "Beam" then
            v.Enabled = false
        end
    end
    self.ui.ShopFrame.PurchasePage.Visible = false
    self.ui.ShopFrame.BackgroundTransparency = 1
    self.ui.ShopFrame.Header.TextTransparency = 1
    for _, element in pairs(self.ui.ShopFrame.Footer:GetChildren()) do
        if element:IsA("TextButton") then
            element.TextTransparency = 1
        end
    end
    camera.CameraType = Enum.CameraType.Custom
    local character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
    camera.CameraSubject = character:WaitForChild("Humanoid")
    camera.FieldOfView = 70
    self.ui.Enabled = false
    self:HidePages()
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
        --camera.FieldOfView = 70
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
                --connection:Disconnect()
            else
                self:Render()
                --connection:Disconnect()
            end
            --connection:Disconnect()
        end))
    end
end

--// Show the knives shop menu
function shop:ShowKnives()
    local data = HttpService:JSONDecode(repData.Knives.Value)
    for _, item in pairs(data) do
        if shopPanels[item] then
            shopPanels[item]:Destroy()
        end
    end
    knives.Visible = true
    guns.Visible = false
    gamepasses.Visible = false
    sprays.Visible = false
    if #knives:GetChildren() == 2 then
        knives.EmptyLabel.Visible = true
    end
end

--// Show the gun shop menu
function shop:ShowGuns()
    local data = HttpService:JSONDecode(repData.Guns.Value)
    for _, item in pairs(data) do
        if shopPanels[item] then
            shopPanels[item]:Destroy()
        end
    end
    knives.Visible = false
    guns.Visible = true
    gamepasses.Visible = false
    sprays.Visible = false

    if #guns:GetChildren() == 2 then
        guns.EmptyLabel.Visible = true
    end
end

--// Show the gamepass shop menu
function shop:ShowGamepasses()
    knives.Visible = false
    guns.Visible = false
    gamepasses.Visible = true
    sprays.Visible = false
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
    knives.Visible = false
    guns.Visible = false
    gamepasses.Visible = false
    sprays.Visible = true
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