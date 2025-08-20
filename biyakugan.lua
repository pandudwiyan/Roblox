--// Client-side Transparency Toggle UI
--// Akan memindai semua BasePart di workspace
--// Toggle 100% transparan <-> 90% transparan
--// Bisa dipakai di HP, emulator, PC
--// UI draggable, awalnya di pojok kanan atas

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- Transparansi
local INVISIBLE = 1.0 -- 100%
local SHOWN     = 0.9 -- 90%

--================ UI ==================--
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TransparencyUI"
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player:WaitForChild("PlayerGui")

local button = Instance.new("TextButton")
button.Size = UDim2.fromOffset(90, 36)
button.AnchorPoint = Vector2.new(1, 0)
button.Position = UDim2.new(1, -10, 0, 10) -- pojok kanan atas
button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.TextScaled = true
button.Font = Enum.Font.GothamBold
button.Text = "ON"
button.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = button

--================ Drag =================--
do
    local dragging = false
    local dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        button.Position = UDim2.fromOffset(startPos.X.Offset + delta.X, startPos.Y.Offset + delta.Y)
        button.AnchorPoint = Vector2.new(0, 0)
    end

    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = UDim2.fromOffset(button.AbsolutePosition.X, button.AbsolutePosition.Y)
        end
    end)

    button.InputEnded:Connect(function(input)
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

--================ Logic =================--
local isShown = false

local function setTransparency(value)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.LocalTransparencyModifier = value
        end
    end
end

-- mulai 100% transparan
setTransparency(INVISIBLE)
button.Text = "ON"

button.MouseButton1Click:Connect(function()
    isShown = not isShown
    if isShown then
        setTransparency(SHOWN)
        button.Text = "OFF"
    else
        setTransparency(INVISIBLE)
        button.Text = "ON"
    end
end)
