local function bsod(err, monitor)
  local color = {}
  local start = 1

  if monitor.isColor() then
    color.bg = colors.blue
  else
    color.bg = colors.gray
  end
  color.fg = colors.white

  monitor.setBackgroundColor(color.bg)
  monitor.clear()

  local function monPrint(...)
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
        count = count + splitPrint2(thing)
      end
    end

    return count
  end

  monitor.setCursorPos(1, 1)
  if err == "Terminated" then
    splitPrint2("Simplify Shop has been terminated.")
    return
  end

  local lines = splitPrint2("Simplify Shop encountered an error it could not recover from.")
  print("LINES: " .. lines)
  monitor.setCursorPos(1, 3 + lines)
  local lLines = lines
  lines = splitPrint2(err)

  monitor.setCursorPos(1, 5 + lines + lLines)
  splitPrint2("Please let Fatboychummy#4287 on Discord know.")

end

return bsod
