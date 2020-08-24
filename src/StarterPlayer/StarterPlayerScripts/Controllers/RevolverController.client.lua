--// Services
local replicatedStorage = game:GetService("ReplicatedStorage")

--// Folders
local events = replicatedStorage:WaitForChild("Events")

--// Events
local gunShot = events.GunShot
local gunShotServer = events.GunShotServer

--// Variables
local plr = game.Players.LocalPlayer
local mouse = plr:GetMouse()


--// Event handlers
gunShot.OnClientEvent:Connect(function(item)
	gunShotServer:FireServer(mouse.Hit.p)
end)