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


-- Get icon IDs for a KeyCode, or nil
local function getIconIds(keyCode: Enum.KeyCode): IconIds?

	local iconId = Utilities.GetIconId(keyCode, nil, false)
	local pressedIconId = Utilities.GetIconId(keyCode, nil, true)

	if iconId == "" then
		return nil
	end

	return {iconId = iconId, pressedIconId = Settings.ENABLE_RESPONSIVE and pressedIconId or ""}

end


-- Creates a hint that auto-updates
function Hint.new(inputAction: InputAction, inputContext: InputContext, screenGui: ScreenGui, setupInfo: Utilities.SetupInfo)

	local self = {}
	setmetatable(self, metatable)

	-- Set initial values
	self.InputContext = inputContext
	self.InputAction = inputAction
	self.SetupInfo = setupInfo
	self.Hidden = false
	self.Content = {}
	self.BindingConnections = {}

	-- Get template and container
	local container = screenGui:FindFirstChild("Container")
	assert(container and container:IsA("Frame"), "No Frame 'Container' found in ScreenGui '" .. screenGui.Name .. "'!")
	local templateHint = container:FindFirstChild("TemplateHint")
	assert(templateHint and templateHint:IsA("Frame"), "No Frame 'TemplateHint' found in Frame 'Container'!")

	-- Get list of KeyCode combinations
	local inputType = setupInfo.inputType
	local combinationList = Utilities.GetCombinations(inputAction, inputType)

	-- Get icon IDs for each KeyCode in a combination
	local combinationIdList: {CombinationIds} = {}
	for _, combination in combinationList do
		table.insert(combinationIdList, {
			keyCode = getIconIds(combination.keyCode),
			primaryMod = getIconIds(combination.primaryMod),
			secondaryMod = getIconIds(combination.secondaryMod)
		} :: CombinationIds)
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
	self.Frame = templateHint:Clone()
	self.Frame.Name = inputAction.Name
	self.Frame.LayoutOrder = layoutOrder

	-- Setup label
	local label = self.Frame:FindFirstChild("Label")
	assert(label and label:IsA("TextLabel"), "TextLabel 'Label' not found in Frame 'TemplateHint'!")

	-- Set text for label
	local customName = inputAction:GetAttribute("CustomName")
	local displayName = typeof(customName) == "string" and customName :: string or inputAction.Name
	label.Text = displayName

	-- Get template icon, separator (optional), and union (optional)
	local iconTemplate = self.Frame:FindFirstChild("Icon")
	assert(iconTemplate and iconTemplate:IsA("ImageLabel"), "ImageLabel 'Icon' not found in Frame 'TemplateHint'!")
	local separatorTemplate = self.Frame:FindFirstChild("Separator")
	local unionTemplate = self.Frame:FindFirstChild("Union")

	self.IconTemplate = iconTemplate
	self.SeparatorTemplate = separatorTemplate
	self.UnionTemplate = unionTemplate

	-- Parent templates to nil
	iconTemplate.Parent = nil
	if separatorTemplate then separatorTemplate.Parent = nil end
	if unionTemplate then unionTemplate.Parent = nil end

	-- Initial build for icons
	self:RebuildIcons()

	-- Setup dynamic scaling (if enabled)
	local isGamepad = UserInputService.PreferredInput == Enum.PreferredInput.Gamepad
	local useDynamicScaling = Settings.ENABLE_DYNAMIC_SCALING and isGamepad
	if useDynamicScaling then
		Utilities.ApplyDynamicScaling(setupInfo.screenWidth, self.Frame)
	end

	-- Parent hint to container
	self.Frame.Parent = container

	-- Update when InputContent changed or when InputAction changed/pressed/released
	-- Destroy when ScreenGui or InputContext/Action is destroying
	local function doUpdate()
		self:Update()
	end
	local function doDestroy()
		self:Destroy()
	end

	self.Connections = {
		inputContext.Changed:Connect(doUpdate),
		inputAction.Changed:Connect(doUpdate),
		inputAction.Pressed:Connect(doUpdate),
		inputAction.Released:Connect(doUpdate),
		inputAction.Destroying:Once(doDestroy),
		inputAction.ChildAdded:Connect(function(child)
			if child:IsA("InputBinding") then
				self:RebuildIcons()
				self:Update()
			end
		end),
		inputAction.ChildRemoved:Connect(function(child)
			if child:IsA("InputBinding") then
				self:RebuildIcons()
				self:Update()
			end
		end),
		inputContext.Destroying:Once(doDestroy),
		screenGui.Destroying:Once(doDestroy)
	}

	-- Initial update
	self:Update()

	return self

end


