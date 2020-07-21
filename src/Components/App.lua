local TextEditor = script:FindFirstAncestor("TextEditor")
local ChangeHistoryService = game:GetService("ChangeHistoryService")
local Roact = require(TextEditor.Packages.Roact)
local RoactRodux = require(TextEditor.Packages.RoactRodux)
local Llama = require(TextEditor.Packages.Llama)

local App = Roact.Component:extend("App")
local StudioThemeContext = require(script.Parent.StudioThemeContext)
local Section = require(script.Parent.Section)
local ThemedTextLabel = require(script.Parent.TextLabel)
local ThemedTextBox = require(script.Parent.TextBox)
local ThemedTextButton = require(script.Parent.TextButton)

function App:init()
  local studioSettings = settings().Studio

  self.holderSize, self.updateHolderSize = Roact.createBinding(0)
  self.labelText, self.updateLabelText = Roact.createBinding("")
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
    self.updateLabelText(self.props.TextItem.Text)

    Children.Padding = Roact.createElement("UIPadding", {
      PaddingLeft = UDim.new(0, 5),
      PaddingRight = UDim.new(0, 5),
      PaddingTop = UDim.new(0, 5),
      PaddingBottom = UDim.new(0, 5),
    })

    Children.Layout = Roact.createElement("UIListLayout", {
      Padding = UDim.new(0, 5),
      SortOrder = Enum.SortOrder.LayoutOrder,
      [Roact.Change.AbsoluteContentSize] = function(rbx)
        self.updateHolderSize(rbx.AbsoluteContentSize.Y)
      end,
    })

    Children.TextBox = Roact.createElement(ThemedTextBox, {
      LayoutOrder = 2,
      Text = self.props.TextItem.Text,
      ClearTextOnFocus = false,
      MultiLine = true,
      Size = UDim2.new(1, 0, 0.5, 0),
      BackgroundTransparency = 0,

      OnTextChange = function(rbx)
        self.updateLabelText(rbx.Text)
      end
    })

    Children.Output = Roact.createElement(Section, {
      LayoutOrder = 3,
      Title = "Output",
    }, {
      Padding = Roact.createElement("UIPadding", {
        PaddingTop = UDim.new(0, 5),
        PaddingBottom = UDim.new(0, 5),
      }),

      OutputLabel = Roact.createElement(ThemedTextLabel, {
        BackgroundTransparency = 1,
        Text = self.labelText,
        RichText = true,
        Width = UDim.new(1, 0),
        
        -- Copy the label text
        Font = self.props.TextItem.Font,
        TextColor3 = self.props.TextItem.TextColor3,
        TextSize = self.props.TextItem.TextSize,
        TextStrokeColor3 = self.props.TextItem.TextStrokeColor3,
        TextStrokeTransparency = self.props.TextItem.TextStrokeTransparency,
        TextTransparency = self.props.TextItem.TextTransparency,
        TextXAlignment = self.props.TextItem.TextXAlignment,
      })
    })

    Children.Save = Roact.createElement(ThemedTextButton, {
      LayoutOrder = 4,
      Name = "Save",
      Size = UDim2.new(1, 0, 0, 35),
      AnchorPoint = Vector2.new(0, 1),
      Enabled = true,
      ShowPressed = true,
      OnClicked = function()
        self.props.TextItem.Text = self.labelText:getValue()
        ChangeHistoryService:SetWaypoint("Updated text")
      end,
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
        return Roact.createElement("ScrollingFrame", {
          BackgroundColor3 = theme:GetColor("MainBackground", "Default"),
          Size = UDim2.fromScale(1, 1),
          CanvasSize = self.holderSize:map(function(value)
            return UDim2.fromOffset(0, value)
          end),
        }, Children)
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