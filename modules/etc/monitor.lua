local funcs = {}

local ep = require("modules.etc.extraPeripherals")
local e = require("modules.etc.errors")

function funcs.setDefaultMonitor(default)
  monitor = peripheral.wrap(monitor)
end

function funcs.print(monitor, ...)
  e.watch(1, "table", monitor)
  local strs = {...}
  local mx, my = monitor.getSize()
  local str = tostring(strs[1]) or ""
  local count = 0

  for word in str:gmatch("%S+") do
    local posx, posy = monitor.getCursorPos()

    if posx + #word > mx then
      monitor.setCursorPos(1, posy + 1)
      count = count + 1
    end
    monitor.write(word .. " ")
  end

  -- call splitprint on the rest of the inputs
  for i = 1, #strs do
    local thing = strs[i]
    if i ~= 1 then
      count = count + monPrint(thing)
    elseif i == #strs then
      local psx, psy = monitor.getCursorPos()
      if psy + 1 > my then
        monitor.scroll(1)
        monitor.setCursorPos(1, my)
      else
        monitor.setCursorPos(1, psy + 1)
      end

    end
  end

  return count
end

return funcs
