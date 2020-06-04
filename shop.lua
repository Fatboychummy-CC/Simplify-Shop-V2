local debug = true
local expect = require("cc.expect").expect


--##############################################################
-- Initial setup stuff, so we can download dependencies we need
--##############################################################
local sAbsoluteDir = "/" .. shell.dir() .. "/"
local sSelfLocation = "https://raw.githubusercontent.com/Fatboychummy-CC/Simplify-Shop-V2/master/shop.lua"
local sSelfName = sAbsoluteDir .. "shop.lua"
local smd5Location = "https://raw.githubusercontent.com/kikito/md5.lua/master/md5.lua"
local smd5Name = sAbsoluteDir .. "modules/md5.lua"
local sTampererLocation = "https://raw.githubusercontent.com/Fatboychummy-CC/Tamperer/master/minified.lua"
local sTampererName = sAbsoluteDir .. "modules/Tamperer.lua"
local sFrameLocation = "https://raw.githubusercontent.com/Fatboychummy-CC/Frame/master/Frame.lua"
local sFrameName = sAbsoluteDir .. "modules/Frame.lua"
local sLoggerLocation = "https://raw.githubusercontent.com/Fatboychummy-CC/Compendium/master/modules/core/logger.lua"
local sLoggerName = sAbsoluteDir .. "modules/Logger.lua"
local sMainMenuLocation = "https://raw.githubusercontent.com/Fatboychummy-CC/Simplify-Shop-V2/master/data/main.lson"

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
checkAndDownload(smd5Name, smd5Location)
checkAndDownload(sFrameName, sFrameLocation)
checkAndDownload(sTampererName, sTampererLocation)
checkAndDownload(sLoggerName, sLoggerLocation)

local md5 = require "modules.md5"
local Frame = require "modules.Frame"
local Tamperer = require "modules.Tamperer"
local Logger = require "modules.Logger"
local log = Logger("Shop")
