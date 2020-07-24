-- Based off https://github.com/tiffany352/Roblox-Tag-Editor/blob/master/src/Components/TextLabel.lua
local TextService = game:GetService("TextService")
local TextEditor = script:FindFirstAncestor("TextEditor")
local Roact = require(TextEditor.Packages.Roact)

local StudioThemeContext = require(script.Parent.StudioThemeContext)
local TextLabel = Roact.Component:extend("TextLabel")

TextLabel.defaultProps = {
  BackgroundTransparency = 1,
  BorderSizePixel = 1,
  Visible = true,

  Font = Enum.Font.SourceSans,
  TextSize = 20,
  Text = "props.Text",
  TextWrapped = false,
  TextXAlignment = Enum.TextXAlignment.Left,
  TextYAlignment = Enum.TextYAlignment.Center,
  RichText = false,

  backgroundThemeType = Enum.StudioStyleGuideColor.MainBackground,
  themeType = Enum.StudioStyleGuideColor.MainText,
  themeModifier = Enum.StudioStyleGuideModifier.Default,
}

function TextLabel:init()
  local size = self.props.Size
  if not size then
    if self.props.TextWrapped then
      size = UDim2.fromScale(1, 0)
    else
      local TextBounds = TextService:GetTextSize(typeof(self.props.Text) == "string" and self.props.Text or self.props.Text:getValue(), self.props.TextSize, self.props.Font, Vector2.new(math.huge, math.huge))
      size = UDim2.new(self.props.Width or UDim.new(0, TextBounds.X), UDim.new(0, TextBounds.Y))
    end
  end
  self.size, self.updateSize = Roact.createBinding(size)
end

function TextLabel:render()
  return Roact.createElement(StudioThemeContext.Consumer, {
    render = function(theme)
      return Roact.createElement("TextLabel", {
        AnchorPoint = self.props.AnchorPoint,
        LayoutOrder = self.props.LayoutOrder,
        Position = self.props.Position,
        Size = self.size,
        BackgroundColor3 = self.props.BackgroundColor3 or theme:GetColor(self.props.backgroundThemeType, self.props.themeModifier),
        BackgroundTransparency = self.props.BackgroundTransparency,
        BorderSizePixel = self.props.BorderSizePixel,
        Visible = self.props.Visible,

        Font = self.props.Font,
        TextSize = self.props.TextSize,
        TextColor3 = self.props.TextColor3 or theme:GetColor(self.props.themeType, self.props.themeModifier),
        Text = self.props.Text,
        TextWrapped = self.props.TextWrapped,
        TextXAlignment = self.props.TextXAlignment,
        TextYAlignment = self.props.TextYAlignment,
        RichText = self.props.RichText,

        [Roact.Change.Text] = function(rbx, ...)
          local MaxWidth = self.props.TextWrapped and rbx.AbsoluteSize.X - 2 or math.huge
          local TextBounds = TextService:GetTextSize(rbx.Text, self.props.TextSize, self.props.Font, Vector2.new(MaxWidth, math.huge))
          self.updateSize(UDim2.new(self.props.TextWrapped and UDim.new(1, 0) or self.props.Width or UDim.new(0, TextBounds.X), UDim.new(0, TextBounds.Y)))
          if self.props[Roact.Change.Text] then
            self.props[Roact.Change.Text](rbx, ...)
          end
        end,
      })
    end
  })
end


return TextLabel