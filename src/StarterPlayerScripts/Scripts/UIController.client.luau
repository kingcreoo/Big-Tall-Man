-- Client UI controller script
-- Initialized by KingCreoo on 7/19/2024

-- Define services

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Define variables

local LocalPlayer: Player = Players.LocalPlayer
local PlayerGui: PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local CloseElementBindable: BindableEvent = script:WaitForChild("CloseElement")
local OpenElementBindable: BindableEvent = script:WaitForChild("OpenElement")

local Events = ReplicatedStorage:WaitForChild("Events")
local Functions = ReplicatedStorage:WaitForChild("Functions")

local JoinGamePromptEvent: RemoteEvent = Events:WaitForChild("JoinGamePrompt")

-- Define UI Elements

local Main: ScreenGui = PlayerGui:WaitForChild("Main")
local JoinGamePromptFrame: Frame = Main:WaitForChild("JoinGamePromptFrame")

local Elements = {
    ["JoinGamePromptFrame"] = JoinGamePromptFrame
}

local CurrentlyOpen = {}

-- Define management functions

local function CloseOtherElements()
    for CloseElement, Critical in pairs(CurrentlyOpen) do
        if Critical == 0 then
            -- TODO clean animation here
            CloseElement.Visible = false
            CurrentlyOpen[CloseElement] = nil
        end
    end
end

-- Manages opening elements (ex: frames, prompts)
local function OpenElement(ElementName, CloseOthers: boolean, Critical: boolean)
    local Element = Elements[ElementName]

    -- If this is a major element we will close all other open non-critical elements
    if CloseOthers then
        CloseOtherElements()
    end

    -- TODO clean animation here
    Element.Visible = true
    if Critical then
        CurrentlyOpen[Element] = 1 -- If critical (reward, purchase, etc) then mark it as such
    else
        CurrentlyOpen[Element] = 0
    end
end

local function CloseElement(Element, ElementName)
    if Element == nil then
        Element = Elements[ElementName]
    end

    -- TODO clean animation here
    Element.Visible = false
    CurrentlyOpen[Element] = nil
end

-- Function calling & events

JoinGamePromptEvent.OnClientEvent:Connect(OpenElement)
CloseElementBindable.Event:Connect(CloseElement)