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
- `specificPlatform` (`("keyboard" | "mobile" | "xbox" | "ps")?`): An optional platform to grab from. When omitted, the platform is taken from the KeyCode's own device, so a binding mixing devices still resolves each icon correctly.
- `isPressed` (`boolean?`): An optional boolean to grab the pressed (active) variant of an icon.

### .GetBindingDevice()

```luau
Utilities.GetBindingDevice(inputBinding: InputBinding): ("Keyboard" | "Gamepad" | "Mobile")?
```

Returns the device an InputBinding is shown on, or `nil` if it cannot be determined.

**Parameters**:

- `inputBinding` (`InputBinding`): The InputBinding to match to a device.

A `CustomDevice` attribute is used if there is one. Otherwise the binding's KeyCode is matched, then its directional KeyCodes. A binding with no KeyCode at all returns `nil` and is not displayed.

## DeviceMapping

### .Classify()

```luau
DeviceMapping.Classify(keyCode: Enum.KeyCode?): ("Keyboard" | "Gamepad" | "Mobile")?
```

Returns the device a KeyCode belongs to, or `nil` if the KeyCode is `Enum.KeyCode.None` or missing.

**Parameters**:

- `keyCode` (`Enum.KeyCode?`): The KeyCode to match to a device.

See [Device Mapping](customization/device-mapping.md) for how the matching is configured.
