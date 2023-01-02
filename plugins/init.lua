local module = require "plugins.module"
local file_helper = require "file_helper"

local dir = fs.combine(fs.getDir(shell.getRunningProgram()), "plugins")

---@class plugins
local plugins = { loaded = {} }

function plugins.loadPlugins()
  local list = fs.list(dir)
  local ignore = {
    ["init.lua"] = true,
    ["module.lua"] = true,
    ["config.lua"] = true
  }

  for _, filename in ipairs(list) do
    if not ignore[filename] and not fs.isDir(filename) then
      local data = file_helper.getAll(fs.combine(dir, filename))

      local loaded, err = load(data, "=" .. filename, 't', _ENV)
      if not loaded then
        error(err, 0)
      end

      local ok, plugin = pcall(loaded, "PLUGIN")
      if not ok then
        error(plugin, 0)
      end

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
    error(err, 0)
  end
end

return plugins
