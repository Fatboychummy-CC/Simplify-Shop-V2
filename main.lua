--[[
0

]]

-- requires

local menus = require("modules.text.menus")
local build = 0

local function mainMenu()
  local menu = menus.newMenu()
  menu.title = "Simplify Shop V2B" .. tostring(build)
  menu:addMenuItem(
    "Run",
    "Run the shop.",
    "Run the shop."
  )
  --
  menu:addMenuItem(
    "Update",
    "No update available.",
    "Updates the shop and reboots."
  )
  --
  menu:addMenuItem(
    "Add/Remove",
    "Add/Remove shop item(s).",
    "Use a helpful UI to add items to your shop."
  )
  --
  --
  menu:addMenuItem(
    "Options",
    "Edit shop config.",
    "Open a menu which allows you to change core settings for the shop."
  )
  --
  --
  --
  --
  return menu:go(5)
end



local function main()
  local selection = 0
  repeat
    selection = mainMenu()
  until selection == 1
end

local ok, err = pcall(main)

if not ok then
  error(err, 0)
end
