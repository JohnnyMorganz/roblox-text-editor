local TextEditor = script:FindFirstAncestor("TextEditor")
local Roact = require(TextEditor.Packages.Roact)

local studioSettings = settings().Studio
local StudioThemeContext = Roact.createContext(studioSettings.Theme)

return StudioThemeContext