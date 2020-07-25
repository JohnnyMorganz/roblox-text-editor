-- Dropdown with an editable TextBox to type option
local TextEditor = script:FindFirstAncestor("TextEditor")
local Roact = require(TextEditor.Packages.Roact)

local StudioThemeContext = require(script.Parent.Parent.StudioThemeContext)
local DropdownItem = Roact.Component:extend("DropdownItem")

DropdownItem.defaultProps = {
  Text = "props.Text",
  TextSize = 14,
  selected = false,
  height = 15,
}

function DropdownItem:init()
  self:setState({
    hovered = false,
  })
end

function DropdownItem:render()
  return Roact.createElement(StudioThemeContext.Consumer, {
    render = function(theme)
      local state = Enum.StudioStyleGuideModifier.Default
      if self.props.selected then
        state = Enum.StudioStyleGuideModifier.Selected
      elseif self.state.hovered then
        state = Enum.StudioStyleGuideModifier.Hover
      end

      return Roact.createElement("TextButton", {
        AutoButtonColor = false,
        BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Item, state),
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, self.props.height),
        Font = Enum.Font.SourceSans,
        Text = self.props.Text,
        TextSize = self.props.TextSize,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainText),

        [Roact.Event.MouseEnter] = function()
          self:setState({ hovered = true })
        end,

        [Roact.Event.MouseLeave] = function()
          self:setState({ hovered = false })
        end,

        [Roact.Event.Activated] = function()
          self.props.OnSelected(self.props.Text)
        end,
      })
    end
  })
end

return DropdownItem