--!nonstrict
-- ^ code is written with strict typechecking, but it's disabled to ignore errors regarding OOP
local ContentProvider = game:GetService("ContentProvider")
local UserInputService = game:GetService("UserInputService")

-- ModuleScripts
local Utilities = require("./Utilities")
local Settings = require("../Configuration/Settings")
local Sorting = require("../Configuration/KeyCodeSorting")

local Hint = {}
local metatable = {}
metatable.__index = metatable

type IconIds = {
	iconId: string,
	pressedIconId: string
}

type CombinationIds = {
	keyCode: IconIds,
	primaryMod: IconIds,
	secondaryMod: IconIds
}


-- Creates a hint that auto-updates
function Hint.new(inputAction: InputAction, inputContext: InputContext, screenGui: ScreenGui, setupInfo: Utilities.SetupInfo)

	local self = {}
	setmetatable(self, metatable)

	self.InputContext = inputContext
	self.InputAction = inputAction

	-- Get template and container
	local container = screenGui:FindFirstChild("Container")
	assert(container and container:IsA("Frame"), "No Frame 'Container' found in ScreenGui '" .. screenGui.Name .. "'!")
	local templateHint = container:FindFirstChild("TemplateHint")
	assert(templateHint and templateHint:IsA("Frame"), "No Frame 'TemplateHint' found in Frame 'Container'!")

	-- Get list of KeyCode combinations
	local inputType = setupInfo.inputType
	local combinationList = Utilities.GetCombinations(inputAction, inputType)

	-- Get icon IDs for a KeyCode, or nil
	local function getIconIds(keyCode: Enum.KeyCode): IconIds?

		local iconId = Utilities.GetIconId(keyCode, nil, false)
		local pressedIconId = Utilities.GetIconId(keyCode, nil, true)
		
		if iconId == "" then
			return nil
		end

		return {iconId = iconId, pressedIconId = Settings.ENABLE_RESPONSIVE and pressedIconId or ""}

	end

	-- Get icon IDs for each KeyCode in a combination
	local combinationIdList: {CombinationIds} = {}
	for _, combination in combinationList do
		table.insert(combinationIdList, {
			keyCode = getIconIds(combination.keyCode),
			primaryMod = getIconIds(combination.primaryMod),
			secondaryMod = getIconIds(combination.secondaryMod)
		})
	end

	-- Get layout order for hint
	local customOrder = inputAction:GetAttribute("CustomOrder")
	local layoutOrder = typeof(customOrder) == "number" and customOrder :: number or math.huge

	-- If no custom order, then sort manually
	if layoutOrder == math.huge then
		-- Get sort index by inputType
		local sortIndex = (inputType == "Keyboard" and Sorting.keyboard_sort_index) or (inputType == "Gamepad" and Sorting.gamepad_sort_index) or Sorting.mobile_sort_index
		if not sortIndex then
			if Settings.DEBUG then
				warn("No sort table found for inputType '" .. inputType .. "'. Add a table to the Sorting module for consistent hints display.")
			end
			sortIndex = {}
		end

		-- Find minimum layout order according to sort index
		for _, combination in combinationList do
			local index = sortIndex[combination.keyCode] or math.huge
			layoutOrder = math.min(layoutOrder, index)
		end
	end

	-- Create new hint from template
	local newHint = templateHint:Clone()
	self.Frame = newHint
	self.Frame.Name = inputAction.Name
	self.Frame.LayoutOrder = layoutOrder

	-- Setup label
	local label = self.Frame:FindFirstChild("Label")
	assert(label and label:IsA("TextLabel"), "TextLabel 'Label' not found in Frame 'TemplateHint'!")

	-- Set text for label
	local customName = inputAction:GetAttribute("CustomName")
	local displayName = typeof(customName) == "string" and customName :: string or inputAction.Name
	label.Text = displayName

	-- Setup icon, optional separator, and optional union
	local icon = self.Frame:FindFirstChild("Icon")
	assert(icon and icon:IsA("ImageLabel"), "ImageLabel 'Icon' not found in Frame 'TemplateHint'!")
	local separator = self.Frame:FindFirstChild("Separator")
	local union = self.Frame:FindFirstChild("Union")

	-- Build icons
	local iconList: {[ImageLabel]: IconIds} = {}
	local currentOrder = icon.LayoutOrder
	
	-- Helper to create an icon
	local function newIcon(iconIds: IconIds)
		
		local newIcon = icon:Clone()
		
		newIcon.LayoutOrder = currentOrder
		newIcon.Parent = self.Frame

		iconList[newIcon] = iconIds

		currentOrder += Settings.INCREMENT
		
	end
	
	-- Helper to create a separator
	local function newSeparator()
		
		if separator then
			assert(separator:IsA("GuiObject"), "Instance 'Separator' in Frame 'TemplateHint' is not a GuiObject, but is a " .. separator.ClassName .. "!")
			local newSeparator = separator:Clone()

			newSeparator.LayoutOrder = currentOrder
			newSeparator.Visible = true
			newSeparator.Parent = self.Frame

			currentOrder += Settings.INCREMENT
		end
		
	end
	
	-- Helper to create a union
	local function newUnion()
		
		if union then
			assert(union:IsA("GuiObject"), "Instance 'Union' in Frame 'TemplateHint' is not a GuiObject, but is a " .. separator.ClassName .. "!")
			local newUnion = union:Clone()

			newUnion.LayoutOrder = currentOrder
			newUnion.Visible = true
			newUnion.Parent = self.Frame

			currentOrder += Settings.INCREMENT
		end
		
	end
	
	-- Construct icons with separators/unions as appropriate
	local isFirst = true
	for _, combinationIds in combinationIdList do
		if not isFirst then
			newSeparator()
		else
			isFirst = false
		end
		if combinationIds.secondaryMod then
			newIcon(combinationIds.secondaryMod)
			newUnion()
		end
		if combinationIds.primaryMod then
			newIcon(combinationIds.primaryMod)
			newUnion()
		end
		newIcon(combinationIds.keyCode)
	end

	-- Remove original icons/separators/unions
	icon:Destroy()
	if separator then separator:Destroy() end
	if union then union:Destroy() end

	-- Preload pressed icons (if responsive is enabled)
	if Settings.ENABLE_RESPONSIVE then
		-- Build list of temporary ImageLabels to preload
		local preloadList: {ImageLabel} = {}
		for _, iconIds in iconList do
			local icon = Instance.new("ImageLabel")
			icon.Image = iconIds.pressedIconId
			table.insert(preloadList, icon)
		end

		if #preloadList > 0 then
			ContentProvider:PreloadAsync(preloadList)

			-- Clear memory
			for _, icon in preloadList do
				icon:Destroy()
			end
			table.clear(preloadList)
		end
	end

	self.IconList = iconList

	-- Setup dynamic scaling (if enabled)
	local isGamepad = UserInputService.PreferredInput == Enum.PreferredInput.Gamepad
	local useDynamicScaling = Settings.ENABLE_DYNAMIC_SCALING and isGamepad
	if useDynamicScaling then
		Utilities.ApplyDynamicScaling(setupInfo.screenWidth, self.Frame)
	end

	-- Set parent
	self.Frame.Parent = container

	-- Update when InputContent changed or when InputAction changed/pressed/released
	-- Destroy when ScreenGui is destroying
	local function doUpdate()
		self:Update()
	end
	self.connections = {}
	table.insert(self.connections, inputContext.Changed:Connect(doUpdate))
	table.insert(self.connections, inputAction.Changed:Connect(doUpdate))
	table.insert(self.connections, inputAction.Pressed:Connect(doUpdate))
	table.insert(self.connections, inputAction.Released:Connect(doUpdate))
	table.insert(self.connections, screenGui.Destroying:Connect(function()
		self:Destroy()
	end))

	-- Initial update
	doUpdate()

	return self

