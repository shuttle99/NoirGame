local PlayerHandler = {}
PlayerHandler.PlayerList = {}

--// Services
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Folders
local Modules = ServerScriptService:WaitForChild("Modules")
local Events = ReplicatedStorage:WaitForChild("Events")

--// Modules
local ds = require(Modules:WaitForChild("Init"))

--// Events
local TogglePlayerInGame = Events:WaitForChild("TogglePlayerInGame")

function PlayerHandler:RegisterPlayer(player)
    ds.new(player)
    table.insert(PlayerHandler.PlayerList, player)
end

function PlayerHandler:TogglePlayer(player)
    if table.find(PlayerHandler.PlayerList, player) then
        table.remove(PlayerHandler.PlayerList, table.find(PlayerHandler.PlayerList, player))
    else
        table.insert(PlayerHandler.PlayerList, player)
    end
end

--// Remove player from list if they choose to go AFK
TogglePlayerInGame.OnServerEvent:Connect(function(player)
    PlayerHandler:TogglePlayer(player)
end)

return PlayerHandler