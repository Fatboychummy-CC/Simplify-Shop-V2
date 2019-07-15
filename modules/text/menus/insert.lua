local funcs = {}
local meta = {}
local met = {}
meta.__index = met
met.__type = "menuObject"

local ers = require("modules.etc.errors")
local ec = ers.create

function met:selectDown()
  self.selected = self.selected - 1
  if self.selected < 1 then
    self.selected = #self.menuItems.selectables
  end

  return self
end

function met:selectUp()
  self.selected = self.selected + 1
  if self.selected > #self.menuItems.selectables then
    self.selected = 1
  end

  return self
end

function met:addMenuItem(selection, append, info)
  selection = type(selection) == "string" and selection
                or error(ec(1, "string", selection))
  --
  append = type(append) == "string" and append
           or type(append) == "nil" and ""
             or error(ec(2, "string or nil", append))
  --
  info = type(info) == "string" and info or type(info) == "nil" and ""
           or error(ec(3, "string or nil", info))
  --
  local m = self.menuItems
  table.insert(m.selectables, selection)
  table.insert(m.infos, info)
  table.insert(m.appends, append)

  return self
end

function met:changeAppend(selection, append)
  selection = type(selection) == "number" and selection
                or error(ec(1, "number", selection))
  append = type(append) == "string" and append
             or error(ec(2, "string", append))
  --
  local m = self.menuItems
  if m.selectables[selection] then
    m.appends[selection] = append
  else
    local mx = #m.selectables
    local es = "Selection out of range. Current:" .. tostring(selection) .. " "
    if selection > mx then
      es = es .. "> Max:" .. tostring(mx)
    else
      es = es .. "< Min:1"
    end
    error(es, 2)
  end

  return self
end

function met:draw()
  term.setBackgroundColor(self.colors.bg)
  term.setTextColor(self.colors.fg)
  term.clear()
  term.setCursorPos(1, 1)
  local ln = print(self.title)
  term.setBackgroundColor(self.colors.infobg)
  term.setTextColor(self.colors.infofg)
  local ln2 = print(self.info)
  local inc = ln + ln2 + 1
  print()
  term.setBackgroundColor(self.colors.bg)
  term.setTextColor(self.colors.fg)

  for i, selection in ipairs(self.menuItems.selectables) do
    if self.selected == i then
      io.write('>')
    else
      io.write(' ')
    end
    print(selection)
  end

  term.setBackgroundColor(self.colors.appendbg)
  term.setTextColor(self.colors.appendfg)
  for i, append in ipairs(self.menuItems.appends) do
    term.setCursorPos(15, inc + i)
    io.write(append)
  end

  term.setBackgroundColor(self.colors.infobg)
  term.setTextColor(self.colors.infofg)
  term.setCursorPos(1, #self.menuItems.selectables + 3 + inc)
  print(self.menuItems.infos[self.selected])

  return self
end

local function getInsertion(typ)
  if typ == "boolean" then
    while true do
      local ev = {os.pullEvent("key")}
      local key = ev[2]
      if key == 205 or key == 208 then
        -- switch true/false
      elseif key == 28 then
        -- enter
      end
    end
  elseif typ == "string" then
    --TODO: this
  elseif typ == "number" then
    --TODO: this
  else
    error(ec(1, "string", typ))
  end
end

function met:go()
  self = type(self) == "table" and self.__type == "menuObject" and self
           or error(ec(0, "menuObject", self))
  --
  local oldbg = term.getBackgroundColor()
  local oldfg = term.getTextColor()

  while true do
    local ev = {os.pullEvent()}
    local event = ev[1]

    if event == "key" then
      local key = ev[2]

      if key == 200  then
        -- go down (up, since inverted)
        self:selectDown()
      elseif key == 208 then
        -- go up (down, since inverted)
        self:selectUp()
      elseif key == 28 then
        -- enter key pressed
        local sel = self.selection
        local temp = getInsertion(self.menuItems.types[sel])
        print(temp)
      end
    end

    self:draw()
  end
end

function funcs.newMenu()
  local tmp = {}
  setmetatable(tmp, meta)

  tmp.menuItems = {
    selectables = {
    },
    types = { -- "boolean", "string", "number"
    },
    infos = {
    },
    appends = {
    }
  }
  tmp.selected = 1
  tmp.title = "Menu"
  tmp.info = "Select an item."

  tmp.colors = {
    bg = colors.black,
    fg = colors.white,
    appendbg = colors.black,
    appendfg = colors.gray,
    infobg = colors.black,
    infofg = colors.lightGray
  }

  return tmp
end

return funcs
