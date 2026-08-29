# API Reference

## ControlHints

### .CreateUI()

```luau
ControlHints.CreateUI(iasSetup: Instance, optionalParent: Instance?): ScreenGui
```

Creates and returns a ScreenGui that automatically displays control hints for the provided IAS setup.

**Parameters**:

- `iasSetup` (`Instance`): An Instance containing your IAS setup.
- `optionalParent` (`Instance?`): An optional Instance to set as the parent of the new ScreenGui.

Control Hints actively manages Hint objects to match your IAS setup. It listens for new descendants of the IAS setup and creates unique Hints when possible. Additionally, it will recreate Hints when `UserInputService.PreferredInput` changes.

All connections are cleaned up when the ScreenGui is destroyed via `Instance:Destroy()`.

## Utilities

### .GetIconId()

```luau
Utilities.GetIconId(keyCode: Enum.KeyCode, specificPlatform: ("keyboard" | "mobile" | "xbox" | "ps")?, isPressed: boolean?): string
```

Returns an `rbxassetid://` string if an icon is found, or an empty `""` string if not found.

**Parameters**:

- `keyCode` (`Enum.KeyCode`): The KeyCode to get the icon for.
- `specificPlatform` (`("keyboard" | "mobile" | "xbox" | "ps")?`): An optional platform to grab from, regardless of `UserInputService.PreferredInput`.
- `isPressed` (`boolean?`): An optional boolean to grab the pressed (active) variant of an icon.
