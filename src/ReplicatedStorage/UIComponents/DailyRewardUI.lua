local RewardUI = {}
RewardUI.__index = RewardUI

--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

--// Folders
local UIComponents = ReplicatedStorage:WaitForChild("UIComponents")

function RewardUI.new(plr, cash, tickets, knife, consecDays)
    local self = setmetatable({
        plr = plr,
        cash = cash,
        tickets = tickets,
        knife = knife,
        ui = UIComponents:WaitForChild("RewardFrame"):Clone()
    }, RewardUI)

    if self.cash then
        self.ui.CashReceived.Visible = true
        self.ui.CashReceived.Text = self.cash .. " CASH"
    end

    if self.tickets then
        self.ui.TicketsReceived.Visible = true
        self.ui.TicketsReceived.Text = self.tickets .. " TICKETS"
    end

    if self.knife then
        self.ui.KnifeReceived.Visible = true
    end

    if self.consecDays == 25 then
        self.ui.DayJoined.Visible = false
    end
    self.ui.DayJoined.Text = "YOU'VE PLAYED FOR " .. consecDays .. " DAYS IN A ROW! PLAY FOR " .. 25 - consecDays .. " TO RECEIVE A SPECIAL KNIFE!"

    self.ui.Position = UDim2.fromScale(0.5, -1.3)
    self.ui.Parent = self.plr.PlayerGui.GameUI

    local uiTween = TweenService:Create(self.ui, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Position = UDim2.fromScale(0.5, 0.5)})
    uiTween:Play()

    self.ui.ExitButton.MouseButton1Click:Connect(function()
        self.ui:Destroy()
    end)

    return self
end

return RewardUI