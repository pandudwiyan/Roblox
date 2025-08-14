--[[
UI: Search Teleport
By ChatGPT
Desain: Mirip gambar user, dengan List, Search, dan Teleport button
Fitur:
- Ketik di Search -> list hasil pencarian (Parts, Models, Players) langsung muncul
- Klik salah satu -> kamera snap ke target
- Bergerak -> kamera kembali ke karakter
]]

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

-- GUI Parent
local parentGui = (gethui and gethui()) or game:FindFirstChildOfClass("CoreGui")
if parentGui:FindFirstChild("SearchTeleportUI") then parentGui.SearchTeleportUI:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "SearchTeleportUI"
gui.ResetOnSpawn = false
gui.Parent = parentGui

-- Main Frame
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 320, 0, 400)
main.Position = UDim2.new(0.35, 0, 0.25, 0)
main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
main.BorderSizePixel = 0
main.Parent = gui

-- UICorner
local function roundify(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = obj
end

roundify(main, 10)

-- List Frame
local listFrame = Instance.new("Frame")
listFrame.Size = UDim2.new(1, -20, 0, 250)
listFrame.Position = UDim2.new(0, 10, 0, 10)
listFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
listFrame.BorderSizePixel = 0
listFrame.Parent = main
roundify(listFrame, 8)

-- ScrollingFrame
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, 0, 1, 0)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.ScrollBarThickness = 6
scroll.BackgroundTransparency = 1
scroll.Parent = listFrame

local layout = Instance.new("UIListLayout")
layout.Parent = scroll
layout.Padding = UDim.new(0, 4)

-- Search Box
local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(1, -20, 0, 35)
searchBox.Position = UDim2.new(0, 10, 0, 270)
searchBox.PlaceholderText = "SEARCH"
searchBox.TextColor3 = Color3.new(1, 1, 1)
searchBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
searchBox.BorderSizePixel = 0
searchBox.ClearTextOnFocus = false
searchBox.Parent = main
roundify(searchBox, 12)

-- Teleport Button
local teleportBtn = Instance.new("TextButton")
teleportBtn.Size = UDim2.new(1, -20, 0, 35)
teleportBtn.Position = UDim2.new(0, 10, 0, 315)
teleportBtn.Text = "Teleport"
teleportBtn.TextColor3 = Color3.new(1, 1, 1)
teleportBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
teleportBtn.BorderSizePixel = 0
teleportBtn.Parent = main
roundify(teleportBtn, 12)

-- Variabel target
local currentTarget = nil
local cameraFollowing = true

-- Fungsi refresh list
local function refreshList(keyword)
    for _, child in ipairs(scroll:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    keyword = keyword:lower()

    local results = {}

    -- Cari di semua player
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character and (plr.Name:lower():find(keyword) or plr.DisplayName:lower():find(keyword)) then
            table.insert(results, plr.Character:FindFirstChild("HumanoidRootPart"))
        end
    end

    -- Cari di semua object workspace
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find(keyword) then
            table.insert(results, obj)
        end
    end

    for _, part in ipairs(results) do
        if part then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -4, 0, 30)
            btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
            btn.TextColor3 = Color3.new(1, 1, 1)
            btn.Text = part.Name
            btn.Parent = scroll
            roundify(btn, 6)
            btn.MouseButton1Click:Connect(function()
                currentTarget = part
                cameraFollowing = false
                Camera.CameraType = Enum.CameraType.Scriptable
                Camera.CFrame = CFrame.new(
                    part.Position + Vector3.new(0, 5, 10),
                    part.Position
                )
            end)
        end
    end
    scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
end

-- Event search
searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    if searchBox.Text ~= "" then
        refreshList(searchBox.Text)
    else
        for _, child in ipairs(scroll:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
    end
end)

-- Teleport ke target
teleportBtn.MouseButton1Click:Connect(function()
    if currentTarget and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        LP.Character:PivotTo(CFrame.new(currentTarget.Position + Vector3.new(0, 3, 0)))
    end
end)

-- Kembalikan kamera kalau bergerak
UIS.InputBegan:Connect(function(input, processed)
    if not processed and cameraFollowing == false then
        if input.UserInputType == Enum.UserInputType.Keyboard then
            local key = input.KeyCode
            if key == Enum.KeyCode.W or key == Enum.KeyCode.A or key == Enum.KeyCode.S or key == Enum.KeyCode.D then
                Camera.CameraType = Enum.CameraType.Custom
                cameraFollowing = true
            end
        end
    end
end)
