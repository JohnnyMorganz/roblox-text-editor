local TextEditor = script:FindFirstAncestor("TextEditor")
local Roact = require(TextEditor.Packages.Roact)

local StudioThemeContext = require(script.Parent.StudioThemeContext)

local function ToolbarButton(props)
  return Roact.createElement(StudioThemeContext.Consumer, {
    render = function(theme)
      local elementProps = {
        LayoutOrder = props.LayoutOrder,
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.RibbonButton, props.IsSelected and Enum.StudioStyleGuideModifier.Selected or Enum.StudioStyleGuideModifier.Default),
        BorderSizePixel = 0,

        [Roact.Event.Activated] = props.OnClick,
      }

      if props.type == "ImageButton" then
        elementProps.Image = props.Image
        elementProps.ImageColor3 = theme:GetColor(Enum.StudioStyleGuideColor.TitlebarText)
      else
        elementProps.Text = props.Text
        elementProps.TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.TitlebarText)
        elementProps.RichText = true
      end

      return Roact.createElement(props.type or "TextButton", elementProps, {
        AspectRatio = Roact.createElement("UIAspectRatioConstraint"),
      })
    end
  })
end

return ToolbarButton