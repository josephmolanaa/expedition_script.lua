-- Expedition Antarctica: Simple Teleport Buttons Only
-- By JosephStarling

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- UI Setup
local Window = Rayfield:CreateWindow({
    Name = "Teleport Menu",
    LoadingTitle = "Teleport Utility",
    LoadingSubtitle = "Joseph Starling",
    Theme = "Default",
    ConfigurationSaving = {Enabled = false},
    KeySystem = false
})

local MainTab = Window:CreateTab("📍 Teleports")

-- Camp Coordinates
local Camps = {
    ["Camp 1"] = CFrame.new( -(4236.6 -(114 + 404)), 227.4, 723.6 -(106 + 382) ),
    ["Camp 2"] = CFrame.new(1789.7, 107.8, -137),
    ["MT. Vinson"] = CFrame.new(3733.94, 1508.68, -184.84),
    ["Camp 3"] = CFrame.new(5635.53, 341.25, 92.76),
    ["Camp 4"] = CFrame.new(8992.2, 598, 102.6),
    ["South Pole"] = CFrame.new(11001.9, 551.5, 103.8)
}

-- Create Buttons
for name, cframe in pairs(Camps) do
    MainTab:CreateButton({
        Name = "🚩 Teleport to " .. name,
        Callback = function()
            local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local root = char:WaitForChild("HumanoidRootPart")
            root.CFrame = cframe
        end
    })
end
