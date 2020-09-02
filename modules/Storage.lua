local Storage = {}

function Storage.GetPeripherals()
  local tPeripherals = peripheral.getNames()
  local tReturn = {n = 0}
  for i = 1, #tPeripherals do
    local tCurrent = peripheral.getMethods(tPeripherals[i])
    for j = 1, #tCurrent do
      local sMethod = tCurrent[j]
      if sMethod == "pushItems" then
        tReturn.n = tReturn.n + 1
        tReturn[tReturn.n] = tPeripherals[i]
        break
      end
    end
  end
  return tReturn
end

-- Extremely efficient grab algorithm utilizing coroutines for speed:tm:
function Storage.GrabItems(sItemID, iDamage, nbtHash, nAmount)

end

function Storage.CountItems(tItems)
  local tPeripherals = Storage.GetPeripherals()
  local tCounts = {}

  for i = 1, #tItems do
    tCounts[i] = 0
  end

  for i = 1, tPeripherals.n do
    local sPeripheral = tPeripherals[i]
    local tList = peripheral.call(sPeripheral, "list")
    local iSize = peripheral.call(sPeripheral, "size")
    for j = 1, iSize do
      if tList[j] then
        for k = 1, #tItems do
          local tItem = tItems[k]
          if tList[j].name == tItem.name and tList[j].damage == tItem.damage then
            if tItem.nbtHash and tItem.sortByNbt then
              if nbtHash == tList[j].nbtHash then
                tCounts[k] = tCounts[k] + tList[j].count
              end
            else
              tCounts[k] = tCounts[k] + tList[j].count
            end
          end
        end
      end
    end
  end
  for i = 1, #tCounts do
    tItems[i].count = tCounts[i]
  end
end

function Storage.GetStackSizes(tItems)
  local tPeripherals = Storage.GetPeripherals()
  for i = 1, tItems.n do
    local tItem = tItems[i]
    for j = 1, tPeripherals.n do
      local sPeripheral = tPeripherals[j]
      local tList = peripheral.call(sPeripheral, "list")
      local iSize = peripheral.call(sPeripheral, "size")
      for k = 1, iSize do
        if tList[k] then
          if tList[k].name == tItem.name and tList[k].damage == tItem.damage then
            if tItem.nbtHash then
              if tItem.nbtHash == tList[k].nbtHash then
                tItem.stackSize = peripheral.call(sPeripheral, "getItem", k).getMetadata().maxCount
                break
              end
            else
              tItem.stackSize = peripheral.call(sPeripheral, "getItem", k).getMetadata().maxCount
              break
            end
          end
        end
      end
      if tItem.stackSize then
        break
      end
    end
  end
end

return Storage
