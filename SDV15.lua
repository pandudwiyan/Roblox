--// Scanner v7 (Players + Objects by Name) – Delta Executor
--// - Draggable (header), Close, Minimize (header only), Refresh
--// - Hanya BasePart (punya posisi)
--// - Players: Username | DisplayName, TP 12 stud di belakang
--// - Objects: dikelompokkan per Name, urut terbanyak, expand menampilkan SEMUA instance
--// - Spectate toggle fix (balik ke kamera normal saat dimatikan/refresh/close)

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ===== Clean up old =====
pcall(function()
    local pg = LocalPlayer:WaitForChild("PlayerGui")
    local old = pg:FindFirstChild("ScannerPanelV7")
    if old then old:Destroy() end
end)

-- ===== UI base =====
local WIDTH, HEIGHT = 320, 420
local HEADER_H = 32

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ScannerPanelV7"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, WIDTH, 0, HEIGHT)
Main.Position = UDim2.new(0.05, 0, 0.12, 0)
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
Title.Size = UDim2.new(1, -160, 1, 0)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Text = "Scanner v7"
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.TextColor3 = Color3.new(1,1,1)

local RefreshBtn = Instance.new("TextButton", Header)
RefreshBtn.Size = UDim2.new(0, 72, 1, 0)
RefreshBtn.Position = UDim2.new(1, -152, 0, 0)
RefreshBtn.BackgroundColor3 = Color3.fromRGB(0, 130, 0)
RefreshBtn.TextColor3 = Color3.new(1,1,1)
RefreshBtn.Text = "Refresh"
RefreshBtn.Font = Enum.Font.SourceSans
RefreshBtn.TextSize = 16

local MinBtn = Instance.new("TextButton", Header)
MinBtn.Size = UDim2.new(0, 40, 1, 0)
MinBtn.Position = UDim2.new(1, -80, 0, 0)
MinBtn.BackgroundTransparency = 1
MinBtn.Text = "-"
MinBtn.Font = Enum.Font.SourceSansBold
MinBtn.TextSize = 18
MinBtn.TextColor3 = Color3.fromRGB(255, 220, 90)

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 40, 1, 0)
CloseBtn.Position = UDim2.new(1, -40, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 18
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)

local Body = Instance.new("ScrollingFrame", Main)
Body.Size = UDim2.new(1, 0, 1, -HEADER_H)
Body.Position = UDim2.new(0, 0, 0, HEADER_H)
Body.BackgroundTransparency = 1
Body.ScrollBarThickness = 6
Body.AutomaticCanvasSize = Enum.AutomaticSize.Y
Body.CanvasSize = UDim2.new(0,0,0,0)

local BodyList = Instance.new("UIListLayout", Body)
BodyList.Padding = UDim.new(0, 6)
BodyList.SortOrder = Enum.SortOrder.LayoutOrder

-- ===== Drag (by header) =====
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

-- ===== Camera / movement helpers =====
local function getHRP(plr)
    local ch = plr.Character
    return ch and ch:FindFirstChild("HumanoidRootPart")
end

local function tpToPart(part)
    local hrp = getHRP(LocalPlayer)
    if hrp and part and part:IsA("BasePart") then
        hrp.CFrame = part.CFrame + Vector3.new(0,3,0)
    end
end

local function tpBehindPlayer(target)
    local my = getHRP(LocalPlayer)
    local th = getHRP(target)
    if my and th then
        my.CFrame = th.CFrame * CFrame.new(0,0,12) -- 12 stud di belakang
    end
end

local spectatingTarget = nil
local function stopSpectate()
    Camera.CameraType = Enum.CameraType.Custom
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then Camera.CameraSubject = hum end
    spectatingTarget = nil
end

local function toggleSpectate(target)
    if spectatingTarget == target then
        stopSpectate()
        return
    end
    if typeof(target) == "Instance" and target:IsA("Player") then
        local hum = target.Character and target.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            Camera.CameraType = Enum.CameraType.Custom
            Camera.CameraSubject = hum
            spectatingTarget = target
        end
    elseif typeof(target) == "Instance" and target:IsA("BasePart") then
        Camera.CameraType = Enum.CameraType.Attach
        Camera.CameraSubject = target
        spectatingTarget = target
    end
end

