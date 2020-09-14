-- Scheduler
-- July 13 2020
-- MrAsync

local Scheduler = {}
Scheduler.__index = Scheduler

--//Api

--//Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

--//Classes
local MaidClass = require(ReplicatedStorage.Shared:WaitForChild("Maid"))

--//Locals
local _Maid = MaidClass.new()


--Constructor
function Scheduler.new(targetTime)
	local self = setmetatable({
		Length = targetTime,
		Elapsed = 0,
		
		_Elapsed = 0,
		_Maid = MaidClass.new()
	}, Scheduler)
	
	--Construct Events
	self._Tick = Instance.new("BindableEvent")
	self.Tick = self._Tick.Event
	self._Maid:GiveTask(self._Tick)
	
	self._Ended = Instance.new("BindableEvent")
	self.Ended = self._Ended.Event
	self._Maid:GiveTask(self._Ended)
	
	self._Stopped = Instance.new("BindableEvent")
	self.Stopped = self._Stopped.Event
	self._Maid:GiveTask(self._Ended)
	
	return self
end

--//Begins counting for appointment
function Scheduler:Start()
	self._Maid:GiveTask(RunService.Stepped:Connect(function(_, step)
		self._Elapsed += step
		
		--Update Whole-Number, fire tick
		local elapsed = math.floor(self._Elapsed)
		if (elapsed > self.Elapsed) then
			self.Elapsed = elapsed
			self.CurrentTime = self.Length - self.Elapsed
			self._Tick:Fire(elapsed)
		end
		
		--Check if timer should be over
		if (self._Elapsed >= self.Length) then
			self._Ended:Fire()
			self._Maid:Destroy()
		end
	end))
end


--//Kills counter for appointment
function Scheduler:Stop()
	self._Stopped:Fire()
	self._Maid:Destroy()
end


return Scheduler