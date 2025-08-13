-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local UIListLayout = Instance.new("UIListLayout")
local CloseButton = Instance.new("TextButton")

ScreenGui.Parent = game:GetService("CoreGui")

Frame.Size = UDim2.new(0, 250, 0, 400)
Frame.Position = UDim2.new(0, 50, 0, 100)
Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Frame.Parent = ScreenGui

CloseButton.Size = UDim2.new(1, 0, 0, 30)
CloseButton.Text = "X Close"
CloseButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
CloseButton.TextColor3 = Color3.new(1, 1, 1)
CloseButton.Parent = Frame
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

UIListLayout.Parent = Frame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 2)

-- Hitung jumlah tiap ClassName
local classCount = {}
for _, obj in ipairs(workspace:GetDescendants()) do
    classCount[obj.ClassName] = (classCount[obj.ClassName] or 0) + 1
end

-- Tampilkan tabel
for className, count in pairs(classCount) do
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 0, 25)
    label.Text = className .. " : " .. count
    label.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Parent = Frame
end
