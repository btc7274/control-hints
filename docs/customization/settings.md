---
icon: material/cog
---

# Settings

These settings can be found in the `Settings` ModuleScript under `Configuration`. This is a good starting point for changing style and behavior.

| Name                        | Type     | Default      | Description |
|--------------------------------|----------|--------------|-----------|
| `ICON_SET`                     | table    | Kenney       | Icon set to use for keyboard, gamepad, and mobile. |
| `DISPLAY_STYLE`                | ScreenGui | Classic      | Visual layout template for the hints container. |
| `ENABLED_DEVICES`              | table    | all true     | Set `Keyboard`, `Gamepad`, or `Mobile` to false to hide every hint from players using that device. |
| `DEBUG`                        | boolean  | false      | Enables detailed non-critical warnings. |
| `INCREMENT`                    | number   | 1            | LayoutOrder increment between hint elements (not between hints themselves). |
| `ENABLE_RESPONSIVE`            | boolean  | true       | Enables visual feedback for pressed actions using `_pressed` icons. |
| `ENABLE_DYNAMIC_SCALING`       | boolean  | true       | Enables automatic scaling of font and icon size for console users. |
| `MIN_SCREEN_WIDTH`             | number   | 1080         | Screen width where dynamic scaling begins. |
| `MAX_SCREEN_WIDTH`             | number   | 1920         | Screen width where dynamic scaling stops. |
| `BASE_FONT_SIZE`               | number   | 16           | Base font size for action labels. |
| `BASE_ICON_SIZE`               | number   | 30           | Base size for icons. |
| `MAX_SCALE_FACTOR`             | number   | 1.4          | Maximum scale multiplier for dynamic scaling. |
