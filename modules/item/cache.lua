local funcs = {}
local meta = {}
local met = {}
meta.__index = met
met.__type = "cache"

local cache = {}
local saveLocation = "/cache.ic"

local function save()
  local h = io.open(saveLocation, 'w')
  if h then
    h:write(textutils.serialize(cache)):close()
  else
    error("Failed to open cache save file for writing.")
  end
end

function funcs.load()
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

function funcs.addToCache(itemName, itemID, itemDamage, worth)
  if not cache[itemID] then cache[itemID] = {} end
  cache[itemID][itemDamage] = {name = itemName, value = worth, enabled = true}
  save()
end

function funcs.removeFromCache(itemID, itemDamage)
  if cache[itemID] then
    cache[itemID][itemDamage] = nil
  end
  save()
end

function funcs.getRegistration(itemID, itemDamage)
  if cache[itemID] then
    return cache[itemID][itemDamage].name, cache[itemID][itemDamage].value
  end
  return false
end

function funcs.getCache()
  return cache
end

function funcs.setSaveLocation(location)
  saveLocation = location
end

return funcs
