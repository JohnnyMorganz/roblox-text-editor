-- Based off https://github.com/tiffany352/Roblox-Tag-Editor/blob/master/src/Components/TextLabel.lua
local TextService = game:GetService("TextService")
local TextEditor = script:FindFirstAncestor("TextEditor")
local Roact = require(TextEditor.Packages.Roact)

local StudioThemeContext = require(script.Parent.StudioThemeContext)
local TextBox = Roact.Component:extend("TextBox")

TextBox.defaultProps = {
  BackgroundTransparency = 1,

  Font = Enum.Font.SourceSans,
  TextSize = 20,
  Text = "",
  TextWrapped = false,
  TextXAlignment = Enum.TextXAlignment.Left,
  TextYAlignment = Enum.TextYAlignment.Center,
  ClearTextOnFocus = true,
  MultiLine = false,
  RichText = false,

  themeType = Enum.StudioStyleGuideColor.InputFieldBackground,
  borderThemeType = Enum.StudioStyleGuideColor.InputFieldBorder,
  textThemeType = Enum.StudioStyleGuideColor.MainText,
  themeModifier = Enum.StudioStyleGuideModifier.Default,
}

function TextBox:render()
  local size = self.props.Size
  if not size then
    local TextBounds = TextService:GetTextSize(self.props.Text, self.props.TextSize, self.props.Font, Vector2.new(math.huge, math.huge))
    size = UDim2.new(self.props.Width or UDim.new(0, TextBounds.X), UDim.new(0, TextBounds.Y))
  end

  return Roact.createElement(StudioThemeContext.Consumer, {
    render = function(theme)
      return Roact.createElement("TextBox", {
        AnchorPoint = self.props.AnchorPoint,
        LayoutOrder = self.props.LayoutOrder,
        Position = self.props.Position,
        Size = size,
        BackgroundTransparency = self.props.BackgroundTransparency,
        BackgroundColor3 = theme:GetColor(self.props.themeType, self.props.themeModifier),
        BorderColor3 = theme:GetColor(self.props.borderThemeType, self.props.themeModifier),

        Font = self.props.Font,
        TextSize = self.props.TextSize,
        TextColor3 = theme:GetColor(self.props.textThemeType, self.props.themeModifier),
        Text = self.props.Text,
        TextWrapped = self.props.TextWrapped,
        TextXAlignment = self.props.TextXAlignment,
        TextYAlignment = self.props.TextYAlignment,
        ClearTextOnFocus = self.props.ClearTextOnFocus,
        MultiLine = self.props.MultiLine,
        RichText = self.props.RichText,

        [Roact.Ref] = self.props[Roact.Ref],
        [Roact.Change.Text] = self.props[Roact.Change.Text],
        [Roact.Change.SelectionStart] = self.props[Roact.Change.SelectionStart],
        [Roact.Change.CursorPosition] = self.props[Roact.Change.CursorPosition],
        [Roact.Event.FocusLost] = self.props[Roact.Event.FocusLost],
      })
    end
  })
end


return TextBox