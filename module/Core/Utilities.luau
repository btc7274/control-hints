--!strict
local UserInputService = game:GetService("UserInputService")
local CollectionService = game:GetService("CollectionService")

-- ModuleScripts
local Settings = require("../Configuration/Settings")
local DeviceMapping = require("./DeviceMapping")

-- Types
type InputType = DeviceMapping.Device

type GamepadType = "xbox" | "ps"

export type HintType = "Bool" | "Directional"

type BindingKeyCodes = {
	keyCode: Enum.KeyCode,
	primaryModifier: Enum.KeyCode,
	secondaryModifier: Enum.KeyCode,
	up: Enum.KeyCode?,
	down: Enum.KeyCode?,
	left: Enum.KeyCode?,
	right: Enum.KeyCode?,
	forward: Enum.KeyCode?,
	backward: Enum.KeyCode?,
	displayImage: Content?
}

export type SetupInfo = {
	screenWidth: number,
	inputType: InputType
}

local Utilities = {}

-- InputBinding properties for composite directions
local DIRECTION_PROPERTIES = {"Up", "Down", "Left", "Right", "Forward", "Backward"}

-- Accepted values for an InputBinding's CustomDevice attribute
local VALID_DEVICES: {[string]: InputType} = {
	Keyboard = "Keyboard",
	Gamepad = "Gamepad",
	Mobile = "Mobile",
}

-- Icon sets that have already warned about missing '_pressed' tables
local warnedResponsiveSets: {[any]: true} = {}

-- KeyCodes that have already warned about a missing icon, keyed by 'table/KeyCode'
local warnedMissingIcons: {[string]: true} = {}

-- InputBindings that have already warned about stale directions, keyed by full name
local warnedStaleDirections: {[string]: true} = {}

-- InputBindingType is missing on older clients, so it is resolved safely
local SCRIPTABLE_BINDING_TYPE: EnumItem? = (function(): EnumItem?
	local ok, value = pcall(function()
		return (Enum :: any).InputBindingType.Scriptable
	end)
	return ok and value or nil
end)()


