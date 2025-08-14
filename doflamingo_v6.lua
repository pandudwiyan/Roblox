-- Player Teleporter v4.3 (Realtime Sort + Camera Follow)
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local camera = workspace.CurrentCamera

-- Hapus GUI lama
local parentGui = (gethui and gethui()) or game:FindFirstChildOfClass("CoreGui")
if parentGui:FindFirstChild("PlayerTeleporterV4_3") then
    parentGui.PlayerTeleporterV4_3:Destroy()
end

-- GUI utama
local gui = Instance.new("ScreenGui")
gui.Name = "PlayerTeleporterV4_3"
gui.ResetOnSpawn = false
gui.Parent = parentGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 280, 0, 160)
main.Position = UDim2.new(0.35, 0, 0.3, 0)
main.BackgroundColor3 = Color3.fromRGB(35,35,35)
main.BorderSizePixel = 2
main.BorderColor3 = Color3.fromRGB(255,0,0)
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0,8)

-- Header
local header = Instance.new("Frame")
header.Size = UDim2.new(1,0,0,30)
header.BackgroundColor3 = Color3.fromRGB(120,0,0)
header.Parent = main
Instance.new("UICorner", header).CornerRadius = UDim.new(0,8)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,-30,1,0)
title.Position = UDim2.new(0,5,0,0)
title.Text = "Player Teleporter v4.3"
title.TextXAlignment = Enum.TextXAlignment.Left
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 16
title.Parent = header

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0,30,1,0)
closeBtn.Position = UDim2.new(1,-30,0,0)
closeBtn.Text = "X"
closeBtn.BackgroundColor3 = Color3.fromRGB(170,0,0)
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Parent = header
closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

-- Drag header
do
    local dragging, dragStart, startPos
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
        end
    end)
    header.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,
                                      startPos.Y.Scale,startPos.Y.Offset+delta.Y)
        end
    end)
end

-- Tombol navigasi target
local prevBtn = Instance.new("TextButton")
prevBtn.Size = UDim2.new(0,40,0,30)
prevBtn.Position = UDim2.new(0,10,0,50)
prevBtn.BackgroundColor3 = Color3.fromRGB(80,0,0)
prevBtn.TextColor3 = Color3.new(1,1,1)
prevBtn.Text = "<"
prevBtn.Parent = main
Instance.new("UICorner", prevBtn).CornerRadius = UDim.new(0,6)

local nextBtn = Instance.new("TextButton")
nextBtn.Size = UDim2.new(0,40,0,30)
nextBtn.Position = UDim2.new(1,-50,0,50)
nextBtn.BackgroundColor3 = Color3.fromRGB(0,80,0)
nextBtn.TextColor3 = Color3.new(1,1,1)
nextBtn.Text = ">"
nextBtn.Parent = main
Instance.new("UICorner", nextBtn).CornerRadius = UDim.new(0,6)

-- Label target
local targetLabel = Instance.new("TextLabel")
targetLabel.Size = UDim2.new(1,-100,0,30)
targetLabel.Position = UDim2.new(0.5,-(targetLabel.Size.X.Offset/2),0,50)
targetLabel.BackgroundColor3 = Color3.fromRGB(50,50,50)
targetLabel.TextColor3 = Color3.new(1,1,0)
targetLabel.Font = Enum.Font.SourceSansBold
targetLabel.TextSize = 14
targetLabel.Text = "Tidak ada target"
targetLabel.Parent = main
Instance.new("UICorner", targetLabel).CornerRadius = UDim.new(0,6)

-- Tombol bawah
local tpBtn = Instance.new("TextButton")
tpBtn.Size = UDim2.new(0.3,-5,0,30)
tpBtn.Position = UDim2.new(0,10,0,100)
tpBtn.BackgroundColor3 = Color3.fromRGB(80,0,0)
tpBtn.TextColor3 = Color3.new(1,1,1)
tpBtn.Text = "Teleport"
tpBtn.Parent = main
Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0,6)

local quickBtn = Instance.new("TextButton")
quickBtn.Size = UDim2.new(0.3,-5,0,30)
quickBtn.Position = UDim2.new(0.35,0,0,100)
quickBtn.BackgroundColor3 = Color3.fromRGB(0,80,0)
quickBtn.TextColor3 = Color3.new(1,1,1)
quickBtn.Text = "Quick"
quickBtn.Parent = main
Instance.new("UICorner", quickBtn).CornerRadius = UDim.new(0,6)

local bringBtn = Instance.new("TextButton")
bringBtn.Size = UDim2.new(0.3,-5,0,30)
bringBtn.Position = UDim2.new(0.7,0,0,100)
bringBtn.BackgroundColor3 = Color3.fromRGB(0,0,80)
bringBtn.TextColor3 = Color3.new(1,1,1)
bringBtn.Text = "Bring"
bringBtn.Parent = main
Instance.new("UICorner", bringBtn).CornerRadius = UDim.new(0,6)

-- Variabel target
local currentTarget = nil
local frontList, backList = {}, {}

-- Fungsi teleport
local function teleportBehind(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if targetHRP and myHRP then
        local behind = targetHRP.CFrame * CFrame.new(0,0,9)
        myChar:PivotTo(behind)
    end
end

local function summonToFront(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if targetHRP and myHRP then
        local frontPos = myHRP.CFrame * CFrame.new(0, 0, -5)
        targetPlayer.Character:PivotTo(frontPos)
    end
end

-- Update list realtime
RS.Heartbeat:Connect(function()
    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end

    frontList, backList = {}, {}
    local forward = myHRP.CFrame.LookVector

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local dir = (hrp.Position - myHRP.Position).Unit
                local dot = forward:Dot(dir)
                local dist = (hrp.Position - myHRP.Position).Magnitude
                if dot > 0 then
                    table.insert(frontList, {plr, dist})
                else
                    table.insert(backList, {plr, dist})
                end
            end
        end
    end

    table.sort(frontList, function(a,b) return a[2] < b[2] end)
    table.sort(backList, function(a,b) return a[2] < b[2] end)
end)

-- Fungsi pilih target
local function setTarget(plr)
    currentTarget = plr
    if plr then
        targetLabel.Text = plr.DisplayName .. " | " .. plr.Name
        local humanoid = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            camera.CameraSubject = humanoid
        end
    else
        targetLabel.Text = "Tidak ada target"
    end
end

-- Navigasi tombol
local frontIndex, backIndex = 0, 0

nextBtn.MouseButton1Click:Connect(function()
    if #frontList > 0 then
        frontIndex = frontIndex + 1
        if frontIndex > #frontList then frontIndex = 1 end
        setTarget(frontList[frontIndex][1])
    end
end)

prevBtn.MouseButton1Click:Connect(function()
    if #backList > 0 then
        backIndex = backIndex + 1
        if backIndex > #backList then backIndex = 1 end
        setTarget(backList[backIndex][1])
    end
end)

-- Tombol aksi
tpBtn.MouseButton1Click:Connect(function()
    if currentTarget then teleportBehind(currentTarget) end
end)

quickBtn.MouseButton1Click:Connect(function()
    if #frontList > 0 then
        setTarget(frontList[1][1])
        teleportBehind(frontList[1][1])
    end
end)

bringBtn.MouseButton1Click:Connect(function()
    if currentTarget then summonToFront(currentTarget) end
end)

-- Balik kamera kalau lompat
LP.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid").Jumping:Connect(function(active)
        if active then
            local humanoid = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                camera.CameraSubject = humanoid
            end
        end
    end)
end)
