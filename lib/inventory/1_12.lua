--- Inventory shim for 1.12 (pre-flattening)

return function(inventory)
  ---@class inv_1_12 : inventory
  local inv_1_12 = inventory

  --- Move items from any inventory to specific inventory.
  ---@param to string|peripheral The peripheral (or peripheral name) to send items to.
  ---@param item string The item ID of the item to be sent.
  ---@param amount integer The amount of items to send.
  ---@return integer amount The amount of items actually sent.
  function inv_1_12.moveItems(to, item, amount)

    return 0
  end

  --- Searches all connected inventories for items in the cache and counts them, appending the count to the data stored in the cache.
  function inv_1_12.countItems()

  end

  --- Searches for inventories and returns them.
  ---@return peripheral[] inventories The inventories.
  function inv_1_12.getInventories()
    error("getInventories not implemented for this version.", 2)
    return {}
  end

  return inv_1_12
end
