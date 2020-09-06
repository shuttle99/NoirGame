--[[
	Handles visual effects of the gun
]]

--// Services
local replicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

--// Folders
local events = replicatedStorage:WaitForChild("Events")
local shared = replicatedStorage:WaitForChild("Shared")

--// Events
local gunActivation = events:WaitForChild("GunActivation")

--// Variables
local plr = game.Players.LocalPlayer
local mouse = plr:GetMouse()
local camera = game.Workspace.CurrentCamera

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
	_maid:GiveTask(item.Equipped:Connect(function()
		mouse.Icon = "rbxgameasset://Images/88b6afb5ab51c20de57f17649d5ecfdf (2)"
	end))
	_maid:GiveTask(item.Activated:Connect(function()
		event:FireServer(mouse.UnitRay)
		--_maid:DoCleaning()
	end))
	_maid:GiveTask(item.Unequipped:Connect(function()
		mouse.Icon = ""
		--plr.CameraMode = Enum.CameraMode.Classic
		_maid.RenderChar = nil
	end))
end)