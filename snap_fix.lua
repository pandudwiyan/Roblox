--// Teleport & Snap GUI Revisi //--

if game.CoreGui:FindFirstChild("TeleportSnapGui") then
    game.CoreGui.TeleportSnapGui:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "TeleportSnapGui"
gui.Parent = game.CoreGui

-- Main Panel
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 220)
frame.Position = UDim2.new(0, 10, 1, -230) -- pojok kiri bawah
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BackgroundTransparency = 0.2
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

-- UICorner biar modern
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 0, 30)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Teleport & Snap"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 0)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.BackgroundTransparency = 1
closeBtn.Parent = frame
closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- Textbox untuk koordinat hasil snap
local coordBox = Instance.new("TextBox")
coordBox.Size = UDim2.new(1, -20, 0, 60)
coordBox.Position = UDim2.new(0, 10, 0, 40)
coordBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
coordBox.TextColor3 = Color3.fromRGB(255,255,255)
coordBox.Font = Enum.Font.Code
coordBox.TextSize = 14
coordBox.TextXAlignment = Enum.TextXAlignment.Left
coordBox.TextYAlignment = Enum.TextYAlignment.Top
coordBox.ClearTextOnFocus = false
coordBox.MultiLine = true
coordBox.TextWrapped = true
coordBox.Text = "-- Hasil Snap Akan Muncul Disini --"
coordBox.Parent = frame

local coordCorner = Instance.new("UICorner")
coordCorner.CornerRadius = UDim.new(0, 6)
coordCorner.Parent = coordBox

-- AutoName Checkbox
local autoCheck = Instance.new("TextButton")
autoCheck.Size = UDim2.new(0, 20, 0, 20)
autoCheck.Position = UDim2.new(0, 10, 0, 110)
autoCheck.Text = ""
autoCheck.BackgroundColor3 = Color3.fromRGB(60,60,60)
autoCheck.Parent = frame

local autoCorner = Instance.new("UICorner")
autoCorner.CornerRadius = UDim.new(0,4)
autoCorner.Parent = autoCheck

local checked = false
local currentCP = 1

autoCheck.MouseButton1Click:Connect(function()
    checked = not checked
    autoCheck.BackgroundColor3 = checked and Color3.fromRGB(80,200,120) or Color3.fromRGB(60,60,60)
end)

-- Label AutoName
local autoLabel = Instance.new("TextLabel")
autoLabel.Size = UDim2.new(0, 80, 0, 20)
autoLabel.Position = UDim2.new(0, 35, 0, 110)
autoLabel.BackgroundTransparency = 1
autoLabel.Text = "AutoName:"
autoLabel.TextColor3 = Color3.fromRGB(255,255,255)
autoLabel.Font = Enum.Font.Gotham
autoLabel.TextSize = 14
autoLabel.TextXAlignment = Enum.TextXAlignment.Left
autoLabel.Parent = frame

-- Input CP Number
local cpInput = Instance.new("TextBox")
cpInput.Size = UDim2.new(0, 50, 0, 20)
cpInput.Position = UDim2.new(0, 115, 0, 110)
cpInput.BackgroundColor3 = Color3.fromRGB(50,50,50)
cpInput.TextColor3 = Color3.fromRGB(255,255,255)
cpInput.Font = Enum.Font.Code
cpInput.TextSize = 14
cpInput.Text = "1"
cpInput.ClearTextOnFocus = false
cpInput.Parent = frame

local cpCorner = Instance.new("UICorner")
cpCorner.CornerRadius = UDim.new(0,4)
cpCorner.Parent = cpInput

-- SNAP Button
local snapBtn = Instance.new("TextButton")
snapBtn.Size = UDim2.new(0.45, -15, 0, 35)
snapBtn.Position = UDim2.new(0, 10, 0, 150)
snapBtn.Text = "SNAP"
snapBtn.Font = Enum.Font.GothamBold
snapBtn.TextSize = 16
snapBtn.TextColor3 = Color3.fromRGB(255,255,255)
snapBtn.BackgroundColor3 = Color3.fromRGB(0,120,255)
snapBtn.Parent = frame

local snapCorner = Instance.new("UICorner")
snapCorner.CornerRadius = UDim.new(0,8)
snapCorner.Parent = snapBtn

-- COPY ALL Button
local copyBtn = Instance.new("TextButton")
copyBtn.Size = UDim2.new(0.45, -15, 0, 35)
copyBtn.Position = UDim2.new(0.55, 5, 0, 150)
copyBtn.Text = "COPY ALL"
copyBtn.Font = Enum.Font.GothamBold
copyBtn.TextSize = 16
copyBtn.TextColor3 = Color3.fromRGB(255,255,255)
copyBtn.BackgroundColor3 = Color3.fromRGB(80,200,120)
copyBtn.Parent = frame

local copyCorner = Instance.new("UICorner")
copyCorner.CornerRadius = UDim.new(0,8)
copyCorner.Parent = copyBtn

-- SNAP Logic
snapBtn.MouseButton1Click:Connect(function()
    local player = game.Players.LocalPlayer
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end

    local pos = player.Character.HumanoidRootPart.Position
    local coordText

    if checked then
        -- ambil angka dari input CP kalau baru diaktifkan
        if tonumber(cpInput.Text) then
            currentCP = tonumber(cpInput.Text)
        end
        coordText = string.format("X: %.2f, Y: %.2f, Z: %.2f (CP%d)", pos.X, pos.Y, pos.Z, currentCP)
        currentCP = currentCP + 1
        cpInput.Text = tostring(currentCP) -- update input biar kelihatan
    else
        coordText = string.format("X: %.2f, Y: %.2f, Z: %.2f", pos.X, pos.Y, pos.Z)
    end

    if coordBox.Text == "-- Hasil Snap Akan Muncul Disini --" then
        coordBox.Text = coordText
    else
        coordBox.Text = coordBox.Text .. "\n" .. coordText
    end
end)

-- COPY ALL Logic
copyBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(coordBox.Text)
    end
end)
