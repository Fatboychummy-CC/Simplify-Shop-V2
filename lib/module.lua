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
local pre_init_stop = false
local errored = false
local error_message ---@type string?

local function reset_coroutines()
  running_coroutines = { n = 0 }
  tracked_coroutines = {}
  tracked_n1 = false
end

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
      module.pushEvent("error", filter)
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

--- Run a set of coroutines until they are done.
---@param coroutine_list function[]
---@param time_limit number? The time limit, if any.
---@return boolean time_out If the stop was caused by a time-out.
---@return boolean errored If the stop was caused by an error.
---@return string? error_message The message returned by the error, if any.
local function run_tracked_coroutines(coroutine_list, time_limit)
  for _, callback in pairs(coroutine_list) do
    track_coroutine(coroutine.create(callback), {})
  end

  local timer
  if time_limit then
    timer = os.startTimer(time_limit)
  end
  local result, tmr
  repeat
    result, tmr = coroutine.yield()
    module_context.debug("%s %s", result, tmr)
  until result == "tracked_coroutines_complete" or result == "error" or (result == "timer" and tmr == timer)

  if result == "error" then
    return false, true, tmr
  end
  return result == "timer", false
end

--- Handle events and queue coroutines as needed.
function module.run()
  running = true
  errored = false
  pre_init_stop = false
  error_message = nil

  parallel.waitForAny(coroutines, function()
    module_context.info("Pre-initializing plugins.")
    local _, _errored, _error_message = run_tracked_coroutines(callbacks["pre-init"])
    module_context.info("All plugins Pre-initialized.")
    errored = _errored
    error_message = _error_message
    reset_coroutines() -- ensure coroutine tables are clean

    -- Safe to hard-stop after pre-initialization, but not after initialization.
    if not pre_init_stop and not errored then
      module_context.info("Initializing plugins.")
      _, _errored, _error_message = run_tracked_coroutines(callbacks.init)
      module_context.info("All plugins initialized.")
      errored = _errored
      error_message = _error_message
      reset_coroutines() -- ensure coroutine tables are clean

      if not errored then
        os.queueEvent("ready")
        while running do
          local event_data = table.pack(os.pullEventRaw())
          local event_name = event_data[1]

          if event_name == "terminate" then
            module_context.warn("Terminate queued.")
            break
          elseif event_name == "error" then
            running = false
            errored = true
            error_message = event_data[2]
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
      end
    end
    reset_coroutines() -- ensure coroutine tables are clean

    module_context.info("Stopping plugins...")
    local timed_out = run_tracked_coroutines(callbacks.stop, 5)
    module_context.info("All plugins have stopped.")
    if timed_out then
      printError("One or more modules ran past the 5 second shutdown limit and have been killed.")
    end
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
---@overload fun(event_name:"pre-init") Called pre-start of the shop. Run any settings menus and whatnot here.
---@overload fun(event_name:"init") Called when the system is starting up. Initialize your websockets or whatever here.
---@overload fun(event_name:"ready") Called when all init functions have completed. Looping module code should be stuffed here.
---@overload fun(event_name:"stop") Called when the system is stopping. Close your websockets or whatever here. It is recommended you check the return values of `module.errored()` here.
---@overload fun(event_name:"purchase", item_info:item, count:integer, price:integer, refunded:integer) Called whenever an item is purchased.
---@overload fun(event_name:"refresh_stock", stock:item[]) Called when the shop's stock refreshes. This occurs by default every minute and after each purchase.
---@overload fun(event_name:"redraw", monitors:multimon) Called when the shop redraws the monitors.
---@overload fun(event_name:"activity_dot", x:integer, y:integer, colour:colour) Push this event to display an activity dot for 0.5 seconds.
---@overload fun(event_name:"error", error:string) Push this event when a critical error occurs. INTERNAL USE ONLY.
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
---@overload fun(event_name:"stop", callback:fun()): table Called when the system is stopping. Close your websockets or whatever here. It is recommended you check the return values of `module.errored()` here.
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

--- Stop the system during pre-init stage. Use this in place of `module.stop()` when in the pre-init stage.
function module.pre_init_stop()
  pre_init_stop = true
end

--- Get the current status of the coroutine controller.
---@return boolean running Whether or not the controller is running.
function module.running()
  return running
end

--- Check if the module is stopping due to an error.
---@return boolean errored If the module stopped due to an error.
---@return string? error The error message, if an error occurred.
function module.errored()
  return errored, error_message
end

return module
