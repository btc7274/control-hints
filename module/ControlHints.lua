--!strict

-- Classes
local Hint = require(script.Core.Hint)

-- ModuleScripts
local Settings = require(script.Configuration.Settings)
local Utilities = require(script.Core.Utilities)

local ControlHints = {}


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

	-- Cache display style
	local displayStyle = Settings.DISPLAY_STYLE

	-- Create new ScreenGui from display style
	local newScreenGui = displayStyle:Clone()

	-- Error handling, hide template hint
	local container = newScreenGui.Container
	assert(container, "Frame 'Container' not found in display style '" .. displayStyle.Name .. "'!")
	local templateHint = container.TemplateHint
	assert(templateHint, "Frame 'TemplateHint' not found in Frame 'Container'!")
	templateHint.Visible = false

	-- Set parent (if given)
	if optionalParent then
		newScreenGui.Parent = optionalParent
	end

	-- Get setup info for hint creation
	local setupInfo: Utilities.SetupInfo = {
		screenWidth = newScreenGui.AbsoluteSize.X,
		inputType = Utilities.GetInputType()
	}

	-- Track InputActions that have hints (avoid duplication)
	local assignedHints: {[InputAction]: boolean} = {}

	-- Helper function
	local function createHint(inputAction: InputAction, inputContext: InputContext)

		if assignedHints[inputAction] then return end
		assignedHints[inputAction] = true

		Hint.new(inputAction, inputContext, newScreenGui, setupInfo)

	end

	-- Listen for new descendants of the iasSetup Folder
	local descAddedConn: RBXScriptConnection
	descAddedConn = iasSetup.DescendantAdded:Connect(function(desc)
		if desc:IsA("InputContext") then
			local inputContext = desc
			for _, inputAction in inputContext:GetChildren() do
				if not inputAction:IsA("InputAction") then continue end
				createHint(inputAction, inputContext)
			end
		elseif desc:IsA("InputAction") then
			local inputAction = desc
			local inputContext = inputAction:FindFirstAncestorOfClass("InputContext")
			if inputContext then
				createHint(inputAction, inputContext)
			end
		end
	end)

	-- Populate UI with hints
	for _, inputContext in iasSetup:GetChildren() do
		if not inputContext:IsA("InputContext") then continue end
		for _, inputAction in inputContext:GetChildren() do
			if not inputAction:IsA("InputAction") then continue end
			task.defer(createHint, inputAction, inputContext)
		end
	end

	-- Disconnect all connections, clear memory (hints are auto-destroyed)
	local function cleanUp()
		descAddedConn:Disconnect()
		table.clear(assignedHints)
	end

	-- Clean up when ScreenGui is destroying
	newScreenGui.Destroying:Connect(cleanUp)

	return newScreenGui

end


return ControlHints
