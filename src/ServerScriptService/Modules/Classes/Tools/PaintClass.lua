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
local uiComponents = replicatedStorage:WaitForChild("UIComponents")
local uiEvents = uiComponents:WaitForChild("UIEvents")

--// Events
local setRole = events.SetRole
local toggleVisibility = events.ToggleVisibility
local toggleHints = uiEvents:WaitForChild("ToggleHints")

--// Modules
local sprayEffects = require(modules.SprayEffects)
local data = require(modules:WaitForChild("Init"))
local maid = require(shared.Maid)
local RotatedRegion3 = require(shared.RotatedRegion3)

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
			if item:IsA("MeshPart") then
				item.TextureID = ""
			end
		end
	end

	--[[if not self.dataObj then
		self.dataObj = data.new(plr)
	end]]

	return self
end

function paintClass:Activate()
	toggleHints:FireClient(self.plr, "UseSprayPaint", true)
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
			
			local region = RotatedRegion3.new(CFrame.new(humCFrame.Position + lookVector * 7), 7)
			for _, part in pairs(region:FindPartsInRegion3()) do
				if part.Parent:FindFirstChild("Humanoid") then
					if part.Parent.Name == self.murderer.Value then
						local murdererChar = part.Parent
						toggleVisibility:FireAllClients(game.Players:FindFirstChild(murdererChar.Name), true)
						part.Parent.Revealed.Value = true
						sprayEffects[self.dataObj["EquippedSpray"]:Get()](murdererChar)
						toggleHints:FireClient(self.plr, "UseSprayPaint", false)
						region = nil
					end
				end
			end
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
			if hit.Parent.Name ~= self.plr.Name and hit.Parent.Name ~= self.murderer.Value and hit.Parent.Humanoid.Health > 0 then
				setRole:Fire("Vandal", game.Players:GetPlayerFromCharacter(hit.Parent))
				replicatedItemModel:Destroy()
				self._maid:Destroy()
			end
		end
	end)
end

function paintClass:Destroy()
	self._maid:Destroy()
	self.item:Destroy()
end

return paintClass
