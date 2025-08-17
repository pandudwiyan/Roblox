-- Gui Teleport & View (Delta Executor)
-- JUDUL: Gunung Yahayuk

-- ========== Buat GUI ==========
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Header = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local CloseBtn = Instance.new("TextButton")
local MinBtn = Instance.new("TextButton")
local Content = Instance.new("Frame")
local UIListLayout = Instance.new("UIListLayout")

ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- MainFrame
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
MainFrame.BackgroundTransparency = 0.3
MainFrame.Position = UDim2.new(0.3,0,0.2,0)
MainFrame.Size = UDim2.new(0,300,0,400)
MainFrame.Active = true
MainFrame.Draggable = true

-- Header
Header.Parent = MainFrame
Header.BackgroundColor3 = Color3.fromRGB(30,30,30)
Header.Size = UDim2.new(1,0,0,30)

Title.Parent = Header
Title.Text = "Gunung Yahayuk"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16
Title.Position = UDim2.new(0,5,0,0)
Title.Size = UDim2.new(0.7,0,1,0)
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Tombol Close
CloseBtn.Parent = Header
CloseBtn.Size = UDim2.new(0,30,1,0)
CloseBtn.Position = UDim2.new(1,-30,0,0)
CloseBtn.Text = "X"
CloseBtn.BackgroundColor3 = Color3.fromRGB(100,0,0)
CloseBtn.TextColor3 = Color3.fromRGB(255,255,255)

-- Tombol Minimize
MinBtn.Parent = Header
MinBtn.Size = UDim2.new(0,30,1,0)
MinBtn.Position = UDim2.new(1,-60,0,0)
MinBtn.Text = "-"
MinBtn.BackgroundColor3 = Color3.fromRGB(100,100,0)
MinBtn.TextColor3 = Color3.fromRGB(255,255,255)

-- Content
Content.Parent = MainFrame
Content.Position = UDim2.new(0,0,0,30)
Content.Size = UDim2.new(1,0,1,-30)
Content.BackgroundTransparency = 1

UIListLayout.Parent = Content
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- ========== Data Lokasi ==========
local locations = {
    {name="Base", pos=Vector3.new(-941.34,170.97,873.10)},
    {name="CP1", pos=Vector3.new(-470.67,250.17,764.74)},
    {name="CP2", pos=Vector3.new(-361.80,389.17,572.98)},
    {name="CP3", pos=Vector3.new(258.42,430.97,506.56)},
    {name="CP4", pos=Vector3.new(333.92,487.33,358.00)},
    {name="CP5", pos=Vector3.new(237.64,315.17,-144.60)},
    {name="Ujung Rintangan C5", pos=Vector3.new(-474.32,678.17,-377.65)},
    {name="Puncak", pos=Vector3.new(-609.87,906.17,-504.59)}
}

local Players = game:GetService("Players")
local LP = Players.LocalPlayer

-- ========== Fungsi Teleport ==========
local function teleportTo(position)
    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        LP.Character.HumanoidRootPart.CFrame = CFrame.new(position)
    end
end

-- ========== Fungsi View (Toggle) ==========
local isViewing = false
local viewConn = nil
local currentViewBtn = nil -- simpan tombol yang aktif

local function toggleView(position, button)
    local cam = workspace.CurrentCamera
    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")
    local speed = 2

    if not isViewing then
        -- Masuk mode View
        isViewing = true
        currentViewBtn = button
        button.BackgroundColor3 = Color3.fromRGB(0,150,0) -- hijau saat aktif
        button.TextColor3 = Color3.fromRGB(255,255,255)

        cam.CameraType = Enum.CameraType.Scriptable
        cam.CFrame = CFrame.new(position + Vector3.new(0,5,0)) * CFrame.Angles(0,math.rad(180),0)

        viewConn = RunService.RenderStepped:Connect(function()
            local moveVec = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveVec = moveVec + cam.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveVec = moveVec - cam.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveVec = moveVec - cam.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveVec = moveVec + cam.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.E) then
                moveVec = moveVec + Vector3.new(0,1,0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Q) then
                moveVec = moveVec - Vector3.new(0,1,0)
            end
            cam.CFrame = cam.CFrame + moveVec * speed
        end)

    else
        -- Keluar mode View
        isViewing = false
        if viewConn then
            viewConn:Disconnect()
            viewConn = nil
        end
        cam.CameraType = Enum.CameraType.Custom
        cam.CameraSubject = LP.Character:FindFirstChild("Humanoid")

        -- reset tombol warna
        if currentViewBtn then
            currentViewBtn.BackgroundColor3 = Color3.fromRGB(200,200,200)
            currentViewBtn.TextColor3 = Color3.fromRGB(0,0,0)
            currentViewBtn = nil
        end
    end
end

-- ========== Generate Button per Lokasi ==========
for _,loc in ipairs(locations) do
    local frame = Instance.new("Frame", Content)
    frame.Size = UDim2.new(1,0,0,30)
    frame.BackgroundTransparency = 1

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.4,0,1,0)
    label.Text = loc.name
    label.TextColor3 = Color3.fromRGB(255,255,255)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left

    local tpBtn = Instance.new("TextButton", frame)
    tpBtn.Size = UDim2.new(0,60,0.8,0)
    tpBtn.Position = UDim2.new(0.5,0,0.1,0)
    tpBtn.Text = "Teleport"
    tpBtn.BackgroundColor3 = Color3.fromRGB(200,200,200)

    local viewBtn = Instance.new("TextButton", frame)
    viewBtn.Size = UDim2.new(0,60,0.8,0)
    viewBtn.Position = UDim2.new(0.75,0,0.1,0)
    viewBtn.Text = "View"
    viewBtn.BackgroundColor3 = Color3.fromRGB(200,200,200)

    tpBtn.MouseButton1Click:Connect(function()
        teleportTo(loc.pos)
    end)
    viewBtn.MouseButton1Click:Connect(function()
        toggleView(loc.pos, viewBtn)
    end)
end

-- ========== Fitur Close & Minimize ==========
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        Content.Visible = false
        MainFrame.Size = UDim2.new(0,300,0,30)
    else
        Content.Visible = true
        MainFrame.Size = UDim2.new(0,300,0,400)
    end
end)
