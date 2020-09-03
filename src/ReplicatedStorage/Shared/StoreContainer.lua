local storeContainer = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local itemModels = ReplicatedStorage:WaitForChild("ItemModels")

local Events = ReplicatedStorage:WaitForChild("Events")
local queryStoreData = Events:WaitForChild("QueryStoreData")

storeContainer.Knives = {}
storeContainer.Sprays = {}
storeContainer.Guns = {}

function storeContainer:Init()
	local ServerStorage = game:GetService("ServerStorage")
	local assets = ServerStorage:WaitForChild("Assets")
	for _, folder in pairs(assets.Items:GetChildren()) do
		local reference
		if folder.Name == "Murderer" then
			reference = "Knives"
		elseif folder.Name == "Vandal" then
			reference = "Sprays"
		elseif folder.Name == "Vigilante" then
			reference = "Guns"
		end
		if folder.Name == "Vandal" then
			for _, item in pairs(folder.Sprays:GetChildren()) do
				if itemModels:FindFirstChild(item.Name) and item.Name ~= "Spray" then
					local itemModel = itemModels:FindFirstChild(item.Name)
					if not itemModel:FindFirstChild("Code") then
						storeContainer[reference][itemModel.Name] = {
							["Name"] = itemModel:WaitForChild("Name").Value,
							["Description"] = itemModel:WaitForChild("Description").Value,
							["Price"] = itemModel:WaitForChild("Price").Value
						}
						if itemModel:FindFirstChild("Gamepass") then
							storeContainer[reference][item.Name]["Gamepass"] = itemModel.Gamepass.Value
						end
					end
				end
			end
		else
			for _, item in pairs(folder:GetChildren()) do
				if itemModels:FindFirstChild(item.Name) and item.Name ~= "Spray" then
					local itemModel = itemModels:FindFirstChild(item.Name)
					if not itemModel:FindFirstChild("Code") then
						print(itemModel.Name)
						storeContainer[reference][itemModel.Name] = {
							["Name"] = itemModel:WaitForChild("Name").Value,
							["Description"] = itemModel:WaitForChild("Description").Value,
							["Price"] = itemModel:WaitForChild("Price").Value
						}
						if itemModel:FindFirstChild("Gamepass") then
							storeContainer[reference][item.Name]["Gamepass"] = itemModel.Gamepass.Value
						end
					end
				end
			end
		end
	end
end

if RunService:IsServer() then
	queryStoreData.OnServerInvoke = function()
		return storeContainer
	end
end

--// To do 
--[[
	write an init method for this to be called only once in a service, then reference it otherwise to prevent serverstorage loading issue7
]]

return storeContainer