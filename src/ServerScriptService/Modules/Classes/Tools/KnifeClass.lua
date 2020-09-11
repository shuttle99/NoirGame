local knifeClass = {}
knifeClass.__index = knifeClass

--// Services
local replicatedStorage = game:GetService("ReplicatedStorage")

--// Folders
local shared = replicatedStorage:WaitForChild("Shared")
local events = replicatedStorage:WaitForChild("Events")

--// Modules
local data = require(game.ServerScriptService.Modules.Init)
local statIncrementer = require(game.ServerScriptService.Modules.StatIncrementer)
local maid = require(shared:WaitForChild("Maid"))

--//Testing event
local meleeHitEvent = events:WaitForChild("MeleeHitEvent")
local meleeEvent = events:WaitForChild("MeleeEvent")

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
		print("User has the golden knife enabled")
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
	print("Activation")
	self.item.Parent = self.plr.Backpack
	meleeEvent:FireClient(self.plr, self.item)
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

			wait(animTable[anim].length)
			anim = anim == 1 and 2 or 1
			sound = sound == 1 and 2 or sound == 2 and 3 or sound == 3 and 1
			self.debounce = false
		end
	end))
	self._maid:GiveTask(meleeHitEvent.OnServerEvent:Connect(function(plr, result)
		if result.Parent:FindFirstChild("Humanoid") then
			result.Parent.Humanoid.Health = -100

			statIncrementer:GiveCoins(10, plr)
			--// Make secure
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
