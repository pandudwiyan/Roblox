-- Floating Tools UI (PC + Mobile) - Ghost Sphere Rev 8 (Player List Added)
-- Fitur: Vision, Jump, Ghost, Teleport/Marking Coordinate, Minimize UI, Player List (TP/Spectate)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-------------------------------------------------
-- GUI
-------------------------------------------------

local gui = Instance.new("ScreenGui")
gui.Name = "ToolsUI"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local panel = Instance.new("Frame")
panel.Size = UDim2.new(0,250,0,95) 
panel.Position = UDim2.new(0.05,0,0.7,0)
panel.BackgroundColor3 = Color3.fromRGB(0,0,0)
panel.BackgroundTransparency = 0.3
panel.Active = true
panel.Parent = gui

Instance.new("UICorner",panel).CornerRadius = UDim.new(0,8)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -30, 0, 20)
title.Position = UDim2.new(0, 5, 0, 3)
title.BackgroundTransparency = 1
title.Text = "SKIZOO"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.SourceSansBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextSize = 14
title.Parent = panel

-- Tombol Minimize
local minBtn = Instance.new("TextButton")
minBtn.Name = "MinimizeBtn"
minBtn.Size = UDim2.new(0, 20, 0, 20)
minBtn.Position = UDim2.new(1, -25, 0, 3)
minBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
minBtn.TextColor3 = Color3.new(1,1,1)
minBtn.Font = Enum.Font.SourceSansBold
minBtn.TextSize = 16
minBtn.Text = "-"
minBtn.Parent = panel
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 4)

-------------------------------------------------
-- BUTTON CREATOR
-------------------------------------------------

local function createButton(text,x,y)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,70,0,28)
    btn.Position = UDim2.new(0,x,0,y or 28)
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(120,120,120)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 14
    btn.Parent = panel
    Instance.new("UICorner",btn).CornerRadius = UDim.new(0,6)
    return btn
end

-- Baris 1
local visionBtn = createButton("Vision",10)
local jumpBtn = createButton("Jump",90)
local ghostBtn = createButton("Ghost",170)

-- Baris 2 (Layout Dimodifikasi: Player, Marking, Teleport)
local playerListBtn = createButton("Player", 10, 60) -- Tombol Baru
playerListBtn.Size = UDim2.new(0, 60, 0, 28)
playerListBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)

local markingBtn = createButton("Marking", 75, 60) -- Posisi digeser
markingBtn.Size = UDim2.new(0, 80, 0, 28)
markingBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 150)

local tpMarkBtn = createButton("Teleport", 160, 60) -- Posisi digeser
tpMarkBtn.Size = UDim2.new(0, 80, 0, 28)
tpMarkBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 150)

-------------------------------------------------
-- PLAYER LIST GUI (NEW)
-------------------------------------------------

local playerListPanel = Instance.new("Frame")
playerListPanel.Name = "PlayerListPanel"
playerListPanel.Size = UDim2.new(0, 500, 0, 300)
playerListPanel.Position = UDim2.new(0.3, 0, 0.3, 0)
playerListPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
playerListPanel.BackgroundTransparency = 0.1
playerListPanel.Active = true
playerListPanel.Visible = false -- Awalnya tersembunyi
playerListPanel.Parent = gui

Instance.new("UICorner", playerListPanel).CornerRadius = UDim.new(0, 8)

-- Header Player List
local plTitle = Instance.new("TextLabel")
plTitle.Size = UDim2.new(1, -30, 0, 25)
plTitle.Position = UDim2.new(0, 5, 0, 3)
plTitle.BackgroundTransparency = 1
plTitle.Text = "Player List"
plTitle.TextColor3 = Color3.new(1,1,1)
plTitle.Font = Enum.Font.SourceSansBold
plTitle.TextXAlignment = Enum.TextXAlignment.Left
plTitle.TextSize = 16
plTitle.Parent = playerListPanel

