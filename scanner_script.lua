--// Script Browser – Delta Executor
--// Scan semua object di Workspace yang memiliki Script/LocalScript/ModuleScript
--// Panel kiri = daftar object
--// Panel kanan = isi script

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Bersihkan kalau sudah ada
pcall(function()
    local pg = LocalPlayer:WaitForChild("PlayerGui")
    local old = pg:FindFirstChild("ScriptBrowserPanel")
    if old then old:Destroy() end
end)

-- ===== UI setup =====
local WIDTH, HEIGHT = 800, 450
local HEADER_H = 32

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ScriptBrowserPanel"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, WIDTH, 0, HEIGHT)
Main.Position = UDim2.new(0.1, 0, 0.15, 0)
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
Title.Size = UDim2.new(1, -150, 1, 0)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Text = "Script Browser"
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.TextColor3 = Color3.new(1, 1, 1)

local RefreshBtn = Instance.new("TextButton", Header)
RefreshBtn.Size = UDim2.new(0, 72, 1, 0)
RefreshBtn.Position = UDim2.new(1, -120, 0, 0)
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

-- ===== Panel kiri (list object) =====
local LeftPanel = Instance.new("ScrollingFrame", Main)
LeftPanel.Size = UDim2.new(0.4, -2, 1, -HEADER_H)
LeftPanel.Position = UDim2.new(0, 0, 0, HEADER_H)
LeftPanel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
LeftPanel.ScrollBarThickness = 6
LeftPanel.BorderSizePixel = 0
LeftPanel.AutomaticCanvasSize = Enum.AutomaticSize.Y

local LeftList = Instance.new("UIListLayout", LeftPanel)
LeftList.Padding = UDim.new(0, 4)
LeftList.SortOrder = Enum.SortOrder.LayoutOrder

-- ===== Panel kanan (script viewer) =====
local RightPanel = Instance.new("Frame", Main)
RightPanel.Size = UDim2.new(0.6, 0, 1, -HEADER_H)
RightPanel.Position = UDim2.new(0.4, 2, 0, HEADER_H)
RightPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
RightPanel.BorderSizePixel = 0

local ScriptBox = Instance.new("TextBox", RightPanel)
ScriptBox.Size = UDim2.new(1, -8, 1, -8)
ScriptBox.Position = UDim2.new(0, 4, 0, 4)
ScriptBox.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ScriptBox.TextColor3 = Color3.new(1,1,1)
ScriptBox.Font = Enum.Font.Code
ScriptBox.TextSize = 14
ScriptBox.TextXAlignment = Enum.TextXAlignment.Left
ScriptBox.TextYAlignment = Enum.TextYAlignment.Top
ScriptBox.ClearTextOnFocus = false
ScriptBox.MultiLine = true
ScriptBox.TextWrapped = false
ScriptBox.TextEditable = false
ScriptBox.Text = "-- Pilih script di sebelah kiri untuk melihat isi"
ScriptBox.RichText = false

-- ===== Dragging header =====
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

-- ===== Scanner =====
local function scanObjectsWithScripts()
    local result = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        -- Cek kalau obj punya script di dalamnya
        local scriptsFound = {}
        for _, child in ipairs(obj:GetDescendants()) do
            if child:IsA("Script") or child:IsA("LocalScript") or child:IsA("ModuleScript") then
                table.insert(scriptsFound, child)
            end
        end
        if #scriptsFound > 0 then
            table.insert(result, {Object = obj, Scripts = scriptsFound})
        end
    end
    return result
end

-- ===== Build list kiri =====
local function buildList()
    for _, ch in ipairs(LeftPanel:GetChildren()) do
        if not ch:IsA("UIListLayout") then ch:Destroy() end
    end
    ScriptBox.Text = "-- Pilih script di sebelah kiri untuk melihat isi"

    local objects = scanObjectsWithScripts()
    for _, entry in ipairs(objects) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -8, 0, 26)
        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Font = Enum.Font.SourceSans
        btn.TextSize = 14
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Text = ("%s  [%d scripts]"):format(entry.Object:GetFullName(), #entry.Scripts)
        btn.Parent = LeftPanel

        btn.MouseButton1Click:Connect(function()
            if #entry.Scripts == 1 then
                ScriptBox.Text = entry.Scripts[1].Source or "-- Script kosong"
            else
                -- kalau banyak, tampilkan semua gabungan
                local combined = {}
                for i, sc in ipairs(entry.Scripts) do
                    table.insert(combined, ("-- %d: %s\n%s\n"):format(i, sc.Name, sc.Source or "-- Script kosong"))
                end
                ScriptBox.Text = table.concat(combined, "\n")
            end
        end)
    end
end

-- ===== Tombol =====
RefreshBtn.MouseButton1Click:Connect(buildList)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- Build pertama
buildList()
