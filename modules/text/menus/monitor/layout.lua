local lay = {}
local meta = {}
local met = {}
meta.__index = meta
meta.__type = "monitorMenu"

function met:addObject(object)

end

function lay.newLayout()
  local tmp = {}
  setmetatable(tmp, meta)

  -- TODO: monitor menu class
  -- TODO: monitor menu functionality
  -- INFO:
  --[[
    Data:
      {compatibleSizes}|table: table of sizes this menu is compatible with.
        -- to be used by 'subclasses'
      {objects}|table: table containing the following data:
        {buttons}|table: table of buttons.
        {boxes}|table: table of boxes (square shapes)
        {TextBoxes}|table: like boxes but can contain text
      -
    Functions/Methods:
      draw(monitor|table)|nil:
          draw this menu to the monitor
      addObject(Object|table)|nil:
          add a button or colored Box/TextBox to this menu
      pressButton(x|number, y|number)|boolean:
          loops through the objects.buttons table and attempts to run the
          'press' method on each of them.
      -
  ]]


  -- TODO:

  -- TODO: Button class
  -- TODO: Button functionality
  -- INFO:
  --[[
    Data:
      callback|function: callback for what happens when pressed.
      {position}|number: position on the monitor

  ]]

  return tmp
end

return lay
