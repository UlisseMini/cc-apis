-- Fake cc turtle api used in testing
-- TODO:
-- Add fuel system instead of randomly returning true / false
local math = require("math")
local os   = require("os")
local slot = math.random(1,16)

math.randomseed(os.clock())

-- return true or false randomly. if the first argument is
-- a bool then return that instead.
local function trueorfalse(bool)
  if bool ~= nil then return bool end

  local n = math.random(0, 1)
  if n == 0 then
    return true
  else
    return false
  end
end

-- Some items for one to randomly be picked by randitem
local items = {
  "minecraft:sand",
  "minecraft:iron_ingot",
  "minecraft:dirt",
  "minecraft:redstone",
  "minecraft:stone"
}

turtle = {}

function turtle.getSelectedSlot()
  return slot
end

function turtle.select(n)
  if n < 1 then
    error(("can't select %q too low"):format(n))
  elseif n > 16 then
    error(("can't select %q too high"):format(n))
  end

  slot = n
end

-- New function that returns true or false.
-- @param event will be corutine.yield'ed if inside a yieldable coroutine.
-- this allows for tests to limit atempted moves.
local function fn(event)
  return function(...)
    if coroutine.isyieldable() then
      coroutine.yield(event)
    end

    return trueorfalse(...)
  end
end

-- return a function that always returns ...
local function always(...)
  local r = {...}
  return function()
    return table.unpack(r)
  end
end

-- Moving functions will return true or false randomly
turtle.forward = fn 'forward'
turtle.back    = fn 'back'
turtle.down    = fn 'down'
turtle.up      = fn 'up'

-- Turning functions return nothing so i can leave them blank
-- TODO: Add yields so they can be tested.
function turtle.turnRight () end
function turtle.turnLeft  () end

-- Digging functions always return false.
turtle.dig     = always(false)
turtle.digUp   = always(false)
turtle.digDown = always(false)

-- Attacking functions always return false
turtle.attackDown = always(false)
turtle.attackUp   = always(false)
turtle.attack     = always(false)
