local Utils = require 'utils'
local Obstacle = {}

local obstacles = {}

function Obstacle:new(x, y, speed, size)
	local obstacle = {
		x = x,
		y = y,
		size = size
	}
	setmetatable(obstacle, self)
	self.__index = self
	table.insert(obstacles, obstacle)
	return obstacle
end

function getNearestObstacle(x, y)
	local nearestDist = math.huge
	local nearestObstacle = nil
	
	for i=1, #obstacles do
		local o = obstacles[i]
		local dist = Utils.dist(x, y, o.x, o.y) - o.size * 0.5
		if dist <= nearestDist then
			nearestDist = dist
			nearestObstacle = o
		end
	end
	
	return nearestObstacle
end

return Obstacle