-- Data module
-- Initialized by KingCreoo on 7/18/2024

-- Define module
local _Data = {}

-- Define services
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Define modules
local _Settings = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Settings"))

-- Define variables
local DataStore = DataStoreService:GetDataStore("_ds_6")

local Database = {}
local Saves = {}

-- Local functions

-- Recursively copy table data
local function DeepCopy(Table)
    local Copy = {}

    for k, v in pairs(Table) do
        if type(v) == table then
            DeepCopy(v)
        else
            Copy[k] = v
        end
    end

    return Copy
end

-- Recursively reconcile two tables (use for game updates & major codebase changes)
local function DeepReconcile(Table0: table --[[Default data]], Table1: table --[[Player's data]])
    for k, v in pairs(Table0) do
        if not Table1[k] then continue end

        if type(v) == table then
            DeepReconcile(Table0[k], Table1[k])
        else
            if Table1[k] then 
                Table0[k] = Table1[k] 
            end
        end
    end
end

-- Module functions

-- Return player's data
function _Data.Get(Player: Player)
    return Database[Player.Name]
end

-- Set player's data to the database and to the datastore(if eligble)
function _Data.Set(Player: Player, PlayerData: table)
    Database[Player.Name] = PlayerData -- Set player's data
    
    local leaderstats = Player:FindFirstChild("leaderstats")
    if leaderstats then
        for Stat, Value in pairs(PlayerData["leaderstats"]) do -- Update player's leaderstat data here
            leaderstats:WaitForChild(Stat).Value = Value
        end
    end
    

    local TimeOfTransaction = os.time()
    local ToSave

    if not Saves[Player.Name] then -- Find if the player is eligable for a save at TimeOfTransaction
        ToSave = true
    else
        if Saves[Player.Name] - TimeOfTransaction > 60 then
            ToSave = true
        end
    end

    if not ToSave then return end -- If ineligble for save then return

    Saves[Player.name] = TimeOfTransaction

    local Success, ErrorMessage = pcall(function()
        DataStore:SetAsync("Player_" .. Players:GetUserIdFromNameAsync(Player.Name), PlayerData) -- Save the player's data
    end)

    if not Success then 
        warn(ErrorMessage) -- If there was an error in the save: warn of error (maybe write some kind of warning for the player in the future)
        -- TODO warn player that there data has saved incorrectly
        -- TODO create contingency methods
    end
end

function _Data.Initialize(Player: Player)
    local PlayerData
    local NewPlayer

    local Success, ErrorMessage = pcall(function()
        PlayerData = DataStore:GetAsync("Player_" .. Players:GetUserIdFromNameAsync(Player.Name))
    end)

    if not Success then
        warn(ErrorMessage)
        -- TODO warn player that their data has not loaded properly
    end

    -- If player has no data, then we will give them the standard new player data
    if not PlayerData then
        PlayerData = DeepCopy(_Settings.StandardData)
        NewPlayer = true
    end

    -- If player's data is not up to date, then reconcile it with the updated standard data
    if PlayerData["Version"] ~= _Settings.Version then
        PlayerData = DeepReconcile(_Settings.StandardData, PlayerData)
    end

    Database[Player.Name] = PlayerData

    return PlayerData, NewPlayer
end

function _Data.Clear(Player: Player)
    local PlayerData = DeepCopy(Database[Player.Name]) -- Make a copy of player's data for safe keeping
    PlayerData["Version"] = _Settings.Version -- Set player's data version for data security
    Database[Player.Name] = nil -- Delete player's data
    Saves[Player.Name] = nil

    local Success, ErrorMessage = pcall(function()
        DataStore:SetAsync("Player_" .. Players:GetUserIdFromNameAsync(Player.Name), PlayerData) -- Save the copy of the player's data as final save
    end)

    if not Success then 
        warn(ErrorMessage) -- If there was an error in the save, warn of error
    end

    return PlayerData -- Return copy of player's data
end

-- Return module
return _Data