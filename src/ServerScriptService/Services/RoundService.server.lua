--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Lighting = game:GetService("Lighting")

--// Folders
local sharedModules = ReplicatedStorage.Shared
local modules = ServerScriptService.Modules
local classes = modules.Classes
local assets = ServerStorage.Assets
local maps = assets.Maps:GetChildren()
local currentMapFolder = workspace.CurrentMap
local uiComponents = ReplicatedStorage.UIComponents
local uiEvents = uiComponents.UIEvents

--// Modules
local scheduler = require(sharedModules.Scheduler)

--// Modules; Gamemodes
local originalGamemode = require(classes.OriginalGamemodeClass)

--// Misc
local random = Random.new()
local connection

--// Events
local updateTimer = uiEvents.TimerUpdateEvent

--// Round variable
local roundTime
local round

--// Local functions
local function checkForPlayers()
	local counter = 0
	for _, player in pairs(game.Players:GetPlayers()) do
		if not player:FindFirstChild("AFK") then
			counter += 1
		end
	end
	if counter >= 4 then
		return true
	end
end

local function chooseMap()
	local map = maps[random:NextInteger(1, #maps)]:Clone()
	map.Parent = currentMapFolder

	--// Set Config of map
	for _, value in pairs(map.MapConfig:GetChildren()) do
		if value.Name ~= "RoundTime" and value.Name ~= "Thumbnail" then
			if Lighting[value.Name] then
				Lighting[value.Name] = value.Value
			end
		end
	end

	roundTime = map.MapConfig.RoundTime.Value
end

local bindConnection
local function roundComplete()
	bindConnection = game.ReplicatedStorage.Events.DeathEvent.Event:Connect(function(plr)
		round:CheckDeath(plr)
	end)
	connection = round._roundEnded.Event:Connect(function()
		intermission()
		connection:Disconnect()
		bindConnection:Disconnect()
	end)
end

function intermission()
	round = nil
	local intermissionTimer = scheduler.new(30)

	intermissionTimer:Start()
	intermissionTimer.Tick:Connect(function()
		updateTimer:FireAllClients("Intermission: " .. intermissionTimer.CurrentTime)
		if intermissionTimer.CurrentTime == 5 then
			chooseMap()
		end
	end)
 
	intermissionTimer.Ended:Connect(function()
		while not checkForPlayers() do
			wait(1.5)
			updateTimer:FireAllClients("You need ".. 4 - #game.Players:GetPlayers() .. " more players for the game to begin!")
		end

		round = originalGamemode.new(game.Players:GetPlayers(), roundTime)
		roundComplete()
	end)
end

--// Init
--intermission()


