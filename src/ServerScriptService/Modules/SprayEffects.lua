local sprayEffects = {
    ["StandardSpray"] = function(char)
        local plr = game.Players:GetPlayerFromCharacter(char)
        plr:ClearCharacterAppearance()
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then 
                part.Color = Color3.fromRGB(255, 0, 0)
            end
        end
    end,
    ["GreenSpray"] = function(char)
        local plr = game.Players:GetPlayerFromCharacter(char)
        plr:ClearCharacterAppearance()
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then 
                part.Color = Color3.fromRGB(0,255, 0)
            end
        end
    end,
    ["BlueSpray"] = function(char)
        local plr = game.Players:GetPlayerFromCharacter(char)
        plr:ClearCharacterAppearance()
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then 
                part.Color = Color3.fromRGB(0, 0, 255)
            end
        end
    end,
    ["WhiteSpray"] = function(char)
        local plr = game.Players:GetPlayerFromCharacter(char)
        plr:ClearCharacterAppearance()
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then 
                part.Color = Color3.fromRGB(248, 248, 248)
            end
        end
    end,
    ["GoldSpray"] = function(char)
        local plr = game.Players:GetPlayerFromCharacter(char)
        plr:ClearCharacterAppearance()
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then 
                part.Color = Color3.fromRGB(249, 166, 2)
            end
        end
    end,
    ["BlackSpray"] = function(char)
        local plr = game.Players:GetPlayerFromCharacter(char)
        plr:ClearCharacterAppearance()
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then 
                part.Color = Color3.fromRGB(0, 0, 0)
            end
        end
    end,
    ["OrangeSpray"] = function(char)
        local plr = game.Players:GetPlayerFromCharacter(char)
        plr:ClearCharacterAppearance()
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then 
                part.Color = Color3.fromRGB(255, 125, 0)
            end
        end
    end,
    ["TealSpray"] = function(char)
        local plr = game.Players:GetPlayerFromCharacter(char)
        plr:ClearCharacterAppearance()
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then 
                part.Color = Color3.fromRGB(0, 255, 255)
            end
        end
    end,
    ["PurpleSpray"] = function(char)
        local plr = game.Players:GetPlayerFromCharacter(char)
        plr:ClearCharacterAppearance()
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then 
                part.Color = Color3.fromRGB(255, 0, 255)
            end
        end
    end,
    ["YellowSpray"] = function(char)
        local plr = game.Players:GetPlayerFromCharacter(char)
        plr:ClearCharacterAppearance()
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then 
                part.Color = Color3.fromRGB(255, 255, 0)
            end
        end
    end,
    ["FireSpray"] = function(char)
        local plr = game.Players:GetPlayerFromCharacter(char)
        game.ReplicatedStorage.ItemModels.FireSpray.Head.ParticleEmitter:Clone().Parent = char.Head
        plr:ClearCharacterAppearance()
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then 
                part.Color = Color3.fromRGB(67, 29, 29)
            end
        end
    end,
    ["IceSpray"] = function(char)
        local plr = game.Players:GetPlayerFromCharacter(char)
        local cloneHat = game.ReplicatedStorage.ItemModels.IceSpray.IceCube:Clone()
        cloneHat.Parent = char
        char.Humanoid:AddAccessory(cloneHat)
        plr:ClearCharacterAppearance()
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then 
                part.Transparency = 0.5
                part.Color = Color3.fromRGB(175, 221, 255)
            end
        end
    end,
    ["RainbowSpray"] = function(char)
        local plr = game.Players:GetPlayerFromCharacter(char)
        plr:ClearCharacterAppearance()
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
        plr:ClearCharacterAppearance()
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
        plr:ClearCharacterAppearance()
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