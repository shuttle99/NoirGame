--[[
    Handle visuals behind cash purchasing
]]
local cashPurchase = {}
cashPurchase.__index = cashPurchase

--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Folders
local uiComponents = ReplicatedStorage:WaitForChild("UIComponents")

function cashPurchase.new(plr)
    local self = setmetatable({
        plr = plr,
        ui = uiComponents:WaitForChild("DevProductsFrame"):Clone()
    }, cashPurchase)

    self.ui.Parent = self.plr.PlayerGui:WaitForChild("GameUI")

    return self
end

function cashPurchase:Show()
    self.ui.Visible = true
end

function cashPurchase:Hide()
    self.ui.Visible = false
end