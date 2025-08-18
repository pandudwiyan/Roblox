--// UI Sederhana Anti Jatuh + Auto Climb
-- by ChatGPT

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local hrp = char:WaitForChild("HumanoidRootPart")

--// Variables
local autoClimb = false
local antiSlip = false
local anchorMode = false

--// Buat UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "AntiFallUI"

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 180, 0, 160)
Frame.Position = UDim2.new(1, -200, 0, 40)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

-- Header
local Header = Instance.new("TextLabel")
Header.Size = UDim2.new(1, 0, 0, 25)
Header.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Header.Text = "⚙ Anti Jatuh UI"
Header.TextColor3 = Color3.fromRGB(255,255,255)
Header.TextSize = 14
Header.Parent = Frame

-- Tombol Minimize/Close
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -25, 0, 0)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseBtn.Parent = Frame

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 25, 0, 25)
MinBtn.Position = UDim2.new(1, -50, 0, 0)
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
MinBtn.Parent = Frame

-- Container
local Container = Instance.new("Frame")
Container.Size = UDim2.new(1, 0, 1, -25)
Container.Position = UDim2.new(0, 0, 0, 25)
Container.BackgroundTransparency = 1
Container.Parent = Frame

-- Buat fungsi toggle button
local function createToggle(name, order, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 30)
    btn.Position = UDim2.new(0, 10, 0, (order-1)*35)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.TextSize = 14
    btn.Text = name.." [OFF]"
    btn.Parent = Container

    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = name.." ["..(state and "ON" or "OFF").."]"
        btn.BackgroundColor3 = state and Color3.fromRGB(80,150,80) or Color3.fromRGB(60,60,60)
        callback(state)
    end)
end

--// Toggle List
createToggle("Auto Climb", 1, function(v) autoClimb = v end)
createToggle("Anti Slip", 2, function(v) antiSlip = v end)
createToggle("Anchor", 3, function(v) anchorMode = v end)

--// Logic
RunService.RenderStepped:Connect(function()
    if antiSlip then
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
        if hum:GetState() == Enum.HumanoidStateType.Freefall then
            hrp.Velocity = Vector3.new(hrp.Velocity.X, -10, hrp.Velocity.Z)
        end
    end

    if anchorMode and hum:GetState() == Enum.HumanoidStateType.Freefall then
        hrp.Anchored = true
        task.wait(0.05)
        hrp.Anchored = false
    end

    if autoClimb then
        if hum.MoveDirection.Magnitude > 0 then
            hum:ChangeState(Enum.HumanoidStateType.Climbing)
        end
    end
end)

-- Close / Minimize
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    Container.Visible = not minimized
    Frame.Size = minimized and UDim2.new(0,180,0,25) or UDim2.new(0,180,0,160)
end)
