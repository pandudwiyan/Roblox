--// GUI Setup
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local ScrollingFrame = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")
local CloseButton = Instance.new("TextButton")

ScreenGui.Parent = game:GetService("CoreGui")

-- Frame utama
Frame.Size = UDim2.new(0, 300, 0, 400)
Frame.Position = UDim2.new(0, 50, 0, 100)
Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Frame.Parent = ScreenGui

-- Tombol close
CloseButton.Size = UDim2.new(1, 0, 0, 30)
CloseButton.Text = "X Close"
CloseButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
CloseButton.TextColor3 = Color3.new(1, 1, 1)
CloseButton.Parent = Frame
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Scroll list
ScrollingFrame.Size = UDim2.new(1, 0, 1, -30)
ScrollingFrame.Position = UDim2.new(0, 0, 0, 30)
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingFrame.ScrollBarThickness = 8
ScrollingFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
ScrollingFrame.Parent = Frame

UIListLayout.Parent = ScrollingFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 2)

local Players = game:GetService("Players")
local player = Players.LocalPlayer

--// SCAN OBJECT
for _, obj in ipairs(workspace:GetDescendants()) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 25)
    btn.Text = obj.Name .. " | " .. obj.ClassName
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Parent = ScrollingFrame

    btn.MouseButton1Click:Connect(function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and obj:IsA("BasePart") then
            player.Character.HumanoidRootPart.CFrame = obj.CFrame + Vector3.new(0, 5, 0)
        else
            warn("Tidak bisa teleport ke object ini: " .. obj.Name)
        end
    end)
end

-- Update tinggi canvas
UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
end)