-- Tombol Minimize Player List
local plMinBtn = Instance.new("TextButton")
plMinBtn.Size = UDim2.new(0, 20, 0, 20)
plMinBtn.Position = UDim2.new(1, -25, 0, 3)
plMinBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
plMinBtn.TextColor3 = Color3.new(1,1,1)
plMinBtn.Font = Enum.Font.SourceSansBold
plMinBtn.TextSize = 16
plMinBtn.Text = "-"
plMinBtn.Parent = playerListPanel
Instance.new("UICorner", plMinBtn).CornerRadius = UDim.new(0, 4)

-- Container untuk Header & Konten
local listContainer = Instance.new("Frame")
listContainer.Size = UDim2.new(1, -10, 1, -35)
listContainer.Position = UDim2.new(0, 5, 0, 30)
listContainer.BackgroundTransparency = 1
listContainer.Parent = playerListPanel

-- Header Kolom
local headerFrame = Instance.new("Frame")
headerFrame.Size = UDim2.new(1, 0, 0, 25)
headerFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
headerFrame.Parent = listContainer
Instance.new("UICorner", headerFrame).CornerRadius = UDim.new(0, 4)

local headers = {"No", "Name", "NickName", "Distance", "TP", "Cam"}
local widths = {30, 120, 120, 80, 60, 60} -- Total 470, sisanya padding
local xPos = 5
for i, h in ipairs(headers) do
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, widths[i], 1, 0)
    lbl.Position = UDim2.new(0, xPos, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = h
    lbl.TextColor3 = Color3.new(1,1,1)
    lbl.Font = Enum.Font.SourceSansBold
    lbl.TextSize = 14
    lbl.Parent = headerFrame
    xPos = xPos + widths[i]
end

-- Scrolling Frame untuk List Pemain
local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Size = UDim2.new(1, 0, 1, -30)
scrollingFrame.Position = UDim2.new(0, 0, 0, 30)
scrollingFrame.BackgroundTransparency = 1
scrollingFrame.ScrollBarThickness = 4
scrollingFrame.Parent = listContainer

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = scrollingFrame

-------------------------------------------------
-- SELECTION MENU (Object Selector)
-------------------------------------------------

local menu = Instance.new("Frame")
menu.Size = UDim2.new(0,150,0,140) 
menu.BackgroundColor3 = Color3.fromRGB(40,40,40)
menu.Visible = false
menu.Parent = gui

Instance.new("UICorner",menu).CornerRadius = UDim.new(0,8)

local function createMenuButton(text,y,color)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0,130,0,25)
    b.Position = UDim2.new(0,10,0,y)
    b.Text = text
    b.BackgroundColor3 = color
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.SourceSans
    b.TextSize = 14
    b.Parent = menu
    Instance.new("UICorner",b).CornerRadius = UDim.new(0,6)
    return b
end

local bringBtn = createMenuButton("Bring",10,Color3.fromRGB(0,120,215))
local teleportBtn = createMenuButton("Teleport",40,Color3.fromRGB(0,170,0))
local markBtn = createMenuButton("Mark",70,Color3.fromRGB(100, 0, 150))
local deleteBtn = createMenuButton("Delete",100,Color3.fromRGB(255, 0, 0))

-------------------------------------------------
-- VARIABLES
-------------------------------------------------

local selectedObject
local selectedOriginalColor
local broughtObjects = {}
local lastClick = 0
local lastObject
local originalTransparency = {}
local originalColors = {}
local objectLabels = {}

-- Variabel Ghost
local ghostSphere = nil
local ghostConnections = {}
local mobileControls = nil

-- Variabel Mark & Teleport
local markedCFrame = nil 
local tempMarkCFrame = nil 
local isUndoMode = false 
local undoThread = nil 

-- Variabel Player List
local spectatingPlayer = nil
local spectatingConnection = nil
local playerRows = {}

-------------------------------------------------
-- FITUR MINIMIZE
-------------------------------------------------

local isMinimized = false
local originalSize = panel.Size

minBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        panel.Size = UDim2.new(0, 250, 0, 30)
        minBtn.Text = "+"
        visionBtn.Visible = false
        jumpBtn.Visible = false
        ghostBtn.Visible = false
        markingBtn.Visible = false
        tpMarkBtn.Visible = false
        playerListBtn.Visible = false
    else
        panel.Size = originalSize
        minBtn.Text = "-"
        visionBtn.Visible = true
        jumpBtn.Visible = true
        ghostBtn.Visible = true
        markingBtn.Visible = true
        tpMarkBtn.Visible = true
        playerListBtn.Visible = true
    end
