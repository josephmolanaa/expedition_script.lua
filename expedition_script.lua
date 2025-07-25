-- Cleaned and unified script combining UI utilities and Auto Expedition logic
-- Original contributors: Oevani (logic), KG3L (UI enhancements), JosephStarling

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

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

-- Tabs
local MainTab = Window:CreateTab("🏔️ Main")
local MiscTab = Window:CreateTab("🔧 Misc")

-- Stats
local CurrentSpeed = 16
local CurrentJump = 50
local AutoFarmActive = false
local NoclipActive = false
local FogRemoved = false

-- Camp Teleports
local CampTeleports = {
    ["Camp 1"] = CFrame.new(-4236.6 + 114 + 404, 227.4, 723.6 - (106 + 382)),
    ["Camp 2"] = CFrame.new(1789.7, 107.8, -137),
    ["MT. Vinson"] = CFrame.new(3733.94, 1508.68, -184.84),
    ["Camp 3"] = CFrame.new(5892.1, 323.4, -20.3),
    ["Camp 4"] = CFrame.new(8992.2, 598, 102.6),
    ["5 South Pole"] = CFrame.new(11001.9, 551.5, 103)
}

for name, cframe in pairs(CampTeleports) do
    MainTab:CreateButton({
        Name = "🚩 Teleport to " .. name,
        Callback = function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = cframe
            end
        end
    })
end

-- Expedition Camps
local Camps = {
    {Name = "Spawn", CFrame = CFrame.new(-9774.5, -156.6, -53.6)},
    {Name = "Camp 1", CFrame = CFrame.new(-4754.6, 227.4, 235.6)},
    {Name = "Camp 2", CFrame = CFrame.new(1789.7, 107.8, -137)},
    {Name = "Camp 3", CFrame = CFrame.new(5892.1, 323.4, -20.3)},
    {Name = "Camp 4", CFrame = CFrame.new(8992.2, 598, 102.6)},
    {Name = "South Pole", CFrame = CFrame.new(11001.9, 551.5, 103.8)}
}

-- Expedition Logic
local currentCampIndex = 1
local currentLoop = 0
local maxLoops = 0
local expeditionActive = false
local autoJumpTask, cameraFollowConnection = nil, nil

local function isGrounded(root)
    local ray = workspace:Raycast(root.Position, Vector3.new(0, -4, 0), RaycastParams.new())
    return ray ~= nil
end

local function doJumpReset()
    if not expeditionActive then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            local root = char:FindFirstChild("HumanoidRootPart")
            if hum and root and hum.Health > 0 and isGrounded(root) then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end

local function startAutoJump()
    if not autoJumpTask then
        autoJumpTask = task.spawn(function()
            while expeditionActive do
                doJumpReset()
                task.wait(2)
            end
        end)
    end
end

local function stopAutoJump()
    if autoJumpTask then
        task.cancel(autoJumpTask)
        autoJumpTask = nil
    end
end

local function teleportToCamp(index)
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")
    stopAutoJump()
    task.wait(3)
    root.Anchored = true
    root.CFrame = Camps[index].CFrame
    task.wait(1)
    root.Anchored = false
    task.wait(1)
end

RunService.RenderStepped:Connect(function()
    if not expeditionActive then return end
    for _, guiObj in ipairs(LocalPlayer.PlayerGui:GetDescendants()) do
        if guiObj:IsA("TextLabel") and guiObj.Visible and guiObj.Text:find("You have made it to") then
            local expectedCamp = Camps[currentCampIndex].Name
            if guiObj.Text:find(expectedCamp) then
                currentCampIndex += 1
                if expectedCamp ~= "South Pole" then
                    Rayfield:Notify({Title = "Camp Reached", Content = expectedCamp .. " reached. Moving on...", Duration = 3})
                    teleportToCamp(currentCampIndex)
                else
                    Rayfield:Notify({Title = "South Pole Reached", Content = "Handling next loop...", Duration = 3})
                    currentLoop += 1
                    if maxLoops > 0 and currentLoop >= maxLoops then
                        expeditionActive = false
                        stopAutoJump()
                        Rayfield:Notify({Title = "Done", Content = "Completed all loops.", Duration = 5})
                        return
                    end
                    teleportToCamp(1)
                end
            end
            break
        end
    end
end)

-- Expedition UI
local AutoTab = Window:CreateTab("Auto Expedition")

