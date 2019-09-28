local funcs = {}
local meta = {}
local met = {}
meta.__index = met
met.__type = "cache"

function funcs.new()
  local tmp = setmetatable({}, meta)

  return tmp
end
