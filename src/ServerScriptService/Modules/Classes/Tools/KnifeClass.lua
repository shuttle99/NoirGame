local knifeClass = {}
knifeClass.__index = knifeClass

--// Services
local replicatedStorage = game:GetService("ReplicatedStorage")

--// Folders
local replicatedAssets = replicatedStorage.ItemModels
local shared = replicatedStorage:WaitForChild("Shared")

--// Modules
local data = require(game.ServerScriptService.Modules.Init)
local statIncrementer = require(game.ServerScriptService.Modules.StatIncrementer)
local maid = require(shared:WaitForChild("Maid"))

function knifeClass.new(plr)
	local self = setmetatable({
		plr = plr,
		debounce = false,
		dataObj = data:Get(plr),
		item = "",

		_maid = maid.new()
	}, knifeClass)

	if not self.dataObj then
		self.dataObj = data.new(plr)
	end
	
	self.item = game.ServerStorage.Assets.Items.Murderer[self.dataObj["EquippedKnife"]:Get()]:Clone()
	if self.dataObj.GoldenKnife:Get() == true then
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

function knifeClass:Activate()
	self.item.Parent = self.plr.Backpack
	local char = self.plr.Character or self.plr.CharacterAdded:Wait()

	local animTable = {char.Humanoid:LoadAnimation(self.item:WaitForChild("HitAnim")), char.Humanoid:LoadAnimation(self.item.HitAnim2)}
	local idleAnim = char.Humanoid:LoadAnimation(self.item:WaitForChild("KnifeIdleAnim"))
	local anim = 1
	local sound = 1

	self._maid:GiveTask(self.item.Equipped:Connect(function()
		idleAnim:Play()
	end))
	local connection
	self._maid:GiveTask(self.item.Unequipped:Connect(function()
		idleAnim:Stop()
		if connection then
			connection:Disconnect()
		end
	end))
	local connection2
	self._maid:GiveTask(self.item.Activated:Connect(function()
		if not self.debounce then
			self.debounce = true
			animTable[anim]:Play()
			connection = self.item.Handle.Touched:Connect(function(hit)
				if hit.Parent:FindFirstChild("Humanoid") and hit.Parent.Name ~= self.plr.Name then
					if hit.Parent.Humanoid.Health > 0 and self.debounce then
						self.item.Handle:FindFirstChild("Hit" .. sound):Play()
						hit.Parent.Humanoid.Health = 0
						statIncrementer:GiveCoins(10, self.plr)
						connection:Disconnect()
					end
				end
			end)
			wait(animTable[anim].length)
			anim = anim == 1 and 2 or 1
			sound = sound == 1 and 2 or sound == 2 and 3 or sound == 3 and 1
			self.debounce = false
		end
	end))
end

function knifeClass:Destroy()
	self._maid:Destroy()
	if self.item then
		self.item:Destroy()
	end
end

return knifeClass
