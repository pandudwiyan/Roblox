-- LocalScript di StarterPlayerScripts
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local PhysicsService = game:GetService("PhysicsService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Tunggu karakter siap
local char = player.Character or player.CharacterAdded:Wait()
char:WaitForChild("HumanoidRootPart")
char:WaitForChild("Humanoid")
local hrp = char.HumanoidRootPart
local hum = char.Humanoid

-- Collision group khusus
local groupName = "PlayerOnly_" .. player.UserId
pcall(function() PhysicsService:CreateCollisionGroup(groupName) end)
PhysicsService:CollisionGroupSetCollidable(groupName, groupName, true)
for _, g in ipairs(PhysicsService:GetCollisionGroups()) do
    if g.name ~= groupName then
        PhysicsService:CollisionGroupSetCollidable(groupName, g.name, false)
    end
end
for _, part in ipairs(char:GetDescendants()) do
    if part:IsA("BasePart") then
        PhysicsService:SetPartCollisionGroup(part, groupName)
    end
end
char.DescendantAdded:Connect(function(d)
    if d:IsA("BasePart") then PhysicsService:SetPartCollisionGroup(d, groupName) end
end)

-- ===== GUI Setup =====
local gui = Instance.new("ScreenGui")
gui.Name = "ModeSpawnGUI"
gui.ResetOnSpawn = false
gui.DisplayOrder = 1000
gui.Parent = playerGui

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 80, 0, 35)
button.Position = UDim2.new(1, -90, 0, 15)
button.AnchorPoint = Vector2.new(0,0)
button.BackgroundColor3 = Color3.fromRGB(0,0,0)
button.BackgroundTransparency = 0.4
button.TextColor3 = Color3.fromRGB(255,255,255)
button.Text = "Mode: Off"
button.Parent = gui
local uic = Instance.new("UICorner", button)
uic.CornerRadius = UDim.new(0,10)

-- Draggable
local dragging, dragStart, startPos
button.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = button.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        button.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                    startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Toggle Mode
local modes = {"Off","Mode1","Mode2","Mode3"}
local currentModeIndex = 1
local function toggleMode()
    currentModeIndex = currentModeIndex % #modes + 1
    button.Text = "Mode: "..modes[currentModeIndex]
end
button.MouseButton1Click:Connect(toggleMode)
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.Q then toggleMode() end
end)

-- ===== Spawn Part Function =====
local function spawnPart()
    local part = Instance.new("Part")
    part.Size = Vector3.new(10,1,10)
    part.Anchored = true
    part.CanCollide = true
    part.Color = Color3.fromRGB(255,255,255)
    part.Transparency = 1 -- start transparan
    part.Position = Vector3.new(hrp.Position.X, hrp.Position.Y - hum.HipHeight - 0.5, hrp.Position.Z)
    part.Parent = workspace
    PhysicsService:SetPartCollisionGroup(part, groupName)

    -- Tween fade in
    TweenService:Create(part, TweenInfo.new(0.2), {Transparency=0.25}):Play()
    -- Auto fade out & remove
    local t = TweenService:Create(part, TweenInfo.new(0.3), {Transparency=1})
    Debris:AddItem(part,5)
    delay(4.7,function() t:Play() end)
end

-- ===== Mode Logic =====
local moving = false
local jumping = false
local peakY = nil
local landedY = nil

-- Humanoid state change lebih akurat
hum.StateChanged:Connect(function(oldState, newState)
    local mode = modes[currentModeIndex]
    
    if mode == "Mode2" then
        if newState == Enum.HumanoidStateType.Jumping then
            jumping = true
            peakY = hrp.Position.Y
        elseif jumping and newState == Enum.HumanoidStateType.Freefall then
            if hrp.Position.Y < peakY then
                spawnPart()
                jumping = false
            else
                peakY = math.max(peakY, hrp.Position.Y)
            end
        elseif newState == Enum.HumanoidStateType.Landed then
            jumping = false
        end

    elseif mode == "Mode3" then
        if newState == Enum.HumanoidStateType.Jumping then
            jumping = true
            landedY = hrp.Position.Y
        elseif jumping and newState == Enum.HumanoidStateType.Landed then
            if math.abs(hrp.Position.Y - landedY) < 0.1 then
                spawnPart()
            end
            jumping = false
        end
    end
end)

-- Mode1: pergerakan deteksi di Heartbeat
RunService.Heartbeat:Connect(function()
    if modes[currentModeIndex] == "Mode1" then
        local isMoving = hum.MoveDirection.Magnitude > 0
        if isMoving and not moving then
            spawnPart()
        end
        moving = isMoving
    end
end)
