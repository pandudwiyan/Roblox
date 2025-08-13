-- Player Teleporter GUI
-- By ChatGPT

-- Hapus GUI lama
local parentGui = (gethui and gethui()) or game:FindFirstChildOfClass("CoreGui")
if parentGui:FindFirstChild("PlayerTeleporter") then parentGui.PlayerTeleporter:Destroy() end

local Players = game:GetService("Players")
local LP = Players.LocalPlayer

-- GUI utama
local gui = Instance.new("ScreenGui")
gui.Name = "PlayerTeleporter"
gui.ResetOnSpawn = false
gui.Parent = parentGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 280, 0, 360)
main.Position = UDim2.new(0.35, 0, 0.3, 0)
main.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
main.Parent = gui

-- Header
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 30)
header.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
header.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -60, 1, 0)
title.Position = UDim2.new(0, 5, 0, 0)
title.Text = "Player Teleporter"
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

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 30, 1, 0)
minBtn.Position = UDim2.new(1, -60, 0, 0)
minBtn.Text = "-"
minBtn.BackgroundColor3 = Color3.fromRGB(110, 0, 0)
minBtn.TextColor3 = Color3.new(1,1,1)
minBtn.Parent = header

-- Scroll area
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -12, 1, -42)
scroll.Position = UDim2.new(0, 6, 0, 36)
scroll.ScrollBarThickness = 6
scroll.BackgroundTransparency = 1
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.Parent = main

local layout = Instance.new("UIListLayout")
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 4)
layout.Parent = scroll

-- Tombol scan
local scanBtn = Instance.new("TextButton")
scanBtn.Size = UDim2.new(1, -12, 0, 40)
scanBtn.Position = UDim2.new(0, 6, 0, 36)
scanBtn.Text = "🔍 Scan Players"
scanBtn.TextColor3 = Color3.new(1,1,1)
scanBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
scanBtn.Parent = main

-- Fungsi drag
local UIS = game:GetService("UserInputService")
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

-- Tombol Close & Minimize
closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)
minBtn.MouseButton1Click:Connect(function() scroll.Visible = not scroll.Visible end)

-- Clear list
local function clearList()
    for _, c in ipairs(scroll:GetChildren()) do
        if c:IsA("GuiObject") then c:Destroy() end
    end
end

-- Teleport ke belakang player
local function teleportBehind(targetPlayer)
    local char = targetPlayer.Character
    local myChar = LP.Character
    if char and myChar then
        local targetHRP = char:FindFirstChild("HumanoidRootPart")
        local myHRP = myChar:FindFirstChild("HumanoidRootPart")
        if targetHRP and myHRP then
            -- ambil CFrame target, mundur 3 stud
            local behind = targetHRP.CFrame * CFrame.new(0, 0, 3)
            myChar:PivotTo(behind)
        end
    end
end

-- Scan players
local function scanPlayers()
    clearList()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 30)
            btn.Text = plr.Name
            btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
            btn.TextColor3 = Color3.new(1,1,1)
            btn.Parent = scroll
            btn.MouseButton1Click:Connect(function()
                teleportBehind(plr)
            end)
        end
    end
end

scanBtn.MouseButton1Click:Connect(function()
    scanPlayers()
    scanBtn.Visible = false
end)
