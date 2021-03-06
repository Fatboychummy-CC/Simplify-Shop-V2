local expect = require("cc.expect").expect


--##############################################################
-- Initial setup stuff, so we can download dependencies we need
--##############################################################
local sAbsoluteDir = shell.dir()
local tFiles = {
  self = {
    location = "https://raw.githubusercontent.com/Fatboychummy-CC/Simplify-Shop-V2/__BRANCH__/shop.lua",
    name = shell.getRunningProgram()
  },
  Storage = {
    location = "https://raw.githubusercontent.com/Fatboychummy-CC/Simplify-Shop-V2/__BRANCH__/modules/Storage.lua",
    name = fs.combine(sAbsoluteDir, "modules/Storage.lua")
  },
  argparse = {
    location = "https://raw.githubusercontent.com/mpeterv/argparse/master/src/argparse.lua",
    name = fs.combine(sAbsoluteDir, "modules/argparse.lua")
  },
  sha256 = {
    location = "https://pastebin.com/raw/6UV4qfNF",
    name = fs.combine(sAbsoluteDir, "modules/sha256.lua")
  },
  md5 = {
    location = "https://raw.githubusercontent.com/kikito/md5.lua/master/md5.lua",
    name = fs.combine(sAbsoluteDir, "modules/md5.lua")
  },
  Tamperer = {
    location = "https://raw.githubusercontent.com/Fatboychummy-CC/Tamperer/master/minified.lua",
    name = fs.combine(sAbsoluteDir, "modules/Tamperer.lua")
  },
  Frame = {
    location = "https://raw.githubusercontent.com/Fatboychummy-CC/Frame/master/Frame.lua",
    name = fs.combine(sAbsoluteDir, "modules/Frame.lua")
  },
  Logger = {
    location = "https://raw.githubusercontent.com/Fatboychummy-CC/Compendium/master/modules/core/logger.lua",
    name = fs.combine(sAbsoluteDir, "modules/Logger.lua")
  },
  JSON = {
    location = "https://raw.githubusercontent.com/rxi/json.lua/master/json.lua",
    name = fs.combine(sAbsoluteDir, "modules/json.lua")
  },
  KristWrap = {
    location = "https://raw.githubusercontent.com/Fatboychummy-CC/KristWrap/master/minified.lua",
    name = fs.combine(sAbsoluteDir, "modules/KristWrap.lua")
  },
  MainMenu = {
    location = "https://raw.githubusercontent.com/Fatboychummy-CC/Simplify-Shop-V2/__BRANCH__/data/main.tamp",
    name = fs.combine(sAbsoluteDir, "data/main.tamp")
  },
  OptionsMenu = {
    location = "https://raw.githubusercontent.com/Fatboychummy-CC/Simplify-Shop-V2/__BRANCH__/data/options.tamp",
    name = fs.combine(sAbsoluteDir, "data/options.tamp")
  },
  UpdaterMenu = {
    location = "https://raw.githubusercontent.com/Fatboychummy-CC/Simplify-Shop-V2/__BRANCH__/data/updates.tamp",
    name = fs.combine(sAbsoluteDir, "data/updates.tamp")
  },
  ItemsMenu = {
    location = "https://raw.githubusercontent.com/Fatboychummy-CC/Simplify-Shop-V2/__BRANCH__/data/items.tamp",
    name = fs.combine(sAbsoluteDir, "data/items.tamp")
  }
}
local tBranches = {
  "master",
  "development"
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

settings.load(".shopStartup")
if not settings.get("shop.branch") then
  local nSelected
  repeat
    term.clear()
    term.setCursorPos(1, 1)
    print("Choose a branch:")
    for i = 1, #tBranches do
      print(i, tBranches[i])
    end
    nSelected = tonumber(io.read())
  until nSelected and tBranches[nSelected]
  settings.set("shop.branch", tBranches[nSelected])
  settings.save(".shopStartup")
end

local sBranch = settings.get("shop.branch")
settings.clear()

-- check and download dependencies
for sModule, tData in pairs(tFiles) do
  if sModule ~= "self" then
    checkAndDownload(tData.name, tData.location:gsub("__BRANCH__", sBranch))
  end
end

--##############################################################
-- Start main program
--##############################################################
-- set the path
package.path = string.format("%s;modules/?;modules/?.lua;%s/modules/?;%s/modules/?.lua", package.path, sAbsoluteDir, sAbsoluteDir)

-- Parse command line arguments, if any.
local args
do
  function os.exit()
    error("", 0)
  end

  local argparse  = require "argparse"

  local parser = argparse()
    :name(shell.getRunningProgram())
    :description("A computercraft shop system running on Krist")
    :epilog("See https://github.com/Fatboychummy-CC/Simplify-Shop-V2/wiki for documentation.")

  parser:flag "-n" "--no-update-check" :description "Start the shop without checking for updates."

  parser:flag "-i" "--immediate" :description "Immediately launch the shop after getting to the menu (ignoring the auto-wait, if set)."

  local mx = ({term.getSize()})[1]

  parser:help_max_width(mx)
    :help_description_margin(#("Usage: " .. shell.getRunningProgram()))
    :help_vertical_space(1)

  parser:usage_max_width(mx)
    :usage_margin(#("Usage: " .. shell.getRunningProgram()))

  parser:add_help {
     action = function() textutils.pagedPrint(parser:get_help()) error("", 0) end
  }

  args = parser:parse({...})

  os.exit = nil
end


local md5       = require "md5"
local Frame     = require "Frame"
local Tamperer  = require "Tamperer"
local Logger    = require "Logger"
local json      = require "json"
local KristWrap = require "KristWrap"
local Storage   = require "Storage"
local log  = Logger("Shop")
local plog = Logger("Purchase")
local sCacheLocation = "data/cache"
settings.load(fs.combine(sAbsoluteDir, sCacheLocation))
settings.define("cache", {default = {}})
local tCache = settings.get("cache")
tCache.n = #tCache
local bFrameInitialized = false
local dots    = {}
local buttons = {}
local tFrame, sAddress

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

local modemSide
for _, sSide in ipairs(rs.getSides()) do
  if peripheral.getType(sSide) == "modem" then
    if modemSide then error("Too many modems attached to controller! Please only connect one modem to the controller.") end
    modemSide = sSide
  end
end

for k, v in pairs(colors) do
  if type(v) == "number" then
    colors[v] = k
  end
end

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

local function IsIn(t, v)
  for i = 1, t.n or #t do
    if t[i] == v then
      return true
    end
  end
  return false
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
    -- if a provider is down, don't fail the update check.
    local bOk, tFileData = pcall(getFile, tData.location:gsub("__BRANCH__", sBranch))
    if not bOk then return true end
    local sRemoteHash = md5.sum(tFileData)

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
    end
    i = i + 1
    term.setCursorPos(iX, iY)
    io.write(string.rep(' ', mX - iX))
    term.setCursorPos(iX, iY)
    io.write(string.format("%d / %d)", i, iCount))
  end

  log.info(string.format("Found %d update(s).", tCheck.n))
  if tCheck.n > 0 then
    for k, v in pairs(tCheck) do
      if k ~= "n" and v then
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
        "Set the name of the item %.30s (with damage %d).",
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

  if tItem.nbtHash then
    tTampCurrent.settings[#tTampCurrent.settings + 1] = {
      setting = "tempdata.sortByNbt",
      title = "Sort NBT",
      tp = "boolean",
      bigInfo = "This item has an NBT hash. Include this information while sorting?"
    }
  end

  Tamperer.display(tTampCurrent)
  tItem.displayName = settings.get("tempdata.displayName")
  tItem.price = settings.get("tempdata.price")
  tItem.show = settings.get("tempdata.show")
  tItem.localname = settings.get("tempdata.localname")
  tItem.sortByNbt = settings.get("tempdata.sortByNbt")
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
      local sInfo = string.format(
        "Edit '%s'",
        tCurrent.displayName
      )
      if #sInfo > 25 then
        sInfo = sInfo:sub(1, 22) .. "..."
      end
      tTampCurrent.selections[#tTampCurrent.selections + 1] = {
        title = tCurrent.displayName:sub(1, 12),
        info = sInfo,
        bigInfo = string.format(
          "Item: %.32s\nDamage: %d | NBT? %s\nPrice: %.5f",
          tCurrent.name,
          tCurrent.damage,
          tCurrent.nbtHash and true or false,
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
      if tNItem.name == tCItem.name and tNItem.nbtHash == tCItem.nbtHash then
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
          "Item: %.32s | Damage: %d | Price: %s",
          tCache[tCurrent[2]].name,
          tCache[tCurrent[2]].damage,
          tCache[tCurrent[2]].price
        )
      },
      {
        title = "New",
        info = tNewItems[tCurrent[1]].displayName,
        bigInfo = string.format(
          "Item: %.32s | Damage: %d | Price: %s",
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
          "Remove the item %.20s with damage %d%s.",
          tItem.name,
          tItem.damage,
          tItem.nbtHash and " with nbtHash" or ""
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
          -- we want to keep the name, damage, display name, and nbtHash (if exists)
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
              nbtHash = tMeta.nbtHash, -- TODO: Filter by nbtHash?
              sortByNbt = tMeta.nbtHash and true or false,
              stackSize = tMeta.maxCount,
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

local function redrawError(sError)
  error(string.format("Failed to redraw: %s", sError))
end

-- check if a setting exists, if not: error.  If so, return setting value
local function does(sSetting, sDescriptiveName)
  local valExists = settings.get(sSetting)
  if valExists == nil then
    redrawError(
      string.format(
        "Setting %s (%s) not set.",
        sSetting,
        sDescriptiveName
      )
    )
  end
  return valExists
end

-- define some default settings
local function defineDefault(sSetting, val)
  expect(1, sSetting, "string")
  expect(2, val, "string", "number", "table", "boolean")
  settings.define(sSetting, {type = type(val), default = val})
end

local function defineTampererFile(sFileName, sContents)
  local sDir = fs.combine(fs.getDir(shell.getRunningProgram()), ".TampererLongData")

  if not fs.exists(sDir) then
    fs.makeDir(sDir)
  end
  if not fs.exists(fs.combine(sDir, sFileName)) then
    -- write file
    sContents = sContents:gsub("%%open%%", "["):gsub("%%close%%", "]")
    local h = io.open(fs.combine(sDir, sFileName), 'w')
    h:write(sContents):close()
  end
end

local function defineSettings()
  -- base settings
  defineDefault("shop.autorun", 15)
  defineDefault("shop.monitor", peripheral.findFirstName("monitor") or error("Cannot find monitor.", 0))
  if not peripheral.isPresent(settings.get("shop.monitor")) then
    settings.unset("shop.monitor")
  end

  -- -- -- Visuals -- -- --
  defineDefault("shop.visual.monitorScale", 1)
  defineDefault("shop.visual.mainBG",       colors.black)

  -- palette
  local sFormat = "shop.visual.palette.%s.%%s"
  for i = 0, 15 do
    local sColor = string.format(sFormat, colors[2^i])
    local iHex = colors.rgb8(term.nativePaletteColor(2^i))
    local iR, iG, iB = colors.unpackRGB(iHex)
    defineDefault(string.format(sColor, 'hex'), iHex)
    defineDefault(string.format(sColor, 'r'), iR * 255)
    defineDefault(string.format(sColor, 'g'), iG * 255)
    defineDefault(string.format(sColor, 'b'), iB * 255)
  end
  -- itemlist
    -- legend
  defineDefault("shop.visual.itemlist.showLegend", true)
  defineDefault("shop.visual.itemlist.legendBG",   colors.purple)
  defineDefault("shop.visual.itemlist.legendFG",   colors.white)
    -- positioning
  defineDefault("shop.visual.itemlist.x", 2)
  defineDefault("shop.visual.itemlist.y", 10)
  defineDefault("shop.visual.itemlist.w", 27)
  defineDefault("shop.visual.itemlist.h", 5)
  defineDefault("shop.visual.itemlist.s", 1)
    -- odd entries
  defineDefault("shop.visual.itemlist.oddBG",       colors.gray)
  defineDefault("shop.visual.itemlist.oddFG",       colors.white)
  defineDefault("shop.visual.itemlist.emptyOddBG",  colors.gray)
  defineDefault("shop.visual.itemlist.emptyOddFG",  colors.red)
  defineDefault("shop.visual.itemlist.selectOddBG", colors.white)
  defineDefault("shop.visual.itemlist.selectOddFG", colors.black)
    -- even entries
  defineDefault("shop.visual.itemlist.evenBG",       colors.lightGray)
  defineDefault("shop.visual.itemlist.evenFG",       colors.white)
  defineDefault("shop.visual.itemlist.emptyEvenBG",  colors.lightGray)
  defineDefault("shop.visual.itemlist.emptyEvenFG",  colors.red)
  defineDefault("shop.visual.itemlist.selectEvenBG", colors.white)
  defineDefault("shop.visual.itemlist.selectEvenFG", colors.black)
    -- etc
  defineDefault("shop.visual.itemlist.showEmpty",    true)
  defineDefault("shop.visual.itemlist.decimal",      2)
  defineDefault("shop.visual.itemlist.showDomain",   false)
  defineDefault("shop.visual.itemlist.shortDomain",  false)
  defineDefault("shop.visual.itemlist.deselectTime", 120)

  -- items
  defineDefault("shop.items.dispenseFromTurtle", true)
  defineDefault("shop.items.dispenseDir", "up")
  -- shop.items.dispenseFrom is not set, as it is not used by default.

  -- info box
  defineDefault("shop.visual.infobox.enabled",  true)
  defineDefault("shop.visual.infobox.x",        2)
  defineDefault("shop.visual.infobox.y",        2)
  defineDefault("shop.visual.infobox.w",        27)
  defineDefault("shop.visual.infobox.h",        7)
  defineDefault("shop.visual.infobox.centered", false)
  defineDefault("shop.visual.infobox.text", "infoboxtext.lua")

  -- initialize the file with "basic" datas
  defineTampererFile("infoboxtext.lua", [[--%open%%open%
  Available in the environment:
    math [library],
    string [library],
    table [library],
    item {
      name [string] (the internally cached name of the item),
      displayName [string] (the name of the item displayed to the user),
      damage [int],
      nbtHash [string or nil],
      sortByNbt [bool] (if the shop sorts this item by its nbt data),
      stackSize [int] (maximum amount of items in a single stack),
      price [float] (price per item),
      localname [string] (localname@domain.kst),
      show [bool] (is this item displayed?)
    },
    krist {
      address [string],
      domain [string] (localname@domain.kst)
    }
%close%%close%

local tLines = {}
tLines[1] = ""
tLines[2] = string.format("Krist address: %s", krist.address)
if item then
  tLines[3] = string.format("Item: %s", item.displayName)
  tLines[4] = string.format("Price %.2f", item.price)
  if item.price < 1 then
    tLines[5] = string.format(
      "1 KST: %d items.",
      math.min(
        math.floor(1 / item.price),
        item.count
      )
    )
  else
    tLines[5] = string.format(
      "1 stack (%d): %.2f KST",
      math.min(item.stackSize, item.count),
      math.ceil(item.price * math.min(item.count, item.stackSize))
    )
  end

  tLines[6] = string.format(
    "/pay %s %d",
    krist.domain and krist.domain ~= ""
    and item.localname and item.localname ~= ""
    and string.format(
      "%s@%s.kst",
      item.localname,
      krist.domain
    )
    or krist.address,
    math.ceil(
      item.price * math.min(item.stackSize, item.count)
    )
  )
end


return tLines
]])

  defineDefault("shop.visual.infobox.bg",       colors.lightGray)
  defineDefault("shop.visual.infobox.fg",       colors.white)

    -- bsod
  defineDefault("shop.visual.bsod.bg", colors.blue)
  defineDefault("shop.visual.bsod.fg", colors.white)
  defineDefault("shop.visual.bsod.custom", "bsodinformation.lua")
  defineTampererFile("bsodinformation.lua", [[--%open%%open%
  Available in the environment:
    string [library],
    owner [string]
%close%%close%

return string.format(
  "Contact %s for help.",
  owner and owner ~= "" and owner or "the owner of this shop"
)]])

  -- buttons
    -- previous page
  defineDefault("shop.visual.buttons.prev.enabled",     true)
  defineDefault("shop.visual.buttons.prev.x",           2)
  defineDefault("shop.visual.buttons.prev.y",           17)
  defineDefault("shop.visual.buttons.prev.w",           6)
  defineDefault("shop.visual.buttons.prev.h",           2)
  defineDefault("shop.visual.buttons.prev.color.bgOn",  colors.blue)
  defineDefault("shop.visual.buttons.prev.color.fgOn",  colors.white)
  defineDefault("shop.visual.buttons.prev.color.bgOff", colors.lightGray)
  defineDefault("shop.visual.buttons.prev.color.fgOff", colors.white)
  defineDefault("shop.visual.buttons.prev.text",        "Prev")
    -- next page
  defineDefault("shop.visual.buttons.next.enabled",     true)
  defineDefault("shop.visual.buttons.next.x",           23)
  defineDefault("shop.visual.buttons.next.y",           17)
  defineDefault("shop.visual.buttons.next.w",           6)
  defineDefault("shop.visual.buttons.next.h",           2)
  defineDefault("shop.visual.buttons.next.color.bgOn",  colors.blue)
  defineDefault("shop.visual.buttons.next.color.fgOn",  colors.white)
  defineDefault("shop.visual.buttons.next.color.bgOff", colors.lightGray)
  defineDefault("shop.visual.buttons.next.color.fgOff", colors.white)
  defineDefault("shop.visual.buttons.next.text",        "Next")

  -- dots
    -- Redraw dot
  defineDefault("shop.visual.dots.redraw.enabled",           true)
  defineDefault("shop.visual.dots.redraw.displayTime",       2)
  defineDefault("shop.visual.dots.redraw.x",                 1)
  defineDefault("shop.visual.dots.redraw.y",                 1)
  defineDefault("shop.visual.dots.redraw.color",             colors.blue)
  defineDefault("shop.visual.dots.redraw.useCustomOffColor", false)
  defineDefault("shop.visual.dots.redraw.offColor",          colors.black)

    -- Purchase dot
  defineDefault("shop.visual.dots.purchase.enabled",           true)
  defineDefault("shop.visual.dots.purchase.displayTime",       2)
  defineDefault("shop.visual.dots.purchase.x",                 1)
  defineDefault("shop.visual.dots.purchase.y",                 2)
  defineDefault("shop.visual.dots.purchase.color",             colors.green)
  defineDefault("shop.visual.dots.purchase.useCustomOffColor", false)
  defineDefault("shop.visual.dots.purchase.offColor",          colors.black)

    -- Redraw dot
  defineDefault("shop.visual.dots.userInput.enabled",           true)
  defineDefault("shop.visual.dots.userInput.displayTime",       2)
  defineDefault("shop.visual.dots.userInput.x",                 1)
  defineDefault("shop.visual.dots.userInput.y",                 3)
  defineDefault("shop.visual.dots.userInput.color",             colors.red)
  defineDefault("shop.visual.dots.userInput.useCustomOffColor", false)
  defineDefault("shop.visual.dots.userInput.offColor",          colors.black)

    -- Redraw dot
  defineDefault("shop.visual.dots.update.enabled",           true)
  defineDefault("shop.visual.dots.update.displayTime",       1)
  defineDefault("shop.visual.dots.update.x",                 1)
  defineDefault("shop.visual.dots.update.y",                 ({peripheral.call(settings.get("shop.monitor"), "getSize")})[2])
  defineDefault("shop.visual.dots.update.color",             colors.green)
  defineDefault("shop.visual.dots.update.useCustomOffColor", true)
  defineDefault("shop.visual.dots.update.offColor",          colors.blue)

  -- -- -- Krist -- -- --
  defineDefault("shop.krist.address",                   "kxxxxxxxx")
  defineDefault("shop.krist.domain",                    "")
  defineDefault("shop.krist.doPurchaseForwarding",      false)
  defineDefault("shop.krist.purchaseForwardingAddress", "")
  defineDefault("shop.krist.endpoint",                  KristWrap.getDefaultEndPoint())
  defineDefault("shop.krist.purchaseForwardingMeta",    "forwardmeta.lua")
  defineTampererFile("forwardmeta.lua", [[return string.format("Forwarded purchase: %s bought %d %s for %d (%.2f per unit, with %d refunded).", from, itemsGiven, item.displayName, value, item.price, refunded)
  ]])


  -- -- -- Logger -- -- --
  defineDefault("shop.logger.level", 1) -- TODO: Set this to 3 once prod
  defineDefault("shop.logger.saveold", false)
end

local function Bawx(tTo, x, y, w, h, bg, fg)
  local chars = {
    corners = {
      br = {char = "\133", inverted = true},
      bl = {char = "\138", inverted = true},
      tr = {char = "\148", inverted = true},
      tl = {char = "\151", inverted = false}
    },
    tl = {char = "\131", inverted = false},
    ll = {char = "\149", inverted = false},
    rl = {char = "\149", inverted = true},
    bl = {char = "\143", inverted = true}
  }

  local function drawCorner(char, x, y)
    tTo.setCursorPos(x, y)
    tTo.setBackgroundColor(char.inverted and fg or bg)
    tTo.setTextColor(char.inverted and bg or fg)
    tTo.write(char.char)
  end
  local function horiLine(char, x, y, len)
    tTo.setCursorPos(x, y)
    tTo.setBackgroundColor(char.inverted and fg or bg)
    tTo.setTextColor(char.inverted and bg or fg)
    tTo.write(string.rep(char.char, len))
  end


  drawCorner(chars.corners.tl, x, y)
  drawCorner(chars.corners.tr, x + w - 1, y)
  drawCorner(chars.corners.bl, x, y + h - 1)
  drawCorner(chars.corners.br, x + w - 1, y + h - 1)

  horiLine(chars.tl, x + 1, y, w - 2)
  horiLine(chars.bl, x + 1, y + h - 1, w - 2)

end

-- cut a string into multiple strings
local function cut(s, iMax)
  local t = {n = 0}
  for str in string.gmatch(s, string.rep(".?", iMax)) do
    t.n = t.n + 1
    t[t.n] = str
  end
  return t
end

-- split a string into a table of lines
-- s: string, iMax: max x value
local function line(s, iMax)
  expect(1, s, "string")

  -- seperate string into words
  local tSep = {n = 0}
  for word in s:gmatch("%S+") do
    tSep.n = tSep.n + 1
    tSep[tSep.n] = word
  end

  local tMeta = {__index = {
    push = function(t, v) t.n = t.n + 1 t[t.n] = v return t end,
    pop = function(t, v) t[t.n] = nil t.n = t.n - 1 return t end
  }}
  local tNew = setmetatable({n = 0}, tMeta)
  local tTemp = setmetatable({n = 0}, tMeta)
  local i = 1

  -- split
  while true do
    local function pushLine(bFlag)
      local toPush = table.concat(tTemp, ' ', 1, bFlag and tTemp.n or tTemp.n - 1)
      if toPush ~= "" then
        tNew:push(toPush)
      end
      i = i - 1
      tTemp = setmetatable({n = 0}, tMeta)
    end
    -- push the next word to the line
    tTemp:push(tSep[i])

    -- check if the current line is too long
    if tTemp.n == 1 and #tTemp[1] > iMax then
      -- If a single word is too long, push it.
      tTemp = setmetatable({n = 0}, tMeta)
      local cuts = cut(tSep[i], iMax)
      for j = 1, cuts.n do
        tNew:push(cuts[j])
      end
    elseif #table.concat(tTemp, ' ') > iMax then
      -- If the line is too long, move it to the lines table and clear
      pushLine()
    end

    -- increase word position
    i = i + 1
    -- check if we have iterated past the last word
    if i > tSep.n then
      pushLine(true)
      return tNew
    end
  end
end

local function initMonitor()
  if not bFrameInitialized then
    settings.clear()
    settings.load(".shopSettings")
    local sMonName = does("shop.monitor", "Monitor Peripheral Name")
    if not peripheral.isPresent(sMonName) then
      redrawError(string.format("Peripheral '%s' does not exist.", sMonName))
    end
    if peripheral.getType(sMonName) ~= "monitor" then
      redrawError(string.format("Peripheral '%s' is not a monitor.", sMonName))
    end
    local tMon = peripheral.wrap(sMonName)
    if not tMon then
      redrawError("Failed to wrap peripheral '%s'.")
    end
    local fMonScale = does("shop.visual.monitorScale", "Monitor Scale")
    tMon.setTextScale(fMonScale)

    tFrame = Frame.new(tMon)
    tFrame.Initialize()
    bFrameInitialized = true

    -- set palette
    local sFormat = "shop.visual.palette.%s.%%s"
    for i = 0, 15 do
      local sColor = string.format(sFormat, colors[2^i])
      local iHex = does(string.format(sColor, 'hex'), "A color's hex value")
      tMon.setPaletteColor(2^i, iHex)
    end
  end
end

local function initDots()
  dots = {}
  local tMeta = {
    __call = function(t, b)
      if t.enabled then
        tFrame.setCursorPos(t.x, t.y)
        tFrame.setBackgroundColor(b and t.color or t.offColor)
        tFrame.write(' ')
      end
    end
  }

  -- redraw dot
  dots.redraw = setmetatable({
    color    = does("shop.visual.dots.redraw.color", "Redraw dot color"),
    offColor = does("shop.visual.dots.redraw.useCustomOffColor", "Redraw dot use custom off color")
               and does("shop.visual.dots.redraw.offColor", "Redraw dot off color")
               or does("shop.visual.mainBG", "Main background"),
    x        = does("shop.visual.dots.redraw.x", "Redraw dot X pos"),
    y        = does("shop.visual.dots.redraw.y", "Redraw dot Y pos"),
    enabled  = does("shop.visual.dots.redraw.enabled", "Redraw dot enabled"),
    time     = does("shop.visual.dots.redraw.displayTime", "Redraw dot display time")
  }, tMeta)

  -- purchase dot
  dots.purchase = setmetatable({
    color    = does("shop.visual.dots.purchase.color", "Purchase dot color"),
    offColor = does("shop.visual.dots.purchase.useCustomOffColor", "Purchase dot use custom off color")
               and does("shop.visual.dots.purchase.offColor", "Purchase dot off color")
               or does("shop.visual.mainBG", "Main background"),
    x        = does("shop.visual.dots.purchase.x", "Purchase dot X pos"),
    y        = does("shop.visual.dots.purchase.y", "Purchase dot Y pos"),
    enabled  = does("shop.visual.dots.purchase.enabled", "Purchase dot enabled"),
    time     = does("shop.visual.dots.purchase.displayTime", "Purchase dot display time")
  }, tMeta)

  -- user input dot
  dots.userInput = setmetatable({
    color    = does("shop.visual.dots.userInput.color", "User Input dot color"),
    offColor = does("shop.visual.dots.userInput.useCustomOffColor", "User Input dot use custom off color")
               and does("shop.visual.dots.userInput.offColor", "User Input dot off color")
               or does("shop.visual.mainBG", "Main background"),
    x        = does("shop.visual.dots.userInput.x", "User Input dot X pos"),
    y        = does("shop.visual.dots.userInput.y", "User Input dot Y pos"),
    enabled  = does("shop.visual.dots.userInput.enabled", "User Input dot enabled"),
    time     = does("shop.visual.dots.userInput.displayTime", "User Input dot display time")
  }, tMeta)

  -- update available dot
  dots.update = setmetatable({
    color    = does("shop.visual.dots.update.color", "Update dot color"),
    offColor = does("shop.visual.dots.update.useCustomOffColor", "Update dot use custom off color")
               and does("shop.visual.dots.update.offColor", "Update dot off color")
               or does("shop.visual.mainBG", "Main background"),
    x        = does("shop.visual.dots.update.x", "Update dot X pos"),
    y        = does("shop.visual.dots.update.y", "Update dot Y pos"),
    enabled  = does("shop.visual.dots.update.enabled", "Update dot enabled"),
    time     = does("shop.visual.dots.update.displayTime", "Update dot display time")
  }, tMeta)
end

local function initButtons()
  buttons = {}
  local tMeta = {
    __call = function(t, b)
      if t.enabled then
        tFrame.setBackgroundColor(b and t.bgcolor or t.bgoffcolor)
        tFrame.setTextColor(b and t.fgcolor or t.fgoffcolor)
        for y = 0, t.h - 1 do
          tFrame.setCursorPos(t.x, t.y + y)
          tFrame.write(string.rep(' ', t.w))
        end
        tFrame.setCursorPos(t.x + math.floor(t.w / 2 + 0.5) - math.floor(#t.text / 2 + 0.5), t.y + math.ceil(t.h / 2))
        tFrame.write(t.text)
        t.state = b
      end
    end
  }
  local function hit(self, iX, iY)
    return self.state and iX >= self.x and iX <= self.x + self.w - 1
       and iY >= self.y and iY <= self.y + self.h - 1
  end

  buttons.prev = setmetatable({
    hit        = hit,
    enabled    = does("shop.visual.buttons.prev.enabled",     "Previous button Enabled"),
    x          = does("shop.visual.buttons.prev.x",           "Previous button X"),
    y          = does("shop.visual.buttons.prev.y",           "Previous button Y"),
    w          = does("shop.visual.buttons.prev.w",           "Previous button Width"),
    h          = does("shop.visual.buttons.prev.h",           "Previous button Height"),
    bgcolor    = does("shop.visual.buttons.prev.color.bgOn",  "Previous button background color on"),
    fgcolor    = does("shop.visual.buttons.prev.color.fgOn",  "Previous button text color on"),
    bgoffcolor = does("shop.visual.buttons.prev.color.bgOff", "Previous button background color off"),
    fgoffcolor = does("shop.visual.buttons.prev.color.fgOff", "Previous button text color off"),
    text       = does("shop.visual.buttons.prev.text",        "Previous button Text"),
  }, tMeta)

  buttons.next = setmetatable({
    hit        = hit,
    enabled    = does("shop.visual.buttons.next.enabled",     "Next button Enabled"),
    x          = does("shop.visual.buttons.next.x",           "Next button X"),
    y          = does("shop.visual.buttons.next.y",           "Next button Y"),
    w          = does("shop.visual.buttons.next.w",           "Next button Width"),
    h          = does("shop.visual.buttons.next.h",           "Next button Height"),
    bgcolor    = does("shop.visual.buttons.next.color.bgOn",  "Next button background color on"),
    fgcolor    = does("shop.visual.buttons.next.color.fgOn",  "Next button text color on"),
    bgoffcolor = does("shop.visual.buttons.next.color.bgOff", "Next button background color off"),
    fgoffcolor = does("shop.visual.buttons.next.color.fgOff", "Next button text color off"),
    text       = does("shop.visual.buttons.next.text",        "Next button Text"),
  }, tMeta)
end

local function rAlign(iX, iY, sText)
  iX = math.floor(iX)
  iY = math.floor(iY)
  sText = tostring(sText)
  tFrame.setCursorPos(iX - #sText, iY)
  tFrame.write(sText)
end

local function cutRound(fValue, iDecimal)
  local iMult = 10^iDecimal
  return math.floor(fValue * iMult + 0.5) / iMult
end

local function getNext(tItems, i, bShowEmpty)
  for j = 1, #tItems do
    if tItems[j].show and (tItems[j].count > 0 or (bShowEmpty and tItems[j].count == 0)) then
      i = i - 1
    end
    if i == 0 then
      return j
    end
  end
  return math.huge
end

local function getSelectedItem(tItems, iPage, iSelection)
  if iSelection then
    local iHList = does("shop.visual.itemlist.h", "Item List Max-Per-Page")
    return tItems[(iPage - 1) * iHList + iSelection]
  end
end

local function drawItemList(tItems, iPage, tSelections, bOverride)
  -- legend data
  local iXList = does("shop.visual.itemlist.x", "Item List X")
  local iYList = does("shop.visual.itemlist.y", "Item List Y")
  local iWList = does("shop.visual.itemlist.w", "Item List Width")
  local iHList = does("shop.visual.itemlist.h", "Item List Max-Per-Page")
  local bLegend = does("shop.visual.itemlist.showLegend", "Item List Show-Legend")
  local bShowDomain = does("shop.visual.itemlist.showDomain", "Item List Show Domain")
  local bShortDomain = does("shop.visual.itemlist.shortDomain", "Item List Short Domain")
  local iLegendSpacing = does("shop.visual.itemlist.s", "Item List Spacing")
  -- item list data
  local iFloat = does("shop.visual.itemlist.decimal", "Item List Float")
  local iOddBG = does("shop.visual.itemlist.oddBG", "Item List Shop BG (odd)")
  local iOddFG = does("shop.visual.itemlist.oddFG", "Item List Shop Text (odd)")
  local iEvenBG = does("shop.visual.itemlist.evenBG", "Item List Shop BG (even)")
  local iEvenFG = does("shop.visual.itemlist.evenFG", "Item List Shop Text (even)")

  local iEOddBG = does("shop.visual.itemlist.emptyOddBG", "Item List Shop BG (odd, empty)")
  local iEOddFG = does("shop.visual.itemlist.emptyOddFG", "Item List Shop Text (odd, empty)")
  local iEEvenBG = does("shop.visual.itemlist.emptyEvenBG", "Item List Shop BG (even, empty)")
  local iEEvenFG = does("shop.visual.itemlist.emptyEvenFG", "Item List Shop Text (even, empty)")

  local iSOddBG = does("shop.visual.itemlist.selectOddBG", "Item List Shop BG (odd, select)")
  local iSOddFG = does("shop.visual.itemlist.selectOddFG", "Item List Shop Text (odd, select)")
  local iSEvenBG = does("shop.visual.itemlist.selectEvenBG", "Item List Shop BG (even, select)")
  local iSEvenFG = does("shop.visual.itemlist.selectEvenFG", "Item List Shop Text (even, select)")

  local bShowEmpty = does("shop.visual.itemlist.showEmpty", "Item List Show Empty")

  local sDomain = does("shop.krist.domain", "Krist Domain")

  local fPriceX = iXList + iWList - 1
  local fQuantityX = fPriceX - 5 - iLegendSpacing
  local fDomainX = fQuantityX - 8 - iLegendSpacing

  -- Draw legend (if wanted)
  tFrame.setCursorPos(iXList, iYList)
  if bLegend then
    local cLegendBG = does("shop.visual.itemlist.legendBG", "Item List Legend-BG")
    local cLegendFG = does("shop.visual.itemlist.legendFG", "Item List Legend-Text")
    tFrame.setBackgroundColor(cLegendBG)
    tFrame.setTextColor(cLegendFG)
    tFrame.write(string.rep(' ', iWList))
    tFrame.setCursorPos(iXList + 1, iYList)
    tFrame.write("Item")
    rAlign(fQuantityX, iYList, "Quantity")
    rAlign(fPriceX, iYList, "Price")
    if bShowDomain then
      rAlign(fDomainX, iYList, bShortDomain and string.format("@%s.kst", sDomain) or "Domain")
    end
  end

  -- determine the item to grab
  local iCurrent = (iPage - 1) * iHList

  -- draw item list
  for i = 1, bOverride and 6 or iHList do
    local iPos = getNext(tItems, iCurrent + i, bShowEmpty)
    if iPos <= #tItems then
      local tCItem = tItems[iPos]

      -- check if selected
      local bIsSelected = false
      for j = 1, #tSelections do
        if i == tSelections[j] then
          bIsSelected = true
          break
        end
      end
      if i % 2 == 0 then
        -- even
        if bIsSelected then
          tFrame.setBackgroundColor(iSEvenBG)
          tFrame.setTextColor(iSEvenFG)
        elseif tCItem.count == 0 then
          tFrame.setBackgroundColor(iEEvenBG)
          tFrame.setTextColor(iEEvenFG)
        else
          tFrame.setBackgroundColor(iEvenBG)
          tFrame.setTextColor(iEvenFG)
        end
      else
        -- odd
        if bIsSelected then
          tFrame.setBackgroundColor(iSOddBG)
          tFrame.setTextColor(iSOddFG)
        elseif tCItem.count == 0 then
          tFrame.setBackgroundColor(iEOddBG)
          tFrame.setTextColor(iEOddFG)
        else
          tFrame.setBackgroundColor(iOddBG)
          tFrame.setTextColor(iOddFG)
        end
      end

      -- write info
      local iYPos = iYList - (bLegend and 0 or 1) + i
      -- color the line
      tFrame.setCursorPos(iXList, iYPos)
      tFrame.write(string.rep(' ', iWList))
      -- write the name
      tFrame.setCursorPos(iXList + 1, iYPos)
      tFrame.write(tCItem.displayName)
      -- write the quantity available
      rAlign(fQuantityX, iYPos, tCItem.count)
      -- write the price
      rAlign(fPriceX, iYPos, cutRound(tCItem.price, iFloat))

      if bShowDomain then
        if bShortDomain then
          rAlign(fDomainX, iYPos, tCItem.localname)
        else
          rAlign(fDomainX, iYPos, string.format("%s@%s.kst", tCItem.localname, sDomain))
        end
      end
    end
  end
end

local function UserCode(sText, sChunkName, tEnv, sReturnType)
  if sText == "" then
    return ""
  end
  local fFunc, sErr = load(sText, "User Code:" .. tostring(sChunkName), 't', tEnv or {})
  if not fFunc then
    redrawError(sErr)
  end

  local bOk, returnValue = pcall(fFunc)
  if not bOk then
    redrawError(returnValue)
  end

  if type(returnValue) ~= sReturnType then
    redrawError(string.format(
      "User Code:%s:Expected %s, got %s",
      tostring(sChunkName),
      sReturnType,
      type(returnValue)
    ))
  end
  return returnValue
end

local function drawInfoBox(tSelectedItem)
  if does("shop.visual.infobox.enabled", "Info Box Enabled") then
    local iX        = does("shop.visual.infobox.x", "Info Box X Pos")
    local iY        = does("shop.visual.infobox.y", "Info Box Y Pos")
    local iW        = does("shop.visual.infobox.w", "Info Box Width")
    local iH        = does("shop.visual.infobox.h", "Info Box Height")
    local bCentered = does("shop.visual.infobox.centered", "Info Box Centered")
    local tText     = UserCode(
      readFile(
        fs.combine(
          fs.combine(sAbsoluteDir, ".TampererLongData"),
          does("shop.visual.infobox.text", "Info box text")
        )
      ),
      "Info Box",
      {
        _G = nil,
        math = math,
        string = string,
        table = table,
        item = tSelectedItem and dCopy(tSelectedItem),
        krist = {
          address = does("shop.krist.address", "Krist Address"),
          domain = does("shop.krist.domain", "Krist Domain")
        }
      },
      "table"
    )
    local cBG       = does("shop.visual.infobox.bg", "Info Box BG Color")
    local cFG       = does("shop.visual.infobox.fg", "Info Box Text Color")

    -- draw background
    local sBG = string.rep(' ', iW)
    tFrame.setBackgroundColor(cBG)
    tFrame.setTextColor(cFG)
    for i = 0, iH - 1 do
      tFrame.setCursorPos(iX, iY + i)
      tFrame.write(sBG)
    end
    -- write text
    for i = 0, #tText - 1 do
      local sParsed = tText[i + 1] or ""
      tFrame.setCursorPos(bCentered and iX + math.floor(iW / 2 + 0.5) - math.floor(#sParsed / 2 + 0.5) or iX + 1, iY + i)
      tFrame.write(sParsed)
    end
  end
end

local function drawButtons(tItems, iPage)
  local bShowEmpty = does("shop.visual.itemlist.showEmpty", "Item List Show Empty")
  local iHList     = does("shop.visual.itemlist.h", "Item List Height")
  local iCurrent = (iPage - 1) * iHList
  local bPrev = iPage > 1
  local bNext = true

  for i = 1, iHList do
    if getNext(tItems, iCurrent + i, bShowEmpty) >= #tItems then
      bNext = false
    end
  end

  buttons.prev(bPrev)
  buttons.next(bNext)
end

local function redraw(tItems, iPage, tSelections, bOverride)
  os.queueEvent("redraw")
  initMonitor()

  local cBGColor = does("shop.visual.mainBG", "Main Background Color")
  tFrame.setBackgroundColor(cBGColor)
  tFrame.clear()

  drawItemList(tItems, iPage, tSelections, bOverride)
  drawInfoBox(getSelectedItem(tItems, iPage, tSelections[1]))
  drawButtons(tItems, iPage)

  tFrame.PushBuffer()
end

local function bsod(sErr)
  if tFrame then
    local mX, mY = tFrame.getSize()
    local tLines = line(sErr, mX - 8)

    tFrame.setBackgroundColor(settings.get("shop.visual.bsod.bg") or colors.blue)
    tFrame.clear()

    local bOk, sText = pcall(UserCode,
      readFile(
        fs.combine(
          sAbsoluteDir,
          fs.combine(
            ".TampererLongData",
            settings.get("shop.visual.bsod.custom")
          )
        )
      ),
      "Info Box",
      {
        string = string,
        owner = settings.get("shop.owner")
      },
      "string"
    )

    Bawx(
      tFrame,
      2,
      math.ceil(mY / 2 - tLines.n / 2 + 0.5) - 1,
      mX - 2,
      #tLines + 2,
      settings.get("shop.visual.bsod.bg") or colors.blue,
      settings.get("shop.visual.bsod.fg") or colors.white
    )

    tFrame.setBackgroundColor(settings.get("shop.visual.bsod.bg") or colors.blue)
    tFrame.setTextColor(settings.get("shop.visual.bsod.fg") or colors.white)

    local s = "An unrecoverable error has occured."
    tFrame.setCursorPos(math.ceil(mX / 2 - #s / 2 + 0.5), 1)
    tFrame.write(s)

    for i = 1, #tLines do
      tFrame.setCursorPos(
        math.ceil(mX / 2 - #tLines[i] / 2 + 0.5),
        math.ceil(mY / 2 - #tLines / 2 + 0.5) + i - 1
      )
      tFrame.write(tLines[i])
    end

    if bOk then
      local tCustomLines = line(sText, mX - 8)
      for i = 1, #tCustomLines do
        tFrame.setCursorPos(
          math.ceil(mX / 2 - #tCustomLines[i] / 2 + 0.5),
          mY - #tCustomLines + i
        )
        tFrame.write(tCustomLines[i])
      end
    end
    tFrame.PushBuffer()
  end
end

-- run the options page
local function options()
  local function settingHandler(sFileName, sSetting, NewVal, tPage)
    local bDoRedraw = true
    KristWrap.setEndPoint(settings.get("shop.krist.endpoint"))
    local tDict = {}
    tDict["shop.monitor"] = function()
      bFrameInitialized = false
      tFrame = nil
      if not peripheral.isPresent(NewVal) then
        settings.set("shop.monitor", peripheral.findFirstName("monitor"))
        return true, "Not on the network."
      elseif peripheral.getType(NewVal) ~= "monitor" then
        settings.set("shop.monitor", peripheral.findFirstName("monitor"))
        return true, "Not a monitor."
      end
    end
    tDict["shop.visual.monitorScale"] = tDict["shop.monitor"]
    tDict["shop.krist.hash"] = function()
      if NewVal == "" then
        settings.set("shop.krist.address", "kxxxxxxxx")
      else
        local sAddress, err = KristWrap.getV2Address(NewVal)
        if not sAddress then
          return true, "Krist connection failure."
        end
        settings.set("shop.krist.address", sAddress)
      end
    end
    tDict["shop.krist.address"] = function()
      local hash = settings.get("shop.krist.hash")
      local sAddress, err
      if hash then
        sAddress, err = KristWrap.getV2Address(settings.get("shop.krist.hash"))
        if not sAddress then
          return true, "Krist connection failure."
        end
      else
        sAddress = "kxxxxxxxx"
      end
      settings.set("shop.krist.address", sAddress)
      return true, "Set automatically."
    end
    tDict["shop.visual.infobox.text"] = function()
      local bOk, sErr = pcall(UserCode,
        readFile(
          fs.combine(
            sAbsoluteDir,
            fs.combine(
              ".TampererLongData",
              settings.get(sSetting)
            )
          )
        ),
        "Info Box",
        {
          _G = nil,
          math = math,
          string = string,
          table = table,
          krist = {
            address = does("shop.krist.address", "Krist Address"),
            domain = does("shop.krist.domain", "Krist Domain")
          }
        },
        "table"
      )

      if not bOk then
        return true, "Check monitor."
      end
    end
    tDict["shop.items.dispenseFromTurtle"] = function()
      if NewVal == true and not turtle then
        settings.set("shop.items.dispenseFromTurtle", false)
        return true, "Not a turtle."
      end
    end
    tDict["shop.items.dispenseDir"] = function()
      -- "up", "forward", "down" or "nesw/ud"
      local tDirs = {
        t = {"up", "forward", "down"},
        nt = {"north", "east", "south", "west", "up", "down"}
      }
      if settings.get("shop.items.dispenseFromTurtle") then
        if not IsIn(tDirs.t, NewVal) then
          settings.set("shop.items.dispenseDir", "forward")
          return true, "Invalid direction."
        end
      else
        if not IsIn(tDirs.nt, NewVal) then
          settings.set("shop.items.dispenseDir", "up")
          return true, "Invalid direction."
        end
      end
    end
    tDict["shop.items.dispenseFrom"] = function()
      local tPeriphs = Storage.GetPeripherals()
      if not IsIn(tPeriphs, NewVal) then
        settings.set("shop.items.dispenseFrom", tPeriphs[1])
        return true, "No storage."
      end
    end
    tDict["shop.krist.domain"] = function()
      if NewVal ~= "" then
        local tDomainInfo, sErr = KristWrap.getName(NewVal)
        if tDomainInfo and tDomainInfo.ok then
          if tDomainInfo.name and tDomainInfo.name.owner ~= settings.get("shop.krist.address") then
            settings.set("shop.krist.domain", "")
            return true, "Not owner of domain."
          end
        else
          if tDomainInfo then
            if tDomainInfo.error == "domain_not_found" then
              settings.set("shop.krist.domain", "")
              return true, "Domain not found."
            end
          end
          settings.set("shop.krist.domain", "")
          return true, sErr or tDomainInfo and tDomainInfo.error or "Unknown Error."
        end
      end
    end
    tDict["shop.visual.bsod.custom"] = function()
      local bOk, sErr = pcall(UserCode,
        readFile(
          fs.combine(
            sAbsoluteDir,
            fs.combine(
              ".TampererLongData",
              settings.get(sSetting)
            )
          )
        ),
        "Info Box",
        {
          string = string,
          owner = settings.get("shop.owner")
        },
        "string"
      )

      if not bOk then
        bsod(sErr)
        bDoRedraw = sErr
        return true, "Check monitor."
      end
    end

    local bRet1, sRet2, nnRet3

    if tDict[sSetting] then
      bRet1, sRet2, nnRet3 = tDict[sSetting]()
    elseif sSetting:match("^shop%.visual%.palette") then
      bFrameInitialized = false
      tFrame = nil
      local sColor = sSetting:match("^shop%.visual%.palette%.(.-)%.")
      local sFormat = string.format("shop.visual.palette.%s.%%s", sColor)
      if sSetting:match("palette%..-%.hex") then
        -- hex value updated, update RGBs
        local iR, iG, iB = colors.unpackRGB(settings.get(sSetting))
        settings.set(string.format(sFormat, 'r'), iR * 255)
        settings.set(string.format(sFormat, 'g'), iG * 255)
        settings.set(string.format(sFormat, 'b'), iB * 255)
      else
        -- r/g/b value updated, update hex
        settings.set(
          string.format(sFormat, 'hex'),
          colors.rgb8(
            settings.get(string.format(sFormat, 'r')) / 255,
            settings.get(string.format(sFormat, 'g')) / 255,
            settings.get(string.format(sFormat, 'b')) / 255
          )
        )
      end
    end

    settings.save(sFileName)

    if tFrame then
      defineDefault("shop.visual.dots.update.y", ({tFrame.getSize()})[2])
    end
    initDots()
    initButtons()

    if bDoRedraw == true then
      local ok, err = pcall(
        redraw,
        {
          {stackSize = 64, count = 1, localname = "odd", displayName = "Odd", price = 1.2345678901234567890, damage = 0, show = true},
          {stackSize = 64, count = 1, localname = "even", displayName = "Even", price = 1.2345678901234567890, damage = 0, show = true},
          {stackSize = 64, count = 0, localname = "odde", displayName = "Odd Empty", price = 1.2345678901234567890, damage = 0, show = true},
          {stackSize = 64, count = 0, localname = "evne", displayName = "Even Empty", price = 1.2345678901234567890, damage = 0, show = true},
          {stackSize = 64, count = 1, localname = "odds", displayName = "Odd Selected", price = 1.2345678901234567890, damage = 0, show = true},
          {stackSize = 64, count = 1, localname = "evns", displayName = "Even Selected", price = 1.2345678901234567890, damage = 0, show = true},
        },
        1,
        {5, 6},
        true
      )
      if tFrame then
        for k, v in pairs(dots) do
          v(true)
        end
        for k, v in pairs(buttons) do
          v(true)
        end
        tFrame.PushBuffer()
      end

      if not ok then
        pcall(bsod, err)
      end
    else
      pcall(bsod, bDoRedraw)
    end
    if type(bDoRedraw) == "string" then
      tFrame.clear()
      tFrame.setCursorPos(1, 1)
      tFrame.write(bDoRedraw)
    end

    return bRet1, sRet2, nnRet3
  end

  local tTamp = Tamperer.loadFile(tFiles.OptionsMenu.name)()

  local tPalette = Tamperer.getSubPage(tTamp, "Palette")

  local tInit = dCopy(tPalette.subPages[1])

  local function replace(t, sWith)
    for k, v in pairs(t) do
      if type(v) == "string" then
        t[k] = v:gsub("COLOR", sWith)
      elseif type(v) == "table" then
        replace(t[k], sWith)
      end
    end
  end
  for i = 0, 15 do
    local tTemp = dCopy(tInit)
    replace(tTemp, colors[2^i])
    tPalette.subPages[i + 1] = tTemp
  end

  Tamperer.display(tTamp, settingHandler)
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
          bigInfo = string.format("Set to true to update the module %15s.", sModule)
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
local function mainMenu(bGetUpdates)
  -- load the page (the same way tamperer does)
  local fLoad, err = load("return " .. readFile(tFiles.MainMenu.name))

  -- if no errors
  if fLoad then
    -- turn the page into a table
    local tMenu = fLoad()
    -- check for updates
    local tUpdates = {n = 0}
    if bGetUpdates and not args.no_update_check then
      tUpdates = checkUpdates()
    end
    if args.immediate then
      args.immediate = false
      return true, tUpdates.n > 0
    end

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
        return true,
               tUpdates.n > 0
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
        return false
      end
    end
  else
    printError("Failed to load the main menu.")
    error(string.format("Failed to load the main menu.\n%s", err), 0)
  end
end



local function parseMeta(sMeta)
  local tMeta = {ArrayMeta = {n = 0}}

  local sDomainMatch = "^(.+)@(.+)%.kst$"
  local sEqualsMatch = "^(.+)=(.+)$"

  for line in sMeta:gmatch("[^;]+") do
    if line:match(sDomainMatch) and not line:match(sEqualsMatch) then
      tMeta.localname, tMeta.domain = line:match(sDomainMatch)
    elseif line:match(sEqualsMatch) then
      local _1, _2 = line:match(sEqualsMatch)
      if _2 == "true" then
        _2 = true
      elseif _2 == "false" then
        _2 = false
      end
      tMeta[_1] = _2
    else
      tMeta.ArrayMeta.n = tMeta.ArrayMeta.n + 1
      tMeta.ArrayMeta[tMeta.ArrayMeta.n] = line
    end
  end

  return tMeta
end

local function refundKrist(sFrom, nAmount, tMeta, sRefundMeta)
  if nAmount < 1 then
    return
  end
  sRefundMeta = sRefundMeta or "error=Unknown error occured."
  local sTo = sFrom

  if tMeta["return"] then
    sTo = tMeta["return"]
  end

  KristWrap.makeTransaction(sTo, nAmount, sRefundMeta)
end

local function shop(bUpdates)
  local tItems = {}
  local iPage = 1
  local bAllowRedrawing = true
  local iSelection
  initMonitor()
  initDots()
  initButtons()

  local function dotHandler()
    local dotlog = Logger("Dot")
    local iPurchaseTimer
    local bPurchaseOn = false
    local iRedrawTimer
    local bRedrawOn = false
    local iUserTimer
    local bUserOn = false
    local iUpdateTimer
    local bUpdateOn = false
    if bUpdates then
      iUpdateTimer = os.startTimer(dots.update.time)
    else
      dots.update.enabled = false
    end
    while true do
      local tEvent = table.pack(os.pullEvent())
      if tEvent[1] == "timer" then
        local iTimer = tEvent[2]
        if iTimer == iUserTimer then
          bUserOn = false
        elseif iTimer == iRedrawTimer then
          bRedrawOn = false
        elseif iTimer == iPurchaseTimer then
          bPurchaseOn = false
        elseif iTimer == iUpdateTimer then
          bUpdateOn = not bUpdateOn
          iUpdateTimer = os.startTimer(dots.update.time)
        end
      elseif tEvent[1] == "monitor_touch" then
        iUserTimer = os.startTimer(dots.userInput.time)
        bUserOn = true
      elseif tEvent[1] == "redraw" then
        iRedrawTimer = os.startTimer(dots.redraw.time)
        bRedrawOn = true
      elseif tEvent[1] == "purchase" then
        iPurchaseTimer = os.startTimer(dots.purchase.time)
        bPurchaseOn = true
      end
      if tEvent[1] == "timer" or tEvent[1] == "monitor_touch"
        or tEvent[1] == "redraw" or tEvent[1] == "purchase" then
        dots.purchase(bPurchaseOn)
        dots.userInput(bUserOn)
        dots.redraw(bRedrawOn)
        dots.update(bUpdateOn)
        tFrame.PushBuffer()
      end
    end
  end

  local function inventoryHandler()
    local invlog = Logger("Inventory")
    KristWrap.Initialized:Wait()
    tItems = dCopy(tCache)
    tItems.n = #tItems
    for i = 1, tItems.n do
      Storage.CountItems(tItems)
    end
    os.queueEvent("_redraw")

    -- main loop
    while true do
      Storage.CountItems(tItems)
      os.sleep(10)
    end
  end

  local function userHandler()
    local userlog    = Logger("User")
    local sMon       = does("shop.monitor",                      "Shop monitor")
    local iListSkip1 = does("shop.visual.itemlist.showLegend",   "Item List Show Legend")
    local iListX     = does("shop.visual.itemlist.x",            "Item List X")
    local iListY     = does("shop.visual.itemlist.y",            "Item List Y")
    local iListW     = does("shop.visual.itemlist.w",            "Item List Width")
    local iListH     = does("shop.visual.itemlist.h",            "Item List Height")
    local iTime      = does("shop.visual.itemlist.deselectTime", "Item List Deselect Timer")
    local iSelectionTimer

    local function hitList(iX, iY)
      if iX >= iListX and iX <= iListX + iListW - 1 and
         iY >= iListY + (iListSkip1 and 1 or 0) and iY <= iListY + (iListSkip1 and 1 or 0) + iListH - 1 then
        return iY - (iListY - (iListSkip1 and 0 or 1))
      end
    end

    while true do
      local sEvent, sMonitor, iX, iY = os.pullEvent()
      if sEvent == "monitor_touch" then
        if sMonitor == sMon then
          iSelectionTimer = os.startTimer(iTime)
          if buttons.prev:hit(iX, iY) then
            iPage = iPage - 1
            os.queueEvent("_redraw")
          elseif buttons.next:hit(iX, iY) then
            iPage = iPage + 1
            os.queueEvent("_redraw")
          else
            iSelection = hitList(iX, iY)
            os.queueEvent("_redraw")
          end
        end
      elseif sEvent == "timer" and iSelectionTimer == sMonitor then
        iSelection = nil
        os.queueEvent("_redraw")
      end
    end
  end

  local function kristHandler()
    local kristLog = Logger("Krist")
    parallel.waitForAny(function()
      -- connect to the endpoint
      KristWrap.setEndPoint(does("shop.krist.endpoint", "Krist Endpoint"))
      kristLog("KristWrap", "Starting main coroutine.", 1)
      KristWrap.run({"transactions"}, does("shop.krist.hash", "KristWallet Password (hashed)"))
    end,
    function()
      -- wait for initialization
      KristWrap.Initialized:Wait()
      kristLog("KristWrap", "Initialized.")

      sAddress = does("shop.krist.address", "Shop krist address")
      local doTurtleDispensing = does("shop.items.dispenseFromTurtle", "Item dispensed from turtle?")
      local dispenseDir = does("shop.items.dispenseDir", "Item dispense direction")
      local sDomain = does("shop.krist.domain", "Krist domain")

      if sDomain ~= "" then
        local tDomainInfo, sErr = KristWrap.getName(sDomain)
        if tDomainInfo and tDomainInfo.ok then
          if tDomainInfo.name and tDomainInfo.name.owner ~= sAddress then
            error(string.format("Krist domain '%s' is not registered to address '%s'.", sDomain, sAddress), 0)
          end
        else
          if tDomainInfo then
            if tDomainInfo.error == "domain_not_found" then
              error(string.format("Krist domain '%s' is not registered on the endpoint.", sDomain), 0)
            end
          end
          error(tDomainInfo and tDomainInfo.error or sErr, 0)
        end
      end

      local drop

      if doTurtleDispensing then
        if not turtle then
          error("Cannot drop from self if we are not a turtle!")
        end
        local dropFunc
        if dispenseDir == "up" then
          dropFunc = turtle.dropUp
        elseif dispenseDir == "forward" then
          dropFunc = turtle.drop
        elseif dispenseDir == "down" then
          dropFunc = turtle.dropDown
        else
          error("Turtles cannot dispense in direction '" .. tostring(dispenser) .. "'.")
        end
        drop = function()
          for i = 1, 16 do
            if turtle.getItemCount(i) > 0 then
              turtle.select(i)
              dropFunc()
            end
          end
        end
      else
        local dispenser = does("shop.items.dispenseFrom", "Item dispense peripheral")
        if peripheral.isPresent(dispenser) then
          local sides = {"north", "east", "south", "west", "up", "down"}
          local ok = false
          for i = 1, #sides do
            if dispenseDir == sides[i] then
              local size = peripheral.call(dispenser, "size")
              if not size then error("Dispenser peripheral has unidentifiable size.") end
              drop = function()
                for i = 1, size do
                  peripheral.call(dispenser, "drop", i, nil, dispenseDir)
                end
              end
              ok = true
              break
            end
          end
          if not ok then
            error("Unknown dispenser direction '" .. tostring(dispenseDir) .. "'.")
          end
        else
          error("Dispenser peripheral does not exist!")
        end
      end

      -- Grab the items
      local function dispense(tItem, nCount)
        local nDispensed = Storage.GrabItems(doTurtleDispensing and peripheral.call(modemSide, "getNameLocal") or dispenser, tItem.name, tItem.damage, tItem.nbtHash, nCount, tItem.sortByNbt)
        drop()

        log("Dispenser", string.format("Dispensed %d, Requested %d", nDispensed, nCount), nDispensed == nCount and 1 or 3)
      end

      local function Forward(tItem, nValue, nRefund, tFrom, nItemsGiven, bIsDonation)
        if does("shop.krist.doPurchaseForwarding", "Enable Krist Purchase Forwarding") then
          local sTo = does("shop.krist.purchaseForwardingAddress", "Krist Purchase Forwarding Address")
          local sMeta = does("shop.krist.purchaseForwardingMeta", "Krist Purchase Forwarding Metadata")
          local bOk, sText = pcall(UserCode,
            readFile(
              fs.combine(
                sAbsoluteDir,
                fs.combine(
                  ".TampererLongData",
                  settings.get("shop.krist.purchaseForwardingMeta")
                )
              )
            ),
            "Purchase Forwarding Metadata",
            {
              _G = nil,
              math = math,
              string = string,
              table = table,
              item = tItem,
              itemsGiven = nItemsGiven,
              value = nValue,
              refunded = nRefund,
              from = tFrom,
              isDonation = bIsDonation,
              krist = {
                address = does("shop.krist.address", "Krist Address"),
                domain = does("shop.krist.domain", "Krist Domain")
              }
            },
            "string"
          )

          KristWrap.makeTransaction(sTo, nValue - nRefund, sText)
        end
      end

      local function Purchase(tItem, tMeta, sFrom, sTo, nValue)
        local nItemsToGrab = math.floor(nValue / tItem.price)

        if nItemsToGrab < 1 then
          -- Not enough krist for one item!
          refundKrist(
            sFrom,
            nValue,
            tMeta,
            string.format("error=You need to send at least %d krist to buy that.", tItem.price)
          )
        elseif tItem.count == 0 then
          refundKrist(
            sFrom,
            nValue,
            tMeta,
            "error=Sorry, we don't have any of that item."
          )
        else
          -- Enough krist for one item!
          local nOver = nValue % tItem.price
          local sOverageReason = "You overpaid a little"
          if nItemsToGrab > tItem.count then
            nOver = nOver + (nItemsToGrab - tItem.count) * tItem.price
            nItemsToGrab = tItem.count
            sOverageReason = "We didn't have enough items to complete your purchase and/or you overpaid a little"
          end
          nOver = math.floor(nOver)

          -- Refund if overpay.
          if nOver > 0 then
            refundKrist(
              sFrom,
              nOver,
              tMeta,
              string.format("message=%s, here's your change!", sOverageReason)
            )
          end

          -- Dispense the item
          dispense(tItem, nItemsToGrab)

          -- If purchase forwarding enabled, forward the krist earned to the specified address.
          Forward(tItem, nValue, nOver, sFrom, nItemsToGrab, false)
        end
      end

      -- run the shop
      while true do
        local sFrom, sTo, nValue, sMeta = KristWrap.Transaction:Wait()
        KristWrap.setQueueEnabled(true)
        if sTo == sAddress then
          -- The transaction was sent to us
          local tMeta, tMetaError, err = parseMeta(sMeta)
          if tMetaError then
            -- There was an error parsing metadata, return krist as well as we can.
            refundKrist(sFrom, nValue, tMetaError, "error=" .. err)
          else
            -- Metadata OK.
            if tMeta.donate or tMeta.donation or IsIn(tMeta.ArrayMeta, "donate") or IsIn(tMeta.ArrayMeta, "donation") then
              -- Donation, do nothing.
              plog.info(string.format("Received donation of %d kst.", nValue))
              Forward({displayName = "Donation", price = nValue}, nValue, 0, sFrom, 1, true)
            else
              -- Not a donation, must be a purchase.
              if tMeta.domain and tMeta.localname then
                if tMeta.domain == sDomain then
                  local bSent = false
                  for i = 1, tItems.n do
                    if tItems[i].localname == tMeta.localname and tItems[i].show then
                      if tMeta.query or IsIn(tMeta.ArrayMeta, "query") then
                        refundKrist(
                          sFrom,
                          nValue,
                          tMeta,
                          "message=Now displaying extra info about that item."
                        )
                        bAllowRedrawing = false
                        redraw({tItems[i]}, 1, {1})
                        local iTimer = os.startTimer(6)
                        while true do
                          local _, _iTimer = os.pullEvent "timer"
                          if iTimer == _iTimer then
                            break
                          end
                        end

                        bAllowRedrawing = true
                        os.queueEvent("_redraw")
                      else
                        Purchase(tItems[i], tMeta, sFrom, sTo, nValue)
                      end
                      bSent = true
                      break
                    end
                  end
                  if not bSent then
                    refundKrist(sFrom, nValue, tMeta, string.format(
                      "error=localname '%s' refers to no item sold in the shop.",
                      tMeta.localname
                    ))
                  end
                else
                  refundKrist(sFrom, nValue, tMeta, string.format(
                    "error=Domain '%s' is not registered to this shop.",
                    tMeta.domain
                  ))
                end
              elseif iSelection then
                -- Item *is* selected, try to retrieve as many as was wanted.
                local tItem = getSelectedItem(tItems, iPage, iSelection)
                if tItem then
                  Purchase(tItem, tMeta, sFrom, sTo, nValue)
                else
                  refundKrist(sFrom, nValue, tMeta, "error=No item is selected!")
                end
              else
                -- No item selected! Return krist to the user.
                refundKrist(sFrom, nValue, tMeta, "error=No item is selected!")
              end
            end
          end
        end
        KristWrap.setQueueEnabled(false)
      end
    end)
  end

  local function _redraw()
    local shoplog = Logger("Redraw")
    local iTimer
    tFrame.setBackgroundColor(colors.black)
    tFrame.setTextColor(colors.white)
    tFrame.clear()
    tFrame.setCursorPos(2, 1)
    tFrame.write("Initializing...")
    tFrame.PushBuffer()
    while true do
      local tEvent = table.pack(os.pullEvent())
      if tEvent[1] == "_redraw" then
        if bAllowRedrawing then
          redraw(tItems, iPage, {iSelection})
          local x, y = tFrame.getSize()
          tFrame.setCursorPos(x - 3, y)
          tFrame.setBackgroundColor(colors.black)
          tFrame.setTextColor(colors.red)
          tFrame.write("BETA")
          tFrame.PushBuffer()
        end
        iTimer = os.startTimer(5)
      elseif tEvent[1] == "timer" and tEvent[2] == iTimer then
        os.queueEvent("_redraw")
      end
    end
  end

  local ok, err = pcall(parallel.waitForAny, _redraw, dotHandler, inventoryHandler, userHandler, kristHandler)
  if not ok and err == "Terminated" then
    tFrame.setBackgroundColor(colors.black)
    tFrame.clear()
    tFrame.setCursorPos(2, 1)
    tFrame.write("Stopped...")
    tFrame.PushBuffer()
    return true
  elseif not ok then
    printError(err)
  end
  error("A main coroutine has stopped unexpectedly. (" .. tostring(err) .. ")")
end

local function main()
  local bNotUpdated = true
  repeat
    local bOk, bUpdates = mainMenu(bNotUpdated)
    bNotUpdated = false
    if bOk then
      local bTerminate
      parallel.waitForAny(
        function()
          bTerminate = shop(bUpdates)
        end,
        function()
          Tamperer.display({
            name = "Shop running",
            info = "",
            bigInfo = "",
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
            platform = "all",
            final = "Stop"
          })
        end
      )

      if bTerminate then
        return
      end
    end
  until not bOk
end

settings.load(".shopSettings")
defineSettings()

Logger.setMasterLevel(does("shop.logger.level", "Logger Level"))

while true do
  local bOk, sErr = xpcall(main, debug.traceback)
  if bOk then
    break
  else
    log.err(sErr:match("[^\n]+"))

    term.setTextColor(colors.white)
    term.setBackgroundColor(colors.black)
    term.clear()
    term.setCursorPos(1, 1)
    printError(sErr:match("[^\n]+"))
    printError("A stack traceback is available in the latest logfile.")
    --TODO: Bluescreen
    if sErr:match("[^\n]+") ~= "Terminated" then
      for sLine in sErr:gmatch("[^\n]+") do
        log("Traceback", sLine)
      end
      bsod( sErr:match("[^\n]+"))
      break
    end
  end
end

Logger.close()
if not does("shop.logger.saveold", "Logger Enabled") then
  fs.delete(fs.combine(sAbsoluteDir, "data/.templog"))
  fs.copy(fs.combine(sAbsoluteDir, "logs/LATEST.log"), fs.combine(sAbsoluteDir, "data/.templog"))
  fs.delete(fs.combine(sAbsoluteDir, "logs"))
  fs.makeDir(fs.combine(sAbsoluteDir, "logs"))
  fs.move(fs.combine(sAbsoluteDir, "data/.templog"), fs.combine(sAbsoluteDir, "logs/LATEST.log"))
  fs.delete(fs.combine(sAbsoluteDir, "data/.templog"))
end
