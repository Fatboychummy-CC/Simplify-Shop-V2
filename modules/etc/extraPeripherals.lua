local funcs = {}

----------------------------------------------------------
-- func:    findString
-- part of: peripheral
-- inputs:  tp: type|string
-- returns: peripherals|table[string]
-- info:    like peripheral.find, but does not wrap what it finds.
----------------------------------------------------------
function peripheral.findString(tp)
  local tmp = {}
  for i, mon in ipairs(peripheral.getNames()) do
    if peripheral.getType(mon) == tp then
      table.insert(tmp, mon)
    end
  end
  return tmp
end

return funcs
