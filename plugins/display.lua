--- Display plugin for displaying shop contents and whatnot.

local module          = require "plugins.module"
local config          = require "plugins.config"
local multimon        = require "multimon"
local window_utils    = require "window_utilities"
local logging         = require "logging"
local display_context = logging.createContext("DISPLAY", colors.black, colors.lightGray)

local monitors

module.registerEventCallback("init", function()
  display_context.debug("Init monitors")
  monitors = multimon.monitors(table.unpack(config.loaded.monitors))

  monitors(function(mon)
    mon.setBackgroundColor(config.loaded.init.monitor_background)
    mon.setTextColor(config.loaded.init.monitor_text_colour)
    mon.clear()

    local w = mon.getSize()

    window_utils.writeCenteredText(mon, nil, nil, config.loaded.init.monitor_text, math.floor(w * 2 / 3))
  end)
end)

module.registerEventCallback("ready", function()
  while true do
    display_context.debug("Redraw.")
    module.pushEvent("redraw", monitors)
    sleep(30)
  end
end)

module.registerEventCallback("stop", function()
  display_context.debug("Stop monitors")

  monitors(function(mon)
    mon.setBackgroundColor(config.loaded.stop.monitor_background)
    mon.setTextColor(config.loaded.stop.monitor_text_colour)
    mon.clear()

    local w = mon.getSize()

    window_utils.writeCenteredText(mon, nil, nil, config.loaded.stop.monitor_text, math.floor(w * 2 / 3))
  end)
end)
