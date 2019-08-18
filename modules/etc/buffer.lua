local funcs = {}

local dcopy = require(".modules.etc.dcop")
local ers = require(".modules.etc.errors")
local ec = ers.create
local ew = ers.watch

local buffer = {
  bg = colors.black,    -- background color
  fg = colors.white,    -- foreground color
  p = {1, 1},           -- cursor position ()
  lines = {}            -- content of each line
}
--[[
  lines = {
    {
      [1] = "some text!" -- actual text.
      [2] = "0000000000" -- foreground color
      [3] = "ffffffffff" -- background color
    }
  }

  EZ BLIT
]]

function funcs.bufferize(mon)
  local oldgbg = mon.getBackgroundColor--
  local oldgfg = mon.getTextColor--
  local oldsbg = mon.setBackgroundColor--
  local oldsfg = mon.setTextColor--
  local oldsc = mon.setTextScale--
  local oldscp = mon.setCursorPos--
  local oldgcp = mon.getCursorPos--

  local oldc = mon.clear--
  local oldcl = mon.clearLine--
  local oldscr = mon.scroll--

  local oldw = mon.write--
  local oldb = mon.blit

  local mx, my = mon.getSize()

  local function toP(col)
    local tmp = {
      [1] = '0',
      [2] = '1',
      [4] = '2',
      [8] = '3',
      [16] = '4',
      [32] = '5',
      [64] = '6',
      [128] = '7',
      [256] = '8',
      [512] = '9',
      [1024] = 'a',
      [2048] = 'b',
      [4096] = 'c',
      [8192] = 'd',
      [16384] = 'e',
      [32768] = 'f'
    }
    return tmp[col]
  end

  function mon.setBackgroundColor(col)
    ew(1, "number", col)
    if col < 1 or col > 32768 then
      error("Colour out of range", 2)
    end
    buffer.bg = col
    oldsbg(col)
  end
  mon.setBackgroundColour = mon.setBackgroundColor

  function mon.setTextColor(col)
    ew(1, "number", col)
    if col < 1 or col > 32768 then
      error("Colour out of range", 2)
    end
    buffer.fg = col
    oldsfg(col)
  end
  mon.setTextColour = mon.setTextColor

  function mon.getBackgroundColor()
    return buffer.bg
  end
  mon.getBackgroundColour = mon.getBackgroundColor

  function mon.getTextColor()
    return buffer.fg
  end
  mon.getTextColour = mon.getTextColor

  function mon.setCursorPos(x, y)
    ew(1, "number", x)
    ew(2, "number", y)
    buffer.p = {x, y}
  end

  function mon.getCursorPos()
    return table.unpack(buffer.p)
  end


  function mon.clear()
    for i = 1, my do
      buffer.lines[i] = {
        string.rep(' ', mx),
        string.rep(toP(mon.getTextColor()), mx),
        string.rep(toP(mon.getBackgroundColor()), mx),
      }
    end
  end

  function mon.clearLine(ln)
    buffer.lines[ln] = {
      string.rep(' ', mx),
      string.rep(toP(mon.getTextColor()), mx),
      string.rep(toP(mon.getBackgroundColor()), mx),
    }
  end

  function mon.scroll(cnt)
    for i = 1, cnt do
      table.insert(
        buffer.lines,
        1,
        {
          string.rep(' ', mx),
          string.rep(toP(mon.getTextColor()), mx),
          string.rep(toP(mon.getBackgroundColor()), mx),
        }
      )
      table.remove(buffer.lines, #buffer.lines)
    end
  end

  function mon.setTextScale(sc)
    oldsc(sc)
    mon.clear()
  end

  function mon.write(txt)
    local bg = toP(mon.getBackgroundColor())
    local fg = toP(mon.getTextColor())

    local line = buffer.lines[buffer.p[2]]
    local stt = string.sub(line[1], 0, buffer.p[1] - 1)
    local edt = string.sub(line[1], buffer.p[1] + #txt)
    local text = stt .. txt .. edt

    local stf = string.sub(line[2], 0, buffer.p[1] - 1)
    local edf = string.sub(line[2], buffer.p[1] + #txt)
    local fg = stf .. string.rep(fg, #txt) .. edf

    local stb = string.sub(line[3], 0, buffer.p[1] - 1)
    local edb = string.sub(line[3], buffer.p[1] + #txt)
    local bg = stb .. string.rep(bg, #txt) .. edb

    buffer.lines[buffer.p[2]] = {
      text,
      fg,
      bg
    }
    buffer.p = {
      buffer.p[1] + #txt,
      buffer.p[2]
    }
  end

  function mon.blit(txt, fg, bg)
    ew(1, "string", txt)
    ew(2, "string", fg)
    ew(3, "string", bg)
    if #txt ~= #fg or #fg ~= #bg then
      error("Arguments must be the same length", 2)
    end

    local bfOffset = buffer.p[1] - 1
    local afOffset = buffer.p[1] + #txt

    local line = buffer.lines[buffer.p[2]]
    local stt = string.sub(line[1], 0, bfOffset)
    local edt = string.sub(line[1], afOffset)
    local text = stt .. txt .. edt

    local stf = string.sub(line[2], 0, bfOffset)
    local edf = string.sub(line[2], afOffset)
    fg = stf .. fg .. edf

    local stb = string.sub(line[3], 0, bfOffset)
    local edb = string.sub(line[3], afOffset)
    bg = stb .. bg .. edb

    buffer.lines[buffer.p[2]] = {
      text,
      fg,
      bg
    }
    buffer.p = {
      buffer.p[1] + #txt,
      buffer.p[2]
    }
  end


  function mon.flush()
    for i = 1, #buffer.lines do
      oldscp(1, i)
      oldb(table.unpack(buffer.lines[i]))
    end
    mon.setCursorPos(table.unpack(buffer.p))
  end

  buffer.p = {oldgcp()}
  buffer.fg = oldgfg()
  buffer.bg = oldgbg()
  mon.clear()

end

function funcs.getBuffer()
  return buffer
end

return funcs
