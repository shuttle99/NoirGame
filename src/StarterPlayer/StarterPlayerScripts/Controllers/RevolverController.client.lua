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
gunActivation.OnClientEvent:Connect(function(item, event)
	_maid:GiveTask(plr.CharacterRemoving:Connect(function()
		item:Destroy()
		_maid:DoCleaning()
	end))
	--[[_maid:GiveTask(item.Equipped:Connect(function()
		mouse.Icon = "rbxassetid://5613409376"
	end))]]
	_maid:GiveTask(item.Activated:Connect(function()
		event:FireServer(mouse.UnitRay)
		--_maid:DoCleaning()
	end))
	_maid:GiveTask(item.Unequipped:Connect(function()
		mouse.Icon = ""
	end))
end)