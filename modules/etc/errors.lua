local funcs = {}

function funcs.create(arg, expect, actual, level)
  return "Bad argument #" .. tostring(arg) .. ", expected " .. tostring(expect)
         .. ", got " .. type(actual), level or 2
end

return funcs
