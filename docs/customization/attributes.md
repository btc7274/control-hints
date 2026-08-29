# Attributes

Attributes can be set on InputActions and InputContexts at runtime (or before) to change how a hint is displayed.

For InputActions only:

- `CustomName` (string): Overrides the displayed label text.
- `CustomOrder` (number): Controls vertical position (lower = higher on screen). Overrides default sorting.

For InputContexts or InputActions:

- `Hidden` (boolean): Hides the hint even if the InputContext and InputAction are Enabled.
