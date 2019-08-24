local funcs = {}
local moni = require("modules.etc.monitor")
local l = require("modules.shop.monitor.listy")
local b = require("modules.shop.monitor.infoBox")

local onotify

function funcs.notify(ev, ...)
  local args = {...}

  if ev == "init" then
    onotify = args["notify"]
  elseif ev == "settings_update" then
    local set = args[1]
    if not set then
      error("Missing setting in settings_update notification.", 3)
    end
    local t = settings.get(set)
    if set == "shop.listing.topStop" or set == "shop.listing.leftStop" then
      if t < 1 then
        settings.set(set, 1)
      end
    elseif set == "shop.listing.rightStop" then
      local mx = peripheral.call(settings.get("shop.monitor.monitor"),
                                 "getSize")
      if t > mx then
        settings.set(set, mx)
      end
    end
  end
end

function funcs.go()
  local mon = peripheral.wrap(settings.get("shop.monitor.monitor"))
  moni.setupMonitor(mon, true)

  local listtop = settings.get("shop.listing.topStop")
  local listmx = settings.get("shop.listing.maxItemsPerPage")
  local dcml = settings.get("shop.listing.decimalPlaces")

  local sleepTime = settings.get("shop.refreshRate")

  local list = l.createList(
    settings.get("shop.listing.leftStop"),
    listtop,
    settings.get("shop.listing.rightStop"),
    listtop + listmx,
    settings.get("shop.listing.enabled")
  )
  local shopInfoBox = b.new(
    settings.get("shop.info.leftStop"),
    settings.get("shop.info.topStop"),
    settings.get("shop.info.rightStop"),
    settings.get("shop.info.bottomStop"),
    settings.get("shop.info.bgcolor"),
    settings.get("shop.info.fgcolor"),
    settings.get("shop.info.centered"),
    settings.get("shop.info.enabled")
  )
  for i = 1, 5 do
    shopInfoBox:setLine(i, settings.get("shop.info.line" .. tostring(i)) or "")
  end

  local toDrawSimple = {
    shopInfoBox
  }

  while true do
    list:clearItems()
    mon.setBackgroundColor(colors.black)
    mon.clear()

    -- "Complex" redraws which require extra inputs.
    list:draw(mon, dcml)

    -- simple redraws (don't require added inputs)
    for i, item in ipairs(toDrawSimple) do
      item:draw(mon)
    end
    mon.flush()
    os.sleep(sleepTime)
  end
end

return funcs
