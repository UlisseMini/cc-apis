--- describeTurn tests a turning function.
-- @tparam number diff the difference in orientation after a turn.
-- @tparam string name the name of the function we are testing.
local function describeTurn(diff, name)
  local turn = assert(load('return ' .. name))()
  describe(name, function()
    it('increments orientation by ' .. diff, function()
      local want = c.ori + diff
      turn()
      assert.are.same(want, c.ori)
    end)

    it('does not go over 3 or below 0', function()
      for i=1,100 do
        turn()
        assert(not (c.ori > 3 or c.ori < 0),
          ('c.ori = %d (iteration #%d)'):format(c.ori, i))
      end
    end)
  end)
end

describeTurn(1, 't.turnRight')
describeTurn(-1, 't.turnLeft')
