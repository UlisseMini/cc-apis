-- Helper functions for tests.
local co = coroutine

-- reset coordanites in the c table.
function reset(c)
  c.x, c.y, c.z, c.ori = 0,0,0,0
end

--- call fn in a coroutine until it
-- A: Finishes
-- B: Number of yields is greater then limit
-- @tparam number limit
-- @tparam function fn
-- @param ... passed to fn
function withLimit(limit, fn, ...)
  local c = co.create(fn)

  -- first resume is treated as a call.
  local r = { co.resume(c, ...) }

  for i=0,limit do
    if co.status(c) == 'dead' then
      if r[2] then
        -- Finished with error, rethrow it.
        error(('%q (iteration #%d)'):format(err, i), 2)
      else
        -- Finished OK.
        return
      end
    end

    r = { co.resume(c) }
  end

  -- TODO: Convert this from a test error to a test failure.
  error(
    ('Limit (%d) exceeded, last event was %q'):format(limit, r[2]), 2)
end
