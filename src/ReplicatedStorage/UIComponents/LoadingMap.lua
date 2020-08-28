local loading = {}
loading.__index = loading

--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

--// Folders
local uiComponents = ReplicatedStorage:WaitForChild("UIComponents")
local loadingScreen = uiComponents:WaitForChild("LoadingFrame")

--// Variables
local random = Random.new()
local frameTween
local textTween

--// Tip table
local tips = {
    "Want to see live development of Noir? Check out CheekyVisuals on Twitch!",
    "Join VectorThree for exclusive in-game perks!",
    "We are going to be adding new game modes + perks for innocents soon! The game is still in an early state.",
    "Want to give us ideas? Tweet @NoirTheGame on Twitter!",
    "Use Spray Paint to reveal the Murderer!"
}

function loading.new(plr)
    local self = setmetatable({
        plr = plr,
        ui = loadingScreen:Clone()
    }, loading)

    return self
end

function loading:Show()
    self.ui.TipLabel.Text = tips[random:NextInteger(1, #tips)]

    self.ui.Parent = self.plr:WaitForChild("PlayerGui"):WaitForChild("GameUI")
    frameTween = TweenService:Create(self.ui.LoadingLabel, TweenInfo.new(1, Enum.EasingStyle.Quint), {ImageTransparency = 0})
    textTween = TweenService:Create(self.ui.TipLabel, TweenInfo.new(1, Enum.EasingStyle.Quint), {TextTransparency = 0})

    frameTween:Play()
    textTween:Play()
end

function loading:Hide()
    frameTween = TweenService:Create(self.ui.LoadingLabel, TweenInfo.new(.5, Enum.EasingStyle.Quint), {ImageTransparency = 1})
    textTween = TweenService:Create(self.ui.TipLabel, TweenInfo.new(.5, Enum.EasingStyle.Quint), {TextTransparency = 1})

    frameTween:Play()
    textTween:Play()

    textTween.Completed:Wait()

    self.ui:Destroy()  
end

return loading