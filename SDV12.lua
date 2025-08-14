--// Roblox Delta Executor Script - Object & Player Scanner (Final v4)
--// By ChatGPT

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local UIS = game:GetService("UserInputService")
local camera = Workspace.CurrentCamera

-- Settings
local PANEL_WIDTH, PANEL_HEIGHT = 300, 400
local HEADER_HEIGHT = 30
local MINIMIZED_HEIGHT = HEADER_HEIGHT
local SPACING = 2

local spectating = false
local spectateTarget = nil

-- Destroy old GUI
if game.CoreGui:FindFirstChild("ScanPanel") then
    game.CoreGui.ScanPanel:Destroy()
end

-- Create GUI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "ScanPanel"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, PANEL_WIDTH, 0, PANEL_HEIGHT)
MainFrame.Position = UDim2.new(0.05, 0, 0.1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true

-- Dragging
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.Touch then
		dragging = true
		dragStart = input.Position
		startPos = MainFrame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)
MainFrame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)
UIS.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- Header
local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, HEADER_HEIGHT)
Header.BackgroundColor3 = Color3.fromRGB(25, 25, 25)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(0.6, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "Workspace Scanner"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Position = UDim2.new(0.02, 0, 0, 0)

-- Close Button
local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 40, 1, 0)
CloseBtn.Position = UDim2.new(1, -40, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.Text = "X"
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 18
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Minimize Button
local MinBtn = Instance.new("TextButton", Header)
MinBtn.Size = UDim2.new(0, 40, 1, 0)
MinBtn.Position = UDim2.new(1, -80, 0, 0)
MinBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 0)
MinBtn.TextColor3 = Color3.new(1, 1, 1)
MinBtn.Text = "-"
MinBtn.Font = Enum.Font.SourceSansBold
MinBtn.TextSize = 18

local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        MainFrame.Size = UDim2.new(0, PANEL_WIDTH, 0, MINIMIZED_HEIGHT)
    else
        MainFrame.Size = UDim2.new(0, PANEL_WIDTH, 0, PANEL_HEIGHT)
    end
end)

-- Refresh Button
local RefreshBtn = Instance.new("TextButton", Header)
RefreshBtn.Size = UDim2.new(0, 60, 1, 0)
RefreshBtn.Position = UDim2.new(1, -140, 0, 0)
RefreshBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
RefreshBtn.TextColor3 = Color3.new(1, 1, 1)
RefreshBtn.Text = "Refresh"
RefreshBtn.Font = Enum.Font.SourceSans
RefreshBtn.TextSize = 14

-- Scrolling Content
local Scrolling = Instance.new("ScrollingFrame", MainFrame)
Scrolling.Size = UDim2.new(1, 0, 1, -HEADER_HEIGHT)
Scrolling.Position = UDim2.new(0, 0, 0, HEADER_HEIGHT)
Scrolling.CanvasSize = UDim2.new(0, 0, 0, 0)
Scrolling.ScrollBarThickness = 6
Scrolling.BackgroundTransparency = 1
Scrolling.AutomaticCanvasSize = Enum.AutomaticSize.Y

-- Teleport
local function teleportTo(obj)
    if obj and obj:IsA("BasePart") then
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = obj.CFrame + Vector3.new(0, 3, 0)
        end
    end
end

-- Teleport to player (12 studs behind)
local function teleportBehindPlayer(targetPlayer)
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local targetHRP = targetPlayer.Character.HumanoidRootPart
        if hrp then
            local backPos = targetHRP.CFrame * CFrame.new(0, 0, 12)
            hrp.CFrame = backPos
        end
    end
end

-- Spectate toggle
local function toggleSpectate(target)
    if spectating and spectateTarget == target then
        camera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        spectating = false
        spectateTarget = nil
    else
        if target:IsA("Player") then
            if target.Character and target.Character:FindFirstChild("Humanoid") then
                camera.CameraSubject = target.Character:FindFirstChild("Humanoid")
                spectating = true
                spectateTarget = target
            end
        elseif target:IsA("BasePart") then
            camera.CameraType = Enum.CameraType.Attach
            camera.CameraSubject = target
            spectating = true
            spectateTarget = target
        end
    end
