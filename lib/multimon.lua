--- Control multiple monitors at once.

---@class multimon
local multimon = {}

--- Wrap all monitors into a single option.
---@param ... peripheral|string The monitors to wrap.
---@return fun(per_monitor:fun(monitor:peripheral)) multimon Function which runs code on all monitors listed.
function multimon.monitors(...)
  local monitors = table.pack(...)
  for i = 1, monitors.n do
    if type(monitors[i]) == "string" then
      monitors[i] = peripheral.wrap(monitors[i])
    end
  end

  return function(per_monitor)
    for i = 1, monitors.n do
      per_monitor(monitors[i])
    end
  end
end

return multimon
