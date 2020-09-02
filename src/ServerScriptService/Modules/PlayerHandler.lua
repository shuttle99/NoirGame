local PlayerHandler = {}
PlayerHandler.PlayerList = {}

--// Services
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BadgeService = game:GetService("BadgeService")

--// Folders
local Modules = ServerScriptService:WaitForChild("Modules")
local Events = ReplicatedStorage:WaitForChild("Events")

--// Modules
local gamepasses = require(Modules:WaitForChild("Gamepasses"))
local ds = require(Modules:WaitForChild("Init"))

--// Events
local TogglePlayerInGame = Events:WaitForChild("TogglePlayerInGame")

function PlayerHandler:RegisterPlayer(player)
    local dataObj = ds.new(player)
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

	dataObj.Tickets:OnUpdate(function(val)
		ticketStat.Value = val
	end)

	dataObj.Level:OnUpdate(function(val)
		levelStat.Value = val
	end)

	dataObj.Cash:OnUpdate(function(val)
		cashStat.Value = val
	end)
end

function PlayerHandler:TogglePlayer(player)
    if table.find(PlayerHandler.PlayerList, player) then
        table.remove(PlayerHandler.PlayerList, table.find(PlayerHandler.PlayerList, player))
    else
        table.insert(PlayerHandler.PlayerList, player)
    end
end

--// Remove player from list if they choose to go AFK
TogglePlayerInGame.OnServerEvent:Connect(function(player)
    PlayerHandler:TogglePlayer(player)
end)

return PlayerHandler