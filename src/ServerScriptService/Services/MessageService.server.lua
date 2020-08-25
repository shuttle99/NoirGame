--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

--// Folders
local events = ReplicatedStorage:WaitForChild("Events")
local modules = ServerScriptService:WaitForChild("Modules")

--// Modules
local chatRunner = game.ServerScriptService:WaitForChild("ChatServiceRunner")
local chatService = require(chatRunner:WaitForChild("ChatService"))
local gamepasses = require(modules:WaitForChild("Gamepasses"))


--// Events
local giveTag = events:WaitForChild("GiveTag")

giveTag.Event:Connect(function(plr)
    print("Connected to speaker event")
    local speaker = chatService:GetSpeaker(plr.Name)
    speaker:SetExtraData("Tags", {{TagText = "VIP", TagColor = Color3.new(1, 0, 0)}})
end)