local sqrt = math.sqrt

local Utils = {}

function Utils.direction(x1, y1, x2, y2)
  local a = y2 - y1
  local b = x2 - x1
  local c = sqrt(a*a + b*b)
  -- dividing by zero returns a NAN value, so we should coerce to zero
  return c == 0 and 0 or (b/c),
    c == 0 and 0 or (a/c)
end

function Utils.normalizeVector(a, b)
  local c = sqrt(a*a + b*b)
  -- dividing by zero returns a NAN value, so we should coerce to zero
  return c == 0 and 0 or (a/c),
    c == 0 and 0 or (b/c)
end

function Utils.dist(x1, y1, x2, y2)
	local a = x2 - x1
	local b = y2 - y1
	return sqrt(a*a + b*b)
end

return Utils