-- Player Teleporter v2
-- By ChatGPT

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Hapus GUI lama
local parentGui = (gethui and gethui()) or game:FindFirstChildOfClass("CoreGui")
if parentGui:FindFirstChild("PlayerTeleporterV2") then parentGui.PlayerTeleporterV2:Destroy() end

-- GUI utama
local gui = Instance.new("ScreenGui")
gui.Name = "PlayerTeleporterV2"
gui.ResetOnSpawn = false
gui.Parent = parentGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 300, 0, 150)
main.Position = UDim2.new(0.35, 0, 0.3, 0)
main.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
main.BackgroundTransparency = 0.15
main.BorderSizePixel = 2
main.BorderColor3 = Color3.fromRGB(255, 0, 0)
main.Parent = gui

-- Header
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 30)
header.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
header.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -60, 1, 0)
title.Position = UDim2.new(0, 5, 0, 0)
title.Text = "Player Teleporter v2"
title.TextXAlignment = Enum.TextXAlignment.Left
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 16
title.Parent = header

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 1, 0)
closeBtn.Position = UDim2.new(1, -30, 0, 0)
closeBtn.Text = "X"
closeBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Parent = header
closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

-- Fungsi drag
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
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                      startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Mode dropdown
local modeSelect = Instance.new("TextButton")
modeSelect.Size = UDim2.new(1, -20, 0, 30)
modeSelect.Position = UDim2.new(0, 10, 0, 40)
modeSelect.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
modeSelect.TextColor3 = Color3.new(1,1,1)
modeSelect.Text = "Mode: Teleport Terdekat"
modeSelect.Parent = main

local mode = "nearest" -- default

modeSelect.MouseButton1Click:Connect(function()
    if mode == "nearest" then
        mode = "select"
        modeSelect.Text = "Mode: Teleport To"
        playerSelect.Active = true
        playerSelect.AutoButtonColor = true
        playerSelect.TextColor3 = Color3.new(1,1,1)
    else
        mode = "nearest"
        modeSelect.Text = "Mode: Teleport Terdekat"
        playerSelect.Active = false
        playerSelect.AutoButtonColor = false
        playerSelect.TextColor3 = Color3.fromRGB(150,150,150)
    end
end)

-- Player dropdown
local playerSelect = Instance.new("TextButton")
playerSelect.Size = UDim2.new(1, -20, 0, 30)
playerSelect.Position = UDim2.new(0, 10, 0, 80)
playerSelect.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
playerSelect.TextColor3 = Color3.fromRGB(150,150,150)
playerSelect.Text = "Pilih Player"
playerSelect.Active = false
playerSelect.AutoButtonColor = false
playerSelect.Parent = main

-- List player
local currentTarget = nil
local function refreshPlayerList()
    if mode == "select" then
        local playersList = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP then
                table.insert(playersList, plr)
            end
        end
        if #playersList > 0 then
            local plr = playersList[1]
            currentTarget = plr
            playerSelect.Text = plr.DisplayName.." | "..plr.Name
        else
            playerSelect.Text = "Tidak ada player"
            currentTarget = nil
        end
    end
end

-- Teleport function
local function teleportBehind(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if targetHRP and myHRP then
        local behind = targetHRP.CFrame * CFrame.new(0, 0, 9) -- jarak 9 stud
        myChar:PivotTo(behind)
    end
end

-- Cari player terdekat di depan
local function getNearestInFront()
    local myChar = LP.Character
    if not myChar then return nil end
    local myHRP = myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil end

    local nearest, minDist = nil, math.huge
    local forward = myHRP.CFrame.LookVector
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local dir = (hrp.Position - myHRP.Position).Unit
                local dot = forward:Dot(dir)
                if dot > 0 then -- hanya yang di depan
                    local dist = (hrp.Position - myHRP.Position).Magnitude
                    if dist < minDist then
                        minDist = dist
                        nearest = plr
                    end
                end
            end
        end
    end
    return nearest
end

-- Tombol teleport
local tpBtn = Instance.new("TextButton")
tpBtn.Size = UDim2.new(1, -20, 0, 30)
tpBtn.Position = UDim2.new(0, 10, 0, 120)
tpBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
tpBtn.TextColor3 = Color3.new(1,1,1)
tpBtn.Text = "Teleport"
tpBtn.Parent = main

tpBtn.MouseButton1Click:Connect(function()
    if mode == "nearest" then
        local nearest = getNearestInFront()
        if nearest then
            teleportBehind(nearest)
        end
    elseif mode == "select" then
        if currentTarget then
            teleportBehind(currentTarget)
        end
    end
end)

-- Auto-refresh player list
RunService.Heartbeat:Connect(function()
    refreshPlayerList()
end)