end)

-------------------------------------------------
-- BUTTON TOGGLE
-------------------------------------------------

local function toggle(btn)
    local on = not btn:GetAttribute("Active")
    btn:SetAttribute("Active",on)
    btn.BackgroundColor3 =
        on and Color3.fromRGB(0,200,0)
        or Color3.fromRGB(120,120,120)
    return on
end

-------------------------------------------------
-- DRAG UI (General Function)
-------------------------------------------------

local function makeDraggable(frame)
    local dragging
    local dragStart
    local startPos

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)

    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

makeDraggable(panel)
makeDraggable(playerListPanel)

-------------------------------------------------
-- INFINITE JUMP
-------------------------------------------------

local function setupJump(char)
    local hum = char:WaitForChild("Humanoid")
    UserInputService.JumpRequest:Connect(function()
        if jumpBtn:GetAttribute("Active") then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end

-------------------------------------------------
-- GHOST SPHERE FEATURE
-------------------------------------------------

local function createMobileControls()
    local frame = Instance.new("Frame")
    frame.Name = "MobileGhostControls"
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.Parent = gui

    local function mBtn(text, size, pos)
        local b = Instance.new("TextButton")
        b.Text = text
        b.Size = size
        b.Position = pos
        b.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        b.BackgroundTransparency = 0.4
        b.TextColor3 = Color3.new(1,1,1)
        b.TextSize = 24 
        b.Font = Enum.Font.SourceSansBold
        b.BorderSizePixel = 0
        b.Parent = frame
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)
        return b
    end

    local btnSize = UDim2.new(0, 45, 0, 45)

    local fwd = mBtn("▲", btnSize, UDim2.new(0, 60, 1, -140))
    local lft = mBtn("◄", btnSize, UDim2.new(0, 20, 1, -100))
    local rgt = mBtn("►", btnSize, UDim2.new(0, 100, 1, -100))
    local bck = mBtn("▼", btnSize, UDim2.new(0, 60, 1, -60))

    local upB = mBtn("UP", btnSize, UDim2.new(1, -145, 1, -105))
    local dnB = mBtn("DN", btnSize, UDim2.new(1, -145, 1, -60))

    return {
        Frame = frame,
        Fwd = fwd, Bck = bck, Lft = lft, Rgt = rgt,
        Up = upB, Dn = dnB
    }
end

