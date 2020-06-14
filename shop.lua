local debug = true
local expect = require("cc.expect").expect


--##############################################################
-- Initial setup stuff, so we can download dependencies we need
--##############################################################
local sAbsoluteDir = "/" .. shell.dir() .. "/"
local tFiles = {
  self = {
    location = "https://raw.githubusercontent.com/Fatboychummy-CC/Simplify-Shop-V2/master/shop.lua",
    name = shell.getRunningProgram()
  },
  md5 = {
    location = "https://raw.githubusercontent.com/kikito/md5.lua/master/md5.lua",
    name = sAbsoluteDir .. "modules/md5.lua"
  },
  Tamperer = {
    location = "https://raw.githubusercontent.com/Fatboychummy-CC/Tamperer/master/minified.lua",
    name = sAbsoluteDir .. "modules/Tamperer.lua"
  },
  Frame = {
    location = "https://raw.githubusercontent.com/Fatboychummy-CC/Frame/master/Frame.lua",
    name = sAbsoluteDir .. "modules/Frame.lua"
  },
  Logger = {
    location = "https://raw.githubusercontent.com/Fatboychummy-CC/Compendium/master/modules/core/logger.lua",
    name = sAbsoluteDir .. "modules/Logger.lua"
  },
  MainMenu = {
    location = "https://raw.githubusercontent.com/Fatboychummy-CC/Simplify-Shop-V2/master/data/main.tamp",
    name = sAbsoluteDir .. "data/main.tamp"
  },
  OptionsMenu = {
    location = "https://raw.githubusercontent.com/Fatboychummy-CC/Simplify-Shop-V2/master/data/options.tamp",
    name = sAbsoluteDir .. "data/options.tamp"
  },
  UpdaterMenu = {
    location = "https://raw.githubusercontent.com/Fatboychummy-CC/Simplify-Shop-V2/master/data/updates.tamp",
    name = sAbsoluteDir .. "data/updates.tamp"
  },
  ItemsMenu = {
    location = "https://raw.githubusercontent.com/Fatboychummy-CC/Simplify-Shop-V2/master/data/items.tamp",
    name = sAbsoluteDir .. "data/items.tamp"
  }
}

-- Reads a local file and returns the data in a string
local function readFile(sFileName)
  expect(1, sFileName, "string")

  local h, err = io.open(sFileName, 'r')
  if h then
    local sData = h:read("*a")
    h:close()
    return sData
  else
    printError(string.format("Failed to open file '%s' for reading.", sFileName))
    error(err, 2)
  end
end

-- Downloads a file using http from sFileLocation
local function getFile(sFileLocation)
  expect(1, sFileLocation, "string")

  local h, err = http.get(sFileLocation)
  if h then
    local sData = h.readAll()
    h.close()
    return sData
  else
    printError(string.format("Failed to download file from %s.", sFileLocation))
    error(err, 2)
  end
end

-- writes sData to sFileName
local function writeFile(sFileName, sData)
  expect(1, sFileName, "string")
  expect(2, sData, "string")

  local h, err = io.open(sFileName, 'w')
  if h then
    h:write(sData):close()
  else
    printError(string.format("Failed to open file '%s' for writing.", sFileName))
    error(err, 2)
  end
end

-- checks if sFileName exists, and if not, downloads it from sLocation
local function checkAndDownload(sFileName, sLocation)
  expect(1, sFileName, "string")
  expect(2, sLocation, "string")

  if not fs.exists(sFileName) then
    print(string.format(
      "Missing dependency: %s\nDownloading: %s",
      sFileName,
      sLocation
    ))
    writeFile(sFileName, getFile(sLocation))
  end
end

-- check and download dependencies
for sModule, tData in pairs(tFiles) do
  if sModule ~= "self" then
    checkAndDownload(tData.name, tData.location)
  end
end

--##############################################################
-- Start main program
--##############################################################
local md5 = require "modules.md5"
local Frame = require "modules.Frame"
local Tamperer = require "modules.Tamperer"
local Logger = require "modules.Logger"
local log = Logger("Shop")
local sCacheLocation = "data/cache"
settings.load(fs.combine(sAbsoluteDir, sCacheLocation))
settings.define("cache", {default = {}})
local tCache = settings.get("cache")
tCache.n = #tCache

local tTampBase = {
  bigInfo = "",
  platform = "all",
  colors = {
    bg = {
      main = "black",
    },
    fg = {
      main = "white",
      title = "yellow",
      info = "lightGray",
      listInfo = "gray",
      listTitle = "white",
      bigInfo = "lightGray",
      selector = "yellow",
      arrowDisabled = "gray",
      arrowEnabled = "white",
      input = "yellow",
      error = "red",
    }
  },
  final = "Confirm"
}

