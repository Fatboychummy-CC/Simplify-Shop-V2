local ec = require("modules.etc.errors").create

local function dCopy(a)
  a = type(a) == "table" and a or error(ec(1, "table", a))

  local tmp = {}
  for k, v in pairs(a) do
    if type(v) == "table" and v ~= a then
      tmp[k] = dCopy(v)
    else
      tmp[k] = v
    end
  end

  return tmp
end

return dCopy
