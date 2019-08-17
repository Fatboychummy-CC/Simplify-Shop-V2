local funcs = {}

local onotify

function funcs.notify(ev, ...)
  local args = {...}

  if ev == "init" then
    onotify = args["notify"]
  end
end

function funcs.go(mon)
  while true do
    mon.clear()
    mon.setCursorPos(1, 1)
    mon.write("Yeah we runnin boiiiiiiiiiiis")
    os.sleep(5)
  end
end

return funcs