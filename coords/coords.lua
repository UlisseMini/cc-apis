-- For debug logging.
local function debugf(s, ...)
  --print(s:format(...))
end

-- The current coordanites, initalized to zero.
-- TODO: Option to use GPS
local c = {
  x = 0,
  y = 0,
  z = 0,
  ori = 0,
}

-- Copy the turtle's movement functions since we are going to overwrite them.
local raw = {}
for key, value in pairs(turtle) do
  raw[key] = value
end

-- How to increment Z depending on the orientation
local zDiff = {
	[0] = -1,
	[1] = 0,
	[2] = 1,
	[3] = 0
}

-- How to increment Y depending on the orientation
local xDiff = {
	[0] = 0,
	[1] = 1,
	[2] = 0,
	[3] = -1
}

function turtle.turnRight(...)
	raw.turnRight(...)
	c.ori = (c.ori + 1) % 4
end

function turtle.turnLeft(...)
	raw.turnLeft(...)
	c.ori = (c.ori - 1) % 4
end

-- create a new move function.
-- @moveFn should be a function that returns a bool
-- @fn     will be called if moveFn returns true
-- afterwards the return value of moveFn will be returned.
local function move(moveFn, fn)
  return function(...)
    local b = moveFn(...)

    if b then fn() end
    return b
  end
end

turtle.forward = move(raw.forward, function()
  c.x = c.x + xDiff[c.ori]
  c.z = c.z + zDiff[c.ori]
end)

turtle.back = move(raw.back, function()
    c.x = c.x - xDiff[c.ori]
    c.z = c.z - zDiff[c.ori]
end)

turtle.up   = move(raw.up,   function() c.y = c.y + 1 end)
turtle.down = move(raw.down, function() c.y = c.y - 1 end)

-- key must be a string (x | y | z), will be used as a key
-- for the c table.
-- @lt will be executed when target < c[key]
-- @gt will be executed when target > c[key]
local function moveOn(target, key, le, gt)
  while target < c[key] do le() end
  while target > c[key] do gt() end
end

-- Helper for moveTo, calls dig move then while attack() do end
local function moveWith(dig, move, attack)
  dig()
  move()
  while attack() do end
end

function turtle.moveTo(xT, yT, zT, oriT)
  if not xT or not yT or not zT or not oriT then
    error(
      ([[c.moveTo Can't travel to nil.
xT = %q
yT = %q
zT = %q
oriT = %q]]):format(xT, yT, zT, oriT))
  end

  -- Moves to the correct Y coord
  while yT < c.y do
		moveWith(turtle.digDown, turtle.down, turtle.attackDown)
  end

  while yT > c.y do
    moveWith(turtle.digUp, turtle.up, turtle.attackUp)
  end

  -- Turns to correct c.ori then moves forward until its at the right c.x cord
  if xT < c.x then
    turtle.look('west')
    while xT < c.x do
      turtle.dig()
      turtle.forward()
			while turtle.attack() do end
    end
  end

  if xT > c.x then
    turtle.look('east')
    while xT > c.x do
      turtle.dig()
      turtle.forward()
			while turtle.attack() do end
    end
  end

  -- Turns to correct orientation then moves forward until its at the right c.z cord
  if zT < c.z then
    turtle.look('north')
    while zT < c.z do
      turtle.dig()
      turtle.forward()
			while turtle.attack() do end
    end
  end
  if zT > c.z then
    turtle.look('south')
    while zT > c.z do
      turtle.dig()
      turtle.forward()
			while turtle.attack() do end
    end
  end
  -- Look to correct orientation
  turtle.look(oriT)
end

return c

