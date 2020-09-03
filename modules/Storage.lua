local expect = require("cc.expect").expect

local Storage = {}

function math.clamp(nMin, nMax, nVal)
  expect(1, nMin, "number")
  expect(2, nMax, "number")
  expect(3, nVal, "number")
  
  return math.max(nMin, math.min(nMax, nVal))
end

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
function Storage.GrabItems(sTo, sItemID, iDamage, nbtHash, nAmount, bSortNbt)
  expect(1, sTo, "string")
  expect(2, sItemID, "string")
  expect(3, iDamage, "number")
  expect(4, nbtHash, "string", "nil")
  expect(5, nAmount, "number")
  expect(6, bSortNbt, "boolean", "nil")

  local tPeripherals = Storage.GetPeripherals()
  local tCoroutines = {n = tPeripherals.n}
  local nSent = 0

  local function Request(n)
    local toMove = math.clamp(0, nAmount - nSent, n)
    nSent = nSent + toMove
    return toMove
  end

  -- generate coroutines
  for i = 1, tPeripherals.n do
    -- create a coroutine that lists each storage peripheral
    tCoroutines[i] = function()
      if nSent >= nAmount then
        -- If we sent more than or equal to what we want to send, stop.
        return
      end
      local tStorage = tPeripherals[i]
      local tList = peripheral.call(tStorage, "list")

      -- for each slot in the peripheral
      for iSlot = 1, peripheral.call(tStorage, "size") do
        local tItem = tList[iSlot]

        -- if there is an item in the slot
        if tItem then
          -- if the item matches our search parameter
          if tItem.name == sItemID and tItem.damage == iDamage then
            -- AND we want to sort by NBT AND the nbtHash is similar (or we don't want to sort by nbt)
            if (bSortNbt and tItem.nbtHash == nbtHash) or not bSortNbt then
              -- then send the items to us

              if nSent >= nAmount then
                -- If we sent more than or equal to what we want to send, stop.
                return
              end
              local nRequestAmount = Request(tItem.count)
              if nRequestAmount > 0 then
                peripheral.call(tStorage, "pushItems", sTo, iSlot, nRequestAmount)
              end
              if nSent >= nAmount then
                -- If we sent more than or equal to what we want to send, stop.
                return
              end
            end
          end
        end
      end
    end
  end

  -- run 8 coroutines at a time
  for i = 1, tCoroutines.n, 8 do
    parallel.waitForAll(table.unpack(tCoroutines, i, math.min(i + 7, tCoroutines.n)))
  end

  return nSent
end

function Storage.CountItems(tItems)
  expect(1, tItems, "table")

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
  expect(1, tItems, "table")

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
