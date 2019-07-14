--[[
0

]]

-- requires

local menus = require("modules.text.menus")
local build = 0



local function main()
  local mainMenu = menus.newMenu()
  mainMenu.title = "Simplify Shop V2B" .. tostring(build)
  mainMenu:addMenuItem("Run", "Run the shop.",
                        "Run the shop.")
  --
  mainMenu:addMenuItem("Update", "No update available.", "Updates the shop and "
                                                         .. "reboots.")
  --
  mainMenu:addMenuItem("Add", "Add shop item(s).",
                       "Use a helpful UI to add items to your shop.")
  --
  mainMenu:addMenuItem("Remove", "Remove shop item(s).",
                       "Use a helpful UI to remove items from your shop.")
  mainMenu:go(5)
end

local ok, err = pcall(main)

if not ok then
  error(err, 0)
end
