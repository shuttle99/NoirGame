local murdererClass = {}
murdererClass.__index = murdererClass

--// Services
local replicatedStorage = game:GetService("ReplicatedStorage")
local serverStorage = game:GetService("ServerStorage")

--// Folders
local events = replicatedStorage.Events
local toolClasses = script.Parent.Tools
local assets = serverStorage.Assets

--// Asset folders
local characters = assets.Characters

--// Classes
local knifeClass = require(toolClasses.KnifeClass)

--// Events
local visibilityToggle = events.ToggleVisibility
local notif = replicatedStorage.UIComponents.UIEvents.RoleNotification

function murdererClass.new(plr)
	local self = setmetatable({
		plr = plr,
		tool = knifeClass.new(plr)
	}, murdererClass)
	
	self:GiveAppearance()
	self.tool:Activate()
	notif:FireClient(self.plr, "You are the Murderer!", "Use your KNIFE to kill everyone.")
	
	game.ServerStorage.MurdererValue.Value = self.plr.Name

	return self
end

function murdererClass:GiveAppearance()
	local char = characters.Murderer:FindFirstChildOfClass("Model"):Clone()
	char.Name = "StarterCharacter"
	char.Parent = game.StarterPlayer
	self.plr:LoadCharacter()
	char:Destroy()
end

return murdererClass
