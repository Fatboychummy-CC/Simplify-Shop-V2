local deep_copy = require "deep_copy"
local file_helper = require "file_helper"

---@class inventory
---@field protected _cache cache yeah
local inventory = { _cache = {} }

--- Get a copy of the cache.
---@return cache
function inventory.cache()
  return deep_copy(inventory._cache)
end

--- Load the cache from a file.
---@param filename string The file to load the cache from.
function inventory.loadCache(filename)
  inventory._cache = file_helper.unserialize(filename, {})
end

--- Save the cache to a file.
---@param filename string The file to save the cache to.
function inventory.saveCache(filename)
  return file_helper.serialize(filename, inventory._cache)
end

--- Get the display name of a block's ID.
---@virtual
---@param item_info item The block information as returned from a `.list()` call.
---@return string? display_name The display name of the given item, or nil if it is not cached.
function inventory.display(item_info)
  error("display not implemented for this version.", 2)
end

--- Cache an item.
---@virtual
---@param item_info item The block information as returned from a `.list()` call.
---@param display_name string The name of the block as displayed by Minecraft.
function inventory.cacheItem(item_info, display_name)
  error("cacheItem not implemented for this version.", 2)
end

--- Remove an item from the cache.
---@virtual
---@param item_info item The block information as returned from a `.list()` call.
function inventory.uncacheItem(item_info)
  error("uncacheItem not implemented for this version.", 2)
end

--- Move items from any inventory to specific inventory.
---@virtual to be implemented by child shims.
---@param to string|peripheral The peripheral (or peripheral name) to send items to.
---@param item string The item ID of the item to be sent.
---@param amount integer The amount of items to send.
---@return integer amount The amount of items actually sent.
function inventory.moveItems(to, item, amount)
  error("moveItems not implemented for this version.", 2)
  return 0
end

--- Searches all connected inventories for items in the cache and counts them, appending the count to the data stored in the cache.
---@virtual to be implemented by child shims.
function inventory.countItems()
  error("countItems not implemented for this version.", 2)
end

--- Searches for inventories and returns them.
---@return peripheral[] inventories The inventories.
function inventory.getInventories()
  error("getInventories not implemented for this version.", 2)
  return {}
end

function inventory.cacheItems()

end

return inventory