-- Rebuild all icons
function metatable:RebuildIcons()

	-- Cache key values
	local inputAction = self.InputAction :: InputAction
	local iconTemplate = self.IconTemplate :: ImageLabel
	local separatorTemplate = self.SeparatorTemplate :: GuiObject
	local unionTemplate = self.UnionTemplate :: GuiObject
	local inputType = self.SetupInfo.inputType

	-- Disconnect all binding connections
	for _, connection in self.BindingConnections do
		connection:Disconnect()
	end
	table.clear(self.BindingConnections)

	-- Clear old content
	for _, instance in self.Content do
		instance:Destroy()
	end
	table.clear(self.Content)

	-- Get icon IDs for each KeyCode in a combination
	local combinationList = Utilities.GetCombinations(inputAction, inputType)

	-- Hide hint if InputAction has no InputBindings
	self.Hidden = #combinationList == 0

	local combinationIdList: {CombinationIds} = {}
	for _, combination in combinationList do
		table.insert(combinationIdList, {
			keyCode = getIconIds(combination.keyCode),
			primaryMod = getIconIds(combination.primaryMod),
			secondaryMod = getIconIds(combination.secondaryMod)
		} :: CombinationIds)
	end

	local iconList: {[ImageLabel]: IconIds} = {}
	local currentOrder = iconTemplate.LayoutOrder

	-- Create an icon
	local function createIcon(iconIds: IconIds)

		local icon = iconTemplate:Clone()

		-- Set properties
		icon.LayoutOrder = currentOrder
		icon.Parent = self.Frame

		iconList[icon] = iconIds
		table.insert(self.Content, icon)

		currentOrder += Settings.INCREMENT

	end

	-- Create a separator (if it exists)
	local function createSeparator()

		if separatorTemplate then
			assert(separatorTemplate:IsA("GuiObject"), "Instance 'Separator' in Frame 'TemplateHint' is not a GuiObject, but is a " .. separatorTemplate.ClassName .. "!")
			local separator = separatorTemplate:Clone()

			-- Set properties
			separator.LayoutOrder = currentOrder
			separator.Visible = true
			separator.Parent = self.Frame

			table.insert(self.Content, separator)

			currentOrder += Settings.INCREMENT
		end

	end

	-- Create a union (if it exists)
	local function createUnion()

		if unionTemplate then
			assert(unionTemplate:IsA("GuiObject"), "Instance 'Union' in Frame 'TemplateHint' is not a GuiObject, but is a " .. unionTemplate.ClassName .. "!")
			local union = unionTemplate:Clone()

			-- Set properties
			union.LayoutOrder = currentOrder
			union.Visible = true
			union.Parent = self.Frame

			table.insert(self.Content, union)

			currentOrder += Settings.INCREMENT
		end

	end

	-- Construct icons with separators/unions as appropriate
	local isFirst = true
	for _, combinationIds in combinationIdList do
		if not isFirst then
			createSeparator()
		else
			isFirst = false
		end
		if combinationIds.secondaryMod then
			createIcon(combinationIds.secondaryMod)
			createUnion()
		end
		if combinationIds.primaryMod then
			createIcon(combinationIds.primaryMod)
			createUnion()
		end
		createIcon(combinationIds.keyCode)
	end

	self.IconList = iconList

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
			task.defer(function()

				ContentProvider:PreloadAsync(preloadList)

				-- Clear memory
				for _, icon in preloadList do
					icon:Destroy()
				end
				table.clear(preloadList)

			end)
		end
	end

	-- Rebuild when an InputBinding changes
	for _, child in inputAction:GetChildren() do
		if child:IsA("InputBinding") then
			table.insert(self.BindingConnections, child.Changed:Connect(function()
				self:RebuildIcons()
				self:Update()
			end))
		end
	end

end


-- Updates hint label text, hint visibility, and icon images
function metatable:Update()

	-- Cache key values
	local frame = self.Frame :: Frame
	local inputAction = self.InputAction :: InputAction
	local inputContext = self.InputContext :: InputContext

	-- Update hint visibility
	frame.Visible = inputContext.Enabled and inputAction.Enabled and not self.Hidden

	-- Get display name for hint
	local customName = inputAction:GetAttribute("CustomName")
	local displayName = typeof(customName) == "string" and customName :: string or inputAction.Name

	-- Update label text
	frame.Label.Text = displayName

	-- Update icon images
	for icon, iconIds in self.IconList do
		local isPressed = Settings.ENABLE_RESPONSIVE and inputAction.Type == Enum.InputActionType.Bool and inputAction:GetState() and true or false
		icon.Image = isPressed and iconIds.pressedIconId or iconIds.iconId
	end

end


function metatable:Destroy()

	self.InputContext = nil
	self.InputAction = nil
	self.SetupInfo = nil
	self.Hidden = nil

	if self.Content then
		for _, instance in self.Content do
			instance:Destroy()
		end
		table.clear(self.Content)
	end
	self.Content = nil

	if self.BindingConnections then
		for _, connection in self.BindingConnections do
			connection:Disconnect()
		end
		table.clear(self.BindingConnections)
	end
	self.BindingConnections = nil

	if self.Frame then
		self.Frame:Destroy()
	end
	self.Frame = nil

	if self.IconTemplate then
		self.IconTemplate:Destroy()
	end
	self.IconTemplate = nil

	if self.SeparatorTemplate then
		self.SeparatorTemplate:Destroy()
	end
	self.SeparatorTemplate = nil

	if self.UnionTemplate then
		self.UnionTemplate:Destroy()
	end
	self.UnionTemplate = nil

	if self.IconList then
		for _, iconIds in self.IconList do
			table.clear(iconIds)
		end
		table.clear(self.IconList)
	end
	self.IconList = nil

	if self.Connections then
		for _, connection in self.Connections do
			connection:Disconnect()
		end
		table.clear(self.Connections)
	end
	self.Connections = nil

end


return Hint
