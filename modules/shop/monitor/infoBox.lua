local funcs = {}
local met = {}
local meta = {__index = met, __type = "infoBox"}

local ers = require("modules.etc.errors")
local ec = ers.create
local ew = ers.watch

local function box(m, x1, y1, x2, y2)
  local line = string.rep(' ', x2 - x1)

  for i = y1, y2 do
    m.setCursorPos(x1, i)
    m.write(line)
  end
end

function met:setLine(index, line)
  ew(1, "infoBox", self)
  ew(2, "number", index)
  ew(3, "string", line)
  self.lines[index] = line
end

function met:draw(m)
  ew(1, "infoBox", self)
  ew(2, "table", m)

  m.setBackgroundColor(self.colors.bg)
  m.setTextColor(self.colors.fg)
  box(m, table.unpack(self.pos))
  for i, line in ipairs(self.lines) do
    if centered then

    else
      m.setCursorPos(self.pos[1] + 1, self.pos[2] + i)
      m.write(line)
    end
  end
end

function funcs.new(x1, y1, x2, y2, bgcolor, fgcolor, centered, enabled)
  ew(1, "number", x1)
  ew(2, "number", y1)
  ew(3, "number", x2)
  ew(4, "number", y2)
  ew(5, "number", bgcolor)
  ew(6, "number", fgcolor)
  if type(centered) ~= "boolean" and centered ~= nil then
    error(ec(7, "boolean or nil", centered))
  end
  if type(enabled) ~= "boolean" and enabled ~= nil then
    error(ec(8, "boolean or nil", enabled))
  end

  local tmp = setmetatable({}, meta)

  tmp.pos = {x1, y1, x2, y2}
  tmp.colors = {
    bg = bgcolor,
    fg = fgcolor
  }
  tmp.lines = {}

  if type(centered) == "boolean" then
    tmp.centered = centered
  else
    tmp.centered = false
  end
  if type(enabled) == "boolean" then
    tmp.enabled = enabled
  else
    tmp.enabled = true
  end

  return tmp
end

return funcs
