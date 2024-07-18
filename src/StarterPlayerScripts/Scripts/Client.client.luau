-- Client side core script
-- Initialized by KingCreoo on 7/18/2024

-- Define services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
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

    local Horde = Instance.new("Part")
    Horde.Anchored = true
    Horde.CanCollide = false
    Horde.Parent = LevelClone
    Horde.Position = LevelClone:WaitForChild("Start").Position

    local HordeCamera = Instance.new("Camera")
    HordeCamera.Parent = Horde
    HordeCamera.CameraType = Enum.CameraType.Follow
    HordeCamera.CameraSubject = Horde
    workspace.CurrentCamera = HordeCamera

    local MarchTween = TweenService:Create(LevelClone:WaitForChild("Base"), TweenInfo.new((LevelClone:WaitForChild("Start").Position - LevelClone:WaitForChild("End").Position).Magnitude / 4), {Position = LevelClone:WaitForChild("End").Position})
    task.wait(1)
    print("playing tween")
    MarchTween:Play()
end

-- Events & function calling

EnterPlayzoneFunction.OnClientInvoke = function(Level: string)
    GeneratePlayzone(Level)

    return
end