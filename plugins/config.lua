--- Config handler plugin.
--- require "plugins.config"

local file_helper = require "file_helper"
local logging     = require "logging"

local config_context = logging.createContext("CONFIG", colors.black, colors.yellow)

local DIR = fs.getDir(shell.getRunningProgram()) -- should point to the root of shop.lua
local CONF_FILE = fs.combine(DIR, "SSV2.conf")

local config = {}

--- Load configuration on startup (and define default value should no config exist)
config_context.debug("Loading config.")
config.loaded = file_helper.unserialize(CONF_FILE, {
  general_info = {
    owner = "Unknown",
    name = "Unnamed Shop",
    contact = "Nobody",
  },
  activity_dots = {
    alive = {
      colour = colours.blue,
      position = { 1, 1 },
      time = 0.5
    },
    purchase = {
      colour = colours.green,
      position = { 1, 2 },
      time = 0.5
    },
    redraw = {
      colour = colours.red,
      position = { 1, 3 },
      time = 0.5
    }
  },
  monitors = { "left" },
  init = {
    monitor_background = colours.yellow,
    monitor_text_colour = colours.black,
    monitor_text = "Initializing shop... Please wait.",
  },
  stop = {
    monitor_background = colours.blue,
    monitor_text_colour = colours.white,
    monitor_text = "Shop has stopped.",
  },
})
config_context.info("Config has been loaded.")

--- Call this after any configuration change.
function config.save()
  config_context.info("Config saved.")
  file_helper.serialize(CONF_FILE, config.loaded)
end

return config
