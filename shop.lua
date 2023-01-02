--
-- Simplify Shop V2
---@creator Fatboychummy
---@license MIT

package.path = ("%s;lib/?.lua;lib/?/init.lua"):format(package.path)

local plugins = require "plugins"
plugins.loadPlugins()
plugins.run()
