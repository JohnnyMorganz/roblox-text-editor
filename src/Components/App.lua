local TextEditor = script:FindFirstAncestor("TextEditor")
local ChangeHistoryService = game:GetService("ChangeHistoryService")
local Roact = require(TextEditor.Packages.Roact)
local RoactRodux = require(TextEditor.Packages.RoactRodux)
local Llama = require(TextEditor.Packages.Llama)

local App = Roact.Component:extend("App")
local StudioThemeContext = require(script.Parent.StudioThemeContext)
local TextEditorComponent = require(script.Parent.TextEditor)
local ThemedTextLabel = require(script.Parent.TextLabel)
local ThemedTextButton = require(script.Parent.TextButton)

function App:init()
  local studioSettings = settings().Studio

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

function App:render()
  local Children = {}

  if self.props.TextItem then
    Children.TextEditor = Roact.createElement(TextEditorComponent, {
      updateHolderSize = self.updateHolderSize,
      pluginActions = self.props.pluginActions,
    })
  else
    Children.Label = Roact.createElement(ThemedTextLabel, {
      Text = "Select a TextLabel, TextButton or TextBox to edit",
      AnchorPoint = Vector2.new(0.5, 0.5),
      Position = UDim2.fromScale(0.5, 0.5)
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
            BackgroundColor3 = theme:GetColor("MainBackground", "Default"),
            Size = self.props.TextItem and UDim2.new(1, 0, 1, -35) or UDim2.fromScale(1, 1),
            CanvasSize = self.holderSize:map(function(value)
              return UDim2.fromOffset(0, value)
            end),
          }, Children),

          SaveButtonHolder = Roact.createElement("Frame", {
            LayoutOrder = 2,
            Size = UDim2.new(1, 0, 0, 35),
            BackgroundColor3 = theme:GetColor("MainBackground", "Default"),
            BorderColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Border),
            Visible = self.props.TextItem
          }, {
            Padding = Roact.createElement("UIPadding", {
              PaddingTop = UDim.new(0, 5),
              PaddingBottom = UDim.new(0, 5),
              PaddingLeft = UDim.new(0, 5),
              PaddingRight = UDim.new(0, 5),
            }),

            SaveButton = Roact.createElement(ThemedTextButton, {
              Name = "Save",
              Size = UDim2.fromScale(1, 1),
              AnchorPoint = Vector2.new(0, 1),
              Enabled = true,
              ShowPressed = true,
              OnClicked = function()
                self.props.TextItem.Text = self.labelText:getValue()
                ChangeHistoryService:SetWaypoint("Updated text")
              end,
            }),
          })
        })
      end
    })
  }, self.props[Roact.Children])
end

return RoactRodux.connect(
  function(state, props)
    if state.TextItem ~= props.TextItem then
      local newProps = Llama.Dictionary.copy(props)
      newProps.TextItem = state.TextItem
      return newProps
    end
    return props
  end
)(App)