local function toggleGhost()
    local on = toggle(ghostBtn)
    local char = player.Character
    if not char then return end

    local hum = char:FindFirstChild("Humanoid")

    if on then
        ghostSphere = Instance.new("Part")
        ghostSphere.Name = player.Name .. "_eye"
        ghostSphere.Shape = Enum.PartType.Ball
        ghostSphere.Size = Vector3.new(2, 2, 2)
        ghostSphere.Transparency = 0.7
        ghostSphere.Anchored = true
        ghostSphere.CanCollide = false
        ghostSphere.Material = Enum.Material.Neon
        ghostSphere.Color = Color3.fromRGB(255, 255, 255)

        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            ghostSphere.CFrame = hrp.CFrame * CFrame.new(0, 2, -5)
        end
        ghostSphere.Parent = Workspace

        Workspace.CurrentCamera.CameraSubject = ghostSphere

        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Anchored = true
            end
        end
        if hum then hum.PlatformStand = true end

        local keysPressed = {}
        local moveDir = { forward = 0, strafe = 0, vertical = 0 }
        local SPEED = 2

        local inputCon = UserInputService.InputBegan:Connect(function(input, gp)
            if gp then return end
            keysPressed[input.KeyCode] = true
        end)
        table.insert(ghostConnections, inputCon)

        local inputEndCon = UserInputService.InputEnded:Connect(function(input)
            keysPressed[input.KeyCode] = nil
        end)
        table.insert(ghostConnections, inputEndCon)

        if UserInputService.TouchEnabled then
            mobileControls = createMobileControls()

            local function setupMobileBtn(btn, axis, value)
                local btnCon1 = btn.InputBegan:Connect(function()
                    moveDir[axis] = value
                end)
                local btnCon2 = btn.InputEnded:Connect(function()
                    moveDir[axis] = 0
                end)
                table.insert(ghostConnections, btnCon1)
                table.insert(ghostConnections, btnCon2)
            end

            setupMobileBtn(mobileControls.Fwd, "forward", 1)
            setupMobileBtn(mobileControls.Bck, "forward", -1)
            setupMobileBtn(mobileControls.Lft, "strafe", -1)
            setupMobileBtn(mobileControls.Rgt, "strafe", 1)
            setupMobileBtn(mobileControls.Up, "vertical", 1)
            setupMobileBtn(mobileControls.Dn, "vertical", -1)
        end

        local renderCon = RunService.RenderStepped:Connect(function()
            if not ghostSphere or not ghostSphere.Parent then return end

            local cam = Workspace.CurrentCamera
            local finalMove = Vector3.new(0,0,0)

            local camCF = cam.CFrame
            local camLook = camCF.LookVector
            local camRight = camCF.RightVector

            if keysPressed[Enum.KeyCode.W] then finalMove = finalMove + camLook end
            if keysPressed[Enum.KeyCode.S] then finalMove = finalMove - camLook end
            if keysPressed[Enum.KeyCode.D] then finalMove = finalMove + camRight end
            if keysPressed[Enum.KeyCode.A] then finalMove = finalMove - camRight end
            if keysPressed[Enum.KeyCode.Space] then finalMove = finalMove + Vector3.new(0,1,0) end
            if keysPressed[Enum.KeyCode.Q] then finalMove = finalMove - Vector3.new(0,1,0) end

            finalMove = finalMove + (camLook * moveDir.forward)
            finalMove = finalMove + (camRight * moveDir.strafe)
            finalMove = finalMove + (Vector3.new(0,1,0) * moveDir.vertical)

            if finalMove.Magnitude > 0 then
                ghostSphere.CFrame = ghostSphere.CFrame + (finalMove * SPEED)
            end
        end)
        table.insert(ghostConnections, renderCon)

    else
        if ghostSphere then
            ghostSphere:Destroy()
            ghostSphere = nil
        end

        if mobileControls then
            mobileControls.Frame:Destroy()
            mobileControls = nil
        end

        for _, conn in pairs(ghostConnections) do
            if conn then conn:Disconnect() end
        end
        ghostConnections = {}

        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Anchored = false
                end
            end
        end

        if hum then
            hum.PlatformStand = false
            Workspace.CurrentCamera.CameraSubject = hum
        end
    end
end

ghostBtn.MouseButton1Click:Connect(toggleGhost)

-------------------------------------------------
-- VISION (Rainbow Player ESP)
-------------------------------------------------

local rainbowConnection = nil

