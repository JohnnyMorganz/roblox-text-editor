local SetTextItem = require(script.SetTextItem)

return function (state, action)
  state = state or {}

  return {
    TextItem = SetTextItem(state.TextItem, action)
  }
end