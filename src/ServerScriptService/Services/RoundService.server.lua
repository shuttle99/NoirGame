--// Services
local replicatedStorage = game:GetService("ReplicatedStorage")
local serverStorage = game:GetService("ServerStorage")
local serverScriptService = game:GetService("ServerScriptService")

--// Folders
local sharedModules = replicatedStorage.Shared
local modules = serverScriptService.Modules
local classes = modules.Classes
local assets = serverStorage.Assets
local maps = assets.Maps:GetChildren()
local currentMapFolder = workspace.CurrentMap
local uiComponents = replicatedStorage.UIComponents
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
end

local function roundComplete()
	connection = round.roundEnded:Connect(function()
		intermission()
		connection:Disconnect()
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

		originalGamemode.new(game.Players:GetPlayers())
	end)
end

--// Init
intermission()


