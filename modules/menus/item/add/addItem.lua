local smenus = require("modules.menus.layouts.simple")

----------------------------------------------------------
-- func:    addItem
-- inputs:  none
-- returns: nil
-- info:    Runs the add item menu.
----------------------------------------------------------
local function addItem(scanChest, getDetails, cache)
  local menu = smenus.newMenu()
  menu.title = "Add Items."
  menu.info = "Add items via a chest in front of the turtle."

  menu:addMenuItem(
    "Scan",
    "Scan the chest.",
    "Scan the chest. You will be prompted for each item for it's price and etc."
  )
  menu:addMenuItem(
    "Return",
    "Go back.",
    "Return to the startup page."
  )

  local a = menu:go()

  if a == 1 then
    local items = scanChest()           -- scan the chest
    local the_deets = getDetails(items) -- get user input
    for i, item in ipairs(the_deets) do -- add each item to cache
      cache.addToCache(item.displayName, item.name, item.damage, item.value)
    end
    -- scan the chest
  elseif a == 2 then
    -- Return
    return
  end
end

return addItem
