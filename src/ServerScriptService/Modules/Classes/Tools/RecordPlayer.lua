local RecordPlayer = {}
RecordPlayer.__index = RecordPlayer

--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

--// Folders
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Assets = ServerStorage:WaitForChild("Assets")
local Items = Assets:WaitForChild("Items")
local Misc = Items:WaitForChild("Misc")
local Events = ReplicatedStorage:WaitForChild("Events")

--// Modules
local Maid = require(Shared:WaitForChild("Maid"))

--// Constructor
function RecordPlayer.new(plr)
    local self = setmetatable({
        plr = plr,
        tool = Misc.RecordPlayer:Clone(),

        _maid = Maid.new(),
        getText = Events.ReturnText
    }, RecordPlayer)

    --// Give the tool to the player
    self.tool.Parent = self.plr.Backpack
    self._maid:GiveTask(self.tool)

    --// Init the UI for playing music
    self.ui = self.tool.SoundUI:Clone()
    self.ui.Parent = self.plr.PlayerGui.GameUI
    self._maid:GiveTask(self.ui)

    --// Open/Close the song choice
    self._maid:GiveTask(self.ui.ToggleSongChoice.MouseButton1Click:Connect(function()
        self.ui.SongChoice.Visible = not self.ui.SongChoice.Visible
    end))

    --// Set the new audio and play it
    self._maid:GiveTask(self.ui.SongChoice.Confirm.MouseButton1Click:Connect(function()
        --// Stop current playing audio
        self.tool.Handle.Sound:Stop()

        --// Get entered song ID
        local id = tostring(self.getText:InvokeClient(self.plr))
        self.tool.Handle.Sound.SoundId = string.format("rbxassetid://%s", tostring(id))

        --// Play the song entered
        self.tool.Handle.Sound:Play()
    end))

    --// Start current song when item equipped
    self._maid:GiveTask(self.tool.Equipped:Connect(function()
        self.tool.Handle.Sound:Play()
        self.ui.Visible = false
    end))

    --// Stop song when item unequipped
    self._maid:GiveTask(self.tool.Unequipped:Connect(function()
        self.tool.Handle.Sound:Stop()
        self.ui.Visible = true
    end))

    return self
end

--// Cleanup
function RecordPlayer:Destroy()
    self._maid:Destroy()
end

return RecordPlayer