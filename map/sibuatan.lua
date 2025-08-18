-- Gui Teleport & View (Delta Executor)
-- JUDUL: Gunung Sibuatan (Versi Simple Drag + Minimize)

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Header = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local CloseBtn = Instance.new("TextButton")
local MinBtn = Instance.new("TextButton")
local Content = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")

ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- MainFrame
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
MainFrame.BackgroundTransparency = 0.25
MainFrame.Position = UDim2.new(0,20,1,-300) -- pojok kiri bawah
MainFrame.Size = UDim2.new(0,420,0,300)
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0,8)

-- Header (sama warna dengan body, hitam transparan)
Header.Parent = MainFrame
Header.BackgroundColor3 = Color3.fromRGB(30,30,30)
Header.BackgroundTransparency = 0.25
Header.Size = UDim2.new(1,0,0,30)
Instance.new("UICorner", Header).CornerRadius = UDim.new(0,8)

Title.Parent = Header
Title.Text = "Gunung Sibuatan"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Position = UDim2.new(0,10,0,0)
Title.Size = UDim2.new(0.7,0,1,0)
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Tombol Close
CloseBtn.Parent = Header
CloseBtn.Size = UDim2.new(0,30,1,0)
CloseBtn.Position = UDim2.new(1,-30,0,0)
CloseBtn.Text = "X"
CloseBtn.BackgroundTransparency = 1
CloseBtn.TextColor3 = Color3.fromRGB(255,255,255)
CloseBtn.Font = Enum.Font.GothamBold

-- Tombol Minimize
MinBtn.Parent = Header
MinBtn.Size = UDim2.new(0,30,1,0)
MinBtn.Position = UDim2.new(1,-60,0,0)
MinBtn.Text = "-"
MinBtn.BackgroundTransparency = 1
MinBtn.TextColor3 = Color3.fromRGB(255,255,255)
MinBtn.Font = Enum.Font.GothamBold

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
    {name="Base", pos=Vector3.new(988.73,113.97,-693.31)},
    {name="CP1", pos=Vector3.new(-313.49,156.16,-326.08)},
    {name="CP2", pos=Vector3.new(-728.78,590.17,-124.20)},
    {name="CP3", pos=Vector3.new(-884.61,993.97,-206.13)},
    {name="CP4", pos=Vector3.new(-1636.73,994.17,282.63)},
    {name="CP5", pos=Vector3.new(-1647.80,996.25,633.38)},
    {name="CP6", pos=Vector3.new(-1637.69,1114.17,2151.40)},
    {name="CP7", pos=Vector3.new(-519.04,1450.17,3279.67)},
    {name="CP8", pos=Vector3.new(-707.65,1894.17,2382.58)},
    {name="CP9", pos=Vector3.new(-861.12,1941.97,2071.94)},
    {name="CP10", pos=Vector3.new(-868.03,2102.17,1667.52)},
    {name="CP11", pos=Vector3.new(-901.51,2342.17,1441.72)},
    {name="CP12", pos=Vector3.new(-846.89,2766.17,1505.55)},
    {name="CP13", pos=Vector3.new(-613.79,3286.17,1919.97)},
    {name="CP14", pos=Vector3.new(-237.50,3405.37,2578.94)},
    {name="CP15", pos=Vector3.new(309.96,3542.17,3041.96)},
    {name="CP16", pos=Vector3.new(439.63,3598.17,3562.56)},
    {name="CP17", pos=Vector3.new(913.02,3666.17,4151.22)},
    {name="CP18", pos=Vector3.new(1422.11,3906.17,4996.96)},
    {name="CP19", pos=Vector3.new(1668.22,4286.17,5193.27)},
    {name="CP20", pos=Vector3.new(1721.12,4469.97,5171.88)},
    {name="CP21", pos=Vector3.new(1862.86,4654.09,5201.69)},
    {name="CP22", pos=Vector3.new(1900.72,4962.17,5156.13)},
    {name="CP23", pos=Vector3.new(2847.50,5074.17,5241.92)},
    {name="CP24", pos=Vector3.new(3459.49,5242.17,5121.06)},
    {name="CP25", pos=Vector3.new(4578.36,5478.17,5267.37)},
    {name="CP26", pos=Vector3.new(4635.98,4950.05,5235.59)},
    {name="CP27", pos=Vector3.new(4626.76,4565.76,5243.68)},
    {name="CP ( Water )", pos=Vector3.new(4880.66,3985.86,5184.27)},
    {name="CP28", pos=Vector3.new(5830.06,3997.85,5741.35)},
    {name="CP29", pos=Vector3.new(6632.73,4223.57,5577.83)},
    {name="CP30", pos=Vector3.new(7474.53,4223.10,5305.50)},
    {name="CP31", pos=Vector3.new(8210.79,4330.17,4893.81)},
    {name="CP32", pos=Vector3.new(8696.03,4482.11,4545.91)},
    {name="CP33", pos=Vector3.new(8786.96,4538.16,4347.60)},
    {name="CP34", pos=Vector3.new(9198.62,5074.17,2466.44)},
    {name="CP35", pos=Vector3.new(9188.99,5321.94,2460.10)},
    {name="CP36", pos=Vector3.new(9079.95,5893.41,2041.92)},
    {name="CP37", pos=Vector3.new(9188.45,6217.98,1988.47)},
    {name="CP38", pos=Vector3.new(9062.20,6498.57,1827.87)},
    {name="CP39", pos=Vector3.new(8697.10,6530.01,1292.58)},
    {name="CP40", pos=Vector3.new(8396.11,6557.98,1144.27)},
    {name="CP41", pos=Vector3.new(7993.31,6608.77,1015.79)},
    {name="CP42", pos=Vector3.new(7139.38,6774.17,375.86)},
    {name="CP43", pos=Vector3.new(6572.58,6967.02,255.21)},
    {name="CP44", pos=Vector3.new(6040.21,6966.17,251.92)},
    {name="CP45", pos=Vector3.new(4873.80,7146.17,680.08)},
    {name="CP46", pos=Vector3.new(5396.93,8109.97,2205.45)},
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
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVec = moveVec + cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVec = moveVec - cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVec = moveVec - cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVec = moveVec + cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.E) then moveVec = moveVec + Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.Q) then moveVec = moveVec - Vector3.new(0,1,0) end
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
    row.BackgroundTransparency = 1

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

-- Minimize
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        Content.Visible = false
        MainFrame.Size = UDim2.new(0,420,0,30)
    else
        Content.Visible = true
        MainFrame.Size = UDim2.new(0,420,0,300)
    end
end)

-- Dragging (PC & Mobile)
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
