describe('t.moveTo', function()
  it('should be able to travel away and back', function()
    local needed = 984
    local T = {
      x = -39,
      y = 294,
      z = -139,
      ori = 2
    }

    t.moveTo(T.x, T.y, T.z, T.ori)
    assert.are.same(T, c)

    t.moveTo(0, 0, 0, 0)
    assert.are.same({
        x = 0,
        y = 0,
        z = 0,
        ori = 0,
      }, c)
  end)

  it('should not move if it is already there', function()
    assert.are.same({
        x = 0,
        y = 0,
        z = 0,
        ori = 0,
      }, c)
  end)
end)
