local murdererClass = {}
murdererClass.__index = murdererClass

--// Services
local replicatedStorage = game:GetService("ReplicatedStorage")
local serverStorage = game:GetService("ServerStorage")

--// Folders
local events = replicatedStorage.Events
local toolClasses = script.Parent.Tools
local assets = serverStorage.Assets
local Shared = replicatedStorage:WaitForChild("Shared")

--// Asset folders
local characters = assets.Characters

--// Classes
local knifeClass = require(toolClasses.KnifeClass)

--// Modules
local maid = require(Shared.Maid)

--// Events
local notif = replicatedStorage.UIComponents.UIEvents.RoleNotification
local toggleJump = events.ToggleJump
local rageEffect = replicatedStorage.UIComponents.UIEvents.RageEffect


function murdererClass.new(plr)
	local self = setmetatable({
		plr = plr,
		tool = knifeClass.new(plr),
		revealed = Instance.new("BoolValue"),

		_maid = maid.new()
	}, murdererClass)

	self.revealed.Name = "Revealed"

	return self
end

function murdererClass:GiveAppearance()
	local char = characters.Murderer:FindFirstChildOfClass("Model"):Clone()
	char.Name = "StarterCharacter"
	char.Parent = game.StarterPlayer
	self.revealed.Parent = char
	if game.Players:FindFirstChild(self.plr.Name) then
		self.plr:LoadCharacter()
	end
	char:Destroy()
end

function murdererClass:Enable(gamemode)
	notif:FireClient(self.plr, "You are the Murderer!", "Use your KNIFE to kill everyone.")
	--// Set global value so other scripts can reference the murderer
	game.ServerStorage.MurdererValue.Value = self.plr.Name
	--// Set murderer appearance
	self:GiveAppearance()
	--// Give them tool and activate it
	self.tool:Activate()
	gamemode:TeleportPlayer(self.plr)

	local char = self.plr.Character or self.plr.CharacterAdded:Wait()
	local humanoid = char.Humanoid

	toggleJump:FireClient(self.plr, true)
end

function murdererClass:Enrage()
	local char = self.plr.Character or self.plr.CharacterAdded:Wait()
	local humanoid = char:WaitForChild("Humanoid")
	humanoid.WalkSpeed = 19

	rageEffect:FireClient(self.plr, true)
end

function murdererClass:Disable()
	toggleJump:FireClient(self.plr, false)
	self.plr.Character.Humanoid.JumpPower = 50
	self.tool:Destroy()
	self._maid:Destroy()
	game.ServerStorage.MurdererValue.Value = nil
end

return murdererClass
