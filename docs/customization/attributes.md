# Attributes

Attributes can be set on InputContexts, InputActions, and InputBindings at runtime (or before) to change how a hint is displayed.

For InputActions only:

- `CustomName` (string): Overrides the displayed label text.
- `CustomOrder` (number): Controls vertical position (lower = higher on screen). Overrides default sorting.

For InputContexts or InputActions:

- `Hidden` (boolean): Hides the hint even if the InputContext and InputAction are Enabled.

For InputBindings only:

- `CustomDevice` (string): Forces the binding onto a platform, whatever its KeyCode. Must be `"Keyboard"`, `"Gamepad"`, or `"Mobile"`. See [Device Mapping](device-mapping.md).

## InputBinding properties

Some of Roblox's own InputBinding properties also change how a hint is displayed:

- `DisplayImage` (Content): Replaces the icon shown for that binding, instead of looking one up in the icon set.

!!! info "DisplayImage and responsive icons"
    A binding with a `DisplayImage` has no pressed variant, so responsive icons do not apply to it.
