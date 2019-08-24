local funcs = {}
local ers = require("modules.etc.errors")
local simple = require("modules.menus.layouts.simple")
local dCopy = require("modules.etc.dcop")
local converter = require("modules.etc.colors")
local meta = getmetatable(simple.newMenu())
meta = dCopy(meta)
local met = meta.__index
meta.__index = met
local ec = ers.create

local mx, my = term.getSize()

function met:addMenuItem(selection, tp,  append, info)
  selection = type(selection) == "string" and selection
                or error(ec(1, "string", selection))
  --
  tp = type(tp) == "string" and tp or error(ec(2, "string", tp))
  if tp ~= "boolean" and tp ~= "string" and tp ~= "number" and tp ~= "password" and tp ~= "color" and tp ~= "subpage" then
    error("Bad argument #2, expected string stating 'boolean', 'string', "
          .. "'password', 'color', 'subpage', or 'number'", 2)
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
  if append == "true" then
    append = true
  elseif append == "false" then
    append = false
  end
  local m = self.menuItems
  table.insert(m.selectables, selection)
  table.insert(m.infos, info)
  table.insert(m.appends, append)
  table.insert(m.types, tp)

  return self
end

function met:getType(i)
  return self.menuItems.types[i]
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
  local inc = 4
  self.menuItems.lineStart = inc
  print()
  term.setBackgroundColor(self.colors.bg)
  term.setTextColor(self.colors.fg)

  self:update()

  term.setBackgroundColor(self.colors.appendbg)
  term.setTextColor(self.colors.appendfg)
  local ind = 1
  for i = self.maxSelection - 3, self.maxSelection do
    local append = self.menuItems.appends[i]
    if type(append) == "boolean" or append then
      if self.menuItems.types[i] == "boolean" then
        term.setCursorPos(15, inc + ind)
        if self.selected == i then
          term.setBackgroundColor(self.colors.selectedbg)
          term.setTextColor(self.colors.selectedfg)
        end
        if append == true then
          io.write(" false [true]")
        elseif append == false then
          io.write("[false] true")
        else
          io.write(" false true ?")
        end
        if self.selected == i then
          term.setBackgroundColor(self.colors.appendbg)
          term.setTextColor(self.colors.appendfg)
        end
      else
        term.setCursorPos(15, inc + ind)
        if self.menuItems.types[i] == "password" then
          io.write(
            #tostring(append) < mx - 15
            and string.rep('*', #tostring(append))
            or string.rep('*', #(tostring(append):sub(1, mx - 18))) .. "..."
          )
        elseif self.menuItems.types[i] == "color" then
          io.write((converter(append) or "err") .. " (" .. tostring(append) .. ")")
        else
          io.write(
            #tostring(append) < mx - 15 and tostring(append)
              or tostring(append):sub(1, mx - 18) .. "..."
          )
        end
      end
      ind = ind + 1
    end
  end

  self:update2()

  return self
end

local function getColorInput(self)
  local function writeAt(stf)
    term.setCursorPos(15, self.menuItems.lineStart + self.slot)
    io.write("                          ")
    term.setCursorPos(15, self.menuItems.lineStart + self.slot)
    io.write(stf)
  end
  local done = false
  while true do
    writeAt("")
    local input = read()
    if tonumber(input) then
      if converter(tonumber(input)) then
        return tonumber(input)
      else
        writeAt("Not a color!")
        os.sleep(1)
        writeAt("")
      end
    else
      if converter(input) then
        return converter(input)
      else
        writeAt("Not a color!")
        os.sleep(1)
        writeAt("")
      end
    end
  end
end

local function getInsertion(self, typ)
  term.setBackgroundColor(self.colors.selectedbg)
  term.setTextColor(self.colors.selectedfg)
  if typ == "boolean" then
    if self.menuItems.appends[self.selected] == true then
      return false
    else
      return true
    end
  elseif typ == "string" or typ == "password" then
    term.setCursorPos(15, self.menuItems.lineStart + self.slot)
    io.write("                          ")
    term.setCursorPos(15, self.menuItems.lineStart + self.slot)
    return read(typ == "password" and "*" or nil)
  elseif typ == "number" then
    term.setCursorPos(15, self.menuItems.lineStart + self.slot)
    io.write("                          ")
    term.setCursorPos(15, self.menuItems.lineStart + self.slot)
    return tonumber(read()) or 0
  elseif typ == "color" then
    return getColorInput(self)
  elseif typ == "subpage" then
    return "SUB"
  else
    error(ec(2, "string", typ))
  end
end

function met:go(updater)
  do
  local tp, stp = type(self)
  self = tp == "module" and stp == "menuObject" and self
           or error(ec(0, "module (subtype:menuObject)", self))

  end
  local oldbg = term.getBackgroundColor()
  local oldfg = term.getTextColor()
  if self.menuItems.selectables[self:count()] ~= "Exit" then
    table.insert(self.menuItems.selectables, "Exit")
    table.insert(self.menuItems.types, "string")
    table.insert(self.menuItems.infos, "Return to the previous screen.")
    table.insert(self.menuItems.appends, "Exit this menu")
  end

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
        if sel == self:count() then
          return self:count()
        end

        local temp = getInsertion(self, self.menuItems.types[sel])
        if temp == "SUB" then
          return self.selected
        end
        self.menuItems.appends[sel] = temp
        if type(updater) == "function" then
          updater(sel)
        end
      end
    end

    self:draw()
  end

  return false
end

function funcs.newMenu()
  local tmp = simple.newMenu()
  setmetatable(tmp, meta)

  tmp.menuItems = {
    lineStart = 5,
    selectables = {
    },
    types = { -- "boolean", "string", "number"
    },
    infos = {
    },
    appends = {
    },
  }

  tmp.colors = {
    bg = colors.black,
    fg = colors.white,
    appendbg = colors.black,
    appendfg = colors.gray,
    infobg = colors.black,
    infofg = colors.lightGray,
    selectedbg = colors.black,
    selectedfg = colors.lightGray
  }



  return tmp
end

return funcs
