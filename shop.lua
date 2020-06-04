local debug = true
local expect = require("cc.expect").expect

local smd5Location = "https://raw.githubusercontent.com/kikito/md5.lua/master/md5.lua"
local sTampererLocation = "https://raw.githubusercontent.com/Fatboychummy-CC/Tamperer/master/minified.lua"
local sFrameLocation = "https://raw.githubusercontent.com/Fatboychummy-CC/Frame/master/Frame.lua"
local sLoggerLocation = "https://raw.githubusercontent.com/Fatboychummy-CC/Compendium/master/modules/core/logger.lua"

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

if not fs.exists("/md5.lua") then
  print("Installing initial md5 file.")
  writeFile("/md5.lua", getFile(smd5Location))
end

if not fs.exists("/Frame.lua") then
  print("Installing initial Frame file.")
  writeFile("/Frame.lua", getFile(sFrameLocation))
end

if not fs.exists("/Tamperer.lua") then
  print("Installing initial Tamperer file.")
  writeFile("/Tamperer.lua", getFile(sTampererLocation))
end

if not fs.exists("/Logger.lua") then
  print("Installing initial logger file.")
  writeFile("/Logger.lua", getFile(sLoggerLocation))
end

local md5 = require "md5"
local Frame = require "Frame"
local Tamperer = require "Tamperer"
local Logger = require "Logger"
local log = Logger("Shop")