local function saveCache()
  settings.clear()
  settings.set("cache", tCache)
  settings.save(fs.combine(sAbsoluteDir, sCacheLocation))
  settings.clear()
end

function peripheral.findFirstName(sType)
  local tPeriphs = peripheral.getNames()
  for i = 1, #tPeriphs do
    if peripheral.getType(tPeriphs[i]) == sType then
      return tPeriphs[i]
    end
  end
end

local function dCopy(tCopy)
  local tReturn = {}
  for k, v in pairs(tCopy) do
    if type(v) == "table" then
      tReturn[k] = dCopy(v)
    else
      tReturn[k] = v
    end
  end
  return tReturn
end

-- update checker
-- returns a table of boolean values.
local function checkUpdates()
  io.write("Checking for updates (")
  local iX, iY = term.getCursorPos()
  local mX = term.getSize()
  log.info("Checking for updates...")

  -- check if a single module needs an update by getting both hashes and comparing
  -- if the hash is different, an update is available
  local function checkSingleUpdate(tData)
    local sLocalHash = md5.sum(readFile(tData.name))
    local sRemoteHash = md5.sum(getFile(tData.location))
    if sLocalHash ~= sRemoteHash then
      return true
    end
    return false
  end

  -- count modules
  local iCount = 0
  for _, _ in pairs(tFiles) do
    iCount = iCount + 1
  end

  -- check each module
  local tCheck = {n = 0}
  local i = 0
  for sModule, tData in pairs(tFiles) do
    local bVal = checkSingleUpdate(tData)
    tCheck[sModule] = bVal
    if bVal then
      tCheck.n = tCheck.n + 1
    i = i + 1
    term.setCursorPos(iX, iY)
    io.write(string.rep(' ', mX - iX))
    term.setCursorPos(iX, iY)
    io.write(string.format("%d / %d)", i, iCount))

  log.info(string.format("Found %d update(s).", tCheck.n))
  if tCheck.n > 0 then
    for k, v in pairs(tCheck) do
      if k ~= "n" then
        log.info(string.format("  %s", k))
      end
    end
  end
  return tCheck
end

-- get a yes or no answer
local function ensure(sTitle, sInfo, sInfoYes, sBigInfoYes)
  local tTampCurrent = dCopy(tTampBase)
  tTampCurrent.name = sTitle or ""
  tTampCurrent.info = sInfo or "Are you sure?"
  tTampCurrent.selections = {
    {
      title = "Yes",
      info = sInfoYes or "",
      bigInfo = sBigInfoYes or ""
    }
  }
  tTampCurrent.final = "No"

  return Tamperer.display(tTampCurrent) == 1
end

-- edit single item
local function edit(tItem)
  local tTampCurrent = dCopy(tTampBase)
  tTampCurrent.name = "Edit Item"
  tTampCurrent.info = "Edit the selected item"
  tTampCurrent.final = "Confirm"

  settings.set("tempdata.displayName", tItem.displayName)
  settings.set("tempdata.price", tItem.price)
  settings.set("tempdata.show", tItem.show)
  settings.set("tempdata.localname", tItem.localname)

  tTampCurrent.settings = {
    location = "data/.temp",
    {
      setting = "tempdata.displayName",
      title = "Name",
      tp = "string",
      bigInfo = string.format(
        "Set the name of the item %s (with damage %d).",
        tItem.name,
        tItem.damage
      )
    },
    {
      setting = "tempdata.price",
      title = "Price",
      tp = "number",
      min = 0,
      bigInfo = "Set the price of this item."
    },
    {
      setting = "tempdata.show",
      title = "Show",
      tp = "boolean",
      bigInfo = "Show this item in the shop?"
    },
    {
      setting = "tempdata.localname",
      title = "Sub-domain",
      tp = "string",
      bigInfo = "Set this only if you are using a Krist Domain (<this part>@domain.kst)."
    }
  }

  Tamperer.display(tTampCurrent)
  tItem.displayName = settings.get("tempdata.displayName")
  tItem.price = settings.get("tempdata.price")
  tItem.show = settings.get("tempdata.show")
  tItem.localname = settings.get("tempdata.localname")
  settings.clear()
  settings.save(tTampCurrent.settings.location)
end

