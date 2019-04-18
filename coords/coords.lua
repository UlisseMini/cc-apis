---------
-- Module for managing coordanites in computercraft.
-- @module coords
-- @author Ulisse Mini
-- @license MIT

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

--- How to increment Z depending on the orientation
local zDiff = {
	[0] = -1,
	[1] = 0,
	[2] = 1,
	[3] = 0
}

--- How to increment Y depending on the orientation
local xDiff = {
	[0] = 0,
	[1] = 1,
	[2] = 0,
	[3] = -1
}

function turtle.turnRight()
	raw.turnRight()
	c.ori = (c.ori + 1) % 4
end

function turtle.turnLeft()
	raw.turnLeft()
	c.ori = (c.ori - 1) % 4
end

--- Create a new move function.
-- Afterwards the return value of moveFn will be returned.
-- @tparam function moveFn A function that returns a bool after moving the turtle.
-- @tparam function fn The function to be called if moveFn returns true.
local function move(moveFn, fn)
  return function(...)
    local b = moveFn(...)

    if b then fn() end
    return b
  end
end

--- Move the turtle forward.
-- @treturn bool success
-- @function turtle.forward
turtle.forward = move(raw.forward, function()
  c.x = c.x + xDiff[c.ori]
  c.z = c.z + zDiff[c.ori]
end)

--- Move the turtle backward.
-- @treturn bool success
-- @function turtle.back
turtle.back = move(raw.back, function()
    c.x = c.x - xDiff[c.ori]
    c.z = c.z - zDiff[c.ori]
end)

--- Move the turtle upwards.
-- @treturn bool success
-- @function turtle.up
turtle.up   = move(raw.up,   function() c.y = c.y + 1 end)

--- Move the turtle upwards.
-- if it succeeds, increment our y coordanite.
-- @treturn bool success
-- @function turtle.down
turtle.down = move(raw.down, function() c.y = c.y - 1 end)

--- Needed for converting the orientation back and forth to strings.
-- if a key does not exist an error is thrown.
local oris = {
	["north"] = 0,
	["east"]  = 1,
	["south"] = 2,
	["west"]  = 3
}

--- Look a direction,
-- @param direction can be a string or number
-- if it is a string then it will be converted to a number based
-- on the oris table.
function turtle.look(direction)
	if type(direction) == "string" then
    if oris[direction] == nil then
      error(direction .. ' is not in the orientations table')
    end

    direction = oris[direction]
	end

  -- Now we turn to the correct orientation
	if direction == c.ori then return end

	if (direction - c.ori) % 2 == 0 then
		turtle.turnLeft()
		turtle.turnLeft()
	elseif (direction - c.ori) % 4 == 1 then
		turtle.turnRight()
	else
		turtle.turnLeft()
	end
end

--- Helper for turtle.moveTo,
-- @tparam function dig    to be called until it's
-- return value is falsy.
-- @tparam function move   to call second.
-- @tparam function attack to be called until
-- it's return value is falsy.
local function moveWith(dig, move, attack)
  dig()
  move()
  while attack() do end
end

--- Helper for turtle.moveTo. is the same as
-- moveWith(turtle.forward, turtle.dig, turtle.attack)
local function moveForward()
  moveWith(turtle.forward, turtle.dig, turtle.attack)
end

--- Move to a set of coordanites.
-- @tparam number xT Target X coordanite
-- @tparam number yT Target Y coordanite
-- @tparam number zT Target Z coordanite
-- @tparam number,string oriT orientation target [optional].
function turtle.moveTo(xT, yT, zT, oriT)
  if not oriT then
    oriT = c.ori
  end

  -- check for nil arguments
  if (not xT or not yT or not zT) then
    error(
      ([[turtle.moveTo Invalid arguments
xT = %q (want number)
yT = %q (want number)
zT = %q (want number)
oriT = %q (want number or string)
]]):format(xT, yT, zT, oriT))
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
    while xT < c.x do moveForward() end
  end

  if xT > c.x then
    turtle.look('east')
    while xT > c.x do moveForward() end
  end

  -- Turn to the correct orientation,
  -- then move forward until we're at the right z coord
  if zT < c.z then
    turtle.look('north')
    while zT < c.z do moveForward() end
  end

  if zT > c.z then
    turtle.look('south')
    while zT > c.z do moveForward() end
  end

  -- Finally look to the correct orientation
  turtle.look(oriT)
end

return c
