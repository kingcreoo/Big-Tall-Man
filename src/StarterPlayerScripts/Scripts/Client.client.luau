-- Client side core script
-- Initialized by KingCreoo on 7/18/2024

-- Define services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Define variables
local LocalPlayer: Player = Players.LocalPlayer

local Events = ReplicatedStorage:WaitForChild("Events")
local Functions = ReplicatedStorage:WaitForChild("Functions")

local ToggleControlsEvent: RemoteEvent = Events:WaitForChild("ToggleControls")

-- Define functions

local function DisablePlayerControls()
    local PlayerScripts = LocalPlayer:WaitForChild("PlayerScripts")
    local PlayerModule = require(PlayerScripts:WaitForChild("PlayerModule"))
    local Controls = PlayerModule:GetControls()
    Controls:Disable()
end

local function EnablePlayerControls()
    local PlayerScripts = LocalPlayer:WaitForChild("PlayerScripts")
    local PlayerModule = require(PlayerScripts:WaitForChild("PlayerModule"))
    local Controls = PlayerModule:GetControls()
    Controls:Enable()
end

-- Events & function calling

ToggleControlsEvent.OnClientEvent:Connect(function(Toggle: number)
    if Toggle == 0 then
        DisablePlayerControls()
    elseif Toggle == 1 then
        EnablePlayerControls()
    end
end)