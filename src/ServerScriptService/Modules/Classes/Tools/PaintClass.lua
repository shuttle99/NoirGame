local paintClass = {}
paintClass.__index = paintClass

--// Services
local replicatedStorage = game:GetService("ReplicatedStorage")
local serverScriptService = game:GetService("ServerScriptService")

--// Folders
local replicatedAssets = replicatedStorage.ItemModels
local events = replicatedStorage.Events
local modules = serverScriptService.Modules
local shared = replicatedStorage.Shared

--// Events
local setRole = events.SetRole
local toggleVisibility = events.ToggleVisibility

--// Modules
local sprayEffects = require(modules.SprayEffects)
local data = require(modules:WaitForChild("Init"))
local maid = require(shared.Maid)

--// Local Functions
local function GetTouchingParts(part)
	local connection = part.Touched:Connect(function() end)
	local results = part:GetTouchingParts()
	connection:Disconnect()
	return results
end

function paintClass.new(plr)
	local self = setmetatable({
		plr = plr,
		murderer = game.ServerStorage.MurdererValue,
		item = game.ServerStorage.Assets.Items.Vandal.Spray:Clone(),
		debounce = false,
		dataObj = data:Get(plr) or data.new(plr),

		_maid = maid.new()
	}, paintClass)

	if self.dataObj.GoldenSpray:Get() == true then
		for _, item in pairs(self.item:GetDescendants()) do
			if item:IsA("BasePart") then
				item.Color = Color3.fromRGB(249, 166, 2)
			end
		end
	end

	--[[if not self.dataObj then
		self.dataObj = data.new(plr)
	end]]

	return self
end

function paintClass:Activate()
	print("Called")
	local char = self.plr.Character
	local equip = char:WaitForChild("Humanoid"):LoadAnimation(self.item.EquipAnim)
	local idle = char.Humanoid:LoadAnimation(self.item.IdleAnim)
	local spray = char.Humanoid:LoadAnimation(self.item.SprayAnim)
	game.ServerStorage.Assets.Items.Vandal.Sprays[self.dataObj["EquippedSpray"]:Get()]:Clone().Parent = self.item.Handle.EmitFrom
	
	self.item.Parent = self.plr.Backpack
	
	self._maid:GiveTask(self.item.Equipped:Connect(function()
		equip:Play()
		equip.Stopped:Wait()
		idle:Play()
	end))
	
	self._maid:GiveTask(self.item.Unequipped:Connect(function()
		equip:Stop()
		idle:Stop()
	end))
	
	self._maid:GiveTask(self.item.Activated:Connect(function()
		if not self.debounce then
			self.debounce = true
			self.item.Handle.EmitFrom:FindFirstChildOfClass("ParticleEmitter").Enabled = true
			spray:Play()
			local humCFrame = self.plr.Character.HumanoidRootPart.CFrame
			local lookVector = humCFrame.LookVector
            local part = Instance.new("Part")
            part.Anchored = true
            part.CanCollide = false
            part.CFrame = CFrame.new(humCFrame.Position + lookVector * 5)
            part.Size = Vector3.new(15,10,15)
            part.Parent = workspace
            part.Transparency = 1
            self.item.Handle.EmitFrom:FindFirstChildOfClass("ParticleEmitter").Enabled = true
			for _, v in pairs(GetTouchingParts(part)) do
				if v then        
					if v.Parent:FindFirstChild("Humanoid") and v.Name == "HumanoidRootPart" then
						print(v.Name)
						--Check if murderer
						for _, x in pairs(v.Parent:GetChildren()) do
							if x.Name ~= "HumanoidRootPart" and x:IsA("BasePart") then
								if x.Parent.Name == self.murderer.Value then
									local murdererChar = x.Parent
									print(murdererChar.Name)
									sprayEffects[self.dataObj["EquippedSpray"]:Get()](murdererChar)
									local sprayModel = game.ReplicatedStorage.ItemModels:FindFirstChild(self.dataObj["EquippedSpray"]:Get())
									--print(sprayModel.Name)
									--game.Players:FindFirstChild(self.murderer.Value):ClearCharacterAppearance()

									--[[local accessories = {}
									for _, item in pairs(murdererChar.Humanoid:GetAccessories()) do
										table.insert(accessories, item)
									end
									for _, accessory in pairs(accessories) do
										murdererChar.Humanoid:AddAccessory(accessory)
									end
	
									murdererChar.Humanoid:ApplyDescription(sprayModel.Humanoid:GetAppliedDescription())]]
									part:Destroy()
									toggleVisibility:FireAllClients(game.Players:GetPlayerFromCharacter(murdererChar), true)
								end
							end
						end
					end
				end
			end
			part:Destroy()
			self._maid:GiveTask(spray.Stopped:Connect(function()
				self.item.Handle.EmitFrom:FindFirstChildOfClass("ParticleEmitter").Enabled = false
			end))
			wait(5)
			self.debounce = false
		end
	end))
end

function paintClass:DropItem(pos)
	local replicatedItemModel = replicatedAssets[self.item.Name]:Clone()
	replicatedItemModel.Parent = game.Workspace.Drops
	replicatedItemModel:SetPrimaryPartCFrame(CFrame.new(pos))

	replicatedItemModel.Handle.Touched:Connect(function(hit)
		if hit.Parent:FindFirstChild("Humanoid") then
			if hit.Parent.Name ~= self.plr.Name and hit.Parent.Name ~= self.murderer.Value then
				if #game.Players:GetPlayerFromCharacter(hit.Parent).Backpack:GetChildren() == 0 then
					setRole:Fire("Vandal", game.Players:GetPlayerFromCharacter(hit.Parent))
					replicatedItemModel:Destroy()
					self._maid:Destroy()
				end
			end
		end
	end)
end

function paintClass:Destroy()
	self._maid:Destroy()
	self.item:Destroy()
end

return paintClass
