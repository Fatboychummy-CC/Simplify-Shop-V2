local funcs = {}
local met = {}
local meta = {__index = met, __type = "list"}

local ers = require(".modules.etc.errors")
require(".modules.etc.typer")
local ec = ers.create
local ew = ers.watch

function met:getItem(i)
  return self.list.item[i]
end
function met:getPrice(i)
  return self.list.price[i]
end
function met:setItem(i, item)
  self.list.item[i] = item
end
function met:setPrice(i, price)
  self.list.price[i] = price
end

function met:addItem(item, price)
  ew(1, "list", self)
  ew(2, "string", item)
  ew(3, "number", price)

  self:setItem(#self.list.item + 1, item)
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

function met:draw(m, dcml)
  ew(1, "list", self)
  ew(2, "table", m)

  local line = string.rep(' ', self.pos[3] - self.pos[1] + 1)

  m.setCursorPos(self.pos[1], self.pos[2])
  m.setBackgroundColor(self.headers.colors.bg)
  m.setTextColor(self.headers.colors.fg)
  m.write(line)

  m.setCursorPos(self.pos[1] + 1, self.pos[2])
  m.write(self.headers[1])

  m.setCursorPos(self.pos[3] - #self.headers[2], self.pos[2])
  m.write(self.headers[2])

  for i = 1, self:getSize() do
    local item = self.list.item[i]
    local price = self.list.price[i]

    m.setCursorPos(self.pos[1], self.pos[2] + i)
    m.setBackgroundColor(i % 2 == 1 and self.colors[1].bg or self.colors[2].bg)
    m.setTextColor(i % 2 == 0 and self.colors[1].fg or self.colors[2].fg)
    m.write(line)

    m.setCursorPos(self.pos[1] + 1, self.pos[2] + i)
    m.write(self.list.item[i])

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

function funcs.createList(x1, y1, x2, y2)
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
  local tmp = setmetatable({}, meta)

  tmp.headers = {
    "Item",
    "Price",
    colors = {
      bg = colors.purple,
      fg = colors.white
    }
  }
  tmp.list = {
    item = {},
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
    }
  }
  tmp.pos = {x1, y1, x2, y2}

  return tmp
end

return funcs
