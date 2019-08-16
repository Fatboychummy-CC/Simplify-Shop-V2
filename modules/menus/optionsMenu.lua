local smenus = require("modules.menus.layouts.simple")

local sub = require("modules.menus.options.subPage")

--TODO: SPLIT THIS INTO MULTIPLE MENUS

----------------------------------------------------------
-- func:    optionsMenu
-- inputs:  none
-- returns: nil
-- info:    runs the menu where you can change settings.
----------------------------------------------------------
local function optionsMenu(sets, settingsLocation, notify)
  local menu = smenus.newMenu()
  menu.title = "Options"
  menu.info = "Select a sub-page."

  local subPages = {
    {
      name = "Shop Info",
      info = "Change shop info.",
      bigInfo = "Change information like the name of your shop and etc.",
      settings = {
        {
          "shop.shopName",
          "Shop name",
          "string",
          "The name to be displayed for the shop."
        },
        {
          "shop.shopOwner",
          "Shop owner",
          "string",
          "Who owns this shop?"
        },
        {
          "shop.refreshRate",
          "Refresh rate",
          "number",
          "Rate at which the shop will refresh it's screen (in seconds)."
        },
        {
          "shop.autorun",
          "Autorun",
          "boolean",
          "Should the shop autorun on boot?"
        },
        {
          "shop.autorunTime",
          "Autorun time",
          "number",
          "How long should the shop wait until being run if autorun is enabled?"
        },
        {
          "shop.rebootTime",
          "Error timer",
          "number",
          "When an error occurs, the shop will wait this time (in seconds) to "
          .. "reboot."
        }
      }
    },
    {
      name = "Data",
      info = "Change data settings.",
      bigInfo = "Change the locations of save files.",
      settings = {
        {
          "shop.dataLocation",
          "Data folder",
          "string",
          "File system location at which the data folder will be stored."
        },
        {
          "shop.cacheSaveName",
          "Cache File",
          "string",
          "File system location at which the cache will be saved."
        },
        {
          "shop.logLocation",
          "Log folder",
          "string",
          "File system location at which the logs folder will be saved."
        }
      }
    },
    {
      name = "Monitor",
      info = "Change monitor settings.",
      bigInfo = "Change things such as text-display size, and which monitor "
                .. "to display on.",
      settings = {
        {
          "shop.monitor.monitor",
          "Monitor",
          "string",
          "The name of the monitor on the wired network."
        },
        {
          "shop.monitor.textScale",
          "Text Scale",
          "number",
          "The scale of the text for the monitor. Min 0.5, max 4."
        }
      }
    },
    {
      name = "Krist",
      info = "Change Krist settings.",
      bigInfo = "Change things such as your krist-password, and etc.",
      settings = {
        {
          "shop.krist.password",
          "Password",
          "password",
          "Your kristwallet password.  Without this you may not send refunds."
        },
        {
          "shop.krist.address",
          "Address",
          "string",
          "Your kristwallet address. ie: kxo123ds."
        }
      }
    }
  }

  for i, subPage in ipairs(subPages) do
    menu:addMenuItem(
      subPage.name,
      subPage.info,
      subPage.bigInfo
    )
  end
  menu:addMenuItem(
    "Return",
    "Go back.",
    "Return to the startup page."
  )

  while true do
    local ans = menu:go()

    if ans >= 1 and ans < menu:count() then
      sub(subPages[ans], settingsLocation, notify)
    else
      return
    end
  end

  --updater()
end

return optionsMenu
