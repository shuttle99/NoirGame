local viewport = {}
viewport.__index = viewport

--// Services
local RunService = game:GetService("RunService")

--// Modules
local maid = require(game.ReplicatedStorage.Shared.Maid)

--// Variables
local plr = game.Players.LocalPlayer

--// Initializiations
local Camera

function viewport.new(model, uiElement, spin)
    local self = setmetatable({
        model = model,
        uiElement = uiElement,
        spin = spin,
        _maid = maid.new()
    }, viewport)

    self:Render()

    return self
end

--//Calculate and return position for model to center it perfectly in the viewport frame
local function AttachCameraToModel(model)
    local cf, size = model:GetBoundingBox()
    local rot = CFrame.Angles(math.rad(22.5), math.rad(180), 0)

    --Create sizes based on radians and stuff
    size = rot:VectorToObjectSpace(size)
    local sizeY, sizeZ = math.abs(size.Y), math.abs(size.Z)

    --Calulate proper distance from model to camera
    local h = (sizeY / (math.tan(math.rad(Camera.FieldOfView / 2)) * 2)) + (sizeZ / 2)

    return cf * rot * CFrame.new(0, 0, h + 1)
end


function viewport:Render()
    local newModel = self.model:Clone()
	newModel.Parent = self.uiElement
	Camera = Instance.new("Camera")
	self.uiElement.CurrentCamera = Camera
	Camera.Parent = self.uiElement
	
	Camera.CFrame = AttachCameraToModel(newModel)
	
	if self.spin then
		self._maid:GiveTask(RunService.RenderStepped:Connect(function()
			if self.uiElement:FindFirstChildOfClass("Model") then
				newModel:SetPrimaryPartCFrame(newModel.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(1), 0))
			end
		end))
	end
end

function viewport:Derender()
   self._maid:DoCleaning()
   self.uiElement:ClearAllChildren()
end

return viewport