local funcs = {}

function funcs.create(arg, expect, actual, level)
  return "Bad argument #" .. tostring(arg) .. ", expected " .. tostring(expect)
         .. ", got " .. type(actual), level or 2
end

function funcs.watch(arg, expect, actual, level)
  return type(actual) == expect and actual
    or error(funcs.create(arg, expect, actual, level and level + 1 or 3))
end

return funcs
