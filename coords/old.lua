--[[
Valvates library for cordanite management and stuff.
If you have an idea for feature make an issue or
Create a pull request if you're a coder.
A lot of stuff here is unfinished so
Be careful and tell me how to make it better :DD

WARNING!
Since the turtle writes his coordanites to a file you should
run fs.delete(t.coordsfile) when your program finishes!
if you don't then his coords will get all screwed up if he moved without updating his coords

If you're using gps you can manually set coords and then update them
heres some untested example code

t = require("val_api")
t.x, t.y, t.z = gps.locate(0.5)
In this example orientation is still set to north by default,
if you want to find orientation you'll need code that compares coords
after you move, i might add this later but for now its up to you! ;)

TODO:
	Write saved positions to a file and read from it on startup.
	Add automatic gps support, maybe with a bool config variable to turn it on or off.
--]]
local t = {}

t.logfile = "val_lib.log"
t.coordsfile = "coords"
t.posfile = "savedPositions"

t.saved_positions = {}

t.blocks_dug = 0

-- How to increment depending on the orientation
local zDiff = {
	[0] = -1,
	[1] = 0,
	[2] = 1,
	[3] = 0
}

local xDiff = {
	[0] = 0,
	[1] = 1,
	[2] = 0,
	[3] = -1
}

-- Needed for human readable input/output
t.orientations = {
	[0] = "north",
	[1] = "east",
	[2] = "south",
	[3] = "west"
}

-- Unwanted items for clean inventory function.
t.unWantedItems = {
	"minecraft:cobblestone",
	"minecraft:stone",
	"minecraft:flint",
	"minecraft:dirt",
	"minecraft:sandstone",
	"minecraft:gravel",
	"minecraft:sand",
	"minecraft:torch",
	"minecraft:netherrack",
	"minecraft:nether_brick",
	"biomesoplenty:dirt",
	"biomesoplenty:grass",
	"biomesoplenty:flower_1",
}

local function writeFile(data, file, mode)
  local f = assert( io.open(file, mode))
  f:write(data)
  f:close()
end

function t.dumpCoords()
	return {
		x = t.x,
		y = t.y,
		z = t.z,
		orientation = t.orientation,
	}
end

local function inTable(value, table)
	for key, keyValue in pairs(table) do
		if value == keyValue then
			return true
		end
	end
	return false
end

function t.cleanInventory()
	local item
	local prevSlot = turtle.getSelectedSlot()

	for i=1,16 do
		item = turtle.getItemDetail(i)
		-- Makes sure item exists to avoid nil errors.
		if item and inTable(item.name, t.unWantedItems) then
			turtle.select(i)
			turtle.dropDown(item.count) -- Drops all of the unwanted item
		end
	end
	turtle.select(prevSlot)
end

local function logFunc(prefix)
  return function(s, ...)
    local msg = prefix..s:format(...)

		local f = assert(io.open(t.logfile, "a"))
		f:write(msg..'\n')
		f:close()
  end
end

t.debug = logFunc '[DEBUG] '

-- Get coords from file if file does not exist create one and set coords to 0,0,0,0
function t.init()
	if t.coordsfile == nil then
		error "t.coordsfile is nil"
	end

  -- Create coords file if needed.
	if not fs.exists(t.coordsfile) then
		t.debug("t.coordsfile does not exist, creating it...")
		local f = assert(io.open(t.coordsfile, 'w'))
		f:write(textutils.serialize({
			x = 0,
			y = 0,
			z = 0,
			orientation = 0
		}))
    f:close()

    -- Make sure it has been created.
		if not fs.exists(t.coordsfile) then
			error("Failed to create "..t.coordsfile)
		end
	end

	local f = assert(io.open(t.coordsfile, "r"))
	local contents = f:read("*all")
	f:close()

	if contents == nil then
		error "Failed to read file contents"
	end

	t.debug("Read file contents, trying to unserialize it")
	t.debug("contents = %q", contents)
	local coords = textutils.unserialize(contents)
	if type(coords) ~= "table" then
		error(
		  "failed to unserialize contents, coords is not a table, it is a "..type(coords))
	end

	-- Sets coordanites
	t.debug("Got coordanites from file, they are\n"..textutils.serialize(coords))
	t.x = coords.x
	t.y = coords.y
	t.z = coords.z

	-- Sets orientation
	t.orientation = coords.orientation

	-- Gets saved positions
	t.getSavedPositions()
	-- Not going to return a value since i'll just change the varables.
end

-- Saves coordanites to file
function t.saveCoords()
	local c = {
		x = t.x,
		y = t.y,
		z = t.z,
		orientation = t.orientation
	}
	c = textutils.serialize(c)

	t.debug("Updating "..t.coordsfile.."\n"..c)
	assert(io.open(t.coordsfile, "w"))
	  :write(c)
	  :close()
end

local function orientationToNumber(orientationStr)
	-- Turns an orientation string into an Orientation number.
	for i=0,#t.orientations do
			if orientationStr == t.orientations[i] then
				return i
			end
	end
end

-- Turns an orientation number into an t.orientation string.
local function orientationToString(orientationInt)
	-- Checks to see if orientationInt is a number
	if type(orientationInt) ~= "number" then
		error "orientationInt is not a number"
	end
	if orientations[orientationInt] then
		return t.orientations[orientationInt]
	else
		print("orientation is invalid", 0)
		print("orientationInt = "..orientationInt)
	end
end

-- Turning functions
function t.turnRight()
	turtle.turnRight()
	-- This "magic" math adds one to t.orientation unless t.orientation is 3, then it moves to 0.
	-- This could also be done with an if statement but this is cleaner imo
	t.orientation = (t.orientation + 1) % 4
	t.saveCoords()
end

