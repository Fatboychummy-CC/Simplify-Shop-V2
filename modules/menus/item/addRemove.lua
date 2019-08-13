local smenus = require("modules.menus.layouts.simple")

local addItem = require("modules.menus.item.add.addItem")
local editItem = require("modules.menus.item.edit.editItem")
local removeItem = require("modules.menus.item.remove.removeItem")

----------------------------------------------------------
-- func:    addRemove
-- inputs:  none
-- returns: nil
-- info:    Runs the "Add or Remove Items" prompt
----------------------------------------------------------
local function addRemove(cache)

  local menu = smenus.newMenu()

  menu.title = "Add or Remove Items"

  menu:addMenuItem( -- 1 = add item
    "Add Items",
    "Add items to the shop.",
    "Use a helpful UI to add items to your shop."
  )
  menu:addMenuItem( -- 2 = edit item
    "Edit Items",
    "Edit prices for items.",
    "Edit the prices for items sold at your shop."
  )
  menu:addMenuItem( -- 3 = remove item
    "Remove Items",
    "Remove items from shop.",
    "Use a helpful UI to remove items from your shop."
  )
  menu:addMenuItem( -- max = return
    "Return",
    "Go back.",
    "Return to the startup page."
  )

  while true do
    local ans = menu:go()
    if ans == 1 then
      addItem(cache) --TODO: move scanChest, getDetails into here
    elseif ans == 2 then
      editItem(cache)
    elseif ans == 3 then
      removeItem(cache) --TODO: move actuallyRemove into here
    elseif ans == menu:count() then
      -- return to main
      return
    end
  end
end

return addRemove
