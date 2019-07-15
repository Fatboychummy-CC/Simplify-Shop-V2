local funcs = {}
local ers = require("modules.etc.errors")
local simple = require("modules.text.menus.simple")
local dCopy = require("modules.etc.dcop")
local meta = getmetatable(simple.newMenu())
meta = dCopy(meta)
local met = meta.__index
meta.__index = met
local ec = ers.create

function met:addMenuItem(selection, tp,  append, info)
  selection = type(selection) == "string" and selection
                or error(ec(1, "string", selection))
  --
  tp = type(tp) == "string" and tp or error(ec(2, "string", tp))
  if tp ~= "boolean" and tp ~= "string" and tp ~= "number" then
    error("Bad argument #2, expected string stating 'boolean', 'string', or "
          .. "'number'", 2)
  end
  --
  append = type(append) == "string" and append
           or type(append) == "number" and append
           or type(append) == "boolean" and tostring(append)
           or type(append) == "nil" and ""
             or error(ec(3, "string, number, boolean or nil", append))
  --
  info = type(info) == "string" and info or type(info) == "nil" and ""
           or error(ec(4, "string or nil", info))
  --
  local m = self.menuItems
  table.insert(m.selectables, selection)
  table.insert(m.infos, info)
  table.insert(m.appends, append)
  table.insert(m.types, tp)

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

local function getInsertion(self, typ)
  print(self, typ)
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
        local sel = self.selected
        print(sel)
        local temp = getInsertion(self, self.menuItems.types[sel])
        print(temp)
        os.sleep(1)
      end
    end

    self:draw()
  end
end

function funcs.newMenu()
  local tmp = simple.newMenu()
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


  return tmp
end

return funcs
