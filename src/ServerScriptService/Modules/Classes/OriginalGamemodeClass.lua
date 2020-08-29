--[[
	Handles original game mode data and methods
]]
local original = {}
original.__index = original

--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

--// Folders
local events = ReplicatedStorage:WaitForChild("Events")
local uiComponents = ReplicatedStorage:WaitForChild("UIComponents")
local shared = ReplicatedStorage:WaitForChild("Shared")
local uiEvents = uiComponents:WaitForChild("UIEvents")
local modules = ServerScriptService:WaitForChild("Modules")
local classes = modules:WaitForChild("Classes")

--// Modules
local Murderer = require(classes:WaitForChild("MurdererClass"))
local Vigilante = require(classes:WaitForChild("VigilanteClass"))
local Vandal = require(classes:WaitForChild("VandalClass"))
local Innocent = require(classes:WaitForChild("InnocentClass"))
local Maid = require(shared:WaitForChild("Maid"))
local Scheduler = require(shared:WaitForChild("Scheduler"))

--// Variables
local random = Random.new()
local roundTime = 15

--//Events
local EventTable = {}
for _, event in pairs(events:GetChildren()) do
	EventTable[event.Name] = events:WaitForChild(event.Name)
end

for _, event in pairs(uiEvents:GetChildren()) do
	EventTable[event.Name] = uiEvents:WaitForChild(event.Name)
end

--// Round constructor
function original.new(players)
	local cachedPlayers = players
	local self = setmetatable({
		timer = Scheduler.new(roundTime),
		players = players,

		murderer = Murderer.new(table.remove(cachedPlayers, random:NextInteger(1, #cachedPlayers))),
		vigilante = Vigilante.new(table.remove(cachedPlayers, random:NextInteger(1, #cachedPlayers))),
		vandal = Vandal.new(table.remove(cachedPlayers, random:NextInteger(1, #cachedPlayers))),
		innocents = {},
		roles = {},

		spectateList = players,

		_maid = Maid.new()
	}, original)

	self.roles[self.murderer.plr.Name] = "Murderer"
	self.roles[self.vigilante.plr.Name] = "Vigilante"
	self.roles[self.vandal.plr.Name] = "Vandal"

	for _, player in pairs(cachedPlayers) do
		table.insert(self.innocents, Innocent.new(player))
		self.roles[player.Name] = "Innocent"
	end

	--// Begin the round
	self:PrepareRound()

	return self
end

function original:TeleportPlayers()
	local maps = Workspace:WaitForChild("CurrentMap")
	local map = maps:FindFirstChildOfClass("Folder")
	local spawns = map.Spawns:WaitForChildren()
	for _, player in pairs(self.players) do
		local character = player.Character or player.CharacterAdded:Wait()
		local spawn = table.remove(spawns, random:NextInteger(1, #spawns))
		character.HumanoidRootPart.CFrame = CFrame.new(spawn.Position + Vector3.new(0, 3, 0))
	end
end

function original:PrepareRound()
	--// Init the timer
	local prepTimer = Scheduler.new(5)
	prepTimer:Start()

	--// Call loading UI
	for _, player in pairs(self.players) do
		EventTable["LoadEvent"]:FireClient(player,true)
	end

	self._maid:GiveTask(prepTimer.Tick:Connect(function()
		if prepTimer.CurrentTime == 2 then
			--// Teleport all players
			--[[TODO: Add teleportation to classes prepare method; Disable player movement until StartRound is called]]
			self.murderer:Enable()
			self.vigilante:Enable()
			self.vandal:Enable()
			for _, innocent in self.innocents do
				innocent:Enable()
			end
			self:TeleportPlayers()
		elseif prepTimer.CurrentTime == 4 then
			--// End loading UI
			for _, player in pairs(self.players) do
				EventTable["LoadEvent"]:FireClient(player, false)
			end
		end
	end))

	self._maid:GiveTask(prepTimer.Ended:Connect(function()
		--// Start the round
		self:StartRound()
	end))
end

function original:StartRound()
	--// Start the timer
	self.timer:Start()

	--// Fires every second
	self._maid:GiveTask(self.timer.Tick:Connect(function()
		print(self.timer.CurrentTime)
	end))

	--// Fires when timer runs out
	self._maid:GiveTask(self.Timer.Ended:Connect(function()
		self:EndRound("InnocentsWin") -- Win condition 1
	end))
end

function original:EndRound(condition)
	EventTable["VictoryScreen"]:FireAllClients(condition)

	--// Disable all event connections
	self._maid:Destroy()
	self.timer:Stop()
end

--// Event connections
function original:CheckDeath(player)
	local playerRole
	local allButMurderer = {}
	for plr, roles in pairs(self.roles) do
		if roles ~= "Murderer" then
			table.insert(allButMurderer, plr)
		end
		if plr == player.Name then
			self.roles[plr] = nil
			self[roles] = nil
			playerRole = roles
		end
	end
	if playerRole == "Murderer" then
		self:EndRound("InnocentsWin") -- Win condition 2
	else
		table.remove(allButMurderer, table.find(player))
		if #allButMurderer == 0 then
			self:EndRound("MurdererWins")
		end
	end
end

--Return
return original