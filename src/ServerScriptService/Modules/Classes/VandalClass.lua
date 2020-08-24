local vandalClass = {}
vandalClass.__index = vandalClass

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
local paintClass = require(toolClasses.PaintClass)

--// Events
local visibilityToggle = events.ToggleVisibility
local notif = replicatedStorage.UIComponents.UIEvents.RoleNotification

function vandalClass.new(plr)
	local self = setmetatable({
		plr = plr,
		item = paintClass.new(plr)
	}, vandalClass)
	
	notif:FireClient(self.plr, "You are the Vandal!", "Use your SPRAY PAINT to reveal the MURDERER to everyone else.")	
	
	return self
end

function vandalClass:GiveAppearance()
	local char = characters.Vandal:FindFirstChildOfClass("Model"):Clone()
	char.Name = "StarterCharacter"
	char.Parent = game.StarterPlayer
	self.plr:LoadCharacter()
	char:Destroy()
end

function vandalClass:EndClass()
	self.item:Destroy()
end

return vandalClass
