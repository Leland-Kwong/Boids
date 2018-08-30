local Boid = require('Boid')

math.randomseed( os.time() )

local boids = {}

function love.load()
	for i=1, 10 do
		table.insert(
			boids,
			Boid:new(
				math.random(0, 400),
				math.random(0, 400),
				200,
				20
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
	for i=1, #boids do
		boids[i]:moveToPosition(mx, my)
		boids[i]:update(dt, 30)
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
end