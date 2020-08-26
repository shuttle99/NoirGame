local ExperienceBar = {}
ExperienceBar.__index = ExperienceBar

--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

--// Folders
local uiComponents = ReplicatedStorage:WaitForChild("UIComponents")
local uiEvents = uiComponents:WaitForChild("UIEvents")
local replicatedData = ReplicatedStorage:WaitForChild("ReplicatedData")

--// Events
local expUpdate = uiEvents:WaitForChild("ExpUpdate")

--// Local functions
local function getLevel(xp)
    return ((math.sqrt(625+100*xp)-25)/50)
end

--// Constructor fucnction
function ExperienceBar.new(plr, level)
    local self = setmetatable({
        plr = plr,
        ui = uiComponents.ExperienceBackground:Clone(),
        clientData = replicatedData:WaitForChild(plr.UserId),
    }, ExperienceBar)

    self:Init()
    return self
end

-- Public Init
function ExperienceBar:Init()
    local TweenService = game:GetService("TweenService")
    --// Render the UI
    self.ui.Parent = self.plr.PlayerGui.GameUI

    --// Init position
    local percentToLevel = getLevel(self.clientData.Experience.Value) % 1
    self.ui.XPAmountFrame.Size = UDim2.fromScale(percentToLevel, 1)

    --// Whenever the UI is changed, detect it and update the UI accordingly
    expUpdate.OnClientEvent:Connect(function(amt, level)
        percentToLevel = level % 1
        
        --//Tween the gained label
        local newLabel = self.ui.GainedLabel:Clone()
        newLabel.Parent = self.ui
        newLabel.Text = "+" .. amt .. "!"
        newLabel:TweenPosition(UDim2.fromScale(0.5, -0.6), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, .5)
        wait(.7)
        local textTransparencyTween = TweenService:Create(newLabel, TweenInfo.new(.5), {TextTransparency = 1})
        textTransparencyTween:Play()
        textTransparencyTween.Completed:Wait()
        newLabel:Destroy()

        --// Add tween
        self.ui.XPAmountFrame:TweenSize(UDim2.fromScale(percentToLevel, 1), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, .5)
    end)
end

return ExperienceBar