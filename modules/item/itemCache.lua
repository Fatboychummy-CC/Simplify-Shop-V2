local funcs = {}
local meta = {}
local met = {}
meta.__index = met
meta.__call = function(self, arg)
  return self.t[arg]
end
met.__type = "cache"

local function tsort(a, b)
  if string.lower(a.displayName) > string.lower(b.displayName) then
    return false
  end
  return true
end

function funcs.new()
  local tmp = setmetatable({}, meta)
  tmp.t = {}
  return tmp
end

function met:addItem(name, dmg, display, count)
  table.insert(
    self.t,
    {
      name = name,
      damage = dmg,
      displayName = display,
      count = count
    }
  )
end

function met:clear()
  self.t = {}
end

function met:sort(d)
  table.sort(self.t, d or tsort)
end
