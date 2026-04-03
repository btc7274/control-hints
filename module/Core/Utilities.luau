--!strict
local UserInputService = game:GetService("UserInputService")
local CollectionService = game:GetService("CollectionService")

-- ModuleScripts
local Settings = require("../Configuration/Settings")

-- Types
type InputType = "Keyboard" | "Gamepad" | "Mobile"

type GamepadType = "xbox" | "ps"

type KeyCodeCombination = {
	keyCode: Enum.KeyCode,
	primaryMod: Enum.KeyCode,
	secondaryMod: Enum.KeyCode
}

export type SetupInfo = {
	screenWidth: number,
	inputType: InputType
}

local Utilities = {}


-- Returns icon asset ID (rbxassetid://...) for KeyCode; empty string if not found
-- specificPlatform: Optionally select a platform to get an icon from
function Utilities.GetIconId(keyCode: Enum.KeyCode, specificPlatform: ("keyboard" | "mobile" | "xbox" | "ps")?, isPressed: boolean?): string

	-- Early exit
	if keyCode == Enum.KeyCode.Unknown then
		return ""
	end

	local iconSet = Settings.ICON_SET
	local useResponsive = isPressed == true and Settings.ENABLE_RESPONSIVE

	-- Determine platform
	local platform: string
	if specificPlatform then
		platform = specificPlatform
	else
		if UserInputService.PreferredInput == Enum.PreferredInput.Gamepad then
			platform = Utilities.GetGamepadType()
		elseif UserInputService.PreferredInput == Enum.PreferredInput.Touch then
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
		warn("Settings.ENABLE_RESPONSIVE is true, but the icon set does not have any tables with the '_pressed' suffix for the platform '" .. platform .. "'!")

		-- Fallback to normal icon
		suffix = ""
		tableName = platform .. suffix
		iconTable = iconSet[tableName]
	end

	local iconId = iconTable[keyCode] or ""
	if iconId == "" then
		warn("Missing icon asset ID for KeyCode '" .. keyCode.Name .. "' on platform '" .. platform .. "' (using table '" .. tableName .. "'). Nothing will be displayed.")
	end

	return iconId

end


-- Determines gamepad type for the player
function Utilities.GetGamepadType(): GamepadType

	local buttonString = UserInputService:GetStringForKeyCode(Enum.KeyCode.ButtonA)
	if buttonString == "ButtonCross" then
		return "ps"
	else
		return "xbox"  -- Default.
	end

end


-- Calculate scale factor for dynamic scaling
function Utilities.GetScaleFactor(screenWidth: number): number
	local lerp = math.clamp((screenWidth - Settings.MIN_SCREEN_WIDTH) / (Settings.MAX_SCREEN_WIDTH - Settings.MIN_SCREEN_WIDTH), 0, 1)
	return 1 + lerp * (Settings.MAX_SCALE_FACTOR - 1)
end


-- Returns list of KeyCode combinations for InputBindings that match the inputType
function Utilities.GetCombinations(inputAction: InputAction, inputType: InputType): {KeyCodeCombination}

	-- Get all KeyCode combinations for the InputAction
	local combinationList: {KeyCodeCombination} = {}
	for _, inputBinding in inputAction:GetChildren() do
		if inputBinding:IsA("InputBinding") and inputBinding.Name:match("^" .. inputType) then
			if inputType == "Mobile" then
				table.insert(combinationList, {
					keyCode = Enum.KeyCode.Touch,
					primaryMod = Enum.KeyCode.Unknown,
					secondaryMod = Enum.KeyCode.Unknown
				})
			else
				local keyCode = inputBinding.KeyCode
				local primaryMod = inputBinding.PrimaryModifier
				local secondaryMod = inputBinding.SecondaryModifier

				if keyCode ~= Enum.KeyCode.Unknown then
					table.insert(combinationList, {
						keyCode = keyCode,
						primaryMod = primaryMod,
						secondaryMod = secondaryMod
					})
				elseif Settings.DEBUG then
					warn("InputBinding '" .. inputBinding.Name .. "' inside InputAction '" .. inputAction.Name .. "' has no assigned KeyCode! It will not be displayed.")
				end
			end
		end
	end

	if #combinationList == 0 and Settings.DEBUG then
		warn("InputAction '" .. inputAction.Name .. "' does not have any valid InputBindings for the inputType '" .. inputType .. "'! It will not be displayed.")
	end

	return combinationList

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
