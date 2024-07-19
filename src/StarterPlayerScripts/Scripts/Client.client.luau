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

local Events = ReplicatedStorage:WaitForChild("Events")
local ReflectHordeEvent: RemoteEvent = Events:WaitForChild("ReflectHorde")
local FireHordeEvent: RemoteEvent = Events:WaitForChild("FireHorde")

local Functions = ReplicatedStorage:WaitForChild("Functions")
local EnterPlayzoneFunction: RemoteFunction = Functions:WaitForChild("EnterPlayzone")

local Levels = ReplicatedStorage:WaitForChild("Levels")
local LevelAnchor = workspace:WaitForChild("LevelAnchor")

local Controls
local CurrentHorde

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

-- Generate level, base horde, & camera
local function GeneratePlayzone(LevelName: string)
    DisablePlayerControls(LocalPlayer)

    -- Generate the level
    local LevelClone = Levels:WaitForChild(LevelName):Clone()
    LevelClone.Name = LocalPlayer.Name .. "--Level"
    LevelClone:SetPrimaryPartCFrame(LevelAnchor.CFrame)
    LevelClone.Parent = workspace

    -- Generate base horde
    local Horde = ReplicatedStorage:WaitForChild("Horde"):Clone()
    Horde.Parent = LevelClone
    Horde:SetPrimaryPartCFrame(LevelClone:WaitForChild("Start").CFrame)
    CurrentHorde = Horde

    -- Generate camera
    local HordeCamera = Instance.new("Camera")
    HordeCamera.CameraType = Enum.CameraType.Follow
    HordeCamera.CameraSubject = LevelClone:WaitForChild("Start")
    HordeCamera.Parent = LevelClone
    workspace.CurrentCamera = HordeCamera

    return LevelClone, Horde
end

-- Generate march animation
local function GenerateMarch(Level, WaitTime)
    local MarchTween = TweenService:Create(Level:WaitForChild("Base"), TweenInfo.new((Level:WaitForChild("Start").Position - Level:WaitForChild("End").Position).Magnitude / 4), {Position = Level:WaitForChild("End").Position})
    task.wait(WaitTime)
    MarchTween:Play()
end

-- Generate player's horde controls
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

-- Terminate player's horde controls
local function TerminateControls()
    Controls:Disconnect()
end

-- Reflect horde based on given args
local function ReflectHorde(Horde: table)
    for Slot, Soldier in pairs(Horde) do
        if Soldier == 1 then
            CurrentHorde:FindFirstChild(Slot).Transparency = 0
        elseif Soldier == 0 then
            CurrentHorde:FindFirstChild(Slot).Transparency = 1
        end
    end
end

-- Fire the horde's weapons
local function FireHorde(Horde: table)
    for _, Soldier in pairs(CurrentHorde:GetChildren()) do
        if Soldier.Name == "HordeAnchor" then continue end

        if Horde[tonumber(Soldier.Name)] == 0 then continue end

        local Bullet = Instance.new("Part")
        Bullet.Position = Soldier.Position
        Bullet.Size = Vector3.new(.5,.5,3)
        Bullet.Material = Enum.Material.SmoothPlastic
        Bullet.BrickColor = BrickColor.new("New Yeller")
        Bullet.Anchored = true
        Bullet.CanCollide = false
        Bullet.Parent = workspace

        local BulletTween = TweenService:Create(Bullet, TweenInfo.new(.7), {Position = Bullet.Position + Vector3.new(0,0,-50)})
        BulletTween:Play()

        BulletTween.Completed:Connect(function()
            Bullet:Destroy()
        end)
    end
end

-- Events & function calling

EnterPlayzoneFunction.OnClientInvoke = function(LevelName: string, WaitTime: number, LevelSideMotion: number, StartingHorde: table)
    local Level, Horde = GeneratePlayzone(LevelName)

    coroutine.wrap(function()
        GenerateMarch(Level, WaitTime)
    end)()

    GenerateControls(Level, Horde, LevelSideMotion)

    ReflectHorde(StartingHorde)

    return
end

ReflectHordeEvent.OnClientEvent:Connect(ReflectHorde)
FireHordeEvent.OnClientEvent:Connect(FireHorde)