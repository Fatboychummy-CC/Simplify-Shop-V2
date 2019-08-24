--[[
0

]]

--[[
This program uses os.sleep() during boot to allow the user some time to skim
information as it scrolls by.

It is not meant as a "fake loading time" thing.
]]

-- requires

local smenus = require("modules.menus.layouts.simple")
local imenus = require("modules.menus.layouts.insert")
local qmenus = require("modules.menus.layouts.questions")
local cache = require("modules.item.cache")
local bsod = require("modules.etc.bsod")
local monitor = require("modules.etc.monitor")
local ep = require("modules.etc.extraPeripherals")
local fileGrab = require("modules.http.fileGrabby")
local shop = require("modules.shop.main")
local _ = require("modules.etc.typer")

local modules = {
  smenus,
  imenus,
  qmenus,
  cache,
  bsod,
  monitor,
  ep,
  fileGrab,
  shop
}

-- miniinit
local build = 0
local mon
local settingsLocation = "/.shopsettings"


-- shop settings.
local sets = {
  "shop.shopName",
  "shop.shopOwner",
  "shop.refreshRate",
  "shop.dataLocation",
  "shop.cacheSaveName",
  "shop.logLocation",
  "shop.rebootTime",
  "shop.autorun",
  "shop.autorunTime",
  -- monitor
  "shop.monitor.monitor",
  "shop.monitor.textScale",
  -- shop listings
  "shop.listing.enabled",
  "shop.listing.decimalPlaces",
  "shop.listing.leftStop",
  "shop.listing.rightStop",
  "shop.listing.topStop",
  "shop.listing.maxItemsPerPage",
  -- shop information box
  "shop.info.enabled",
  "shop.info.centered",
  "shop.info.bgcolor",
  "shop.info.fgcolor",
  "shop.info.leftStop",
  "shop.info.rightStop",
  "shop.info.topStop",
  "shop.info.bottomStop",
  "shop.info.line1",
  "shop.info.line2",
  "shop.info.line3",
  "shop.info.line4",
  "shop.info.line5",
  -- krist
  "shop.krist.password",
  "shop.krist.address",
  defaults = {
    "Unnamed Shop",
    "Unknown",
    10,
    "/data",
    "/data/cache.ic",
    "/data/logs",
    30,
    true,
    5,
    -- monitor
    "FIX ME PLS EEEEE", -- no it doesn't actually need to be fixed
                        -- the shop does this automatically, no matter what this
                        -- is set to.
    0.5,
    -- shop listings
    true,
    2,
    1,
    25,
    1,
    6,
    -- shop information box
    true,
    false,
    colors.gray,
    colors.white,
    1,
    30,
    9,
    14,
    "Simplify Shop V2",
    "Created by Fatboychummy",
    "Change these by going to",
    "options>Info Box>lines",
    "",
    -- krist
    "1",
    "kkkkkkkk"
  }
}

----------------------------------------------------------
-- func:    checkFiles
-- inputs:  none
-- returns: nil
-- info:    checks for missing files, downloads them if
--          necessary.
----------------------------------------------------------
local function checkFiles()
  local function cad(tp, ...) -- check and download
    local fileInfo = {...}
    local name = fileInfo[1]
    print("Checking for " .. name .. '.')
    if not fs.exists(name) then
      print("File is missing.  Downloading.")
      os.sleep(0.2)
      if tp == "http" then
        fileGrab.get(fileInfo[2], name)
      elseif tp == "pastebin" then
        fileGrab.pastebin(fileInfo[2], name)
      elseif tp == "github" then
        fileGrab.github(
          fileInfo[2], fileInfo[3], fileInfo[4], fileInfo[5], name
        )
      end
    else
      print("File is ok.")
      os.sleep(0.2)
    end
  end

  local tpm = "tmpim"
  local mst = "master"

  cad("pastebin", "json.lua", "4nRg9CHU")
  cad("github", "jua.lua", tpm, "Jua", mst, "jua.lua")
  cad("github", "w.lua", tpm, "w.lua", mst, "w.lua")
  cad("github", "r.lua", tpm, "r.lua", mst, "r.lua")
  cad("github", "k.lua", tpm, "k.lua", mst, "k.lua")
