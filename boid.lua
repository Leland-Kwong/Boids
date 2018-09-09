local Utils = require 'utils'
local Obstacles require 'obstacle'

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
		speed = speed*20/size, --just fancying up the test by adjusting speed based on size
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
	-- print(string.format("%02d",#neighbors))
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
	if neighborCount > 0 then
		vx = vx / neighborCount
		vy = vy / neighborCount
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
	if neighborCount > 0 then
		px = px / neighborCount
		py = py / neighborCount
	end
	px = px - self.x
	py = py - self.y
	return Utils.normalizeVector(px, py)
end

local function computeSeparation(self, neighbors)
	local sx, sy = 0, 0
	local neighborCount = #neighbors
	for i=1, neighborCount do
		local n = neighbors[i]
		-- add separation vector, reducing strength by distance
		-- this can be fancier with decay by the square or taking into account weight or whatever
		local sepX, sepY = Utils.normalizeVector(self.x - n.x, self.y - n.y)
		local dist = math.max(0.01, Utils.dist(self.x, self.y, n.x, n.y) - n.size*0.5 - self.size*0.5)
		sx = sx + (sepX/dist)
		sy = sy + (sepY/dist)
	end

	-- Note that this isn't normalised as you want the influence to reduce if the entity is well separated.
	-- You could apply a similar approach to other influence vectors depending on what sort of behaviour you want
	return sx, sy
end

local function computeObstacleInfluence(self)
	-- We'll just use the single nearest obstacle for demo purposes.
	-- A lot of the time this is enough but more complex environments might need influences from all nearby obstacles
	local no, dist = getNearestObstacle(self.x, self.y)
	dist = math.max(0.01, dist - self.size*0.5)
	local sepX, sepY = Utils.normalizeVector(self.x - no.x, self.y - no.y)

	return sepX/dist, sepY/dist
end

function Boid:update(dt, radius)

	local speed = self.speed * dt

	-- These calcs are to get an adjustment for movement speed based on distance.
	-- Don't take this as a complete solution as it only works based on the mouse target for
	-- this test setup.
	-- In reality you need to be a bit smarter about slowing/stopping AI entities when
	-- they have reached a goal point. This will often tie into the combat system (stopping
	-- when they can hit the player, for example).
	local targetDist = Utils.dist(self.x, self.y, self.target.x, self.target.y)
	local targetDistDamping = math.min(1.0, targetDist/radius)

	--Find neighbors
	local neighbors = self:getNeighbors(radius + self.size/2)

	-- Calculate direction influence vectors
	-- Remember that you're not bound to the classical boids here. You can add influences from all sorts
	-- of things in your game. I've added some obstacles (which could be traps or fire or whatever) to demonstrate.
	local targetDirX, targetDirY = Utils.direction(self.x, self.y, self.target.x, self.target.y)
	local alignmentX, alignmentY = computeAlignment(self, neighbors)
	local cohesionX, cohesionY = computeCohesion(self, neighbors)
	local separationX, separationY = computeSeparation(self, neighbors)
	local obstInfluenceX, obstInfluenceY = computeObstacleInfluence(self)

	-- these are the weights for each influence vector and can be adjusted to get different behaviours
	local separationWeight = 4
	local alignmentWeight = 0.1
	local cohesionWeight = 0.2
	local targetDirectionWeight = 1.5
	local obstInfluenceWeight = 6.0

	-- Now we calculate the overall influence vector
	local adjustedVx = targetDirX*targetDirectionWeight + obstInfluenceX*obstInfluenceWeight + (alignmentX * alignmentWeight) + (cohesionX * cohesionWeight) + (separationX * separationWeight)
	local adjustedVy = targetDirY*targetDirectionWeight + obstInfluenceY*obstInfluenceWeight + (alignmentY * alignmentWeight) + (cohesionY * cohesionWeight) + (separationY * separationWeight)

	-- Normalise to a direction vector
	local normVx, normVy = Utils.normalizeVector(adjustedVx, adjustedVy)

	-- Here I'm effectively lerping the direction just to smooth things out a bit. Completely optional/adjustable
	self.vx = (self.vx + normVx) * 0.5
	self.vy = (self.vy + normVy) * 0.5

	-- Apply direction with speed and our damping based on the target distance
	self.x = self.x + self.vx * self.speed * dt * targetDistDamping
	self.y = self.y + self.vy * self.speed * dt * targetDistDamping
end

return Boid