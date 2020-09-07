--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

--// Folders
local Events = ReplicatedStorage:WaitForChild("Events")
local Shared = ReplicatedStorage:WaitForChild("Shared")

--// Events
local ToggleJump = Events:WaitForChild("ToggleJump")

--// Module
local Maid = require(Shared:WaitForChild("Maid"))

--// Variables
local player = Players.LocalPlayer
local isJumping = false
local _maid = Maid.new()

--// Event Connections
ToggleJump.OnClientEvent:Connect(function(enabled)
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    if enabled then
        _maid:GiveTask(humanoid.StateChanged:Connect(function(oldState, newState)
            print("State changed")
            if newState == Enum.HumanoidStateType.Jumping then
                if not isJumping then
                    isJumping = true
                    print("Disable jump")
                    humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
                end
            elseif newState == Enum.HumanoidStateType.Landed then
                if isJumping then
                    isJumping = false
                    wait(.7)
                    humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
                end
            end
        end))
    else
        _maid:DoCleaning()
    end
end)