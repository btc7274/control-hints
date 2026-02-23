-- Put me under StarterPlayer/StarterPlayerScripts
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
assert(player)



-- Adjust as needed:
local ControlHints = require(ReplicatedStorage.ControlHints)
local IAS_SETUP = player.PlayerScripts:WaitForChild("IasSetup")

-- 	^^ if IAS_SETUP is under StarterGui, it will reset on death,
--	   so any old Control Hints UI will not update




local newUi = ControlHints.CreateUI(IAS_SETUP, player.PlayerGui)
