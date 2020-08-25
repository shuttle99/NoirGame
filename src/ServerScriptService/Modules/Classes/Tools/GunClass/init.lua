local gunClass = {}
gunClass.__index = gunClass

--// Services
local replicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

--// Modules
local data = require(game.ServerScriptService.Modules:WaitForChild("Init"))
local maid = require(game.ReplicatedStorage.Shared.Maid)
local Draw = require(game.ReplicatedStorage.Shared.Draw)

--// Folders
local replicatedAssets = replicatedStorage.ItemModels
local events = replicatedStorage.Events
local assets = ServerStorage:WaitForChild("Assets")
local items = assets:WaitForChild("Items")
local vigilante = items:WaitForChild("Vigilante")

--//Events
local setRole = events.SetRole
local gunActivation = events.GunActivation
local gunShotServer = events.GunShotServer

function gunClass.new(plr)
	local self = setmetatable({
		plr = plr,
		dataObj = nil,
		murderer = game.ServerStorage.MurdererValue,
		item = "",
		debounce = false,

		_maid = maid.new()
	}, gunClass)
	
	if data:Get(plr) then
		self.dataObj = data.new(plr)
	else
		self.dataObj = data:Get(plr)
	end

	self.item = vigilante[self.dataObj["EquippedGun"]:Get()]:Clone()
	
	return self
end

function gunClass:Activate()
	local char = self.plr.Character
	self.item.Parent = self.plr.Backpack
	
	local idle = char.Humanoid:LoadAnimation(self.item.PistolIdle)
	local fireAnim = char.Humanoid:LoadAnimation(self.item.GunFireAnim)
	
	self._maid:GiveTask(self.item.Equipped:Connect(function()
		idle:Play()
	end))
	
	self._maid:GiveTask(self.item.Unequipped:Connect(function()
		idle:Stop()
	end))
	
	gunActivation:FireClient(self.plr, self.item)

	gunShotServer.OnServerInvoke = function(plr, mousePos)
		Draw.vector(self.item.Barrel.Position, mousePos, Color3.new(255, 255, 255), workspace.Rays, .25)
	end
end

function gunClass:DropItem(pos)
	local replicatedItemModel = replicatedAssets[self.item.Name]:Clone()
	replicatedItemModel.Parent = game.Workspace.Drops
	replicatedItemModel:SetPrimaryPartCFrame(CFrame.new(pos))
	replicatedItemModel.Handle.Touched:Connect(function(hit)
		if hit.Parent:FindFirstChild("Humanoid") then
			if hit.Parent.Name ~= self.plr.Name and hit.Parent.Name ~= self.murderer.Value then
				if #game.Players:GetPlayerFromCharacter(hit.Parent).Backpack:GetChildren() == 0 then
					setRole:Fire("Vigilante", game.Players:GetPlayerFromCharacter(hit.Parent))
					replicatedItemModel:Destroy()
					self._maid:Destroy()
				end
			end
		end
	end)
end

function gunClass:Destroy()
	self._maid:Destroy()
	self.item:Destroy()
end


return gunClass
