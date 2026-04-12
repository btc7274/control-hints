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

type BindingIconIds = {
	keyCode: IconIds,
	primaryModifier: IconIds,
	secondaryModifier: IconIds,
	up: IconIds?,
	down: IconIds?,
	left: IconIds?,
	right: IconIds?,
	forward: IconIds?,
	backward: IconIds?
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

	-- Get container Frame
	local container = screenGui:FindFirstChild("Container")
	assert(container and container:IsA("Frame"), "No Frame 'Container' found in ScreenGui '" .. screenGui.Name .. "'!")

	-- Get hint type
	self.HintType = Utilities.GetHintType(inputAction)

	-- Get hint template Frame
	local hintTemplate = container:FindFirstChild("HintTemplate")
	assert(hintTemplate and hintTemplate:IsA("Frame"), "No Frame 'HintTemplate' found in Frame 'Container'!")

	-- Create new hint from template
	self.Frame = hintTemplate:Clone()
	self.Frame.Name = inputAction.Name

	-- Setup label
	local label = self.Frame:FindFirstChild("Label")
	assert(label and label:IsA("TextLabel"), "TextLabel 'Label' not found in Frame 'TemplateHint'!")

	-- Set text for label
	local customName = inputAction:GetAttribute("CustomName")
	local displayName = typeof(customName) == "string" and customName :: string or inputAction.Name
	label.Text = displayName

	-- Get templates depending on hint type
	self.Templates = {
		Separator = self.Frame:FindFirstChild("Separator"),
		Union = self.Frame:FindFirstChild("Union")
	} :: {[string]: Instance}

	-- Add icon template
	local iconTemplate = self.Frame:FindFirstChild("Icon")
	assert(iconTemplate and iconTemplate:IsA("ImageLabel"), "ImageLabel 'Icon' not found in Frame 'TemplateHint'!")
	self.Templates.Icon = iconTemplate

	-- Add icon group template
	local iconGroup = self.Frame:FindFirstChild("IconGroup")
	assert(iconGroup and iconGroup:IsA("Frame"), "Frame 'IconGroup' not found in Frame 'TemplateHint'!")
	self.Templates.IconGroup = iconGroup

	-- Parent templates to nil
	for _, template in self.Templates do
		template.Parent = nil
	end

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
	local function doSort()
		self:Sort()
	end

	self.Connections = {
		inputContext.Changed:Connect(doUpdate),
		inputContext:GetAttributeChangedSignal("Hidden"):Connect(doUpdate),
		inputAction.Changed:Connect(doUpdate),
		inputAction:GetPropertyChangedSignal("Type"):Connect(function()
			self.HintType = Utilities.GetHintType(inputAction)
			self:RebuildIcons()
			self:Update()
		end),
		inputAction:GetAttributeChangedSignal("CustomName"):Connect(doUpdate),
		inputAction:GetAttributeChangedSignal("CustomOrder"):Connect(doSort),
		inputAction:GetAttributeChangedSignal("Hidden"):Connect(doUpdate),
		inputAction.StateChanged:Connect(doUpdate),
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

	-- Initial update and sort
	self:Sort()
	self:Update()

	return self

end


-- Update hint's LayoutOrder
function metatable:Sort()

	local inputAction = self.InputAction :: InputAction
	local inputType = self.SetupInfo.inputType
	local bindingKeyCodesList = Utilities.GetBindingKeyCodes(inputAction, inputType)

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
		for _, bindingKeyCodes in bindingKeyCodesList do
			local index = sortIndex[bindingKeyCodes.keyCode] or math.huge
			layoutOrder = math.min(layoutOrder, index)
		end
	end

	self.Frame.LayoutOrder = layoutOrder

end


-- Rebuild all icons
function metatable:RebuildIcons()

	-- Cache key values
	local inputAction = self.InputAction :: InputAction
	local hintType = self.HintType
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

	-- Get templates
	local iconTemplate = self.Templates.Icon :: ImageLabel?
	assert(iconTemplate and iconTemplate:IsA("ImageLabel"), "No template 'Icon' found.")
	local iconGroupTemplate = self.Templates.IconGroup :: Frame?
	assert(iconGroupTemplate and iconGroupTemplate:IsA("Frame"), "No template 'IconGroup' found.")
	local separatorTemplate = self.Templates.Separator :: GuiObject?
	local unionTemplate = self.Templates.Union :: GuiObject?

	-- Get KeyCode combinations
	local bindingKeyCodesList = Utilities.GetBindingKeyCodes(inputAction, inputType)

	-- Hide hint if InputAction has no InputBindings
	self.Hidden = #bindingKeyCodesList == 0

	-- Get icon IDs for all of an InputBinding's KeyCodes
	local bindingIconIdsList: {BindingIconIds} = {}
	for _, bindingKeyCodes in bindingKeyCodesList do
		local bindingIconIds: {[string]: IconIds} = {}
		for property, keyCode in bindingKeyCodes :: {[string]: Enum.KeyCode?} do
			if keyCode and keyCode ~= Enum.KeyCode.Unknown then
				local iconIds = getIconIds(keyCode)
				if iconIds then
					bindingIconIds[property] = iconIds
				end
			end
		end
		table.insert(bindingIconIdsList, bindingIconIds :: BindingIconIds)
	end

	local iconList: {[ImageLabel]: IconIds} = {}
	local iconGroupIconsList: {[Frame]: {[ImageLabel]: IconIds}} = {}
	local currentOrder = iconTemplate.LayoutOrder

	-- Create a singular icon
	local function createIcon(iconIds: IconIds)

		local icon = iconTemplate:Clone()

		-- Set properties
		icon.LayoutOrder = currentOrder
		icon.Parent = self.Frame

		iconList[icon] = iconIds
		table.insert(self.Content, icon)

		currentOrder += Settings.INCREMENT

	end

	-- Create an icon group (for directional InputActions)
	local function createIconGroup(bindingIconIds: BindingIconIds)

		local iconGroup = iconGroupTemplate:Clone()

		-- Set properties
		iconGroup.LayoutOrder = currentOrder
		iconGroup.Parent = self.Frame

		-- Create list of all directional icons in the group
		local directionalIconList: {[string]: ImageLabel} = {
			up = iconGroup:FindFirstChild("UpIcon", true) :: ImageLabel,
			down = iconGroup:FindFirstChild("DownIcon", true) :: ImageLabel,
			left = iconGroup:FindFirstChild("LeftIcon", true) :: ImageLabel,
			right = iconGroup:FindFirstChild("RightIcon", true) :: ImageLabel,
			forward = iconGroup:FindFirstChild("ForwardIcon", true) :: ImageLabel,
			backward = iconGroup:FindFirstChild("BackwardIcon", true) :: ImageLabel
		}

		-- Setup each directional icon
		local iconList2: {[ImageLabel]: IconIds} = {}
		for property, icon in directionalIconList do
			local iconIds = bindingIconIds[property] :: IconIds?
			if iconIds then
				iconList2[icon] = iconIds
			else
				icon.Visible = false
			end
		end

		iconGroupIconsList[iconGroup] = iconList2
		table.insert(self.Content, iconGroup)

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
	for _, bindingIconIds in bindingIconIdsList do
		if not isFirst then
			createSeparator()
		else
			isFirst = false
		end
		if bindingIconIds.secondaryModifier then
			createIcon(bindingIconIds.secondaryModifier)
			createUnion()
		end
		if bindingIconIds.primaryModifier then
			createIcon(bindingIconIds.primaryModifier)
			createUnion()
		end
		if bindingIconIds.keyCode then
			createIcon(bindingIconIds.keyCode)
		end
		if bindingIconIds.up
			or bindingIconIds.down
			or bindingIconIds.left
			or bindingIconIds.right
			or bindingIconIds.forward
			or bindingIconIds.backward
		then
			createIconGroup(bindingIconIds)
		end
	end

	self.IconList = iconList
	self.IconGroupIconsList = iconGroupIconsList

	-- Preload pressed icons (if responsive is enabled)
	if Settings.ENABLE_RESPONSIVE then
		-- Build list of temporary ImageLabels to preload
		local preloadList: {ImageLabel} = {}
		for _, iconIds in self.IconList do
			local icon = Instance.new("ImageLabel")
			icon.Image = iconIds.pressedIconId
			table.insert(preloadList, icon)
		end
		for _, iconList in self.IconGroupIconsList do
			for _, iconIds in iconList do
				local icon = Instance.new("ImageLabel")
				icon.Image = iconIds.pressedIconId
				table.insert(preloadList, icon)
			end
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
	local hintType = self.HintType :: Utilities.HintType

	-- Get Hidden attributes (overrides .Enabled visibility)
	local contextHidden = inputContext:GetAttribute("Hidden")
	local actionHidden = inputAction:GetAttribute("Hidden")

	-- Update hint's Hidden value
	if contextHidden or actionHidden then
		self.Hidden = true
	else
		self.Hidden = false
	end

	-- Update hint visibility
	frame.Visible = inputContext.Enabled and inputAction.Enabled and not self.Hidden

	-- Get display name for hint
	local customName = inputAction:GetAttribute("CustomName")
	local displayName = typeof(customName) == "string" and customName :: string or inputAction.Name

	-- Update label text
	local label = frame:FindFirstChild("Label")
	assert(label and label:IsA("TextLabel"), "TextLabel 'Label' not found in Hint Frame '" .. frame.Name .. "'!")
	label.Text = displayName

	-- Update singular icons
	for icon, iconIds in self.IconList :: {[ImageLabel]: IconIds} do
		local actionState = inputAction:GetState()
		local isStateActive = actionState ~= 0 and actionState ~= Vector2.zero and actionState ~= Vector3.zero and actionState ~= false
		local isPressed = Settings.ENABLE_RESPONSIVE and isStateActive
		icon.Image = isPressed and iconIds.pressedIconId or iconIds.iconId
	end

	-- Update icon groups for directional hints
	if hintType == "Directional" then
		local direction = inputAction:GetState()
		local pressedIcons = {}  -- renamed for clarity

		if typeof(direction) == "number" then
			if direction > 0 then pressedIcons.UpIcon = true end
			if direction < 0 then pressedIcons.DownIcon = true end

		elseif typeof(direction) == "Vector2" or typeof(direction) == "Vector3" then
			if direction.Y > 0 then pressedIcons.UpIcon = true end
			if direction.Y < 0 then pressedIcons.DownIcon = true end
			if direction.X and direction.X < 0 then pressedIcons.LeftIcon = true end
			if direction.X and direction.X > 0 then pressedIcons.RightIcon = true end

			if typeof(direction) == "Vector3" then
				if direction.Z < 0 then pressedIcons.ForwardIcon = true end
				if direction.Z > 0 then pressedIcons.BackwardIcon = true end
			end
		end

		for _, iconList in self.IconGroupIconsList :: {[Frame]: {[ImageLabel]: IconIds}} do
			for icon, iconIds in iconList do
				local isPressed = Settings.ENABLE_RESPONSIVE and pressedIcons[icon.Name]
				icon.Image = isPressed and iconIds.pressedIconId or iconIds.iconId
			end
		end
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

	self.HintType = nil

	if self.Frame then
		self.Frame:Destroy()
	end
	self.Frame = nil

	if self.Templates then
		for _, template in self.Templates do
			template:Destroy()
		end
		table.clear(self.Templates)
	end
	self.Templates = nil

	if self.IconList then
		for _, iconIds in self.IconList do
			table.clear(iconIds)
		end
		table.clear(self.IconList)
	end
	self.IconList = nil

	if self.IconGroupIconsList then
		for _, iconList in self.IconGroupIconsList do
			for _, iconIds in iconList do
				table.clear(iconIds)
			end
			table.clear(iconList)
		end
		table.clear(self.IconGroupIconsList)
	end
	self.IconGroupIconsList = nil

	if self.Connections then
		for _, connection in self.Connections do
			connection:Disconnect()
		end
		table.clear(self.Connections)
	end
	self.Connections = nil

end


return Hint
