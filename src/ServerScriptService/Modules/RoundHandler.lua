local RoundHandler = {}
print("Round handler successfully required")

--// Services
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local ServerStorage = game:GetService("ServerStorage")

--// Folders
local Modules = ServerScriptService:WaitForChild("Modules")
local Classes = Modules:WaitForChild("Classes")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Assets = ServerStorage:WaitForChild("Assets")
local Maps = Assets:WaitForChild("Maps"):GetChildren()
local CurrentMap = Workspace:WaitForChild("CurrentMap")

--// Modules
local OriginalGamemode = require(Classes:WaitForChild("OriginalGamemodeClass"))
local Scheduler = require(Shared:WaitForChild("Scheduler"))
local Maid = require(Shared:WaitForChild("Maid"))
local PlayerHandler = require(Modules:WaitForChild("PlayerHandler"))


--// Variables
local round
local roundTime
local _maid = Maid.new()
local random = Random.new()

local function chooseMap()
	local map = Maps[random:NextInteger(1, #Maps)]:Clone()
	map.Parent = CurrentMap

	--// Set Config of map
	for _, value in pairs(map.MapConfig:GetChildren()) do
		if value.Name ~= "RoundTime" and value.Name ~= "Thumbnail" then
			if Lighting[value.Name] then
				Lighting[value.Name] = value.Value
			end
		end
	end

	roundTime = map.MapConfig.RoundTime.Value
end

local function intermission()
    local intermissionTimer = Scheduler.new(30)
    intermissionTimer:Start()
    
    _maid:GiveTask(intermissionTimer.Tick:Connect(function()
        print(intermissionTimer.CurrentTime)
    end))

    if intermissionTimer.CurrentTime == 5 then
        chooseMap()
    end

    intermissionTimer.Ended:Connect(function()
        RoundHandler:CheckForPlayers()
    end)
end

local function startRound()
    if not round then
        round = OriginalGamemode.new(PlayerHandler.PlayerList, roundTime)

        round._roundEnded.Event:Connect(function()
            round = nil
            _maid:DoCleaning()
            intermission()
        end)
    end
end

function RoundHandler:RegisterDeath(player)
    if round then
        round:CheckDeath(player)
    end
end

function RoundHandler:CheckForPlayers()
    if #PlayerHandler.PlayerList >= 4 then
        startRound()
    end
end

return RoundHandler