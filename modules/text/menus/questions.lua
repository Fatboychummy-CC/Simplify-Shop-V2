local funcs = {}
local meta = {}
local met = {}
meta.__index = met
met.__type = "menuObject"

local ec = require(".simplify.modules.etc.errors").watch

local function ask(question, tp)
  ec(1, "string", question)
  ec(2, "string", tp)

  local answer = ""

  if tp == "string" then

  elseif tp == "number" then

  elseif tp == "boolean" then

  else

  end

  return ""
end

function met:addQuestion(question, tp)
  ec(1, "string", question)
  ec(2, "string", tp)

  table.insert(tmp.questions.q, question)
  table.insert(tmp.questions.t, tp)
  table.insert(tmp.questions.a, "")

  return self
end

function met:go()
  for i, question in ipairs(self.questions.q) do
    self.questions.a[i] = ask()
  end
end

function funcs.new()
  local tmp = {}
  setmetatable(tmp, meta)

  tmp.questions = {
    q = {},
    t = {},
    a = {}
  }

  tmp.title = "Untitled"


  return tmp
end

return funcs
