local tmp = {}

tmp.toColor = {
  [1] = "white",
  [2] = "orange",
  [4] = "magenta",
  [8] = "lightBlue",
  [16] = "yellow",
  [32] = "lime",
  [64] = "pink",
  [128] = "gray",
  [256] = "lightGray",
  [512] = "cyan",
  [1024] = "purple",
  [2048] = "blue",
  [4096] = "brown",
  [8192] = "green",
  [16384] = "red",
  [32768] = "black"
}
tmp.fromColor = {}
tmp.toColour = {}
tmp.fromColour = {}

for k, v in pairs(tmp.toColor) do
  tmp.fromColor[v] = k
end

for k, v in pairs(tmp.toColor) do
  tmp.toColour[k] = v
end
tmp.toColour[128] = "grey"
tmp.toColour[256] = "lightGrey"

for k, v in pairs(tmp.toColour) do
  tmp.fromColour[v] = k
end

local meta = {
  __call = function(self, col)
    if type(col) == "number" then
      return self.toColor[col] or self.toColour[col]
    elseif type(col) == "string" then
      return self.fromColor[col] or self.fromColour[col]
    elseif type(col) ~= "nil" then
      error("Expected string or number, got " .. type(col) .. ".", 2)
    end
  end
}

return setmetatable(tmp, meta)
