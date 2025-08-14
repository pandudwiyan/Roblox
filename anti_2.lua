--[[
Search Teleport UI v2
By ChatGPT
Fitur:
- Draggable GUI
- Background transparan
- List hasil pencarian hidden saat kosong
- Kamera snap ke target, bisa diputar POV
- Teleport 12 stud di belakang target
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
main.Size = UDim2.new(0, 220, 0, 90) -- default size kecil
main.Position = UDim2.new(0.4, 0, 0.3, 0)
main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
main.BackgroundTransparency = 0.4 -- transparan
main.BorderSizePixel = 0
main.Parent = gui

local function roundify(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = obj
end
roundify(main, 8)

-- Dragging logic
do
    local dragging, dragStart, startPos
    main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
        end
    end)
    main.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Search Box
local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(1, -20, 0, 30)
searchBox.Position = UDim2.new(0, 10, 0, 10)
searchBox.PlaceholderText = "SEARCH"
searchBox.TextColor3 = Color3.new(1, 1, 1)
searchBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
searchBox.BackgroundTransparency = 0.3
searchBox.BorderSizePixel = 0
searchBox.ClearTextOnFocus = false
searchBox.Parent = main
roundify(searchBox, 8)

-- Teleport Button
local teleportBtn = Instance.new("TextButton")
teleportBtn.Size = UDim2.new(1, -20, 0, 30)
teleportBtn.Position = UDim2.new(0, 10, 0, 50)
teleportBtn.Text = "Teleport"
teleportBtn.TextColor3 = Color3.new(1, 1, 1)
teleportBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
teleportBtn.BackgroundTransparency = 0.3
teleportBtn.BorderSizePixel = 0
teleportBtn.Parent = main
roundify(teleportBtn, 8)

-- List Frame (hidden awalnya)
local listFrame = Instance.new("Frame")
listFrame.Size = UDim2.new(1, -20, 0, 150)
listFrame.Position = UDim2.new(0, 10, 0, -160) -- di atas panel
listFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
listFrame.BackgroundTransparency = 0.3
listFrame.BorderSizePixel = 0
listFrame.Visible = false
listFrame.Parent = main
roundify(listFrame, 8)

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, 0, 1, 0)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.ScrollBarThickness = 6
scroll.BackgroundTransparency = 1
scroll.Parent = listFrame

local layout = Instance.new("UIListLayout")
layout.Parent = scroll
layout.Padding = UDim.new(0, 4)

-- Variabel
local currentTarget = nil
local cameraFollowing = true

-- Fungsi refresh list
local function refreshList(keyword)
    for _, child in ipairs(scroll:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    keyword = keyword:lower()

    local results = {}

    -- Player
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character and (plr.Name:lower():find(keyword) or plr.DisplayName:lower():find(keyword)) then
            table.insert(results, plr.Character:FindFirstChild("HumanoidRootPart"))
        end
    end

    -- Object
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find(keyword) then
            table.insert(results, obj)
        end
    end

    if #results > 0 then
        listFrame.Visible = true
    else
        listFrame.Visible = false
    end

    for _, part in ipairs(results) do
        if part then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -4, 0, 30)
            btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
            btn.BackgroundTransparency = 0.3
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
        listFrame.Visible = false
    end
end)

-- Teleport ke target 12 stud di belakang
teleportBtn.MouseButton1Click:Connect(function()
    if currentTarget and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        local behind = currentTarget.CFrame * CFrame.new(0, 0, 12)
        LP.Character:PivotTo(behind)
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

-- Saat kamera snap, masih bisa putar POV dengan mouse
RunService.RenderStepped:Connect(function()
    if not cameraFollowing and currentTarget then
        local mouseDelta = UIS:GetMouseDelta()
        if mouseDelta.Magnitude > 0 then
            local rot = CFrame.Angles(0, -mouseDelta.X * 0.002, 0)
            local offset = Camera.CFrame.Position - currentTarget.Position
            offset = rot:VectorToWorldSpace(offset)
            Camera.CFrame = CFrame.new(currentTarget.Position + offset, currentTarget.Position)
        end
    end
end)
