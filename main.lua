--[[
0

]]

-- requires

local smenus = require("modules.text.menus.simple")
local imenus = require("modules.text.menus.insert")
local qmenus = require("modules.text.menus.questions")
local cache = require("modules.item.cache")
local build = 0


-- shop settings.
local sets = {
  "shop.shopName",
  "shop.shopOwner",
  "shop.refreshRate",
  "shop.dataLocation",
  "shop.cacheSaveName",
  "shop.logLocation",
  defaults = {
    "Unnamed Shop",
    "Unknown",
    10,
    "/data",
    "/data/cache.ic",
    "/data/logs"
  }
}

local function checkSettings()
  for i = 1, #sets do
    if not settings.get(sets[i]) then
      settings.set(sets[i], sets.defaults[i])
      settings.save("/.shopsettings")
    end
  end
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

  menu:go()

  for i = 1, #sets do
    settings.set(sets[i], menu.menuItems.appends[i])
  end
  settings.save("/.shopsettings")
end

local function scanChest()
  term.clear()
  term.setCursorPos(1, 1)

  local front = peripheral.getType("front")

  local function scan()
    local chest = peripheral.wrap("front")
    local size = chest.size()
    local ls = chest.list()
    local items = {}
    --TODO: fix duplicates.

    for i = 1, size do
      if ls[i] then
        items[#items + 1] = {
          name = ls[i].name,
          damage = ls[i].damage,
          displayName = chest.getItemMeta(i).displayName
        }
      end
    end
    return items
  end

  if front and (front:find("chest") or front:find("shulker")) then
    print("Chest or shulker box in front, scanning it.")
    return scan()
  end

  print("No chest or shulker box in front. Waiting for you to place one.")
  while true do
    local ev, side = os.pullEvent("peripheral")
    if side == "front" then
      front = peripheral.getType("front")
      if front and (front:find("chest") or front:find("shulker")) then
        print("Shulker or chest attached, scanning in 5 seconds.")
        os.sleep(5)
        return scan()
      else
        print("That is not a valid chest or shulker box.")
      end
    end
  end
end

local function getDetails(items)
  local tmp = {}
  for i, item in ipairs(items) do
    local menu = qmenus.new()
    menu:addQuestion(
      "Scanned '" .. item.name .. "' with damage "
      .. tostring(item.damage) .. ".",
      "string",
      "Enter the name you wish to use for this item.\n"
      .. "Leave blank to enter '" .. item.displayName .. "'."
    )
    menu:addQuestion(
      "For the previous item, what shall the cost in krist per item be?",
      "number",
      "Enter the cost per item you wish to charge for the previous item."
    )
    menu:go()

    if menu.questions.a[1] == "" then
      menu.questions.a[1] = item.displayName
    end

    tmp[#tmp + 1] = {
      name = item.name,
      damage = item.damage,
      displayName = menu.questions.a[1],
      value = menu.questions.a[2]
    }
  end

  return tmp
end

local function addItem()
  local menu = smenus.newMenu()
  menu.title = "Add Items."
  menu.info = "Add items via a chest in front of the turtle."

  menu:addMenuItem(
    "Scan",
    "Scan the chest.",
    "Scan the chest. You will be prompted for each item for it's price and etc."
  )
  menu:addMenuItem(
    "Return",
    "Go back.",
    "Return to the startup page."
  )

  local a = menu:go()

  if a == 1 then
    local items = scanChest()
    local the_deets = getDetails(items)
    for i, item in ipairs(the_deets) do
      cache.addToCache(item.displayName, item.name, item.damage, item.value)
    end
    -- scan the chest
  elseif a == 2 then
    -- Return
    return
  end
end

local function removeItem()

end

local function editItem()

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
    "Edit Items",
    "Edit prices for items.",
    "Edit the prices for items sold at your shop."
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

  while true do
    local ans = menu:go()
    if ans == 1 then
      addItem()
    elseif ans == 2 then
      editItem()
      --TODO: edit items
    elseif ans == 3 then
      removeItem()
      --TODO: remove items
    elseif ans == 4 then
      -- return to main
      return
    end
  end
end

local function main()
  -- init
  print("Initializing.")
  os.sleep(0.1)
  print("Checking settings.")
  if not settings.load("/.shopsettings") then
    print("No settings are saved, creating them.")
    os.sleep(0.5)
    for i = 1, #sets do
      settings.set(sets[i], sets.defaults[i])
      print(sets[i], " - ", sets.defaults[i])
    end
    settings.save("/.shopsettings")
    print("Saved settings.")
    os.sleep(0.5)
  end
  checkSettings()

  print("Checking Cache")
  os.sleep(0.1)
  cache.setSaveLocation(settings.get("shop.cacheSaveName"))
  if not cache.load() then
    print("No cache file found.")
    os.sleep(0.5)
  end

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
