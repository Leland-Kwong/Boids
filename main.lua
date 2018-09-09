local Boid = require('boid')
local Obstacle = require('obstacle')

math.randomseed( os.time() )

local boids = {}
local obstacles = {}

function love.load()
	for i=1, 30 do
		table.insert(
			boids,
			Boid:new(
				math.random(0, love.graphics.getWidth( )),
				math.random(0, love.graphics.getHeight( )),
				100,
				-- math.random(100, 300),
				math.random(10, 30)
			)
		)
	end

	for i=1, 10 do
		table.insert(
			obstacles,
			Obstacle:new(
				math.random(0, love.graphics.getWidth( )),
				math.random(0, love.graphics.getHeight( )),
				math.random(20, 50)
			)
		)
	end
end

function love.keypressed(key)
	if key == 'escape' then
		love.event.quit()
	end
end

function love.update(dt)
	local mx, my = love.mouse.getX(), love.mouse.getY()
	-- print( string.format("%02d, %02d", mx, my), 10, 10 )
	for i=1, #boids do
		boids[i]:moveToPosition(mx, my)
		boids[i]:update(dt, 50)
	end
end

function love.draw()
	love.graphics.setColor(1,1,0)
	for i=1, #boids do
		local b = boids[i]
		love.graphics.circle(
			'fill',
			b.x,
			b.y,
			b.size / 2
		)
	end

	love.graphics.setColor(0.8,0.1,0.05)
	for i=1, #obstacles do
		local o = obstacles[i]
		love.graphics.circle(
			'fill',
			o.x,
			o.y,
			o.size / 2
		)
	end
end