--CheekyVisuals
--9/14/2020
--Handles os.time() operations in game

--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Folders
local Events = ReplicatedStorage:WaitForChild("Events")

--// Events
--[[local checkShopReset = Events:WaitForChild("CheckShopReset")

--// Event connections
checkShopReset.OnClientInvoke = function()
    return os.date("%j")
end]]

print(os.date("%j"))