local function toggleVision()
    local on = toggle(visionBtn)

    if on then
        local processedPlayers = {} 

        if rainbowConnection then rainbowConnection:Disconnect() end

        rainbowConnection = RunService.RenderStepped:Connect(function()
            for obj, label in pairs(objectLabels) do
                if label and label.Parent then
                    local isPlayer = false
                    if obj:IsA("BasePart") then
                        local char = obj:FindFirstAncestorWhichIsA("Model")
                        if char and Players:GetPlayerFromCharacter(char) then
                            isPlayer = true
                        end
                    end

                    if isPlayer then
                        local hue = tick() % 5 / 5 
                        local txt = label:FindFirstChild("TextLabel")
                        if txt then
                            txt.TextColor3 = Color3.fromHSV(hue, 1, 1)
                        end
                    end
                end
            end
        end)

        for _,obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                originalTransparency[obj] = obj.Transparency
                originalColors[obj] = obj.Color
                obj.Transparency = 0

                if obj:GetAttribute("Marked") then
                    obj.Color = Color3.fromRGB(0, 255, 255)
                else
                    if obj.CanCollide then
                        obj.Color = Color3.fromRGB(0,255,0)
                    end
                end

                local characterModel = obj:FindFirstAncestorWhichIsA("Model")
                local playerFromCharacter = characterModel and Players:GetPlayerFromCharacter(characterModel)

                if playerFromCharacter then
                    if not processedPlayers[playerFromCharacter] then
                        local head = characterModel:FindFirstChild("Head")
                        if head then
                            local labelText = string.format("%s | %s", playerFromCharacter.Name, playerFromCharacter.DisplayName)
                            local label = Instance.new("BillboardGui")
                            label.Name = "NameLabel"
                            label.Size = UDim2.new(0, 100, 0, 20)
                            label.StudsOffset = Vector3.new(0, 2.5, 0) 
                            label.Parent = head 
                            local textLabel = Instance.new("TextLabel")
                            textLabel.Size = UDim2.new(1, 0, 1, 0)
                            textLabel.BackgroundTransparency = 1
                            textLabel.Text = labelText
                            textLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                            textLabel.TextStrokeTransparency = 0
                            textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
                            textLabel.Font = Enum.Font.SourceSansBold 
                            textLabel.TextSize = 14
                            textLabel.Parent = label
                            objectLabels[head] = label 
                            processedPlayers[playerFromCharacter] = true 
                        end
                    end
                else
                    if obj.Name ~= "" then
                        local label = Instance.new("BillboardGui")
                        label.Name = "NameLabel"
                        label.Size = UDim2.new(0, 100, 0, 20)
                        label.StudsOffset = Vector3.new(0, 2, 0)
                        label.Parent = obj
                        local textLabel = Instance.new("TextLabel")
                        textLabel.Size = UDim2.new(1, 0, 1, 0)
                        textLabel.BackgroundTransparency = 1
                        textLabel.Text = obj.Name
                        textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                        textLabel.TextStrokeTransparency = 0
                        textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
                        textLabel.Font = Enum.Font.SourceSans
                        textLabel.TextSize = 14
                        textLabel.Parent = label
                        objectLabels[obj] = label
                    end
                end
            end
        end
    else
        if rainbowConnection then
            rainbowConnection:Disconnect()
            rainbowConnection = nil
        end

        for obj,val in pairs(originalTransparency) do
            if obj and obj.Parent then
                obj.Transparency = val
            end
        end
        for obj,val in pairs(originalColors) do
            if obj and obj.Parent then
                obj.Color = val
            end
        end
        for _, label in pairs(objectLabels) do
            if label and label.Parent then
                label:Destroy()
            end
        end
        objectLabels = {}
        menu.Visible = false
    end
end

-------------------------------------------------
-- OBJECT SELECT
-------------------------------------------------

local function selectObject(obj)
    if not visionBtn:GetAttribute("Active") then return end
    if not obj then return end
    if not obj:IsA("BasePart") then return end

    local time = tick()

    if obj == lastObject and time-lastClick < 0.5 then
        if selectedObject then
            if selectedObject.Parent then
                selectedObject.Color = Color3.fromRGB(0,255,0) 
            end
        end
        selectedObject = obj
        selectedOriginalColor = obj.Color
        obj.Color = Color3.fromRGB(255,0,0) 

        menu.Visible = true
        menu.Position = UDim2.new(
            0,
            panel.AbsolutePosition.X + panel.AbsoluteSize.X + 10,
            0,
            panel.AbsolutePosition.Y
        )
        if broughtObjects[selectedObject] then
            bringBtn.Text = "Unbring"
        else
            bringBtn.Text = "Bring"
        end

        markBtn.Text = "Mark"
    else
        lastObject = obj
        lastClick = time
    end
end

-------------------------------------------------
-- INPUTS
-------------------------------------------------

