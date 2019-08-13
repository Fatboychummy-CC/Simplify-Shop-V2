local smenus = require("modules.menus.layouts.simple")

----------------------------------------------------------
-- func:    removeItem
-- inputs:  none
-- returns: nil
-- info:    Runs the remove item prompt.
----------------------------------------------------------
local function removeItem(cache, actuallyRemove)
  while true do
    local menu = smenus.newMenu()
    menu.title = "Delete items."
    menu.info = "Select an item to delete."

    local registry = {}
    local cacheItems = cache.getCache()

    for key, reg in pairs(cacheItems) do
      for damage, registration in pairs(reg) do
        -- for each item in the cache
        -- get the cache registration
        local sName = registration.name
        -- if the name is too long, shorten it.
        if #sName > 12 then
          sName = sName:sub(1, 9) .. "..."
        end
        menu:addMenuItem(
          sName,
          "Remove this item",
          "Remove the item " .. key .. "[" .. tostring(damage) .. "]"
        )
        -- add to the registry (temp, not the cache registry)
        registry[#registry + 1] = {key = key, damage = damage}
      end
    end
    menu:addMenuItem(
      "Return",
      "Go back.",
      "Return to the previous menu."
    )
    local ans = menu:go()

    if ans == #menu.menuItems.selectables then
      break
    else
      -- ask the player if they really want to remove the selected item.
      actuallyRemove(registry[ans], cache)
    end
  end
end

return removeItem
