local mon = require("modules.etc.monitor")

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

  monitor.setCursorPos(1, 1)
  if err == "Terminated" then
    mon.print("Simplify Shop has been terminated.")
    return
  end

  local lines = mon.print("Simplify Shop encountered an error it could not recover from.")
  monitor.setCursorPos(1, 3 + lines)

  lines = lines + mon.print(err)

  monitor.setCursorPos(1, 5 + lines)
  lines = lines + mon.print("Please let Fatboychummy#4287 on Discord know.")

end

return bsod
