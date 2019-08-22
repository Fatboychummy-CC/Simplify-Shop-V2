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

  local list = l.createList(
    settings.get("shop.listing.leftStop")
    listtop,
    settings.get("shop.listing.rightStop")
    listtop + listmx,
    settings.get("shop.listing.enabled")
  )
  local shopInfoBox = b.new(1, 15, 20, 22, colors.black, colors.white)

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
    os.sleep(5)
  end
end

return funcs
