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
    if a.__type then
      return a.__type
    end
    return "table"
  end

  return oldType(input)
end

_G.type = setmetatable(
  {},
  {
    __call = typer,
    __type = "function"
  }
)
