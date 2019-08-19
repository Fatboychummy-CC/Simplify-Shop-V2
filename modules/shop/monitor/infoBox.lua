local funcs = {}
local met = {}
local meta = {__index = met}

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

function met:draw(m)
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

function funcs.new(x1, y1, x2, y2, bgcolor, fgcolor, centered)
  ew(1, "number", x1)
  ew(2, "number", y1)
  ew(3, "number", x2)
  ew(4, "number", y2)
  ew(5, "number", bgcolor)
  ew(6, "number", fgcolor)

  local tmp = setmetatable({}, meta)

  tmp.pos = {x1, y1, x2, y2}
  tmp.colors = {
    bg = bgcolor,
    fg = fgcolor
  }
  tmp.lines = {}
  tmp.centered = centered

  return tmp
end

return funcs
