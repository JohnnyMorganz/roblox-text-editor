return function (state, action)
  state = state or Enum.TextXAlignment.Center

  if action.type == "setXAlignment" then
    return action.alignment or Enum.TextXAlignment.Center
  elseif action.type == "setTextItem" then
    -- Update when a new TextItem is set
    return action.item and action.item.TextXAlignment or Enum.TextXAlignment.Center
  end

  return state
end