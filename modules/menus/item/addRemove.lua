local smenus = require("modules.menus.layouts.simple")

local addItem = require("modules.menus.item.add.addItem")

----------------------------------------------------------
-- func:    addRemove
-- inputs:  none
-- returns: nil
-- info:    Runs the "Add or Remove Items" prompt
----------------------------------------------------------
local function addRemove(editItem, removeItem, cache, cacheEdit, actuallyRemove, getDetails)

  ----------------------------------------------------------
  -- func:    scanChest
  -- inputs:  none
  -- returns: items|table
  -- info:    scans a chest or shulker box in front of the
  --          turtle, then returns them.
  ----------------------------------------------------------
  local function scanChest()
    term.clear()
    term.setCursorPos(1, 1)

    local front = peripheral.getType("front")

    ----------------------------------------------------------
    -- func:    scan
    -- inputs:  none
    -- returns: items|table
    -- info:    actually scan the chest
    ----------------------------------------------------------
    local function scan()
      local chest = peripheral.wrap("front")
      local size = chest.size()
      local ls = chest.list()
      local items = {}
      local cacheItems = cache.getCache()

      for i = 1, size do
        -- for each slot in the chest
        if ls[i] then
          -- if there is an item
          local flag = true
          for j = 1, #items do
            -- for each item already scanned
            if items[j].name == ls[i].name
               and items[j].damage == ls[i].damage then
               -- check if we already scanned it, set flag to false if we have.
              flag = false
              break
            end
          end

          if flag then
            -- if we haven't already scanned the item then
            for k, v in pairs(cacheItems) do
              -- for each minecraft:ItemID in the cache do...
              for k2, v2 in pairs(v) do
                -- for each damage value in minecraft:ItemID in the cache do...
                if k == ls[i].name and k2 == ls[i].damage then
                  -- if the item scanned is already in the cache, set flag to
                  -- false
                  flag = false
                end
              end
            end
          end

          -- if we haven't already scanned the item then
          if flag then
            -- add the item to the table
            items[#items + 1] = {
              name = ls[i].name,
              damage = ls[i].damage,
              displayName = chest.getItemMeta(i).displayName
            }
          end
        end
      end
      return items
    end

    -- if there is a chest or shulker box...
    if front and (front:find("chest") or front:find("shulker")) then
      print("Chest or shulker box in front, scanning it.")
      return scan()
    end

    -- if we could not see a chest or shulker box...
    print("No chest or shulker box in front. Waiting for you to place one.")
    while true do
      local ev, side = os.pullEvent("peripheral")
      -- wait for a peripheral event (ie: chest attached, etc)
      if side == "front" then
        front = peripheral.getType("front")
        if front and (front:find("chest") or front:find("shulker")) then
          -- chest/shulker attached
          print("Shulker or chest attached, scanning in 5 seconds.")
          os.sleep(5)
          return scan()
        else
          -- not a valid chest/shulker
          print("That is not a valid chest or shulker box.")
        end
      end
    end
  end

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
      addItem(scanChest, getDetails, cache) --TODO: move scanChest, getDetails into here
    elseif ans == 2 then
      editItem(cache, cacheEdit) --TODO: move cacheEdit into here.
    elseif ans == 3 then
      removeItem(cache, actuallyRemove) --TODO: move actuallyRemove into here
    elseif ans == menu:count() then
      -- return to main
      return
    end
  end
end

return addRemove
