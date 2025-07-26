-- Combined Auto Expedition and UI Utility Script
-- Expedition Auto Logic by Oevani + Utility Enhancements by KG3L

-- Load Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Window Setup
local Window = Rayfield:CreateWindow({
   Name = "Expedition Antarctica Script",
   Icon = 0,
   LoadingTitle = "Welcome",
   LoadingSubtitle = "by Joseph",
   Theme = "Default",
   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false,
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "ExpeditionAntarcticaConfig",
      FileName = "Settings"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },
   KeySystem = false
})

-- UI Tabs
local MainTab = Window:CreateTab("🏔️ Main", nil)
local MiscTab = Window:CreateTab("🔧 Misc", nil)
local Section = MainTab:CreateSection("Movement")
local MiscSection = MiscTab:CreateSection("Utilities")

-- === CONFIGURABLE STATS === --
local CurrentSpeed = 16
local CurrentJump = 50
local AutoFarmActive = false
local NoclipActive = false
local FogRemoved = false

-- === TELEPORT BUTTONS TO CAMPS === --
local Camps = {
    ["Camp 1"] = CFrame.new( -(4236.6 -(114 + 404)), 227.4, 723.6 -(106 + 382) ),
    ["Camp 2"] = CFrame.new(1789.7, 107.8, -137),
    ["Camp 2.5"] = CFrame.new(5635.53, 341.25, 92.76),
    ["Camp 3"] = CFrame.new(5892.1, 323.4, -20.3),
    ["Camp 4"] = CFrame.new(8992.2, 598, 102.6),
    ["South Pole"] = CFrame.new(11001.9, 551.5, 103)
}

for name, cframe in pairs(Camps) do
    MainTab:CreateButton({
        Name = "🚩 Teleport to " .. name,
        Callback = function()
            local char = game.Players.LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = cframe
            end
        end
    })
end

