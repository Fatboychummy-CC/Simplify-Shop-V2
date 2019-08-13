local imenus = require("modules.menus.layouts.insert")

--TODO: SPLIT THIS INTO MULTIPLE MENUS

----------------------------------------------------------
-- func:    optionsMenu
-- inputs:  none
-- returns: nil
-- info:    runs the menu where you can change settings.
----------------------------------------------------------
local function optionsMenu(sets, settingsLocation, notify)
  local menu = imenus.newMenu()
  menu.title = "Settings"
  menu.info = "Select an item to edit it's value."

  menu:addMenuItem(
    "Shop name",
    "string",
    settings.get("shop.shopName") or "ERROR 1",
    "The name to be displayed for the shop."
  )
  menu:addMenuItem(
    "Shop owner",
    "string",
    settings.get("shop.shopOwner") or "ERROR 1",
    "Who owns this shop?"
  )
  menu:addMenuItem(
    "Refresh rate",
    "number",
    settings.get("shop.refreshRate") or -1,
    "Speed at which the shop will refresh it's screen (in seconds)."
  )
  menu:addMenuItem(
    "Data folder",
    "string",
    settings.get("shop.dataLocation") or "ERROR 1",
    "File system location at which the data folder will be stored"
  )
  menu:addMenuItem(
    "Cache Name",
    "string",
    settings.get("shop.cacheSaveName") or "ERROR 1",
    "Location at which the cache will be saved."
  )
  menu:addMenuItem(
    "Log folder",
    "string",
    settings.get("shop.logLocation") or "ERROR 1",
    "Location at which the logs folder will be saved."
  )
  menu:addMenuItem(
    "Error Timer",
    "number",
    settings.get("shop.rebootTime") or "ERROR 1",
    "When an error occurs, the shop will wait this time (in seconds) to reboot."
  )
  local autorun = settings.get("shop.autorun")
  if type(autorun) == "boolean" then
    menu:addMenuItem(
      "Autorun",
      "boolean",
      autorun,
      "Should the shop autorun on boot?"
    )
  else
    menu:addMenuItem(
      "Autorun",
      "boolean",
      true,
      "Should the shop autorun on boot?"
    )
  end
  menu:addMenuItem(
    "Autorun Time",
    "number",
    settings.get("shop.autorunTime") or "ERROR 1",
    "How long should the shop wait until being run if autorun enabled?"
  )
  menu:addMenuItem(
    "Monitor",
    "string",
    settings.get("shop.monitor.monitor") or peripheral.findString("monitor")[1]
      or "NO MONITOR",
    "The name of the monitor on the wired network."
  )
  menu:addMenuItem(
    "Text Size",
    "number",
    settings.get("shop.monitor.textScale") or 0.5,
    "The scale of the text for the monitor.  Min 0.5, max 4"
  )

  ----------------------------------------------------------
  -- func:    updater
  -- inputs:  none
  -- returns: nil
  -- info:    to be run by the menu when a menu option is updated.
  --          Notifies other modules of a settings update.
  ----------------------------------------------------------
  local function updater()
    -- for each setting, set them to the new menu option
    for i = 1, #sets do
      settings.set(sets[i], menu.menuItems.appends[i])
    end
    settings.save(settingsLocation)
    notify("settings_update") -- notify all modules

    -- sets the menu options back to the settings.
    -- since the settings may be changed after notifying.
    for i = 1, #sets do
      local append = menu.menuItems.appends[i]
      if settings.get(sets[i]) ~= append then
        menu.menuItems.appends[i] = settings.get(sets[i])
      end
    end
  end

  menu:go(updater)

  updater()
end

return optionsMenu
