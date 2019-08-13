local smenus = require("modules.menus.layouts.simple")

----------------------------------------------------------
-- func:    errorMenu
-- inputs:  err: error|string
-- returns: selected|number
-- info:    displays the error menu, after an error occurs.
----------------------------------------------------------
local function errorMenu(err)
  local menu = smenus.newMenu()
  menu.title = "Error"
  menu.info = err

  menu:addMenuItem(
    "Reboot",
    "Reboot the shop.",
    "Reboot the shop."
  )
  menu:addMenuItem(
    "Return",
    "",
    "Return to the shell."
  )

  return menu:go(settings.get("shop.rebootTime") or 30)
end

return errorMenu
