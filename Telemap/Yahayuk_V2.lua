-- Gui Teleport & View (Delta Executor)
-- JUDUL: Gunung Yahayuk (Revisi)

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
MainFrame.Position = UDim2.new(0,20,1,-420) -- pojok kiri bawah
MainFrame.Size = UDim2.new(0,300,0,400)

-- Rounded sudut panel
local corner = Instance.new("UICorner", MainFrame)
corner.CornerRadius = UDim.new(0,12)

-- Header
Header.Parent = MainFrame
Header.BackgroundColor3 = Color3.fromRGB(30,30,30)
Header.Size = UDim2.new(1,0,0,30)

local headerCorner = Instance.new("UICorner", Header)
headerCorner.CornerRadius = UDim.new(0,12)

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
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0,6)

-- Tombol Minimize
MinBtn.Parent = Header
MinBtn.Size = UDim2.new(0,30,1,0)
MinBtn.Position = UDim2.new(1,-60,0,0)
MinBtn.Text = "-"
MinBtn.BackgroundColor3 = Color3.fromRGB(100,100,0)
MinBtn.TextColor3 = Color3.fromRGB(255,255,255)
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0,6)

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
    {name="CP1", pos=Vector3.new(-470.77,250.17,775.94)},
    {name="CP2", pos=Vector3.new(-361.80,389.17,572.98)},
    {name="CP3", pos=Vector3.new(258.42,430.97,506.56)},
    {name="CP4", pos=Vector3.new(333.92,487.33,358.00)},
    {name="CP5", pos=Vector3.new(237.64,315.17,-144.60)},
    {name="Puncak", pos=Vector3.new(-582.54,906.17,-518.30)}
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
    Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0,6)

    local viewBtn = Instance.new("TextButton", frame)
    viewBtn.Size = UDim2.new(0,60,0.8,0)
    viewBtn.Position = UDim2.new(0.75,0,0.1,0)
    viewBtn.Text = "View"
    viewBtn.BackgroundColor3 = Color3.fromRGB(200,200,200)
    Instance.new("UICorner", viewBtn).CornerRadius = UDim.new(0,6)

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

-- ========== Fungsi Custom Drag ==========
local UserInputService = game:GetService("UserInputService")
local dragging, dragInput, dragStart, startPos

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                       startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
