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

-- local KEYCODES_FOR_TAGS = {
--   [Enum.KeyCode.B] = "b",
--   [Enum.KeyCode.I] = "i",
--   [Enum.KeyCode.U] = "u",
-- }

function TextEditorComponent:init()
  self.textItemMaid = Maid.new() -- Maid related to the TextItem involved

  self.inputRef = Roact.createRef()
  self.selectionStartPosition, self.updateSelectionStartPosition = Roact.createBinding(-1) -- This is a delayed value as the textbox loses focus before a Button Activated event occurs
  self.cursorPosition, self.updateCursorPosition = Roact.createBinding(-1) -- Same as above
end

function TextEditorComponent:_saveText()
  local newText = self.props.labelText:getValue()

  if self.props.TextItem.Text ~= newText then
    self.props.TextItem.Text = newText
    ChangeHistoryService:SetWaypoint("Updated text")
  end
end

function TextEditorComponent:_addTextItemConnections()
  self.textItemMaid:DoCleaning() -- Clear any old connections

  -- Connect to any property changes of the TextItem, so that the Text Editor is up to date
  self.textItemMaid:GiveTask(self.props.TextItem:GetPropertyChangedSignal("Text"):Connect(function()
    local textBox = self.inputRef:getValue()
    if textBox then
      textBox.Text = self.props.TextItem.Text
    end
  end))

  self.textItemMaid:GiveTask(self.props.TextItem:GetPropertyChangedSignal("TextXAlignment"):Connect(function()
    if self.props.TextXAlignment ~= self.props.TextItem.TextXAlignment then
      self.props.setXAlignment(self.props.TextItem.TextXAlignment)
  end
  end))
end

function TextEditorComponent:didMount()
  self:_addTextItemConnections()
end

function TextEditorComponent:didUpdate(prevProps, _prevState)
  if prevProps.TextItem ~= self.props.TextItem then
    self:_addTextItemConnections()
end
end

function TextEditorComponent:willUnmount()
  self.textItemMaid:DoCleaning()
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

function TextEditorComponent:render()
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
    }),
  
    TextBox = Roact.createElement(ThemedTextBox, {
      [Roact.Ref] = self.inputRef,
      LayoutOrder = 2,
      Text = self.props.TextItem.Text,
      ClearTextOnFocus = false,
      MultiLine = true,
      Width = UDim.new(1, 0),
      BackgroundTransparency = 0,
  
      [Roact.Change.Text] = function(rbx)
        self.props.updateLabelText(rbx.Text)
      end,
  
      [Roact.Change.SelectionStart] = function(rbx)
        coroutine.wrap(function()
          wait(0.3)
          self.updateSelectionStartPosition(rbx.SelectionStart)
        end)()
      end,
  
      [Roact.Change.CursorPosition] = function(rbx)
        coroutine.wrap(function()
          wait(0.3)
          self.updateCursorPosition(rbx.CursorPosition)
        end)()
      end,

      [Roact.Event.FocusLost] = function()
        self:_saveText()
      end,
    }, {
      SizeConstraint = Roact.createElement("UISizeConstraint", {
        MinSize = Vector2.new(0, 100),
      }),
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
        TextXAlignment = self.props.TextXAlignment, -- This is specifically managed in the Rodux store
      })
    }),
  })
end

return RoactRodux.connect(
  function(state, props)
    if state.TextItem ~= props.TextItem then
      local newProps = Llama.Dictionary.copy(props)
      newProps.TextItem = state.TextItem
      newProps.TextXAlignment = state.TextXAlignment
      return newProps
    end
    return props
  end,
  function(dispatch)
    return {
      setXAlignment = function(alignment)
        dispatch({ type = "setXAlignment", alignment = alignment })
      end,
    }
  end
)(TextEditorComponent)