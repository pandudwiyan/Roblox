--// Object Scanner v2 - By ChatGPT

-- Buat GUI
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TitleBar = Instance.new("Frame")
local TitleLabel = Instance.new("TextLabel")
local MinimizeBtn = Instance.new("TextButton")
local CloseBtn = Instance.new("TextButton")
local ScrollFrame = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")
local ScanButton = Instance.new("TextButton")

ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Frame Utama
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MainFrame.Size = UDim2.new(0, 300, 0, 400)
MainFrame.Position = UDim2.new(0.3, 0, 0.3, 0)
MainFrame.Active = true
MainFrame.Draggable = true

-- Title Bar
TitleBar.Parent = MainFrame
TitleBar.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
TitleBar.Size = UDim2.new(1, 0, 0, 30)

TitleLabel.Parent = TitleBar
TitleLabel.BackgroundTransparency = 1
TitleLabel.Size = UDim2.new(1, -60, 1, 0)
TitleLabel.Position = UDim2.new(0, 5, 0, 0)
TitleLabel.Text = "Object Scanner"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

MinimizeBtn.Parent = TitleBar
MinimizeBtn.Size = UDim2.new(0, 30, 1, 0)
MinimizeBtn.Position = UDim2.new(1, -60, 0, 0)
MinimizeBtn.Text = "-"
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(90, 0, 0)
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

CloseBtn.Parent = TitleBar
CloseBtn.Size = UDim2.new(0, 30, 1, 0)
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.Text = "X"
CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

-- Scroll Frame
ScrollFrame.Parent = MainFrame
ScrollFrame.Size = UDim2.new(1, 0, 1, -30)
ScrollFrame.Position = UDim2.new(0, 0, 0, 30)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.ScrollBarThickness = 6
ScrollFrame.Visible = false

UIListLayout.Parent = ScrollFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 2)

-- Tombol Scan
ScanButton.Parent = MainFrame
ScanButton.Size = UDim2.new(1, 0, 1, -30)
ScanButton.Position = UDim2.new(0, 0, 0, 30)
ScanButton.BackgroundColor3 = Color3.fromRGB(70, 0, 0)
ScanButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ScanButton.Text = "Scan ClassName"

-- Variabel
local currentClass = nil
local lastScanData = {}

-- Fungsi Scan Semua Class
local function scanAll()
    local classCount = {}
    for _, obj in pairs(game:GetDescendants()) do
        local cname = obj.ClassName
        classCount[cname] = (classCount[cname] or 0) + 1
    end
    return classCount
end

-- Fungsi Scan Class Tertentu
local function scanSpecific(classname)
    local objs = {}
    for _, obj in pairs(game:GetDescendants()) do
        if obj.ClassName == classname then
            table.insert(objs, obj)
        end
    end
    return objs
end

-- Fungsi Update List
local function updateListClass()
    ScrollFrame:ClearAllChildren()
    UIListLayout.Parent = ScrollFrame

    for cname, count in pairs(lastScanData) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 30)
        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Text = cname .. " : " .. count
        btn.Parent = ScrollFrame

        btn.MouseButton1Click:Connect(function()
            currentClass = cname
            local objs = scanSpecific(cname)
            lastScanData = objs
            ScrollFrame:ClearAllChildren()
            UIListLayout.Parent = ScrollFrame

            for i, obj in ipairs(objs) do
                local objBtn = Instance.new("TextButton")
                objBtn.Size = UDim2.new(1, 0, 0, 30)
                objBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
                objBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                objBtn.Text = cname .. " #" .. i
                objBtn.Parent = ScrollFrame

                objBtn.MouseButton1Click:Connect(function()
                    if obj:IsA("BasePart") then
                        game.Players.LocalPlayer.Character:SetPrimaryPartCFrame(obj.CFrame + Vector3.new(0, 3, 0))
                    elseif obj:IsA("Model") and obj.PrimaryPart then
                        game.Players.LocalPlayer.Character:SetPrimaryPartCFrame(obj.PrimaryPart.CFrame + Vector3.new(0, 3, 0))
                    end
                end)
            end

            ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
        end)
    end

    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
end

-- Klik Scan
ScanButton.MouseButton1Click:Connect(function()
    lastScanData = scanAll()
    updateListClass()
    ScanButton.Visible = false
    ScrollFrame.Visible = true
end)

-- Minimize & Close
MinimizeBtn.MouseButton1Click:Connect(function()
    ScrollFrame.Visible = not ScrollFrame.Visible
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)
