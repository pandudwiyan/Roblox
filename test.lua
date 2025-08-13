--// GUI Teleport ke Stage / Summit
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

-- Buat GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "StageTeleportUI"

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 200, 0, 400)
MainFrame.Position = UDim2.new(0, 20, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "Stage Teleport"
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Parent = MainFrame

local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, 0, 1, -40)
ScrollFrame.Position = UDim2.new(0, 0, 0, 40)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.ScrollBarThickness = 6
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout", ScrollFrame)
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Cari semua Part yang namanya mengandung "stage", "checkpoint", atau "summit"
local stages = {}
for _, obj in ipairs(workspace:GetDescendants()) do
    if obj:IsA("BasePart") then
        local name = obj.Name:lower()
        if name:find("stage") or name:find("checkpoint") or name:find("summit") then
            table.insert(stages, obj)
        end
    end
end

-- Buat tombol untuk setiap lokasi
for i, stagePart in ipairs(stages) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = stagePart.Name
    btn.Parent = ScrollFrame

    btn.MouseButton1Click:Connect(function()
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        if char and char:FindFirstChild("HumanoidRootPart") then
            char:SetPrimaryPartCFrame(stagePart.CFrame + Vector3.new(0, 3, 0))
        end
    end)
end

-- Auto update ukuran scroll
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
end)
