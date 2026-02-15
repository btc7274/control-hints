--!strict
-- Used to show control hints in a consistent order.
-- Move KeyCodes up/down for your preferred hint display order.

-- Tips:
--   • Top of sort order = displayed at top
--   • Bottom of sort order = displayed at bottom
--   • InputActions can override sorting by having a CustomOrder attribute (number).
--   • If a KeyCode is not listed, it will sort last (math.huge).

local Sorting = {}

Sorting.keyboard_order = {
	Enum.KeyCode.MouseLeftButton,
	Enum.KeyCode.MouseRightButton,
	Enum.KeyCode.MouseMiddleButton,
	Enum.KeyCode.A,
	Enum.KeyCode.B,
	Enum.KeyCode.C,
	Enum.KeyCode.D,
	Enum.KeyCode.E,
	Enum.KeyCode.F,
	Enum.KeyCode.G,
	Enum.KeyCode.H,
	Enum.KeyCode.I,
	Enum.KeyCode.J,
	Enum.KeyCode.K,
	Enum.KeyCode.L,
	Enum.KeyCode.M,
	Enum.KeyCode.N,
	Enum.KeyCode.O,
	Enum.KeyCode.P,
	Enum.KeyCode.Q,
	Enum.KeyCode.R,
	Enum.KeyCode.S,
	Enum.KeyCode.T,
	Enum.KeyCode.U,
	Enum.KeyCode.V,
	Enum.KeyCode.W,
	Enum.KeyCode.X,
	Enum.KeyCode.Y,
	Enum.KeyCode.Z,
	Enum.KeyCode.Zero,
	Enum.KeyCode.One,
	Enum.KeyCode.Two,
	Enum.KeyCode.Three,
	Enum.KeyCode.Four,
	Enum.KeyCode.Five,
	Enum.KeyCode.Six,
	Enum.KeyCode.Seven,
	Enum.KeyCode.Eight,
	Enum.KeyCode.Nine,
	Enum.KeyCode.Up,
	Enum.KeyCode.Down,
	Enum.KeyCode.Left,
	Enum.KeyCode.Right,
	Enum.KeyCode.LeftShift,
	Enum.KeyCode.RightShift,
	Enum.KeyCode.LeftControl,
	Enum.KeyCode.RightControl,
	Enum.KeyCode.LeftAlt,
	Enum.KeyCode.RightAlt,
	Enum.KeyCode.Space,
	Enum.KeyCode.Tab,
	Enum.KeyCode.Return,
	Enum.KeyCode.Backspace,
	Enum.KeyCode.Escape,
	Enum.KeyCode.Comma,
	Enum.KeyCode.Period,
	Enum.KeyCode.Slash,
	Enum.KeyCode.Semicolon,
	Enum.KeyCode.Quote,
	Enum.KeyCode.LeftBracket,
	Enum.KeyCode.RightBracket,
	Enum.KeyCode.BackSlash,
	Enum.KeyCode.Minus,
	Enum.KeyCode.Equals,
	-- Add/remove/move as needed.
}

Sorting.gamepad_order = {
	Enum.KeyCode.ButtonA,
	Enum.KeyCode.ButtonB,
	Enum.KeyCode.ButtonX,
	Enum.KeyCode.ButtonY,
	Enum.KeyCode.ButtonL1,
	Enum.KeyCode.ButtonR1,
	Enum.KeyCode.ButtonL2,
	Enum.KeyCode.ButtonR2,
	Enum.KeyCode.ButtonL3,
	Enum.KeyCode.ButtonR3,
	Enum.KeyCode.DPadUp,
	Enum.KeyCode.DPadDown,
	Enum.KeyCode.DPadLeft,
	Enum.KeyCode.DPadRight,
	Enum.KeyCode.ButtonStart,
	Enum.KeyCode.ButtonSelect,
	-- Add/remove/move as needed.
}

Sorting.mobile_order = {
	Enum.KeyCode.Touch,
	-- Add/remove/move as needed.
}

-- Lookup indices.
Sorting.keyboard_sort_index = {}
for index, keyCode in ipairs(Sorting.keyboard_order) do
	Sorting.keyboard_sort_index[keyCode] = index
end

Sorting.gamepad_sort_index = {}
for index, keyCode in ipairs(Sorting.gamepad_order) do
	Sorting.gamepad_sort_index[keyCode] = index
end

Sorting.mobile_sort_index = {}
for index, keyCode in ipairs(Sorting.mobile_order) do
	Sorting.mobile_sort_index[keyCode] = index
end

return Sorting
