--- Menus displayed while the shop is starting, running, and stopping.

-- "press c for console" needs to be somewhere ye ye?

local module       = require "module"
local menus        = require "menus"
local logging      = require "logging"
local window_utils = require "window_utilities"
local config       = require "config"

local menu_context   = logging.createContext("MENUS", colors.black, colors.gray)
local log_win        = logging.getWin()
local menu_win       = window.create(term.current(), 1, 1, term.getSize())
local log_visibility = false

local function run_settings_menu()
  local settings_menu = menus.create(menu_win, "Settings")
end

local function run_help_menu()
  local help_menu = menus.create(menu_win, "Help")

end

local function run_plugins_menu()
  local EXIT = "exit"

  local plugin_menu = menus.create(menu_win, "Plugins")
  local changed = false

  -- Populate the list with all the plugins.
  local plugin_info = {}
  for state, plugins in pairs(config.loaded.plugins) do
    for _, plugin in ipairs(plugins) do
      table.insert(plugin_info,
        { name = plugin, enabled = state == "core" or state == "enabled", core = state == "core" })
    end
  end

  -- Sort alphabetically
  table.sort(plugin_info, function(a, b)
    return a.name:lower() < b.name:lower()
  end)

  --- Shorthand to add a selection
  ---@param name string
  ---@param desc string
  ---@param long_desc string
  ---@param color colour
  local function plug(name, desc, long_desc, color)
    menu_context.debug("Add selection: %s", name)
    plugin_menu.addSelection(
      name,
      name:sub(1, -5),
      desc,
      long_desc,
      { description_colour = color }
    )
  end

  for _, info in pairs(plugin_info) do
    local name = info.name

    if info.core then
      plug(name, "Core plugin.", "Core plugins cannot be disabled.", colors.yellow)
    elseif info.enabled then
      plug(name, "Enabled.", "Press enter to disable this plugin.", colors.green)
    else
      plug(name, "Disabled.", "Press enter to enable this plugin.", colors.red)
    end
  end

  -- Add the go back button
  plugin_menu.addSelection(EXIT, "Go back", "Return to menu.", "Exit this menu and go to the previous menu.")

  repeat
    local selection = plugin_menu.run()
    menu_context.debug("Plugin menu got selection: %s", selection)

    if selection ~= EXIT then
      local selection_info = plugin_menu.getSelection(selection)

      if selection_info then
        ---@TODO Set this so it actually changes things instead of just pretending.
        if selection_info.description == "Enabled." then
          plugin_menu.editSelection(selection, nil, "Disabled.", "Press enter to enable this plugin.",
            { description_colour = colors.red })

          plugin_menu.editSelection(EXIT, "Exit", "Exit the shop.", "Reloading plugins requires the shop to stop.")
          changed = true
        elseif selection_info.description == "Disabled." then
          plugin_menu.editSelection(selection, nil, "Enabled.", "Press enter to disable this plugin.",
            { description_colour = colors.green })

          plugin_menu.editSelection(EXIT, "Exit", "Exit the shop.", "Reloading plugins requires the shop to stop.")
          changed = true
        end
      end
    end
  until selection == EXIT

  if changed then
    menu_win.setBackgroundColor(colors.black)
    menu_win.setTextColor(colors.white)
    menu_win.clear()
    local x, y = menu_win.getSize()
    x = math.floor(x / 2 + 0.5)
    y = math.floor(y / 2 + 0.5)
    window_utils.writeCenteredText(menu_win, x, y, "The shop must be relaunched in order to reload plugins.", 25)
    sleep(3)
  end

  return changed
end

--- Generate a stop event after the shop is ready.
local function stop_preboot()
  menu_context.warn("Stop requested by user.")
  module.pre_init_stop()
end

--- Run the main menu.
local function run_main_menu()
  -- define the main menu selections and whatnot
  local GO = "go"
  local SETTINGS = "settings"
  local HELP = "help"
  local PLUGINS = "plugins"
  local EXIT = "exit"

  local main_menu = menus.create(menu_win, "Simplify Shop V2.0.0")
  main_menu.addSelection(GO, "Run Shop", "Run the shop.", "Run the shop.")
  main_menu.addSelection(SETTINGS, "Settings", "Change shop settings.",
    "Open the settings menu to change details about the shop.")
  main_menu.addSelection(HELP, "Help", "View help page.", "Open the shop's builtin documentation for help.")
  main_menu.addSelection(PLUGINS, "Plugins", "Toggle plugins", "Enable or disable plugins.")
  main_menu.addSelection(EXIT, "Exit", "Exit the shop.",
    "Stop the shop, return to the CraftOS shell.")

  -- run the main menu
  repeat
    local selection = main_menu.run()

    if selection == SETTINGS then
      menu_context.debug("Open settings")
      run_settings_menu()

    elseif selection == HELP then
      menu_context.debug("Open help")
      run_help_menu()

    elseif selection == PLUGINS then
      menu_context.debug("Open plugins")
      if run_plugins_menu() then
        stop_preboot()
        selection = EXIT
      end

    elseif selection == EXIT then
      menu_context.debug("EXIT")
      stop_preboot()
    end
  until selection == GO or selection == EXIT
  menu_context.debug("Run shop.")
end

--- Run the menu that is displayed while the shop is running
local function run_running_menu()
  local run_menu = menus.create(menu_win, "Shop is running.")
  run_menu.addSelection("", "Stop", "Stop the shop.",
    "Stop the shop. WARNING: This terminates anything in progress.")

  run_menu.run()
  menu_context.info("Stop triggered by menu.")
  os.queueEvent("terminate")
end

module.registerEventCallback("pre-init", function()
  -- Run menus, return only when menu exited.
  log_win.setVisible(false)
  menu_win.setVisible(true)
  menu_win.redraw()

  run_main_menu()
end)

module.registerEventCallback("init", function()
  menu_win.clear()
  menu_win.setCursorPos(1, 1)
  menu_win.write("Initializing...")
end)

module.registerEventCallback("ready", function()
  -- Run the 'shop running' menu.
  menu_win.setBackgroundColor(colors.black)
  menu_win.setTextColor(colors.white)
  menu_win.clear()

  run_running_menu()
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
