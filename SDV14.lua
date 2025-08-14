--// Roblox Workspace & Player Scanner with GUI (v6)
--// Delta Executor Script

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local UIS = game:GetService("UserInputService")

-- Create ScreenGui
local gui = Instance.new("ScreenGui")
gui.Name = "ScannerGUI"
gui.ResetOnSpawn = false
gui.Parent = game.CoreGui

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 400)
mainFrame.Position = UDim2.new(0.3, 0, 0.3, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = gui

-- Header
local header = Instance.new("TextLabel")
header.Size = UDim2.new(1, -60, 0, 30)
header.Position = UDim2.new(0, 0, 0, 0)
header.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
header.Text = "Scanner v6"
header.TextColor3 = Color3.new(1, 1, 1)
header.TextSize = 18
header.Parent = mainFrame

-- Close Button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -30, 0, 0)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.new(1, 0, 0)
closeBtn.Parent = mainFrame

-- Minimize Button
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 30, 0, 30)
minBtn.Position = UDim2.new(1, -60, 0, 0)
minBtn.Text = "-"
minBtn.TextColor3 = Color3.new(1, 1, 0)
minBtn.Parent = mainFrame

-- Refresh Button
local refreshBtn = Instance.new("TextButton")
refreshBtn.Size = UDim2.new(1, 0, 0, 30)
refreshBtn.Position = UDim2.new(0, 0, 0, 30)
refreshBtn.Text = "Refresh"
refreshBtn.TextColor3 = Color3.new(0, 1, 0)
refreshBtn.Parent = mainFrame

-- Scroll Area
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, 0, 1, -60)
scroll.Position = UDim2.new(0, 0, 0, 60)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.ScrollBarThickness = 6
scroll.Parent = mainFrame

-- Function: Teleport
local function teleportTo(target)
    if not target then return end
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        if target:IsA("Model") and target.PrimaryPart then
            char:MoveTo(target.PrimaryPart.Position)
        elseif target:IsA("BasePart") then
            char:MoveTo(target.Position)
        end
    end
end

-- Function: Teleport behind player
local function teleportBehindPlayer(targetPlayer)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local targetPos = targetPlayer.Character.HumanoidRootPart.Position
        local lookVector = targetPlayer.Character.HumanoidRootPart.CFrame.LookVector
        local behindPos = targetPos - (lookVector * 12)
        char:MoveTo(behindPos)
    end
end

-- Function: Spectate
local spectatingTarget = nil
local function toggleSpectate(target)
    local camera = Workspace.CurrentCamera
    if spectatingTarget == target then
        -- Stop spectating
        spectatingTarget = nil
        camera.CameraType = Enum.CameraType.Custom
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            camera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        end
    else
        spectatingTarget = target
        camera.CameraType = Enum.CameraType.Attach
        if target:IsA("Model") and target.PrimaryPart then
            camera.CameraSubject = target.PrimaryPart
        elseif target:IsA("BasePart") then
            camera.CameraSubject = target
        elseif target:IsA("Player") and target.Character and target.Character:FindFirstChild("Humanoid") then
            camera.CameraSubject = target.Character.Humanoid
        end
    end
end

