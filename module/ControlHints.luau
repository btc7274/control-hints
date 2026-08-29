--!strict
local UserInputService = game:GetService("UserInputService")

-- Classes
local Hint = require(script.Core.Hint)

-- ModuleScripts
local Settings = require(script.Configuration.Settings)
local Utilities = require(script.Core.Utilities)

local ControlHints = {}

local connections: {RBXScriptConnection} = {}


-- Disconnect all connections
local function clearConnections()

	for _, connection in connections do
		connection:Disconnect()
	end
	table.clear(connections)

end


-- Creates a ScreenGui that updates with the given IAS setup
-- iasSetup: An Instance containing InputContexts, InputActions, and InputBindings (nested in that order)
-- optionalParent: Sets the parent of the ScreenGui
function ControlHints.CreateUI(iasSetup: Instance, optionalParent: Instance?): ScreenGui

	-- Error handling for iasSetup
	assert(iasSetup, "Instance 'iasSetup' is missing!")
	assert(typeof(iasSetup) == "Instance", "'iasSetup' is not an Instance, but is a " .. typeof(iasSetup) .. "!")

	-- Error handling for optionalParent
	if optionalParent then
		assert(typeof(optionalParent) == "Instance", "Instance 'optionalParent' is not an Instance, but is a " .. typeof(optionalParent) .. "!")
	end

	clearConnections()

	-- Cache display style
	local displayStyle = Settings.DISPLAY_STYLE

	-- Create new ScreenGui from display style
	local controlHintsGui = displayStyle:Clone()

	-- Get container
	local container = controlHintsGui:FindFirstChild("Container")
	assert(container and container:IsA("Frame"), "Frame 'Container' not found in display style '" .. displayStyle.Name .. "'!")

	-- Hide template hint
	local hintTemplate = container:FindFirstChild("HintTemplate")
	assert(hintTemplate and hintTemplate:IsA("Frame"), "Frame 'HintTemplate' not found in Frame 'Container'!")
	hintTemplate.Visible = false

	-- Set parent (if given)
	if optionalParent then
		controlHintsGui.Parent = optionalParent
	end

	-- Get setup info for hint creation
	local setupInfo: Utilities.SetupInfo = {
		screenWidth = controlHintsGui.AbsoluteSize.X,
		inputType = Utilities.GetInputType()
	}

	-- Whether hints are shown on the player's current device
	local deviceEnabled = true
	local function updateDeviceEnabled()
		deviceEnabled = Settings.ENABLED_DEVICES[setupInfo.inputType] ~= false
		controlHintsGui.Enabled = deviceEnabled
	end

	-- Track InputActions that have hints (avoid duplication)
	local assignedHints: {[InputAction]: any} = {}

	-- Create a unique Hint object for an InputAction
	local function createHint(inputAction: InputAction)

		if not deviceEnabled then return end
		if assignedHints[inputAction] then return end

		-- InputActions are not required to be direct children of their InputContext
		local inputContext = inputAction:FindFirstAncestorOfClass("InputContext")
		if not inputContext then
			if Settings.DEBUG then
				warn("InputAction '" .. inputAction.Name .. "' is not a descendant of an InputContext! It will not be displayed.")
			end
			return
		end

		assignedHints[inputAction] = Hint.new(inputAction, inputContext, controlHintsGui, setupInfo)

	end

	-- Create a hint when a descendant is added to iasSetup
	table.insert(connections, iasSetup.DescendantAdded:Connect(function(descendant)
		if descendant:IsA("InputAction") then
			createHint(descendant)
		elseif descendant:IsA("InputContext") then
			for _, inputAction in descendant:GetDescendants() do
				if not inputAction:IsA("InputAction") then continue end
				createHint(inputAction)
			end
		elseif descendant:IsA("InputBinding") then
			local inputAction = descendant:FindFirstAncestorOfClass("InputAction")
			if inputAction then
				createHint(inputAction)
			end
		end
	end))

	-- Populate UI with hints
	local function populateUI()
		for _, inputAction in iasSetup:GetDescendants() do
			if not inputAction:IsA("InputAction") then continue end
			task.defer(createHint, inputAction)
		end
	end

	-- Initial update
	updateDeviceEnabled()
	if deviceEnabled then
		populateUI()
	end

	-- Rescale hints when the screen size changes
	table.insert(connections, controlHintsGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()

		setupInfo.screenWidth = controlHintsGui.AbsoluteSize.X

		for _, hint in assignedHints do
			hint:ApplyScaling()
		end

	end))

	-- Re-populate when PreferredInput changes
	table.insert(connections, UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(function()

		-- Clear existing hints
		for key, hint in assignedHints do
			hint:Destroy()
			assignedHints[key] = nil
		end
		table.clear(assignedHints)

		-- Update setupInfo
		setupInfo.inputType = Utilities.GetInputType()

		-- Re-populate UI with new hints (if the new device shows them)
		updateDeviceEnabled()
		if deviceEnabled then
			populateUI()
		end

	end))

	-- Clean up when ScreenGui or iasSetup is destroying
	table.insert(connections, controlHintsGui.Destroying:Once(clearConnections))
	table.insert(connections, iasSetup.Destroying:Once(clearConnections))

	return controlHintsGui

end


return ControlHints
