local innocentClass = {}
innocentClass.__index = innocentClass

--// Services
local replicatedStorage = game:GetService("ReplicatedStorage")
local serverStorage = game:GetService("ServerStorage")

--// Folders
local events = replicatedStorage.Events
local assets = serverStorage.Assets

--// Asset folders
local characters = assets.Characters

--// Events
local visibilityToggle = events.ToggleVisibility
local notif = replicatedStorage.UIComponents.UIEvents.RoleNotification

function innocentClass.new(plr)
	local self = setmetatable({
		plr = plr,
	}, innocentClass)
	
	self:GiveAppearance()
	notif:FireClient(self.plr, "You are innocent!", "Survive.")
	
	return self
end

function innocentClass:GiveAppearance()
	local innoCharacters = characters.Innocent:GetChildren()
	local random = Random.new()
	local ranChar = random:NextInteger(1, #innoCharacters)
	local char = innoCharacters[ranChar]:Clone()
	char.Name = "StarterCharacter"
	char.Parent = game.StarterPlayer
	self.plr:LoadCharacter()
	char:Destroy()
end

return innocentClass
