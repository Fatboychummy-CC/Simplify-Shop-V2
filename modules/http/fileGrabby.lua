local funcs = {}

local ers = require(".modules.etc.errors")
local ec = ers.create
local ew = ers.watch

local ht = "http://"
local pastebin = ht .. "pastebin.com/raw/"
local github = ht .. "raw.githubusercontent.com/"

function funcs.get(loc, to)
  ew(1, "string", loc)
  ew(2, "string", to)

  print("Connecting to " .. tostring(loc) .. ".")
  local res = http.get(loc)
  if res then
    print("Connected, opening file for writing.")
    local handle = io.open(to, 'w')
    if handle then
      print("Open, writing.")
      local dat = res.readAll()
      res.close()
      handle:write(dat):close()
      print("Done.")
    else
      error("Failed to open file (" .. tostring(to) .. ") for writing.", 2)
    end
  else
    error("Failed to connect to " .. tostring(loc) .. ".", 2)
  end
end

function funcs.pastebin(id, to)
  ew(1, "string", id)
  ew(2, "string", to)

  id = pastebin .. id
  funcs.get(id, to)
end

function funcs.github(user, repo, branch, file, to)
  ew(1, "string", user)
  ew(2, "string", repo)
  ew(3, "string", branch)
  ew(4, "string", file)
  ew(5, "string", to)

  local toGet = github .. user .. "/" .. repo .. "/" .. branch .. "/" .. file

  funcs.get(toGet, to)
end

return funcs
