local oldType = type

_G.type = function(input)
  local a = getmetatable(input)
  local tp = oldType(a)
  if tp == "table" then
    if a.__type then
      return "userdata", a.__type
    end
    return "table"
  end
  return tp
end