-- edit items
local function editItems(tItems)
  while true do
    local tTampCurrent = dCopy(tTampBase)

    tTampCurrent.name = "Edit Items"
    tTampCurrent.info = "Edit items here."
    tTampCurrent.final = "Exit."

    tTampCurrent.selections = {}
    for i = 1, #tItems do
      local tCurrent = tItems[i]
      tTampCurrent.selections[#tTampCurrent.selections + 1] = {
        title = tCurrent.displayName:sub(1, 12),
        info = string.format(
          "Edit item %s (%d)",
          tCurrent.displayName,
          tCurrent.damage
        ):sub(1, 25),
        bigInfo = string.format(
          "Edit the item '%s' (with damage %d%s).  Currently priced at %.2f.",
          tCurrent.displayName,
          tCurrent.damage,
          tCurrent.nbtHash and " and with a nbtHash" or "",
          tCurrent.price
        )
      }
    end

    local iSelection = Tamperer.display(tTampCurrent)

    if iSelection == #tItems + 1 then
      return
    else
      edit(tItems[iSelection])
    end
  end
end

-- compare two tables, ignoring anything at lower depths.
-- will return false if the tables contain subtables.
local function compare(t1, t2)
  local function check(t1, t2)
    for k, v in pairs(t1) do
      if not t2[k] or t2[k] ~= v then
        return false
      end
    end

    return true
  end

  return check(t1, t2) and check(t2, t1)
end

