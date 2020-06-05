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

local md5 = require "modules.md5"
local Frame = require "modules.Frame"
local Tamperer = require "modules.Tamperer"
local Logger = require "modules.Logger"
local log = Logger("Shop")

local function checkUpdates()
  print("Checking for updates...")
  log.info("Checking for updates...")

  local function checkSingleUpdate(tData)
    local sLocalHash = md5.sum(readFile(tData.name))
    local sRemoteHash = md5.sum(getFile(tData.location))
    if sLocalHash ~= sRemoteHash then
      return true
    end
    return false
  end

  local tCheck = {n = 0}
  for sModule, tData in pairs(tFiles) do
    local bVal = checkSingleUpdate(tData)
    tCheck[sModule] = bVal
    if bVal then
      tCheck.n = tCheck.n + 1
    end
  end
  return tCheck
end

local function options()
end

local function updater(tUpdates)
end

local function mainMenu()
  local fLoad, err = load("return " .. readFile(tFiles.MainMenu.name))

  if fLoad then
    local tMenu = fLoad()
    local tUpdates = checkUpdates()
    tMenu.selections[2].info = tUpdates.n == 1 and "1 update available"
                              or string.format("%d updates available", tUpdates.n)
    tMenu.selections[2].bigInfo = tUpdates.n == 0 and "There are no updates available at this time."
                              or tUpdates.n == 1 and "There is one update available at this time."
                              or string.format("There are %d updates available at this time.", tUpdates.n)

    local iSelection = Tamperer.display(tMenu, nil, 15)
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
    end
  else
    printError("Failed to load the main menu.")
    error(err, 0)
  end
end