AutoTab:CreateToggle({
    Name = "Start Expedition",
    CurrentValue = false,
    Callback = function(state)
        expeditionActive = state
        if state then
            currentCampIndex = 2
            currentLoop = 0
            Rayfield:Notify({Title = "Started", Content = "Starting from Camp 1", Duration = 5})
            startAutoJump()
            teleportToCamp(currentCampIndex)
        else
            stopAutoJump()
            Rayfield:Notify({Title = "Stopped", Content = "Expedition stopped.", Duration = 5})
        end
    end
})

AutoTab:CreateInput({
    Name = "Loop Count (0 = infinite)",
    PlaceholderText = "0",
    Callback = function(value)
        local num = tonumber(value)
        if num and num >= 0 then
            maxLoops = num
        else
            Rayfield:Notify({Title = "Warning", Content = "Loop count must be >= 0", Duration = 4})
        end
    end
})

-- MainTab Features: Speed & Jump
MainTab:CreateSlider({
    Name = "🏃‍♂️ Walk Speed",
    Range = {16, 200},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(v)
        CurrentSpeed = v
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = v end
    end
})

MainTab:CreateSlider({
    Name = "🦨 Jump Power",
    Range = {50, 200},
    Increment = 1,
    CurrentValue = 50,
    Callback = function(v)
        CurrentJump = v
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.JumpPower = v end
    end
})

-- Auto apply on respawn
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = CurrentSpeed
        hum.JumpPower = CurrentJump
    end
end)

-- Misc Utilities
MiscTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Callback = function(Value)
        _G.infinjump = Value
        if Value and _G.infinJumpStarted == nil then
            _G.infinJumpStarted = true
            Rayfield:Notify({Title = "Infinite Jump", Content = "Press space to jump infinitely!", Duration = 5})
            local m = LocalPlayer:GetMouse()
            m.KeyDown:Connect(function(k)
                if _G.infinjump and k:byte() == 32 then
                    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                    if hum then
                        hum:ChangeState("Jumping")
                        task.wait()
                        hum:ChangeState("Seated")
                    end
                end
            end)
        end
    end
})

MiscTab:CreateButton({
    Name = "🚀 FPS Booster",
    Callback = function()
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Decal") or v:IsA("Smoke") or v:IsA("Fire") then
                v:Destroy()
            end
        end
        settings().Rendering.QualityLevel = 1
        Lighting.GlobalShadows = false
        Rayfield:Notify({Title = "FPS Boost", Content = "Graphics optimized", Duration = 3})
    end
})

MiscTab:CreateSlider({
    Name = "👁️ Field of View",
    Range = {70, 120},
    Increment = 1,
    CurrentValue = 70,
    Callback = function(v)
        workspace.CurrentCamera.FieldOfView = v
    end
})

-- NoClip
local NoclipConnection = nil
MiscTab:CreateToggle({
    Name = "🚀 NoClip",
    CurrentValue = false,
    Callback = function(Value)
        NoclipActive = Value
        if NoclipConnection then
            NoclipConnection:Disconnect()
            NoclipConnection = nil
        end
        if Value then
            NoclipConnection = RunService.Stepped:Connect(function()
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end)
            Rayfield:Notify({Title = "NoClip Enabled", Content = "Walk through walls active", Duration = 3})
        else
            Rayfield:Notify({Title = "NoClip Disabled", Content = "Collisions restored", Duration = 3})
        end
    end
})

-- Fullbright and Fog
local OriginalFogStart, OriginalFogEnd = Lighting.FogStart, Lighting.FogEnd

MiscTab:CreateToggle({
    Name = "💡 Fullbright",
    CurrentValue = false,
    Callback = function(Value)
        Lighting.Ambient = Value and Color3.new(1,1,1) or Color3.new(0.5, 0.5, 0.5)
        Lighting.FogEnd = Value and 100000 or 10000
        Rayfield:Notify({Title = Value and "Fullbright Enabled" or "Fullbright Disabled", Content = "Lighting updated", Duration = 3})
    end
})

MiscTab:CreateToggle({
    Name = "🌫️ Remove Fog",
    CurrentValue = false,
    Callback = function(Value)
        FogRemoved = Value
        Lighting.FogStart = Value and 0 or OriginalFogStart
        Lighting.FogEnd = Value and 100000 or OriginalFogEnd
        Rayfield:Notify({Title = Value and "Fog Removed" or "Fog Restored", Content = "Fog settings updated", Duration = 3})
    end
})

-- Initial Notification
Rayfield:Notify({
    Title = "Script Loaded!",
    Content = "Expedition Antarctica Script by JosephStarling",
    Duration = 6.5
})
