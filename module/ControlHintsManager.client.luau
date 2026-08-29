-- Place me under StarterGui
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")

local TAG = "ControlHints_UI"

local player = Players.LocalPlayer


-- Adjust as needed:
local ControlHints = require(ReplicatedStorage.ControlHints)
local IAS_SETUP = player.PlayerScripts:WaitForChild("IasSetup")

--[[
	if IAS_SETUP is under StarterGui, it will reset on death,
	so any old Control Hints UI will not update, and game systems may break.

	To prevent this, place IAS_SETUP under StarterPlayerScripts.
]]



-- Destroy existing UI
for _, instance in CollectionService:GetTagged(TAG) do
	instance:Destroy()
end

-- Create UI
local controlHintsGui = ControlHints.CreateUI(IAS_SETUP, player.PlayerGui)
controlHintsGui:AddTag(TAG)
