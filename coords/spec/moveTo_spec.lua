-- require('fs')
-- require('turtle')
-- require('textutils')
-- 
-- local coords = dofile('../coords.lua')
-- 
-- describe('turtle.moveTo', function()
--   it('should be able to travel away and back', function()
--     turtle.moveTo(1, 2, 3, 4)
-- 
--     assert.are.same(coords,
--       {
--         x = 1,
--         y = 2,
--         z = 3,
--         ori = 4,
--       })
-- 
--     turtle.moveTo(0, 0, 0, 0)
--     assert.are.same(coords,
--       {
--         x = 0,
--         y = 0,
--         z = 0,
--         ori = 0,
--       })
--   end)
-- end)
