local sqrt = math.sqrt

local Utils = {}

function Utils.direction(x1, y1, x2, y2)
  local a = x2 - x1
  local b = y2 - y1
  return Utils.normalizeVector(a, b)
end

function Utils.normalizeVector(a, b)
  local c = sqrt(a*a + b*b)
  -- dividing by zero returns a NAN value, so we should coerce to zero
  if c == 0 then
	return 0.0, 0.0
  else
    return a/c, b/c
  end
end

function Utils.dist(x1, y1, x2, y2)
	local a = x2 - x1
	local b = y2 - y1
	return sqrt(a*a + b*b)
end

return Utils