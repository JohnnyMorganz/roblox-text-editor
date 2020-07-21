local Selection = game:GetService("Selection")
local TextEditor = script:FindFirstAncestor("TextEditor")

local Roact = require(TextEditor.Packages.Roact)
local Rodux = require(TextEditor.Packages.Rodux)
local RoactRodux = require(TextEditor.Packages.RoactRodux)
local Maid = require(TextEditor.Packages.Maid)
local Reducer = require(TextEditor.Plugin.Reducer)
local App = require(TextEditor.Plugin.Components.App)

local textEditorWidgetInfo = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, false, false, 200, 300, 150, 150)
local toolbar = plugin:CreateToolbar("Text Editor")
local textEditorButton = toolbar:CreateButton("Open Text Editor", "Open the text editor", "rbxassetid://4459262762")
local textEditorActions = {
  toggleOpen = plugin:CreatePluginAction("TextEditorToggleOpen", "Text Editor: Toggle Open", "Toggles the text editor to open/close", "rbxassetid://4459262762", true),
  -- toggleBold = plugin:CreatePluginAction("TextEditorToggleBold", "Text Editor: Toggle Bold", "Toggles bold in the text editor", "rbxassetid://4459262762", true),
  -- toggleItalic = plugin:CreatePluginAction("TextEditorToggleItalic", "Text Editor: Toggle Italic", "Toggles italic in the text editor", "rbxassetid://4459262762", true),
  -- toggleUnderline = plugin:CreatePluginAction("TextEditorToggleUnderline", "Text Editor: Toggle Underline", "Toggles underline in the text editor", "rbxassetid://4459262762", true),
  -- toggleStrikethrough = plugin:CreatePluginAction("TextEditorToggleStrikethrough", "Text Editor: Toggle Strikethrough", "Toggles strikethrough in the text editor", "rbxassetid://4459262762", true),
}
local textEditorWidget = plugin:CreateDockWidgetPluginGui("TextEditorWidget", textEditorWidgetInfo)
textEditorWidget.Name = "TextEditor"
textEditorWidget.Title = "Text Editor"
textEditorWidget.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
textEditorButton:SetActive(textEditorWidget.Enabled)

local pluginMaid = Maid.new()
local store = Rodux.Store.new(Reducer, {})

local app = Roact.createElement(RoactRodux.StoreProvider, {
  store = store,
}, {
  App = Roact.createElement(App)
})

local roactTree = Roact.mount(app, textEditorWidget, "TextEditor")

local function getSelectedObject()
  local items = Selection:Get()
  if #items > 0 then
    local textItem = items[1]
    if textItem:IsA("TextLabel") or textItem:IsA("TextButton") or textItem:IsA("TextBox") then
      store:dispatch({ type = "setTextItem", item = textItem })
    else
      store:dispatch({ type = "setTextItem", item = nil })
    end
  else
    store:dispatch({ type = "setTextItem", item = nil })
  end
end

local function selectionChanged()
  if textEditorWidget.Enabled then
    getSelectedObject()
  end
end

local function onButtonClick()
  textEditorWidget.Enabled = not textEditorWidget.Enabled
  textEditorButton:SetActive(textEditorWidget.Enabled)
  if textEditorWidget.Enabled then
    getSelectedObject()
  end
end

textEditorWidget:BindToClose(function()
  textEditorButton:SetActive(false)
end)

pluginMaid:GiveTask(textEditorButton.Click:Connect(onButtonClick))
pluginMaid:GiveTask(textEditorActions.toggleOpen.Triggered:Connect(onButtonClick))
pluginMaid:GiveTask(Selection.SelectionChanged:Connect(selectionChanged))

plugin.Unloading:Connect(function()
  Roact.unmount(roactTree)
  pluginMaid:DoCleaning()
end)