UserInputService.InputBegan:Connect(function(input,gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local mouse = player:GetMouse()
        if mouse.Target then
            selectObject(mouse.Target)
        end
    end
end)

UserInputService.TouchTapInWorld:Connect(function(pos,processed)
    if processed then return end
    local cam = Workspace.CurrentCamera
    local ray = cam:ViewportPointToRay(pos.X,pos.Y)
    local result = Workspace:Raycast(ray.Origin,ray.Direction*500)
    if result then
        selectObject(result.Instance)
    end
end)

-------------------------------------------------
-- ACTIONS
-------------------------------------------------

bringBtn.MouseButton1Click:Connect(function()
    if not selectedObject then return end
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if broughtObjects[selectedObject] then
        selectedObject.CFrame = broughtObjects[selectedObject]
        broughtObjects[selectedObject] = nil
        bringBtn.Text = "Bring"
    else
        broughtObjects[selectedObject] = selectedObject.CFrame
        selectedObject.CFrame = hrp.CFrame + hrp.CFrame.LookVector*5
        bringBtn.Text = "Unbring"
    end
end)

teleportBtn.MouseButton1Click:Connect(function()
    if not selectedObject then return end
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        local originalLookVector = hrp.CFrame.LookVector
        local targetPosition = selectedObject.CFrame.Position + Vector3.new(0,5,0)
        hrp.CFrame = CFrame.new(targetPosition, targetPosition + originalLookVector)
    end
end)

-- FITUR: MARK (Melalui Menu)
markBtn.MouseButton1Click:Connect(function()
    if not selectedObject then return end

    markedCFrame = selectedObject.CFrame

    print("--- MARK SAVED ---")
    print("Position:", markedCFrame.Position)
    print("------------------")

    selectedObject:SetAttribute("Marked", true)
    selectedObject.Color = Color3.fromRGB(0, 255, 255)

    markBtn.Text = "Marked!"
    task.wait(0.5)
    markBtn.Text = "Mark"
end)

deleteBtn.MouseButton1Click:Connect(function()
    if not selectedObject then return end

    selectedObject:Destroy()
    selectedObject = nil
    menu.Visible = false
end)

-------------------------------------------------
-- FITUR BARU: MARKING (Tombol Utama)
-------------------------------------------------

markingBtn.MouseButton1Click:Connect(function()
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    markedCFrame = hrp.CFrame

    markingBtn.Text = "Marked!"
    markingBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)

    print("--- MARKING SAVED ---")
    print("Current Position Marked:", markedCFrame.Position)
    print("---------------------")

    task.wait(0.3)

    markingBtn.Text = "Marking"
    markingBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 150)
end)

-------------------------------------------------
-- FITUR UTAMA: TP TO MARK (FIXED ROTATION)
-------------------------------------------------

tpMarkBtn.MouseButton1Click:Connect(function()
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if isUndoMode then
        if tempMarkCFrame then
            local currentLook = hrp.CFrame.LookVector
            local targetPos = tempMarkCFrame.Position
            hrp.CFrame = CFrame.new(targetPos, targetPos + currentLook)
            print("Returned to temporary position.")
        end

        isUndoMode = false
        tempMarkCFrame = nil
        if undoThread then task.cancel(undoThread) end
        tpMarkBtn.Text = "Teleport"
        tpMarkBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 150)
        return
    end

    if not markedCFrame then
        tpMarkBtn.Text = "No Mark!"
        task.wait(0.5)
        tpMarkBtn.Text = "Teleport"
        return
    end

    tempMarkCFrame = hrp.CFrame
    local originalLook = hrp.CFrame.LookVector
    local targetPos = markedCFrame.Position

    hrp.CFrame = CFrame.new(targetPos, targetPos + originalLook)

    isUndoMode = true
    tpMarkBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 0)

    undoThread = task.spawn(function()
        for i = 10, 0, -1 do
            if not isUndoMode then break end
            tpMarkBtn.Text = "Undo ("..tostring(i)..")"
            task.wait(1)
        end

        if isUndoMode then
            isUndoMode = false
            tempMarkCFrame = nil
            tpMarkBtn.Text = "Teleport"
            tpMarkBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 150)
            print("Undo time expired.")
        end
    end)
end)

-------------------------------------------------
-- FITUR BARU: PLAYER LIST SYSTEM
-------------------------------------------------

local isPlayerListMinimized = false

-- Toggle Player List Panel
playerListBtn.MouseButton1Click:Connect(function()
    playerListPanel.Visible = not playerListPanel.Visible
end)

