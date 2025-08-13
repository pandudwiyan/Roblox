--// GUI Carry Player (Client Side)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Cek apakah RemoteEvent sudah ada, kalau belum, buat sendiri (client side mockup)
local CarryEvent = ReplicatedStorage:FindFirstChild("CarryEvent") or Instance.new("RemoteEvent", ReplicatedStorage)
CarryEvent.Name = "CarryEvent"

-- Fungsi untuk membuat GUI
local function createGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CarryGUI"
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 100)
    frame.Position = UDim2.new(0, 20, 0, 200)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    frame.BackgroundTransparency = 0.3
    frame.Parent = screenGui

    local uiCorner = Instance.new("UICorner", frame)
    uiCorner.CornerRadius = UDim.new(0, 10)

    local carryBtn = Instance.new("TextButton")
    carryBtn.Size = UDim2.new(1, -20, 0, 40)
    carryBtn.Position = UDim2.new(0, 10, 0, 10)
    carryBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    carryBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    carryBtn.Font = Enum.Font.SourceSansBold
    carryBtn.TextSize = 18
    carryBtn.Text = "Carry Player"
    carryBtn.Parent = frame

    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -20, 0, 30)
    statusLabel.Position = UDim2.new(0, 10, 0, 55)
    statusLabel.BackgroundTransparency = 1
    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    statusLabel.Font = Enum.Font.SourceSansBold
    statusLabel.TextSize = 16
    statusLabel.Text = "Status: Idle"
    statusLabel.Parent = frame

    carryBtn.MouseButton1Click:Connect(function()
        CarryEvent:FireServer()
        if statusLabel.Text == "Status: Idle" then
            statusLabel.Text = "Status: Carrying"
            carryBtn.Text = "Drop Player"
            carryBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
        else
            statusLabel.Text = "Status: Idle"
            carryBtn.Text = "Carry Player"
            carryBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        end
    end)
end

createGUI()
