local smenus = require("modules.menus.layouts.simple")

----------------------------------------------------------
-- func:    actuallyRemove
-- inputs:  registry|table
-- returns: nil
-- info:    Asks the player if they would like to "actually remove"
--          the item they selected.
----------------------------------------------------------
local function actuallyRemove(registry, cache)
  local menu = smenus.newMenu()
  menu.title = "Confirmation"
  menu.info = "Item to be deleted: " .. tostring(registry.key) .. " ["
              .. tostring(registry.damage) .. "]"

  menu:addMenuItem(
    "Yes",
    "Delete item.",
    "Delete the item (Warning: this is permanent)."
  )
  menu:addMenuItem(
    "No",
    "Keep item.",
    "Do not remove the item from the shop."
  )

  local ans = menu:go()
  if ans == 1 then
    cache.removeFromCache(registry.key, registry.damage)
  end
end

return actuallyRemove
