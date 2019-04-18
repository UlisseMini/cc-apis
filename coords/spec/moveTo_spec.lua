require('fs')
require('turtle')
require('textutils')

local coords = dofile('../coords.lua')

describe('turtle.moveTo', function()
  it('should be able to travel away and back', function()
    local t = {
      x = -39,
      y = 294,
      z = -139,
      ori = 2
    }

    turtle.moveTo( t.x, t.y, t.z, t.ori )

    assert.are.same(t, coords)

    turtle.moveTo(0, 0, 0, 0)
    assert.are.same({
        x = 0,
        y = 0,
        z = 0,
        ori = 0,
      }, coords)
  end)
end)
