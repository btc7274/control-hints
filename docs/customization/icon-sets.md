# Icon Sets

## Overview

Icon sets can be found under the `IconSets` Folder under `Configuration`. These are ModuleScripts that contain tables for each platform, keyed by KeyCode and pointing to an `rbxassetid://` string.

Control Hints reads the selected icon set from `Settings` for a certain platform and KeyCode, then displays an icon or prints a warning.

??? info "Preview Icon Sets"
    Control Hints comes with 3 icon sets:
    
    <div class="grid cards" markdown>
    
    - `Kenney`
    
        [Kenney Input Prompts v1.4](https://kenney.nl/assets/input-prompts). Default icon set for Control Hints.
    
        ![Kenney Icon Set Preview](../images/icon-sets/Kenney.png){.icon-preview}
    
        *Includes pressed icons:*
    
        ![Kenney Icon Set Pressed Preview](../images/icon-sets/Kenney_Pressed.png){.icon-preview}
    
    - `Xelu_Dark`
    
        Dark icon set from [Xelu Free Controller & Key Prompts](https://github.com/mklabs/ue-xelu-icons). Commonly used in Roblox games.
    
        ![Xelu_Dark Icon Set Preview](../images/icon-sets/Xelu_Dark.png){.icon-preview}
    
    - `Xelu_Light`
    
        Light icon set from [Xelu Free Controller & Key Prompts](https://github.com/mklabs/ue-xelu-icons). Commonly used in Roblox games.
    
        ![Xelu_Light Icon Set Preview](../images/icon-sets/Xelu_Light.png){.icon-preview}
    
    </div>

Icon sets may also include tables with a `_pressed` suffix, which indicates an alternate set of icons for use when an InputAction is Pressed. To toggle this functionality, set `ENABLE_RESPONSIVE` in [`Settings`](settings.md) to true/false.

## Creating Icon Sets

Icon sets are designed to be extensible and flexible for your game.

### Platform Tables

An icon set consists of several tables whose names correspond to a certain platform the player may be on. The available platform types are:

- `keyboard`: PC players.
- `xbox`: Console players on Xbox.
- `ps`: Console players on PlayStation.
- `mobile`: Mobile players.

Each platform table should be a dictionary, with an `Enum.KeyCode` key and an `rbxassetid://` string value. For example:

```luau
-- Keyboard / Mouse icons
iconSet.keyboard = {
    [Enum.KeyCode.A] = "rbxassetid://117056368827812",
	[Enum.KeyCode.B] = "rbxassetid://74240184806752",
	[Enum.KeyCode.C] = "rbxassetid://134893867998488"
}
```

At runtime, Control Hints will lookup a table for a given platform, then find the `rbxassetid://` string value for an `Enum.KeyCode` key. If one is found, an icon will be displayed (otherwise, a warning is produced).

Because Control Hints only uses icons when it needs them, there is no need to have icons for every platform or KeyCode. Therefore, if you are making a custom icon set, it is recommended to only include icons your game will likely use.

### Responsive Icons

Control Hints supports responsive icons where a hint will switch icons to an active/solid variant when its InputAction is pressed.

To enable this functionality:

1. Ensure that the `ENABLE_RESPONSIVE` setting in [`Settings`](settings.md) is set to true.

2. Provide an alternative platform table with the suffix `_pressed` (ex: `iconSet.keyboard_pressed`).

Responsive icons will preload once the UI is created via [`ControlHints.CreateUI()`](../api-reference.md#createui)

## Limitations

- In the default icon sets, icon coverage is limited to common keys and buttons. Numpad and function keys are not included.