-- Minimize Player List Panel
plMinBtn.MouseButton1Click:Connect(function()
    isPlayerListMinimized = not isPlayerListMinimized
    if isPlayerListMinimized then
        playerListPanel.Size = UDim2.new(0, 500, 0, 30)
        plMinBtn.Text = "+"
        listContainer.Visible = false
    else
        playerListPanel.Size = UDim2.new(0, 500, 0, 300)
        plMinBtn.Text = "-"
        listContainer.Visible = true
    end
end)

-- Fungsi untuk menghentikan spectate
local function stopSpectate()
    if spectatingConnection then
        spectatingConnection:Disconnect()
        spectatingConnection = nil
    end
    spectatingPlayer = nil
    -- Kembalikan kamera ke player jika masih hidup
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        Workspace.CurrentCamera.CameraSubject = player.Character.Humanoid
    end
end

-- Fungsi untuk membuat baris pemain
local function createPlayerRow(plr, index)
    if plr == player then return end -- Jangan tampilkan diri sendiri

    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 25)
    row.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    row.BackgroundTransparency = 0.5
    row.Parent = scrollingFrame
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 4)

    local xPos = 5
    local labels = {}

    -- No
    labels[1] = Instance.new("TextLabel")
    labels[1].Size = UDim2.new(0, widths[1], 1, 0)
    labels[1].Position = UDim2.new(0, xPos, 0, 0)
    labels[1].BackgroundTransparency = 1
    labels[1].Text = tostring(index)
    labels[1].TextColor3 = Color3.new(1,1,1)
    labels[1].Font = Enum.Font.SourceSans
    labels[1].TextSize = 14
    labels[1].Parent = row
    xPos = xPos + widths[1]

    -- Name
    labels[2] = Instance.new("TextLabel")
    labels[2].Size = UDim2.new(0, widths[2], 1, 0)
    labels[2].Position = UDim2.new(0, xPos, 0, 0)
    labels[2].BackgroundTransparency = 1
    labels[2].Text = plr.Name
    labels[2].TextColor3 = Color3.new(1,1,1)
    labels[2].Font = Enum.Font.SourceSans
    labels[2].TextSize = 14
    labels[2].TextXAlignment = Enum.TextXAlignment.Left
    labels[2].Parent = row
    xPos = xPos + widths[2]

    -- NickName
    labels[3] = Instance.new("TextLabel")
    labels[3].Size = UDim2.new(0, widths[3], 1, 0)
    labels[3].Position = UDim2.new(0, xPos, 0, 0)
    labels[3].BackgroundTransparency = 1
    labels[3].Text = plr.DisplayName
    labels[3].TextColor3 = Color3.new(1,1,1)
    labels[3].Font = Enum.Font.SourceSans
    labels[3].TextSize = 14
    labels[3].TextXAlignment = Enum.TextXAlignment.Left
    labels[3].Parent = row
    xPos = xPos + widths[3]

    -- Distance (Dynamic)
    labels[4] = Instance.new("TextLabel")
    labels[4].Size = UDim2.new(0, widths[4], 1, 0)
    labels[4].Position = UDim2.new(0, xPos, 0, 0)
    labels[4].BackgroundTransparency = 1
    labels[4].Text = "0"
    labels[4].TextColor3 = Color3.new(1,1,1)
    labels[4].Font = Enum.Font.SourceSans
    labels[4].TextSize = 14
    labels[4].Parent = row
    xPos = xPos + widths[4]

    -- Button Teleport
    local tpB = Instance.new("TextButton")
    tpB.Size = UDim2.new(0, widths[5] - 10, 1, -4)
    tpB.Position = UDim2.new(0, xPos, 0, 2)
    tpB.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    tpB.Text = "TP"
    tpB.TextColor3 = Color3.new(1,1,1)
    tpB.Font = Enum.Font.SourceSansBold
    tpB.TextSize = 12
    tpB.Parent = row
    Instance.new("UICorner", tpB).CornerRadius = UDim.new(0, 4)

    tpB.MouseButton1Click:Connect(function()
        local char = plr.Character
        local myChar = player.Character
        if char and myChar then
            local thrp = char:FindFirstChild("HumanoidRootPart")
            local myhrp = myChar:FindFirstChild("HumanoidRootPart")
            if thrp and myhrp then
                -- Teleport 10 stud di belakang target
                -- Rumus: Posisi Target - (Arah Hadap Target * 10)
                local behindPos = thrp.CFrame.Position - (thrp.CFrame.LookVector * 10)
                myhrp.CFrame = CFrame.new(behindPos)
            end
        end
    end)

    xPos = xPos + widths[5]

    -- Button Cam (Spectate)
    local camB = Instance.new("TextButton")
    camB.Size = UDim2.new(0, widths[6] - 10, 1, -4)
    camB.Position = UDim2.new(0, xPos, 0, 2)
    camB.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    camB.Text = "Cam"
    camB.TextColor3 = Color3.new(1,1,1)
    camB.Font = Enum.Font.SourceSansBold
    camB.TextSize = 12
    camB.Parent = row
    Instance.new("UICorner", camB).CornerRadius = UDim.new(0, 4)

    camB.MouseButton1Click:Connect(function()
        if spectatingPlayer == plr then
            -- Jika sedang spectate player ini, matikan
            stopSpectate()
            camB.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            camB.Text = "Cam"
        else
            -- Jika sedang spectate player lain atau tidak, nyalakan untuk ini
            stopSpectate()
            spectatingPlayer = plr

            -- Set Camera Subject
            if plr.Character and plr.Character:FindFirstChild("Humanoid") then
                Workspace.CurrentCamera.CameraSubject = plr.Character.Humanoid
            end

            -- Update UI semua tombol Cam (Reset warna)
            for p, rowObj in pairs(playerRows) do
                if rowObj and rowObj.CamBtn then
                    if p == spectatingPlayer then
                        rowObj.CamBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Merah = Aktif
                        rowObj.CamBtn.Text = "Stop"
                    else
                        rowObj.CamBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
                        rowObj.CamBtn.Text = "Cam"
                    end
                end
            end
        end
    end)

    -- Simpan referensi untuk update
    playerRows[plr] = {
        Row = row, 
        DistLabel = labels[4], 
        CamBtn = camB
    }
