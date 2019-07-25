local oldType = _G.type

local typeCheck = getmetatable(oldType)
if typeCheck then
  return
end
-- the above checks if there is a metatable for _G.type.  If there is, we have
-- already changed what _G.type is.

local function typer(_, input)
  local ok, a = pcall(getmetatable, input)
  local oldInType = oldType(input)

  if ok and oldInType == "table" and oldType(a) == "table" then
    if a.__masterType then
      return a.__masterType
    end
    if a.__type then
      return "userdata", a.__type
    end
    if oldInType == "string" then
      return "string"
    end
    return "table"
  end

  return oldType(input)
end
-- TODO: remove userdata

_G.type = setmetatable(
  {},
  {
    __call = typer,
    __masterType = "function"
  }
)
