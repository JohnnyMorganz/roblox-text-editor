local TextEditor = script:FindFirstAncestor("TextEditor")
local ChangeHistoryService = game:GetService("ChangeHistoryService")
local Roact = require(TextEditor.Packages.Roact)
local RoactRodux = require(TextEditor.Packages.RoactRodux)
local Llama = require(TextEditor.Packages.Llama)
local Maid = require(TextEditor.Packages.Maid)

local TextEditorComponent = Roact.Component:extend("TextEditor")
local Toolbar = require(script.Parent.Toolbar)
local Section = require(script.Parent.Section)
local ThemedTextLabel = require(script.Parent.TextLabel)
local ThemedTextBox = require(script.Parent.TextBox)
local ThemedTextButton = require(script.Parent.TextButton)

-- local KEYCODES_FOR_TAGS = {
--   [Enum.KeyCode.B] = "b",
--   [Enum.KeyCode.I] = "i",
--   [Enum.KeyCode.U] = "u",
-- }

local function stringtrim(str)
  return string.match(str, '^%s*(.-)%s*$')
end

local function stringstartswith(str, pattern, plain)
	local start = 1
	return string.find(str, pattern, start, plain) == start
end

local function stringendswith(str, pattern, plain)
	local start = #str - #pattern + 1
	return string.find(str, pattern, start, plain) == start
end

local function addTagsAroundSelection(guiItem, cursorPosition, selectionStart, tag)
  if cursorPosition == -1 or selectionStart == -1 then return guiItem.Text end

  local startTag, endTag = string.format('<%s>', tag), string.format('</%s>', tag)

  local selectedText = string.sub(guiItem.Text, math.min(cursorPosition, selectionStart), math.max(cursorPosition, selectionStart) - 1)
  local trimmedSelectedText = stringtrim(selectedText)

  if stringstartswith(trimmedSelectedText, startTag) and stringendswith(trimmedSelectedText, endTag) then
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

function TextEditorComponent:init()
  self.maid = Maid.new()

  self.inputRef = Roact.createRef()
  self.selectionStartPosition, self.updateSelectionStartPosition = Roact.createBinding(-1) -- This is a delayed value as the textbox loses focus before a Button Activated event occurs
  self.cursorPosition, self.updateCursorPosition = Roact.createBinding(-1) -- Same as above
end

-- function TextEditorComponent:toggleTagWrapper(tag)
--   return function()
--     local textBox = self.inputRef:getValue()
--     local cursorPosition, selectionStart = self.cursorPosition:getValue(), self.selectionStartPosition:getValue()
--     if cursorPosition ~= -1 and selectionStart ~= -1 then
--       textBox.Text = addTagsAroundSelection(textBox, cursorPosition, selectionStart, tag)
--       textBox:CaptureFocus()
--     else
--       -- Add tags at cursor position and then set the cursor in between them
--       local startText, endText = textBox.Text:sub(0, cursorPosition - 1), textBox.Text:sub(cursorPosition)
--       startText ..= "<" .. tag .. ">"
--       local newCursorPosition = startText:len() + 1
--       startText ..= "</" .. tag .. ">"
--       textBox.Text = startText .. endText
--       textBox:CaptureFocus()
--       textBox.CursorPosition = newCursorPosition 
--     end
--   end
-- end

-- function TextEditorComponent:didMount()
--   local overlay = self.props.overlayRef:getValue()
--   local textBox = self.inputRef:getValue()
--   TODO: Keybinds
--   self.maid:GiveTask(overlay.InputBegan:Connect(function(InputObject)
--     if InputObject:IsModifierKeyDown(Enum.ModifierKey.Ctrl) then
--       if KEYCODES_FOR_TAGS[InputObject.KeyCode] then
--         textBox.Text = addTagsAroundSelection(textBox, textBox.CursorPosition, textBox.SelectionStart, KEYCODES_FOR_TAGS[InputObject.KeyCode])
--       end
--     end
--   end))

