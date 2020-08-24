local module = {}

--//Services
local runService = game:GetService("RunService")

--// Folders
local events = game.ReplicatedStorage.Events

--// Events
local gunHit = events.GunHit

--//Void; Raycast from gun to mousePos with 300 stud constraint
function module:CastRay(origin, mousePos, tool, plr, visualize)	
    --//Cast ray; Ignore character and tool
    local rayParams = RaycastParams.new()
   	rayParams.FilterDescendantsInstances = {plr.Character, workspace.Rays}
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
	local raycastResult = workspace:Raycast(origin, (mousePos - origin).Unit * 999999, rayParams)
	
    --//Check for a hit
    if raycastResult then
        local hitPart = raycastResult.Instance
		--//Check if part belongs to murderer
		print(hitPart.Name .. " is this one")
		print(hitPart.Parent.Name .. " is the parent of HitPart")
		
		if hitPart.Parent:FindFirstChild("Humanoid") then
			gunHit:Fire(hitPart.Parent)
		end     	
    else
        print("Nothing was hit.")
    end
    
	--//Visualize ray	
	return visualize and module:DrawRay(origin, mousePos, BrickColor.new(255, 255, 255))
end

function module:DrawRay(Start, End, Color)
    local Length = (End - Start).magnitude
    local Orientation = CFrame.new(Start, End)
    local Mesh = Instance.new("BlockMesh")
    local Laser1 = Instance.new("Part")
    Mesh.Parent = Laser1
    Laser1.Anchored = true
    Laser1.CanCollide = false
    Laser1.Locked = true
    Laser1.Size = Vector3.new(1, 1, 1)
    Laser1.TopSurface = 0
    Laser1.BottomSurface = 0
    Laser1.CFrame = Orientation * CFrame.new(0, 0, -Length * .75)
    Laser1.Mesh.Scale = Vector3.new(.2, .2, Length * .5)
    Laser1.BrickColor = Color
    Laser1.Parent = workspace.Rays
    local Laser2 = Laser1:Clone()
    Laser2.CFrame = Orientation * CFrame.new(0, 0, -Length * .25)
    Laser2.Parent = workspace.Rays
    game.Debris:AddItem(Laser1, .06)
	game.Debris:AddItem(Laser2, .03)
end

return module