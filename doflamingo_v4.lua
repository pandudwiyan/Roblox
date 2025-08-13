-- Vars
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 250, 0, 300)
main.Position = UDim2.new(0.5, -125, 0.5, -150)
main.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
main.Parent = ScreenGui
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)

-- Dropdown button
local dropdownBtn = Instance.new("TextButton", main)
dropdownBtn.Size = UDim2.new(1, -20, 0, 30)
dropdownBtn.Position = UDim2.new(0, 10, 0, 10)
dropdownBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
dropdownBtn.TextColor3 = Color3.new(1, 1, 1)
dropdownBtn.Text = "Select Player"
dropdownBtn.Font = Enum.Font.SourceSansBold
dropdownBtn.TextSize = 14
Instance.new("UICorner", dropdownBtn).CornerRadius = UDim.new(0, 6)

-- Search box
local searchBox = Instance.new("TextBox", main)
searchBox.Size = UDim2.new(1, -20, 0, 25)
searchBox.Position = UDim2.new(0, 10, 0, 45)
searchBox.PlaceholderText = "Search..."
searchBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
searchBox.TextColor3 = Color3.new(1, 1, 1)
searchBox.ClearTextOnFocus = false
searchBox.Visible = false
Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0, 6)

-- Dropdown frame
local dropdownFrame = Instance.new("Frame", main)
dropdownFrame.Size = UDim2.new(1, -20, 0, 120)
dropdownFrame.Position = UDim2.new(0, 10, 0, 75)
dropdownFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
dropdownFrame.Visible = false
Instance.new("UICorner", dropdownFrame).CornerRadius = UDim.new(0, 6)

local listLayout = Instance.new("UIListLayout", dropdownFrame)
listLayout.Padding = UDim.new(0, 2)
listLayout.FillDirection = Enum.FillDirection.Vertical
listLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Action buttons frame
local actionFrame = Instance.new("Frame", main)
actionFrame.Size = UDim2.new(1, -20, 0, 150)
actionFrame.Position = UDim2.new(0, 10, 0, 200)
actionFrame.BackgroundTransparency = 1

-- Function make button
local function makeButton(text, color, yOffset, callback)
    local btn = Instance.new("TextButton", actionFrame)
    btn.Size = UDim2.new(1, 0, 0, 28)
    btn.Position = UDim2.new(0, 0, 0, yOffset)
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSansBold
    btn.Text = text
    btn.TextSize = 14
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(callback)
end

-- Selected target
local currentTarget = nil

-- Refresh player list
local function refreshPlayerList(filter)
    dropdownFrame:ClearAllChildren()
    listLayout.Parent = dropdownFrame

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LP and (not filter or filter == "" or string.find(plr.Name:lower(), filter:lower()) or string.find(plr.DisplayName:lower(), filter:lower())) then
            local btn = Instance.new("TextButton", dropdownFrame)
            btn.Size = UDim2.new(1, 0, 0, 24)
            btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
            btn.TextColor3 = Color3.new(1, 1, 1)
            btn.Font = Enum.Font.SourceSans
            btn.TextSize = 14
            btn.Text = plr.DisplayName .. " | " .. plr.Name
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

            btn.MouseButton1Click:Connect(function()
                currentTarget = plr
                dropdownBtn.Text = plr.DisplayName .. " | " .. plr.Name
                dropdownFrame.Visible = false
                searchBox.Visible = false
            end)
        end
    end
end

-- Dropdown toggle
dropdownBtn.MouseButton1Click:Connect(function()
    dropdownFrame.Visible = not dropdownFrame.Visible
    searchBox.Visible = dropdownFrame.Visible
    if dropdownFrame.Visible then
        refreshPlayerList(searchBox.Text)
    end
end)

-- Search update
searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    refreshPlayerList(searchBox.Text)
end)

-- ACTIONS
makeButton("Teleport", Color3.fromRGB(100, 100, 255), 0, function()
    if currentTarget and currentTarget.Character and LP.Character then
        local myPos = LP.Character:FindFirstChild("HumanoidRootPart")
        local targetPos = currentTarget.Character:FindFirstChild("HumanoidRootPart")
        if myPos and targetPos then
            myPos.CFrame = targetPos.CFrame
        end
    end
end)

makeButton("Quick Teleport", Color3.fromRGB(0, 150, 255), 35, function()
    if currentTarget and currentTarget.Character and LP.Character then
        local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
        local targetHrp = currentTarget.Character:FindFirstChild("HumanoidRootPart")
        if hrp and targetHrp then
            hrp.CFrame = targetHrp.CFrame
        end
    end
end)

makeButton("Change", Color3.fromRGB(0, 120, 215), 70, function()
    if currentTarget and currentTarget.Character and LP.Character then
        local myPos = LP.Character:FindFirstChild("HumanoidRootPart")
        local targetPos = currentTarget.Character:FindFirstChild("HumanoidRootPart")
        if myPos and targetPos then
            local temp = myPos.CFrame
            myPos.CFrame = targetPos.CFrame
            targetPos.CFrame = temp
        end
    end
end)

makeButton("Summon", Color3.fromRGB(200, 50, 50), 105, function()
    if currentTarget and currentTarget.Character and LP.Character then
        local myPos = LP.Character:FindFirstChild("HumanoidRootPart")
        local targetPos = currentTarget.Character:FindFirstChild("HumanoidRootPart")
        if myPos and targetPos then
            targetPos.CFrame = myPos.CFrame * CFrame.new(0, 0, -5)
        end
    end
end)
