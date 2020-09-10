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
local Scheduler = require(shared:WaitForChild("Scheduler"))

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
	self._maid:GiveTask(self.item.Activated:Connect(function()
		if not self.debounce then
			self.debounce = true
			animTable[anim]:Play()
			--// Implement raycast
			local rayParams = RaycastParams.new()
			rayParams.FilterType = Enum.RaycastFilterType.Blacklist
			rayParams.FilterDescendantsInstances = {self.plr.Character, self.item}
			
			local origin = self.plr.Character.HumanoidRootPart
			local result = workspace:Raycast(origin.Position, origin.CFrame.LookVector * 100, rayParams)

			if result then
				if result.Instance.Parent:FindFirstChild("Humanoid") then
					result.Instance.Parent.Humanoid.Health = -100
				end
			end
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