end

----------------------------------------------------------
-- func:    checkSettings()
-- inputs:  none
-- returns: nil
-- info:    Loops through the list of settings and the defaults.
--          If a setting is missing, then it is set to it's default.
----------------------------------------------------------
local function checkSettings()
  for i = 1, #sets do
    if type(settings.get(sets[i])) == "nil" then
      print("Missing settings value:", sets[i])
      os.sleep(0.2)
      settings.set(sets[i], sets.defaults[i])
      settings.save(settingsLocation)
    end
  end
end

----------------------------------------------------------
-- func:    updateCheck
-- inputs:  none
-- returns: isUpdate|boolean
-- info:    checks for updates, if there is an update,
--          returns true, else false.
----------------------------------------------------------
local function updateCheck()
  --TODO: finish this.
end

----------------------------------------------------------
-- func:    updateCheckString
-- inputs:  none
-- returns: updates|string
-- info:    runs updateCheck, then returns a string based on what was returned.
----------------------------------------------------------
local function updateCheckString()
  --TODO: call updateCheck and return a string depending on what is returned.
  return "No updates available."
end

----------------------------------------------------------
-- func:    notify
-- inputs:  any
-- returns: nil
-- info:    loops through modules, checks if they have a notify function.
--          If so, runs notify with the inputs to this function
----------------------------------------------------------
local function notify(...)
  local args = {...}
  -- notify modules
  for i, module in ipairs(modules) do
    local tp, stp = type(module)
    if tp == "table" or tp == "module" then
      if type(module.notify) == "function" then
        module.notify(table.unpack(args))
        settings.save(settingsLocation)
      end
    end
  end

  -- Also updates "ourself" by notifying ourself
  if args[1] == "settings_update" then
    if args[2] == "shop.monitor.monitor"
        or args[2] == "shop.monitor.textScale" then
      mon = peripheral.wrap(settings.get("shop.monitor.monitor"))

      if type(mon) ~= "table" then
        local monName = peripheral.findString("monitor")[1]
        mon = peripheral.wrap(monName)
        settings.set("shop.monitor.monitor", monName)
      end

      local scale = settings.get("shop.monitor.textScale")
      if scale > 4 then
        settings.set("shop.monitor.textScale", 4)
      elseif scale < 0.5 then
        settings.set("shop.monitor.textScale", 0.5)
      end

      settings.save(settingsLocation)
      monitor.setupMonitor(mon)
    end
  end
end

----------------------------------------------------------
-- func:    mainMenu
-- inputs:  none
-- returns: nil
-- info:    runs the 'title screen' menu
----------------------------------------------------------
local mainMenu = require("modules.menus.mainMenu")

----------------------------------------------------------
-- func:    optionsMenu
-- inputs:  none
-- returns: nil
-- info:    runs the menu where you can change settings.
----------------------------------------------------------
local optionsMenu = require("modules.menus.optionsMenu")

----------------------------------------------------------
-- func:    errorMenu
-- inputs:  err: error|string
-- returns: selected|number
-- info:    displays the error menu, after an error occurs.
----------------------------------------------------------
local errorMenu = require("modules.menus.errorMenu")

----------------------------------------------------------
-- func:    addRemove
-- inputs:  none
-- returns: nil
-- info:    Runs the "Add or Remove Items" prompt
----------------------------------------------------------
local addRemove = require("modules.menus.item.addRemove")

----------------------------------------------------------
-- func:    doShop
-- inputs:  none
-- returns: nil
-- info:    Runs the shop
----------------------------------------------------------
local function doShop()
  --TODO: shop
  mon:print("Running.")
  local ok, err = pcall(shop.go)
  if not ok then
    if err == "Terminated" then
      mon.setBackgroundColor(colors.black)
      mon.setTextColor(colors.white)
      mon.clear()
      mon.setCursorPos(1, 1)
      mon.write("Shop halted, returned to menu.")
      if mon.flush then mon.flush() end
      return
    else
      error(err, 0)
    end
  else
    error("Shop stopped for unknown reason.")
  end
end

