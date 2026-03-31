--!strict

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

	-- Error handling, hide template hint
	local container = controlHintsGui.Container
	assert(container, "Frame 'Container' not found in display style '" .. displayStyle.Name .. "'!")
	local templateHint = container.TemplateHint
	assert(templateHint, "Frame 'TemplateHint' not found in Frame 'Container'!")
	templateHint.Visible = false

	-- Set parent (if given)
	if optionalParent then
		controlHintsGui.Parent = optionalParent
	end

	-- Get setup info for hint creation
	local setupInfo: Utilities.SetupInfo = {
		screenWidth = controlHintsGui.AbsoluteSize.X,
		inputType = Utilities.GetInputType()
	}

	-- Track InputActions that have hints (avoid duplication)
	local assignedHints: {[InputAction]: boolean} = {}

	-- Create a unique Hint object
	local function createHint(inputAction: InputAction, inputContext: InputContext)

		-- Pass if not assigned to hint
		if assignedHints[inputAction] then return end
		assignedHints[inputAction] = true

		Hint.new(inputAction, inputContext, controlHintsGui, setupInfo)

	end

	-- Create a hint when a descendant is added to iasSetup
	table.insert(connections, iasSetup.DescendantAdded:Connect(function(descendant)
		if descendant:IsA("InputContext") then
			local inputContext = descendant
			for _, inputAction in inputContext:GetChildren() do
				if not inputAction:IsA("InputAction") then continue end
				createHint(inputAction, inputContext)
			end
		elseif descendant:IsA("InputAction") then
			local inputAction = descendant
			local inputContext = inputAction:FindFirstAncestorOfClass("InputContext")
			if inputContext then
				createHint(inputAction, inputContext)
			end
		elseif descendant:IsA("InputBinding") then
			local inputAction = descendant:FindFirstAncestorOfClass("InputAction")
			if inputAction then
				local inputContext = inputAction:FindFirstAncestorOfClass("InputContext")
				if inputContext then
					createHint(inputAction, inputContext)
				end
			end
		end
	end))

	-- Populate UI with hints
	for _, inputContext in iasSetup:GetChildren() do
		if not inputContext:IsA("InputContext") then continue end
		for _, inputAction in inputContext:GetChildren() do
			if not inputAction:IsA("InputAction") then continue end
			task.defer(createHint, inputAction, inputContext)
		end
	end

	-- Clean up when ScreenGui or iasSetup is destroying
	table.insert(connections, controlHintsGui.Destroying:Once(clearConnections))
	table.insert(connections, iasSetup.Destroying:Once(clearConnections))

	return controlHintsGui

end


return ControlHints
