--- Menus displayed while the shop is starting, running, and stopping.

-- "press c for console" needs to be somewhere ye ye?

local module  = require "plugins.module"
local menus   = require "menus"
local logging = require "logging"

local menu_context   = logging.createContext("MENUS", colors.black, colors.gray)
local log_win        = logging.getWin()
local menu_win       = window.create(term.current(), 1, 1, term.getSize())
local log_visibility = false

local function run_settings_menu(menu_win)
  local settings_menu = menus.create(menu_win, "Settings")
end

local function run_help_menu(menu_win)
  local help_menu = menus.create(menu_win, "Help")

end

local function run_main_menu(menu_win)
  -- define the main menu selections and whatnot
  local GO = "go"
  local SETTINGS = "settings"
  local HELP = "help"
  local EXIT = "exit"

  local main_menu = menus.create(menu_win, "Simplify Shop V2.0.0")
  main_menu.addSelection(GO, "Run Shop", "Run the shop.", "Run the shop.")
  main_menu.addSelection(SETTINGS, "Settings", "Change shop settings.",
    "Open the settings menu to change details about the shop.")
  main_menu.addSelection(HELP, "Help", "View help page.", "Open the shop's builtin documentation for help.")
  main_menu.addSelection(EXIT, "Exit", "Exit the shop.",
    "Stop the shop, return to the CraftOS shell.")

  -- run the main menu
  repeat
    local selection = main_menu.run()

    if selection == SETTINGS then
      menu_context.debug("Open settings")

    elseif selection == HELP then
      menu_context.debug("Open help")

    elseif selection == EXIT then
      menu_context.debug("EXIT")
      module.registerEventCallback("ready", function()
        sleep(0.15)
        os.queueEvent "terminate"
      end)
    end
  until selection == GO or selection == EXIT
  menu_context.debug("Run shop.")
end

module.registerEventCallback("init", function()
  -- Run menus, return only when menu exited.
  log_win.setVisible(false)
  menu_win.setVisible(true)
  menu_win.redraw()

  run_main_menu(menu_win)
end)

module.registerEventCallback("ready", function()
  -- Run the 'shop running' menu.
end)

module.registerEventCallback("key", function(key)
  if key == keys.c then
    log_visibility = not log_visibility
    menu_context.debug("Log visibility: %s", log_visibility)

    -- Ensure that the menu window is invisible before the log window is made visible.
    -- ... Not sure if I need to do this.
    if log_visibility then menu_win.setVisible(false) end

    log_win.setVisible(log_visibility)

    -- and if the log window goes invisible, the menu window should be made visible afterwards.
    -- ... Not sure if I need to do this.
    if not log_visibility then menu_win.setVisible(true) end
  end
end)

module.registerEventCallback("stop", function()
  log_win.setVisible(false)
  menu_win.setVisible(false)
  term.setBackgroundColor(colors.black)
  term.setTextColor(colors.white)
  term.clear()
  term.setCursorPos(1, 1)
  print("Shop is stopping...")
end)
