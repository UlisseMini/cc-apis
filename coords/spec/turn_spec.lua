--- describeTurn tests a turning function.
-- @tparam number diff the difference in orientation after a turn.
-- @tparam string name the name of the function we are testing.
local function describeTurn(diff, name)
  local turn = assert(load('return ' .. name))()
  describe(name, function()
    it('increments orientation by ' .. diff, function()
      local want = coords.ori + diff
      turn()
      assert.are.same(want, coords.ori)
    end)

    it('does not go over 3 or below 0', function()
      for i=1,100 do
        turn()
        assert(not (coords.ori > 3 or coords.ori < 0),
          ('coords.ori = %d (iteration #%d)'):format(coords.ori, i))
      end
    end)
  end)
end

describeTurn(1, 'turtle.turnRight')
describeTurn(-1, 'turtle.turnLeft')
