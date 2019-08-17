local funcs = {}
local met = {}
local meta = {__index = met}

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

function funcs.createList()
  local tmp = setmetatable({}, meta)

  tmp.headers = {
    "Item",
    "Price"
  }
  tmp.list = {
    item = {},
    price = {}
  }

  return tmp
end

return funcs
