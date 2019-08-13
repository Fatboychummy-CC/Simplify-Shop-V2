local smenus = require("modules.menus.layouts.simple")

----------------------------------------------------------
-- func:    mainMenu
-- inputs:  none
-- returns: nil
-- info:    runs the 'title screen' menu
----------------------------------------------------------
local function mainMenu(build, update)
  local menu = smenus.newMenu()
  menu.title = "Simplify Shop V2B" .. tostring(build)
  menu:addMenuItem(
    "Run",
    "Run the shop.",
    "Run the shop."
  )
  --
  menu:addMenuItem(
    "Update",
    update,
    "Updates the shop and reboots."
  )
  --
  menu:addMenuItem(
    "Add/Remove",
    "Add/Remove shop item(s).",
    "Use a helpful UI to add or remove items in your shop."
  )
  --
  menu:addMenuItem(
    "Options",
    "Edit shop config.",
    "Open a menu which allows you to change core settings for the shop."
  )
  --
  menu:addMenuItem(
    "Error",
    "Debug Error",
    "Force an error to do some random debugging."
  )

  return menu:go(settings.get("shop.autorun")
                 and settings.get("shop.autorunTime"))
end

return mainMenu
