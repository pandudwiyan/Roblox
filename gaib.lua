--// Transparency Toggle GUI
--// Buat semua BasePart dengan Transparency == 1 menjadi 0.9 (hanya client-side).
--// Ada ON/OFF + Minimize + Close. Bisa di mobile, emulator, PC.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- ===== CONFIG =====
local HIDDEN_ALPHA = 1.0    -- target "tidak terlihat"
local REVEAL_ALPHA = 0.90   -- target setelah toggle ON

-- ===== UI =====
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TransparencyController"
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Frame utama
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.fromOffset(180, 100)
mainFrame.Position = UDim2.new(1, -190, 0, 20) -- pojok kanan atas
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

-- Judul
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -60, 0, 30)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.Text = "Transparency"
title.TextSize = 16
title.TextColor3 = Color3.fromRGB(255,255,255)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = mainFrame

-- Tombol Close
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.fromOffset(30, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 0)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Text = "X"
closeBtn.TextScaled = true
closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
closeBtn.Parent = mainFrame

-- Tombol Minimize
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.fromOffset(30, 30)
minBtn.Position = UDim2.new(1, -70, 0, 0)
minBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
minBtn.Text = "-"
minBtn.TextScaled = true
minBtn.TextColor3 = Color3.fromRGB(255,255,255)
minBtn.Parent = mainFrame

-- Tombol Toggle
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(1, -20, 0, 40)
toggleBtn.Position = UDim2.new(0, 10, 0, 40)
toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 120, 40)
toggleBtn.Text = "ON"
toggleBtn.TextScaled = true
toggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
toggleBtn.Parent = mainFrame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 8)
btnCorner.Parent = toggleBtn

-- ===== DRAGGABLE =====
do
    local dragging, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.fromOffset(startPos.X.Offset + delta.X, startPos.Y.Offset + delta.Y)
    end

    mainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = UDim2.fromOffset(mainFrame.AbsolutePosition.X, mainFrame.AbsolutePosition.Y)
        end
    end)
    mainFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement 
        or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
end

-- ===== LOGIC =====
local isOn = false
local isMinimized = false

local function setTransparency(value)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            if obj.Transparency == HIDDEN_ALPHA or obj.LocalTransparencyModifier == HIDDEN_ALPHA then
                obj.LocalTransparencyModifier = value
            end
        end
    end
end

-- Toggle ON/OFF
toggleBtn.MouseButton1Click:Connect(function()
    isOn = not isOn
    if isOn then
        setTransparency(REVEAL_ALPHA)
        toggleBtn.Text = "OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
    else
        setTransparency(HIDDEN_ALPHA)
        toggleBtn.Text = "ON"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 120, 40)
    end
end)

-- Close
closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Minimize
minBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        for _, child in ipairs(mainFrame:GetChildren()) do
            if child:IsA("TextButton") and child ~= minBtn and child ~= closeBtn then
                child.Visible = false
            end
            if child:IsA("TextLabel") then
                child.Visible = false
            end
        end
        mainFrame.Size = UDim2.fromOffset(100, 30)
    else
        for _, child in ipairs(mainFrame:GetChildren()) do
            child.Visible = true
        end
        mainFrame.Size = UDim2.fromOffset(180, 100)
    end
end)
