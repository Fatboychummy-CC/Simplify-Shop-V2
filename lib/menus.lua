--- Runs the menus for the shop.

---@class menu
---@field public addSelection fun(id:string, name:string, description:string, long_description:string) Add a new selection to the menu.
---@field public run fun(id:string?):string Run the menu and return the id of the selection selected. Start with the id passed selected (or the first selection, if nil)
---@field public title string The title of this menu
---@field public win table The window that this menu draws to.
---@field public _selected integer The currently selected index (subtract 1 to make working with it easier: 0 to n-1 instead of 1 to n. For modulo).
---@field public _scroll_position integer The current scroll distance.
---@field public selections selection[]


---@alias selection {id:string, name:string, description:string, long_description:string}

---@class menus
local menus = {}

local function redraw_menu(menu)
  local win = menu.win
  local old = term.redirect(win)

  -- Draw the title.
  term.setCursorPos(1, 1)
  term.setTextColor(colors.yellow)
  term.setBackgroundColor(colors.black)
  term.clear()
  write(menu.title)

  -- Determine how many selections can fit, leaving 3 lines at the bottom.
  -- Two spaces top (title, empty space between)
  -- Three lines bottom
  -- should be h - 5?
  local w, h = term.getSize()
  local selection_count = h - 5

  -- Draw the scroll bar.
  local TOP_POS = 3
  local down_count = math.min(selection_count, #menu.selections)
  if selection_count > down_count then
    for y = TOP_POS + 1, TOP_POS + down_count - 2 do
      term.setCursorPos(1, y)
      term.write("|")
    end
    term.setCursorPos(1, TOP_POS)
    term.write('\x1E')
    term.setCursorPos(1, TOP_POS + down_count - 1)
    term.write('\x1F')
  else
    if down_count == 1 then
      term.setCursorPos(1, TOP_POS)
      term.write('>')
    else
      for y = TOP_POS + 1, TOP_POS + down_count - 2 do
        term.setCursorPos(1, y)
        term.write("|")
      end
      term.setCursorPos(1, TOP_POS)
      term.write('=')
      term.setCursorPos(1, TOP_POS + down_count - 1)
      term.write('=')
    end
  end

  -- Draw the selections.
  term.setTextColor(colors.white)
  for y = TOP_POS, TOP_POS + down_count - 1 do
    local sel_n = y - TOP_POS + 1
    ---@type selection
    local sel = menu.selections[sel_n]
    term.setCursorPos(3, y)

    if menu._selected + 1 == sel_n then

      term.setBackgroundColor(colors.gray)
      term.write(string.rep(' ', w))
      term.setCursorPos(3, y)
      term.write(sel.name)

      term.setCursorPos(w - 25, y)
      term.write(sel.description)

      term.setCursorPos(1, h - 1)
      term.setBackgroundColor(colors.black)
      write(sel.long_description)
    else
      term.setBackgroundColor(colors.black)
      term.setTextColor(colors.white)
      term.write(sel.name)

      term.setCursorPos(w - 25, y)
      term.write(sel.description)
    end
  end

  -- Draw the long description of the selected selection.



  term.redirect(old)
end

local event_handlers = {
  --- Handle key event
  ---@param menu menu
  ---@param key integer
  key = function(menu, key)
    if key == keys.up then
      menu._selected = (menu._selected - 1) % #menu.selections
    elseif key == keys.down then
      menu._selected = (menu._selected + 1) % #menu.selections
    elseif key == keys.enter then
      return true
    end
  end
}

--- Handle an event for a given menu.
---@param menu menu The menu to handle events for.
---@param event_name string The name of the event.
---@param ... any The event parameters.
local function handle_menu_event(menu, event_name, ...)
  if event_handlers[event_name] then
    local result = event_handlers[event_name](menu, ...)

    if not result then
      redraw_menu(menu)
    end

    return result
  end
end

--- Create a new menu object
---@param win table The window to draw to.
---@param title string The title of the menu.
---@return menu menu The menu object.
function menus.create(win, title)
  ---@class menu
  local menu = {
    selections = {},
    win = win,
    title = title,
    _selected = 0
  }

  function menu.addSelection(id, name, description, long_description)
    table.insert(menu.selections,
      { id = id, name = name, description = description, long_description = long_description })
  end

  function menu.run(id)
    redraw_menu(menu)
    while true do
      if handle_menu_event(menu, coroutine.yield()) then
        return menu.selections[menu._selected + 1].id
      end
    end
  end

  return menu
end

return menus
