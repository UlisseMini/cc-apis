-- Fake fs api, so i can test outside of cc
local math = require("math")
local os   = require("os")

math.randomseed(
  math.random(1, 2147483647) / os.clock()
)

fs = {}

-- Helper functions
local function trueorfalse()
  local n = math.random(0, 1)

  if n == 0 then
    return false
  else
    return true
  end
end

local function exists(name)
  if type(name) ~= "string" then return false end
  return os.rename(name, name) and true or false
end

local function isFile(name)
  if type(name) ~= "string" then return false end
  if not exists(name) then return false end
  local f = io.open(name)
  local data = f:read(1)
  if data then
    f:close()
    return true
  else
    f:close()
    return false
  end
end

local function isDir(name)
  return ( exists(name) and not isFile(name) )
end

function fs.exists(fname)
  return ( isFile(fname) and isDir() )
end

function fs.open(file, mode)
  local handle = io.open(file, mode)

  local f = {}
  function f.readAll()
    return handle:read("*a")
  end

  function f.close()
    handle:close()
  end

  function f.write(data)
    handle:write(data)
  end

  return f
end
