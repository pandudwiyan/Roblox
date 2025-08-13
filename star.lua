--// Object Scanner v2 by ChatGPT

-- Hilangkan GUI lama kalau ada
if game.CoreGui:FindFirstChild("ObjectScanner") then
    game.CoreGui.ObjectScanner:Destroy()
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Buat ScreenGui
local gui = Instance.new("ScreenGui")
gui.Name = "ObjectScanner"
gui.Parent = game.CoreGui
gui.ResetOnSpawn = false

-- Frame utama
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 400)
mainFrame.Position = UDim2.new(0.3, 0, 0.2, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = gui
mainFrame.Active = true -- biar draggable

-- Header
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 30)
header.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
header.BorderSizePixel = 0
header.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -60, 1, 0)
title.Position = UDim2.new(0, 5, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Object Scanner"
title.Font = Enum.Font.SourceSansBold
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

-- Minimize button
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 30, 1, 0)
minimizeBtn.Position = UDim2.new(1, -60, 0, 0)
minimizeBtn.Text = "-"
minimizeBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.Parent = header

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 1, 0)
closeBtn.Position = UDim2.new(1, -30, 0, 0)
closeBtn.Text = "X"
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Parent = header

-- Scroll area
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, 0, 1, -30)
scrollFrame.Position = UDim2.new(0, 0, 0, 30)
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.BackgroundTransparency = 1
scrollFrame.ScrollBarThickness = 6
scrollFrame.Parent = mainFrame

-- UI List Layout
local listLayout = Instance.new("UIListLayout")
listLayout.Parent = scrollFrame
listLayout.Padding = UDim.new(0, 2)

-- Fungsi draggable
local dragging, dragInput, dragStart, startPos
header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)
header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)
game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
header.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Tutup & minimize
closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)
local minimized = false
minimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    scrollFrame.Visible = not minimized
end)

-- Fungsi scan semua class
local function scanAll()
    scrollFrame:ClearAllChildren()
    listLayout.Parent = scrollFrame
    local classCount = {}
    for _, obj in ipairs(game:GetDescendants()) do
        classCount[obj.ClassName] = (classCount[obj.ClassName] or 0) + 1
    end
    for className, count in pairs(classCount) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -5, 0, 25)
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Text = className .. " : " .. count
        btn.Parent = scrollFrame
        btn.MouseButton1Click:Connect(function()
            scanSpecific(className)
        end)
    end
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
end

-- Fungsi scan spesifik class
function scanSpecific(className)
    scrollFrame:ClearAllChildren()
    listLayout.Parent = scrollFrame
    local list = {}
    for _, obj in ipairs(game:GetDescendants()) do
        if obj.ClassName == className then
            table.insert(list, obj)
        end
    end
    for i, obj in ipairs(list) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -5, 0, 25)
        btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Text = className .. " #" .. i
        btn.Parent = scrollFrame
        btn.MouseButton1Click:Connect(function()
            if obj:IsA("BasePart") then
                LocalPlayer.Character:PivotTo(CFrame.new(obj.Position + Vector3.new(0, 3, 0)))
            elseif obj:IsA("Attachment") then
                LocalPlayer.Character:PivotTo(CFrame.new(obj.WorldPosition + Vector3.new(0, 3, 0)))
            end
        end)
    end

    -- Tombol kembali
    local backBtn = Instance.new("TextButton")
    backBtn.Size = UDim2.new(1, -5, 0, 25)
    backBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
    backBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    backBtn.Text = "< Kembali"
    backBtn.Parent = scrollFrame
    backBtn.MouseButton1Click:Connect(scanAll)

    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
end

-- Jalankan pertama kali
scanAll()