end

-- Update Jarak Realtime
RunService.RenderStepped:Connect(function()
    local myChar = player.Character
    if not myChar then return end
    local myHrp = myChar:FindFirstChild("HumanoidRootPart")
    if not myHrp then return end

    for plr, data in pairs(playerRows) do
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (plr.Character.HumanoidRootPart.Position - myHrp.Position).Magnitude
            data.DistLabel.Text = string.format("%.0f", dist)
        else
            data.DistLabel.Text = "N/A"
        end
    end
end)

-- Inisialisasi Player List
local function initPlayerList()
    -- Bersihkan daftar lama
    for _, data in pairs(playerRows) do
        if data.Row then data.Row:Destroy() end
    end
    playerRows = {}

    -- Buat daftar baru
    local i = 1
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player then
            createPlayerRow(plr, i)
            i = i + 1
        end
    end
end

Players.PlayerAdded:Connect(function(plr)
    -- Tunggu sedikit agar pemain sempat load
    task.wait(1)
    initPlayerList()
end)

Players.PlayerRemoving:Connect(function(plr)
    if playerRows[plr] then
        if playerRows[plr].Row then playerRows[plr].Row:Destroy() end
        playerRows[plr] = nil
    end
    -- Jika yg di-remove sedang di spectate
    if spectatingPlayer == plr then
        stopSpectate()
    end
    -- Reset Indexing
    initPlayerList()
end)

-- Jalankan inisialisasi pertama kali
initPlayerList()

-------------------------------------------------
-- EVENTS
-------------------------------------------------

visionBtn.MouseButton1Click:Connect(toggleVision)

jumpBtn.MouseButton1Click:Connect(function()
    local on = toggle(jumpBtn)
    if on and player.Character then
        setupJump(player.Character)
    end
end)

player.CharacterAdded:Connect(function(c)
    task.wait(0.5)
    setupJump(c)
    if ghostBtn:GetAttribute("Active") then
        toggleGhost()
    end
end)
