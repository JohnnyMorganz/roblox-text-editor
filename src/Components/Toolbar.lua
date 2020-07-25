local TextEditor = script:FindFirstAncestor("TextEditor")
local ChangeHistoryService = game:GetService("ChangeHistoryService")
local Roact = require(TextEditor.Packages.Roact)
local RoactRodux = require(TextEditor.Packages.RoactRodux)
local Llama = require(TextEditor.Packages.Llama)
local Utilities = require(TextEditor.Plugin.Utilities)

local Toolbar = Roact.Component:extend("Toolbar")
local StudioThemeContext = require(script.Parent.StudioThemeContext)
local ToolbarButton = require(script.Parent.ToolbarButton)
local ThemedTextBox = require(script.Parent.TextBox)
local TypeDropdown = require(script.Parent.TypeDropdown)
local assets = require(TextEditor.Plugin.assets)

local FONT_NAMES = {}
do
  for _, font in pairs(Enum.Font:GetEnumItems()) do
    table.insert(FONT_NAMES, font.Name)
  end
end

local function ToolbarSpacer(props)
  return Roact.createElement("Frame", {
    LayoutOrder = props.LayoutOrder,
    BackgroundTransparency = 1,
    Size = UDim2.new(0, props.Width or 3, 1, 0),
  })
end

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

  if self.props.Font ~= prevProps.Font then
    self.props.TextItem.Font = self.props.Font
    ChangeHistoryService:SetWaypoint("Change Font")
  end

  if self.props.TextSize ~= prevProps.TextSize then
    self.props.TextItem.TextSize = self.props.TextSize
    ChangeHistoryService:SetWaypoint("Change TextSize")
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
        
        Font = Roact.createElement(TypeDropdown, {
          LayoutOrder = 1,
          Size = UDim2.new(0, 0, 0, 20),
          currentOption = self.props.Font.Name,
          options = FONT_NAMES,
          OnOptionSelect = function(option)
            self.props.setFont(Enum.Font[option])
          end,
        }),

        Spacer1 = Roact.createElement(ToolbarSpacer, {
          LayoutOrder = 2,
        }),

        TextSize = Roact.createElement(ThemedTextBox, {
          LayoutOrder = 3,
          BackgroundTransparency = 0,
          TextSize = 14,
          Size = UDim2.new(0, 22, 1, 0),
          Text = self.props.TextSize,
          TextXAlignment = Enum.TextXAlignment.Center,
          ClipsDescendants = true,
          [Roact.Event.FocusLost] = function(rbx)
            local newTextSize = tonumber(rbx.Text)
            if newTextSize and newTextSize > 0 and newTextSize <= 100 then
              self.props.setTextSize(newTextSize)
            else
              rbx.Text = self.props.TextSize
            end
          end,
        }),

        Spacer2 = Roact.createElement(ToolbarSpacer, {
          LayoutOrder = 4,
        }),

        BoldButton = Roact.createElement(ToolbarButton, {
          LayoutOrder = 5,
          Text = "<b>B</b>",
          Tooltip = "<b>Bold</b>\nMake your text bold",
          OnClick = self:toggleTagWrapper("b")
        }),

        ItalicButton = Roact.createElement(ToolbarButton, {
          LayoutOrder = 6,
          Text = "<i>I</i>",
          Tooltip = "<b>Italics</b>\nItalicize your text",
          OnClick = self:toggleTagWrapper("i")
        }),
  
        UnderlineButton = Roact.createElement(ToolbarButton, {
          LayoutOrder = 7,
          Text = "<u>U</u>",
          Tooltip = "<b>Underline</b>\nUnderline your text",
          OnClick = self:toggleTagWrapper("u")
        }),
  
        StrikethroughButton = Roact.createElement(ToolbarButton, {
          LayoutOrder = 8,
          Text = "<s>S</s>",
          Tooltip = "<b>Strikethrough</b>\nCross something out",
          OnClick = self:toggleTagWrapper("s")
        }),

        XAlignmentLeft = Roact.createElement(ToolbarButton, {
          type = "ImageButton",
          LayoutOrder = 9,
          Image = assets["paragraph-left"],
          Tooltip = "<b>Align Left</b>\nAlign your content with the left margin",
          OnClick = function()
            self.props.setXAlignment(Enum.TextXAlignment.Left)
          end,
          IsSelected = self.props.TextXAlignment == Enum.TextXAlignment.Left,
        }),

        XAlignmentCenter = Roact.createElement(ToolbarButton, {
          type = "ImageButton",
          LayoutOrder = 10,
          Image = assets["paragraph-center"],
          Tooltip = "<b>Align Center</b>\nCenter your content",
          OnClick = function()
            self.props.setXAlignment(Enum.TextXAlignment.Center)
          end,
          IsSelected = self.props.TextXAlignment == Enum.TextXAlignment.Center,
        }),

        XAlignmentRight = Roact.createElement(ToolbarButton, {
          type = "ImageButton",
          LayoutOrder = 11,
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
    newProps.Font = state.Font
    newProps.TextSize = state.TextSize
    return newProps
  end,
  function(dispatch)
    return {
      setXAlignment = function(alignment)
        dispatch({ type = "setXAlignment", alignment = alignment })
      end,
      setFont = function(font)
        dispatch({ type = "setFont", font = font })
      end,
      setTextSize = function(textSize)
        dispatch({ type = "setTextSize", textSize = textSize })
      end,
    }
  end
)(Toolbar)