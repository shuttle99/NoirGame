--[[
	Handles visual effects of the gun
]]

--// Services
local replicatedStorage = game:GetService("ReplicatedStorage")

--// Folders
local events = replicatedStorage:WaitForChild("Events")
local shared = replicatedStorage:WaitForChild("Shared")

--// Events
local gunActivation = events:WaitForChild("GunActivation")
local gunShotServer = events.GunShotServer

--// Variables
local plr = game.Players.LocalPlayer
local mouse = plr:GetMouse()

--// Modules
local maid = require(shared:WaitForChild("Maid"))

--// Maid init
local _maid = maid.new()

--// Event handlers
_maid:GiveTask(gunActivation.OnClientEvent:Connect(function(item, event)
	mouse.Icon = "rbxassetId://5518924110"
	_maid:GiveTask(item.Activated:Connect(function()
		event:InvokeServer(mouse.UnitRay)
		--_maid:DoCleaning()
	end))
end))