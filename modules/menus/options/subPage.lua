local imenus = require("modules.menus.layouts.insert")
local smenus = require("modules.menus.layouts.simple")

local function subPage(page, settingsLocation, notify)
  local menu
  if not page.type then
    menu = imenus.newMenu()
  elseif page.type == 1 then
    menu = smenus.newMenu()
  end
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
  local function updater(index)
    -- for each setting, set them to the new menu option
    settings.set(sets[index], menu.menuItems.appends[index])
    settings.save(settingsLocation)

    notify("settings_update", sets[index]) -- notify all modules

    -- sets the menu options back to the settings.
    -- since the settings may be changed after notifying.
    menu.menuItems.appends[index] = settings.get(sets[index])
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
  if not page.type then
    local function getSetting(tp, name)
      local set = settings.get(name)

      if tp == "string" then
        if type(set) == "string" then
          return set
        else
          return "ERROR_5"
        end
      elseif tp == "password" then
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

    for i, setting in ipairs(page.settings) do
      sets[#sets + 1] = setting[1]
      menu:addMenuItem(
        setting[2],
        setting[3],
        getSetting(setting[3], setting[1]),
        setting[4]
      )
    end

    menu:go(updater)

  elseif page.type == 1 then
    local ohnorecursion = require("modules.menus.options.subPage")

    for i, pagen in ipairs(page.subPages) do
      menu:addMenuItem(
        pagen.name,
        pagen.info,
        pagen.bigInfo
      )
    end

    menu:addMenuItem(
      "Return",
      "Go back.",
      "Return to the previous page."
    )

    local sel
    repeat
      sel = menu:go()
      if sel ~= menu:count() then
        ohnorecursion(page.subPages[sel], settingsLocation, notify)
      end
    until sel == menu:count()
  end


end

return subPage
