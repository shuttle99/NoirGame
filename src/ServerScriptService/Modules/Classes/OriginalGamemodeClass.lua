local originalModeClass = {}
originalModeClass.__index = originalModeClass

--// Services
local replicatedStorage = game:GetService("ReplicatedStorage")
local serverScriptService = game:GetService("ServerScriptService")
local workspace = game:GetService("Workspace")

--// Folders
local events = replicatedStorage.Events
local modules = serverScriptService.Modules
local classes = modules.Classes
local currentMapFolder = workspace.CurrentMap
local sharedModules = game.ReplicatedStorage.Shared
local uiComponents = replicatedStorage.UIComponents
local uiEvents = uiComponents.UIEvents

--// Modules
local scheduler = require(sharedModules.Scheduler)
local maid = require(sharedModules.Maid)
local stats = require(modules.StatIncrementer)
local proximity = require(modules.ProximityDetection)

--// Classes
local murdererClass = require(classes.MurdererClass)
local vandalClass = require(classes.VandalClass)
local vigilanteClass = require(classes.VigilanteClass)
local innocentClass = require(classes.InnocentClass)

--// Events
local deathEvent = events.DeathEvent
local setRole = events.SetRole
local visbilityToggle = events.ToggleVisibility
--local gunHit = events.GunHit

--// UI Events
local updateTimer = uiEvents.TimerUpdateEvent
local disableInventory = uiEvents.DisableInventory
local enableInventory = uiEvents.EnableInventory
local enableSpectate = uiEvents.EnableSpectate
local disableSpectate = uiEvents.DisableSpectate
local updateSpectate = uiEvents.UpdateSpectate
local loadEvent = uiEvents.LoadEvent
local disableShop = uiEvents.DisableShop
local enableShop = uiEvents.EnableShop
local enableCodesUI = uiEvents.EnableCodeUI
local disableCodesUI = uiEvents.DisableCodeUI
local fixFOV = uiEvents.FixFOV
local victoryScreen = uiEvents.VictoryScreen

--[[ Variables to access data
	self -
		Input:Role
		Output:Role Object

	self.RoleName.Player -
		Input: Role name + .plr
		Output: Player object

	Roles -
		Input: Player object
		Output: Role name
	
	AllButMurderer -
		Input: Integer
		Output: Player Name

	SpectateList -
		Input: Integer
		Output: Player Name
--]]

--// Variables
local random = Random.new()

--// Win Conditions
local winConditions = {
	["MurdererDies"] = function(murderer)
		print("Innocents win!")
	end,
	["InnocentsDie"] = function()
		print("Murderer wins")
	end,
	["TimeOut"] = function(murderer)
		print("Out of time")
	end
}

