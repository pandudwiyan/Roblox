-- Player Teleporter v4 + Search Feature (Optimized Refresh)
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local UIS = game:GetService("UserInputService")

-- Hapus GUI lama
local parentGui = (gethui and gethui()) or game:FindFirstChildOfClass("CoreGui")
if parentGui:FindFirstChild("PlayerTeleporterV4") then parentGui.PlayerTeleporterV4:Destroy() end

-- GUI utama
local gui = Instance.new("ScreenGui")
gui.Name = "PlayerTeleporterV4"
gui.ResetOnSpawn = false
gui.Parent = parentGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 300, 0, 230)
main.Position = UDim2.new(0.35, 0, 0.3, 0)
main.BackgroundColor3 = Color3.fromRGB(35,35,35)
main.BackgroundTransparency = 0.15
main.BorderSizePixel = 2
main.BorderColor3 = Color3.fromRGB(255,0,0)
main.Parent = gui
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0,8)
corner.Parent = main

-- Header
local header = Instance.new("Frame")
header.Size = UDim2.new(1,0,0,30)
header.BackgroundColor3 = Color3.fromRGB(120,0,0)
header.Parent = main
local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0,8)
headerCorner.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,-30,1,0)
title.Position = UDim2.new(0,5,0,0)
title.Text = "Player Teleporter v4"
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

-- Drag
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

-- Dropdown Button
local dropdownBtn = Instance.new("TextButton")
dropdownBtn.Size = UDim2.new(1,-20,0,30)
dropdownBtn.Position = UDim2.new(0,10,0,40)
dropdownBtn.BackgroundColor3 = Color3.fromRGB(60,0,0)
dropdownBtn.TextColor3 = Color3.new(1,1,1)
dropdownBtn.Text = "Pilih Player"
dropdownBtn.Parent = main
local dropCorner = Instance.new("UICorner")
dropCorner.CornerRadius = UDim.new(0,6)
dropCorner.Parent = dropdownBtn

-- Search Box
local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(1,-20,0,25)
searchBox.Position = UDim2.new(0,10,0,70)
searchBox.PlaceholderText = "Cari player..."
searchBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
searchBox.TextColor3 = Color3.new(1,1,1)
searchBox.ClearTextOnFocus = false
searchBox.Visible = false
searchBox.Parent = main
local searchCorner = Instance.new("UICorner")
searchCorner.CornerRadius = UDim.new(0,6)
searchCorner.Parent = searchBox

-- Dropdown Frame
local dropdownFrame = Instance.new("Frame")
dropdownFrame.Size = UDim2.new(1,-20,0,125)
dropdownFrame.Position = UDim2.new(0,10,0,100)
dropdownFrame.BackgroundColor3 = Color3.fromRGB(50,50,50)
dropdownFrame.Visible = false
dropdownFrame.Parent = main
local dropFrameCorner = Instance.new("UICorner")
dropFrameCorner.CornerRadius = UDim.new(0,6)
dropFrameCorner.Parent = dropdownFrame

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1,0,1,0)
scroll.CanvasSize = UDim2.new(0,0,0,0)
scroll.ScrollBarThickness = 6
scroll.BackgroundTransparency = 1
scroll.Parent = dropdownFrame

local layout = Instance.new("UIListLayout")
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0,2)
layout.Parent = scroll

-- Selected target
local currentTarget = nil

-- Refresh player list
local function refreshPlayerList(filter)
    for _, c in ipairs(scroll:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            local match = (not filter or filter == "") or
                (string.find(plr.DisplayName:lower(), filter:lower(), 1, true)) or
                (string.find(plr.Name:lower(), filter:lower(), 1, true))
            if match then
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1,-4,0,30)
                btn.BackgroundColor3 = Color3.fromRGB(70,70,70)
                btn.Text = ""
                btn.TextColor3 = Color3.new(1,1,1)
                btn.Parent = scroll
                local btnCorner = Instance.new("UICorner")
                btnCorner.CornerRadius = UDim.new(0,6)
                btnCorner.Parent = btn

                local dn = Instance.new("TextLabel")
                dn.Size = UDim2.new(0.5,0,1,0)
                dn.BackgroundTransparency = 1
                dn.Text = plr.DisplayName
                dn.TextColor3 = Color3.fromRGB(255,255,0)
                dn.Font = Enum.Font.SourceSans
                dn.TextSize = 14
                dn.TextXAlignment = Enum.TextXAlignment.Left
                dn.Parent = btn

                local un = Instance.new("TextLabel")
                un.Size = UDim2.new(0.5,0,1,0)
                un.Position = UDim2.new(0.5,0,0,0)
                un.BackgroundTransparency = 1
                un.Text = plr.Name
                un.TextColor3 = Color3.new(1,1,1)
                un.Font = Enum.Font.SourceSans
                un.TextSize = 14
                un.TextXAlignment = Enum.TextXAlignment.Left
                un.Parent = btn

                btn.MouseButton1Click:Connect(function()
                    currentTarget = plr
                    dropdownBtn.Text = plr.DisplayName.." | "..plr.Name
                    dropdownFrame.Visible = false
                    searchBox.Visible = false
                end)
            end
        end
    end
    scroll.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y)
end

-- Toggle dropdown + refresh
dropdownBtn.MouseButton1Click:Connect(function()
    local state = not dropdownFrame.Visible
    dropdownFrame.Visible = state
    searchBox.Visible = state
    if state then
        searchBox.Text = ""
        refreshPlayerList("")
    end
end)

-- Saat mengetik di search box
searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    refreshPlayerList(searchBox.Text)
end)

-- Update list saat player join/leave
Players.PlayerAdded:Connect(function()
    if dropdownFrame.Visible then
        refreshPlayerList(searchBox.Text)
    end
end)
Players.PlayerRemoving:Connect(function()
    if dropdownFrame.Visible then
        refreshPlayerList(searchBox.Text)
    end
end)

-- Teleport behind
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

-- Get nearest in front
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
                if dot > 0 then
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

-- Buttons
local tpBtn = Instance.new("TextButton")
tpBtn.Size = UDim2.new(0.5,-15,0,30)
tpBtn.Position = UDim2.new(0,10,0,190)
tpBtn.BackgroundColor3 = Color3.fromRGB(80,0,0)
tpBtn.TextColor3 = Color3.new(1,1,1)
tpBtn.Text = "Teleport"
tpBtn.Parent = main
local tpCorner = Instance.new("UICorner")
tpCorner.CornerRadius = UDim.new(0,6)
tpCorner.Parent = tpBtn

tpBtn.MouseButton1Click:Connect(function()
    if currentTarget then
        teleportBehind(currentTarget)
    end
end)

local quickBtn = Instance.new("TextButton")
quickBtn.Size = UDim2.new(0.5,-15,0,30)
quickBtn.Position = UDim2.new(0.5,5,0,190)
quickBtn.BackgroundColor3 = Color3.fromRGB(0,80,0)
quickBtn.TextColor3 = Color3.new(1,1,1)
quickBtn.Text = "Quick Teleport"
quickBtn.Parent = main
local quickCorner = Instance.new("UICorner")
quickCorner.CornerRadius = UDim.new(0,6)
quickCorner.Parent = quickBtn

quickBtn.MouseButton1Click:Connect(function()
    local nearest = getNearestInFront()
    if nearest then
        teleportBehind(nearest)
    end
end)
