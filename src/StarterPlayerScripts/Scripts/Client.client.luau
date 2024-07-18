-- Client side core script
-- Initialized by KingCreoo on 7/18/2024

-- Define services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

-- Define variables
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local EnterPlayzoneFunction: RemoteFunction = ReplicatedStorage:WaitForChild("Functions"):WaitForChild("EnterPlayzone")

local Levels = ReplicatedStorage:WaitForChild("Levels")
local LevelAnchor = workspace:WaitForChild("LevelAnchor")

local SideMotion = 20

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

    local Horde = ReplicatedStorage:WaitForChild("Horde"):Clone()
    Horde.Parent = LevelClone
    Horde:SetPrimaryPartCFrame(LevelClone:WaitForChild("Start").CFrame)

    local HordeCamera = Instance.new("Camera")
    HordeCamera.CameraType = Enum.CameraType.Follow
    HordeCamera.CameraSubject = LevelClone:WaitForChild("Start")
    HordeCamera.Parent = LevelClone
    workspace.CurrentCamera = HordeCamera

    local MarchTween = TweenService:Create(LevelClone:WaitForChild("Base"), TweenInfo.new((LevelClone:WaitForChild("Start").Position - LevelClone:WaitForChild("End").Position).Magnitude / 4), {Position = LevelClone:WaitForChild("End").Position})
    task.wait(1)
    print("playing tween")
    MarchTween:Play()

    RunService.Heartbeat:Connect(function()
        local MouseHit = Mouse.Hit

        -- Apply movement limits
        local targetX = math.clamp(MouseHit.Position.X, (LevelClone.Start.Position.X - SideMotion), (LevelClone.Start.Position.X + SideMotion))

        -- Lerp to the target position
        local newPosition = Horde.PrimaryPart.Position
        newPosition = Vector3.new(
            newPosition.X + (targetX - newPosition.X) * .1,
            newPosition.Y,
            newPosition.Z
        )

        Horde:SetPrimaryPartCFrame(CFrame.new(newPosition))
    end)
end

-- Events & function calling

EnterPlayzoneFunction.OnClientInvoke = function(Level: string)
    GeneratePlayzone(Level)

    return
end