-- ===== UI builders =====
local function addCategory(titleText)
    local container = Instance.new("Frame")
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(1, -10, 0, 30)
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.Parent = Body

    local innerList = Instance.new("UIListLayout", container)
    innerList.Padding = UDim.new(0, 4)
    innerList.SortOrder = Enum.SortOrder.LayoutOrder

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 16
    btn.Text = titleText
    btn.Parent = container

    local holder = Instance.new("Frame")
    holder.BackgroundTransparency = 1
    holder.Size = UDim2.new(1, 0, 0, 0)
    holder.Visible = false
    holder.AutomaticSize = Enum.AutomaticSize.Y
    holder.Parent = container

    -- IMPORTANT: stack rows inside holder
    local rows = Instance.new("UIListLayout", holder)
    rows.Padding = UDim.new(0, 3)
    rows.SortOrder = Enum.SortOrder.LayoutOrder

    return btn, holder
end

local function addRow(parent, leftText, onTP, onSpec)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 26)
    row.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    row.Parent = parent

    local label = Instance.new("TextLabel", row)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Position = UDim2.new(0, 8, 0, 0)
    label.Size = UDim2.new(0.5, -8, 1, 0)
    label.Text = leftText
    label.Font = Enum.Font.SourceSans
    label.TextSize = 14
    label.TextColor3 = Color3.new(1,1,1)

    local tpBtn = Instance.new("TextButton", row)
    tpBtn.Size = UDim2.new(0.25, -4, 1, -6)
    tpBtn.Position = UDim2.new(0.5, 0, 0, 3)
    tpBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
    tpBtn.TextColor3 = Color3.new(1,1,1)
    tpBtn.Text = "Teleport"
    tpBtn.Font = Enum.Font.SourceSans
    tpBtn.TextSize = 14
    tpBtn.MouseButton1Click:Connect(onTP)

    local spBtn = Instance.new("TextButton", row)
    spBtn.Size = UDim2.new(0.25, -4, 1, -6)
    spBtn.Position = UDim2.new(0.75, 4, 0, 3)
    spBtn.BackgroundColor3 = Color3.fromRGB(0, 70, 160)
    spBtn.TextColor3 = Color3.new(1,1,1)
    spBtn.Text = "Spectate"
    spBtn.Font = Enum.Font.SourceSans
    spBtn.TextSize = 14
    spBtn.MouseButton1Click:Connect(onSpec)
end

-- ===== Scanning =====
local function scanPlayers()
    local list = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then table.insert(list, plr) end
    end
    return list
end

local function scanBasePartsByName()
    local buckets = {} -- name -> {parts}
    for _, inst in ipairs(Workspace:GetDescendants()) do
        if inst:IsA("BasePart") then
            local name = inst.Name
            if not buckets[name] then buckets[name] = {} end
            table.insert(buckets[name], inst)
        end
    end
    -- convert to array for sorting
    local arr = {}
    for n, list in pairs(buckets) do
        table.insert(arr, {Name = n, Items = list, Count = #list})
    end
    table.sort(arr, function(a,b)
        if a.Count == b.Count then
            return a.Name:lower() < b.Name:lower()
        end
        return a.Count > b.Count
    end)
    return arr
end

-- ===== Build / Refresh =====
local function buildList()
    -- clear
    for _, ch in ipairs(Body:GetChildren()) do
        if not ch:IsA("UIListLayout") then ch:Destroy() end
    end

    -- Players (always on top)
    local players = scanPlayers()
    local pBtn, pHolder = addCategory(("Players : %d"):format(#players))
    local pOpen = false
    pBtn.MouseButton1Click:Connect(function()
        pOpen = not pOpen
        pHolder.Visible = pOpen
    end)
    for _, plr in ipairs(players) do
        addRow(
            pHolder,
            (plr.Name .. " | " .. plr.DisplayName),
            function() tpBehindPlayer(plr) end,
            function() toggleSpectate(plr) end
        )
    end

    -- Objects grouped by Name (BasePart only)
    local groups = scanBasePartsByName()
    for _, g in ipairs(groups) do
        local label = ("%s : %d"):format(g.Name, g.Count)
        local oBtn, oHolder = addCategory(label)
        local open = false
        oBtn.MouseButton1Click:Connect(function()
            open = not open
            oHolder.Visible = open
        end)
        for i, part in ipairs(g.Items) do
            addRow(
                oHolder,
                ("%s [%s] #%d"):format(part.Name, part.ClassName, i),
                function() tpToPart(part) end,
                function() toggleSpectate(part) end
            )
        end
    end
end

-- Buttons
RefreshBtn.MouseButton1Click:Connect(function()
    stopSpectate()
    buildList()
end)

CloseBtn.MouseButton1Click:Connect(function()
    stopSpectate()
    ScreenGui:Destroy()
end)

local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        Body.Visible = false
        Main.Size = UDim2.new(0, WIDTH, 0, HEADER_H)
    else
        Main.Size = UDim2.new(0, WIDTH, 0, HEIGHT)
        Body.Visible = true
    end
end)

-- Build first time
buildList()
