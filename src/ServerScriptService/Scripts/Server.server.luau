-- Server side core script
-- Initialized by KingCreoo on 7/18/2024

-- Define services

local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

-- Define variables

local Limbo = workspace:WaitForChild("Limbo")
local Lobby = workspace:WaitForChild("Lobby")

-- Define functions

-- Teleport player to a location
local function TeleportPlayer(Player: Player, Location: Part, Character: Model)
    -- If we aren't given the character variable, define it within this function
    if not Character then
        Character = Player.Character or Player.CharacterAdded:Wait()
    end

    -- Add three studs on the y axis here so that the player stands on top of it rather than inside of it
    Character:SetPrimaryPartCFrame(Location.CFrame + Vector3.new(0,3,0))
end

-- Manage onboarding players to the server
local function OnPlayerAdded(Player)
    -- Recognize player has joined & define basic variables
    print(Player.Name .. " has joined!")
    local Character = Player.Character or Player.CharacterAdded:Wait()

    -- Player joins, spawns at limbo, and is prompted with load screen
    -- TODO Prompt player with load screen

    -- Player exits load screen, we teleport them to the lobby
    TeleportPlayer(Player, Lobby.Teleport, Character)
end

-- Events & function calling

Players.PlayerAdded:Connect(OnPlayerAdded)