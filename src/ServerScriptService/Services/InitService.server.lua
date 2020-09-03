--// Handles the initialization of modules when a player joins

--// Services
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

--// Folders
local Modules = ServerScriptService:WaitForChild("Modules")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local UIComponents = ReplicatedStorage:WaitForChild("UIComponents")
local UIEvents = UIComponents:WaitForChild("UIEvents")

--// Modules
local storeContainer = require(Shared:WaitForChild("StoreContainer"))
local roundHandler = require(Modules:WaitForChild("RoundHandler"))
local playerHandler = require(Modules:WaitForChild("PlayerHandler"))

--// Events
local shopInit = UIEvents:WaitForChild("ShopInit")

--// Init the store container from the server
storeContainer:Init()

--// Initialize player when they join
Players.PlayerAdded:Connect(function(player)
    print("Fired")
    playerHandler:RegisterPlayer(player)

    player.CharacterAdded:Connect(function(char)
        char.Humanoid.Died:Connect(function()
            roundHandler:RegisterDeath(player)
        end)
    end)

    shopInit:FireClient(player)
end)

Players.PlayerRemoving:Connect(function(player)
    roundHandler:RegisterDeath(player)
    roundHandler:RemovePlayer(player)
end)