local TextEditor = script:FindFirstAncestor("TextEditor")
local Roact = require(TextEditor.Packages.Roact)

local StudioThemeContext = require(script.Parent.StudioThemeContext)
local ThemedTextLabel = require(script.Parent.TextLabel)
local Section = Roact.Component:extend("Section")

function Section:init()
  self.lastClickTime = 0
  self.mainSizeY, self.updateMainSizeY = Roact.createBinding(0)
  self.contentsSizeY, self.updateContentsSizeY = Roact.createBinding(0)
  self.minimized, self.updateMinimized = Roact.createBinding(false)
end

function Section:render()
  local ContentsChildren = self.props[Roact.Children]
  ContentsChildren.Layout = Roact.createElement("UIListLayout", {
    SortOrder = Enum.SortOrder.LayoutOrder,
    [Roact.Change.AbsoluteContentSize] = function(rbx)
      self.updateContentsSizeY(rbx.AbsoluteContentSize.Y)
    end,
  })

  return Roact.createElement(StudioThemeContext.Consumer, {
    render = function(theme)
      return Roact.createElement("Frame", {
        LayoutOrder = self.props.LayoutOrder,
        BackgroundTransparency = 1,
        Size = self.mainSizeY:map(function(value)
          return UDim2.new(1, 0, 0, value)
        end),
      }, {
        ListLayout = Roact.createElement("UIListLayout", {
          SortOrder = Enum.SortOrder.LayoutOrder,
          [Roact.Change.AbsoluteContentSize] = function(rbx)
            self.updateMainSizeY(rbx.AbsoluteContentSize.Y)
          end,
        }),

        TitleBar = Roact.createElement("ImageButton", {
          LayoutOrder = 1,
          -- AutoButtonColor = false,
          BorderSizePixel = 0,
          Size = UDim2.new(1, 0, 0, 27),
          BackgroundColor3 = theme:GetColor("Titlebar"),
          [Roact.Event.MouseButton1Down] = function()
            local now = tick()
            if now - self.lastClickTime < 0.5 then
              self.updateMinimized(not self.minimized:getValue())
              self.lastClickTime = 0
            else
              self.lastClickTime = now
            end
          end,
        }, {
          Label = Roact.createElement(ThemedTextLabel, {
            Text = self.props.Title,
            Font = Enum.Font.SourceSansBold,
            TextSize = 15,
            TextXAlignment = Enum.TextXAlignment.Left,
            Position = UDim2.new(0, 27, 0, 0),
            Size = UDim2.new(1, -27, 1, -3),
          }),

          Button = Roact.createElement("ImageButton", {
            Image = self.minimized:map(function(value)
              return value and "rbxasset://textures/TerrainTools/button_arrow.png" or "rbxasset://textures/TerrainTools/button_arrow_down.png"
            end),
            Size = UDim2.fromOffset(9, 9),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0, 27 / 2, 0, 27 / 2),
            BackgroundTransparency = 1,
            [Roact.Event.Activated] = function()
              self.updateMinimized(not self.minimized:getValue())
            end,
          })
        }),

        Contents = Roact.createElement("Frame", {
          LayoutOrder = 2,
          BackgroundTransparency = 1,
          Size = self.contentsSizeY:map(function(value)
            return UDim2.new(1, 0, 0, value)
          end),
          Visible = self.minimized:map(function(value)
            return not value
          end),
        }, ContentsChildren)
      })
    end
  })
end

return Section