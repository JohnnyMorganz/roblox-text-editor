local SetTextItem = require(script.SetTextItem)
local SetXAlignment = require(script.SetXAlignment)

return function (state, action)
  state = state or {}

  return {
    TextItem = SetTextItem(state.TextItem, action),
    TextXAlignment = SetXAlignment(state.TextXAlignment, action)
  }
end