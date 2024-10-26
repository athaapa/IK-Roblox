--[[
	August 12, 2024
	
	FABRIK-based Inverse Kinematic Solver
]]

local Point = require(script.Point)

local DEFAULT_LENGTH = 5
local MARGIN_OF_ERROR = 0.5
local MAX_ITERATIONS = 150

local IK = {}
IK.Point = Point
IK.__index = IK

local parts = {}

IK.length = DEFAULT_LENGTH

function IK.setSegmentLength(length: number)
	IK.length = length
end

function IK.new(points: {})
	local self = setmetatable({}, IK)

	self.start = Vector3.new()
	self.endEffector = Vector3.new()
	self.points = points

	for i, point in pairs(self.points) do
		point:setPosition(self.start)
		point.part.Name = i
		self.points[i]:show()
	end

	return self
end

function IK:setEndEffector(endEffector: Vector3)
	self.endEffector = endEffector
end

function IK:updateParts()
	for _, v in pairs(parts) do
		v:Destroy()
	end
	for i = 1, #self.points - 1 do
		local part = Instance.new("Part")
		part.Parent = workspace
		part.Anchored = true
		part.CanCollide = false
		part.Size = Vector3.new(0.1, 0.1, 5)
		part.Material = "Neon"
		local lookAt = (self.points[i + 1]:getPosition() - self.points[i]:getPosition()).Unit
		part.Position = self.points[i]:getPosition() + lookAt * IK.length / 2
		part.CFrame = CFrame.new(part.Position, part.Position + lookAt)
		part.Parent = workspace
		part.Name = "Part" .. i
		table.insert(parts, part)
	end
end

function IK:solve()
	local startEndVector = (self.endEffector - self.start)
	local startEndDistance = startEndVector.magnitude
	local maxLength = (#self.points - 1) * IK.length

	if startEndDistance > maxLength then
		for i = #self.points, 2, -1 do
			local startEndDirection = startEndVector.Unit
			local newPosition = self.start + startEndDirection * IK.length * (i - 1)
			self.points[i]:setPosition(newPosition)
		end
	else
		local iterations = 0
		while
			(self.endEffector - self.points[#self.points]:getPosition()).Magnitude > MARGIN_OF_ERROR
			and iterations < MAX_ITERATIONS
		do
			-- // Backwards
			self.points[#self.points]:setPosition(self.endEffector)

			for i = #self.points - 1, 1, -1 do
				local pointDirection = Point.getDirection(self.points[i], self.points[i + 1])
				local newPosition = self.points[i + 1]:getPosition() + (pointDirection * IK.length)
				self.points[i]:setPosition(newPosition)
			end

			-- // Forward
			self.points[1]:setPosition(self.start)

			for i = 2, #self.points do
				local pointDirection = Point.getDirection(self.points[i], self.points[i - 1])
				local newPosition = self.points[i - 1]:getPosition() + (pointDirection * IK.length)
				self.points[i]:setPosition(newPosition)
			end
			iterations += 1
		end
	end

	self:updateParts()
end

return IK
