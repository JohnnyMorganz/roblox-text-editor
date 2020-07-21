local TextEditor = script:FindFirstAncestor("TextEditor")
local ChangeHistoryService = game:GetService("ChangeHistoryService")
local Roact = require(TextEditor.Packages.Roact)
local RoactRodux = require(TextEditor.Packages.RoactRodux)
local Llama = require(TextEditor.Packages.Llama)

local TextEditorComponent = Roact.Component:extend("TextEditor")
local Section = require(script.Parent.Section)
local ThemedTextLabel = require(script.Parent.TextLabel)
local ThemedTextBox = require(script.Parent.TextBox)
local ThemedTextButton = require(script.Parent.TextButton)

local function addTagsAroundSelection(guiItem, cursorPosition, selectionStart, tag)
  if cursorPosition == -1 or selectionStart == -1 then return guiItem.Text end

  local text = string.sub(guiItem.Text, 0, math.min(cursorPosition, selectionStart) - 1)
  text ..= string.format('<%s>', tag)
  text ..= string.sub(guiItem.Text, math.min(cursorPosition, selectionStart), math.max(cursorPosition, selectionStart) - 1)
  text ..= string.format('</%s>', tag)
  text ..= string.sub(guiItem.Text, math.max(cursorPosition, selectionStart))

  return text
end

function TextEditorComponent:init()
  self.inputRef = Roact.createRef()
  self.labelText, self.updateLabelText = Roact.createBinding("")
  self.selectionStartPosition, self.updateSelectionStartPosition = Roact.createBinding(-1) -- THIS IS DELAYED
  self.cursorPosition, self.updateCursorPosition = Roact.createBinding(-1) -- THIS IS DELAYED
end

function TextEditorComponent:render()
  self.updateLabelText(self.props.TextItem.Text)

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
        self.props.updateHolderSize(rbx.AbsoluteContentSize.Y)
      end,
    }),
  
    Toolbar = Roact.createElement("Frame", {
      LayoutOrder = 1,
      Size = UDim2.new(1, 0, 0, 20),
    }, {
      Button = Roact.createElement("TextButton", {
        Text = "B",
        Size = UDim2.fromOffset(10, 10),
  
        [Roact.Event.Activated] = function()
          self.inputRef:getValue().Text = addTagsAroundSelection(self.inputRef:getValue(), self.cursorPosition:getValue(), self.selectionStartPosition:getValue(), "b")
        end
      })
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
        self.updateLabelText(rbx.Text)
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
        Text = self.labelText,
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
  
    Save = Roact.createElement(ThemedTextButton, {
      LayoutOrder = 4,
      Name = "Save",
      Size = UDim2.new(1, 0, 0, 35),
      AnchorPoint = Vector2.new(0, 1),
      Enabled = true,
      ShowPressed = true,
      OnClicked = function()
        self.props.TextItem.Text = self.labelText:getValue()
        ChangeHistoryService:SetWaypoint("Updated text")
      end,
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