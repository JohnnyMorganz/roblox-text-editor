local TextEditor = script:FindFirstAncestor("TextEditor")
local ChangeHistoryService = game:GetService("ChangeHistoryService")
local Roact = require(TextEditor.Packages.Roact)
local RoactRodux = require(TextEditor.Packages.RoactRodux)
local Llama = require(TextEditor.Packages.Llama)
local Utilities = require(TextEditor.Plugin.Utilities)

local Toolbar = Roact.Component:extend("Toolbar")
local StudioThemeContext = require(script.Parent.StudioThemeContext)
local ToolbarButton = require(script.Parent.ToolbarButton)
local assets = require(TextEditor.Plugin.assets)

function Toolbar:toggleTagWrapper(tag)
  return function()
    local textBox = self.props.inputRef:getValue()
    local cursorPosition, selectionStart = self.props.cursorPosition:getValue(), self.props.selectionStartPosition:getValue()
    if cursorPosition ~= -1 and selectionStart ~= -1 then
      local text, startPosition, endPosition = Utilities.addTagsAroundSelection(textBox, cursorPosition, selectionStart, tag)
      textBox.Text = text
      textBox:CaptureFocus()
      textBox.SelectionStart = startPosition
      textBox.CursorPosition = endPosition
    else
      -- Add tags at cursor position and then set the cursor in between them
      local startText, endText = textBox.Text:sub(0, cursorPosition - 1), textBox.Text:sub(cursorPosition)
      startText ..= "<" .. tag .. ">"
      local newCursorPosition = startText:len() + 1
      startText ..= "</" .. tag .. ">"
      textBox.Text = startText .. endText
      textBox:CaptureFocus()
      textBox.CursorPosition = newCursorPosition 
    end
  end
end

function Toolbar:didUpdate(prevProps, _prevState)
  if self.props.TextXAlignment ~= prevProps.TextXAlignment then
    -- Update the TextItem TextXAlignment when a button is pressed
    self.props.TextItem.TextXAlignment = self.props.TextXAlignment
    ChangeHistoryService:SetWaypoint("Change TextXAlignment")
  end
end

function Toolbar:render()
  return Roact.createElement(StudioThemeContext.Consumer, {
    render = function(theme)
      return Roact.createElement("Frame", {
        LayoutOrder = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundColor3 = theme:GetColor("Titlebar"),
      }, {
        Layout = Roact.createElement("UIListLayout", {
          SortOrder = Enum.SortOrder.LayoutOrder,
          FillDirection = Enum.FillDirection.Horizontal,
        }),
  
        BoldButton = Roact.createElement(ToolbarButton, {
          LayoutOrder = 1,
          Text = "<b>B</b>",
          Tooltip = "<b>Bold</b>\nMake your text bold",
          OnClick = self:toggleTagWrapper("b")
        }),

        ItalicButton = Roact.createElement(ToolbarButton, {
          LayoutOrder = 2,
          Text = "<i>I</i>",
          Tooltip = "<b>Italics</b>\nItalicize your text",
          OnClick = self:toggleTagWrapper("i")
        }),
  
        UnderlineButton = Roact.createElement(ToolbarButton, {
          LayoutOrder = 3,
          Text = "<u>U</u>",
          Tooltip = "<b>Underline</b>\nUnderline your text",
          OnClick = self:toggleTagWrapper("u")
        }),
  
        StrikethroughButton = Roact.createElement(ToolbarButton, {
          LayoutOrder = 4,
          Text = "<s>S</s>",
          Tooltip = "<b>Strikethrough</b>\nCross something out",
          OnClick = self:toggleTagWrapper("s")
        }),

        XAlignmentLeft = Roact.createElement(ToolbarButton, {
          type = "ImageButton",
          LayoutOrder = 5,
          Image = assets["paragraph-left"],
          Tooltip = "<b>Align Left</b>\nAlign your content with the left margin",
          OnClick = function()
            self.props.setXAlignment(Enum.TextXAlignment.Left)
          end,
          IsSelected = self.props.TextXAlignment == Enum.TextXAlignment.Left,
        }),

        XAlignmentCenter = Roact.createElement(ToolbarButton, {
          type = "ImageButton",
          LayoutOrder = 6,
          Image = assets["paragraph-center"],
          Tooltip = "<b>Align Center</b>\nCenter your content",
          OnClick = function()
            self.props.setXAlignment(Enum.TextXAlignment.Center)
          end,
          IsSelected = self.props.TextXAlignment == Enum.TextXAlignment.Center,
        }),

        XAlignmentRight = Roact.createElement(ToolbarButton, {
          type = "ImageButton",
          LayoutOrder = 7,
          Image = assets["paragraph-right"],
          Tooltip = "<b>Align Right</b>\nAlign your content with the right margin",
          OnClick = function()
            self.props.setXAlignment(Enum.TextXAlignment.Right)
          end,
          IsSelected = self.props.TextXAlignment == Enum.TextXAlignment.Right,
        }),
      })
    end
  })
end

return RoactRodux.connect(
  function(state, props)
    local newProps = Llama.Dictionary.copy(props)
    newProps.TextItem = state.TextItem
    newProps.TextXAlignment = state.TextXAlignment
    return newProps
  end,
  function(dispatch)
    return {
      setXAlignment = function(alignment)
        dispatch({ type = "setXAlignment", alignment = alignment })
      end,
    }
  end
)(Toolbar)