local ChanceHandler = {}
local random = Random.new()

ChanceHandler.IneligblePlayers = {}

--// Concatinate string to reference table
local function chanceOf(role)
    return role .. "Chances"
end

--// Give a new player their chance value
function ChanceHandler:RegisterPlayerChance(player)
    --// To do, check if player has proper gamepasses
    ChanceHandler["MurdererChance"][player] = 1
    ChanceHandler["VigilanteChance"][player] = 1
    ChanceHandler["VandalChance"][player] = 1
end

function ChanceHandler:RemovePlayer(player)
    ChanceHandler["MurdererChance"][player] = nil
    ChanceHandler["VigilanteChance"][player] = nil
    ChanceHandler["VandalChance"][player] = nil

    if table.find(ChanceHandler.IneligblePlayers, player) then
        table.remove(table.find(ChanceHandler.IneligblePlayers, player))
    end
end

--// Reset a chance for specific role
function ChanceHandler:ResetPlayerChance(player, role)
    ChanceHandler[chanceOf(role)][player] = 1
end

--// Increase player's chances
function ChanceHandler:IncreasePlayerChance(player, role, value)
    return ChanceHandler[chanceOf(role)][player] += value
end

--// Set a player's chance for role
function ChanceHandler:SetPlayerChance(player, role, value)
    return ChanceHandler[chanceOf(role)][player] = value
end

--// Returns the chance table for corresponding role
function ChanceHandler:QueryChances(role)
    return ChanceHandler[chanceOf(role)]
end

--// Returns chance for all roles or specific role of player
function ChanceHandler:QueryPlayer(player, role)
    --// Table of chances for specific plyaer
    local roleTable = {
        ["Murderer"] = ChanceHandler.MurdererChances[player],
        ["Vigilante"] = ChanceHandler.VigilanteChances[player],
        ["Vandal"] = ChanceHandler.VandalChances[player]
    }

    --// If role specified, return its chance, otherwise return chance of all 3 roles
    return role and ChanceHandler[chanceOf(role)][player] or roleTable
end

--// Mark player as ineligible for choosing
function ChanceHandler:MarkPlayerIneligible(player)
    table.insert(ChanceHandler.IneligblePlayers, player)
end

--// Mark player as eligible for choosing
function ChanceHandler:MarkPlayerEligble(player)
    if table.find(ChanceHandler.IneligblePlayers, player) then
        table.remove(ChanceHandler.IneligiblePlayers, player)
    end
end

--// Return player with highest value for a role
function ChanceHandler:GetHighestChance(role)
    local highestValue = 0
    local highestPlayer
    local tieTable = {}
    
    --// Get highest number in table
    for player, chance in pairs(ChanceHandler[chanceOf(role)]) do
        if not table.find(ChanceHandler.IneligblePlayers) then
            if chance > highestValue then
                tieTable = {}
                highestValue = chance
                highestPlayer = player
            elseif chance == highestValue then
                table.insert(tieTable, highestPlayer)
                table.insert(tieTable, player)
            end
        end
    end

    if #tieTable >= 2 then
        highestPlayer = tieTable[Random:NextInteger(1, #tieTable)]
        highestValue = ChanceHandler[chanceOf(role)][highestPlayer]
    end

    --// Make player ineligble for the duration
    ChanceHandler:MarkPlayerIneligble(highestPlayer)
    ChanceHandler:ResetChance(highestPlayer)
    return highestPlayer
end

return ChanceHandler