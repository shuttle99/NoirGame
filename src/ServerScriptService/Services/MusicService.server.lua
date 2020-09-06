--// Services
local Workspace = game:GetService("Workspace")

--// Folders
local music = Workspace.Music:GetChildren()

--// Init
local random = Random.new()
local songPlaying = Workspace.Music:FindFirstChild("FirstSong")

local connection

--// Play random audio
local function chooseSong()
    songPlaying = music[random:NextInteger(1, #music)]
    songPlaying:Play()
    connection = songPlaying.Ended:Connect(function()
        chooseSong()
        connection:Disconnect()
    end)
end

--// Connections
connection = songPlaying.Ended:Connect(function()
    chooseSong()
    connection:Disconnect()
end)

--// Init
songPlaying:Play()