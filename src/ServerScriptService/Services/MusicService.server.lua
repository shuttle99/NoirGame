--// Services
local Workspace = game:GetService("Workspace")

--// Folders
local music = Workspace.Music:GetChildren()

--// Init
local random = Random.new()
local songPlaying = Workspace.Music:FindFirstChild("FirstSong")

--// Play random audio
local function chooseSong()
    songPlaying = music[random:NextInteger(1, #music)]
    songPlaying:Play()
end

--// Connections
songPlaying.Ended:Connect(function()
    chooseSong()
end)

songPlaying:Play()