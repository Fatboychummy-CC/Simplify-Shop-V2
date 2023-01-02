local module = require "plugins.module"
local file_helper = require "file_helper"
local logging = require "logging"
local plugin_context = logging.createContext("PLUGIN_MAIN", colors.black, colors.yellow)

local dir = fs.combine(fs.getDir(shell.getRunningProgram()), "plugins")

---@class plugins
local plugins = { loaded = {} }

function plugins.loadPlugins()
  plugin_context.info("Loading plugins.")

  local list = fs.list(dir)
  local ignore = {
    ["init.lua"] = true,
    ["module.lua"] = true,
    ["config.lua"] = true
  }

  for _, filename in ipairs(list) do
    if not ignore[filename] and not fs.isDir(filename) then
      plugin_context.debug("Loading: %s", filename)
      local data = file_helper.getAll(fs.combine(dir, filename))

      local loaded, err = load(data, "=" .. filename, 't', _ENV)
      if not loaded then
        plugin_context.error(err)
        error(err, 0)
      end

      local ok, plugin = pcall(loaded, "PLUGIN")
      if not ok then
        plugin_context.error(err)
        error(plugin, 0)
      end

      plugin_context.debug("Loaded.")
      plugins.loaded[filename] = plugin
    end
  end
end

function plugins.run()
  local ok, err = pcall(
    parallel.waitForAll,
    module.run
  )

  if not ok then
    plugin_context.error(err)
    error(err, 0)
  end
end

return plugins
