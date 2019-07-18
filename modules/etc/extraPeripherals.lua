local funcs = {}

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
