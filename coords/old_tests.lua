-- tester program used for making sure new versions work without bugs
require 'fs'
require 'turtle'
require 'textutils'

local t    = require("cords")
local os   = require("os")
local math = require("math")
local h    = require("helpers")

local defaultRet = "OK"
local testFailures = 0

local results = {}
local test    = {}

-- Reset the coordanites
local function resetCoords()
	t.moveTo(0,0,0,0)
end

function test.positions()
  local startingPos = t.dumpCoords()

  t.saveCurrentPos("start")
  -- Move around some
  for i=1,10 do
    for i=1,10 do t.forward() end
    t.turnRight()

    for i=1,10 do t.forward() end
    t.turnLeft()

    for i=1,10 do t.up() end
    for i=1,5 do t.down() end
  end

  -- Before you error to start make sure coordanites are not 0,0,0,0
  local middlePos = t.dumpCoords()

  -- If the coordanites are still 0, 0, 0, 0 then fail
  if textutils.serialize(middlePos) == textutils.serialize(startingPos) then
    error "Coordanites did not change."
  end
  --print(textutils.serialize(middlePos))

  t.moveToPos("start")
  local endingPos = t.dumpCoords()

  if textutils.serialize(endingPos) ~= textutils.serialize(startingPos) then
    error "Failed to error to start."
  end
end

function test.moveTo()
  local startingPos = t.dumpCoords()
  local expPos = {
    x = 120,
    y = 31,
    z = -391,
    orientation = 2,
  }

  t.moveTo(expPos.x, expPos.y, expPos.z, expPos.orientation)

  local endingPos = t.dumpCoords()

  if not h.isEqual(endingPos, expPos) then
    print(textutils.serialize(endingPos))
    error "Ending position is not equal to expected ending position"
  end
end

function test.calcFuelForPos()
  resetCoords()
  local fuelNeeded
  t.saveCurrentPos("start")

  fuelNeeded = t.calcFuelForPos("start")
  if fuelNeeded ~= 0 then
    error("fuelNeeded is " .. tostring(fuelNeeded) .. " expected 0")
  end

  local x, y, z = 30, -19, 49
  local o = t.orientation

  -- Move around some
  t.moveTo(x,y,z,o)

  fuelNeeded = t.calcFuelForPos("start")
  if fuelNeeded ~= 98 then
    error("fuelNeeded is " .. tostring(fuelNeeded) .. " expected 98")
  end

  -- Move some more
  t.moveTo(-10,20,-30,0)

  fuelNeeded = t.calcFuelForPos("start")
  if fuelNeeded ~= 60 then
    error("fuelNeeded is " .. tostring(fuelNeeded) .. " expected 60")
  end
end

function test.textutils()
  local want = {
    x = 32,
    y = 28,
  }

  -- serialize then unserialize
  local text = textutils.serialize(want)
  local got  = textutils.unserialize(text)

  if want.x ~= got.x then
    error ('want x = %q; got x = %q'):format(want.x, got.x)
  elseif want.y ~= got.y then
    error ('want y = %q; got y = %q'):format(want.y, got.y)
  end
end


local startTime = os.clock()

local pad = 20
-- Run the tests
for tname, tc in pairs(test) do
  local _, err = pcall(tc)

  io.write(tname .. (' '):rep(pad - #tname) .. '| ')
  if err then print(err)
         else print 'PASSED'
  end
end

print(("\nRan %d tests in %.5fs")
  :format(table.size(test), os.clock() - startTime))

if testFailures > 0 then
  print(testFailures .. " test failures")
else
  print "OK"

  -- tests passed, cleanup files.
  os.remove './val_lib.log'
  os.remove './savedPositions'
  os.remove './coords'
end
