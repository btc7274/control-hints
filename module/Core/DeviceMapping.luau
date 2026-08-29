--!strict

-- Types
export type Device = "Keyboard" | "Gamepad" | "Mobile"

local DeviceMapping = {}

-- KeyCode name prefixes for each device
local PREFIX_RULES: {{prefix: string, device: Device}} = {
	{prefix = "Button", device = "Gamepad"},
	{prefix = "DPad", device = "Gamepad"},
	{prefix = "Thumbstick", device = "Gamepad"},
	{prefix = "Touch", device = "Mobile"},
	{prefix = "Mouse", device = "Keyboard"},  -- PreferredInput groups these as KeyboardAndMouse
	{prefix = "Trackpad", device = "Keyboard"},
}

-- KeyCodes whose name does not match the device they belong to
local OVERRIDES: {[Enum.KeyCode]: Device} = {}

-- Device for KeyCodes that match no prefix
local DEFAULT_DEVICE: Device = "Keyboard"


-- Device for every KeyCode, built once from the enum
local deviceByKeyCode: {[Enum.KeyCode]: Device} = {}

for _, keyCode in Enum.KeyCode:GetEnumItems() do

	-- Use the override, if there is one
	local override = OVERRIDES[keyCode]
	if override then
		deviceByKeyCode[keyCode] = override
		continue
	end

	-- Otherwise use the first matching prefix
	local device = DEFAULT_DEVICE
	for _, rule in PREFIX_RULES do
		if keyCode.Name:sub(1, #rule.prefix) == rule.prefix then
			device = rule.device
			break
		end
	end

	deviceByKeyCode[keyCode] = device

end

-- None is not tied to a device
deviceByKeyCode[Enum.KeyCode.None] = nil


-- Returns the Device for a KeyCode, or nil if it is None
function DeviceMapping.Classify(keyCode: Enum.KeyCode?): Device?

	if not keyCode then
		return nil
	end

	return deviceByKeyCode[keyCode]

end


return DeviceMapping
