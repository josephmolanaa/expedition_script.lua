-- Combined Auto Expedition and UI Utility Script
-- Expedition Auto Logic by Oevani + Utility Enhancements by KG3L

-- Load Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Window Setup
local Window = Rayfield:CreateWindow({
   Name = "Expedition Antarctica Script",
   Icon = 0,
   LoadingTitle = "KAIDO HUB",
   LoadingSubtitle = "by KG3L",
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
    ["Camp 1"] = CFrame.new(-4718.6, 227.4, 235.6),
    ["Camp 2"] = CFrame.new(1789.7, 107.8, -137),
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

-- === AUTO EXPEDITION CODE START (Oevani's logic goes here) === --
local AutoExpeditionScript = loadstring(game:HttpGet("https://raw.githubusercontent.com/oevani/expedition-ant/main/autoexpedition.lua"))
if AutoExpeditionScript then
    AutoExpeditionScript()
end

-- === UI FEATURES === --

-- Speed Slider
MainTab:CreateSlider({
    Name = "🏃‍♂️ Walk Speed",
    Range = {16, 200},
    Increment = 1,
    Suffix = " studs",
    CurrentValue = 16,
    Flag = "SpeedSlider",
    Callback = function(Value)
        CurrentSpeed = Value
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            char:FindFirstChildOfClass("Humanoid").WalkSpeed = Value
        end
    end
})

-- Jump Power Slider
MainTab:CreateSlider({
    Name = "🦨 Jump Power",
    Range = {50, 200},
    Increment = 1,
    Suffix = " studs",
    CurrentValue = 50,
    Flag = "JumpSlider",
    Callback = function(Value)
        CurrentJump = Value
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            char:FindFirstChildOfClass("Humanoid").JumpPower = Value
        end
    end
})

-- Reapply on respawn
game.Players.LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = CurrentSpeed
        hum.JumpPower = CurrentJump
    end
end)

-- Infinite Jump
local jumpConnection
MainTab:CreateToggle({
   Name = "Infinite Jump",
   CurrentValue = false,
   Flag = "InfiniteJumpToggle",
   Callback = function(Value)
        _G.infinjump = Value
        if Value and _G.infinJumpStarted == nil then
            _G.infinJumpStarted = true
            Rayfield:Notify({ Title = "Infinite Jump", Content = "Press space to infinite jump!", Duration = 5 })
            local plr = game.Players.LocalPlayer
            local m = plr:GetMouse()
            jumpConnection = m.KeyDown:Connect(function(k)
                if _G.infinjump and k:byte() == 32 then
                    local hum = plr.Character:FindFirstChildOfClass('Humanoid')
                    if hum then
                        hum:ChangeState('Jumping')
                        task.wait()
                        hum:ChangeState('Seated')
                    end
                end
            end)
        elseif not Value and jumpConnection then
            jumpConnection:Disconnect()
        end
   end
})

-- The rest of the original script (AutoFarm, FPS Booster, etc.) remains unchanged --
