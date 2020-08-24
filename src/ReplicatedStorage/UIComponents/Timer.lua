local timerClass = {}
timerClass.__index = timerClass


function timerClass.new(plr)
	local self = setmetatable({
		Element = script.Timer:Clone(),
		plr = plr
	}, timerClass)
	
	self:Render()
	
	return self
end

--// Initialize the UI element
function timerClass:Render()
	self.Element.Parent = self.plr.PlayerGui:WaitForChild("GameUI")
end

--// Remove the UI element
function timerClass:Unrender()
	self.Element:Destroy()
end

--// Update the UI element
function timerClass:Update(value)
	self.Element.Text = value
end

--// Allows the user to retrieve the UI element from other scripts without recreating the object
function timerClass:Get(plrToGet)
	return plrToGet.PlayerGui.GameUI:FindFirstChild(self.Element.Name)
end

return timerClass
