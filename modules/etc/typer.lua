local oldType = _G.type

_G.type = function(input)
  local ok, a = pcall(getmetatable, input)
  if ok and oldType(input) == "table" and oldType(a) == "table" then
    if a.__type then
      return "userdata", a.__type
    end
    return "table"
  end

  return oldType(input)
end