--// Teleport players to the map
local function teleportPlayers(plrList)
	local spawns = currentMapFolder:FindFirstChildOfClass("Folder"):FindFirstChild("Spawns"):GetChildren()
	for i, _ in pairs(plrList) do
		local char = i.Character or i.CharacterAdded:Wait()
		char:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(table.remove(spawns, random:NextInteger(1, #spawns)).Position + Vector3.new(0, 3, 0))
		print(char.Name .. " has been loaded!")
	end
end

--// Init the round
function originalModeClass.new()
	--// Fire UI events
	disableShop:FireAllClients()
	disableInventory:FireAllClients()
	disableSpectate:FireAllClients()
	disableCodesUI:FireAllClients()

	--//Get Players
	local plrsInitial = game.Players:GetPlayers()
	local plrCopy = game.Players:GetPlayers()
	local plrs = {}

	--// Check for AFK players
	for _, player in pairs(plrsInitial) do
		if not player:FindFirstChild("AFK") then
			table.insert(plrs, player)
		end
	end

	--// Fill in class info
	local self = setmetatable({
		gameLength = 120,
		spectateList = {},
		Murderer = murdererClass.new(table.remove(plrs, random:NextInteger(1, #plrs))),
		Vandal = vandalClass.new(table.remove(plrs, random:NextInteger(1, #plrs))),
		Vigilante = vigilanteClass.new(table.remove(plrs, random:NextInteger(1, #plrs))),
		Innocents = {},
		plrs = plrs,
		
		_maid = maid.new()
	}, originalModeClass)

	for _ , player in pairs(plrCopy) do
		table.insert(self.spectateList, player)
	end
	
	--// Set appearances of characters
	self.Vandal:GiveAppearance()
	self.Vigilante:GiveAppearance()

	--// Give items for characters
	self.Vandal.item:Activate()
	self.Vigilante.item:Activate()

	--// Init round ending events
	self._roundEnded = Instance.new("BindableEvent")
	self.roundEnded = self._roundEnded.Event
	self._maid:GiveTask(self._roundEnded)
	
	return self
end

--//Round Start
function originalModeClass:StartRound()
	--// Disable the spectate and shop UI
	disableSpectate:FireAllClients()
	disableShop:FireAllClients()
	fixFOV:FireAllClients()

	--// Toggle the visibility of the murderer
	for _,v in pairs(self.plrs) do
		self.Innocents[v] = innocentClass.new(v)
		visbilityToggle:FireClient(v, self.Murderer.plr, false)
	end

	visbilityToggle:FireClient(self.Vigilante.plr, self.Murderer.plr, false)

	--// Init the timer
	local roundTimer = scheduler.new(self.gameLength)
	local prepTimer = scheduler.new(5)

	--// Set role table
	local roles = {
		[self.Murderer.plr] = "Murderer",
		[self.Vandal.plr] = "Vandal",
		[self.Vigilante.plr] = "Vigilante",
	}
	for _, v in pairs(self.Innocents) do
		roles[v.plr] = "Innocent"
	end

	--// Make a table of all players except for the murderer
	local allButMurderer = {}
	for i, _ in pairs(roles) do
		if self.Murderer.plr ~= i then
			table.insert(allButMurderer, i)
		end
	end

	--// Give the player the vandal data if they pick up an item
	local function giveVandal(plrToGive)
		visbilityToggle:FireClient(plrToGive, self.Murderer.plr, true)
		roles[plrToGive] = "Vandal"
		self.Vandal = vandalClass.new(plrToGive)
		self.Vandal.item:Activate()
	end
	
	--// Give the player the vigilante data if they pick up an item
	local function giveVigilante(plr)
		self.Vigilante = vigilanteClass.new(plr)
		self.Vigilante.item:Activate()
		roles[plr] = "Vigilante"
	end
	
	prepTimer:Start()

	loadEvent:FireAllClients()

	--wait(3)

	--// Teleport players to maps
	teleportPlayers(roles)

	self._maid:GiveTask(prepTimer.Ended:Connect(function()

		--// Start the timer
		roundTimer:Start()

		--// Enable proximity effects
		proximity:Enable(allButMurderer)
	

		--// Check if an item is in the drops folder
		local function checkForItemDropped(item)
			for _, tool in pairs(game.Workspace.Drops:GetChildren()) do
				if item == "Gun" then
					if tool:FindFirstChild("Barrel") then
						return true
					end
				elseif item == "Spray" then
					if tool.Name == "Spray" then
						return true
					end
				end
			end
			return false
		end

		--// Fire an event everytime the timer updates
		self._maid:GiveTask(roundTimer.Tick:Connect(function()
			--// Set time on the UI
			updateTimer:FireAllClients("Time Left: " .. roundTimer.CurrentTime)
			--// Cache the vandal's position
			if self.Vandal then
				local vandalChar = self.Vandal.plr.Character or self.Vandal.plr.CharacterAdded:Wait()
				local hrp = vandalChar:WaitForChild("HumanoidRootPart")
				self.VandalPosition = hrp.Position
			end
			--// Cache the vigilante's position
			if self.Vigilante then
				local vigilanteChar = self.Vigilante.plr.Character or self.Vigilante.plr.CharacterAdded:Wait()
				local hrp = vigilanteChar:WaitForChild("HumanoidRootPart")
				self.VigilantePosition = hrp.Position
			end

			--// If item disappeared from game
			if not self.Vigilante then
				if not checkForItemDropped("Gun") then
					--// Give random player vigilante role
					setRole:Fire("Vigilante", self.Innocents[random:NextInteger(1, #self.Innocents)])
				end
			end
			if not self.Vandal then
				if not checkForItemDropped("Spray") then
					--// Give random player vandal role
					setRole:Fire("Vandal", self.Innocents[random:NextInteger(1, #self.Innocents)])
				end
			end
		end))

		--// Handle the round ending
		self._maid:GiveTask(roundTimer.Ended:Connect(function()
			--// End round with "TimeOut" argument
			victoryScreen:FireAllClients("InnocentsWin")
			self:EndRound("TimeOut")
			--// Fire roundEnded bindable event and remove disconnect
			self._roundEnded:Fire()
			self._maid:Destroy()
		end))

		--// Fires when the timer is deliberately stopped
		self._maid:GiveTask(roundTimer.Stopped:Connect(function()
			self._roundEnded:Fire()
			self._maid:Destroy()
		end))
		--// Give player proper data when they receive a goal
		self._maid:GiveTask(setRole.Event:Connect(function(role, plr)
			return role == "Vandal" and giveVandal(plr) or role == "Vigilante" and giveVigilante(plr)
		end))
		
		--//Fires when a player dies and a round is in progress
		self._maid:GiveTask(deathEvent.Event:Connect(function(plr)
			--// Remove player from spectate list
			if table.find(self.spectateList, plr) ~= -1 then
				table.remove(self.spectateList, table.find(self.spectateList, plr))
			end
			--// Re-enable player UI
			proximity:DisablePlayer(plr)
			enableInventory:FireClient(plr)
			enableSpectate:FireClient(plr, self.spectateList)
			enableShop:FireClient(plr)
			enableCodesUI:FireClient(plr)
			--// Remove player from current spectate list
			updateSpectate:FireAllClients(plr)
			--// Clear player's backpack
			plr.Backpack:ClearAllChildren()
			--// Check and clear data of player who dies
			if roles[plr] == "Murderer" then
				--// Murderer is killed, end the game
				self:EndRound("InnocentsWin")
				roundTimer:Stop()
			elseif roles[plr] == "Vandal" then
				--// Drop player's item and remove them from their role
				self.Vandal.item:DropItem(self.VandalPosition)
				self.Vandal = nil
				--// Show the murderer
				visbilityToggle:FireClient(plr, self.Murderer.plr, true)
				print(allButMurderer)
			elseif roles[plr] == "Vigilante" then
				--// Drop player's item and remove them from their role
				self.Vigilante.item:DropItem(self.VigilantePosition)
				self.Vigilante = nil
				--// Show the murderer
				visbilityToggle:FireClient(plr, self.Murderer.plr, true)
			elseif roles[plr] == "Innocent" then
				--// Remove player from innocent table
				self.Innocents[plr] = nil
				--// Show the murderer
				visbilityToggle:FireClient(plr, self.Murderer.plr, true)
			end
			--// If player is not murderer, remove them from the allButMurderer table.
			if table.find(allButMurderer, plr) then
				table.remove(allButMurderer, table.find(allButMurderer, plr))
			end
			--// Remove player from roles table
			roles[plr] = nil
			--// Check if every non-murderer is dead
			if #allButMurderer == 0 then
				--// Give player tickets, premium currency
				stats:GiveTickets(1, self.Murderer.plr)
				--// Fire victory condition for the murderer winning
				self:EndRound("MurdererWins")
				--// Stop the timer
				roundTimer:Stop()
			end
		end))
	end))
end

local twitchEvent = events:WaitForChild("CheckTwitch")

--// End a round and fire the corresponding win condition in the table
function originalModeClass:EndRound(winCondition)
	victoryScreen:FireAllClients(winCondition)
	--// Disable ProximityDetection
	proximity:Disable()
	--// Remove player roles
	if self.Vandal then
		self.Vandal:EndClass()
	elseif self.Vigilante then
		self.Vigilante:EndClass()
	end
	if self.Murderer.item then
		self.Murderer.item:Destroy()
	end
	--// Clear all dropped items
	game.Workspace.Drops:ClearAllChildren()
	--// Enable UI for the player
	game.ReplicatedStorage.UIComponents.UIEvents.EnableShop:FireAllClients()

	--// Manage UI
	enableInventory:FireAllClients()
	enableCodesUI:FireAllClients()
	disableSpectate:FireAllClients()
	--wait(2)
	--// Give players rewards and reset them
	for _, v in pairs(game.Players:GetPlayers()) do
		v:LoadCharacter()
		stats:GiveExp(100, v)
		stats:GiveCoins(50, v)
		twitchEvent:Fire(v)
	end
	--// Clear the map
	game.Workspace.CurrentMap:ClearAllChildren()
end

return originalModeClass