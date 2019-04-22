---------
-- Module for managing coordanites in computercraft.
-- @module coords
-- @author Ulisse Mini
-- @license MIT

--- The entire API lives in here.
local t = {}

--- Our current coordanites.
local c = {
  x = 0,   -- Current X
  y = 0,   -- Current Y
  z = 0,   -- Current Z
  ori = 0, -- Current orientation, 0-3
}

-- The delta for different orientations.
local delta = {
  [0] = function() c.z = c.z - 1 end,
  [1] = function() c.x = c.x + 1 end,
  [2] = function() c.z = c.z + 1 end,
  [3] = function() c.x = c.x - 1 end
}

function t.turnRight()
	turtle.turnRight()
	c.ori = (c.ori + 1) % 4
end

function t.turnLeft()
	turtle.turnLeft()
	c.ori = (c.ori - 1) % 4
end

--- Create a new move function.
-- Afterwards the return value of moveFn will be returned.
-- @tparam function moveFn A function that returns a bool after moving the t.
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
-- @function t.forward
t.forward = move(turtle.forward, function()
  delta[c.ori]()
end)

--- Move the turtle backward.
-- @treturn bool success
-- @function t.back
t.back = move(turtle.back, function()
  delta[c.ori]()
end)

--- Move the turtle upwards.
-- @treturn bool success
-- @function t.up
t.up   = move(turtle.up,   function() c.y = c.y + 1 end)

--- Move the turtle upwards.
-- if it succeeds, increment our y coordanite.
-- @treturn bool success
-- @function t.down
t.down = move(turtle.down, function() c.y = c.y - 1 end)

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
function t.look(direction)
	if type(direction) == "string" then
    if oris[direction] == nil then
      error(direction .. ' is not in the orientations table')
    end

    direction = oris[direction]
	end

  -- Now we turn to the correct orientation
	if direction == c.ori then return end

	if (direction - c.ori) % 2 == 0 then
		t.turnLeft()
		t.turnLeft()
	elseif (direction - c.ori) % 4 == 1 then
		t.turnRight()
	else
		t.turnLeft()
	end
end

--- Helper for t.moveTo,
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

--- Helper for t.moveTo. is the same as
-- moveWith(t.forward, turtle.dig, turtle.attack)
local function moveForward()
  moveWith(t.forward, turtle.dig, turtle.attack)
end

--- Move to a set of coordanites.
-- @tparam number xT Target X coordanite
-- @tparam number yT Target Y coordanite
-- @tparam number zT Target Z coordanite
-- @tparam number,string oriT orientation target [optional].
function t.moveTo(xT, yT, zT, oriT)
  if not oriT then
    oriT = c.ori
  end

  -- check for nil arguments
  if (not xT or not yT or not zT) then
    error(
      ([[t.moveTo Invalid arguments
xT = %q (want number)
yT = %q (want number)
zT = %q (want number)
oriT = %q (want number or string)
]]):format(xT, yT, zT, oriT))
  end

  while yT < c.y do
		moveWith(turtle.digDown, t.down, turtle.attackDown)
  end

  while yT > c.y do
    moveWith(turtle.digUp, t.up, turtle.attackUp)
  end

  if xT < c.x then
    t.look('west')
    while xT < c.x do moveForward() end
  end

  if xT > c.x then
    t.look('east')
    while xT > c.x do moveForward() end
  end

  if zT < c.z then
    t.look('north')
    while zT < c.z do moveForward() end
  end

  if zT > c.z then
    t.look('south')
    while zT > c.z do moveForward() end
  end

  t.look(oriT)
end

return t, c