----------------------------------------------------------
-- func:    main
-- inputs:  none
-- returns: nil
-- info:    The main prompt
----------------------------------------------------------
local function main()
  -- init
  print("Initializing.")
  os.sleep(0.1)

  local monitorName

  local function fixMonitor()
    monitorName = peripheral.findString("monitor")[1]
    if monitorName then
      settings.set("shop.monitor.monitor", monitorName)
      settings.save(settingsLocation)
      notify("settings_update", "shop.monitor.monitor")
      print("No monitor was selected (or there is no monitor with the name "
            .. "saved), Auto-selected " .. monitorName)
      os.sleep(3)
    else
      error("No monitor")
    end
    mon = peripheral.wrap(monitorName)
  end


  print("Checking settings.")
  if not settings.load(settingsLocation) then
    print("No settings are saved, creating them.")
    os.sleep(0.5)
    for i = 1, #sets do
      settings.set(sets[i], sets.defaults[i])
      print(sets[i], " - ", sets.defaults[i])
      os.sleep(0.1)
    end
    settings.save(settingsLocation)
    print("Saved settings.")
    os.sleep(0.5)
  end
  monitorName = settings.get("shop.monitor.monitor")

  checkSettings()

  print("Grabbing monitor.")

  if not monitorName or monitorName:find("ERROR")
      or monitorName == "INVALID" then
    fixMonitor()
  end

  mon = peripheral.wrap(monitorName) -- if it's not already wrapped, wrap it.

  if type(mon) ~= "table" then
    fixMonitor()
  end

  monitor.setupMonitor(mon)
  mon.setBackgroundColor(colors.black)

  mon.clear()
  mon.setCursorPos(1, 1)
  mon:print("Starting...")
  os.sleep(0.1)

  print("Checking for missing side-files.")
  checkFiles()

  print("Checking Cache")
  os.sleep(0.1)
  cache.setSaveLocation(settings.get("shop.cacheSaveName"))
  if not cache.load() then
    print("No cache file found.")
    os.sleep(0.5)
  end

  print("Notifying other modules of init status.")
  notify("init",
    {
      notify = notify
    }
  )

  mon:print("Awaiting input...")
  mon:print()
  mon:print(
    settings.get("shop.autorun") and "Seconds until autorun: "
      .. tostring(settings.get("shop.autorunTime"))
    or "Autorun is disabled.  Please contact the owner ("
      .. settings.get("shop.shopOwner") .. ") for help."
  )

  local selection = 0
  while true do
    selection = mainMenu(build, updateCheckString())
    if selection == 1 then
      term.clear()
      term.setCursorPos(1, 1)
      print("Shop is running.")
      print()
      print("Hold ctrl+t to stop.")
      doShop()
    elseif selection == 2 then
      --TODO: update
    elseif selection == 3 then
      addRemove(cache)
    elseif selection == 4 then
      optionsMenu(sets, settingsLocation, notify)
    elseif selection == 5 then
      error("Generated error " .. tostring(math.random(1, 1000000)))
    elseif selection == 6 then
      term.setBackgroundColor(colors.black)
      term.clear()
      term.setCursorPos(1, 1)
      notify("stop")
      print("Simplify Shop has stopped.")
      return
    end
  end
end





-- ERROR CHECKING
local ok, err = pcall(main)

if not ok then
  pcall(notify, "error") -- notify modules of an error, so things can be saved
                         -- and unloaded
  pcall(bsod, err, mon)   -- bluescreen the monitor
  -- the above are pcalled in case they, themselves, error.
  if err ~= "Terminated" then
    local function doErr()
      local psx, psy = mon.getCursorPos()
      mon.setCursorPos(1, psy + 2)
      mon.write("Rebooting in " .. tostring(settings.get("shop.rebootTime") or 30)
                .. " seconds.")
      local ans = errorMenu(err)
      if ans == 1 then
        mon.setBackgroundColor(colors.black)
        mon.setTextColor(colors.white)
        mon.clear()
        mon.setCursorPos(1, 1)
        mon.write("Rebooting.")
        os.reboot()
      else
        pcall(bsod, err, mon) -- redo the bsod, without the reboot string.
        return
      end
    end
    local ok, err2 = pcall(doErr)
    if not ok then
      printError(err)
      print()
      printError("Failed to run error screen due to:")
      print()
      error(err2, 0)
    end
  end
end
