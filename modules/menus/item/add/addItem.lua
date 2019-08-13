local smenus = require("modules.menus.layouts.simple")

local getDetails = require("modules.menus.item.add.getDetails")

----------------------------------------------------------
-- func:    addItem
-- inputs:  none
-- returns: nil
-- info:    Runs the add item menu.
----------------------------------------------------------
local function addItem(cache)

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
  os.sleep(0.1)
  local a = menu:go()

  if a == 1 then
    local items = scanChest()           -- scan the chest
    local the_deets = getDetails(items) -- get user input
    local flg = true
    for i, item in ipairs(the_deets) do -- add each item to cache
      flg = false
      cache.addToCache(item.displayName, item.name, item.damage, item.value)
    end
    if flg then
      print("No items, or all items have been previously scanned.")
      os.sleep(4)
    end
    -- scan the chest
  elseif a == 2 then
    -- Return
    return
  end
end

return addItem
