-- LocalScript di StarterPlayerScripts
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local PhysicsService = game:GetService("PhysicsService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")

-- Buat collision group khusus
local groupName = "PlayerOnly_" .. player.UserId
pcall(function()
    PhysicsService:CreateCollisionGroup(groupName)
end)
PhysicsService:CollisionGroupSetCollidable(groupName, groupName, true)
-- Non-collide sama semua group lain
for _, g in ipairs(PhysicsService:GetCollisionGroups()) do
    if g.name ~= groupName then
        PhysicsService:CollisionGroupSetCollidable(groupName, g.name, false)
    end
end

-- Masukin semua part karakter ke collision group
for _, part in ipairs(char:GetDescendants()) do
    if part:IsA("BasePart") then
        PhysicsService:SetPartCollisionGroup(part, groupName)
    end
end
char.DescendantAdded:Connect(function(d)
    if d:IsA("BasePart") then
        PhysicsService:SetPartCollisionGroup(d, groupName)
    end
end)

-- Fungsi spawn part
local function spawnPart()
    local part = Instance.new("Part")
    part.Size = Vector3.new(10, 1, 10)
    part.Anchored = true
    part.Color = Color3.fromRGB(255, 255, 255)
    part.Transparency = 0.75
    part.CanCollide = true
    part.Position = Vector3.new(hrp.Position.X, hrp.Position.Y - hum.HipHeight - 0.5, hrp.Position.Z)
    part.Parent = workspace

    -- Set collision hanya buat player ini
    PhysicsService:SetPartCollisionGroup(part, groupName)

    game.Debris:AddItem(part, 5)
end

-- GUI tombol mode
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:WaitForChild("PlayerGui")

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 60, 0, 30)
button.Position = UDim2.new(1, -70, 0, 10)
button.AnchorPoint = Vector2.new(0, 0)
button.Text = "Off"
button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.Parent = screenGui

-- Bikin draggable
local dragging = false
local dragStart, startPos
local function updateDrag(input)
    local delta = input.Position - dragStart
    button.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end
button.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = button.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        updateDrag(input)
    end
end)

-- Mode toggle
local modes = {"Off", "Mode1", "Mode2", "Mode3"}
local currentModeIndex = 1
button.MouseButton1Click:Connect(function()
    currentModeIndex = currentModeIndex % #modes + 1
    button.Text = modes[currentModeIndex]
end)

-- Variabel deteksi
local wasMoving = false
local jumping = false
local peakY = nil
local landedY = nil

RunService.Heartbeat:Connect(function()
    local mode = modes[currentModeIndex]
    if mode == "Mode1" then
        local moving = hum.MoveDirection.Magnitude > 0
        if moving and not wasMoving then
            spawnPart()
        end
        wasMoving = moving

    elseif mode == "Mode2" then
        if hum:GetState() == Enum.HumanoidStateType.Jumping then
            jumping = true
            peakY = hrp.Position.Y
        elseif jumping and hum:GetState() == Enum.HumanoidStateType.Freefall then
            if hrp.Position.Y < peakY then
                spawnPart()
                jumping = false
            else
                peakY = math.max(peakY, hrp.Position.Y)
            end
        elseif hum:GetState() == Enum.HumanoidStateType.Landed then
            jumping = false
        end

    elseif mode == "Mode3" then
        if hum:GetState() == Enum.HumanoidStateType.Jumping then
            jumping = true
            landedY = hrp.Position.Y
        elseif jumping and hum:GetState() == Enum.HumanoidStateType.Landed then
            if math.abs(hrp.Position.Y - landedY) < 0.1 then
                spawnPart()
            end
            jumping = false
        end
    end
end)
