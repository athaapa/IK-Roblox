local Point = {}

local PART_THICKNESS = 0.5

function Point.new(position: Vector3)
	local self = setmetatable({}, { __index = Point })

	self.position = position

	local part = Instance.new("Part")
	part.Size = Vector3.new(1, 1, 1)
	part.Shape = Enum.PartType.Ball
	part.Anchored = true
	part.CanCollide = false
	part.Color = Color3.fromRGB(255, 0, 0)
	part.Position = self.position
	part.Material = Enum.Material.Neon
	part.Locked = true
	self.part = part

	return self
end

function Point.getDirection(a: Point, b: Point)
	return (a.position - b.position).Unit
end

function Point:setPosition(position: Vector3)
	self.position = position
	self:show()
end

function Point:getPosition()
	return self.position
end

function Point:show()
	self.part.Parent = workspace
	self.part.Position = self.position
end

return Point
