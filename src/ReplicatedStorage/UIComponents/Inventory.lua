local inventory = {}
inventory.__index = inventory

--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

--// Folders
local shared = ReplicatedStorage:WaitForChild("Shared")
local events = ReplicatedStorage:WaitForChild("Events")
local replicatedData = ReplicatedStorage:WaitForChild("ReplicatedData")
local itemModels = ReplicatedStorage:WaitForChild("ItemModels")
local uiComponents = ReplicatedStorage:WaitForChild("UIComponents")
local uiEvents = uiComponents:WaitForChild("UIEvents")
local toggleGold = uiEvents:WaitForChild("ToggleGold")

--// Modules
local viewport = require(shared:WaitForChild("ViewportClass"))
local storeContainer = require(shared:WaitForChild("StoreContainer"))
local maid = require(shared:WaitForChild("Maid"))

--// Viewports
local equippedKnifeFrame
local equippedGunFrame
local equippedSprayFrame

--// Remote Functions
local checkItem = events:WaitForChild("CheckForItemOwned")

--// Remote events


--// Tab functions
local tabFuncs

--//Globals
local knives
local guns
local sprays
local boosts

function inventory.new(plr)
    local self = setmetatable({
        plr = plr,
        ui = script.Parent.InventoryFrame:Clone(),
        panel = script.Parent:WaitForChild("InventoryPanel"),
        plrData = replicatedData:WaitForChild(plr.UserId),
        openButton = script.Parent.InventoryOpenButton:Clone(),
        _maid = maid.new()

        --// Add lighting effects

    }, inventory)

    knives = self.ui.InventoryBG.Knives
    guns = self.ui.InventoryBG.Guns
    sprays = self.ui.InventoryBG.Sprays
    boosts = self.ui.InventoryBG.Boosts

    tabFuncs = {
        ["Knives"] = function()self:ShowKnives() end,
        ["Guns"] = function()self:ShowGuns() end,
        ["Sprays"] = function()self:ShowSprays() end,
        ["Boosts"] = function()self:ShowGamepasses() end
    }

    equippedKnifeFrame = viewport.new(itemModels:WaitForChild(self.plrData:WaitForChild("EquippedKnife").Value), self.ui.KnivesFrame.ItemFrame, true)
    equippedSprayFrame = viewport.new(itemModels:WaitForChild(self.plrData:WaitForChild("EquippedSpray").Value), self.ui.SpraysFrame.ItemFrame, true)
    equippedGunFrame = viewport.new(itemModels:WaitForChild(self.plrData:WaitForChild("EquippedGun").Value), self.ui.GunsFrame.ItemFrame, true)

    self:Init()

    return self
end

--// To do
function inventory:Init()
    self.ui.Position = UDim2.new(-1, 0, 0.252, 0)
    self.ui.Parent = self.plr.PlayerGui:WaitForChild("GameUI")
    for _, tab in pairs(self.ui.Footer:GetChildren()) do
        if tab.Name ~= "Boosts" then
            local decodedData = HttpService:JSONDecode(self.plrData:WaitForChild(tab.Name).Value)
            for _, item in pairs(decodedData) do
                local newPanel = self.panel:Clone()
                newPanel.Parent = self.ui.InventoryBG:WaitForChild(tab.Name)
                viewport.new(itemModels[item], newPanel.ViewportFrame, true)
            end
        end
        tab.MouseButton1Click:Connect(function()
            tabFuncs[tab.Name]()
        end)
    end

    local function toggleGolden(frame, enabled, category)
        if enabled then
            toggleGold:InvokeServer(enabled, category)
            frame.Text = "X"
        else
            toggleGold:InvokeServer(enabled, category)
            frame.Text = ""
        end
    end

    --// Edit whether or not the player has golden weapons
    self._maid:GiveTask(self.ui.GunsFrame.GoldCheck.MouseButton1Click:Connect(function()
        print("Click")
        if self.plrData.GoldenGun.Value == true then 
            toggleGolden(self.ui.GunsFrame.GoldCheck, false, "Gun") 
        else 
            toggleGolden(self.ui.GunsFrame.GoldCheck, true, "Gun") 
        end
    end))
    
    self._maid:GiveTask(self.ui.SpraysFrame.GoldCheck.MouseButton1Click:Connect(function()
        if self.plrData.GoldenGun.Value == true then 
            toggleGolden(self.ui.SpraysFrame.GoldCheck, false, "Spray") 
        else 
            toggleGolden(self.ui.SpraysFrame.GoldCheck, true, "Spray") 
        end
    end))

    self._maid:GiveTask(self.ui.KnivesFrame.GoldCheck.MouseButton1Click:Connect(function()
        if self.plrData.GoldenKnife.Value == true then 
            toggleGolden(self.ui.KnivesFrame.GoldCheck, false, "Knife") 
        else 
            toggleGolden(self.ui.KnivesFrame.GoldCheck, true, "Knife") 
        end
    end))

    self:Enable()
