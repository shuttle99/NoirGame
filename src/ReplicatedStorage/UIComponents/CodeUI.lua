local codeUI = {}
codeUI.__index = codeUI

--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Folders
local uiComponents = ReplicatedStorage:WaitForChild("UIComponents")
local shared = ReplicatedStorage:WaitForChild("Shared")
local uiEvents = uiComponents:WaitForChild("UIEvents")
local events = ReplicatedStorage:WaitForChild("Events")

--// Modules
local maid = require(shared:WaitForChild("Maid"))

--// Events
local redeemCode = events:WaitForChild("RedeemCode")

function codeUI.new(plr)
    local self = setmetatable({
    plr = plr,
    button = uiComponents.CodesOpenButton:Clone(),
    ui = uiComponents.CodesFrame:Clone(),

    _maid = maid.new()
    }, codeUI)

    self:Init()

    return self
end

function codeUI:Init()
   self.ui.Parent = self.plr.PlayerGui.GameUI
   self.button.Parent = self.plr.PlayerGui.GameUI

   self._maid:GiveTask(self.ui.Buttons.ApplyButton.MouseButton1Click:Connect(function()
       if redeemCode:InvokeServer(string.upper(self.ui.Buttons.CodeBox.Text)) then
           self.ui.Buttons.UnlockText.Text = "Code successfully redeemed!"
           wait(3)
           self.ui.Buttons.UnlockText.Text = "Enter a code above."
        else
            self.ui.Buttons.UnlockText.Text = "Invalid code or already redeemed."
            wait(3)
            self.ui.Buttons.UnlockText.Text = "Enter a code above."
       end
   end))

   self._maid:GiveTask(self.button.MouseButton1Click:Connect(function()
       if self.ui.Visible then
           self:Hide()
       else
           self:Show()
       end
   end))

   self._maid:GiveTask(self.ui.ExitButton.MouseButton1Click:Connect(function()
        self:Hide()
   end))

end

function codeUI:Show()
    self.ui.Visible = true
end

function codeUI:Hide()
    self.ui.Visible = false
end

return codeUI