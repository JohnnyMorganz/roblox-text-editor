-- Dropdown with an editable TextBox to type option
local TextService = game:GetService("TextService")
local TextEditor = script:FindFirstAncestor("TextEditor")
local Roact = require(TextEditor.Packages.Roact)

local StudioThemeContext = require(script.Parent.StudioThemeContext)
local TextDropdown = Roact.Component:extend("TextDropdown")
local TextBox = require(script.Parent.TextBox)
local DropdownItem = require(script.DropdownItem)

local BUTTON_SIZE = 20
local TEXT_FIELD_PADDING = 5

TextDropdown.defaultProps = {
  AutoSize = true,
  Size = UDim2.new(0, 50, 0, 20),
  Font = Enum.Font.SourceSans,
  TextSize = 14,

  options = {},
  OnOptionSelect = function() end,
}

function TextDropdown:init()
  self.notTyped = false
  self.lastTyped = ""

  self.dropdownCanvasSize, self.setDropdownCanvasSize = Roact.createBinding(0) 

  self:setState({
    open = false,
  })
end

function TextDropdown:render()
  return Roact.createElement(StudioThemeContext.Consumer, {
    render = function(theme)
      local DropdownChildren = {}

      -- Determine X Size
      local size = self.props.Size
      if self.props.AutoSize then
        local textXSize = 0
        for _, option in pairs(self.props.options) do
          local textBounds = TextService:GetTextSize(option, self.props.TextSize, self.props.Font, Vector2.new(math.huge, math.huge))
          if textXSize < textBounds.X then
            textXSize = textBounds.X
          end
        end
        size = UDim2.new(UDim.new(0, textXSize + 2 + BUTTON_SIZE + TEXT_FIELD_PADDING), size.Y)
      end

      -- Get Children
      DropdownChildren.ListLayout = Roact.createElement("UIListLayout", {
        SortOrder = Enum.SortOrder.Name,

        [Roact.Change.AbsoluteContentSize] = function(rbx)
          self.setDropdownCanvasSize(rbx.AbsoluteContentSize.Y)
        end,
      })

      DropdownChildren.Padding = Roact.createElement("UIPadding", {
        PaddingLeft = UDim.new(0, TEXT_FIELD_PADDING)
      })

      for _, option in pairs(self.props.options) do
        DropdownChildren[option] = Roact.createElement(DropdownItem, {
          Text = option,
          TextSize = self.props.TextSize,
          selected = self.props.currentOption == option,
          OnSelected = function()
            self:setState({ open = false })
            self.props.OnOptionSelect(option)
          end,
        })
      end

      return Roact.createElement("Frame", {
        LayoutOrder = self.props.LayoutOrder,
        Size = size,
        BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Dropdown),
        BorderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.InputFieldBorder),
      }, {
        Holder = Roact.createElement("Frame", {
          BackgroundTransparency = 1,
          Size = UDim2.fromScale(1, 1),
        }, {
          Padding = Roact.createElement("UIPadding", {
            PaddingLeft = UDim.new(0, TEXT_FIELD_PADDING)
          }),
  
          ListLayout = Roact.createElement("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            FillDirection = Enum.FillDirection.Horizontal,
          }),
  
          TextBox = Roact.createElement(TextBox, {
            Text = self.props.currentOption,
            TextSize = self.props.TextSize,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -BUTTON_SIZE, 1, 0), -- Addition includes the UIPadding
            ClearTextOnFocus = false,
  
            [Roact.Change.Text] = function(rbx)
              if self.notTyped then 
                self.notTyped = false
                return
              end 
  
              local text = rbx.Text
              local length = text:len()
  
              -- See if the user is deleting
              if (length < self.lastTyped:len() and text == self.lastTyped:sub(1, length)) or self.lastTyped == text then
                self.lastTyped = text
                return
              end
              self.lastTyped = text
  
              -- Find first option which begins with text, if any
              if length > 0 then
                for _, option in pairs(self.props.options) do
                  if option:lower():sub(1, length) == text:lower() then
                    self.notTyped = true -- used as the Roact.Change.Text will fire again
                    rbx.Text = option
                    rbx.CursorPosition = length + 1
                    rbx.SelectionStart = option:len() + 1
                    break
                  end
                end
              end
            end,
  
            [Roact.Event.Focused] = function(rbx)
              rbx.CursorPosition = 0
              rbx.SelectionStart = rbx.Text:len() + 1
            end,
  
            [Roact.Event.FocusLost] = function(rbx)
              local actualOption = nil
              for _, option in pairs(self.props.options) do
                if rbx.Text:lower() == option:lower() then
                  actualOption = option
                  break
                end
              end
              if actualOption then
                self.props.OnOptionSelect(actualOption)
              else
                rbx.Text = self.props.currentOption
              end
            end,
          }),
  
          OpenClose = Roact.createElement("ImageButton", {
            Size = UDim2.fromOffset(BUTTON_SIZE, BUTTON_SIZE),
            BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Button),
            BorderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.ButtonBorder),
            Image = "rbxasset://textures/StudioToolbox/ArrowDownIconWhite.png",
            ImageColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainText),
            Rotation = self.state.open and 180 or 0,
            [Roact.Event.Activated] = function()
              self:setState({ open = not self.state.open })
            end,
          }),
        }),

        OptionsFrame = Roact.createElement("ScrollingFrame", {
          Visible = self.state.open,
          Size = UDim2.new(1, 0, 0, 100),
          Position = UDim2.new(0, 0, 1, 2),
          BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Dropdown),
          BorderSizePixel = 0,
          CanvasSize = self.dropdownCanvasSize:map(function(value)
            return UDim2.fromOffset(0, value)
          end),

          ScrollBarThickness = 8,
          TopImage = "rbxasset://textures/StudioToolbox/ScrollBarTop.png",
          MidImage = "rbxasset://textures/StudioToolbox/ScrollBarMiddle.png",
          BottomImage = "rbxasset://textures/StudioToolbox/ScrollBarBottom.png",
          -- ScrollBarImageColor3 = theme:GetColor(Enum.StudioStyleGuideColor.ScrollBar), TODO: this colour is really bad...
          VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
        }, DropdownChildren)
      })
    end
  })
end

return TextDropdown
