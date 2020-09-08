local Players = game:GetService("Players")

local bannedPlrs = {173259012, 635030720, 113389871}

game.Players.PlayerAdded:Connect(function(plr)
    for _, id in pairs(bannedPlrs) do
        if id == plr.UserId then
            plr:Kick("Ur banned.")
        end
    end
end)

