local imenus = require("modules.menus.layouts.insert")

local function subPage(page, settingsLocation, notify)
  local menu = imenus.newMenu()
  local sets = {}
  menu.title = page.name
  menu.info = page.info

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

  --[[
  {
    name = "Monitor",
    info = "Change monitor settings.",
    bigInfo = "Change things such as text-display size, and which monitor "
              .. "to display on.",
    settings = {
      [ "shop.monitor.monitor" ] = {
        "Monitor",
        "type"
        "The name of the monitor on the wired network."
      },
      [ "shop.monitor.textScale" ] = {
        "Text Scale",
        "type"
        "The scale of the text for the monitor. Min 0.5, max 4."
      }
    }
  }
  ]]

  local function getSetting(tp, name)
    local set = settings.get(name)

    if tp == "string" then
      if type(set) == "string" then
        return set
      else
        return "ERROR_5"
      end
    elseif tp == "number" then
      if type(set) == "number" then
        return set
      else
        return 0
      end
    elseif tp == "boolean" then
      if type(set) == "boolean" then
        return set
      else
        return 'a'
      end
    end
  end

  for i, setting in pairs(page.settings) do
    sets[#sets + 1] = setting[1]
    menu:addMenuItem(
      setting[2],
      setting[3],
      getSetting(setting[3], setting[1]),
      setting[4]
    )
  end

  menu:go(updater)

  updater()


end

return subPage
