--[[
	Handles original game mode data and methods
]]
local original
original.__index = original

--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local ServerScriptService = game:GetService("ServerScriptService")

--// Folders
local events = ReplicatedStorage:WaitForChild("Events")
local uiComponents = ReplicatedStorage:WaitForChild("UIComponents")
local shared = ReplicatedStorage:WaitForChild("Shared")
local uiEvents = uiComponents:WaitForChild("UIEvents")
local classes = ServerScriptService:WaitForChild("Classes")

--// Modules
local Murderer = require(classes:WaitForChild("MurdererClass"))
local Vigilante = require(classes:WaitForChild("VigilanteClass"))
local Vandal = require(classes:WaitForChild("VandalClass"))
local Innocent = require(classes:WaitForChild("InnocentClass"))
local Maid = require(shared:WaitForChild("Maid"))
local Scheduler = require(shared:WaitForChild("Scheduler"))
local Random = Random.new()

--// Variables
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

		murderer = Murderer.new(table.remove(cachedPlayers, Random:NextInteger(1, #cachedPlayers))),
		vigilante = Murderer.new(table.remove(cachedPlayers, Random:NextInteger(1, #cachedPlayers))),
		vandal = Murderer.new(table.remove(cachedPlayers, Random:NextInteger(1, #cachedPlayers))),
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

	return self
end

--// Round methods
function original:PrepareRound()
	--// Init the timer
	local prepTimer = Scheduler.new(5)

	--// Call loading UI
	for _, player in pairs(self.players) do
		EventTable["LoadEvent"]:FireClient(player,true)
	end

	self._maid:GiveTask(prepTimer.Tick:Connect(function()
		if prepTimer.CurrentTime == 1 then
			--// Teleport all players
			for _, player in pairs(self.players) do
				--// Teleport players using each classes prepare method
			end
		end
	end))
	--// End loading UI
	for _, player in pairs(self.players) do
		EventTable["LoadEvent"]:FireClient(player, false)
	end

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
		print("Game over.")
	end))
end

function original:EndRound(condition)
	--// Disable all event connections
	self._maid:Destroy()
end

--// Event connections
function original:CheckDeath(player)
	for plr, roles in pairs(self.roles) do
		if plr == player.Name then
			self.roles[plr] = nil
			self[roles] = nil
		end
	end
end

--Return
return original