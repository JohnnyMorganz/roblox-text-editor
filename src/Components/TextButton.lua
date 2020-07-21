-- Based off https://github.com/CloneTrooper1019/Roblox-Client-Tracker/blob/roblox/BuiltInPlugins/GameSettings/RoactStudioWidgets/RoundTextButton.lua
--[[
	A button with rounded corners.

	Supports one of two styles:
		"Blue": A blue button with white text and no border.
		"White": A white button with black text and a black border.

	Props:
		bool Enabled = Whether or not this button can be clicked.
		UDim2 Size = UDim2.new(0, Constants.BUTTON_WIDTH, 0, Constants.BUTTON_HEIGHT)
		int LayoutOrder = The order this RoundTextButton will sort to when placed in a UIListLayout.
		string Name = The text to display in this Button.
		function OnClicked = The function that will be called when this button is clicked.
		function OnHoverChanged = The function that will be called when the hover state changes.
		variant Value = Data that can be accessed from the OnClicked callback.
		table Style = {
			ButtonColor,
			ButtonHoverColor,
			ButtonPressedColor,
			ButtonDisabledColor,
			TextColor,
			TextDisabledColor,
			BorderColor,
		}
		bool ShowPressed = Whether the button appears a different color when pressed
		Mouse = plugin mouse for changing the mouse icon
]]


local TextEditor = script:FindFirstAncestor("TextEditor")
local Roact = require(TextEditor.Packages.Roact)

local StudioThemeContext = require(script.Parent.StudioThemeContext)
local RoundTextButton = Roact.PureComponent:extend("RoundTextButton")

function RoundTextButton:init()
  self.state = {
    Hovering = false,
    Pressed = false
  }

  self.mouseEnter = function()
    if self.props.Enabled then
      self:mouseHoverChanged(true)
    end
  end

  self.mouseLeave = function()
    if self.props.Enabled then
      self:mouseHoverChanged(false)
      self:setState({
        Pressed = false,
      })
    end
  end
end

function RoundTextButton:mouseHoverChanged(hovering)
  if nil ~= self.props.OnHoverChanged then
    self.props.OnHoverChanged(self.props.Value, hovering)
  end

  self:setState({
    Hovering = hovering,
  })
end

function RoundTextButton:render()
  local active = self.props.Enabled
  local hovering = self.state.Hovering
  local match = self.props.BorderMatchesBackground

  return Roact.createElement(StudioThemeContext.Consumer, {
    render = function(theme)
      local style = {
        ButtonColor = theme:GetColor(Enum.StudioStyleGuideColor.MainButton),
        ButtonHoverColor = theme:GetColor(Enum.StudioStyleGuideColor.MainButton, Enum.StudioStyleGuideModifier.Hover),
        ButtonPressedColor = theme:GetColor(Enum.StudioStyleGuideColor.Button, Enum.StudioStyleGuideModifier.Pressed),
        ButtonDisabledColor = theme:GetColor(Enum.StudioStyleGuideColor.Button, Enum.StudioStyleGuideModifier.Disabled),
        TextColor = Color3.new(1, 1, 1),
        TextDisabledColor = theme:GetColor(Enum.StudioStyleGuideColor.DimmedText),
        BorderColor = theme:GetColor(Enum.StudioStyleGuideColor.Light),
      }
    
      local backgroundProps = {
        -- Necessary to make the rounded background
        BackgroundTransparency = 1,
        Image = "rbxasset://textures/StudioToolbox/RoundedBackground.png",
        ImageTransparency = 0,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(3, 3, 13, 13),
    
        Position = UDim2.new(0, 0, 0, 0),
        Size = self.props.Size or UDim2.new(0, 125, 0, 35),
    
        LayoutOrder = self.props.LayoutOrder or 1,
        ZIndex = self.props.ZIndex or 1,
    
        [Roact.Event.MouseEnter] = self.mouseEnter,
        [Roact.Event.MouseLeave] = self.mouseLeave,
    
        [Roact.Event.Activated] = function()
          if active then
            self.props.OnClicked(self.props.Value)
          end
        end,
    
        [Roact.Event.InputBegan] = function(_rbx, input)
          if active and input.UserInputType == Enum.UserInputType.MouseButton1 then
            self:setState({
              Pressed = true,
            })
          end
        end,
    
        [Roact.Event.InputEnded] = function(_rbx, input)
          if active and input.UserInputType == Enum.UserInputType.MouseButton1 then
            self:setState({
              Pressed = false,
            })
          end
        end
      }
    
      if active then
        if self.props.ShowPressed and self.state.Pressed then
          backgroundProps.ImageColor3 = style.ButtonPressedColor
        else
          backgroundProps.ImageColor3 = hovering and style.ButtonHoverColor or style.ButtonColor
        end
      else
        backgroundProps.ImageColor3 = style.ButtonDisabledColor
      end

      return Roact.createElement("ImageButton", backgroundProps, {
        Border = Roact.createElement("ImageLabel", {
          Size = UDim2.new(1, 0, 1, 0),
          BackgroundTransparency = 1,
          Image = "rbxasset://textures/StudioToolbox/RoundedBorder.png",
          ImageColor3 = match and backgroundProps.ImageColor3 or style.BorderColor,
          ScaleType = Enum.ScaleType.Slice,
          SliceCenter = Rect.new(3, 3, 13, 13),
          ZIndex = self.props.ZIndex or 1,
        }),
  
        Text = Roact.createElement("TextLabel", {
          Size = UDim2.new(1, 0, 1, 0),
          BackgroundTransparency = 1,
          BorderSizePixel = 0,
          Font = Enum.Font.SourceSans,
          TextColor3 = active and style.TextColor or style.TextDisabledColor,
          TextSize = 22,
          Text = self.props.Name,
          ZIndex = self.props.ZIndex or 1,
        }),
      })
    end
  })
end

return RoundTextButton