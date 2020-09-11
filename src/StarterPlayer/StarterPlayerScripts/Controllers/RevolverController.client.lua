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
local rayClear = events:WaitForChild("RayClear")

--// Variables
local plr = game.Players.LocalPlayer
local mouse = plr:GetMouse()
local camera = game.Workspace.CurrentCamera

--// Modules
local maid = require(shared:WaitForChild("Maid"))
local Draw = require(shared:WaitForChild("Draw"))

--// Maid init
local _maid = maid.new()

gunActivation.OnClientEvent:Connect(function(item, event)
	_maid:GiveTask(plr.CharacterRemoving:Connect(function()
		item:Destroy()
		_maid:DoCleaning()
	end))
	_maid:GiveTask(item.Equipped:Connect(function()
		mouse.Icon = "rbxgameasset://Images/88b6afb5ab51c20de57f17649d5ecfdf (2)"
	end))
	local debounce = false
	_maid:GiveTask(item.Activated:Connect(function()
		if not debounce then
			debounce = true
			local rayParams = RaycastParams.new()
			rayParams.FilterType = Enum.RaycastFilterType.Blacklist
			rayParams.FilterDescendantsInstances = {plr.Character}
			if item.Barrel ~= nil then
				local result = workspace:Raycast(plr.Character.HumanoidRootPart.Position, mouse.UnitRay.Direction * 3000, rayParams)
				if result then
					if result.Instance then
						event:FireServer(result.Instance)
					end
					--// Vector visualization
				Draw.vector(plr.Character.HumanoidRootPart.Position, (result.Position - plr.Character.HumanoidRootPart.Position), Color3.new(255, 255, 255), workspace.Rays, .35, .35)
				wait(.1)
				game.Workspace.Rays:ClearAllChildren()
			end
			--_maid:DoCleaning()
			end
			wait(2)
			debounce = false
		end
	end))
	_maid:GiveTask(item.Unequipped:Connect(function()
		mouse.Icon = ""
		--plr.CameraMode = Enum.CameraMode.Classic
		_maid.RenderChar = nil
	end))
end)