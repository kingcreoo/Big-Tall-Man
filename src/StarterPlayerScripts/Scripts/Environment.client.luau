-- Game environment client-side core script
-- Initialized by KingCreoo on 7/20/2024

-- Define services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

-- Define variables
local LocalPlayer: Player = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Events = ReplicatedStorage:WaitForChild("Events")
local Functions = ReplicatedStorage:WaitForChild("Functions")

local GenerateEnvironmentEvent: RemoteEvent = Events:WaitForChild("GenerateEnvironment")

local Controls

-- Define functions

-- Reflect horde with given data from server
local function ReflectHorde(GivenHorde: table)
    
end

-- Generate horde controls
local function GenerateControls(Level, Horde, LevelSideMotion: number)
    Controls = RunService.Heartbeat:Connect(function()
        local MouseHit = Mouse.Hit

        -- Apply movement limits
        local targetX = math.clamp(MouseHit.Position.X, (Level.Start.Position.X - LevelSideMotion), (Level.Start.Position.X + LevelSideMotion))

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

-- Initialize environment with given data from server
local function InitializeEnvironment(Level: Model, ControlsMotion: number)
    -- Generate camera
    local HordeCamera = Instance.new("Camera")
    HordeCamera.CameraType = Enum.CameraType.Follow
    HordeCamera.CameraSubject = Level:WaitForChild("Start")
    HordeCamera.Parent = Level
    workspace.CurrentCamera = HordeCamera

    -- Generate horde controls
    GenerateControls(Level, Level:WaitForChild("Horde"), ControlsMotion)

end

-- Events & function calling

GenerateEnvironmentEvent.OnClientEvent:Connect(InitializeEnvironment)