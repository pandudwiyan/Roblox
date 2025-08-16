--// Panel Teleport Gunung Daun dengan Freecam
-- Buat panel UI
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

-- Koordinat lokasi
local locations = {
    {name = "Base", pos = Vector3.new(-6.45, 14.90, -9.29)},
    {name = "cp1", pos = Vector3.new(-622.84, 251.27, -385.33)},
    {name = "cp2", pos = Vector3.new(-1203.66, 262.67, -486.82)},
    {name = "cp3", pos = Vector3.new(-1399.26, 579.38, -951.27)},
    {name = "cp4", pos = Vector3.new(-1701.29, 817.61, -1399.51)},
    {name = "Summit", pos = Vector3.new(-3150.49, 1747.27, -2597.62)}
}

-- UI Library
local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
ScreenGui.Name = "GunungDaunUI"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 320, 0, 300)
Frame.Position = UDim2.new(0.3, 0, 0.2, 0)
Frame.BackgroundColor3 = Color3.fromRGB(0,0,0)
Frame.BackgroundTransparency = 0.3
Frame.Active = true
Frame.Draggable = true

local UICorner = Instance.new("UICorner", Frame)
UICorner.CornerRadius = UDim.new(0,10)

local TitleBar = Instance.new("Frame", Frame)
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(20,20,20)
TitleBar.BackgroundTransparency = 0.2
local TitleText = Instance.new("TextLabel", TitleBar)
TitleText.Size = UDim2.new(1, -60, 1, 0)
TitleText.Position = UDim2.new(0, 10, 0, 0)
TitleText.Text = "MAP GUNUNG DAUN"
TitleText.TextColor3 = Color3.fromRGB(255,255,255)
TitleText.Font = Enum.Font.SourceSansBold
TitleText.TextSize = 16
TitleText.BackgroundTransparency = 1

-- Tombol minimize dan close
local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255,100,100)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 16

local MinBtn = Instance.new("TextButton", TitleBar)
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -60, 0, 0)
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(255,255,255)
MinBtn.BackgroundTransparency = 1
MinBtn.Font = Enum.Font.SourceSansBold
MinBtn.TextSize = 16

local Content = Instance.new("Frame", Frame)
Content.Size = UDim2.new(1, -10, 1, -40)
Content.Position = UDim2.new(0, 5, 0, 35)
Content.BackgroundTransparency = 1

local UIListLayout = Instance.new("UIListLayout", Content)
UIListLayout.Padding = UDim.new(0,5)

-- Close & Minimize logic
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    Content.Visible = not minimized
end)

-- Fungsi balik kamera ke player
local freecamConn
local camRot = Vector2.new()
local camSpeed = 2
local function returnCamera()
    if freecamConn then
        freecamConn:Disconnect()
        freecamConn = nil
    end
    local plr = LocalPlayer
    local cam = workspace.CurrentCamera
    if plr.Character and plr.Character:FindFirstChild("Humanoid") then
        cam.CameraSubject = plr.Character.Humanoid
        cam.CameraType = Enum.CameraType.Custom
    end
end

-- Fungsi freecam
local function setSpectate(v3)
    local cam = workspace.CurrentCamera
    cam.CameraType = Enum.CameraType.Scriptable
    cam.CFrame = CFrame.new(v3 + Vector3.new(0,5,0), v3)

    local pos = cam.CFrame.Position
    freecamConn = RS.RenderStepped:Connect(function(dt)
        local cf = cam.CFrame
        local look = cf.LookVector
        local right = cf.RightVector

        -- WASD QE
        if UIS:IsKeyDown(Enum.KeyCode.W) then pos += look * camSpeed end
        if UIS:IsKeyDown(Enum.KeyCode.S) then pos -= look * camSpeed end
        if UIS:IsKeyDown(Enum.KeyCode.A) then pos -= right * camSpeed end
        if UIS:IsKeyDown(Enum.KeyCode.D) then pos += right * camSpeed end
        if UIS:IsKeyDown(Enum.KeyCode.E) then pos += Vector3.new(0,camSpeed,0) end
        if UIS:IsKeyDown(Enum.KeyCode.Q) then pos -= Vector3.new(0,camSpeed,0) end

        -- Mouse drag untuk rotasi
        if UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local delta = UIS:GetMouseDelta()
            camRot = camRot + Vector2.new(-delta.Y, -delta.X) * 0.2
        end

        local rotCFrame = CFrame.Angles(0, math.rad(camRot.Y), 0) * CFrame.Angles(math.rad(camRot.X), 0, 0)
        cam.CFrame = CFrame.new(pos) * rotCFrame
    end)
end

-- Bikin list lokasi
for _, loc in ipairs(locations) do
    local ItemFrame = Instance.new("Frame", Content)
    ItemFrame.Size = UDim2.new(1, 0, 0, 35)
    ItemFrame.BackgroundColor3 = Color3.fromRGB(40,40,40)
    ItemFrame.BackgroundTransparency = 0.2
    local corner = Instance.new("UICorner", ItemFrame)
    corner.CornerRadius = UDim.new(0,6)

    local NameLabel = Instance.new("TextLabel", ItemFrame)
    NameLabel.Size = UDim2.new(0.4, 0, 1, 0)
    NameLabel.Position = UDim2.new(0, 5, 0, 0)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text = loc.name
    NameLabel.TextColor3 = Color3.fromRGB(255,255,255)
    NameLabel.Font = Enum.Font.SourceSansBold
    NameLabel.TextSize = 16
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left

    local TpBtn = Instance.new("TextButton", ItemFrame)
    TpBtn.Size = UDim2.new(0.25, -5, 0.8, 0)
    TpBtn.Position = UDim2.new(0.45, 0, 0.1, 0)
    TpBtn.BackgroundColor3 = Color3.fromRGB(100,150,100)
    TpBtn.Text = "Teleport"
    TpBtn.TextColor3 = Color3.fromRGB(255,255,255)
    TpBtn.Font = Enum.Font.SourceSansBold
    TpBtn.TextSize = 14
    local TpCorner = Instance.new("UICorner", TpBtn)
    TpCorner.CornerRadius = UDim.new(0,6)

    TpBtn.MouseButton1Click:Connect(function()
        local plr = LocalPlayer
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            plr.Character:MoveTo(loc.pos)
        end
    end)

    -- tombol 👀🙈 toggle
    local SpBtn = Instance.new("TextButton", ItemFrame)
    SpBtn.Size = UDim2.new(0.25, -5, 0.8, 0)
    SpBtn.Position = UDim2.new(0.72, 0, 0.1, 0)
    SpBtn.BackgroundColor3 = Color3.fromRGB(70,100,150)
    SpBtn.Text = "🙈"
    SpBtn.TextColor3 = Color3.fromRGB(255,255,255)
    SpBtn.Font = Enum.Font.SourceSansBold
    SpBtn.TextSize = 18
    local SpCorner = Instance.new("UICorner", SpBtn)
    SpCorner.CornerRadius = UDim.new(0,6)

    local spectating = false
    SpBtn.MouseButton1Click:Connect(function()
        spectating = not spectating
        if spectating then
            SpBtn.Text = "👀"
            setSpectate(loc.pos)
        else
            SpBtn.Text = "🙈"
            returnCamera()
        end
    end)
end
