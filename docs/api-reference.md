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

### .AttachIcon()

```luau
ControlHints.AttachIcon(imageLabel: ImageLabel, inputAction: InputAction, responsive: boolean?, source: string?)
```

Keeps an ImageLabel showing the correct icon for an InputAction's current binding, and returns a handle. Use this to put button icons in your own UI, including BillboardGuis and SurfaceGuis. See [Icons in Custom UI](customization/custom-ui-icons.md).

**Parameters**:

- `imageLabel` (`ImageLabel`): The ImageLabel to attach to. Its Image is managed until the attachment is destroyed.
- `inputAction` (`InputAction`): The InputAction to show the icon of its current binding.
- `responsive` (`boolean?`): Optionally show pressed icons while the InputAction is active.
- `source` (`string?`): Optionally select which of the binding's KeyCodes to show: `"KeyCode"` (default), `"PrimaryModifier"`, `"SecondaryModifier"`, `"Up"`, `"Down"`, `"Left"`, `"Right"`, `"Forward"`, or `"Backward"`.

The icon updates on its own when the player's device changes, when the InputAction's bindings change, and (with `responsive`) when the InputAction is pressed or released. A binding's `DisplayImage` is honored for the `"KeyCode"` source.

Call `handle:Destroy()` to release the attachment. It is also released automatically when the ImageLabel or the InputAction is destroyed. Only attach one handle to an ImageLabel at a time.

### .GetIconId()

```luau
ControlHints.GetIconId(keyCode: Enum.KeyCode, specificPlatform: ("keyboard" | "mobile" | "xbox" | "ps")?, isPressed: boolean?): string
```

The same function as [`Utilities.GetIconId`](#geticonid_1), exposed at the top level for one-off lookups in custom UI. Resolved at call time: gamepad icons use whichever gamepad type (Xbox/PlayStation) is connected at that moment. For an icon that must stay correct, use [`AttachIcon`](#attachicon) with an InputAction.

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
