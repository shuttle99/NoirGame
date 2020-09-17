local PlayerHandler = {}
PlayerHandler.PlayerList = {}

--// Services
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BadgeService = game:GetService("BadgeService")

--// Folders
local Modules = ServerScriptService:WaitForChild("Modules")
local Events = ReplicatedStorage:WaitForChild("Events")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local UIComponents = ReplicatedStorage:WaitForChild("UIComponents")

--// Modules
local gamepasses = require(Modules:WaitForChild("Gamepasses"))
local ds = require(Modules:WaitForChild("Init"))
local scheduler = require(Shared:WaitForChild("Scheduler"))
local ChanceHandler = require(Modules:WaitForChild("ChanceHandler"))
local DailyRewards = require(Modules:WaitForChild("DailyRewards"))

--// Events
local TogglePlayerInGame = Events:WaitForChild("TogglePlayerInGame")

local function createLeaderstat(player, name, value)
	local stat = Instance.new("IntValue")
	stat.Parent = player.leaderstats
	stat.Name = name
	stat.Value = value
end

function PlayerHandler:RegisterPlayer(player)
	local dataObj = ds.new(player)
	ChanceHandler:RegisterPlayerChance(player)
	dataObj.VisitDay:Set(os.date("%j") + 4)
	DailyRewards:GiveReward(player)

	--// Print
	print(ChanceHandler:QueryPlayer(player, "Murderer"))

    table.insert(PlayerHandler.PlayerList, player)

    BadgeService:AwardBadge(player.UserId, 2124573793)
	gamepasses:CheckForPasses(player)
	
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	createLeaderstat(player, "Level", dataObj.Level:Get())
	createLeaderstat(player, "Cash", dataObj.Cash:Get())
	createLeaderstat(player, "Wins", dataObj.Wins:Get())

	dataObj.Level:OnUpdate(function(val)
		player.Level.Value = val
	end)
 
	dataObj.Cash:OnUpdate(function(val)
		player.Cash.Value = val
	end)

	dataObj.Wins:OnUpdate(function(val)
		player.Wins.Value = val
	end)
	
	local visitTimer = scheduler.new(3)
	visitTimer:Start()
	visitTimer.Ended:Connect(function()
		dataObj.Visits:Increment(1)
	end)
end

function PlayerHandler:TogglePlayer(player)
	if table.find(PlayerHandler.PlayerList, player) then
		ChanceHandler:MarkPlayerIneligble(player)
        table.remove(PlayerHandler.PlayerList, table.find(PlayerHandler.PlayerList, player))
	else
		ChanceHandler:MarkPlayerEligble(player)
        table.insert(PlayerHandler.PlayerList, player)
    end
end

--// Remove player from list if they choose to go AFK
TogglePlayerInGame.OnServerEvent:Connect(function(player)
    PlayerHandler:TogglePlayer(player)
end)

return PlayerHandler