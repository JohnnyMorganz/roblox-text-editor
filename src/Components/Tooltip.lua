-- Based off https://github.com/tiffany352/Roblox-Tag-Editor/blob/master/src/Components/TextLabel.lua
local TextService = game:GetService("TextService")
local TextEditor = script:FindFirstAncestor("TextEditor")
local Roact = require(TextEditor.Packages.Roact)

local StudioThemeContext = require(script.Parent.StudioThemeContext)
local Tooltip = Roact.Component:extend("Tooltip")

local TEXT_MARGIN = 5

Tooltip.defaultProps = {
  BackgroundTransparency = 0,
  BorderSizePixel = 0,
  Visible = true,

  RichText = false,
  Font = Enum.Font.SourceSans,
  TextSize = 20,
  Text = "props.Text",
  TextXAlignment = Enum.TextXAlignment.Left,
  TextYAlignment = Enum.TextYAlignment.Center,
  ZIndex = 1,

  themeType = Enum.StudioStyleGuideColor.MainText,
  themeModifier = Enum.StudioStyleGuideModifier.Default,
}

function Tooltip:render()
  local Size = self.props.Size
  if not Size then
    local TextBounds = TextService:GetTextSize(self.props.Text, self.props.TextSize, self.props.Font, Vector2.new(math.huge, math.huge))
    Size = UDim2.new(self.props.Width or UDim.new(0, TextBounds.X + TEXT_MARGIN * 2), UDim.new(0, TextBounds.Y + TEXT_MARGIN * 2))
  end

  return Roact.createElement(StudioThemeContext.Consumer, {
    render = function(theme)
      return Roact.createElement("Frame", {
        AnchorPoint = self.props.AnchorPoint,
        LayoutOrder = self.props.LayoutOrder,
        Position = self.props.Position,
        Size = Size,
        BackgroundColor3 = self.props.BackgroundColor3 or theme:GetColor(Enum.StudioStyleGuideColor.Tooltip),
        BackgroundTransparency = self.props.BackgroundTransparency,
        BorderSizePixel = self.props.BorderSizePixel,
        Visible = self.props.Visible,
        ZIndex = self.props.ZIndex,
      }, {
        Padding = Roact.createElement("UIPadding", {
          PaddingTop = UDim.new(0, TEXT_MARGIN),
          PaddingBottom = UDim.new(0, TEXT_MARGIN),
          PaddingLeft = UDim.new(0, TEXT_MARGIN),
          PaddingRight = UDim.new(0, TEXT_MARGIN),
        }),

        Label = Roact.createElement("TextLabel", {
          BackgroundTransparency = 1,
          Size = UDim2.fromScale(1, 1),

          Font = self.props.Font,
          TextSize = self.props.TextSize,
          TextColor3 = self.props.TextColor3 or theme:GetColor(self.props.themeType, self.props.themeModifier),
          Text = self.props.Text,
          TextWrapped = self.props.TextWrapped,
          TextXAlignment = self.props.TextXAlignment,
          TextYAlignment = self.props.TextYAlignment,
          RichText = self.props.RichText,
          ZIndex = self.props.ZIndex,
        }),
      })
    end
  })
end

return Tooltip