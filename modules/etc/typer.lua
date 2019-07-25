local oldType = type
_G.type = function(input)
  local a = getmetatable(input)
  return oldType(a) == "table" and a.__type or oldType(input)
end
