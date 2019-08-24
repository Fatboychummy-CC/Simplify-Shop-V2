local imenus = require("modules.menus.layouts.insert")
local smenus = require("modules.menus.layouts.simple")

local function subPage(page, settingsLocation, notify)
  if not page then error("no page", 3) end
  if not settingsLocation then error("no set", 2) end
  if not notify then error("no notif", 2) end
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
  local function updater(index)
    -- for each setting, set them to the new menu option
    settings.set(sets[index], menu.menuItems.appends[index])
    settings.save(settingsLocation)

    notify("settings_update", sets[index]) -- notify all modules

    -- sets the menu options back to the settings.
    -- since the settings may be changed after notifying.
    menu.menuItems.appends[index] = settings.get(sets[index])
  end

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
  if page.settings then
    for i, setting in ipairs(page.settings) do
      sets[#sets + 1] = setting[1]
      menu:addMenuItem(
        setting[2],
        setting[3],
        getSetting(setting[3], setting[1]),
        setting[4]
      )
    end
  end

  if page.subPages then
    local ohnorecursion = require("modules.menus.options.subPage")

    for i, pagen in ipairs(page.subPages) do
      menu:addMenuItem(
        pagen.name,
        "subpage",
        pagen.info,
        pagen.bigInfo
      )
    end

    local sel
    repeat
      sel = menu:go(updater)
      if sel ~= menu:count() and menu:getType(sel) == "subpage" then
        sel = sel - (page.settings and #page.settings or 0)
        ohnorecursion(page.subPages[sel], settingsLocation, notify)
      end
    until sel == menu:count()
    return sel
  end

  return menu:go(updater)
end

return subPage
