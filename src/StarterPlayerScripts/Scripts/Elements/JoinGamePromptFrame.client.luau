-- JoinGamePromptFrame Element
-- Initialized by KingCreoo on 7/18/2024

-- Define services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Define variables
local LocalPlayer: Player = Players.LocalPlayer
local PlayerGui: PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local JoinGamePromptFrame: Frame = PlayerGui:WaitForChild("Main"):WaitForChild("JoinGamePromptFrame")
local JoinGamePromptEvent: RemoteEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("JoinGamePrompt")

local Buttons = JoinGamePromptFrame:WaitForChild("Buttons")
local CancelButton: TextButton = JoinGamePromptFrame:WaitForChild("Cancel")

local CloseElementBindable: BindableEvent = script.Parent.Parent:WaitForChild("UIController"):WaitForChild("CloseElement")

-- Functionality

CancelButton.MouseButton1Click:Connect(function()
    CloseElementBindable:Fire(JoinGamePromptFrame)
end)

for _, Button: TextButton in pairs(Buttons:GetChildren()) do
    Button.MouseButton1Click:Connect(function()
        JoinGamePromptEvent:FireServer(Button:GetAttribute("LevelID"))
        CloseElementBindable:Fire(JoinGamePromptFrame)
    end)
end