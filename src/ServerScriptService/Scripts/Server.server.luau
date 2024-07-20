-- Server side core script
-- Initialized by KingCreoo on 7/18/2024

-- Define services
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Define modules
local _Data = require(ServerScriptService:WaitForChild("Modules"):WaitForChild("Data"))
local _Environment = require(ServerScriptService:WaitForChild("Modules"):WaitForChild("Environment"))

-- Define variables
local Limbo = workspace:WaitForChild("Limbo")
local Lobby = workspace:WaitForChild("Lobby")
local PlayButton = Lobby:WaitForChild("EnterPlayzone")

local Events = ReplicatedStorage:WaitForChild("Events")
local JoinGamePromptEvent: RemoteEvent = Events:WaitForChild("JoinGamePrompt")

local Bindables = ReplicatedStorage:WaitForChild("Bindables")
local TeleportPlayerBindable: BindableEvent = Bindables:WaitForChild("TeleportPlayer")

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

-- Prompt player to join game
local function PlayButtonPressed(Player: Player)
    JoinGamePromptEvent:FireClient(Player, "JoinGamePromptFrame", true, false)
end

-- Manage player joining a game
local function PlayGame(Player: Player, LevelID: string)
    local GameEnvironment = _Environment.Create(Player, LevelID)

    print(GameEnvironment.Player, GameEnvironment.LevelID)
end

-- Setup player's data structure here. ex: leaderstats folder
local function InitializeDataStructure(Player: Player, PlayerData: table)
    local leaderstats = Instance.new("Folder")
    leaderstats.Parent = Player
    leaderstats.Name = "leaderstats"

    for Name, Value in pairs(PlayerData["leaderstats"]) do
        local String = type(Value) .. "Value"

        local Stat = Instance.new(string.upper(string.sub(String, 1, 1)) .. string.sub(String, 2, -1))
        Stat.Name = Name
        Stat.Value = Value
        Stat.Parent = leaderstats
    end
end

-- Manage onboarding players to the server
local function OnPlayerAdded(Player)
    -- Recognize player has joined & define basic variables
    print(Player.Name .. " has joined!")
    local Character = Player.Character or Player.CharacterAdded:Wait()

    -- Load player's data
    local PlayerData, NewPlayer = _Data.Initialize(Player)
    print(PlayerData, NewPlayer)

    -- Initialize player's folders & items
    InitializeDataStructure(Player, PlayerData)

    -- Player joins, spawns at limbo, and is prompted with load screen
    -- TODO Prompt player with load screen

    -- Player exits load screen, we teleport them to the lobby
    -- TODO Prompt new players with a tutorial
    TeleportPlayer(Player, Lobby.Teleport, Character)
end

-- Manage leaving players
local function OnPlayerRemoving(Player)
    _Data.Clear(Player)
end

-- Events & function calling

Players.PlayerAdded:Connect(OnPlayerAdded)
Players.PlayerRemoving:Connect(OnPlayerRemoving)

PlayButton.Touched:Connect(function(hit)
    if not hit.Parent:FindFirstChild("Humanoid") then return end

    local Player = Players:GetPlayerFromCharacter(hit.Parent)
    if not Player then return end

    PlayButtonPressed(Player)
end)

JoinGamePromptEvent.OnServerEvent:Connect(PlayGame)

TeleportPlayerBindable.Event:Connect(TeleportPlayer)