# Device Mapping

Every KeyCode belongs to a device, and that is what decides which platform an InputBinding is shown on. The mapping lives in the `DeviceMapping` ModuleScript under `Core`. It is built from `Enum.KeyCode` itself when the game starts, so KeyCodes added by future Roblox updates are matched automatically instead of being skipped.

KeyCodes are matched by the start of their name:

| Name starts with | Device |
|------------------|--------|
| `Button`, `DPad`, `Thumbstick` | Gamepad |
| `Touch` | Mobile |
| `Mouse`, `Trackpad` | Keyboard |
| anything else | Keyboard |

Mouse and trackpad KeyCodes count as Keyboard because `UserInputService.PreferredInput` groups them together as `KeyboardAndMouse`, and the icon sets use a single `keyboard` table for both.

If a binding has no KeyCode of its own, its directional KeyCodes (`Up`, `Down`, `Left`, `Right`, `Forward`, `Backward`) are checked instead. This is how composite Direction2D and Direction3D bindings are matched. Modifier KeyCodes are never checked, since the KeyCode they accompany already gives the device.

## Changing the mapping

Move a prefix between devices in `PREFIX_RULES` to rematch a whole family of KeyCodes at once.

For a single KeyCode whose name does not match its device, add it to `OVERRIDES`, which is checked before the prefixes:

```luau
local OVERRIDES: {[Enum.KeyCode]: Device} = {}
```

To change one InputBinding rather than a KeyCode everywhere, use the [`CustomDevice` attribute](attributes.md) instead.
