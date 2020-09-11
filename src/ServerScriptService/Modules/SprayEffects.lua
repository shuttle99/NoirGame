local function clearAppearance(char)
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("Shirt") or part:IsA("Pants") or part:IsA("Decal") then 
            part:Destroy()
        end
    end
end

local function setBaseColor(char, color)
    clearAppearance(char)
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Color = color
        elseif part:IsA("SpecialMesh") then
            part.TextureId = ""
        end
    end
end

local sprayEffects = {
    ["StandardSpray"] = function(char)
        setBaseColor(char, Color3.fromRGB(255, 0, 0))
    end,
    ["GreenSpray"] = function(char)
        setBaseColor(char, Color3.fromRGB(0, 255, 0))
    end,
    ["BlueSpray"] = function(char)
        setBaseColor(char, Color3.fromRGB(0, 0, 255))
    end,
    ["WhiteSpray"] = function(char)
        setBaseColor(char, Color3.fromRGB(248, 248, 248))
    end,
    ["GoldSpray"] = function(char)
        setBaseColor(char, Color3.fromRGB(249, 166, 2))
    end,
    ["BlackSpray"] = function(char)
        setBaseColor(char, Color3.fromRGB(14, 14, 14))
    end,
    ["OrangeSpray"] = function(char)
        setBaseColor(char, Color3.fromRGB(255, 125, 0))
    end,
    ["TealSpray"] = function(char)
        setBaseColor(char, Color3.fromRGB(0, 255, 255))
    end,
    ["PurpleSpray"] = function(char)
        setBaseColor(char,Color3.fromRGB(255, 0, 255) )
    end,
    ["YellowSpray"] = function(char)
        setBaseColor(char, Color3.fromRGB(255, 255, 0))
    end,
    ["FireSpray"] = function(char)
        game.ReplicatedStorage.ItemModels.FireSpray.Head.ParticleEmitter:Clone().Parent = char.Head
        setBaseColor(char, Color3.fromRGB(69, 29, 29))
    end,
    ["IceSpray"] = function(char)
        local cloneHat = game.ReplicatedStorage.ItemModels.IceSpray.IceCube:Clone()
        clearAppearance(char)
        char.Humanoid:AddAccessory(cloneHat)
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then 
				if part.Name ~= "HumanoidRootPart" or not part.Parent:IsA("Tool") then
					part.Transparency = 0.5
				end
                part.Color = Color3.fromRGB(175, 221, 225)
            elseif part:IsA("SpecialMesh") then
                part.TextureId = ""
            elseif part:IsA("Accessory")  then
				part:Destroy()
			end
        end
    end,
    ["RainbowSpray"] = function(char)
        local plr = game.Players:GetPlayerFromCharacter(char)
		clearAppearance(char)
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
		clearAppearance(char)
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
		clearAppearance(char)
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