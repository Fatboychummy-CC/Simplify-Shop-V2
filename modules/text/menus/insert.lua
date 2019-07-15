local funcs = {}
local ers = require("modules.etc.errors")
local simple = require("modules.text.menus.simple")
local dCopy = require("modules.etc.dcop")
local meta = getmetatable(simple.newMenu())
meta = dCopy(meta)
local met = meta.__index
local ec = ers.create

local function getInsertion(self, typ)
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
        local temp = getInsertion(self, self.menuItems.types[sel])
        print(temp)
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

  return tmp
end

return funcs
