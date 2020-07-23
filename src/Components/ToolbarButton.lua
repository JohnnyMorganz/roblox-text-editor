local TextEditor = script:FindFirstAncestor("TextEditor")
local Roact = require(TextEditor.Packages.Roact)

local StudioThemeContext = require(script.Parent.StudioThemeContext)
local ToolbarButton = Roact.Component:extend("ToolbarButton")
local Tooltip = require(script.Parent.Tooltip)

function ToolbarButton:init()
  self:setState({
    hovered = false,
  })
end

function ToolbarButton:render()
  return Roact.createElement(StudioThemeContext.Consumer, {
    render = function(theme)
      local elementProps = {
        LayoutOrder = self.props.LayoutOrder,
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.RibbonButton, self.props.IsSelected and Enum.StudioStyleGuideModifier.Selected or Enum.StudioStyleGuideModifier.Default),
        BorderSizePixel = 0,

        [Roact.Event.Activated] = self.props.OnClick,
        [Roact.Event.MouseEnter] = function()
          self:setState({ hovered = true })
        end,
        [Roact.Event.MouseLeave] = function()
          self:setState({ hovered = false })
        end,
      }

      if self.props.type == "ImageButton" then
        elementProps.Image = self.props.Image
        elementProps.ImageColor3 = theme:GetColor(Enum.StudioStyleGuideColor.TitlebarText)
      else
        elementProps.Text = self.props.Text
        elementProps.TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.TitlebarText)
        elementProps.RichText = true
      end

      return Roact.createElement(self.props.type or "TextButton", elementProps, {
        AspectRatio = Roact.createElement("UIAspectRatioConstraint"),

        ToolTip = self.props.Tooltip and Roact.createElement(Tooltip, {
          Text = self.props.Tooltip,
          TextSize = 14,
          Position = UDim2.new(0, 5, 1, 5),
          RichText = true,
          ZIndex = 5,
          Visible = self.state.hovered,
        }) or nil
      })
    end
  })
end

return ToolbarButton