local spectate = {}
spectate.__index = spectate

--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

--// Folders
local uiComponents = ReplicatedStorage:WaitForChild("UIComponents")
local uiEvents = uiComponents:WaitForChild("UIEvents")
local shared = ReplicatedStorage:WaitForChild("Shared")

--// Modules
local maid = require(shared:WaitForChild("Maid"))

--// Events
local enableShop = uiEvents:WaitForChild("BindedShopEnable")
local disableShop = uiEvents:WaitForChild("BindedShopDisable")

--// Camera
local camera = workspace.CurrentCamera


function spectate.new(plr, plrList)
    local self = setmetatable({
        plr = plr,
        ui = uiComponents:WaitForChild("SpectateUI"):Clone(),
        button = uiComponents:WaitForChild("SpectateButton"):Clone(),
        plrList = plrList,
        iterator = 1,

        _maid = maid.new()
    }, spectate)

    for i, player in pairs(plrList) do
        if player.Name == self.plr.Name then
            table.remove(plrList, i)
        end
    end

    return self
end

function spectate:SetCameraView(character)
    camera.CameraSubject = character.Humanoid
    self.ui.CharacterLabel.Text = character.Name
end

--// Allows the player to spectate
function spectate:Enable()
    --// Make button Visible
    self.button.Parent = self.plr.PlayerGui.GameUI
    self.ui.Parent = self.plr.PlayerGui.GameUI

    --// Render main UI
    self._maid:GiveTask(self.button.MouseButton1Click:Connect(function()
        self:Render()
    end))
end

--// Turns off spectate UI and spectate button
function spectate:Disable()
    --// Derender ui
    self:Derender()
    --// Make button invisible 
    self.button.Parent = nil
end

--// Makes UI visual
function spectate:Render()
    --// Make Spectate UI Visible
    self.ui.Visible = true
    self.button.Parent = nil

    disableShop:Fire()

    self:SetCameraView(self.plrList[self.iterator].Character or self.plrList[self.iterator].CharacterAdded:Wait())

    --//Handle left button clicked
    self._maid:GiveTask(self.ui.LeftButton.MouseButton1Click:Connect(function()
        if self.iterator - 1 < 1 then
            self.iterator = #self.plrList
        else
            self.iterator -= 1 
        end
        self:SetCameraView(self.plrList[self.iterator].Character or self.plrList[self.iterator].CharacterAdded:Wait())
    end))

    self._maid.KeyboardConnection = UserInputService.InputBegan:Connect(function(inputObject)
        if inputObject.UserInputType == Enum.UserInputType.Keyboard then
            if inputObject.KeyCode.Name == "Q" then
                if self.iterator - 1 < 1 then
                    self.iterator = #self.plrList
                else
                    self.iterator -= 1 
                end
                self:SetCameraView(self.plrList[self.iterator].Character or self.plrList[self.iterator].CharacterAdded:Wait())
            elseif inputObject.KeyCode.Name == "E" then
                if self.iterator + 1 > #self.plrList then
                    self.iterator = 1
                else
                    self.iterator += 1
                end
                self:SetCameraView(self.plrList[self.iterator].Character or self.plrList[self.iterator].CharacterAdded:Wait())
            end
        end
    end)

    --//Handle right button clicked
    self._maid:GiveTask(self.ui.RightButton.MouseButton1Click:Connect(function()
        if self.iterator + 1 > #self.plrList then
            self.iterator = 1
        else
            self.iterator += 1
        end
        self:SetCameraView(self.plrList[self.iterator].Character or self.plrList[self.iterator].CharacterAdded:Wait())
    end))

    --//Handle right button clicked
    self._maid:GiveTask(self.ui.ExitButton.MouseButton1Click:Connect(function()
        --// Hide the ui
        self:Derender()
    end))
end

--// Hide spectate UI
function spectate:Derender()
    enableShop:Fire()
    --// Make spectate UI invisible
    self.ui.Visible = false

    --// Make button visible
    self.button.Parent = self.plr.PlayerGui.GameUI

    --// Fix camera
    camera.CameraSubject = self.plr.Character.Humanoid

    self._maid.KeyboardConnection = nil
end

function spectate:Destroy()
    self:Disable()
    self._maid:Destroy()
end

function spectate:RemovePlayer(plrToRemove)
    --// If player leaves then they are nil so fix this
    if plrToRemove ~= nil then
        if self.plrList[self.iterator].Name == plrToRemove.Name then
            if self.iterator + 1 > #self.plrList then
                self.iterator = 1
            else
                self.iterator += 1
            end
            if self.ui.Visible then
                self:SetCameraView(self.plrList[self.iterator].Character or self.plrList[self.iterator].CharacterAdded:Wait())
            end
        end
        
        for i, v in pairs(self.plrList) do
            if v.Name == plrToRemove.Name then
                table.remove(self.plrList, i)
            end
        end
    end
end

--// Just do it bro
return spectate