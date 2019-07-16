--[[
0

]]

-- requires

local smenus = require("modules.text.menus.simple")
local imenus = require("modules.text.menus.insert")
local qmenus = require("modules.text.menus.questions")
local build = 0

if not settings.load("/.shopsettings") then
  settings.set("shop.shopName", "Unnamed Shop")
  settings.set("shop.shopOwner", "Unknown")
  settings.set("shop.refreshRate", 10)
  settings.save("/.shopsettings")
end

local function updateCheck()
  --TODO: finish this.
end

local function updateCheckString()
  --TODO: call updateCheck and return a string depending on what is returned.
  return "No updates available."
end

local function mainMenu()
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
    updateCheckString(),
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
  return menu:go(5)
end

local function optionsMenu()
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

  menu:go()

  settings.set("shop.shopName", menu.menuItems.appends[1])
  settings.set("shop.shopOwner", menu.menuItems.appends[2])
  settings.set("shop.refreshRate", menu.menuItems.appends[3])
  settings.save("/.shopsettings")
end

local function addRemove()
  local menu = smenus.newMenu()

  menu.title = "Add or Remove Items"

  menu:addMenuItem(
    "Add Items",
    "Add items to the shop.",
    "Use a helpful UI to add items to your shop."
  )
  menu:addMenuItem(
    "Remove Items",
    "Remove items from shop.",
    "Use a helpful UI to remove items from your shop."
  )
  menu:addMenuItem(
    "Return",
    "Go back.",
    "Return to the startup page."
  )

  local ans = menu:go()
  if ans == 1 then
    --TODO: add items
  elseif ans == 2 then
    --TODO: remove items
  elseif ans == 3 then
    -- return to main
    return
  end
end

local function main()
  local selection = 0
  repeat
    selection = mainMenu()
    if selection == 2 then
      --TODO: update
    elseif selection == 3 then
      addRemove()
    elseif selection == 4 then
      optionsMenu()
    end
  until selection == 1
    --TODO: shop
end

local ok, err = pcall(main)

if not ok then
  error(err, 0)
end
