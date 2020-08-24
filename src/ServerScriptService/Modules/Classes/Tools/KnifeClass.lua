local knifeClass = {}
knifeClass.__index = knifeClass

--// Services
local replicatedStorage = game:GetService("ReplicatedStorage")

--// Folders
local replicatedAssets = replicatedStorage.ItemModels

--// Modules
local data = require(game.ServerScriptService.Modules.Init)
local statIncrementer = require(game.ServerScriptService.Modules.StatIncrementer)

function knifeClass.new(plr)
	local self = setmetatable({
		plr = plr,
		debounce = false,
		dataObj = data:Get(plr),
		item = ""
	}, knifeClass)

	if not self.dataObj then
		self.dataObj = data.new(plr)
	end
	
	self.item = game.ServerStorage.Assets.Items.Murderer[self.dataObj["EquippedKnife"]:Get()]:Clone()
	
	return self
end

function knifeClass:Activate()
	print("Activation")
	self.item.Parent = self.plr.Backpack
	local char = self.plr.Character or self.plr.CharacterAdded:Wait()

	local animTable = {char.Humanoid:LoadAnimation(self.item:WaitForChild("HitAnim")), char.Humanoid:LoadAnimation(self.item.HitAnim2)}
	local idleAnim = char.Humanoid:LoadAnimation(self.item:WaitForChild("KnifeIdleAnim"))
	local anim = 1
	local sound = 1

	self.item.Equipped:Connect(function()
		idleAnim:Play()
	end)

	self.item.Unequipped:Connect(function()
		idleAnim:Stop()
	end)
	local connection
	self.item.Activated:Connect(function()
		if not self.debounce then
			self.debounce = true
			animTable[anim]:Play()
			connection = self.item.Handle.Touched:Connect(function(hit)
				if hit.Parent:FindFirstChild("Humanoid") and hit.Parent.Name ~= self.plr.Name then
					if hit.Parent.Humanoid.Health > 0 then
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
	end)
end

return knifeClass