end

function inventory:Render()
    self.ui.Visible = true
    local tweenInventoryIn = TweenService:Create(self.ui, TweenInfo.new(.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.new(0.221, 0,0.252, 0)})
    tweenInventoryIn:Play()

    self._maid:GiveTask(self.ui.ExitButton.MouseButton1Click:Connect(function()
        self:Derender()
    end))

    self:ShowKnives()
end

function inventory:Derender()
    local tweenInventoryOut = TweenService:Create(self.ui, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.new(-1, 0, 0.252,0)})
    tweenInventoryOut:Play()
    tweenInventoryOut.Completed:Wait()
    self.ui.Visible = false

    knives.Visible = false
    guns.Visible = false
    sprays.Visible = false 
    boosts.Visible = false
end

function inventory:Enable()
    self.openButton.Parent = self.plr.PlayerGui.GameUI
    --[[self._maid:GiveTask(self.openButton.MouseButton1Click:Connect(function()
        if self.ui.Visible == true then
            self:Derender()
        elseif self.ui.Visible == false then
            self:Render()
        end
    end))]]
    self.openButton.MouseButton1Click:Connect(function()
        self:Render()
    end)
end

function inventory:Disable()
    self.openButton.Parent = nil
    self:Derender()
end

function inventory:ShowKnives()
    knives.Visible = true
    guns.Visible = false
    sprays.Visible = false
    boosts.Visible = false

    for _, button in pairs(knives:GetChildren()) do
        if button:IsA("TextButton") then
            button.MouseButton1Click:Connect(function()
                if checkItem:InvokeServer(button.ViewportFrame:FindFirstChildOfClass("Model").Name) then
                    local itemToEquip = button.ViewportFrame:FindFirstChildOfClass("Model")
                    equippedKnifeFrame:Derender()
                    equippedKnifeFrame = viewport.new(itemToEquip, self.ui:WaitForChild("KnivesFrame").ItemFrame, true)
                end
            end)
        end
    end
end

function inventory:ShowSprays()
    knives.Visible = false
    guns.Visible = false
    sprays.Visible = true
    boosts.Visible = false

    for _, button in pairs(sprays:GetChildren()) do
        if button:IsA("TextButton") then
            button.MouseButton1Click:Connect(function()
                if checkItem:InvokeServer(button.ViewportFrame:FindFirstChildOfClass("Model").Name) then
                    local itemToEquip = button.ViewportFrame:FindFirstChildOfClass("Model")
                    equippedSprayFrame:Derender()
                    equippedSprayFrame = viewport.new(itemToEquip, self.ui:WaitForChild("SpraysFrame").ItemFrame, true)
                end
            end)
        end
    end
end

function inventory:ShowGuns()
    knives.Visible = false
    guns.Visible = true
    sprays.Visible = false
    boosts.Visible = false

    for _, button in pairs(guns:GetChildren()) do
        if button:IsA("TextButton") then
            button.MouseButton1Click:Connect(function()
                if checkItem:InvokeServer(button.ViewportFrame:FindFirstChildOfClass("Model").Name) then
                    local itemToEquip = button.ViewportFrame:FindFirstChildOfClass("Model")
                    equippedGunFrame:Derender()
                    equippedGunFrame = viewport.new(itemToEquip, self.ui:WaitForChild("GunsFrame").ItemFrame, true)
                end
            end)
        end
    end
end

function inventory:ShowGamepasses()
    print("Doesn't do much")
end

return inventory