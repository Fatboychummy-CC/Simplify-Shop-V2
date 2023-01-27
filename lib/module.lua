---@class module
local module = {}

local expect = require "cc.expect".expect
local logging = require "logging"
local module_context = logging.createContext("PLUGIN_RUNNER", colors.black, colors.blue)

local callbacks = {}
local running_coroutines = { n = 0 }
local tracked_coroutines = {}
local tracked_n1 = false
local running = false

local function count_kv(t)
  local n = 0

  for _ in pairs(t) do
    n = n + 1
  end

  return n
end

--- Remove a coroutine from being tracked if we are tracking it
---@param co thread
local function remove_from_tracked(co)
  tracked_coroutines[co] = nil
  module_context.debug("Tracked coroutine stop queued")
  module_context.debug("Tracked coroutines left: %d", count_kv(tracked_coroutines))
  if tracked_n1 and not next(tracked_coroutines) then
    os.queueEvent("tracked_coroutines_complete")
    tracked_n1 = false
  end
end

--- Run a single coroutine with an event.
---@param co table The coroutine to run
---@param ... any The event parameters.
---@return boolean stopped If the coroutine stopped as a result of running this.
local function single_run_single_coroutine(co, ...)
  if co.status == "new" or co.status == "suspended" or co.status == "normal" then
    local ok, filter = coroutine.resume(co.co, ...)

    if ok then
      co.filter = filter
      co.status = coroutine.status(co.co)

      if co.status == "dead" then
        remove_from_tracked(co.co)
        module_context.debug("A coroutine has stopped and was removed (1).")
        return true
      end
    else
      remove_from_tracked(co.co)
      module_context.error("Coroutine threw an error: %s", filter)
      return true
    end

    return false
  end

  -- coroutine status is "not good"
  remove_from_tracked(co.co)
  module_context.debug("A coroutine has stopped and was removed (2).")

  return true
end

--- Run all coroutines for a specific event.
---@param event_name string? The event name.
---@param ... any The event parameters.
local function single_run_coroutines(event_name, ...)
  for i = running_coroutines.n, 1, -1 do
    local co = running_coroutines[i]
    if co.filter == nil or co.filter == event_name then -- terminate events are not forwarded unless specifically listening for them.
      if single_run_single_coroutine(co, event_name, ...) then
        table.remove(running_coroutines, i)
        running_coroutines.n = running_coroutines.n - 1
      end
    end
  end
end

--- Queue a coroutine to be ran.
---@param co thread The coroutine to be run.
---@param parameters any[] The initial values to be passed to the coroutine.
local function run_coroutine(co, parameters)
  local coroutine_info = { co = co, status = "new" }
  table.insert(running_coroutines, coroutine_info)
  running_coroutines.n = running_coroutines.n + 1

  if single_run_single_coroutine(coroutine_info, table.unpack(parameters, 1, parameters.n)) then
    table.remove(running_coroutines, running_coroutines.n)
    running_coroutines.n = running_coroutines.n - 1
  end
end

--- Queue a coroutine to be ran.
---@param co thread The coroutine to be run.
---@param parameters any[] The initial values to be passed to the coroutine.
local function track_coroutine(co, parameters)
  local coroutine_info = { co = co, status = "new" }
  table.insert(running_coroutines, coroutine_info)
  tracked_coroutines[coroutine_info.co] = true
  running_coroutines.n = running_coroutines.n + 1

  tracked_n1 = true

  module_context.debug("Tracking a coroutine.")

  coroutine_info.filter = "CORO_START:" .. tostring(coroutine_info)

  os.queueEvent("CORO_START:" .. tostring(coroutine_info), table.unpack(parameters, 1, parameters.n))
end

--- Coroutine runner which handles input events and whatnot.
local function coroutines()
  while true do
    single_run_coroutines(coroutine.yield())
  end
end

