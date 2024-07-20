-- Environment management module
-- Initialized by KingCreoo on 7/19/2024

-- Define module
local _Environment = {}
_Environment.__index = _Environment

-- Define services
local Players: Players = game:GetService("Players")
local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService: ServerScriptService = game:GetService("ServerScriptService")

-- Define modules
local _Data = require(ServerScriptService:WaitForChild("Modules"):WaitForChild("Data"))
local _Settings = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Settings"))

-- Define variables
local LevelAnchors = workspace:WaitForChild("LevelAnchors")
local ActiveLevels = workspace:WaitForChild("ActiveLevels")

local Bindables = ReplicatedStorage:WaitForChild("Bindables")
local TeleportPlayerBindable: BindableEvent = Bindables:WaitForChild("TeleportPlayer")

local Events = ReplicatedStorage:WaitForChild("Events")
local ToggleControlsEvent: RemoteEvent = Events:WaitForChild("ToggleControls")
local GenerateEnvironmentEvent: RemoteEvent = Events:WaitForChild("GenerateEnvironment")

-- Local functions

-- See what anchors are avaiable and select one
local function SelectAnchor()
   for _, Anchor in pairs(LevelAnchors:GetChildren()) do
        if Anchor:GetAttribute("Occupied") == false then
            Anchor:SetAttribute("Occupied", true)
            return Anchor
        end
   end 
end

local function CreateLevel(Player: Player, LevelID: string, Anchor: Part)
    local Level = ReplicatedStorage:WaitForChild("Levels"):FindFirstChild(LevelID)
    if not Level then
        -- TODO contingency here
        error("cannot find level")
    end

    Level = Level:Clone()
    Level.Name = Player.Name .. "-Level"
    Level:SetPrimaryPartCFrame(Anchor.CFrame)
    Level.Parent = ActiveLevels

    return Level
end

-- Module functions

-- Create & initialize a new environment
function _Environment.Create(Player: Player, LevelID: string)
    local self = setmetatable({}, _Environment)

    self.Player = Player.Name
    self.LevelID = LevelID

    self.Anchor = SelectAnchor()
    self.Level = CreateLevel(Player, LevelID, self.Anchor)

    self.HordeTable = table.clone(_Settings.LevelData[self.LevelID]["StartingHorde"])

    -- Generate base horde
    -- TODO with level's base horde
    local Horde = ReplicatedStorage:WaitForChild("Horde"):Clone()
    Horde.Parent = self.Level
    Horde:SetPrimaryPartCFrame(self.Level:WaitForChild("Start").CFrame)
    self.Horde = Horde

    -- Teleport player & terminate controls
    TeleportPlayerBindable:Fire(Player, workspace:WaitForChild("Limbo"):WaitForChild("Teleport"))
    ToggleControlsEvent:FireClient(Player, 0)

    GenerateEnvironmentEvent:FireClient(Player, self.Level, self.HordeTable ,20 --[[fix here]] )

    -- TODO reflect horde

    return self
end

    -- Return module
return _Environment