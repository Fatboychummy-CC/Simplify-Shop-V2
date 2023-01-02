--- Utility library for writing on terminals or monitors

local strings = require "cc.strings"

---@class window_utils
local window_utils = {}

--- Write text centered at a position.
---@param win peripheral The terminal object to write to.
---@param x integer? The x position of the centerpoint. Leave nil to use the centerpoint of the term object.
---@param y integer? The y position of the centerpoint. Leave nil to use the centerpoint of the term object.
---@param text string The text to be written.
---@param width_limit integer The maximum length of a single line.
---@return integer upper_bound The top-most y value written (This is weird due to CC having y=0 at the top -- this is the lowest y value, when viewed is the furthest up the screen).
---@return integer lower_bound The bottom-most y value written (This is weird due to CC having y=0 at the top -- this is the highest y value, when viewed is the furthest down the screen).
---@return integer left_bound The left-most x value written.
---@return integer right_bound The right-most x value written.
function window_utils.writeCenteredText(win, x, y, text, width_limit)
  local split = strings.wrap(text, width_limit)
  for _, str in ipairs(split) do
    str = str:match(" *(.-) *")
  end
  local y_offset = math.floor(#split / 2 + 0.5)

  local w, h = win.getSize()
  x = x or math.ceil(w / 2)
  y = y or math.ceil(h / 2)

  local widest = 0

  for i, line in ipairs(split) do
    local width = #line
    win.setCursorPos(
      math.floor(x - width / 2 + 0.5),
      y - y_offset + i
    )
    win.write(line)
    widest = math.max(width, widest)
  end

  return y - y_offset + 1, y + y_offset - 1,
      x - math.ceil(widest / 2) + 1, x + math.ceil(widest / 2) - 1
end

return window_utils
