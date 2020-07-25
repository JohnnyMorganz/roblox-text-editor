local SetTextItem = require(script.SetTextItem)
local SetXAlignment = require(script.SetXAlignment)
local SetFont = require(script.SetFont)
local SetTextSize = require(script.SetTextSize)

return function (state, action)
  state = state or {}

  return {
    TextItem = SetTextItem(state.TextItem, action),
    TextXAlignment = SetXAlignment(state.TextXAlignment, action),
    Font = SetFont(state.Font, action),
    TextSize = SetTextSize(state.TextSize, action),
  }
end