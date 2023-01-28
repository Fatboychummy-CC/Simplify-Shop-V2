--- Display plugin for displaying shop contents and whatnot.

local module          = require "module"
local config          = require "config"
local multimon        = require "multimon"
local window_utils    = require "window_utilities"
local logging         = require "logging"
local display_context = logging.createContext("DISPLAY", colors.black, colors.lightGray)

local monitors

module.registerEventCallback("pre-init", function()
  display_context.debug("Init monitors")
  monitors = multimon.monitors(table.unpack(config.loaded.monitors))

  monitors(function(mon)
    mon.setBackgroundColor(config.loaded.pre_init.monitor_background)
    mon.setTextColor(config.loaded.pre_init.monitor_text_colour)
    mon.clear()

    local w = mon.getSize()

    window_utils.writeCenteredText(mon, nil, nil, config.loaded.pre_init.monitor_text, math.floor(w * 2 / 3))
  end)
end)

module.registerEventCallback("init", function()
  monitors(function(mon)
    mon.setBackgroundColor(config.loaded.init.monitor_background)
    mon.setTextColor(config.loaded.init.monitor_text_colour)
    mon.clear()

    local w = mon.getSize()

    window_utils.writeCenteredText(mon, nil, nil, config.loaded.init.monitor_text, math.floor(w * 2 / 3))
  end)
end)

module.registerEventCallback("ready", function()
  monitors(function(mon)
    mon.setBackgroundColor(colors.black)
    mon.clear()
  end)
  while true do
    display_context.debug("Redraw.")
    module.pushEvent("redraw", monitors)
    sleep(30)
  end
end)

--- Redraw monitors when queued
---@param monitors multimon
module.registerEventCallback("redraw", function(monitors)

end)

module.registerEventCallback("stop", function()
  display_context.debug("Stop monitors")

  local errored, err = module.errored()
  if errored then
    monitors(function(mon)
      mon.setBackgroundColor(config.loaded.error.monitor_background)
      mon.setTextColor(config.loaded.error.monitor_text_colour)
      mon.clear()

      local w = mon.getSize()

      ---@diagnostic disable-next-line `err` exists if `errored` is true.
      window_utils.writeCenteredText(mon, nil, nil, config.loaded.error.monitor_text:format(err), w - 4)
    end)
  else
    monitors(function(mon)
      mon.setBackgroundColor(config.loaded.stop.monitor_background)
      mon.setTextColor(config.loaded.stop.monitor_text_colour)
      mon.clear()

      local w = mon.getSize()

      window_utils.writeCenteredText(mon, nil, nil, config.loaded.stop.monitor_text, math.floor(w * 2 / 3))
    end)
  end
end)
