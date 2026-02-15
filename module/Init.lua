-- Put me anywhere a LocalScript can go
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
assert(player)
local playerGui = player.PlayerGui



-- Adjust as needed:
local ControlHints = require(ReplicatedStorage.ControlHints)
local IAS_SETUP_FOLDER = playerGui:WaitForChild("InputContexts")




local newScreenGui = ControlHints.CreateUI(IAS_SETUP_FOLDER, playerGui)
-- Toggle Enabled on newScreenGui if you want to show/hide