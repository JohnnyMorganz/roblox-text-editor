return function (state, action)
  state = state or 14

  if action.type == "setTextSize" then
    return action.textSize or 14
  elseif action.type == "setTextItem" then
    -- Update when a new TextItem is set
    return action.item and action.item.TextSize or 14
  end

  return state
end