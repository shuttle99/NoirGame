--// Services
local ServerStorage = game:GetService("ServerStorage")

--// Folders
local music = ServerStorage.Music:GetChildren()

--// Init
local random = Random.new()
local songPlaying

--// Play random audio
local function chooseSong()
    songPlaying = music[random:NextInteger(1, #music)]
    songPlaying:Play()
end

--// Connections
songPlaying.Ended:Connect(function()
    chooseSong()
end)

--// Play the first sound
chooseSong()