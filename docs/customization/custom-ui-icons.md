# Icons in Custom UI

Control Hints' icon sets can be used outside of the generated hint UI. Any ImageLabel can show a button icon that stays correct across devices, platforms, and rebinds — under your own UI elements, or in the physical world through a BillboardGui or SurfaceGui.

## Live icons

Attach an ImageLabel to an InputAction, and it shows the icon for the action's current binding:

```luau
local ControlHints = require(ReplicatedStorage.ControlHints)

local handle = ControlHints.AttachIcon(imageLabel, jumpAction)
```

The icon updates on its own when the player switches devices, when the binding changes, and — with the `responsive` option — while the action is pressed:

```luau
ControlHints.AttachIcon(imageLabel, jumpAction, true)
```

Call `handle:Destroy()` when you are done. The attachment also cleans itself up when the ImageLabel or the InputAction is destroyed. Only attach one handle to an ImageLabel at a time.

## Key combinations

An ImageLabel shows one icon, so a combination like `L1 + R1` is built from two ImageLabels with the `source` option selecting which of the binding's KeyCodes each one shows:

```luau
ControlHints.AttachIcon(modifierIcon, ultimateAction, false, "PrimaryModifier")
ControlHints.AttachIcon(keyIcon, ultimateAction)
```

If the current binding has no modifier, the modifier label's Image is set to `""`. Hiding the empty label is up to your layout.

## World-space prompts

Nothing extra is needed for icons in the 3D world. An ImageLabel inside a BillboardGui works identically:

```luau
local billboard = Instance.new("BillboardGui")
billboard.Size = UDim2.fromOffset(50, 50)
billboard.AlwaysOnTop = true
billboard.Adornee = door
billboard.Parent = door

local icon = Instance.new("ImageLabel")
icon.Size = UDim2.fromScale(1, 1)
icon.BackgroundTransparency = 1
icon.Parent = billboard

ControlHints.AttachIcon(icon, openDoorAction)
```

The prompt above a door now shows the correct button for the player's device, and follows rebinds automatically.

## One-off lookups

For a static icon that never needs to update, skip the attachment and get the asset ID directly:

```luau
imageLabel.Image = ControlHints.GetIconId(Enum.KeyCode.ButtonY)
```

This is resolved at call time: gamepad icons use whichever gamepad type (Xbox/PlayStation) is connected at that moment. If the icon must stay correct when the player switches controllers, use `AttachIcon` with an InputAction instead.