end


-- Updates hint label and visibility
-- Destroys self in some cases
function metatable:Update()

	-- Destroy self if InputContext or InputAction got destroyed
	if not self.InputContext or not self.InputAction then
		self:Destroy()
	end

	local inputAction = self.InputAction :: InputAction
	local inputContext = self.InputContext :: InputContext

	-- Update hint visibility
	self.Frame.Visible = inputContext.Enabled and inputAction.Enabled

	-- Get display name for hint
	local customName = inputAction:GetAttribute("CustomName")
	local displayName = typeof(customName) == "string" and customName :: string or inputAction.Name

	-- Update label text
	self.Frame.Label.Text = displayName

	-- Update icon images
	for icon, iconIds in self.IconList do
		local isPressed = Settings.ENABLE_RESPONSIVE and inputAction.Type == Enum.InputActionType.Bool and inputAction:GetState() and true or false
		icon.Image = isPressed and iconIds.pressedIconId or iconIds.iconId
	end

end


function metatable:Destroy()

	self.InputContext = nil
	self.InputAction = nil

	if self.Frame then
		self.Frame:Destroy()
	end
	self.Frame = nil

	if self.IconList then
		for _, iconIds in self.IconList do
			table.clear(iconIds)
		end
		table.clear(self.IconList)
	end
	self.IconList = nil

	if self.connections then
		for _, conn in self.connections do
			conn:Disconnect()
		end
		table.clear(self.connections)
	end
	self.connections = nil

end


return Hint