--   See main.server.lua for reason this is not used
--   self.maid:GiveTask(self.props.pluginActions.toggleBold.Triggered:Connect(self:toggleTagWrapper("b")))
--   self.maid:GiveTask(self.props.pluginActions.toggleItalic.Triggered:Connect(self:toggleTagWrapper("i")))
--   self.maid:GiveTask(self.props.pluginActions.toggleUnderline.Triggered:Connect(self:toggleTagWrapper("u")))
--   self.maid:GiveTask(self.props.pluginActions.toggleStrikethrough.Triggered:Connect(self:toggleTagWrapper("s")))
-- end

-- function TextEditorComponent:willUnmount()
--   self.maid:DoCleaning()
-- end

function TextEditorComponent:render()
  self.props.updateLabelText(self.props.TextItem.Text)

  return Roact.createFragment({
    Padding = Roact.createElement("UIPadding", {
      PaddingLeft = UDim.new(0, 5),
      PaddingRight = UDim.new(0, 5),
      PaddingTop = UDim.new(0, 5),
      PaddingBottom = UDim.new(0, 5),
    }),
  
    Layout = Roact.createElement("UIListLayout", {
      Padding = UDim.new(0, 5),
      SortOrder = Enum.SortOrder.LayoutOrder,
      [Roact.Change.AbsoluteContentSize] = function(rbx)
        self.props.updateHolderSize(rbx.AbsoluteContentSize.Y + 10) -- Addition due to padding
      end,
    }),
  
    Toolbar = Roact.createElement(Toolbar, {
      inputRef = self.inputRef,
      cursorPosition = self.cursorPosition,
      selectionStartPosition = self.selectionStartPosition,
      addTagsAroundSelection = addTagsAroundSelection,
    }),
  
    TextBox = Roact.createElement(ThemedTextBox, {
      ref = self.inputRef,
      LayoutOrder = 2,
      Text = self.props.TextItem.Text,
      ClearTextOnFocus = false,
      MultiLine = true,
      Size = UDim2.new(1, 0, 0.5, 0),
      BackgroundTransparency = 0,
  
      OnTextChange = function(rbx)
        self.props.updateLabelText(rbx.Text)
        
        -- -- Create history waypoints to undo text change
        -- local settingText = rbx.Text
        -- local focusedTextItem = self.props.TextItem
        -- delay(1, function()
        --   if focusedTextItem == self.props.TextItem and settingText == rbx.Text then
        --     ChangeHistoryService:SetWaypoint("Typed Text")
        --   end
        -- end)
      end,
  
      OnSelectionStartChange = function(rbx)
        delay(0.3, function()
          self.updateSelectionStartPosition(rbx.SelectionStart)
        end)
      end,
  
      OnCursorPositionChange = function(rbx)
        delay(0.3, function()
          self.updateCursorPosition(rbx.CursorPosition)
        end)
      end,
    }),
  
    Output = Roact.createElement(Section, {
      LayoutOrder = 3,
      Title = "Output",
    }, {
      Padding = Roact.createElement("UIPadding", {
        PaddingTop = UDim.new(0, 5),
        PaddingBottom = UDim.new(0, 5),
      }),
  
      OutputLabel = Roact.createElement(ThemedTextLabel, {
        BackgroundTransparency = 1,
        Text = self.props.labelText,
        RichText = true,
        Width = UDim.new(1, 0),
        
        -- Copy the label text
        Font = self.props.TextItem.Font,
        TextColor3 = self.props.TextItem.TextColor3,
        TextSize = self.props.TextItem.TextSize,
        TextStrokeColor3 = self.props.TextItem.TextStrokeColor3,
        TextStrokeTransparency = self.props.TextItem.TextStrokeTransparency,
        TextTransparency = self.props.TextItem.TextTransparency,
        TextXAlignment = self.props.TextItem.TextXAlignment,
      })
    }),
  })
end

return RoactRodux.connect(
  function(state, props)
    if state.TextItem ~= props.TextItem then
      local newProps = Llama.Dictionary.copy(props)
      newProps.TextItem = state.TextItem
      return newProps
    end
    return props
  end
)(TextEditorComponent)