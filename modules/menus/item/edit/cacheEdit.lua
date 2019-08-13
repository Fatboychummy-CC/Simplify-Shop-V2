local imenus = require("modules.menus.layouts.insert")

----------------------------------------------------------
-- func:    cacheEdit
-- inputs:  c: cache|table, registry: registry|table
-- returns: nil
-- info:    Edit a single cache entry.
----------------------------------------------------------
local function cacheEdit(c, registry, cache)
  local menu = imenus.newMenu()
  menu.title = "Edit item."
  menu.info = registry.key .. " with damage " .. tostring(registry.damage)
              .. "."

  menu:addMenuItem(
    "Display Name",
    "string",
    c[registry.key][registry.damage].name,
    "The name to be displayed for this item."
  )
  menu:addMenuItem(
    "Value",
    "number",
    c[registry.key][registry.damage].value,
    "The value of this item (krist per item)"
  )
  menu:addMenuItem(
    "Enabled",
    "boolean",
    c[registry.key][registry.damage].enabled,
    "If disabled, the shop will not display this item, but it will not be deleted."
  )

  menu:go()
  if menu.menuItems.appends[3] then
    menu.menuItems.appends[3] = true
  else
    menu.menuItems.appends[3] = false
  end

  cache.addToCache(
    menu.menuItems.appends[1],
    registry.key,
    registry.damage,
    menu.menuItems.appends[2],
    menu.menuItems.appends[3]
  )
end

return cacheEdit
