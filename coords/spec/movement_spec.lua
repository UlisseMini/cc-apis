require('fs')
require('turtle')
require('textutils')

local coords = dofile('../coords.lua')

local startCoords = {
  x = 0,
  y = 0,
  z = 0,
  ori = 0
}

local function reset(c)
  c.x, c.y, c.z, c.ori = 0,0,0,0
end

-- describe a generic move spec.
-- TODO: Abstract 'reset(coords)' away
--          (was having issue with scope from the testing framework)
function describeM(thing)
  local move = assert(load('return '..thing))()
  if move == nil then
    error(("failed to get the value for %q"):format(thing))
  end

  describe(thing, function()
    it('should change coords when it moves', function()
      move(true)
      assert.are_not.same ( startCoords, coords )
      reset(coords)
    end)

    it('should not change coords when moving fails ', function()
      move(false)
      assert.are.same ( startCoords, coords )
      reset(coords)
    end)

    it('should return true when passed true', function()
      assert.are.same(move(true), true)
      reset(coords)
    end)

    it('should return false when passed false', function()
      assert.are.same(move(false), false)
      reset(coords)
    end)
  end)
end

describeM('turtle.forward')
describeM('turtle.back')
describeM('turtle.up')
describeM('turtle.down')


-- TODO: Add Test cases for other functions.
describe('turtle.forward', function()
  it('should decrement z when heading north', function()
    turtle.forward(true)
    assert.are.same({z = -1, x = 0, y = 0, ori = 0}, coords)
  end)
end)
