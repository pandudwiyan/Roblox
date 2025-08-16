-- // MAP GUNUNG DAUN - Teleport & Freecam UI
-- Works on PC & Mobile

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Lokasi daftar
local locations = {
    {name="Base", pos=Vector3.new(-6.45, 14.90, -9.29)},
    {name="CP1", pos=Vector3.new(-622.84, 251.27, -385.33)},
    {name="CP2", pos=Vector3.new(-1203.66, 262.67, -486.82)},
    {name="CP3", pos=Vector3.new(-1399.26, 579.38, -951.27)},
    {name="CP4", pos=Vector3.new(-1701.29, 817.61, -1399.51)},
    {name="Perjalanan1", pos=Vector3.new(-1839.11, 741.51, -1514.16)},
    {name="Perjalanan2", pos=Vector3.new(-2051.91, 890.03, -1760.50)},
    {name="Perjalanan3", pos=Vector3.new(-2369.95, 1066.89, -1866.87)},
    {name="Perjalanan4", pos=Vector3.new(-2428.45, 1116.07, -1918.83)},
    {name="Perjalanan5", pos=Vector3.new(-2513.91, 1189.73, -2020.43)},
    {name="Perjalanan6", pos=Vector3.new(-2649.97, 1232.48, -2024.11)},
    {name="Perjalanan7", pos=Vector3.new(-2858.23, 1169.84, -1985.23)},
    {name="Perjalanan8", pos=Vector3.new(-2924.96, 1432.88, -2202.91)},
    {name="Perjalanan9", pos=Vector3.new(-2909.64, 1467.26, -2345.08)},
    {name="Perjalanan10", pos=Vector3.new(-2937.58, 1566.51, -2417.31)},
    {name="Perjalanan11", pos=Vector3.new(-2994.88, 1694.17, -2472.82)},
    {name="Perjalanan12", pos=Vector3.new(-3106.35, 1706.61, -2568.18)},
    {name="Summit", pos=Vector3.new(-3150.49, 1747.27, -2597.62)},
}

-- UI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 350, 0, 400)
Frame.Position = UDim2.new(0.3, 0, 0.2, 0)
Frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
Frame.BackgroundTransparency = 0.2
Frame.Active = true
Frame.Draggable = true

-- Header
local Header = Instance.new("Frame", Frame)
Header.Size = UDim2.new(1,0,0,30)
Header.BackgroundColor3 = Color3.fromRGB(40,40,40)
local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1,-60,1,0)
Title.Text = "MAP GUNUNG DAUN"
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundTransparency = 1

local MinBtn = Instance.new("TextButton", Header)
MinBtn.Size = UDim2.new(0,30,1,0)
MinBtn.Position = UDim2.new(1,-60,0,0)
MinBtn.Text = "-"
MinBtn.BackgroundColor3 = Color3.fromRGB(70,70,70)
MinBtn.TextColor3 = Color3.new(1,1,1)

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0,30,1,0)
CloseBtn.Position = UDim2.new(1,-30,0,0)
CloseBtn.Text = "X"
CloseBtn.BackgroundColor3 = Color3.fromRGB(150,50,50)
CloseBtn.TextColor3 = Color3.new(1,1,1)

-- List container
local List = Instance.new("ScrollingFrame", Frame)
List.Size = UDim2.new(1,0,1,-30)
List.Position = UDim2.new(0,0,0,30)
List.CanvasSize = UDim2.new(0,0,0,#locations*35)
List.ScrollBarThickness = 6
local UIListLayout = Instance.new("UIListLayout", List)

-- Teleport & Freecam
local function teleportTo(v3)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char:MoveTo(v3)
    end
end

-- Freecam system
local freecam = false
local freecamPos = Vector3.new()
local freecamRot = Vector2.new()
local conn

local function enableFreecam(pos)
    freecam = true
    freecamPos = pos + Vector3.new(0,5,0)
    freecamRot = Vector2.new(0,0)
    Camera.CameraType = Enum.CameraType.Scriptable

    conn = RunService.RenderStepped:Connect(function(dt)
        local move = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.E) then move = move + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.Q) then move = move - Vector3.new(0,1,0) end
        freecamPos = freecamPos + move * (30*dt)

        -- rotasi klik kanan PC
        if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local delta = UserInputService:GetMouseDelta()
            freecamRot = freecamRot + Vector2.new(-delta.Y, -delta.X) * 0.003
        end

        local rotCFrame = CFrame.Angles(0, freecamRot.Y, 0) * CFrame.Angles(freecamRot.X,0,0)
        Camera.CFrame = CFrame.new(freecamPos) * rotCFrame
    end)
end

local function disableFreecam()
    freecam = false
    if conn then conn:Disconnect() end
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        Camera.CameraType = Enum.CameraType.Custom
        Camera.CameraSubject = char.Humanoid
    end
end

-- Generate list
for _,loc in ipairs(locations) do
    local Item = Instance.new("Frame", List)
    Item.Size = UDim2.new(1, -5, 0, 30)
    Item.BackgroundColor3 = Color3.fromRGB(50,50,50)
    Item.BackgroundTransparency = 0.2

    local Label = Instance.new("TextLabel", Item)
    Label.Size = UDim2.new(0.4,0,1,0)
    Label.Text = loc.name
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 14
    Label.TextColor3 = Color3.new(1,1,1)
    Label.BackgroundTransparency = 1

    local TpBtn = Instance.new("TextButton", Item)
    TpBtn.Size = UDim2.new(0.3,-5,1,0)
    TpBtn.Position = UDim2.new(0.4,0,0,0)
    TpBtn.Text = "🚀"
    TpBtn.TextSize = 18
    TpBtn.BackgroundColor3 = Color3.fromRGB(70,100,70)
    TpBtn.TextColor3 = Color3.new(1,1,1)
    TpBtn.MouseButton1Click:Connect(function()
        teleportTo(loc.pos)
    end)

    local SpBtn = Instance.new("TextButton", Item)
    SpBtn.Size = UDim2.new(0.3,-5,1,0)
    SpBtn.Position = UDim2.new(0.7,0,0,0)
    SpBtn.Text = "🙈"
    SpBtn.TextSize = 18
    SpBtn.BackgroundColor3 = Color3.fromRGB(70,70,120)
    SpBtn.TextColor3 = Color3.new(1,1,1)
    local watching = false
    SpBtn.MouseButton1Click:Connect(function()
        watching = not watching
        if watching then
            SpBtn.Text = "👀"
            enableFreecam(loc.pos)
        else
            SpBtn.Text = "🙈"
            disableFreecam()
        end
    end)
end

-- Minimize
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        List.Visible = false
        Frame.Size = UDim2.new(0,350,0,30)
    else
        List.Visible = true
        Frame.Size = UDim2.new(0,350,0,400)
    end
end)

-- Close
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)
