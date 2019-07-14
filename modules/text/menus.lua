local funcs = {}
local meta = {}
local met = {}
meta.__index = met


function funcs.newMenu()
  local tmp = {}
  setmetatable(tmp, meta)

  tmp.selects = {s = {}, i = {}, a = {}}
  tmp.title = "Menu"
  tmp.info = "Select an item."

  return tmp
end

return funcs