-- checks for table entries that are the same, recursively.
local function collapse(tTable)
  local tRemovals = {}
  -- compare each table to each table, marking similar tables for removal
  for i = 1, #tTable - 1 do
    for o = i + 1, #tTable do
      if compare(tTable[i], tTable[o]) then
        tRemovals[#tRemovals + 1] = o
      end
    end
  end
  table.sort(tRemovals)

  -- remove things marked for removal
  local iLast = 0
  for i = #tRemovals, 1, -1 do
    -- but only if we haven't already removed it (ie something gets marked twice)
    if tRemovals[i] ~= iLast then
      table.remove(tTable, tRemovals[i])
    end
    iLast = tRemovals[i]
  end
end

-- Check for duplicates and remove them if they exist.
-- Allows the user to choose which duplicate to keep (hence configure)
local function configureDuplicates(tNewItems)
  local tRemovals = {}
  -- determine duplicates
  local tDupes = {}
  for i = 1, #tNewItems do
    local tNItem = tNewItems[i]
    for j = 1, tCache.n do
      local tCItem = tCache[j]
      if tNItem.name == tCItem.name and tNItem.nbthash == tCItem.nbthash then
        tDupes[#tDupes + 1] = {i, j}
      end
    end
  end
  -- get which duplicate to keep
  for i = 1, #tDupes do
    local tCurrent = tDupes[i]
    local tTampCurrent = dCopy(tTampBase)
    tTampCurrent.name = "Duplicate"
    tTampCurrent.info = "Choose which to keep."
    tTampCurrent.final = "None"
    tTampCurrent.selections = {
      {
        title = "Old",
        info = tCache[tCurrent[2]].displayName,
        bigInfo = string.format(
          "Item: %s | Damage: %d | Price: %s",
          tCache[tCurrent[2]].name,
          tCache[tCurrent[2]].damage,
          tCache[tCurrent[2]].price
        )
      },
      {
        title = "New",
        info = tNewItems[tCurrent[1]].displayName,
        bigInfo = string.format(
          "Item: %s | Damage: %d | Price: %s",
          tNewItems[tCurrent[1]].name,
          tNewItems[tCurrent[1]].damage,
          tNewItems[tCurrent[1]].price
        )
      }
    }

    local sel = Tamperer.display(tTampCurrent)
    if sel == 2 then
      -- if they selected to keep the new one
      tCache[tCurrent[2]] = dCopy(tNewItems[tCurrent[1]])
    elseif sel == 3 then
      -- if they decided to keep none of them
      tRemovals[#tRemovals + 1] = tCurrent[2]
    end
  end

  table.sort(tRemovals)
  for i = #tRemovals, 1, -1 do
    table.remove(tCache, tRemovals[i])
    tCache.n = tCache.n - 1
  end

  -- add the other items
  for i = 1, #tNewItems do
    if #tDupes == 0 then
      tCache.n = tCache.n + 1
      tCache[tCache.n] = dCopy(tNewItems[i])
    else
      local bNoDupe = true
      for j = 1, #tDupes do
        if tDupes[j][1] == i then
          bNoDupe = false
        end
      end
      if bNoDupe then
        tCache.n = tCache.n + 1
        tCache[tCache.n] = dCopy(tNewItems[i])
      end
    end
  end
end

local function removeItems()
  local tTampCurrent = dCopy(tTampBase)
  tTampCurrent.name = "Remove Items"
  tTampCurrent.info = "Remove Items Here"
  tTampCurrent.final = "Go back"
  while true do
    tTampCurrent.selections = {}
    for i = 1, tCache.n do
      local tItem = tCache[i]
      tTampCurrent.selections[#tTampCurrent.selections + 1] = {
        title = tItem.displayName:sub(1, 12),
        info = "Remove this item.",
        bigInfo = string.format(
          "Remove the item %s with damage %d%s.",
          tItem.name,
          tItem.damage,
          tItem.nbtHash and " with nbthash" or ""
        )
      }
    end

    local sel = Tamperer.display(tTampCurrent)
    if sel ~= tCache.n + 1 then
      if ensure("Remove?", nil, "Delete item.", "This action cannot be undone.") then
        table.remove(tCache, sel)
        tCache.n = tCache.n - 1
        saveCache()
      end
    else
      return
    end
  end
end

local function addItems()
  term.setTextColor(colors.white)
  term.setBackgroundColor(colors.black)
  term.clear()
  term.setCursorPos(1, 1)
  log.info("Item addition start")
  print("Entering item addition setup...")

  -- get the basic item information
  local bOk, tItems = pcall(peripheral.call, "front", "list")
  if bOk and tItems then
    local iSize = peripheral.call("front", "size")
    if iSize then
      local tDetailedItems = {}

      -- get detailed information about each item
      for i = 1, iSize do
        if tItems[i] then
          -- we want to keep the name, damage, display name, and nbthash (if exists)
          local tCurrent = tItems[i]
          local iDamage = tCurrent.damage
          local sName = tCurrent.name
          print(string.format("Getting metadata for item %s (%d)", sName, iDamage))
          local tMeta = peripheral.call("front", "getItemMeta", i)
          if tMeta then
            tDetailedItems[#tDetailedItems + 1] = {
              name = sName,
              damage = iDamage,
              displayName = tMeta.displayName,
              nbtHash = tMeta.nbtHash, -- TODO: Filter by nbthash?
              price = 1,
              localname = "",
              show = true
            }
          else
            print(string.format("Failed to get metadata for item %s (%d)", sName, iDamage))
            log.warn(string.format("Failed to get metadata for item %s (%d)", sName, iDamage))
          end
        end
      end
      print("Got all items.")
      print("Removing duplicates")
      collapse(tDetailedItems)
      print("Done.")
      os.sleep(1)

      -- enter edit page.
      editItems(tDetailedItems)

      local tDupes = {}
      -- Check for duplicates, and add the items

      configureDuplicates(tDetailedItems)

      saveCache()
      return
    else
      log.warn("Failed to get chest size.")
      printError("Failed to get chest size.  Exiting...")
    end
  else
    log.warn("No chest for item addition!")
    printError("No chest detected in front of the machine! Exiting...")
  end
  os.sleep(5)
end

local function items()
  while true do
    local iSelection = Tamperer.displayFile(tFiles.ItemsMenu.name)

    local tTampCurrent = dCopy(tTampBase)

    if iSelection == 1 then
      -- add items
      tTampCurrent.name = "Add Items"
      tTampCurrent.info = "Item addition wizard"
      tTampCurrent.final = "Cancel"

      tTampCurrent.selections = {{
        title = "Ready",
        info = "Select when ready.",
        bigInfo = "Place a chest with the items you wish to add in front of this machine, then select this."
      }}
      local iResult = Tamperer.display(tTampCurrent)
      if iResult == 1 then
        addItems()
      end
    elseif iSelection == 2 then
      -- edit items
      editItems(tCache)
      saveCache()
    elseif iSelection == 3 then
      -- remove items
      removeItems()
      saveCache()
    else
      return
    end
  end
end

-- define some default settings
local function defineSettings()
  local function defineDefault(sSetting, val)
    settings.define(sSetting, {type = type(val), default = val})
  end
  -- base settings
  defineDefault("shop.autorun", 15)
  defineDefault("shop.monitor", peripheral.findFirstName("monitor") or error("Cannot find monitor.", 0))

  -- -- -- Visuals -- -- --

  -- itemlist
    -- legend
  defineDefault("shop.visual.itemlist.showLegend", true)
  defineDefault("shop.visual.itemlist.legendBG",   colors.purple)
  defineDefault("shop.visual.itemlist.legendFG",   colors.white)
    -- odd entries
  defineDefault("shop.visual.itemlist.oddBG", colors.gray)
  defineDefault("shop.visual.itemlist.oddFG", colors.white)
  defineDefault("shop.visual.itemlist.emptyOddBG", colors.gray)
  defineDefault("shop.visual.itemlist.emptyOddFG", colors.red)
    -- even entries
  defineDefault("shop.visual.itemlist.evenBG", colors.lightGray)
  defineDefault("shop.visual.itemlist.evenFG", colors.white)
  defineDefault("shop.visual.itemlist.emptyEvenBG", colors.lightGray)
  defineDefault("shop.visual.itemlist.emptyEvenFG", colors.red)
    -- etc
  defineDefault("shop.visual.itemlist.showEmpty", true)

  -- -- -- Logger -- -- --
  defineDefault("shop.logger.level", 1) -- TODO: Set this to 3 once prod
end

-- run the options page
local function options()
  local function settingHandler(sFileName, sSetting, NewVal, tPage)
    --TODO: This should display the shop when any visual change is made
  end
  Tamperer.displayFile(tFiles.OptionsMenu.name, settingHandler)
end

-- run the updater page
local function updater(tUpdates)
  local fLoad, err = load("return " .. readFile(tFiles.UpdaterMenu.name))
  if fLoad then
    local tMenu = fLoad()
    tUpdates.n = nil
    local tResolver = {}
    for sModule, bIsUpdate in pairs(tUpdates) do
      if bIsUpdate then
        tMenu.settings[#tMenu.settings + 1] = {
          setting = "UPDATE." .. sModule,
          title = #sModule < 10 and sModule or sModule:sub(1, 7) .. "...",
          tp = "boolean",
          bigInfo = string.format("Set to true to update the module %s.", sModule)
        }
        settings.set("UPDATE." .. sModule, false)
        tResolver["UPDATE." .. sModule] = sModule
      end
    end
    settings.save(tMenu.settings.location)

    local result = Tamperer.display(tMenu)

    -- if we chose to update
    if result == 1 then
      term.setBackgroundColor(colors.black)
      term.setTextColor(colors.white)
      term.clear()
      term.setCursorPos(1, 1)
      log.info("Update started.")
      print("Update started.")
      local iUpdated = 0
      for k, v in pairs(tResolver) do
        if settings.get(k) then -- if the update selection was true
          log.info(string.format("Updating module %s.", v))
          print(string.format("Updating module %s.", v))
          fs.delete(tFiles[v].location)
          writeFile(tFiles[v].name, getFile(tFiles[v].location))
          iUpdated = iUpdated + 1
        end
      end
      log.info("Update completed.")
      Logger.close()
      print(string.format("Update completed. Updated %d module(s).", iUpdated))
      print("Rebooting...")
      os.sleep(4)
      os.reboot()
    end
  end
end

-- run the main menu
local function mainMenu()
  -- load the page (the same way tamperer does)
  local fLoad, err = load("return " .. readFile(tFiles.MainMenu.name))

  -- if no errors
  if fLoad then
    -- turn the page into a table
    local tMenu = fLoad()
    -- check for updates
    local tUpdates = checkUpdates()

    -- set the value of the update selection to match update check
    tMenu.selections[2].info = tUpdates.n == 1 and "1 update available"
                              or string.format("%d updates available", tUpdates.n)
    tMenu.selections[2].bigInfo = tUpdates.n == 0 and "There are no updates available at this time."
                              or tUpdates.n == 1 and "There is one update available at this time."
                              or string.format("There are %d updates available at this time.", tUpdates.n)

    local flg = true
    while true do
      -- display the page
      -- if first time running the page, timeout of 15 seconds
      local iSelection = Tamperer.display(tMenu, nil, flg and 15 or nil)
      flg = false
      if iSelection == 1 then
        -- run the shop
      elseif iSelection == 2 then
        -- updater
        -- presented as a seperate page to allow a "save and exit" sort of functionality.
        updater(tUpdates)
      elseif iSelection == 3 then
        -- options menu
        -- Presented as a seperate page rather than a subpage to allow the visuals customizer to start when swapped to.
        options()
      elseif iSelection == 4 then
        -- items menu
        -- Presented as a seperate page rather than a subpage to allow
        items()
      elseif iSelection == 5 then
        -- exit
        break
      end
    end
  else
    printError("Failed to load the main menu.")
    error(err, 0)
  end
end

local function main()
  defineSettings()
  Logger.setMasterLevel(settings.get("shop.logger.level"))
  mainMenu()
end

local bOk, sErr = pcall(main)
if not bOk then
  log.err(sErr)
  term.setTextColor(colors.white)
  term.setBackgroundColor(colors.black)
  term.clear()
  term.setCursorPos(1, 1)
  printError(sErr)
end

Logger.close()
