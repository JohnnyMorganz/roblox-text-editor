local TextEditor = script:FindFirstAncestor("TextEditor")
local Roact = require(TextEditor.Packages.Roact)
local RoactRodux = require(TextEditor.Packages.RoactRodux)
local Llama = require(TextEditor.Packages.Llama)

local App = Roact.Component:extend("App")
local StudioThemeContext = require(script.Parent.StudioThemeContext)
local TextEditorComponent = require(script.Parent.TextEditor)
local ThemedTextLabel = require(script.Parent.TextLabel)

function App:init()
  local studioSettings = settings().Studio

  self.labelText, self.updateLabelText = Roact.createBinding("")
  self.holderSize, self.updateHolderSize = Roact.createBinding(0)
  self:setState({ 
    theme = studioSettings.Theme
  })
end

function App:didMount()
  local studioSettings = settings().Studio
  self._themeConnection = studioSettings.ThemeChanged:Connect(function()
    self:setState({ 
      theme = studioSettings.Theme
    })
  end)
end

function App:willUnmount()
  self._themeConnection:Disconnect()
end

function App:willUpdate(newProps, _newState)
  if newProps.TextItem ~= self.props.TextItem then
    self.updateLabelText(newProps.TextItem and newProps.TextItem.Text or "")
  end
end

function App:render()
  local Children = {}

  if self.props.TextItem then
    Children.TextEditor = Roact.createElement(TextEditorComponent, {
      updateHolderSize = self.updateHolderSize,
      pluginActions = self.props.pluginActions,
      labelText = self.labelText,
      updateLabelText = self.updateLabelText,
    })
  else
    Children.Label = Roact.createElement(ThemedTextLabel, {
      Text = "Select a TextLabel, TextButton or TextBox to edit",
      AnchorPoint = Vector2.new(0.5, 0.5),
      Position = UDim2.fromScale(0.5, 0.5),
      TextWrapped = true,
      TextXAlignment = Enum.TextXAlignment.Center,
    })
  end

  return Roact.createElement(StudioThemeContext.Provider, {
    value = self.state.theme
  }, {
    Holder = Roact.createElement(StudioThemeContext.Consumer, {
      render = function(theme)
        return Roact.createFragment({
          Layout = Roact.createElement("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
          }),

          Holder = Roact.createElement("ScrollingFrame", {
            LayoutOrder = 1,
            BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainBackground, Enum.StudioStyleGuideModifier.Default),
            BorderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Border),
            Size = UDim2.fromScale(1, 1), -- self.props.TextItem and UDim2.new(1, 0, 1, -35) or UDim2.fromScale(1, 1),
            CanvasSize = self.holderSize:map(function(value)
              return UDim2.fromOffset(0, value)
            end),
            ScrollBarThickness = 8,
            TopImage = "rbxasset://textures/StudioToolbox/ScrollBarTop.png",
            MidImage = "rbxasset://textures/StudioToolbox/ScrollBarMiddle.png",
            BottomImage = "rbxasset://textures/StudioToolbox/ScrollBarBottom.png",
            -- ScrollBarImageColor3 = theme:GetColor(Enum.StudioStyleGuideColor.ScrollBar), TODO: this colour is really bad...
            VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
          }, Children),
        })
      end
    })
  }, self.props[Roact.Children])
end

return RoactRodux.connect(
  function(state, props)
    local newProps = Llama.Dictionary.copy(props)
    newProps.TextItem = state.TextItem
    newProps.TextXAlignment = state.TextXAlignment
    return newProps
  end
)(App)