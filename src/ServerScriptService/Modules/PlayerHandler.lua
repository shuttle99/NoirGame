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

--// Modules
local gamepasses = require(Modules:WaitForChild("Gamepasses"))
print("1")
local ds = require(Modules:WaitForChild("Init"))
print("2")
local scheduler = require(Shared:WaitForChild("Scheduler"))
print("3")
local ChanceHandler = require(Modules:WaitForChild("ChanceHandler"))
print("4")
local dailyRewards = require(Modules:WaitForChild("DailyRewards"))
print("5")

--// Events
local TogglePlayerInGame = Events:WaitForChild("TogglePlayerInGame")

print("H")

function PlayerHandler:RegisterPlayer(player)
	local dataObj = ds.new(player)
	ChanceHandler:RegisterPlayerChance(player)
	dailyRewards:GiveReward(player)
	dataObj.VisitDay:Set(os.date("%j"))
	--// Print
	print(ChanceHandler:QueryPlayer(player, "Murderer"))

    table.insert(PlayerHandler.PlayerList, player)

    BadgeService:AwardBadge(player.UserId, 2124573793)
	gamepasses:CheckForPasses(player)
	
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local levelStat = Instance.new("IntValue")
	levelStat.Name = "Level"
	levelStat.Value = dataObj.Level:Get()
	levelStat.Parent = leaderstats
	
	local cashStat = Instance.new("IntValue")
	cashStat.Name = "Cash"
	cashStat.Value = dataObj.Cash:Get()
	cashStat.Parent = leaderstats

	local ticketStat = Instance.new("IntValue")
	ticketStat.Name = "Tickets"
	ticketStat.Value = dataObj.Tickets:Get()
	ticketStat.Parent = leaderstats

	dataObj.Level:OnUpdate(function(val)
		levelStat.Value = val
	end)
 
	dataObj.Cash:OnUpdate(function(val)
		cashStat.Value = val
	end)
	
	local visitTimer = scheduler.new(3)
	visitTimer:Start()
	visitTimer.Ended:Connect(function()
		dataObj.Visits:Increment(1)
	end)

	--// Check if player is in vector three group
	local GROUP_ID = 6273742

	if player:IsInGroup(GROUP_ID) then
		print("Player is in group.")
	end
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