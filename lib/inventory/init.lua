--- Inventory library
-- Helpful inventory methods, shimmed for each version.

local version = tonumber(_HOST:match("1.(%d+)"))

if version >= 13 then
  return require "inventory.1_13" (require "inventory.inventory")
else
  return require "inventory.1_12" (require "inventory.inventory")
end
