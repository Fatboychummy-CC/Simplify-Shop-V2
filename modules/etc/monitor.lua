local funcs = {}

local monitor = peripheral.find("monitor")

function funcs.setDefaultMonitor(default)

end

function funcs.print(...)
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
  for i, thing in ipairs(strs) do
    if i ~= 1 then
      count = count + monPrint(thing)
    end
  end

  return count
end

return funcs
