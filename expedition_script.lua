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

-- FPS Booster
MiscTab:CreateButton({
    Name = "🚀 FPS Booster",
    Callback = function()
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Decal") or v:IsA("Smoke") or v:IsA("Fire") then
                v:Destroy()
            end
        end
        settings().Rendering.QualityLevel = 1
        game:GetService("Lighting").GlobalShadows = false
        Rayfield:Notify({ Title = "FPS Boost Applied", Content = "Graphics optimized for performance", Duration = 3 })
    end
})

-- FOV Slider
MiscTab:CreateSlider({
    Name = "👁️ Field of View",
    Range = {70, 120},
    Increment = 1,
    Suffix = "°",
    CurrentValue = 70,
    Flag = "FOVSlider",
    Callback = function(Value)
        workspace.CurrentCamera.FieldOfView = Value
    end
})

-- NoClip
local NoclipConnection = nil
MiscTab:CreateToggle({
    Name = "🚀 NoClip (Walk Through Walls)",
    CurrentValue = false,
    Flag = "NoClipToggle",
    Callback = function(Value)
        NoclipActive = Value
        if NoclipConnection then
            NoclipConnection:Disconnect()
            NoclipConnection = nil
        end
        if Value then
            NoclipConnection = game:GetService("RunService").Stepped:Connect(function()
                if game.Players.LocalPlayer.Character then
                    for _, part in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
            Rayfield:Notify({ Title = "NoClip Enabled", Content = "You can now walk through walls", Duration = 3 })
        else
            Rayfield:Notify({ Title = "NoClip Disabled", Content = "Collisions restored", Duration = 3 })
        end
    end
})

-- Fullbright / Remove Fog
local OriginalFogStart = game.Lighting.FogStart
local OriginalFogEnd = game.Lighting.FogEnd
MiscTab:CreateToggle({
    Name = "💡 Fullbright (Remove Darkness)",
    CurrentValue = false,
    Flag = "FullbrightToggle",
    Callback = function(Value)
        if Value then
            game.Lighting.Ambient = Color3.new(1, 1, 1)
            game.Lighting.FogEnd = 100000
            Rayfield:Notify({ Title = "Fullbright Enabled", Content = "Darkness removed from the game", Duration = 3 })
        else
            game.Lighting.Ambient = Color3.new(0.5, 0.5, 0.5)
            game.Lighting.FogEnd = 10000
            Rayfield:Notify({ Title = "Fullbright Disabled", Content = "Default lighting restored", Duration = 3 })
        end
    end
})

MiscTab:CreateToggle({
    Name = "🌫️ Remove Fog",
    CurrentValue = false,
    Flag = "RemoveFogToggle",
    Callback = function(Value)
        FogRemoved = Value
        if Value then
            OriginalFogStart = game.Lighting.FogStart
            OriginalFogEnd = game.Lighting.FogEnd
            game.Lighting.FogStart = 0
            game.Lighting.FogEnd = 100000
            Rayfield:Notify({ Title = "Fog Removed", Content = "All fog has been cleared", Duration = 3 })
        else
            game.Lighting.FogStart = OriginalFogStart
            game.Lighting.FogEnd = OriginalFogEnd
            Rayfield:Notify({ Title = "Fog Restored", Content = "Default fog settings applied", Duration = 3 })
        end
    end
})

-- Initial notification
Rayfield:Notify({
   Title = "Script Loaded!",
   Content = "Expedition Antarctica Script by JosephStarling",
   Duration = 6.5
})
