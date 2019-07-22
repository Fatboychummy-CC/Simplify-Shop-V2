local funcs = {}
local meta = {}
local met = {}
meta.__index = met
met.__type = "cache"

local cache = {}
local saveLocation = "/cache.ic"

----------------------------------------------------------
-- func:    save
-- inputs:  none
-- returns: nil
-- info:    saves the cache to the save location.
----------------------------------------------------------
local function save()
  local h = io.open(saveLocation, 'w')
  if h then
    h:write(textutils.serialize(cache)):close()
  else
    error("Failed to open cache save file for writing.")
  end
end

----------------------------------------------------------
-- func:    load
-- inputs:  none
-- returns: loaded|boolean
-- info:    attempts to load the cache.
----------------------------------------------------------
function funcs.load()
  --[[
    TODO: Looks like this doesn't make use of the settings API.
    TODO: Make use of the settings API, so we can change cache location in data
  ]]
  local h = io.open(saveLocation, 'r')
  if h then
    local dat = h:read("*a")
    h:close()
    cache = textutils.unserialize(dat)
    return true
  else
    return false
  end
end

----------------------------------------------------------
-- func:    addToCache
-- inputs:  itemName|string, itemID|string, itemDamage|number
--          worth|number, [enabled|boolean]
-- returns: nil
-- info:    adds to (or updates) the cache registration
----------------------------------------------------------
function funcs.addToCache(itemName, itemID, itemDamage, worth, enabled)
  if not cache[itemID] then cache[itemID] = {} end

  local en = true
  if type(enabled) == "boolean" then
    en = enabled
  end

  cache[itemID][itemDamage] = {
    name = itemName,
    value = worth,
    enabled = en
  }
  save()
end

----------------------------------------------------------
-- func:    removeFromCache
-- inputs:  itemID|string, itemDamage|number
-- returns: nil
-- info:    removes an item from the cache
----------------------------------------------------------
function funcs.removeFromCache(itemID, itemDamage)
  if cache[itemID] then
    cache[itemID][itemDamage] = nil
  end
  save()
end

----------------------------------------------------------
-- func:    getRegistration
-- inputs:  itemID|string, itemDamage|number
-- returns: (itemName|string, itemValue|number) OR false
-- info:    gets the item's registration (name and krist value)
----------------------------------------------------------
function funcs.getRegistration(itemID, itemDamage)
  if cache[itemID] then
    return cache[itemID][itemDamage].name, cache[itemID][itemDamage].value
  end
  return false
end

----------------------------------------------------------
-- func:    getCache
-- inputs:  nil
-- returns: cache|table
-- info:    gets the cache table
----------------------------------------------------------
function funcs.getCache()
  return cache
end

----------------------------------------------------------
-- func:    setSaveLocation
-- inputs:  location|string
-- returns: nil
-- info:    changes the cache's save location.
----------------------------------------------------------
function funcs.setSaveLocation(location)
  saveLocation = location
  funcs.save()
end

return funcs
