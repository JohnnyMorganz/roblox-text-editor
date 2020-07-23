-- Based off https://github.com/tiffany352/Roblox-Tag-Editor/blob/master/src/Components/TextLabel.lua
local TextService = game:GetService("TextService")
local TextEditor = script:FindFirstAncestor("TextEditor")
local Roact = require(TextEditor.Packages.Roact)

local StudioThemeContext = require(script.Parent.StudioThemeContext)

local function TextLabel(props)
  local update
  local autoSize = not props.Size

  if props.TextWrapped then
    function update(rbx)
      if not rbx then return end
      local width = rbx.AbsoluteSize.x
      local tb = TextService:GetTextSize(rbx.Text, rbx.TextSize, rbx.Font, Vector2.new(width - 2, 100000))
      rbx.Size = UDim2.new(1, 0, 0, tb.y)
    end
  else
    function update(rbx)
      if not rbx then return end
      local tb = TextService:GetTextSize(rbx.Text, rbx.TextSize, rbx.Font, Vector2.new(100000, 100000))
      rbx.Size = UDim2.new(props.Width or UDim.new(0, tb.x), UDim.new(0, tb.y))
    end
  end

  return Roact.createElement(StudioThemeContext.Consumer, {
    render = function(theme)
      return Roact.createElement("TextLabel", {
        AnchorPoint = props.AnchorPoint,
        LayoutOrder = props.LayoutOrder,
        Position = props.Position,
        Size = props.Size or props.TextWrapped and UDim2.new(1, 0, 0, 0) or nil,
        BackgroundColor3 = props.BackgroundColor3 or theme:GetColor(Enum.StudioStyleGuideColor.MainBackground),
        BackgroundTransparency = props.BackgroundTransparency or 1,
        BorderSizePixel = props.BorderSizePixel or 1,
        Visible = props.Visible == nil or true,

        Font = props.Font or Enum.Font.SourceSans,
        TextSize = props.TextSize or 20,
        TextColor3 = props.TextColor3 or theme:GetColor(props.themeType or Enum.StudioStyleGuideColor.MainText, props.themeModifier or Enum.StudioStyleGuideModifier.Default),
        Text = props.Text or "[NO TEXT PRESENT]",
        TextWrapped = props.TextWrapped,
        TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left,
        TextYAlignment = props.TextYAlignment or Enum.TextYAlignment.Center,
        RichText = props.RichText or false,

        [Roact.Ref] = autoSize and update or nil,
        [Roact.Change.TextBounds] = autoSize and update or nil,
        [Roact.Change.AbsoluteSize] = autoSize and update or nil,
        [Roact.Change.Parent] = autoSize and update or nil,
        [Roact.Change.Text] = props.OnTextChange or nil,
      })
    end
  })
end


return TextLabel