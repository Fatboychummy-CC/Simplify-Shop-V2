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
  monitor.setTextColor(color.fg)
  monitor.clear()

  monitor.setCursorPos(1, 1)
  if err == "Terminated" then
    mon.print(monitor, "Simplify Shop V2 has been terminated.")
    return
  end

  local lines = mon.print(
    monitor,
    "Simplify Shop V2 encountered an error it could not recover from."
  )
  monitor.setCursorPos(1, 3 + lines)

  lines = lines + mon.print(monitor, err)

  monitor.setCursorPos(1, 5 + lines)
  lines = lines + mon.print(
    monitor,
    "Please let Fatboychummy#4287 on Discord know."
  )

  monitor.flush()

end

return bsod
