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
local disableProximity = events.DisableProximity

--// Objects
local _maid

local enableTable = {}

--Fires every frame
function proximity:Enable(plrList)
    _maid = maid.new()
    local murdererName = game.ServerStorage.MurdererValue.Value
    local murderer = Players:FindFirstChild(murdererName).Character or Players:FindFirstChild(murdererName).CharacterAdded:Wait()
    _maid:GiveTask(RunService.Stepped:Connect(function()
        for _, plr in pairs(plrList) do
            local distance = plr:DistanceFromCharacter(murderer.HumanoidRootPart.Position)
            if distance < 5 then
                if not table.find(enableTable, plr) then
                    enableProximity:FireClient(plr)
                end
            else
                disableProximity:FireClient(plr)
                for i, player in pairs(enableTable) do
                    if player == plr then
                        table.remove(enableTable, i)
                    end
                end
            end
        end
    end))
end

function proximity:Disable()
    disableProximity:FireAllClients()
    _maid:Destroy()
end

return proximity