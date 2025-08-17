-- Gui Teleport & View (Delta Executor)
-- JUDUL: Gunung Yahayuk (Versi Simple Table)

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Header = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local CloseBtn = Instance.new("TextButton")
local Content = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")

ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- MainFrame
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
MainFrame.BackgroundTransparency = 0.25
MainFrame.Position = UDim2.new(0.3,0,0.2,0) -- tengah layar
MainFrame.Size = UDim2.new(0,420,0,300)
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0,8)

-- Header
Header.Parent = MainFrame
Header.BackgroundColor3 = Color3.fromRGB(20,20,20)
Header.Size = UDim2.new(1,0,0,30)
Instance.new("UICorner", Header).CornerRadius = UDim.new(0,8)

Title.Parent = Header
Title.Text = "Gunung Yahayuk"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Position = UDim2.new(0,10,0,0)
Title.Size = UDim2.new(0.7,0,1,0)
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Tombol Close
CloseBtn.Parent = Header
CloseBtn.Size = UDim2.new(0,30,1,0)
CloseBtn.Position = UDim2.new(1,-30,0,0)
CloseBtn.Text = "X"
CloseBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
CloseBtn.TextColor3 = Color3.fromRGB(255,255,255)
CloseBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0,6)

-- Content (ScrollingFrame tabel)
Content.Parent = MainFrame
Content.Position = UDim2.new(0,0,0,30)
Content.Size = UDim2.new(1,0,1,-30)
Content.BackgroundTransparency = 1
Content.ScrollBarThickness = 6
Content.CanvasSize = UDim2.new(0,0,0,0)
Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
Content.ScrollBarImageColor3 = Color3.fromRGB(150,150,150)

UIListLayout.Parent = Content
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0,1)

-- Data Lokasi
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

local function teleportTo(position)
    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        LP.Character.HumanoidRootPart.CFrame = CFrame.new(position)
    end
end

-- View toggle
local isViewing = false
local viewConn = nil
local currentViewBtn = nil
local function toggleView(position, button)
    local cam = workspace.CurrentCamera
    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")
    local speed = 2

    if not isViewing then
        isViewing = true
        currentViewBtn = button
        button.TextColor3 = Color3.fromRGB(0,200,0)

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
        isViewing = false
        if viewConn then viewConn:Disconnect() end
        cam.CameraType = Enum.CameraType.Custom
        cam.CameraSubject = LP.Character:FindFirstChild("Humanoid")
        if currentViewBtn then
            currentViewBtn.TextColor3 = Color3.fromRGB(255,255,255)
            currentViewBtn = nil
        end
    end
end

-- Generate tabel row
for _,loc in ipairs(locations) do
    local row = Instance.new("Frame", Content)
    row.Size = UDim2.new(1,0,0,28)
    row.BackgroundColor3 = Color3.fromRGB(40,40,40)
    row.BackgroundTransparency = 0.2

    local line = Instance.new("Frame", row)
    line.Size = UDim2.new(1,0,0,1)
    line.Position = UDim2.new(0,0,1,-1)
    line.BackgroundColor3 = Color3.fromRGB(60,60,60)

    local label = Instance.new("TextLabel", row)
    label.Size = UDim2.new(0.4,0,1,0)
    label.Text = loc.name
    label.TextColor3 = Color3.fromRGB(255,255,255)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Position = UDim2.new(0,10,0,0)

    local tpBtn = Instance.new("TextButton", row)
    tpBtn.Size = UDim2.new(0,70,0.8,0)
    tpBtn.Position = UDim2.new(0.55,0,0.1,0)
    tpBtn.Text = "Teleport"
    tpBtn.Font = Enum.Font.Gotham
    tpBtn.TextSize = 13
    tpBtn.BackgroundTransparency = 1
    tpBtn.TextColor3 = Color3.fromRGB(100,180,255)

    local viewBtn = Instance.new("TextButton", row)
    viewBtn.Size = UDim2.new(0,60,0.8,0)
    viewBtn.Position = UDim2.new(0.8,0,0.1,0)
    viewBtn.Text = "View"
    viewBtn.Font = Enum.Font.Gotham
    viewBtn.TextSize = 13
    viewBtn.BackgroundTransparency = 1
    viewBtn.TextColor3 = Color3.fromRGB(200,200,200)

    tpBtn.MouseButton1Click:Connect(function()
        teleportTo(loc.pos)
    end)
    viewBtn.MouseButton1Click:Connect(function()
        toggleView(loc.pos, viewBtn)
    end)
end

-- Close
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)
