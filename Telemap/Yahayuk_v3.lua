-- Gui Teleport & View - Gunung Yahayuk (Rapih Version)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")

-- === DATA KOORDINAT ===
local coords = {
    {name = "Base", pos = Vector3.new(-941.34, 170.97, 873.10)},
    {name = "CP1", pos = Vector3.new(-470.77, 250.17, 775.94)},
    {name = "CP2", pos = Vector3.new(-361.80, 389.17, 572.98)},
    {name = "CP3", pos = Vector3.new(258.42, 430.97, 506.56)},
    {name = "CP4", pos = Vector3.new(333.92, 487.33, 358.00)},
    {name = "CP5", pos = Vector3.new(237.64, 315.17, -144.60)},
    {name = "Puncak", pos = Vector3.new(-582.54, 906.17, -518.30)},
}

-- === GUI UTAMA ===
local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
ScreenGui.Name = "TeleportGui"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 280, 0, 380)
MainFrame.Position = UDim2.new(0, 20, 1, -400) -- pojok kiri bawah
MainFrame.BackgroundColor3 = Color3.fromRGB(20,20,20)
MainFrame.BackgroundTransparency = 0.3
MainFrame.Active = true
MainFrame.Draggable = true

local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0,10)

-- === HEADER ===
local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1,0,0,35)
Header.BackgroundColor3 = Color3.fromRGB(45,45,45)
Header.BorderSizePixel = 0
local HeaderCorner = Instance.new("UICorner", Header)
HeaderCorner.CornerRadius = UDim.new(0,10)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1,-70,1,0)
Title.Position = UDim2.new(0,10,0,0)
Title.Text = "Gunung Yahayuk"
Title.Font = Enum.Font.SourceSansBold
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.TextScaled = true
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Tombol Minimize
local MinBtn = Instance.new("TextButton", Header)
MinBtn.Size = UDim2.new(0,25,0,25)
MinBtn.Position = UDim2.new(1,-60,0.5,-12)
MinBtn.Text = "-"
MinBtn.Font = Enum.Font.SourceSansBold
MinBtn.TextScaled = true
MinBtn.BackgroundColor3 = Color3.fromRGB(255,200,0)
MinBtn.TextColor3 = Color3.fromRGB(0,0,0)
local MinCorner = Instance.new("UICorner", MinBtn)
MinCorner.CornerRadius = UDim.new(0,6)

-- Tombol Close
local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0,25,0,25)
CloseBtn.Position = UDim2.new(1,-30,0.5,-12)
CloseBtn.Text = "X"
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextScaled = true
CloseBtn.BackgroundColor3 = Color3.fromRGB(200,50,50)
CloseBtn.TextColor3 = Color3.fromRGB(255,255,255)
local CloseCorner = Instance.new("UICorner", CloseBtn)
CloseCorner.CornerRadius = UDim.new(0,6)

-- === CONTENT HOLDER ===
local Content = Instance.new("Frame", MainFrame)
Content.Size = UDim2.new(1,-10,1,-45)
Content.Position = UDim2.new(0,5,0,40)
Content.BackgroundTransparency = 1

local UIList = Instance.new("UIListLayout", Content)
UIList.Padding = UDim.new(0,6)

-- === BUAT LIST BUTTON TELEPORT & VIEW ===
for _,data in ipairs(coords) do
    local Row = Instance.new("Frame", Content)
    Row.Size = UDim2.new(1,0,0,35)
    Row.BackgroundColor3 = Color3.fromRGB(35,35,35)
    Row.BackgroundTransparency = 0.2
    local RowCorner = Instance.new("UICorner", Row)
    RowCorner.CornerRadius = UDim.new(0,6)

    local Label = Instance.new("TextLabel", Row)
    Label.Size = UDim2.new(0.4,0,1,0)
    Label.Position = UDim2.new(0,10,0,0)
    Label.BackgroundTransparency = 1
    Label.Text = data.name
    Label.Font = Enum.Font.SourceSansBold
    Label.TextScaled = true
    Label.TextColor3 = Color3.fromRGB(255,255,255)
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local TeleBtn = Instance.new("TextButton", Row)
    TeleBtn.Size = UDim2.new(0,70,0,25)
    TeleBtn.Position = UDim2.new(0.55,0,0.5,-12)
    TeleBtn.Text = "Teleport"
    TeleBtn.Font = Enum.Font.SourceSans
    TeleBtn.TextScaled = true
    TeleBtn.BackgroundColor3 = Color3.fromRGB(70,130,180)
    TeleBtn.TextColor3 = Color3.fromRGB(255,255,255)
    local TeleCorner = Instance.new("UICorner", TeleBtn)
    TeleCorner.CornerRadius = UDim.new(0,6)

    local ViewBtn = Instance.new("TextButton", Row)
    ViewBtn.Size = UDim2.new(0,60,0,25)
    ViewBtn.Position = UDim2.new(1,-70,0.5,-12)
    ViewBtn.Text = "View"
    ViewBtn.Font = Enum.Font.SourceSans
    ViewBtn.TextScaled = true
    ViewBtn.BackgroundColor3 = Color3.fromRGB(100,100,100)
    ViewBtn.TextColor3 = Color3.fromRGB(255,255,255)
    local ViewCorner = Instance.new("UICorner", ViewBtn)
    ViewCorner.CornerRadius = UDim.new(0,6)

    -- === FUNCTION TELEPORT ===
    TeleBtn.MouseButton1Click:Connect(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character:MoveTo(data.pos)
        end
    end)

    -- === FUNCTION VIEW (TOGGLE) ===
    local viewing = false
    ViewBtn.MouseButton1Click:Connect(function()
        viewing = not viewing
        if viewing then
            camera.CameraType = Enum.CameraType.Scriptable
            camera.CFrame = CFrame.new(data.pos + Vector3.new(0,10,0), data.pos)
        else
            camera.CameraType = Enum.CameraType.Custom
            camera.CameraSubject = LocalPlayer.Character:FindFirstChild("Humanoid")
        end
    end)
end

-- === CLOSE & MINIMIZE FUNCTION ===
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    Content.Visible = not minimized
    MainFrame.Size = minimized and UDim2.new(0,280,0,40) or UDim2.new(0,280,0,380)
end)
