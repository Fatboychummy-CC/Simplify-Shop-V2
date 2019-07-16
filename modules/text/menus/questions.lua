local funcs = {}
local meta = {}
local met = {}
meta.__index = met
met.__type = "menuObject"

local e = require(".simplify.modules.etc.errors")
local ew = e.watch
local ec = e.create

local function ask(self, question, tp)
  ew(1, "table", self)
  if self.__type ~= "menuObject" then
    error(ec(1, "menuObject", self))
  end
  ew(2, "string", question)
  ew(3, "string", tp)

  local answer = ""

  if tp == "string" then

  elseif tp == "number" then

  elseif tp == "boolean" then

  else

  end

  return ""
end

function met:addQuestion(question, tp, longInformation)
  ew(1, "string", question)
  ew(2, "string", tp)
  ew(3, "string", longInformation)

  table.insert(tmp.questions.q, question)
  table.insert(tmp.questions.t, tp)
  table.insert(tmp.questions.a, "")
  table.insert(tmp.questions.i, longInformation)

  return self
end

function met:go()
  for i, question in ipairs(self.questions.q) do
    self.questions.a[i] = ask(self, question, self.questions.t[i])
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

  tmp.colors = {
    bg = colors.black,
    fg = colors.white,
    titlefg = colors.black,
    titlebg = colors.white,
    questionbg = colors.black,
    questionfg = colors.white,
    answerbg = colors.black,
    answerfg = colors.gray,
    infobg = colors.black,
    infofg = colors.white
  }

  tmp.title = "Untitled"


  return tmp
end

return funcs
