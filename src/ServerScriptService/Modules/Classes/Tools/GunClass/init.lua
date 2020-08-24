local gunClass = {}
gunClass.__index = gunClass

--// Services
local replicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

--// Modules
local raycaster = require(script.Raycaster)
local data = require(game.ServerScriptService.Modules:WaitForChild("Init"))
local maid = require(game.ReplicatedStorage.Shared.Maid)

--// Folders
local replicatedAssets = replicatedStorage.ItemModels
local events = replicatedStorage.Events
local assets = ServerStorage:WaitForChild("Assets")
local items = assets:WaitForChild("Items")
local vigilante = items:WaitForChild("Vigilante")

--//Events
local setRole = events.SetRole
local gunShot = events.GunShot
local gunShotServer = events.GunShotServer

--// Connections
local eventConnection

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
	
	self._maid:GiveTask(self.item.Activated:Connect(function()
		if not self.debounce then
			self.debounce = true
			fireAnim:Play()
			gunShot:FireClient(self.plr, self.item)
			eventConnection = gunShotServer.OnServerEvent:Connect(function(plr, mousePos)
				print("Here is wehre it's stacking")
				raycaster:CastRay(self.item.Barrel.Position, mousePos, self.item, plr, true)
				eventConnection:Disconnect()
			end)
			wait(2)
			self.debounce = false
		end
	end))
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
