local funcs = {}
local moni = require("modules.etc.monitor")
local items = require("modules.item.itemCache")
local l = require("modules.shop.monitor.listy")
local b = require("modules.shop.monitor.infoBox")

local onotify

local mon, list, shopInfoBox, toDrawSimple

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

function funcs.setup()
  mon = peripheral.wrap(settings.get("shop.monitor.monitor"))
  moni.setupMonitor(mon, true)

  local listtop = settings.get("shop.listing.topStop")
  local listmx = settings.get("shop.listing.maxItemsPerPage")

  list = l.createList(
    settings.get("shop.listing.leftStop"),
    listtop,
    settings.get("shop.listing.rightStop"),
    listtop + listmx,
    settings.get("shop.listing.enabled")
  )
  shopInfoBox = b.new(
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
  list:setSelectionColor(
    settings.get("shop.listing.selectionfgcolor"),
    settings.get("shop.listing.selectionbgcolor")
  )
  list:setEvenColor(
    settings.get("shop.listing.fgcolor2"),
    settings.get("shop.listing.bgcolor2")
  )
  list:setOddColor(
    settings.get("shop.listing.fgcolor1"),
    settings.get("shop.listing.bgcolor1")
  )
  list:setHeaderColor(
    settings.get("shop.listing.fgheader"),
    settings.get("shop.listing.bgheader")
  )
  toDrawSimple = {shopInfoBox}
end

function funcs.draw(displayItems, selection, fake)
  list:clearItems()
  local dcml = settings.get("shop.listing.decimalPlaces")

  if fake then
    list:addItem("LISTING 1 NORMAL", 1, 1)
    list:addItem("LISTING 2 NORMAL", 1, 1)
    list:addItem("LISTING 1 EMPTY", 0, 1)
    list:addItem("LISTING 2 EMPTY", 0, 1)
    list:addItem("LISTING SELECT", 1, 1)
  else
    for i = 1, #displayItems do
      local c = displayItems[i]
      list:addItem(
        c.displayName,
        c.count,
        c.cost
      )
    end
  end

  mon.setBackgroundColor(colors.black)
  mon.clear()

  -- "Complex" redraws which require extra inputs.
  list:draw(mon, dcml, selection or 0)

  -- simple redraws (don't require added inputs)
  for i, item in ipairs(toDrawSimple) do
    item:draw(mon)
  end
  mon.flush()
end

function funcs.go()
  local sleepTime = settings.get("shop.refreshRate")
  local tmr = os.startTimer(sleepTime)
  funcs.draw({}, 0, false)

  while true do
    local ev = {os.pullEvent()}
    funcs.draw({}, 0, false)

    if ev[1] == "timer" and ev[2] == tmr then
      tmr = os.startTimer(sleepTime)
    end
  end
end

return funcs
