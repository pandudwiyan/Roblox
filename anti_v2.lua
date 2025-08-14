-- Player Teleporter Simple Navigation UI v1.1 (with AntiGrav)
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Camera = workspace.CurrentCamera

-- Parent ke PlayerGui supaya nempel di layar
local gui = Instance.new("ScreenGui")
gui.Name = "PlayerTeleporterNav"
gui.ResetOnSpawn = false
gui.Parent = LP:WaitForChild("PlayerGui")

-- Variabel target list
local targetList = {}
local currentIndex = 1
local currentTarget = nil

-- AntiGrav
local antiGravActive = false
local antiGravHeight = nil
local antiGravConnection = nil

-- Ambil semua player lain
local function refreshTargetList()
    targetList = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            table.insert(targetList, plr)
        end
    end
end
refreshTargetList()

Players.PlayerAdded:Connect(refreshTargetList)
Players.PlayerRemoving:Connect(refreshTargetList)

-- UI Frame
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 300, 0, 100)
main.Position = UDim2.new(0.35, 0, 0.7, 0)
main.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
main.BackgroundTransparency = 0.3
main.BorderSizePixel = 2
main.BorderColor3 = Color3.fromRGB(255, 255, 255)
main.Parent = gui
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = main

-- Draggable system
do
    local dragging = false
    local dragStart, startPos

    local function updateDrag(input)
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                  startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
        end
    end)

    main.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateDrag(input)
        end
    end)
end

-- Tombol Prev
local prevBtn = Instance.new("TextButton")
prevBtn.Size = UDim2.new(0, 30, 0, 30)
prevBtn.Position = UDim2.new(0, 5, 0, 10)
prevBtn.Text = "<"
prevBtn.Parent = main

-- Label nama
local nameLabel = Instance.new("TextLabel")
nameLabel.Size = UDim2.new(1, -70, 0, 30)
nameLabel.Position = UDim2.new(0, 35, 0, 10)
nameLabel.Text = "USERNAME | NICKNAME"
nameLabel.TextColor3 = Color3.new(1, 1, 1)
nameLabel.BackgroundTransparency = 1
nameLabel.Font = Enum.Font.SourceSansBold
nameLabel.TextSize = 16
nameLabel.Parent = main

-- Tombol Next
local nextBtn = Instance.new("TextButton")
nextBtn.Size = UDim2.new(0, 30, 0, 30)
nextBtn.Position = UDim2.new(1, -35, 0, 10)
nextBtn.Text = ">"
nextBtn.Parent = main

-- Tombol Teleport
local tpBtn = Instance.new("TextButton")
tpBtn.Size = UDim2.new(0.3, -10, 0, 30)
tpBtn.Position = UDim2.new(0, 5, 0, 60)
tpBtn.Text = "Teleport"
tpBtn.Parent = main

-- Tombol Quick
local quickBtn = Instance.new("TextButton")
quickBtn.Size = UDim2.new(0.3, -10, 0, 30)
quickBtn.Position = UDim2.new(0.35, 0, 0, 60)
quickBtn.Text = "Quick"
quickBtn.Parent = main

-- Tombol AntiGrav
local antiBtn = Instance.new("TextButton")
antiBtn.Size = UDim2.new(0.3, -10, 0, 30)
antiBtn.Position = UDim2.new(0.7, 0, 0, 60)
antiBtn.Text = "AntiGrav OFF"
antiBtn.Parent = main

-- Fungsi update target
local function updateTarget()
    if #targetList == 0 then
        nameLabel.Text = "No Players"
        currentTarget = nil
        return
    end
    if currentIndex > #targetList then currentIndex = 1 end
    if currentIndex < 1 then currentIndex = #targetList end

    currentTarget = targetList[currentIndex]
    nameLabel.Text = currentTarget.Name .. " | " .. currentTarget.DisplayName

    -- Kamera ke target
    if currentTarget and currentTarget.Character then
        local hum = currentTarget.Character:FindFirstChild("Humanoid")
        if hum then
            Camera.CameraSubject = hum
        end
    end
end

-- Fungsi teleport di belakang target
local function teleportBehind(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if targetHRP and myHRP then
        local behind = targetHRP.CFrame * CFrame.new(0, 0, 9)
        myChar:PivotTo(behind)
    end
end

-- Fungsi quick teleport
local function quickTeleport()
    local myChar = LP.Character
    if not myChar then return end
    local myHRP = myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end
    local nearest, minDist = nil, math.huge
    local forward = myHRP.CFrame.LookVector
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local dir = (hrp.Position - myHRP.Position).Unit
                local dot = forward:Dot(dir)
                if dot > 0 then
                    local dist = (hrp.Position - myHRP.Position).Magnitude
                    if dist < minDist then
                        minDist = dist
                        nearest = plr
                    end
                end
            end
        end
    end
    if nearest then
        teleportBehind(nearest)
    end
end

-- Toggle AntiGrav (versi berhenti di 50% tinggi loncatan)
local function toggleAntiGrav()
    antiGravActive = not antiGravActive

    local hum = LP.Character and LP.Character:FindFirstChild("Humanoid")
    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")

    if antiGravActive then
        antiBtn.Text = "AntiGrav ON"

        local startHeight = nil
        local peakHeight = nil
        local falling = false

        if hum and hrp then
            -- Saat loncat
            hum:GetPropertyChangedSignal("Jump"):Connect(function()
                if hum.Jump then
                    startHeight = hrp.Position.Y
                    peakHeight = startHeight
                    falling = false
                end
            end)

            -- Pantau posisi tiap frame
            antiGravConnection = RunService.Heartbeat:Connect(function()
                if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                    local yPos = hrp.Position.Y

                    -- Update puncak tertinggi
                    if startHeight then
                        if yPos > peakHeight then
                            peakHeight = yPos
                        elseif yPos < peakHeight then
                            -- Mulai turun
                            falling = true
                        end

                        -- Hitung batas berhenti
                        if falling then
                            local stopY = startHeight + ((peakHeight - startHeight) * 0.5)
                            if yPos < stopY then
                                hrp.CFrame = CFrame.new(hrp.Position.X, stopY, hrp.Position.Z)
                                startHeight = stopY
                                peakHeight = stopY
                                falling = false
                            end
                        end
                    end
                end
            end)
        end

    else
        antiBtn.Text = "AntiGrav OFF"
        if antiGravConnection then
            antiGravConnection:Disconnect()
            antiGravConnection = nil
        end
    end
end




-- Button event
prevBtn.MouseButton1Click:Connect(function()
    currentIndex -= 1
    updateTarget()
end)
nextBtn.MouseButton1Click:Connect(function()
    currentIndex += 1
    updateTarget()
end)
tpBtn.MouseButton1Click:Connect(function()
    if currentTarget then
        teleportBehind(currentTarget)
    end
end)
quickBtn.MouseButton1Click:Connect(quickTeleport)
antiBtn.MouseButton1Click:Connect(toggleAntiGrav)

-- Reset kamera ke player sendiri jika gerak
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        local key = input.KeyCode
        if key == Enum.KeyCode.W or key == Enum.KeyCode.A or key == Enum.KeyCode.S or
           key == Enum.KeyCode.D or key == Enum.KeyCode.Space then
            local hum = LP.Character and LP.Character:FindFirstChild("Humanoid")
            if hum then
                Camera.CameraSubject = hum
            end
        end
    elseif input.UserInputType == Enum.UserInputType.Gamepad1 then
        local hum = LP.Character and LP.Character:FindFirstChild("Humanoid")
        if hum then
            Camera.CameraSubject = hum
        end
    end
end)

-- Set target awal
updateTarget()
