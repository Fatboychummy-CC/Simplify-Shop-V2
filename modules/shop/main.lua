local funcs = {}
local moni = require("modules.etc.monitor")
local l = require("modules.shop.monitor.listy")

local onotify

function funcs.notify(ev, ...)
  local args = {...}

  if ev == "init" then
    onotify = args["notify"]
  elseif ev == "settings_update" then
    local set = args[1]
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

  local top = settings.get("shop.listing.topStop")
  local lef = settings.get("shop.listing.leftStop")
  local rig = settings.get("shop.listing.rightStop")
  local mx = settings.get("shop.listing.maxItemsPerPage")
  local dcml = settings.get("shop.listing.decimalPlaces")

  local list = l.createList(lef, top, rig, top + mx)
  while true do
    mon.setBackgroundColor(colors.black)
    mon.clear()
    list:draw(mon, dcml)
    mon.flush()
    os.sleep(5)
  end
end

return funcs
