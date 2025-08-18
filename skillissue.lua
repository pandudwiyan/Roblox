--// SafeZone Cling Script
-- by ChatGPT

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")

-- Variables
local enabled = false
local range = 100
local safeRadius = 10

-- UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "SafeClingUI"
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 180, 0, 60)
Frame.Position = UDim2.new(1, -200, 0, 50)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 25)
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Title.Text = "🌀 SafeCling"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.TextSize = 14
Title.Parent = Frame

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(1, -20, 0, 25)
ToggleBtn.Position = UDim2.new(0, 10, 0, 30)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
ToggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
ToggleBtn.Text = "SafeCling [OFF]"
ToggleBtn.Parent = Frame

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -25, 0, 0)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseBtn.Parent = Frame

-- Toggle Logic
local state = false
ToggleBtn.MouseButton1Click:Connect(function()
    state = not state
    enabled = state
    ToggleBtn.Text = "SafeCling ["..(state and "ON" or "OFF").."]"
    ToggleBtn.BackgroundColor3 = state and Color3.fromRGB(80,150,80) or Color3.fromRGB(60,60,60)
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Main Loop
RunService.Heartbeat:Connect(function()
    if not enabled then return end
    if not HRP or not HRP.Parent then return end

    -- Scan objek sekitar
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.CanCollide then
            local dist = (obj.Position - HRP.Position).Magnitude
            if dist < range then
                -- Kalau player masuk radius aman
                if dist <= (obj.Size.Magnitude/2 + safeRadius) then
                    -- Tarik ke tengah object
                    local midpoint = obj.Position
                    local direction = (midpoint - HRP.Position).Unit
                    HRP.Velocity = direction * 30 -- force tarik
                end
            end
        end
    end
end)
