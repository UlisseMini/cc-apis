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

-- Moving functions will return true or false randomly
turtle.forward = trueorfalse
turtle.back    = trueorfalse
turtle.down    = trueorfalse
turtle.up      = trueorfalse

-- Turning functions return nothing so i can leave them blank
function turtle.turnRight () end
function turtle.turnLeft  () end

-- Digging functions return true or false randomly.
turtle.dig     = trueorfalse
turtle.digUp   = trueorfalse
turtle.digDown = trueorfalse

-- Attacking functions return true or false randomly.
turtle.attackDown = trueorfalse
turtle.attackUp   = trueorfalse
turtle.attack     = trueorfalse
