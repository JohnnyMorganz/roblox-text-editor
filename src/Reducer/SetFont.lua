return function (state, action)
  state = state or Enum.Font.SourceSans

  if action.type == "setFont" then
    return action.font or Enum.Font.SourceSans
  elseif action.type == "setTextItem" then
    -- Update when a new TextItem is set
    return action.item and action.item.Font or Enum.Font.SourceSans
  end

  return state
end