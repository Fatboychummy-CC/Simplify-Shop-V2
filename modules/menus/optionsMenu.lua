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
    },
    ----------------
    {
      name = "Aesthetics",
      info = "Change shop aesthetics.",
      bigInfo = "Change locations, colors, and more of each part of the shop.",
      ["type"] = 1,

      subPages = {
        {
          name = "Listings",
          info = "Change item listings.",
          bigInfo = "Change the way the item list is displayed by the shop.",
          settings = {
            {
              "shop.listing.enabled",
              "Enabled",
              "boolean",
              "Should this item be displayed on the monitor?"
            },
            {
              "shop.listing.decimalPlaces",
              "Decimal Pl.",
              "number",
              "How many decimal places should the shop show (1.000 is 3, 1.00 is 2)?"
            },
            {
              "shop.listing.leftStop",
              "Left Stop",
              "number",
              "How far from the left of the screen should the shop start the item "
              .. "list?"
            },
            {
              "shop.listing.rightStop",
              "Right Stop",
              "number",
              "How far from the left of the screen should the shop stop the item "
              .. "list?"
            },
            {
              "shop.listing.topStop",
              "Top Stop",
              "number",
              "How far from the top of the screen should the shop start the item "
              .. "list?"
            },
            {
              "shop.listing.maxItemsPerPage",
              "Max Items",
              "number",
              "How many items should be displayed per page?"
            }
          },
          subPages = {
            {
              name = "Colors",
              info = "Change list colors.",
              bigInfo = "Change colors of each line in the item list.",
              settings = {
                {
                  "shop.listing.fgheader",
                  "Header Text",
                  "color",
                  "Change the text color of the header."
                },
                {
                  "shop.listing.bgheader",
                  "Header BG",
                  "color",
                  "Change the background color of the header."
                },
                {
                  "shop.listing.fgcolor1",
                  "Text Even",
                  "color",
                  "Change the text color of even-numbered items."
                },
                {
                  "shop.listing.bgcolor1",
                  "BG Even",
                  "color",
                  "Change the background color of even-numbered items."
                },
                {
                  "shop.listing.fgcolor2",
                  "Text Odd",
                  "color",
                  "Change the text color of odd-numbered items."
                },
                {
                  "shop.listing.bgcolor2",
                  "BG Odd",
                  "color",
                  "Change the background color of odd-numbered items."
                },
                {
                  "shop.listing.selectionfgcolor",
                  "Selected Txt",
                  "color",
                  "Change the text color of the selected item."
                },
                {
                  "shop.listing.selectionbgcolor",
                  "Selected BG",
                  "color",
                  "Change the text color of the selected item."
                }
              }
            }
          }
        },
        ------------
        {
          name = "Info Box",
          info = "Change info box info.",
          bigInfo = "Change the information displayed in the large "
                    .. "information box.",
          settings = {
            {
              "shop.info.enabled",
              "Enabled",
              "boolean",
              "Should this item be displayed on the monitor?"
            },
            {
              "shop.info.centered",
              "Centered",
              "boolean",
              "Should the info box's text be centered?"
            },
            {
              "shop.info.leftStop",
              "Left Stop",
              "number",
              "How far from the left of the screen should the shop start the "
              .. "info box?"
            },
            {
              "shop.info.rightStop",
              "Right Stop",
              "number",
              "How far from the left of the screen should the shop stop the "
              .. "info box?"
            },
            {
              "shop.info.topStop",
              "Top Stop",
              "number",
              "How far from the top of the screen should the shop start the "
              .. "info box?"
            },
            {
              "shop.info.bottomStop",
              "Bottom Stop",
              "number",
              "How far from the top of the screen should the shop start the "
              .. "info box?"
            },
            {
              "shop.info.bgcolor",
              "BG color",
              "color",
              "What color should the background of the info box be?"
            },
            {
              "shop.info.fgcolor",
              "Text Color",
              "color",
              "What color should the text in the info box be?"
            }
          },
          subPages = {
            {
              name = "Lines",
              info = "Change info lines.",
              bigInfo = "Change the lines the shop info box displays.",
              settings = {
                {
                  "shop.info.line1",
                  "Line 1",
                  "string",
                  "Change the information on this line (Blank = Empty)."
                },
                {
                  "shop.info.line2",
                  "Line 2",
                  "string",
                  "Change the information on this line (Blank = Empty)."
                },
                {
                  "shop.info.line3",
                  "Line 3",
                  "string",
                  "Change the information on this line (Blank = Empty)."
                },
                {
                  "shop.info.line4",
                  "Line 4",
                  "string",
                  "Change the information on this line (Blank = Empty)."
                },
                {
                  "shop.info.line5",
                  "Line 5",
                  "string",
                  "Change the information on this line (Blank = Empty)."
                },
              }
            }
          }
        }
        ------------
      }
    }
    ----------------
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
