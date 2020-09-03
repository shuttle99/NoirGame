local RoundHandler = {}
print("Round handler successfully required")

--// Services
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local ServerStorage = game:GetService("ServerStorage")

--// Folders
local Modules = ServerScriptService:WaitForChild("Modules")
local Classes = Modules:WaitForChild("Classes")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Assets = ServerStorage:WaitForChild("Assets")
local Maps = Assets:WaitForChild("Maps")
local CurrentMap = game.Workspace:WaitForChild("CurrentMap")
local UIComponents = ReplicatedStorage:WaitForChild("UIComponents")
local UIEvents = UIComponents:WaitForChild("UIEvents")

--// Modules
local OriginalGamemode = require(Classes:WaitForChild("OriginalGamemodeClass"))
local Scheduler = require(Shared:WaitForChild("Scheduler"))
local Maid = require(Shared:WaitForChild("Maid"))
local PlayerHandler = require(Modules:WaitForChild("PlayerHandler"))

--// Events
local udpateTimer = UIEvents:WaitForChild("TimerUpdateEvent")

--// Variables
local round
local _maid = Maid.new()
local random = Random.new()

local function chooseMap()
    local mapTable = Maps:GetChildren()
	local map = mapTable[random:NextInteger(1, #mapTable)]:Clone()
	map.Parent = CurrentMap

	--// Set Config of map
	for _, value in pairs(map.MapConfig:GetChildren()) do
		if value.Name ~= "RoundTime" and value.Name ~= "Thumbnail" then
			if Lighting[value.Name] then
				Lighting[value.Name] = value.Value
			end
		end
	end

	RoundHandler.roundTime = map.MapConfig.RoundTime.Value
end

local function intermission()
    game.Workspace.CurrentMap:ClearAllChildren()
    local intermissionTimer = Scheduler.new(30)
    intermissionTimer:Start()
    
    _maid:GiveTask(intermissionTimer.Tick:Connect(function()
        udpateTimer:FireAllClients("Intermission " .. intermissionTimer.CurrentTime)
        if intermissionTimer.CurrentTime == 5 then
            chooseMap()
        end
    end))

    intermissionTimer.Ended:Connect(function()
        RoundHandler:CheckForPlayers()
    end)
end

local function startRound()
    if not round then
        round = OriginalGamemode.new(PlayerHandler.PlayerList, RoundHandler.roundTime)

        round._roundEnded.Event:Connect(function()
            round = nil
            _maid:DoCleaning()
            intermission()
        end)
    end
end

function RoundHandler:RegisterDeath(player)
    print("Death detected")
    if round then
        round:CheckDeath(player)
    end
end

function RoundHandler:RemovePlayer(player)
    if table.find(PlayerHandler.PlayerList, player) then
        table.remove(PlayerHandler.PlayerList, table.find(PlayerHandler.PlayerList, player))
    end
end

function RoundHandler:CheckForPlayers()
    if #PlayerHandler.PlayerList >= 4 then
        startRound()
    else
        intermission()
    end
end

intermission()

return RoundHandler