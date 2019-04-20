describe('turtle.moveTo', function()
  it('should be able to travel away and back', function()
    local needed = 984
    local t = {
      x = -39,
      y = 294,
      z = -139,
      ori = 2
    }

    moveToLimit(needed, t.x, t.y, t.z, t.ori)
    --turtle.moveTo(t.x, t.y, t.z, t.ori)
    assert.are.same(t, coords)

    -- moveToLimit(needed, 0, 0, 0, 0)
    turtle.moveTo(0, 0, 0, 0)
    assert.are.same({
        x = 0,
        y = 0,
        z = 0,
        ori = 0,
      }, coords)
  end)

  it('should not move if it is already there', function()

    -- moveToLimit(0,0,0,0,0)
    turtle.moveTo(0,0,0,0)
    assert.are.same({
        x = 0,
        y = 0,
        z = 0,
        ori = 0,
      }, coords)
  end)
end)
