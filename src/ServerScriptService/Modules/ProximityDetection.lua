local proximity = {}

--// Services
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

--// Folders
local shared = ReplicatedStorage.Shared
local events = ReplicatedStorage.Events

--// Modules
local maid = require(shared.Maid)

--// Events
local enableProximity = events.EnableProximity
local disableProximity = events.EnableProximity

--// Objects
local _maid

--Fires every frame
function proximity:Enable(plrList)
    _maid = maid.new()
    local murdererName = game.ServerStorage.MurdererValue.Value
    local murderer = Players:FindFirstChild(murdererName).Character or Players:FindFirstChild(murdererName).CharacterAdded:Wait()
    _maid:GiveTask(RunService.Stepped:Connect(function()
        for _, plr in pairs(plrList) do
            local distance = plr:DistanceFromCharacter(murderer.HumanoidRootPart.Position)
            if distance < 50 then
                enableProximity:FireClient(plr)
            else 
                disableProximity:FireClient(plr)
            end
        end
    end))
end

function proximity:Disable()
    disableProximity:FireAllClients()
    _maid:Destroy()
end

return proximity