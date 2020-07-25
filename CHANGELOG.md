# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased
### Added
- The input TextBox now scales vertically as more text is added
- Added listening to relevant TextItem properties for changes incase they are not changed through the Text Editor
- Added better ChangeHistoryService support for text (and other Text related properties currently handled by the Editor) changes
- Added ability to change Font and TextSize

### Fixed
- Added TextWrapped to the "Select a TextLabel..." message

### Changed
- Switched from saving using button to saving when Textbox loses focus to quicken workflow
- Cleanup internal code

## [1.1.1] - 2020-07-24
### Fixed
- Fixed widget not closing when pressing the "X" button

### Changed
- Changed the wording of the Save button from "Save" to "Apply"

## [1.1.0] - 2020-07-23
### Added
- Added support for updating TextXAlignment
- Added tooltips to all toolbar buttons

## [1.0.0] - 2020-07-22
### Added
- Initial release