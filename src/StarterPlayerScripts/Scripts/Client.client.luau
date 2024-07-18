-- Client side core script
-- Initialized by KingCreoo on 7/18/2024

-- Define services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Define variables
local LocalPlayer = Players.LocalPlayer

local EnterPlayzoneFunction: RemoteFunction = ReplicatedStorage:WaitForChild("Functions"):WaitForChild("EnterPlayzone")

local Levels = ReplicatedStorage:WaitForChild("Levels")
local LevelAnchor = workspace:WaitForChild("LevelAnchor")

-- Define functions

local function DisablePlayerControls(Player: Player)
    local PlayerScripts = Player:WaitForChild("PlayerScripts")
    local PlayerModule = require(PlayerScripts:WaitForChild("PlayerModule"))
    local Controls = PlayerModule:GetControls()
    Controls:Disable()
end

local function EnablePlayerControls(Player: Player)
    local PlayerScripts = Player:WaitForChild("PlayerScripts")
    local PlayerModule = require(PlayerScripts:WaitForChild("PlayerModule"))
    local Controls = PlayerModule:GetControls()
    Controls:Enable()
end

local function GeneratePlayzone(Level: string)
    DisablePlayerControls(LocalPlayer)

    local LevelClone = Levels:WaitForChild(Level):Clone()
    LevelClone.Name = LocalPlayer.Name .. "--Level"
    LevelClone:SetPrimaryPartCFrame(LevelAnchor.CFrame)
    LevelClone.Parent = workspace
end

-- Events & function calling

EnterPlayzoneFunction.OnClientInvoke = function(Level: string)
    GeneratePlayzone(Level)

    return
end