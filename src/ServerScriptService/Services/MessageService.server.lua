--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Modules
local chatRunner = game.ServerScriptService:WaitForChild("ChatServiceRunner")
local chatService = require(chatRunner:WaitForChild("ChatService"))

--// Folders
local events = ReplicatedStorage:WaitForChild("Events")

--// Events
local giveTag = events:WaitForChild("GiveTag")


giveTag.Event:Connect(function(plr)
    local speaker = chatService:GetSpeaker(plr.Name)
    speaker:SetExtraData("Tags", {{TagText = "VIP", TagColor = Color3.new(1, 0, 0)}})
end)