end

-- Scan function
local function scanObjects()
    local counts = {}
    local objects = {}

    -- Workspace scan
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("MeshPart") or obj:IsA("UnionOperation") then
            local name = obj.Name
            counts[name] = (counts[name] or 0) + 1
            objects[name] = objects[name] or {}
            table.insert(objects[name], obj)
        end
    end

    -- Player scan
    local playerCategory = "Players"
    counts[playerCategory] = 0
    objects[playerCategory] = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            counts[playerCategory] = counts[playerCategory] + 1
            table.insert(objects[playerCategory], plr)
        end
    end

    return counts, objects
end

-- Build UI list
local function buildList()
    Scrolling:ClearAllChildren()

    local counts, objects = scanObjects()
    local sortedCategories = {}
    for cname, count in pairs(counts) do
        table.insert(sortedCategories, {Name = cname, Count = count})
    end
    table.sort(sortedCategories, function(a, b) return a.Count > b.Count end)

    for _, category in ipairs(sortedCategories) do
        local cname = category.Name
        local count = category.Count

        local container = Instance.new("Frame", Scrolling)
        container.Size = UDim2.new(1, -10, 0, HEADER_HEIGHT)
        container.BackgroundTransparency = 1
        container.AutomaticSize = Enum.AutomaticSize.Y

        local catButton = Instance.new("TextButton", container)
        catButton.Size = UDim2.new(1, 0, 0, HEADER_HEIGHT)
        catButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        catButton.TextColor3 = Color3.new(1, 1, 1)
        catButton.Font = Enum.Font.SourceSans
        catButton.TextSize = 16
        catButton.Text = cname .. " : " .. count

        local expanded = false
        local itemFrames = Instance.new("Frame", container)
        itemFrames.Size = UDim2.new(1, 0, 0, 0)
        itemFrames.Position = UDim2.new(0, 0, 0, HEADER_HEIGHT)
        itemFrames.BackgroundTransparency = 1
        itemFrames.Visible = false
        itemFrames.AutomaticSize = Enum.AutomaticSize.Y

        catButton.MouseButton1Click:Connect(function()
            expanded = not expanded
            itemFrames.Visible = expanded
        end)

        for i, obj in ipairs(objects[cname]) do
            local itemFrame = Instance.new("Frame", itemFrames)
            itemFrame.Size = UDim2.new(1, -10, 0, HEADER_HEIGHT)
            itemFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)

            local itemLabel = Instance.new("TextLabel", itemFrame)
            itemLabel.Size = UDim2.new(0.4, 0, 1, 0)
            itemLabel.BackgroundTransparency = 1
            itemLabel.TextColor3 = Color3.new(1, 1, 1)
            itemLabel.Font = Enum.Font.SourceSans
            itemLabel.TextSize = 14
            if cname == "Players" and obj:IsA("Player") then
                itemLabel.Text = obj.Name .. " | " .. obj.DisplayName
            else
                itemLabel.Text = cname .. " " .. i
            end

            local tpBtn = Instance.new("TextButton", itemFrame)
            tpBtn.Size = UDim2.new(0.3, 0, 1, 0)
            tpBtn.Position = UDim2.new(0.4, 0, 0, 0)
            tpBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
            tpBtn.TextColor3 = Color3.new(1, 1, 1)
            tpBtn.Text = "Teleport"
            tpBtn.MouseButton1Click:Connect(function()
                if cname == "Players" and obj:IsA("Player") then
                    teleportBehindPlayer(obj)
                else
                    teleportTo(obj)
                end
            end)

            local spBtn = Instance.new("TextButton", itemFrame)
            spBtn.Size = UDim2.new(0.3, 0, 1, 0)
            spBtn.Position = UDim2.new(0.7, 0, 0, 0)
            spBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 100)
            spBtn.TextColor3 = Color3.new(1, 1, 1)
            spBtn.Text = "Spectate"
            spBtn.MouseButton1Click:Connect(function()
                toggleSpectate(obj)
            end)
        end
    end
end

-- Refresh function
RefreshBtn.MouseButton1Click:Connect(function()
    buildList()
end)

-- First build
buildList()
