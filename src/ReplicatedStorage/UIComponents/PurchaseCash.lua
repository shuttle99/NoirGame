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
        ui = uiComponents:WaitForChild("DevProductsFrame"):Clone(),

        _purchaseEvent = ReplicatedStorage.Events:WaitForChild("PurchaseDevProduct")
    }, cashPurchase)

    self.ui.Parent = self.plr.PlayerGui:WaitForChild("GameUI")

    return self
end

function cashPurchase:Show()
    self.ui.Visible = true

    for _, element in pairs(self.ui.ScrollingFrame:GetChildren()) do
        if element:IsA("Frame") then
            element.Purchase.MouseButton1Click:Connect(function()
                local id = element.Name
                self._purchaseEvent:FireServer(id)
            end)
        end
    end
end

function cashPurchase:Hide()
    self.ui.Visible = false
end

return cashPurchase