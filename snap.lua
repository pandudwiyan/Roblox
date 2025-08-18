-- Delta Exploit - Snap Position Logger (Tema GUI Teleport & View)

-- GUI Utama
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local MainFrame = Instance.new("Frame")
local Header = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local CloseBtn = Instance.new("TextButton")
local MinBtn = Instance.new("TextButton")
local Content = Instance.new("Frame")

-- ScreenGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- MainFrame
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
MainFrame.BackgroundTransparency = 0.25
MainFrame.Position = UDim2.new(0.5,-200,0.5,-125)
MainFrame.Size = UDim2.new(0,400,0,250)
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0,8)

-- Header
Header.Parent = MainFrame
Header.BackgroundColor3 = Color3.fromRGB(30,30,30)
Header.BackgroundTransparency = 0.25
Header.Size = UDim2.new(1,0,0,30)
Instance.new("UICorner", Header).CornerRadius = UDim.new(0,8)

-- Title
Title.Parent = Header
Title.Text = "Snap Position Logger"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Position = UDim2.new(0,10,0,0)
Title.Size = UDim2.new(0.7,0,1,0)
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Close
CloseBtn.Parent = Header
CloseBtn.Size = UDim2.new(0,30,1,0)
CloseBtn.Position = UDim2.new(1,-30,0,0)
CloseBtn.Text = "X"
CloseBtn.BackgroundTransparency = 1
CloseBtn.TextColor3 = Color3.fromRGB(255,255,255)
CloseBtn.Font = Enum.Font.GothamBold

-- Minimize
MinBtn.Parent = Header
MinBtn.Size = UDim2.new(0,30,1,0)
MinBtn.Position = UDim2.new(1,-60,0,0)
MinBtn.Text = "-"
MinBtn.BackgroundTransparency = 1
MinBtn.TextColor3 = Color3.fromRGB(255,255,255)
MinBtn.Font = Enum.Font.GothamBold

-- Content
Content.Parent = MainFrame
Content.Position = UDim2.new(0,0,0,30)
Content.Size = UDim2.new(1,0,1,-30)
Content.BackgroundTransparency = 1

-- Snap Button
local SnapBtn = Instance.new("TextButton", Content)
SnapBtn.Size = UDim2.new(0, 120, 0, 35)
SnapBtn.Position = UDim2.new(0, 20, 0, 15)
SnapBtn.BackgroundTransparency = 1
SnapBtn.Text = "SNAP"
SnapBtn.TextColor3 = Color3.fromRGB(100,180,255)
SnapBtn.Font = Enum.Font.GothamBold
SnapBtn.TextSize = 16

-- AutoName Checkbox + Input
local AutoCheck = Instance.new("TextButton", Content)
AutoCheck.Size = UDim2.new(0,20,0,20)
AutoCheck.Position = UDim2.new(0,160,0,20)
AutoCheck.BackgroundColor3 = Color3.fromRGB(60,60,60)
AutoCheck.Text = ""
AutoCheck.AutoButtonColor = true

local Checked = false
local CheckMark = Instance.new("TextLabel", AutoCheck)
CheckMark.Size = UDim2.new(1,0,1,0)
CheckMark.Text = ""
CheckMark.TextColor3 = Color3.fromRGB(0,200,0)
CheckMark.BackgroundTransparency = 1
CheckMark.Font = Enum.Font.GothamBold
CheckMark.TextSize = 18

local AutoLabel = Instance.new("TextLabel", Content)
AutoLabel.Size = UDim2.new(0,80,0,20)
AutoLabel.Position = UDim2.new(0,185,0,20)
AutoLabel.Text = "AutoName"
AutoLabel.TextColor3 = Color3.fromRGB(255,255,255)
AutoLabel.BackgroundTransparency = 1
AutoLabel.Font = Enum.Font.Gotham
AutoLabel.TextSize = 14
AutoLabel.TextXAlignment = Enum.TextXAlignment.Left

local AutoInput = Instance.new("TextBox", Content)
AutoInput.Size = UDim2.new(0,50,0,22)
AutoInput.Position = UDim2.new(0,265,0,20)
AutoInput.BackgroundColor3 = Color3.fromRGB(40,40,40)
AutoInput.TextColor3 = Color3.fromRGB(255,255,255)
AutoInput.Font = Enum.Font.Gotham
AutoInput.TextSize = 14
AutoInput.Text = "1"

-- ListFrame
local ListFrame = Instance.new("ScrollingFrame", Content)
ListFrame.Size = UDim2.new(0, 360, 0, 130)
ListFrame.Position = UDim2.new(0, 20, 0, 60)
ListFrame.BackgroundTransparency = 1
ListFrame.ScrollBarThickness = 6
ListFrame.CanvasSize = UDim2.new(0,0,0,0)

local UIListLayout = Instance.new("UIListLayout", ListFrame)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0,2)

-- Copy Button
local CopyBtn = Instance.new("TextButton", Content)
CopyBtn.Size = UDim2.new(0, 360, 0, 30)
CopyBtn.Position = UDim2.new(0, 20, 0, 200)
CopyBtn.BackgroundTransparency = 1
CopyBtn.Text = "COPY ALL"
CopyBtn.TextColor3 = Color3.fromRGB(100,255,100)
CopyBtn.Font = Enum.Font.GothamBold
CopyBtn.TextSize = 16

-- Variabel
local savedCoords = {}
local counter = 0

-- Checkbox toggle
AutoCheck.MouseButton1Click:Connect(function()
    Checked = not Checked
    CheckMark.Text = Checked and "✔" or ""
end)

-- Snap function
local function snapPosition()
    local plr = game.Players.LocalPlayer
    local char = plr.Character or plr.CharacterAdded:Wait()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        local pos = hrp.Position
        counter = counter + 1
        local coordText

        if Checked then
            local startNum = tonumber(AutoInput.Text) or 1
            coordText = string.format("X: %.2f, Y: %.2f, Z: %.2f ( CP%d )", pos.X,pos.Y,pos.Z, startNum + counter - 1)
        else
            coordText = string.format("X: %.2f, Y: %.2f, Z: %.2f", pos.X,pos.Y,pos.Z)
        end

        table.insert(savedCoords, coordText)

        local Label = Instance.new("TextLabel", ListFrame)
        Label.Size = UDim2.new(1, -10, 0, 20)
        Label.BackgroundTransparency = 1
        Label.Text = coordText
        Label.TextColor3 = Color3.fromRGB(255,255,255)
        Label.Font = Enum.Font.Gotham
        Label.TextSize = 14
        Label.TextXAlignment = Enum.TextXAlignment.Left

        ListFrame.CanvasSize = UDim2.new(0,0,0,#savedCoords * 22)
    end
end

-- Copy function
local function copyCoords()
    if #savedCoords > 0 then
        local allCoords = table.concat(savedCoords, "\n")
        if setclipboard then setclipboard(allCoords) end
    end
end

-- Connect
SnapBtn.MouseButton1Click:Connect(snapPosition)
CopyBtn.MouseButton1Click:Connect(copyCoords)

-- Close
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Minimize
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        Content.Visible = false
        MainFrame.Size = UDim2.new(0,400,0,30)
    else
        Content.Visible = true
        MainFrame.Size = UDim2.new(0,400,0,250)
    end
end)

-- Drag
local UserInputService = game:GetService("UserInputService")
local dragging, dragInput, dragStart, startPos

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

Header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                       startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
