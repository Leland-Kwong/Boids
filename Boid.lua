local Utils = require 'utils'
local Boid = {}

local boids = {}

function Boid:new(x, y, speed, size)
	local boid = {
		x = x,
		y = y,
		vx = 0,
		vy = 0,
		target = {
			x = 0,
			y = 0
		},
		speed = speed,
		size = size
	}
	setmetatable(boid, self)
	self.__index = self
	table.insert(boids, boid)
	return boid
end

function Boid:moveToPosition(x, y)
	self.target.x = x
	self.target.y = y
end

function Boid:getNeighbors(maxDistFromNeighbor)
	local neighbors = {}
	for i=1, #boids do
		local b = boids[i]
		local isNeighbor = b ~= self
		if isNeighbor then
			local dist = Utils.dist(self.x, self.y, b.x, b.y)
			if dist <= maxDistFromNeighbor then
				table.insert(neighbors, b)
			end
		end
	end
	return neighbors
end

local function computeAlignment(self, neighbors)
	local vx, vy = 0, 0
	local neighborCount = #neighbors
	for i=1, neighborCount do
		local n = neighbors[i]
		vx = vx + n.vx
		vy = vy + n.vy
	end
	return Utils.normalizeVector(vx, vy)
end

local function computeCohesion(self, neighbors)
	local px, py = 0, 0
	local neighborCount = #neighbors
	for i=1, neighborCount do
		local n = neighbors[i]
		px = px + n.x
		py = py + n.y
	end
	return Utils.normalizeVector(px, py)
end

local function computeSeparation(self, neighbors)
	local sx, sy = 0, 0
	local neighborCount = #neighbors
	for i=1, neighborCount do
		local n = neighbors[i]
		sx = sx + n.x - self.x
		sy = sy + n.y - self.y
	end
	return sx * -1, sy * -1
end

function Boid:update(dt, radius)
	local vx, vy = Utils.direction(
		self.x,
		self.y,
		self.target.x,
		self.target.y
	)

	-- average up the vectors of all neighbors
	local neighbors = self:getNeighbors(radius + self.size/2)
	local alignmentX, alignmentY = computeAlignment(self, neighbors)
	local cohesionX, cohesionY = computeCohesion(self, neighbors)
	local separationX, separationY = computeSeparation(self, neighbors)

	local speed = self.speed * dt
	local separationWeight = 0.02
	local alignmentWeight = 1
	local cohesionWeight = 1
	local adjustedVx = vx + (alignmentX * alignmentWeight) + (cohesionX * cohesionWeight) + (separationX * separationWeight)
	local adjustedVy = vy + (alignmentY * alignmentWeight) + (cohesionY * cohesionWeight) + (separationY * separationWeight)
	adjustedVx, adjustedVy = Utils.normalizeVector(adjustedVx, adjustedVy)
	self.vx = adjustedVx
	self.vy = adjustedVy
	self.x = self.x + (speed * (adjustedVx))
	self.y = self.y + (speed * (adjustedVy))
end

return Boid