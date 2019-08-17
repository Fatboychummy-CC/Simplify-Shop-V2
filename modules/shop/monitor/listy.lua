local funcs = {}
local met = {}
local meta = {__index = met}

local ers = require("modules.etc.errors")
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
  self:setItem(#self.list.item + 1, item)
  self:setPrice(#self.list.price + 1, price)
end
function met:delItem(i)
  table.remove(self.list.item, i)
  table.remove(self.list.item, i)
end

function met:draw()
  local mon = peripheral.wrap(settings.get("shop.monitor.monitor"))
  if not mon then error("Failed to get monitor for listy.", 2) end
  
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
    "Price"
  }
  tmp.list = {
    item = {},
    price = {}
  }
  tmp.pos = {x1, y1, x2, y2}

  return tmp
end

return funcs
