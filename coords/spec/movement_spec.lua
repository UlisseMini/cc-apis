local start = {
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

  describe(thing, function()
    before_each(function() reset(c) end)

    it('should change  when it moves', function()
      move(true)
      assert.are_not.same ( start, c )
    end)

    it('should not change  when moving fails ', function()
      move(false)
      assert.are.same ( start, c )
    end)

    it('should return true when passed true', function()
      assert.are.equal(true, move(true))
    end)

    it('should return false when passed false', function()
      assert.are.equal(false, move(false))
    end)
  end)
end

describeM('t.forward')
describeM('t.back')
describeM('t.up')
describeM('t.down')


-- TODO: Add Test cases for other functions.
describe('t.forward', function()
  it('should decrement z when heading north', function()
    t.forward(true)
    assert.are.same({z = -1, x = 0, y = 0, ori = 0}, c)
  end)
end)
