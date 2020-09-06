--[[
Handles the visibility of the murderer to other players
CheekyVisuals
7/17/2020
]]

--// Services
local replicatedStorage = game:GetService("ReplicatedStorage")

--// Folders
local events = replicatedStorage.Events

--// Events
local toggleVisbility = events.ToggleVisibility
local checkVandal = events.CheckVandal

--// Local Functions
local function hideMurderer(murderer)
	local murdererChar = murderer.Character or murderer.CharacterAdded:Wait()
	murdererChar.Parent = game.ReplicatedStorage
end

local function showMurderer(murderer)
	local murdererChar = murderer.Character
	murdererChar.Parent = game.Workspace
end

--// Event Handler
toggleVisbility.OnClientEvent:Connect(function(murderer, visibility)
	murderer.Character.Archivable = true
	if visibility then
		showMurderer(murderer)
	else
		hideMurderer(murderer)
	end
end)