--
-- Simplify Shop V2
---@creator Fatboychummy
---@license MIT

package.path = ("%s;lib/?.lua;lib/?/init.lua"):format(package.path)

local dir = fs.getDir(shell.getRunningProgram())

-- Setup logging
local logging = require "logging"
local main_context = logging.createContext("MAIN", colors.black, colors.white)
local log_win = window.create(term.current(), 1, 1, term.getSize())
logging.setWin(log_win)
logging.setFile(fs.combine(dir, "last_log.txt"))

if ... == "debug" then
  logging.setLevel(0)
  main_context.debug("Debugging is enabled.")
else
  logging.setLevel(1)
end

-- Load and run the plugins
main_context.debug("Require plugins.")
local plugins = require "plugin_loader"
plugins.loadPlugins()

main_context.info("Running shop.")
plugins.run()

main_context.debug("Closing log.")
logging.close()