-- Returns icon asset ID (rbxassetid://...) for KeyCode; empty string if not found
-- specificPlatform: Optionally select a platform to get an icon from
function Utilities.GetIconId(keyCode: Enum.KeyCode, specificPlatform: ("keyboard" | "mobile" | "xbox" | "ps")?, isPressed: boolean?): string

	-- Early exit
	if keyCode == Enum.KeyCode.None then
		return ""
	end

	local iconSet = Settings.ICON_SET
	local useResponsive = isPressed == true and Settings.ENABLE_RESPONSIVE

	-- Determine platform from the KeyCode, so each icon uses its own device's table
	local platform: string
	if specificPlatform then
		platform = specificPlatform
	else
		local device = DeviceMapping.Classify(keyCode)
		if device == "Gamepad" then
			platform = Utilities.GetGamepadType()
		elseif device == "Mobile" then
			platform = "mobile"
		else
			platform = "keyboard"
		end
	end

	-- Get icon asset ID in icon set
	local suffix = useResponsive and "_pressed" or ""
	local tableName = platform .. suffix
	local iconTable = iconSet[tableName]

	if useResponsive and not (iconTable and next(iconTable)) then

		-- Warn once per icon set, instead of once per lookup
		if not warnedResponsiveSets[iconSet] then
			warnedResponsiveSets[iconSet] = true
			warn("Settings.ENABLE_RESPONSIVE is true, but the selected icon set has no '_pressed' table for '" .. platform .. "' (looked for '" .. tableName .. "'). Normal icons will be shown instead, with no pressed feedback. Either set ENABLE_RESPONSIVE to false, or choose an icon set that includes '_pressed' tables.")
		end

		-- Fallback to normal icon
		suffix = ""
		tableName = platform .. suffix
		iconTable = iconSet[tableName]
	end

	local iconId = iconTable[keyCode] or ""
	if iconId == "" then

		-- Warn once per KeyCode per table, instead of once per lookup
		local warnKey = tableName .. "/" .. keyCode.Name
		if not warnedMissingIcons[warnKey] then
			warnedMissingIcons[warnKey] = true
			warn("Missing icon asset ID for KeyCode '" .. keyCode.Name .. "' on platform '" .. platform .. "' (using table '" .. tableName .. "'). Nothing will be displayed. Add an entry for it to the icon set.")
		end

	end

	return iconId

end


-- Determines gamepad type for the player
function Utilities.GetGamepadType(): GamepadType

	local buttonString = UserInputService:GetStringForKeyCode(Enum.KeyCode.ButtonA)
	if buttonString == "ButtonCross" then
		return "ps"
	else
		return "xbox"  -- Default
	end

end


-- Determines hint type using its InputAction
function Utilities.GetHintType(inputAction: InputAction): HintType

	local actionType = inputAction.Type
	if actionType == Enum.InputActionType.Bool then
		return "Bool"
	elseif actionType == Enum.InputActionType.Direction1D
		or actionType == Enum.InputActionType.Direction2D
		or actionType == Enum.InputActionType.Direction3D
		or actionType == Enum.InputActionType.ViewportPosition
	then
		return "Directional"
	else
		return "Bool" -- Fallback
	end

end


-- Calculate scale factor for dynamic scaling
function Utilities.GetScaleFactor(screenWidth: number): number
	local lerp = math.clamp((screenWidth - Settings.MIN_SCREEN_WIDTH) / (Settings.MAX_SCREEN_WIDTH - Settings.MIN_SCREEN_WIDTH), 0, 1)
	return 1 + lerp * (Settings.MAX_SCALE_FACTOR - 1)
end


-- Whether a KeyCode is currently held, or nil if it cannot be queried
-- An InputAction's state sums its directions, so opposing keys cancel out and report nothing
-- Direction icons use this instead, so both keys of an opposing pair still light up
function Utilities.IsKeyCodeDown(keyCode: Enum.KeyCode?): boolean?

	if not keyCode or keyCode == Enum.KeyCode.None then
		return nil
	end

	local device = DeviceMapping.Classify(keyCode)
	local name = keyCode.Name

	if device == "Keyboard" then

		-- IsKeyDown only covers keys, so pointer inputs fall back to the state
		if name:sub(1, 5) == "Mouse" or name:sub(1, 8) == "Trackpad" then
			return nil
		end

		return UserInputService:IsKeyDown(keyCode)

	elseif device == "Gamepad" then

		-- Thumbsticks are axes rather than buttons, so they fall back to the state
		if name:sub(1, 10) == "Thumbstick" then
			return nil
		end

		for _, gamepad in UserInputService:GetConnectedGamepads() do
			if UserInputService:IsGamepadButtonDown(gamepad, keyCode) then
				return true
			end
		end

		return false

	end

	-- Mobile bindings have no key to query
	return nil

end


-- Determines the device an InputBinding belongs to, or nil if it cannot be determined
-- Modifiers are ignored, since the KeyCode they accompany already gives the device
-- skipDirections excludes the direction properties, for InputActions that cannot use them
function Utilities.GetBindingDevice(inputBinding: InputBinding, skipDirections: boolean?): InputType?

	-- Use the CustomDevice attribute, if there is one
	local customDevice = inputBinding:GetAttribute("CustomDevice")
	if typeof(customDevice) == "string" then
		local device = VALID_DEVICES[customDevice]
		if device then
			return device
		end
		if Settings.DEBUG then
			warn("InputBinding '" .. inputBinding.Name .. "' has an invalid CustomDevice attribute '" .. customDevice .. "'. Expected \"Keyboard\", \"Gamepad\", or \"Mobile\".")
		end
	end

	-- Otherwise use the binding's KeyCode
	local device = DeviceMapping.Classify(inputBinding.KeyCode)
	if device then
		return device
	end

	-- Directional bindings leave KeyCode as None, so check their directions
	if not skipDirections then
		for _, property in DIRECTION_PROPERTIES do
			device = DeviceMapping.Classify((inputBinding :: any)[property])
			if device then
				return device
			end
		end
	end

	return nil

end


-- Returns list of all KeyCodes for InputBindings that match the inputType
function Utilities.GetBindingKeyCodes(inputAction: InputAction, inputType: InputType): {BindingKeyCodes}

	-- Bool InputActions fire from a KeyCode and its modifiers, never from directions
	-- Switching a composite InputAction to Bool leaves the old directions on its bindings,
	-- so they are ignored here instead of being displayed alongside the KeyCode
	local usesDirections = inputAction.Type ~= Enum.InputActionType.Bool

	-- Get all BindingInfos for the InputAction
	local bindingKeyCodesList: {BindingKeyCodes} = {}
	for _, inputBinding in inputAction:GetChildren() do
		if not inputBinding:IsA("InputBinding") then continue end

		-- Skip bindings that are fired by script
		if SCRIPTABLE_BINDING_TYPE and inputBinding.Type == SCRIPTABLE_BINDING_TYPE then continue end

		-- Skip bindings with no KeyCode, since there is nothing to display
		local device = Utilities.GetBindingDevice(inputBinding, not usesDirections)
		if not device then
			if Settings.DEBUG and not inputBinding.UIButton then
				warn("InputBinding '" .. inputBinding.Name .. "' in InputAction '" .. inputAction.Name .. "' has no KeyCode or UIButton! It will not be displayed.")
			end
			continue
		end

		if device ~= inputType then continue end

		-- Optional per-binding image override
		local displayImage: Content? = inputBinding.DisplayImage
		if displayImage and displayImage.SourceType == Enum.ContentSourceType.None then
			displayImage = nil
		end

		-- Warn once per binding that kept directions it can no longer use
		if not usesDirections and Settings.DEBUG then
			local fullName = inputBinding:GetFullName()
			if not warnedStaleDirections[fullName] then
				for _, property in DIRECTION_PROPERTIES do
					if (inputBinding :: any)[property] ~= Enum.KeyCode.None then
						warnedStaleDirections[fullName] = true
						warn("InputBinding '" .. inputBinding.Name .. "' in InputAction '" .. inputAction.Name .. "' has direction KeyCodes, but its InputAction is Bool. They will be ignored. Clear them, or set the InputAction back to a composite type.")
						break
					end
				end
			end
		end

		table.insert(bindingKeyCodesList, {
			keyCode = inputBinding.KeyCode,
			primaryModifier = inputBinding.PrimaryModifier,
			secondaryModifier = inputBinding.SecondaryModifier,
			up = usesDirections and inputBinding.Up or nil,
			down = usesDirections and inputBinding.Down or nil,
			left = usesDirections and inputBinding.Left or nil,
			right = usesDirections and inputBinding.Right or nil,
			forward = usesDirections and inputBinding.Forward or nil,
			backward = usesDirections and inputBinding.Backward or nil,
			displayImage = displayImage
		} :: BindingKeyCodes)
	end

	if #bindingKeyCodesList == 0 and Settings.DEBUG then
		warn("InputAction '" .. inputAction.Name .. "' does not have any valid InputBindings for the inputType '" .. inputType .. "'! It will not be displayed.")
	end

	return bindingKeyCodesList

end


-- Get current input type
function Utilities.GetInputType(): InputType

	local inputType = "Keyboard"
	local preferredInput = UserInputService.PreferredInput
	if preferredInput == Enum.PreferredInput.Gamepad then
		inputType = "Gamepad"
	elseif preferredInput == Enum.PreferredInput.Touch then
		inputType = "Mobile"
	end

	return inputType

end


-- Applies current scaling to all active hints (if dynamic scaling is enabled)
function Utilities.ApplyDynamicScaling(screenWidth: number, hintFrame: Frame)

	if screenWidth < Settings.MIN_SCREEN_WIDTH and Settings.DEBUG then
		warn("Screen width is " .. screenWidth .. " (< " .. Settings.MIN_SCREEN_WIDTH .. "). Skipping dynamic scaling.")
		return
	end

	local scale = Utilities.GetScaleFactor(screenWidth)

	local targetText = math.floor(Settings.BASE_FONT_SIZE * scale)
	local targetIcon = math.floor(Settings.BASE_ICON_SIZE * scale)
	targetIcon = Vector2.new(targetIcon, targetIcon)

	for _, constraint in hintFrame:GetDescendants() do
		if constraint:IsA("UITextSizeConstraint") then
			constraint.MaxTextSize = targetText
			constraint.MinTextSize = targetText
		elseif constraint:IsA("UISizeConstraint") then
			constraint.MaxSize = targetIcon
			constraint.MinSize = targetIcon
		end
	end

end


return Utilities
