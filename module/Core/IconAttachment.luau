--!strict
local UserInputService = game:GetService("UserInputService")

-- ModuleScripts
local Utilities = require("./Utilities")
local Settings = require("../Configuration/Settings")

local IconAttachment = {}
local metatable = {}
metatable.__index = metatable

export type Source = "KeyCode" | "PrimaryModifier" | "SecondaryModifier" | "Up" | "Down" | "Left" | "Right" | "Forward" | "Backward"

-- Maps a Source to its field in Utilities.GetBindingKeyCodes
local SOURCE_FIELDS: {[string]: string} = {
	KeyCode = "keyCode",
	PrimaryModifier = "primaryModifier",
	SecondaryModifier = "secondaryModifier",
	Up = "up",
	Down = "down",
	Left = "left",
	Right = "right",
	Forward = "forward",
	Backward = "backward",
}


-- Returns whether a string is a valid Source
function IconAttachment.IsValidSource(source: string): boolean
	return SOURCE_FIELDS[source] ~= nil
end


-- Keeps an ImageLabel showing the correct icon for an InputAction's current binding
function IconAttachment.new(imageLabel: ImageLabel, inputAction: InputAction, responsive: boolean?, source: Source?)

	local self = {}
	setmetatable(self, metatable)

	-- Set initial values
	self.ImageLabel = imageLabel
	self.InputAction = inputAction
	self.Responsive = responsive == true
	self.Source = source or "KeyCode"
	self.Connections = {}
	self.BindingConnections = {}
	self.WatchedKeyCodes = {}

	-- Update when the player's device changes
	table.insert(self.Connections, UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(function()
		self:Update()
	end))

	-- Update when the InputAction's bindings or state change
	table.insert(self.Connections, inputAction.ChildAdded:Connect(function(child)
		if child:IsA("InputBinding") then
			self:Update()
		end
	end))
	table.insert(self.Connections, inputAction.ChildRemoved:Connect(function(child)
		if child:IsA("InputBinding") then
			self:Update()
		end
	end))
	table.insert(self.Connections, inputAction.Destroying:Once(function()
		self:Destroy()
	end))

	if self.Responsive then
		table.insert(self.Connections, inputAction.StateChanged:Connect(function()
			self:Update()
		end))

		-- Keys are read on their own, so pressing one does not always change the InputAction's state
		local function onInput(input: InputObject)
			-- None is skipped, since bindings without modifiers leave it in their chains
			local keyCode = Utilities.GetInputKeyCode(input)
			if keyCode ~= Enum.KeyCode.None and self.WatchedKeyCodes and self.WatchedKeyCodes[keyCode] then
				self:Update()
			end
		end
		table.insert(self.Connections, UserInputService.InputBegan:Connect(onInput))
		table.insert(self.Connections, UserInputService.InputEnded:Connect(onInput))
	end

	-- Clean up when the ImageLabel is destroying
	table.insert(self.Connections, imageLabel.Destroying:Once(function()
		self:Destroy()
	end))

	-- Initial update
	self:Update()

	return self

end


-- Updates the ImageLabel to the current icon
function metatable:Update()

	-- Skip attachments that have been destroyed
	if not self.ImageLabel then return end

	local imageLabel = self.ImageLabel :: ImageLabel
	local inputAction = self.InputAction :: InputAction

	-- Disconnect all binding connections
	for _, connection in self.BindingConnections do
		connection:Disconnect()
	end
	table.clear(self.BindingConnections)

	-- Resolve the KeyCode to show
	local keyCode: Enum.KeyCode = Enum.KeyCode.None
	local displayImage: Content? = nil
	local chain: {Enum.KeyCode} = {}
	local isPressed = false

	-- Use the first InputBinding that matches the player's device
	local bindingKeyCodesList = Utilities.GetBindingKeyCodes(inputAction, Utilities.GetInputType())
	local bindingKeyCodes = bindingKeyCodesList[1]
	if bindingKeyCodes then
		-- Select the requested KeyCode from the binding
		local selected = (bindingKeyCodes :: any)[SOURCE_FIELDS[self.Source]] :: Enum.KeyCode?
		keyCode = selected or Enum.KeyCode.None

		-- DisplayImage replaces the binding's main icon only
		if self.Source == "KeyCode" then
			displayImage = bindingKeyCodes.displayImage
		end

		-- Modifiers can be pressed in any order, but both must be held before the rest of the binding
		if self.Source ~= "SecondaryModifier" and self.Source ~= "PrimaryModifier" then
			chain = {bindingKeyCodes.secondaryModifier, bindingKeyCodes.primaryModifier}
		end
	end

	-- Pressed state (if responsive is enabled)
	if self.Responsive then

		-- The key is read directly, since the InputAction's state is shared by every binding
		-- and sums its directions, so it cannot tell which key is held
		local actionState = inputAction:GetState()
		local isStateActive = actionState ~= 0 and actionState ~= Vector2.zero and actionState ~= Vector3.zero and actionState ~= false
		isPressed = Utilities.IsBindingKeyPressed(keyCode, chain, isStateActive)

		-- The KeyCode fires the InputAction, so it also needs the state and stays dark if pressed out of order
		if self.Source == "KeyCode" then
			isPressed = isPressed and isStateActive
		end

		-- Watch the keys this icon depends on
		table.clear(self.WatchedKeyCodes)
		self.WatchedKeyCodes[keyCode] = true
		for _, chainKeyCode in chain do
			self.WatchedKeyCodes[chainKeyCode] = true
		end
	end

	-- Update when an InputBinding changes
	for _, child in inputAction:GetChildren() do
		if child:IsA("InputBinding") then
			table.insert(self.BindingConnections, child.Changed:Connect(function()
				self:Update()
			end))
		end
	end

	-- Set the image
	if displayImage then
		imageLabel.ImageContent = displayImage
	elseif keyCode == Enum.KeyCode.None then
		imageLabel.Image = ""
	else
		imageLabel.Image = Utilities.GetIconId(keyCode, nil, isPressed)
	end

end


function metatable:Destroy()

	if self.Connections then
		for _, connection in self.Connections do
			connection:Disconnect()
		end
		table.clear(self.Connections)
	end
	self.Connections = nil

	if self.BindingConnections then
		for _, connection in self.BindingConnections do
			connection:Disconnect()
		end
		table.clear(self.BindingConnections)
	end
	self.BindingConnections = nil
	self.WatchedKeyCodes = nil

	self.ImageLabel = nil
	self.InputAction = nil
	self.Responsive = nil
	self.Source = nil

end


return IconAttachment
