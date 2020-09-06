local vigilanteClass = {}
vigilanteClass.__index = vigilanteClass

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
local gunClass = require(toolClasses.GunClass)

--// Events
local visibilityToggle = events.ToggleVisibility
local notif = replicatedStorage.UIComponents.UIEvents.RoleNotification

function vigilanteClass.new(plr)
	local self = setmetatable({
		plr = plr,
		item = gunClass.new(plr)
	}, vigilanteClass)
	
	return self
end

function vigilanteClass:GiveAppearance()
	local char = characters.Vigilante:FindFirstChildOfClass("Model"):Clone()
	char.Name = "StarterCharacter"
	char.Parent = game.StarterPlayer
	if game.Players:FindFirstChild(self.plr.Name) then
		self.plr:LoadCharacter()
	end
	char:Destroy()
end

function vigilanteClass:Enable(gamemode)
	notif:FireClient(self.plr, "You are the Vigilante!", "Use your REVOLVER to shoot the MURDERER when they are revealed.")
	self:GiveAppearance()
	self.item:Activate()
	gamemode:TeleportPlayer(self.plr)
end

function vigilanteClass:Disable(pos)
	self.item:DropItem(pos)
end

return vigilanteClass