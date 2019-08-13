local qmenus = require("modules.menus.layouts.questions")

----------------------------------------------------------
-- func:    getDetails
-- inputs:  items|table
-- returns: items|table
-- info:    loops through the items inputted, and asks
--          the user for it's name and value in krist
----------------------------------------------------------
local function getDetails(items)
  local tmp = {}

  for i, item in ipairs(items) do
    -- for each item in the table
    local menu = qmenus.new()
    menu:addQuestion(
      "Scanned '" .. item.name .. "' with damage "
      .. tostring(item.damage) .. ".",
      "string",
      "Enter the name you wish to use for this item.\n"
      .. "Leave blank to enter '" .. item.displayName .. "'."
    )
    menu:addQuestion(
      "For the previous item, what shall the cost in krist per item be?",
      "number",
      "Enter the cost per item you wish to charge for the previous item."
    )
    menu:go()

    -- check if the player just left the answer blank.  If so, set the name to
    -- the item's default name.
    if menu.questions.a[1] == "" then
      menu.questions.a[1] = item.displayName
    end

    tmp[#tmp + 1] = {
      name = item.name,
      damage = item.damage,
      displayName = menu.questions.a[1],
      value = menu.questions.a[2]
    }
  end

  return tmp
end

return getDetails
