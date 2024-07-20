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

-- Define variables
local LevelAnchors = workspace:WaitForChild("LevelAnchors")
local ActiveLevels = workspace:WaitForChild("ActiveLevels")

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

    return self
end

    -- Return module
return _Environment