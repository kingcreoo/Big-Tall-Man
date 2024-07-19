-- Server side core script
-- Initialized by KingCreoo on 7/18/2024

-- Define services
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Define modules
local _Data = require(ServerScriptService:WaitForChild("Modules"):WaitForChild("Data"))

-- Define variables
local Limbo = workspace:WaitForChild("Limbo")
local Lobby = workspace:WaitForChild("Lobby")

local EnterPlayzone = Lobby:WaitForChild("EnterPlayzone")

local Events = ReplicatedStorage:WaitForChild("Events")
local ReflectHordeEvent: RemoteEvent = Events:WaitForChild("ReflectHorde")
local FireHordeEvent: RemoteEvent = Events:WaitForChild("FireHorde")

local Functions = ReplicatedStorage:WaitForChild("Functions")
local EnterPlayzoneFunction: RemoteFunction = Functions:WaitForChild("EnterPlayzone")

local Levels = ReplicatedStorage:WaitForChild("Levels")

local EnterPlayzoneDebounce = {}

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

-- Manage joining playzone
local function OnEnterPlayzone(Player)
    -- Set debounce for player
    if EnterPlayzoneDebounce[Player.Name] then return end

    EnterPlayzoneDebounce[Player.Name] = true

    -- Prompt player for level and controls, for now just give Level1

    -- Send player to limbo
    TeleportPlayer(Player, Limbo:WaitForChild("Teleport"))

    -- TODO setup level configs: base horde, waitimes, speed, sidemotion, etc.
    -- For now, just give basic things
    local PlayerHorde = {
        [1] = 1,
        [2] = 1,
        [3] = 0,
        [4] = 0,
        [5] = 0,
        [6] = 0,
        [7] = 0,
        [8] = 0,
        [9] = 0,
        [10] = 0,
        [11] = 0,
        [12] = 0,
        [13] = 0,
        [14] = 0,
        [15] = 0,
        [16] = 0,
        [17] = 0,
        [18] = 0,
        [19] = 0,
        [20] = 0,
        [21] = 0,
        [22] = 0,
        [23] = 0,
        [24] = 0
    }

    local function AddSoldier()
        for i = 1, #PlayerHorde do
            if PlayerHorde[i] == 0 then
                PlayerHorde[i] = 1
                    ReflectHordeEvent:FireClient(Player, PlayerHorde)
                break
            end
        end
    end

    local function RemoveSoldier()
        for i = #PlayerHorde, 1, -1 do
            if PlayerHorde[i] == 1 then
                PlayerHorde[i] = 0
                    ReflectHordeEvent:FireClient(Player, PlayerHorde)
                break
            end
        end
    end

    -- Invoke client to generate level & NPC on client-side
    EnterPlayzoneFunction:InvokeClient(Player, "Level1", 3, 20, PlayerHorde) -- for now pipe in basic level args

    local FireSequence = coroutine.wrap(function()
        while true do
            task.wait(1)
            FireHordeEvent:FireClient(Player, PlayerHorde)
        end
    end)()
end

-- Events & function calling

Players.PlayerAdded:Connect(OnPlayerAdded)
Players.PlayerRemoving:Connect(OnPlayerRemoving)

-- Manage when player's want to join the playzone
EnterPlayzone.Touched:Connect(function(hit)
    if not hit.Parent:FindFirstChild("Humanoid") then return end

    local Player = Players:GetPlayerFromCharacter(hit.Parent)

    if not Player then return end

    OnEnterPlayzone(Player)
end)