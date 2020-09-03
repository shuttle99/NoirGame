local sprayEffects = {
    ["StandardSpray"] = function(char)
        for _, part in pairs(char:GetDescendants()) do
			if part:IsA("Shirt") or part:IsA("Pants") or part:IsA("Decal") then 
                part:Destroy()
            elseif part:IsA("BasePart") then 
                part.Color = Color3.fromRGB(255, 0, 0)
            elseif part:IsA("SpecialMesh") then
                part.TextureId = ""
            end
        end
    end,
    ["GreenSpray"] = function(char)
        for _, part in pairs(char:GetDescendants()) do
			if part:IsA("Shirt") or part:IsA("Pants") or part:IsA("Decal") then 
                part:Destroy()
            elseif part:IsA("BasePart") then 
                part.Color = Color3.fromRGB(0, 255, 0)
            elseif part:IsA("SpecialMesh") then
                part.TextureId = ""
            end
        end
    end,
    ["BlueSpray"] = function(char)
        for _, part in pairs(char:GetDescendants()) do
			if part:IsA("Shirt") or part:IsA("Pants") or part:IsA("Decal") then 
                part:Destroy()
            elseif part:IsA("BasePart") then 
                part.Color = Color3.fromRGB(0, 0, 255)
            elseif part:IsA("SpecialMesh") then
                part.TextureId = ""
            end
        end
    end,
    ["WhiteSpray"] = function(char)
        for _, part in pairs(char:GetDescendants()) do
			if part:IsA("Shirt") or part:IsA("Pants") or part:IsA("Decal") then 
                part:Destroy()
            elseif part:IsA("BasePart") then 
                part.Color = Color3.fromRGB(248, 248, 248)
            elseif part:IsA("SpecialMesh") then
                part.TextureId = ""
            end
        end
    end,
    ["GoldSpray"] = function(char)
        for _, part in pairs(char:GetDescendants()) do
			if part:IsA("Shirt") or part:IsA("Pants") or part:IsA("Decal") then 
                part:Destroy()
            elseif part:IsA("BasePart") then 
                part.Color = Color3.fromRGB(249, 166, 2)
            elseif part:IsA("SpecialMesh") then
                part.TextureId = ""
            end
        end
    end,
    ["BlackSpray"] = function(char)
        for _, part in pairs(char:GetDescendants()) do
			if part:IsA("Shirt") or part:IsA("Pants") or part:IsA("Decal") then 
                part:Destroy()
            elseif part:IsA("BasePart") then 
                part.Color = Color3.fromRGB(14, 14, 14)
            elseif part:IsA("SpecialMesh") then
                part.TextureId = ""
            end
        end
    end,
    ["OrangeSpray"] = function(char)
        for _, part in pairs(char:GetDescendants()) do
			if part:IsA("Shirt") or part:IsA("Pants") or part:IsA("Decal") then 
                part:Destroy()
            elseif part:IsA("BasePart") then 
                part.Color = Color3.fromRGB(255, 125, 0)
            elseif part:IsA("SpecialMesh") then
                part.TextureId = ""
            end
        end
    end,
    ["TealSpray"] = function(char)
        for _, part in pairs(char:GetDescendants()) do
			if part:IsA("Shirt") or part:IsA("Pants") or part:IsA("Decal") then 
                part:Destroy()
            elseif part:IsA("BasePart") then 
                part.Color = Color3.fromRGB(0, 255, 255)
            elseif part:IsA("SpecialMesh") then
                part.TextureId = ""
            end
        end
    end,
    ["PurpleSpray"] = function(char)
        for _, part in pairs(char:GetDescendants()) do
			if part:IsA("Shirt") or part:IsA("Pants") or part:IsA("Decal") then 
                part:Destroy()
            elseif part:IsA("BasePart") then 
                part.Color = Color3.fromRGB(255, 0, 255)
            elseif part:IsA("SpecialMesh") then
                part.TextureId = ""
            end
        end
    end,
    ["YellowSpray"] = function(char)
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("Shirt") or part:IsA("Pants") or part:IsA("Decal") then 
                part:Destroy()
       		elseif part:IsA("BasePart") then 
                part.Color = Color3.fromRGB(255, 255, 0)
            elseif part:IsA("SpecialMesh") then
                part.TextureId = ""
            end
        end
    end,
    ["FireSpray"] = function(char)
        game.ReplicatedStorage.ItemModels.FireSpray.Head.ParticleEmitter:Clone().Parent = char.Head
        for _, part in pairs(char:GetDescendants()) do
			if part:IsA("Shirt") or part:IsA("Pants") or part:IsA("Decal") then 
                part:Destroy()
            elseif part:IsA("BasePart") then 
                part.Color = Color3.fromRGB(69, 29, 29)
            elseif part:IsA("SpecialMesh") then
                part.TextureId = ""
            end
        end
    end,
    ["IceSpray"] = function(char)
        local cloneHat = game.ReplicatedStorage.ItemModels.IceSpray.IceCube:Clone()
        char.Humanoid:AddAccessory(cloneHat)
        for _, part in pairs(char:GetDescendants()) do
			if part:IsA("Shirt") or part:IsA("Pants") or part:IsA("Decal") then 
                part:Destroy()
            elseif part:IsA("BasePart") then 
				if part.Name ~= "HumanoidRootPart" or not part.Parent:IsA("Tool") then
					part.Transparency = 0.5
				end
                part.Color = Color3.fromRGB(175, 221, 225)
            elseif part:IsA("SpecialMesh") then
                part.TextureId = ""
            elseif part:IsA("Accessory") then
				part:Destroy()
			end
        end
    end,
    ["RainbowSpray"] = function(char)
        local plr = game.Players:GetPlayerFromCharacter(char)
		for _, part in pairs(char:GetDescendants()) do
			if part:IsA("Shirt") or part:IsA("Pants") or part:IsA("Decal") then 
               	part:Destroy()
			end
		end
        for _, texture in pairs(game.ReplicatedStorage.ItemModels.RainbowSpray:GetDescendants()) do
            if texture:IsA("Decal") then
                texture:Clone().Parent = char:FindFirstChild(texture.Parent.Name)
            elseif texture:IsA("BasePart") then
                if char:FindFirstChild(texture.Name) then
                    char[texture.Name].Color = texture.Color
                end
            end
        end
    end,
    ["TicketSpray"] = function(char)
        local plr = game.Players:GetPlayerFromCharacter(char)
		for _, part in pairs(char:GetDescendants()) do
			if part:IsA("Shirt") or part:IsA("Pants") or part:IsA("Decal") then 
               	part:Destroy()
			end
		end
        for _, texture in pairs(game.ReplicatedStorage.ItemModels.TicketSpray:GetDescendants()) do
            if texture:IsA("Decal") then
                texture:Clone().Parent = char:FindFirstChild(texture.Parent.Name)
            elseif texture:IsA("BasePart") then
                if char:FindFirstChild(texture.Name) then
                    char[texture.Name].Color = texture.Color
                end
            end
        end
    end,
    ["MonochromeSpray"] = function(char)
        local plr = game.Players:GetPlayerFromCharacter(char)
		for _, part in pairs(char:GetDescendants()) do
			if part:IsA("Shirt") or part:IsA("Pants") or part:IsA("Decal") then 
               	part:Destroy()
			end
		end
        for _, texture in pairs(game.ReplicatedStorage.ItemModels.MonochromeSpray:GetDescendants()) do
            if texture:IsA("Decal") then
                texture:Clone().Parent = char:FindFirstChild(texture.Parent.Name)
            elseif texture:IsA("BasePart") then
                if char:FindFirstChild(texture.Name) then
                    char[texture.Name].Color = texture.Color
                end
            end
        end
    end,
}

return sprayEffects