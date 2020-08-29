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
local StatIncrementer = require(modules:WaitForChild("StatIncrementer"))

--// Variables
local random = Random.new()
local roundTime = 120
local vandalPosition
local vigilantePosition

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

		_maid = Maid.new(),
		_roundEnded = Instance.new("BindableEvent")
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

function original:TeleportPlayer(player)
	local maps = Workspace:WaitForChild("CurrentMap")
	local map = maps:FindFirstChildOfClass("Folder")
	local spawns = map.Spawns:GetChildren()
	local character = player.Character or player.CharacterAdded:Wait()
	local spawn = spawns[random:NextInteger(1, # spawns)]
	character.HumanoidRootPart.CFrame = CFrame.new(spawn.Position + Vector3.new(0, 3, 0))
	spawn:Destroy()
end

function original:DisableUI()
	EventTable["DisableInventory"]:FireAllClients()
	EventTable["DisableShop"]:FireAllClients()
	EventTable["DisableSpectate"]:FireAllClients()
	EventTable["DisableCodeUI"]:FireAllClients()
	EventTable["EnableProximity"]:FireAllClients()
end

function original:EnableUI()
	EventTable["EnableInventory"]:FireAllClients()
	EventTable["EnableShop"]:FireAllClients()
	EventTable["EnableCodeUI"]:FireAllClients()
	EventTable["DisableProximity"]:FireAllClients()
	EventTable["DisableSpectate"]:FireAllClients()
end

function original:PrepareRound()
	--// Call loading UI
	EventTable["LoadEvent"]:FireAllClients(true)
	
	--// Init the timer
	local prepTimer = Scheduler.new(5)
	prepTimer:Start()

	self:DisableUI()

	--// Prepare players
	self._maid:GiveTask(prepTimer.Tick:Connect(function()
		if prepTimer.CurrentTime == 2 then
			--// Teleport all players
			self.murderer:Enable(self)
			self.vigilante:Enable(self)
			self.vandal:Enable(self)

			EventTable["ToggleVisibility"]:FireClient(self.vigilante.plr, self.murderer.plr, false)
			for _, innocent in pairs(self.innocents) do
				innocent:Enable(self)
				EventTable["ToggleVisibility"]:FireClient(innocent.plr, self.murderer.plr, false)
			end
		end
	end))

	self._maid:GiveTask(prepTimer.Ended:Connect(function()
		EventTable["LoadEvent"]:FireAllClients(false)
		--// Start the round
		self:StartRound()
	end))
end

function original:StartRound()
	--// Start the timer
	self.timer:Start()

	--// Fires every second
	self._maid:GiveTask(self.timer.Tick:Connect(function()
		EventTable["TimerUpdateEvent"]:FireAllClients(self.timer.CurrentTime)

		if self.vandal then
			vandalPosition = self.vandal.plr.Character.HumanoidRootPart.Position
		end
		if self.vigilante then
			vigilantePosition = self.vigilante.plr.Character.HumanoidRootPart.Position
		end
	end))

	--// Fires when timer runs out
	self._maid:GiveTask(self.timer.Ended:Connect(function()
		self:EndRound("InnocentsWin") -- Win condition 1
	end))

	self._maid:GiveTask(EventTable["SetRole"].Event:Connect(function(role, plr)
		if role == "Vandal" then
			self:GiveVandal(plr)
		elseif role == "Vigilante" then
			self:GiveVigilante(plr)
		end
	end))
end

function original:GiveVandal(player)
	for i, innocent in pairs(self.innocents) do
		if innocent.plr == player then
			innocent:Disable()
			table.remove(self.innocents, i)
			self.roles[player] = "Vandal"
			self.vandal = Vandal.new(player)
			self.vandal.item:Activate()
			EventTable["ToggleVisibility"]:FireClient(player, self.murderer.plr, true)
		end
	end
end

function original:GiveVigilante(player)
	for i, innocent in pairs(self.innocents) do
		if innocent.plr == player then
			innocent:Disable()
			table.remove(self.innocents, i)
			self.roles[player] = "Vigilante"
			self.vigilante = Vigilante.new(player)
			self.vigilante.item:Activate()
		end
	end
end

function original:EndRound(condition)
	self:EnableUI()
	EventTable["VictoryScreen"]:FireAllClients(condition)

	for _, player in pairs(game.Players:GetPlayers()) do
		player:LoadCharacter()

	end
	game.Workspace.CurrentMap:ClearAllChildren()

	for _, player in pairs(self.players) do
		StatIncrementer:GiveCoins(100, player)
		StatIncrementer:GiveExp(100, player)
	end

	--// Disable all event connections
	self._roundEnded:Fire()
	self._maid:Destroy()
	self.timer:Stop()
end

--TODO implement setrole

--// Event connections
function original:CheckDeath(player)
	local playerRole
	local allButMurderer = {}
	for plr, roles in pairs(self.roles) do
		if roles ~= "Murderer" then
			table.insert(allButMurderer, plr)
		end
		if plr == player.Name then
			if roles == "Vandal" then
				self.vandal:Disable(vandalPosition)
			elseif roles == "Vigilante" then
				self.vigilante:Disable(vigilantePosition)
			end
			self.roles[plr] = nil
			self[roles] = nil
			playerRole = roles
		end
	end
	for i, v in pairs(self.spectateList) do
		if v == player then
			table.remove(self.spectateList, i)
		end
	end
	EventTable["EnableSpectate"]:FireClient(player, self.spectateList)
	EventTable["UpdateSpectate"]:FireAllClients(player)
	if playerRole == "Murderer" then
		self:EndRound("InnocentsWin") -- Win condition 2
	else
		table.remove(allButMurderer, table.find(allButMurderer, player))
		if #allButMurderer == 0 then
			self:EndRound("MurdererWins")
		end
	end
end

--Return
return original