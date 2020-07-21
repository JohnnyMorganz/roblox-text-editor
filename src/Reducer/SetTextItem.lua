return function (state, action)
  state = state or nil

  if action.type == "setTextItem" then
    return action.item
  end

  return state
end