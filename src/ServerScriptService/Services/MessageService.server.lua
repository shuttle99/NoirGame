--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

--// Folders
local events = ReplicatedStorage:WaitForChild("Events")
local modules = ServerScriptService:WaitForChild("Modules")

--// Modules
local chatRunner = game.ServerScriptService:WaitForChild("ChatServiceRunner")
local chatService = require(chatRunner:WaitForChild("ChatService"))

chatService.SpeakerAdded:Connect(function(speakerAdded)
    local plr = game.Players:FindFirstChild(speakerAdded)
    local speaker = chatService:GetSpeaker(speakerAdded)
    if plr:FindFirstChild("VIP") then
        speaker:SetExtraData("Tags", {{TagText = "VIP", TagColor = Color3.new(1, 0, 0)}})
    end
    if plr:FindFirstChild("Golden") then
        speaker:SetExtraData("Tags", {{TagText = "GOLDEN", TagColor = Color3.fromRGB(255, 166, 0)}})
    end
end)