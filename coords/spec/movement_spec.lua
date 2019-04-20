local startCoords = {
  x = 0,
  y = 0,
  z = 0,
  ori = 0
}

-- describe a generic move spec.
function describeM(thing)
  local move = assert(load('return '..thing))()
  if move == nil then
    error(("failed to get the value for %q"):format(thing))
  end

  before_each(function() reset(coords) end)

  describe(thing, function()
    it('should change coords when it moves', function()
      move(true)
      assert.are_not.same ( startCoords, coords )
    end)

    it('should not change coords when moving fails ', function()
      move(false)
      assert.are.same ( startCoords, coords )
    end)

    it('should return true when passed true', function()
      assert.are.equal(true, move(true))
    end)

    it('should return false when passed false', function()
      assert.are.equal(false, move(false))
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
