--// Full Object Scanner + Teleport GUI //--
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Buat GUI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local MainFrame = Instance.new("Frame")
local TitleBar = Instance.new("Frame")
local TitleLabel = Instance.new("TextLabel")
local CloseButton = Instance.new("TextButton")
local MinimizeButton = Instance.new("TextButton")
local ScrollingFrame = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")

-- Properti GUI Utama
MainFrame.Size = UDim2.new(0, 300, 0, 400)
MainFrame.Position = UDim2.new(0.3, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Title Bar
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
TitleBar.Parent = MainFrame

TitleLabel.Size = UDim2.new(1, -60, 1, 0)
TitleLabel.Position = UDim2.new(0, 5, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Object Scanner"
TitleLabel.TextColor3 = Color3.new(1, 1, 1)
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

-- Tombol Close
CloseButton.Size = UDim2.new(0, 30, 1, 0)
CloseButton.Position = UDim2.new(1, -30, 0, 0)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.new(1, 1, 1)
CloseButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
CloseButton.Parent = TitleBar
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Tombol Minimize
MinimizeButton.Size = UDim2.new(0, 30, 1, 0)
MinimizeButton.Position = UDim2.new(1, -60, 0, 0)
MinimizeButton.Text = "-"
MinimizeButton.TextColor3 = Color3.new(1, 1, 1)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
MinimizeButton.Parent = TitleBar
local minimized = false
MinimizeButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    ScrollingFrame.Visible = not minimized
    MainFrame.Size = minimized and UDim2.new(0, 300, 0, 30) or UDim2.new(0, 300, 0, 400)
end)

-- Scrolling Frame
ScrollingFrame.Size = UDim2.new(1, 0, 1, -30)
ScrollingFrame.Position = UDim2.new(0, 0, 0, 30)
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingFrame.ScrollBarThickness = 6
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.Parent = MainFrame

UIListLayout.Parent = ScrollingFrame
UIListLayout.Padding = UDim.new(0, 2)

-- Fungsi untuk membuat tombol item
local function CreateButton(name, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -6, 0, 25)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Text = name
    btn.Parent = ScrollingFrame
    btn.MouseButton1Click:Connect(callback)
end

-- Fungsi scanning class
local function ScanObjects()
    ScrollingFrame:ClearAllChildren()
    UIListLayout.Parent = ScrollingFrame

    local classCount = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        local class = obj.ClassName
        classCount[class] = (classCount[class] or 0) + 1
    end

    for class, count in pairs(classCount) do
        CreateButton(class .. " : " .. count, function()
            -- Ketika klik class, tampilkan object-objectnya
            ScrollingFrame:ClearAllChildren()
            UIListLayout.Parent = ScrollingFrame
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj.ClassName == class then
                    CreateButton(obj.Name, function()
                        if obj:IsA("BasePart") then
                            LocalPlayer.Character:MoveTo(obj.Position)
                        elseif obj:FindFirstChild("HumanoidRootPart") then
                            LocalPlayer.Character:MoveTo(obj.HumanoidRootPart.Position)
                        end
                    end)
                end
            end
        end)
    end
end

-- Jalankan scan awal
ScanObjects()
