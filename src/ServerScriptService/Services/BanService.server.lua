local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

local banDatastore = DataStoreService:GetDataStore("Bans")

game.Players.PlayerAdded:Connect(function(plr)
    local store = banDatastore:GetAsync("IDTable")
    for _, id in pairs(store) do
        if id == plr.UserId then
            plr:Kick("Ur banned.")
        end
    end
end)