function t.turnLeft()
	turtle.turnLeft()
	t.orientation = (t.orientation - 1) % 4
	t.saveCoords()
end

-- Looks to a direction, can be passed a string or a number
function t.look(direction)
	-- makes sure the value passed is valid.
	if type(direction) == "string" then
		direction = orientationToNumber(direction)
	elseif type(direction) ~= "number" then
			error("Direction is not a number")
	end

	-- Thanks to Incin for this bit of code :)
	if direction == t.orientation then return end

	if (direction - t.orientation) % 2 == 0 then
		t.turnLeft()
		t.turnLeft()
	elseif (direction - t.orientation) % 4 == 1 then
		t.turnRight()
	else
		t.turnLeft()
	end
end

-- temporary fix, later on i should implement backward coordanites (using math)
function t.back()
	t.turnRight()
	t.turnRight()
	t.forward()
	t.turnRight()
	t.turnRight()
end

function t.forward()
		if turtle.forward() then
			-- Change t.x and t.z coords
			t.x = t.x + xDiff[t.orientation]
			t.z = t.z + zDiff[t.orientation]

			t.saveCoords()
			return true
		else
			-- If he failed to move return false and don't change the coords.
			return false
		end
end

function t.up()
	t.debug("t.up function called")
	if turtle.up() then
		t.y = t.y + 1
		t.debug("Trying to save coords to file after going up")
		t.saveCoords()
		return true
	else
		return false
	end
end

function t.down()
	if turtle.down() then
		t.y = t.y - 1
		t.saveCoords()
		return true
	else
		return false
	end
end

local function digFunc(dig)
  return function()
    if dig() then
      t.blocks_dug = t.blocks_dug + 1
      return true
    else
      return false
    end
  end
end

t.digDown = digFunc(turtle.digDown)
t.digUp   = digFunc(turtle.digUp)
t.dig     = digFunc(turtle.dig)

-- This function saves the turtles position so it can be returned to later.
function t.saveCurrentPos(name)
	if type(name) ~= "string" then
		error("Position name must be a string.")
	end

	-- Creates a new table entry with "name" key
	t.saved_positions[name] = {
		x = t.x,
		y = t.y,
		z = t.z,
		orientation = t.orientation
	}
	t.savePositionsToFile()
end

function t.savePositionsToFile()
	writeFile(textutils.serialize(t.saved_positions), t.posfile, "w")
end

function t.getSavedPositions()
	if fs.exists(t.posfile) then
		local file = fs.open(t.posfile, "r")
		local data = file.readAll()
		file.close()

		local positions = textutils.unserialize(data)
		if type(positions) ~= "table" then
			error "[ERROR] Failed to unserialize positions"
		end

		return positions
	else
		-- Create one
		local positions = {}
		local f = assert(io.open(t.posfile, 'w'))
		f:write(textutils.serialize(positions))
		f:close()
		return positions
	end
end

function t.getPos()
	if fs.exists(t.posfile) then
		local file = fs.open(t.posfile, "r")
		t.saved_positions = textutils.unserialize(file.readAll())
		file.close()
	else
		error("No file to get positions from.")
	end
end

function t.moveToPos(name)
	if t.saved_positions[name] == nil then error("[ERROR] t.saved_positions["..name.."] is nil") end
	for i,v in ipairs(t.saved_positions[name]) do print(i,v) end -- temp

	t.moveTo(t.saved_positions[name].x, t.saved_positions[name].y, t.saved_positions[name].z, t.saved_positions[name].orientation)
end

-- Careful this breaks blocks.
function t.moveTo(xTarget, yTarget, zTarget, orientationTarget)
  if not xTarget or not yTarget or not zTarget or not orientationTarget then
    t.debug('Here are all the params for the moveTo function:')
    t.debug('xTarget='..xTarget..'yTarget='..yTarget..'zTarget='..zTarget..'orientationTarget='..orientationTarget, 4)
    error("t.moveTo Can't travel to nil!, read logs for more info")
  end
  -- Moves to t.y
  while yTarget < t.y do
    t.digDown()
    t.down()
		while turtle.attackDown() do end
  end

  while yTarget > t.y do
    t.digUp()
    t.up()
		while turtle.attackUp() do end
  end

  -- Turns to correct t.orientation then moves forward until its at the right t.x cord
  if xTarget < t.x then
    t.look('west')
    while xTarget < t.x do
      t.dig()
      t.forward()
			while turtle.attack() do end
    end
  end

  if xTarget > t.x then
    t.look('east')
    while xTarget > t.x do
      t.dig()
      t.forward()
			while turtle.attack() do end
    end
  end

  -- Turns to correct t.orientation then moves forward until its at the right t.z cord
  if zTarget < t.z then
    t.look('north')
    while zTarget < t.z do
      t.dig()
      t.forward()
			while turtle.attack() do end
    end
  end
  if zTarget > t.z then
    t.look('south')
    while zTarget > t.z do
      t.dig()
      t.forward()
			while turtle.attack() do end
    end
  end
  -- Look to correct orientation
  t.look(orientationTarget)
end

function t.calcFuelForPos(posName)
	if posName == nil then
		t.debug("pos is nil in t.calcFuelForPos")
	elseif not t.saved_positions[posName] then
		t.debug("t.saved_positions["..tostring(posName).."] Does not exist")
	else
		local fuelNeeded = 0
		pos = t.saved_positions[posName]

		fuelNeeded = fuelNeeded + (math.abs(pos.x) - math.abs(t.x))
		fuelNeeded = fuelNeeded + (math.abs(pos.y) - math.abs(t.y))
		fuelNeeded = fuelNeeded + (math.abs(pos.z) - math.abs(t.z))

		return math.abs(fuelNeeded)
	end
end
t.init()
return t
