local replicatedStorage = game:GetService("ReplicatedStorage")
local BadgeService = game:GetService("BadgeService")
local events = replicatedStorage.Events
local deathEvent = events.DeathEvent
local data = require(game.ServerScriptService.Modules.Init)
local gamepasses = require(game.ServerScriptService.Modules.Gamepasses)
local statIncrementer = require(game.ServerScriptService.Modules.StatIncrementer)
local connection1
local connection2

local devProducts = require(game.ServerScriptService.Modules.DevProducts)

local function fireDeath(plr)
	deathEvent:Fire(plr)
end

game.Players.PlayerAdded:Connect(function(plr)

	local test2 = game.ReplicatedStorage.UIComponents.UIEvents.EnableInventory
	test2:FireClient(plr)

	BadgeService:AwardBadge(plr.UserId, 2124573793)

	local dataObj = data.new(plr) --// Yield caused here
	gamepasses:CheckForPasses(plr)
	
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = plr

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

	dataObj.VisitCount:Increment(1)

	connection2 = plr.CharacterAdded:Connect(function(char)
		char.Humanoid.Died:Connect(function()
			fireDeath(plr)
		end)
	end)
end)

game.Players.PlayerRemoving:Connect(function(plr)
	fireDeath(plr)
end)