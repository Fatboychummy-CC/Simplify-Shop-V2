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

-- update checker
-- returns a table of boolean values.
local function checkUpdates()
  print("Checking for updates...")
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
    end
  end
  return tCheck
end

-- define some default settings
local function defineSettings()
  settings.define("shop.autorun", {type = "number", default = 15})
end

-- run the options page
local function options()
  defineSettings()
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
        -- exit
        break
      end
    end
  else
    printError("Failed to load the main menu.")
    error(err, 0)
  end
end

mainMenu()

Logger.close()