-- Function: Scan
local function scan()
    scroll:ClearAllChildren()
    local objects = {}
    local playersList = {}

    -- Workspace scan
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj:IsDescendantOf(Workspace) then
            local category = obj.Name
            objects[category] = objects[category] or {}
            table.insert(objects[category], obj)
        end
    end

    -- Player scan
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            table.insert(playersList, plr)
        end
    end

    local y = 0

    -- Players category
    if #playersList > 0 then
        local playerFrame = Instance.new("Frame")
        playerFrame.Size = UDim2.new(1, -6, 0, 30)
        playerFrame.Position = UDim2.new(0, 3, 0, y)
        playerFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        playerFrame.Parent = scroll

        local playerBtn = Instance.new("TextButton")
        playerBtn.Size = UDim2.new(1, 0, 1, 0)
        playerBtn.Text = "Players : " .. #playersList
        playerBtn.Parent = playerFrame

        local expanded = false
        local itemsFrame = Instance.new("Frame")
        itemsFrame.Size = UDim2.new(1, -10, 0, 0)
        itemsFrame.Position = UDim2.new(0, 5, 0, 30)
        itemsFrame.BackgroundTransparency = 1
        itemsFrame.Parent = scroll

        playerBtn.MouseButton1Click:Connect(function()
            expanded = not expanded
            itemsFrame:ClearAllChildren()
            if expanded then
                local yy = 0
                for _, plr in ipairs(playersList) do
                    local item = Instance.new("Frame")
                    item.Size = UDim2.new(1, 0, 0, 25)
                    item.Position = UDim2.new(0, 0, 0, yy)
                    item.BackgroundTransparency = 1
                    item.Parent = itemsFrame

                    local label = Instance.new("TextLabel")
                    label.Size = UDim2.new(0.5, 0, 1, 0)
                    label.Text = plr.Name .. " | " .. plr.DisplayName
                    label.BackgroundTransparency = 1
                    label.TextXAlignment = Enum.TextXAlignment.Left
                    label.Parent = item

                    local tpBtn = Instance.new("TextButton")
                    tpBtn.Size = UDim2.new(0.25, -2, 1, 0)
                    tpBtn.Position = UDim2.new(0.5, 0, 0, 0)
                    tpBtn.Text = "Teleport"
                    tpBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
                    tpBtn.TextColor3 = Color3.new(1, 1, 1)
                    tpBtn.Parent = item
                    tpBtn.MouseButton1Click:Connect(function()
                        teleportBehindPlayer(plr)
                    end)

                    local spBtn = Instance.new("TextButton")
                    spBtn.Size = UDim2.new(0.25, -2, 1, 0)
                    spBtn.Position = UDim2.new(0.75, 2, 0, 0)
                    spBtn.Text = "Spectate"
                    spBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
                    spBtn.TextColor3 = Color3.new(1, 1, 1)
                    spBtn.Parent = item
                    spBtn.MouseButton1Click:Connect(function()
                        toggleSpectate(plr)
                    end)

                    yy = yy + 25
                end
                itemsFrame.Size = UDim2.new(1, -10, 0, yy)
            else
                itemsFrame.Size = UDim2.new(1, -10, 0, 0)
            end
        end)

        y = y + 30 + itemsFrame.Size.Y.Offset
    end

    -- Objects category
    for category, list in pairs(objects) do
        local catFrame = Instance.new("Frame")
        catFrame.Size = UDim2.new(1, -6, 0, 30)
        catFrame.Position = UDim2.new(0, 3, 0, y)
        catFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        catFrame.Parent = scroll

        local catBtn = Instance.new("TextButton")
        catBtn.Size = UDim2.new(1, 0, 1, 0)
        catBtn.Text = category .. " : " .. #list
        catBtn.Parent = catFrame

        local expanded = false
        local itemsFrame = Instance.new("Frame")
        itemsFrame.Size = UDim2.new(1, -10, 0, 0)
        itemsFrame.Position = UDim2.new(0, 5, 0, y + 30)
        itemsFrame.BackgroundTransparency = 1
        itemsFrame.Parent = scroll

        catBtn.MouseButton1Click:Connect(function()
            expanded = not expanded
            itemsFrame:ClearAllChildren()
            if expanded then
                local yy = 0
                for _, obj in ipairs(list) do
                    local item = Instance.new("Frame")
                    item.Size = UDim2.new(1, 0, 0, 25)
                    item.Position = UDim2.new(0, 0, 0, yy)
                    item.BackgroundTransparency = 1
                    item.Parent = itemsFrame

                    local label = Instance.new("TextLabel")
                    label.Size = UDim2.new(0.5, 0, 1, 0)
                    label.Text = obj.Name
                    label.BackgroundTransparency = 1
                    label.TextXAlignment = Enum.TextXAlignment.Left
                    label.Parent = item

                    local tpBtn = Instance.new("TextButton")
                    tpBtn.Size = UDim2.new(0.25, -2, 1, 0)
                    tpBtn.Position = UDim2.new(0.5, 0, 0, 0)
                    tpBtn.Text = "Teleport"
                    tpBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
                    tpBtn.TextColor3 = Color3.new(1, 1, 1)
                    tpBtn.Parent = item
                    tpBtn.MouseButton1Click:Connect(function()
                        teleportTo(obj)
                    end)

                    local spBtn = Instance.new("TextButton")
                    spBtn.Size = UDim2.new(0.25, -2, 1, 0)
                    spBtn.Position = UDim2.new(0.75, 2, 0, 0)
                    spBtn.Text = "Spectate"
                    spBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
                    spBtn.TextColor3 = Color3.new(1, 1, 1)
                    spBtn.Parent = item
                    spBtn.MouseButton1Click:Connect(function()
                        toggleSpectate(obj)
                    end)

                    yy = yy + 25
                end
                itemsFrame.Size = UDim2.new(1, -10, 0, yy)
            else
                itemsFrame.Size = UDim2.new(1, -10, 0, 0)
            end
        end)

        y = y + 30 + itemsFrame.Size.Y.Offset
    end

    scroll.CanvasSize = UDim2.new(0, 0, 0, y + 20)
end

-- Refresh click
refreshBtn.MouseButton1Click:Connect(scan)

-- Close click
closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- Minimize click
local minimized = false
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        scroll.Visible = false
        refreshBtn.Visible = false
        mainFrame.Size = UDim2.new(0, 300, 0, 30)
    else
        scroll.Visible = true
        refreshBtn.Visible = true
        mainFrame.Size = UDim2.new(0, 300, 0, 400)
    end
end)

-- First scan
scan()