--- Handle events and queue coroutines as needed.
function module.run()
  running = true

  parallel.waitForAny(coroutines, function()
    module_context.info("Pre-initializing plugins.")
    for _, callback in pairs(callbacks["pre-init"]) do
      track_coroutine(coroutine.create(callback), {})
    end
    coroutine.yield("tracked_coroutines_complete")
    module_context.info("All plugins Pre-initialized.")

    -- Safe to hard-stop after pre-initialization, but not after initialization.
    if not running then
      return
    end

    module_context.info("Initializing plugins.")
    for _, callback in pairs(callbacks.init) do
      track_coroutine(coroutine.create(callback), {})
    end
    coroutine.yield("tracked_coroutines_complete")
    module_context.info("All plugins initialized.")

    os.queueEvent("ready")
    while running do
      local event_data = table.pack(os.pullEventRaw())
      local event_name = event_data[1]

      if event_name == "terminate" then
        module_context.warn("Terminate queued.")
        break
      else
        if callbacks[event_name] then
          table.remove(event_data, 1)
          event_data.n = event_data.n - 1

          for _, callback in pairs(callbacks[event_name]) do
            run_coroutine(coroutine.create(callback), event_data)
          end
          os.queueEvent("new_coroutine")
        end
      end
    end

    module_context.info("Stopping plugins...")
    for _, callback in pairs(callbacks.stop) do
      track_coroutine(coroutine.create(callback), {})
    end
    coroutine.yield("tracked_coroutines_complete") ---@TODO Time limit.
    module_context.info("All plugins have stopped.")
  end)

  running = false
end

--- Run a thread "in the background" (magic!)
---@param func function The function to run in the background.
---@param ... any Arguments to be passed to the function.
function module.thread(func, ...)
  run_coroutine(coroutine.create(func), ...)
end

--- Push an event to all plugin handlers listening for it.
---@param event_name string The name of the event.
---@overload fun(event_name:"pre-init"): table Called pre-start of the shop. Run any settings menus and whatnot here.
---@overload fun(event_name:"init"): table Called when the system is starting up. Initialize your websockets or whatever here.
---@overload fun(event_name:"ready"): table Called when all init functions have completed. Looping module code should be stuffed here.
---@overload fun(event_name:"stop"): table Called when the system is stopping. Close your websockets or whatever here.
---@overload fun(event_name:"purchase", item_info:item, count:integer, price:integer, refunded:integer): table Called whenever an item is purchased.
---@overload fun(event_name:"refresh_stock", stock:item[]): table Called when the shop's stock refreshes. This occurs by default every minute and after each purchase.
---@overload fun(event_name:"redraw", monitors:multimon): table Called when the shop redraws the monitors.
---@overload fun(event_name:"activity_dot", x:integer, y:integer, colour:colour): table Push this event to display an activity dot for 0.5 seconds.
function module.pushEvent(event_name, ...)
  os.queueEvent(event_name, ...)
end

--- Register an event handler which handles events.
---@param event_name string The name of the event to be handled.
---@param callback fun(...:any) The handler function.
---@return table callback_id Unique table to identify the callback with for removal.
---@overload fun(event_name:"pre-init"): table Called pre-start of the shop. Run any settings menus and whatnot here.
---@overload fun(event_name:"init", callback:fun()): table Called when the system is starting up. Initialize your websockets or whatever here.
---@overload fun(event_name:"ready", callback:fun()): table Called when all init functions have completed. Looping module code should be stuffed here.
---@overload fun(event_name:"stop", callback:fun()): table Called when the system is stopping. Close your websockets or whatever here.
---@overload fun(event_name:"purchase", callback:fun(item_info:item, count:integer, price:integer, refunded:integer)): table Called whenever an item is purchased.
---@overload fun(event_name:"refresh_stock", callback:fun(stock:item[])): table Called when the shop's stock refreshes. This occurs by default every minute and after each purchase.
---@overload fun(event_name:"redraw", callback:fun(monitors:multimon)): table Called when the shop redraws the monitors.
---@overload fun(event_name:"activity_dot", callback:fun(x:integer, y:integer, colour:colour)): table Push this event to display an activity dot for 0.5 seconds.
function module.registerEventCallback(event_name, callback)
  module_context.debug("Register event callback: %s", event_name)

  local identifier = {}

  if not callbacks[event_name] then
    callbacks[event_name] = {}
  end

  callbacks[event_name][identifier] = callback

  return identifier
end

--- Remove an event callback via its identifier
---@param event_name string The event to remove the callback from.
---@param identifier table The identifier given from registerEventCallback
function module.removeEventCallback(event_name, identifier)
  module_context.debug("Remove callback: %s", event_name)
  if callbacks[event_name] then callbacks[event_name][identifier] = nil end
end

--- Stop the coroutine controller.
function module.stop()
  running = false
end

--- Get the current status of the coroutine controller.
---@return boolean running Whether or not the controller is running.
function module.running()
  return running
end

return module
