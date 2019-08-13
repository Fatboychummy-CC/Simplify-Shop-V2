local smenus = require("modules.menus.layouts.simple")

----------------------------------------------------------
-- func:    editItem
-- inputs:  none
-- returns: nil
-- info:    Loads each item in the cache, and lists them
--          for the player to be edited.
----------------------------------------------------------
local function editItem(cache, cacheEdit)
  while true do
    local c = cache.getCache()

    local menu = smenus.newMenu()
    menu.title = "Edit Item Data"
    menu.info = "Change values of items in your shop."

    local registry = {}

    for key, reg in pairs(c) do
      for damage, registration in pairs(reg) do
        -- for each item in the cache
        -- get each item.
        local sName = registration.name
        -- if the name is too long, shorten it.
        if #sName > 12 then
          sName = sName:sub(1, 9) .. "..."
        end
        menu:addMenuItem(
          sName,
          "Edit this item.",
          "Edit the item " .. key .. "[" .. tostring(damage) .. "]"
        )
        -- add to registry (temp, not cache registry)
        registry[#registry + 1] = {key = key, damage = damage}
      end
    end

    menu:addMenuItem(
      "Return",
      "Go back.",
      "Return to the previous page."
    )

    local ans = menu:go()
    if ans == #registry + 1 then
      return
    else
      -- confirm edit.
      cacheEdit(c, registry[ans], cache)
    end
  end
end

return editItem
