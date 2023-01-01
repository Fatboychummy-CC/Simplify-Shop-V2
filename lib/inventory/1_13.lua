--- Inventory shim for 1.13+ (post-flattening)

local QIT = require "QIT"

return function(inventory)
  ---@class inv_1_13 : inventory
  local inv_1_13 = inventory

  --- Combine item information into a single unique string that is different per-item.
  --- 1.13+ uses name and nbt to differentiate items. No damage value exists.
  ---@param item_info item The item information to combine.
  local function combine(item_info)
    return item_info.name .. (item_info.nbt or "")
  end

  --- Get the display name of a block's ID.
  ---@param item_info table The block information as returned from a `.list()` call.
  ---@return string? display_name The display name of the given item, or nil if it is not cached.
  function inv_1_13.display(item_info)
    return inv_1_13._cache[combine(item_info)]
        and inv_1_13._cache[combine(item_info)].display_name
  end

  --- Cache an item.
  ---@param item_info table The block information as returned from a `.list()` call.
  ---@param display_name string The name of the block as displayed by Minecraft.
  function inv_1_13.cacheItem(item_info, display_name)
    inv_1_13._cache[combine(item_info)] = { display_name = display_name, count = 0 }
  end

  --- Remove an item from the cache.
  ---@param item_info table The block information as returned from a `.list()` call.
  function inv_1_13.uncacheItem(item_info)
    inv_1_13[combine(item_info)] = nil
  end

  --- Move items from any inventory to specific inventory.
  ---@param to string|peripheral The peripheral (or peripheral name) to send items to.
  ---@param item string The item ID of the item to be sent.
  ---@param amount integer The amount of items to send.
  ---@return integer amount The amount of items actually sent.
  function inv_1_13.moveItems(to, item, amount)
    local invs = inv_1_13.getInventories()

    if type(to) == "table" then
      to = peripheral.getName(to)
    end

    local funcs = QIT()
    local pushed = 0
    for _, inv in ipairs(invs) do
      funcs:Insert(function()
        local list = inv.list()

        for slot, item_info in pairs(list) do
          if amount <= 0 then return end
          if item_info.name == item then
            local _pushed = inv.pushItems(to, slot, amount)
            amount = amount - _pushed
            pushed = pushed + _pushed
          end
        end
      end)
    end

    parallel.waitForAll(table.unpack(funcs))

    return pushed
  end

  --- Searches all connected inventories for items in the cache and counts them, appending the count to the data stored in the cache.
  function inv_1_13.countItems()
    local cache = inv_1_13._cache

    -- zero out all counts
    for _, item_info in pairs(cache) do
      item_info.count = 0
    end

    -- load up table of functions to be ran
    local funcs = QIT()
    for _, inv in ipairs(inv_1_13.getInventories()) do
      funcs:Insert(function()
        local list = inv.list() -- get items in inventory

        -- check each item if it's in the cache
        for _, item_info in pairs(list) do
          local combined = combine(item_info)
          if cache[combined] then
            cache[combined].count = cache[combined].count + item_info.count
          end
        end
      end)
    end

    -- run the loaded functions
    parallel.waitForAll(table.unpack(funcs))
  end

  --- Searches for inventories and returns them.
  ---@return peripheral[] inventories The inventories found.
  function inv_1_13.getInventories()
    local periphs = peripheral.getNames()
    local invs = QIT()

    for _, periph in ipairs(periphs) do
      local types = { peripheral.getType(periph) }
      for _, t in ipairs(types) do
        if t == "inventory" then
          invs:Insert(peripheral.wrap(periph))
        end
      end
    end

    return invs:Clean()
  end

  function inv_1_13.getVersion()
    return "1.13+"
  end

  return inv_1_13
end
