local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Hapus panel lama
pcall(function()
    local pg = LocalPlayer:WaitForChild("PlayerGui")
    local old = pg:FindFirstChild("MimikriPanel")
    if old then old:Destroy() end
end)

-- UI
local WIDTH, HEIGHT = 420, 360
local HEADER_H = 32

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MimikriPanel"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, WIDTH, 0, HEIGHT)
Main.Position = UDim2.new(0.15, 0, 0.2, 0)
Main.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Main.BorderSizePixel = 0
Main.Active = true
Main.Parent = ScreenGui

local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, HEADER_H)
Header.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Header.BorderSizePixel = 0

local Title = Instance.new("TextLabel", Header)
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 10, 0, 0)
Title.Size = UDim2.new(1, -100, 1, 0)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Text = "Player Mimikri"
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.TextColor3 = Color3.new(1, 1, 1)

local RefreshBtn = Instance.new("TextButton", Header)
RefreshBtn.Size = UDim2.new(0, 72, 1, 0)
RefreshBtn.Position = UDim2.new(1, -112, 0, 0)
RefreshBtn.BackgroundColor3 = Color3.fromRGB(0, 130, 0)
RefreshBtn.TextColor3 = Color3.new(1,1,1)
RefreshBtn.Text = "Refresh"
RefreshBtn.Font = Enum.Font.SourceSans
RefreshBtn.TextSize = 16

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 40, 1, 0)
CloseBtn.Position = UDim2.new(1, -40, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 18
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)

local PlayerList = Instance.new("ScrollingFrame", Main)
PlayerList.Size = UDim2.new(1, 0, 1, -HEADER_H)
PlayerList.Position = UDim2.new(0, 0, 0, HEADER_H)
PlayerList.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
PlayerList.ScrollBarThickness = 6
PlayerList.BorderSizePixel = 0
PlayerList.AutomaticCanvasSize = Enum.AutomaticSize.Y

local ListLayout = Instance.new("UIListLayout", PlayerList)
ListLayout.Padding = UDim.new(0, 4)
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Dragging
do
    local dragging, dragStart, startPos
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Fungsi Mimikri
local function mimikriPlayer(target)
    if target and target.Character then
        local hum = target.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            local desc = hum:GetAppliedDescription()
            
            -- Simpan posisi sekarang
            local oldPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position
            
            -- Respawn
            LocalPlayer:LoadCharacter()
            
            -- Tunggu karakter baru
            LocalPlayer.CharacterAdded:Wait()
            task.wait(0.3)
            
            local myHum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if myHum then
                myHum:ApplyDescription(desc)
            end
            
            -- Balikin ke posisi lama kalau ada
            if oldPos and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(oldPos)
            end
        end
    end
end

-- Build List Player
local function buildPlayerList()
    for _, ch in ipairs(PlayerList:GetChildren()) do
        if not ch:IsA("UIListLayout") then ch:Destroy() end
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, -8, 0, 28)
            row.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
            row.Parent = PlayerList

            local nameLabel = Instance.new("TextLabel", row)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Size = UDim2.new(0.6, 0, 1, 0)
            nameLabel.Position = UDim2.new(0, 6, 0, 0)
            nameLabel.Font = Enum.Font.SourceSans
            nameLabel.TextSize = 14
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.TextColor3 = Color3.new(1,1,1)
            nameLabel.Text = plr.Name .. " | " .. plr.DisplayName  -- format baru

            local mimicBtn = Instance.new("TextButton", row)
            mimicBtn.Size = UDim2.new(0.3, -8, 0.8, 0)
            mimicBtn.Position = UDim2.new(0.7, 4, 0.1, 0)
            mimicBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 180)
            mimicBtn.TextColor3 = Color3.new(1,1,1)
            mimicBtn.Font = Enum.Font.SourceSansBold
            mimicBtn.TextSize = 14
            mimicBtn.Text = "Mimikri"

            mimicBtn.MouseButton1Click:Connect(function()
                mimikriPlayer(plr)
            end)
        end
    end
end

-- Tombol
RefreshBtn.MouseButton1Click:Connect(buildPlayerList)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- Build pertama
buildPlayerList()
