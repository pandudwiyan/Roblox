-- GUI
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local ScanButton = Instance.new("TextButton")
local UIListLayout = Instance.new("UIListLayout")

ScreenGui.Parent = game:GetService("CoreGui")

Frame.Size = UDim2.new(0, 250, 0, 400)
Frame.Position = UDim2.new(0, 20, 0, 100)
Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Frame.Parent = ScreenGui

ScanButton.Size = UDim2.new(1, 0, 0, 30)
ScanButton.Text = "🔍 Scan All Parts"
ScanButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
ScanButton.TextColor3 = Color3.new(1, 1, 1)
ScanButton.Parent = Frame

UIListLayout.Parent = Frame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Fungsi scan semua Part
local function scanParts()
    -- Hapus tombol lama
    for _, child in ipairs(Frame:GetChildren()) do
        if child:IsA("TextButton") and child ~= ScanButton then
            child:Destroy()
        end
    end
    
    -- Cari semua Part
    local parts = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            table.insert(parts, obj)
        end
    end
    
    -- Buat tombol untuk tiap Part
    for i, part in ipairs(parts) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 30)
        btn.Text = part.Name .. " #" .. i
        btn.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Parent = Frame
        
        btn.MouseButton1Click:Connect(function()
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.CFrame = part.CFrame + Vector3.new(0, 5, 0)
            end
        end)
    end
end

ScanButton.MouseButton1Click:Connect(scanParts)
