local funcs = {}

function funcs.create(arg, expect, actual)
  return "Bad argument #" .. tostring(arg) .. ", expected " .. tostring(expect)
         .. ", got " .. type(actual), 2
end

return funcs
