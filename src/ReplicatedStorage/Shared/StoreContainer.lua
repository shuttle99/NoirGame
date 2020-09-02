local storeContainer = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local itemModels = ReplicatedStorage:WaitForChild("ItemModels")
local assets = ServerStorage:WaitForChild("Assets")

storeContainer.Knives = {}
storeContainer.Sprays = {}
storeContainer.Guns = {}

function storeContainer:Init()
	for _, folder in pairs(assets.Items:GetChildren()) do
		local reference
		if folder.Name == "Murderer" then
			reference = "Knives"
		elseif folder.Name == "Vandal" then
			reference = "Sprays"
		elseif folder.Name == "Vigilante" then
			reference = "Guns"
		end
		for _, item in pairs(folder:GetChildren()) do
			if itemModels:FindFirstChild(item.Name) and item.Name ~= "Spray" then
				local itemModel = itemModels:FindFirstChild(item.Name)
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

--// To do 
--[[
	write an init method for this to be called only once in a service, then reference it otherwise to prevent serverstorage loading issue7
]]

return storeContainer