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
		dataObj = data:Get(plr) or data.new(plr),
		murderer = game.ServerStorage.MurdererValue,
		item = "",
		debounce = false,

		_event = Instance.new("RemoteEvent"),
		_maid = maid.new()
	}, gunClass)
	
	self._event.Parent = events

	self.item = vigilante[self.dataObj.EquippedGun:Get()]:Clone()
	if self.dataObj.GoldenGun:Get() == true then
		for _, part in pairs(self.item:GetDescendants()) do
			if part:IsA("BasePart") then
				part.Color = Color3.fromRGB(249, 166, 2)
			end
			if part:IsA("MeshPart") then
				part.TextureID = ""
			end
		end
	end
	
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
	
	--// Record item activation on client
	gunActivation:FireClient(self.plr, self.item, self._event)

	--// Fire the ray
	self._maid:GiveTask(self._event.OnServerEvent:Connect(function(plr, result)
		if not self.debounce then
			self.debounce = true
			if result then
				if result.Parent:FindFirstChild("Humanoid") then
					if result.Parent.Name == ServerStorage.MurdererValue.Value then
						result.Parent.Humanoid.Health = 0
					end
				end
			end
			fireAnim:Play()
			self.item.Barrel.GunshotSound:Play()
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
			if hit.Parent.Name ~= self.plr.Name and hit.Parent.Name ~= self.murderer.Value and hit.Parent.Humanoid.Health > 0 then
				setRole:Fire("Vigilante", game.Players:GetPlayerFromCharacter(hit.Parent))
				replicatedItemModel:Destroy()
				if self._event then
					self._event:Destroy()
				end
				self._maid:Destroy()
			end
		end
	end)
end

function gunClass:Destroy()
	self._maid:Destroy()
	self.item:Destroy()
	if self._event then
		self._event:Destroy()
	end
end

return gunClass
