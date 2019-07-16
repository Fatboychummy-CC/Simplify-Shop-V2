local funcs = {}
local meta = {}
local met = {}
meta.__index = met
met.__type = "menuObject"

local e = require(".simplify.modules.etc.errors")
local ew = e.watch
local ec = e.create

local function ask(self, questionIndex, tp)
  ew(1, "table", self)
  if self.__type ~= "menuObject" then
    error(ec(1, "menuObject", self))
  end
  ew(2, "number", questionIndex)
  ew(3, "string", tp)

  local question = self.questions.q[questionIndex]
  local info = self.questions.i[questionIndex]
  local mx, my = term.getSize()

  term.setBackgroundColor(self.colors.questionbg)
  term.setTextColor(self.colors.questionfg)
  term.clear()
  term.setCursorPos(1, 1)
  print(question)
  term.setCursorPos(1, 7)
  term.setBackgroundColor(self.colors.infobg)
  term.setTextColor(self.colors.infofg)
  print(info)
  term.setCursorPos(1, 5)
  io.write("> ")
  term.setBackgroundColor(self.colors.answerbg)
  term.setTextColor(self.colors.answerfg)

  if tp == "string" then
    return io.read()
  elseif tp == "number" then
    while true do
      local ans = tonumber(io.read())
      if not ans then
        term.setCursorPos(1, 5)
        io.write(">" .. string.rep(' ', mx - 1))
        term.setCursorPos(3, 5)
        term.setTextColor(term.isColor() and colors.red or colors.gray)
        io.write("Not a number!")
        os.sleep(2)
        term.setTextColor(self.colors.infofg)
        term.setCursorPos(1, 5)
        io.write(">" .. string.rep(' ', mx - 1))
        term.setCursorPos(3, 5)
        term.setTextColor(self.colors.answerfg)
      else
        return ans
      end
    end
    return tonumber(io.read()) or 0
  elseif tp == "boolean" then
    io.write(" false  true")
    local sel = 1
    while true do
      if sel == 1 then
        term.setCursorPos(3, 5)
        io.write("[false] true ")
      else
        term.setCursorPos(3, 5)
        io.write(" false [true]")
      end
      local event, key = os.pullEvent("key")
      if key == 203 or key == 205 then
        sel = sel == 1 and 2 or 1
      elseif key == 28 then
        return sel == 1 and "false" or sel == 2 and "true"
      end
    end
  else
    error("Bad argument #3, expected string stating 'string', 'number', or "
          .. "'boolean', got " .. tostring(tp), 2)
  end
end

function met:addQuestion(question, tp, longInformation)
  ew(1, "string", question)
  ew(2, "string", tp)
  ew(3, "string", longInformation)

  table.insert(self.questions.q, question)
  table.insert(self.questions.t, tp)
  table.insert(self.questions.a, "")
  table.insert(self.questions.i, longInformation)

  return self
end

function met:go()
  for i, question in ipairs(self.questions.q) do
    self.questions.a[i] = ask(self, i, self.questions.t[i])
  end
end

function funcs.new()
  local tmp = {}
  setmetatable(tmp, meta)

  tmp.questions = {
    q = {},
    t = {},
    a = {},
    i = {}
  }

  tmp.colors = {
    bg = colors.black,
    fg = colors.white,
    titlefg = colors.black,
    titlebg = colors.white,
    questionbg = colors.black,
    questionfg = colors.white,
    answerbg = colors.black,
    answerfg = colors.white,
    infobg = colors.black,
    infofg = colors.lightGray
  }

  tmp.title = "Untitled"


  return tmp
end

return funcs
