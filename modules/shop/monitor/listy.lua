local funcs = {}
local met = {}
local meta = {__index = met, __type = "list"}

local ers = require("modules.etc.errors")
require("modules.etc.typer")
local ec = ers.create
local ew = ers.watch

function met:getItem(i)
  return self.list.item[i]
end
function met:getPrice(i)
  return self.list.price[i]
end
function met:getCount(i)
  return self.list.count[i]
end
function met:setItem(i, item)
  self.list.item[i] = item
end
function met:setPrice(i, price)
  self.list.price[i] = price
end
function met:setCount(i, count)
  self.list.count[i] = count
end

function met:clearItems()
  self.list = {
    item = {},
    count = {},
    price = {}
  }
end
function met:addItem(item, count, price)
  ew(1, "list", self)
  ew(2, "string", item)
  ew(3, "number", count)
  ew(4, "number", price)

  self:setItem(#self.list.item + 1, item)
  self:setCount(#self.list.count + 1, count)
  self:setPrice(#self.list.price + 1, price)
end
function met:delItem(i)
  table.remove(self.list.item, i)
  table.remove(self.list.item, i)
end

function met:getSize()
  ew(1, "list", self)
  return #self.list.item
end

function met:setSelectionColor(fg, bg)
  self.colors.selected = {
    bg = bg,
    fg = fg
  }
end
function met:setOddColor(fg, bg)
  self.colors[2] = {
    bg = bg,
    fg = fg
  }
end
function met:setEvenColor(fg, bg)
  self.colors[1] = {
    bg = bg,
    fg = fg
  }
end
function met:setHeaderColor(fg, bg)
  self.colors.header = {
    bg = bg,
    fg = fg
  }
end

function met:hit(x, y)
  ew(1, "list", self)
  ew(2, "number", x)
  ew(3, "number", y)

  local sx, sx2, sy, sy2 = self.pos[1], self.pos[3], self.pos[2], self.pos[4]

  if x >= sx and x <= sx2 and y > sy and y <= sy2 then
    local itm = self:getItem(y - sy)
    if itm then
      return "Item", itm, y - sy
    else
      return false
    end
  end
  return false
end

function met:draw(m, dcml, selected)
  ew(1, "list", self)
  if self.enabled then
    ew(2, "table", m)
    ew(3, "number", dcml)
    ew(4, "number", selected)

    local line = string.rep(' ', self.pos[3] - self.pos[1] + 1)

    m.setCursorPos(self.pos[1], self.pos[2])
    m.setBackgroundColor(self.colors.header.bg)
    m.setTextColor(self.colors.header.fg)
    m.write(line)

    m.setCursorPos(self.pos[1] + 1, self.pos[2])
    m.write(self.headers[1])

    m.setCursorPos(math.floor(self.pos[3] * 0.75) - 5, self.pos[2])
    m.write(self.headers[2])

    m.setCursorPos(self.pos[3] - #self.headers[3], self.pos[2])
    m.write(self.headers[3])

    for i = 1, self:getSize() do
      local item = self.list.item[i]
      local price = self.list.price[i]
      m.setCursorPos(self.pos[1], self.pos[2] + i)

      if i ~= selected then
        m.setBackgroundColor(i % 2 == 1 and self.colors[1].bg or self.colors[2].bg)
        m.setTextColor(i % 2 == 1 and self.colors[1].fg or self.colors[2].fg)
      else
        m.setBackgroundColor(self.colors.selected.bg)
        m.setTextColor(self.colors.selected.fg)
      end
      m.write(line)

      m.setCursorPos(self.pos[1] + 1, self.pos[2] + i)
      m.write(self.list.item[i])

      m.setCursorPos(math.floor(self.pos[3] * 0.75) - 2 - (#tostring(self.list.count[i]) or 1), self.pos[2] + i)
      m.write(tostring(self.list.count[i]) or '0')

      if dcml > 0 then
        m.setCursorPos(self.pos[3] - 1 - dcml, self.pos[2] + i)
        m.write('.' .. string.rep('0', dcml))

        m.setCursorPos(
          self.pos[3] - 1 - #(string.match(tostring(price), "(%d+)%.?")) - dcml,
          self.pos[2] + i
        )
        m.write(tostring(price))
      else
        m.setCursorPos(self.pos[3] - #(tostring(price)), self.pos[2] + i)
        m.write(tostring(price))
      end
    end
  end
end

function funcs.createList(x1, y1, x2, y2, enabled)
  ew(1, "number", x1)
  ew(2, "number", y1)
  ew(3, "number", x2)
  if x2 < x1 then
    error("Bad argument #3: Expected to be greater than argument #1", 2)
  end
  ew(4, "number", y2)
  if y2 < y1 then
      error("Bad argument #4: Expected to be greater than argument #2", 2)
  end
  if type(enabled) ~= "boolean" and enabled ~= nil then
    error(ec(5, "boolean or nil", enabled))
  end

  local tmp = setmetatable({}, meta)

  tmp.headers = {
    "Item",
    "Count",
    "Price",
  }
  tmp.list = {
    item = {},
    count = {},
    price = {}
  }
  tmp.colors = {
    {
      bg = colors.gray,
      fg = colors.white
    },
    {
      bg = colors.black,
      fg = colors.white
    },
    header = {
      bg = colors.purple,
      fg = colors.white
    },
    selected = {
      bg = colors.white,
      fg = colors.black
    }
  }
  tmp.pos = {x1, y1, x2, y2}

  if type(enabled) == "boolean" then
    tmp.enabled = enabled
  else
    tmp.enabled = true
  end

  return tmp
end

return funcs
