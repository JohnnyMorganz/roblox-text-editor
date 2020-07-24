local Utilities = {
  string = {}
}

function Utilities.string.trim(str)
  return string.match(str, '^%s*(.-)%s*$')
end

function Utilities.string.startswith(str, pattern, plain)
	local start = 1
	return string.find(str, pattern, start, plain) == start
end

function Utilities.string.endswith(str, pattern, plain)
	local start = #str - #pattern + 1
	return string.find(str, pattern, start, plain) == start
end

function Utilities.addTagsAroundSelection(guiItem, cursorPosition, selectionStart, tag)
  if cursorPosition == -1 or selectionStart == -1 then return guiItem.Text end

  local startTag, endTag = string.format('<%s>', tag), string.format('</%s>', tag)

  local selectedText = string.sub(guiItem.Text, math.min(cursorPosition, selectionStart), math.max(cursorPosition, selectionStart) - 1)
  local trimmedSelectedText = Utilities.string.trim(selectedText)

  if Utilities.string.startswith(trimmedSelectedText, startTag) and Utilities.string.endswith(trimmedSelectedText, endTag) then
    selectedText = selectedText:gsub(startTag, ""):gsub(endTag, "")
  else
    selectedText = startTag .. selectedText .. endTag
  end

  local text = string.sub(guiItem.Text, 0, math.min(cursorPosition, selectionStart) - 1)
  local startPosition = text:len() + 1
  text ..= selectedText
  local endPosition = text:len() + 1
  text ..= string.sub(guiItem.Text, math.max(cursorPosition, selectionStart))

  return text, startPosition, endPosition
end

return Utilities