-- Based off https://github.com/tiffany352/Roblox-Tag-Editor/blob/master/src/Components/TextLabel.lua
local TextService = game:GetService("TextService")
local TextEditor = script:FindFirstAncestor("TextEditor")
local Roact = require(TextEditor.Packages.Roact)

local StudioThemeContext = require(script.Parent.StudioThemeContext)
local TextBox = Roact.Component:extend("TextBox")

TextBox.defaultProps = {
  BackgroundTransparency = 1,
  ClipsDescendants = false,

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
  verticalSpacing = 10, -- Extra Y offset to add on if auto updating
}

function TextBox:init()
  self.autoUpdate = false
  self.size, self.updateSize = Roact.createBinding(UDim2.new())

  local size = self.props.Size
  if not size then
    self.autoUpdate = true
    if self.props.TextWrapped then
      size = UDim2.fromScale(1, 0)
    else
      local TextBounds = TextService:GetTextSize(typeof(self.props.Text) == "string" and self.props.Text or self.props.Text:getValue(), self.props.TextSize, self.props.Font, Vector2.new(math.huge, math.huge))
      size = UDim2.new(self.props.Width or UDim.new(0, TextBounds.X), UDim.new(0, TextBounds.Y + self.props.verticalSpacing * 2))
    end
  end
  self.size, self.updateSize = Roact.createBinding(size)
end

function TextBox:render()
  return Roact.createElement(StudioThemeContext.Consumer, {
    render = function(theme)
      return Roact.createElement("TextBox", {
        AnchorPoint = self.props.AnchorPoint,
        LayoutOrder = self.props.LayoutOrder,
        Position = self.props.Position,
        Size = self.size,
        BackgroundTransparency = self.props.BackgroundTransparency,
        BackgroundColor3 = theme:GetColor(self.props.themeType, self.props.themeModifier),
        BorderColor3 = theme:GetColor(self.props.borderThemeType, self.props.themeModifier),
        ClipsDescendants = self.props.ClipsDescendants,

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
        [Roact.Change.Text] = function(rbx, ...)
          if self.autoUpdate then
            local MaxWidth = self.props.TextWrapped and rbx.AbsoluteSize.X - 2 or math.huge
            local TextBounds = TextService:GetTextSize(rbx.Text, self.props.TextSize, self.props.Font, Vector2.new(MaxWidth, math.huge))
            self.updateSize(UDim2.new(self.props.TextWrapped and UDim.new(1, 0) or self.props.Width or UDim.new(0, TextBounds.X), UDim.new(0, TextBounds.Y + self.props.verticalSpacing * 2)))
          end

          if self.props[Roact.Change.Text] then
            self.props[Roact.Change.Text](rbx, ...)
          end
        end,
        [Roact.Change.SelectionStart] = self.props[Roact.Change.SelectionStart],
        [Roact.Change.CursorPosition] = self.props[Roact.Change.CursorPosition],
        [Roact.Event.Focused] = self.props[Roact.Event.Focused],
        [Roact.Event.FocusLost] = self.props[Roact.Event.FocusLost],
      }, self.props[Roact.Children])
    end
  })
end


return TextBox