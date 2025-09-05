-- LocalScript (StarterPlayerScripts)

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- ==========================
-- UI Ransel Button
-- ==========================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RanselGui"
ScreenGui.Parent = PlayerGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 100, 0, 40)
Frame.Position = UDim2.new(1, -110, 0, 10)
Frame.BackgroundColor3 = Color3.fromRGB(50,50,50)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local Button = Instance.new("TextButton")
Button.Size = UDim2.new(1, -20, 1, 0)
Button.Position = UDim2.new(0, 0, 0, 0)
Button.Text = "Ransel"
Button.BackgroundColor3 = Color3.fromRGB(100, 100, 250)
Button.TextColor3 = Color3.fromRGB(255, 255, 255)
Button.Parent = Frame

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 20, 0, 20)
CloseButton.Position = UDim2.new(1, -20, 0, 0)
CloseButton.Text = "X"
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Parent = Frame

CloseButton.MouseButton1Click:Connect(function()
    Frame.Visible = false
end)

-- ==========================
-- Daftar Item
-- ==========================
local items = {
    {Name = "Speed", ToolName = "Speed Coil"},
    {Name = "M. Carpet", ToolName = "M. Carpet"},
    {Name = "L. Board", ToolName = "L. Board"},
    {Name = "Vision", ToolName = "Vision"},
    {Name = "Freeze", ToolName = "Freeze"},
    { Name = "Block", ToolName = "Block" },
    { Name = "Tower", ToolName = "Tower" },
}

local spawnedParts = {}

-- ==========================
-- TOOL: Speed Coil
-- ==========================
local function createSpeedTool()
    local tool = Instance.new("Tool")
    tool.Name = "Speed Coil"
    tool.RequiresHandle = false
    tool.Parent = Player.Backpack

    tool.Equipped:Connect(function()
        local humanoid = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 25
        end
    end)

    tool.Unequipped:Connect(function()
        local humanoid = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 16
        end
    end)
end

-- ==========================
-- TOOL: M.Carpet (Fly)
-- ==========================
local function createCarpetTool()
    local tool = Instance.new("Tool")
    tool.Name = "M. Carpet"
    tool.RequiresHandle = false
    tool.Parent = Player.Backpack

    local flying = false
    local up, down = false, false
    local BV -- BodyVelocity

    -- tombol naik/turun untuk mobile
    local mobileGui = Instance.new("Frame")
    mobileGui.Size = UDim2.new(0,120,0,120)
    mobileGui.Position = UDim2.new(1,-130,1,-130)
    mobileGui.BackgroundTransparency = 1
    mobileGui.Parent = PlayerGui

    local upBtn = Instance.new("TextButton")
    upBtn.Size = UDim2.new(0.5,0,0.5,0)
    upBtn.Position = UDim2.new(0,0,0,0)
    upBtn.Text = "▲"
    upBtn.BackgroundColor3 = Color3.fromRGB(0,200,0)
    upBtn.Parent = mobileGui

    local downBtn = Instance.new("TextButton")
    downBtn.Size = UDim2.new(0.5,0,0.5,0)
    downBtn.Position = UDim2.new(0.5,0,0.5,0)
    downBtn.Text = "▼"
    downBtn.BackgroundColor3 = Color3.fromRGB(200,0,0)
    downBtn.Parent = mobileGui

    upBtn.MouseButton1Down:Connect(function() up = true end)
    upBtn.MouseButton1Up:Connect(function() up = false end)
    downBtn.MouseButton1Down:Connect(function() down = true end)
    downBtn.MouseButton1Up:Connect(function() down = false end)

    mobileGui.Visible = false

    tool.Equipped:Connect(function()
        flying = true
        mobileGui.Visible = true

        local char = Player.Character or Player.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")

        BV = Instance.new("BodyVelocity")
        BV.MaxForce = Vector3.new(4000,4000,4000)
        BV.Velocity = Vector3.zero
        BV.Parent = hrp

        RunService.RenderStepped:Connect(function()
            if flying and BV and hrp then
                local moveDir = Vector3.zero
                local hum = char:FindFirstChildOfClass("Humanoid")

                if hum then
                    moveDir = hum.MoveDirection * 50
                end
                local yVel = 0
                if up then yVel = 50 elseif down then yVel = -50 end

                -- keyboard naik turun
                if UIS:IsKeyDown(Enum.KeyCode.Space) then yVel = 50 end
                if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then yVel = -50 end

                BV.Velocity = Vector3.new(moveDir.X, yVel, moveDir.Z)
            end
        end)
    end)

    tool.Unequipped:Connect(function()
        flying = false
        mobileGui.Visible = false
        if BV then BV:Destroy() end
    end)
end

-- ==========================
-- TOOL: L. Board (Leaderboard Panel)
-- ==========================
local function createLeaderboardTool()
    local tool = Instance.new("Tool")
    tool.Name = "L. Board"
    tool.RequiresHandle = false
    tool.Parent = Player.Backpack

    -- buat UI panel
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "LeaderboardGui"
    ScreenGui.ResetOnSpawn = false

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 500, 0, 350)
    Frame.Position = UDim2.new(0.5, -250, 0.5, -175)
    Frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
    Frame.BorderSizePixel = 0
    Frame.Parent = ScreenGui

    local header = Instance.new("Frame")
    header.Size = UDim2.new(1,0,0,30)
    header.BackgroundColor3 = Color3.fromRGB(60,60,60)
    header.Parent = Frame

    local function createHeader(text, pos, size)
        local lbl = Instance.new("TextLabel")
        lbl.Size = size
        lbl.Position = pos
        lbl.BackgroundTransparency = 1
        lbl.TextColor3 = Color3.new(1,1,0)
        lbl.Font = Enum.Font.SourceSansBold
        lbl.Text = text
        lbl.Parent = header
    end

    createHeader("Nickname (Username)", UDim2.new(0,0,0,0), UDim2.new(0.35,0,1,0))
    createHeader("CP", UDim2.new(0.35,0,0,0), UDim2.new(0.15,0,1,0))
    createHeader("Spectate", UDim2.new(0.5,0,0,0), UDim2.new(0.25,0,1,0))
    createHeader("Teleport", UDim2.new(0.75,0,0,0), UDim2.new(0.25,0,1,0))

    local Scrolling = Instance.new("ScrollingFrame")
    Scrolling.Size = UDim2.new(1,0,1,-30)
    Scrolling.Position = UDim2.new(0,0,0,30)
    Scrolling.CanvasSize = UDim2.new(0,0,0,0)
    Scrolling.ScrollBarThickness = 8
    Scrolling.BackgroundTransparency = 1
    Scrolling.Parent = Frame

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Parent = Scrolling
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

    -- state spectate
    local currentSpectateTarget = nil
    local spectateConn = nil

    local function setSpectate(targetPlayer)
        -- putus koneksi lama dulu
        if spectateConn then
            spectateConn:Disconnect()
            spectateConn = nil
        end

        if targetPlayer then
            currentSpectateTarget = targetPlayer
            -- kalau ada character langsung set kamera
            if targetPlayer.Character and targetPlayer.Character:FindFirstChild("Humanoid") then
                workspace.CurrentCamera.CameraSubject = targetPlayer.Character.Humanoid
            end

            -- listen kalau dia respawn → otomatis batal spectate
            spectateConn = targetPlayer.CharacterAdded:Connect(function()
                setSpectate(nil)
                refreshList()
            end)
        else
            -- keluar spectate
            currentSpectateTarget = nil
            local myChar = Player.Character
            if myChar and myChar:FindFirstChild("Humanoid") then
                workspace.CurrentCamera.CameraSubject = myChar.Humanoid
            end
        end
    end

    function refreshList()
        for _, child in ipairs(Scrolling:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end

        for _, plr in ipairs(Players:GetPlayers()) do
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1,0,0,30)
            row.BackgroundColor3 = Color3.fromRGB(45,45,45)
            row.Parent = Scrolling

            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(0.35,0,1,0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.TextColor3 = Color3.new(1,1,1)
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.Text = plr.DisplayName .. " ("..plr.Name..")"
            nameLabel.Parent = row

            local cpLabel = Instance.new("TextLabel")
            cpLabel.Size = UDim2.new(0.15,0,1,0)
            cpLabel.Position = UDim2.new(0.35,0,0,0)
            cpLabel.BackgroundTransparency = 1
            cpLabel.TextColor3 = Color3.new(1,1,1)
            cpLabel.Text = plr:FindFirstChild("leaderstats") 
                and (plr.leaderstats:FindFirstChild("Checkpoint") and tostring(plr.leaderstats.Checkpoint.Value) or "-") 
                or "-"
            cpLabel.Parent = row

            local spectBtn = Instance.new("TextButton")
            spectBtn.Size = UDim2.new(0.25,0,1,0)
            spectBtn.Position = UDim2.new(0.5,0,0,0)
            spectBtn.BackgroundColor3 = Color3.fromRGB(0,120,200)
            spectBtn.TextColor3 = Color3.new(1,1,1)
            spectBtn.Parent = row

            -- cek status saat refresh
            if currentSpectateTarget == plr then
                spectBtn.Text = "Unspectate"
            else
                spectBtn.Text = "Spectate"
            end

            spectBtn.MouseButton1Click:Connect(function()
                if currentSpectateTarget == plr then
                    setSpectate(nil)
                    refreshList()
                else
                    setSpectate(plr)
                    refreshList()
                end
            end)

            local tpBtn = Instance.new("TextButton")
            tpBtn.Size = UDim2.new(0.25,0,1,0)
            tpBtn.Position = UDim2.new(0.75,0,0,0)
            tpBtn.Text = "Teleport"
            tpBtn.BackgroundColor3 = Color3.fromRGB(0,200,100)
            tpBtn.TextColor3 = Color3.new(1,1,1)
            tpBtn.Parent = row

            tpBtn.MouseButton1Click:Connect(function()
                local myChar = Player.Character
                local targetChar = plr.Character
                if myChar and targetChar then
                    local hrp = myChar:FindFirstChild("HumanoidRootPart")
                    local targetHrp = targetChar:FindFirstChild("HumanoidRootPart")
                    if hrp and targetHrp then
                        -- tepat 5 stud di belakang target
                        hrp.CFrame = targetHrp.CFrame * CFrame.new(0,0,5)
                    end
                end
            end)
        end

        -- sesuaikan panjang canvas
        Scrolling.CanvasSize = UDim2.new(0,0,0,#Players:GetPlayers()*30)
    end

    tool.Equipped:Connect(function()
        ScreenGui.Parent = PlayerGui
        refreshList()
    end)

    tool.Unequipped:Connect(function()
        ScreenGui.Parent = nil
    end)

    Players.PlayerAdded:Connect(refreshList)
    Players.PlayerRemoving:Connect(refreshList)
end

-- ==========================
-- TOOL: Vision (X-Ray Mode)
-- ==========================
local function createVisionTool()
    local tool = Instance.new("Tool")
    tool.Name = "Vision"
    tool.RequiresHandle = false
    tool.Parent = Player.Backpack

    -- buat folder untuk simpan data asli
    local originalStates = {}

    tool.Equipped:Connect(function()
        originalStates = {}

        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                -- simpan kondisi asli
                originalStates[obj] = {
                    Transparency = obj.Transparency,
                    Color = obj.Color,
                }

                -- aturan vision
                if obj.Transparency == 1 then
                    obj.Transparency = 0
                end
                if obj.CanCollide == true then
                    obj.Color = Color3.fromRGB(0,255,0)
                end
            end
        end
    end)

    tool.Unequipped:Connect(function()
        -- kembalikan kondisi semula
        for obj, state in pairs(originalStates) do
            if obj and obj.Parent then
                obj.Transparency = state.Transparency
                obj.Color = state.Color
            end
        end
        originalStates = {}
    end)
end

-- ==========================
-- TOOL: Freeze
-- ==========================
local function createFreezeTool()
    local tool = Instance.new("Tool")
    tool.Name = "Freeze"
    tool.RequiresHandle = false
    tool.Parent = Player.Backpack

    local originalStates = {}

    tool.Equipped:Connect(function()
        originalStates = {}

        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                local model = obj:FindFirstAncestorOfClass("Model")
                -- skip player/humanoid
                if not (model and model:FindFirstChildOfClass("Humanoid")) then
                    -- simpan state lama
                    originalStates[obj] = {
                        Anchored = obj.Anchored,
                        CustomPhysicalProperties = obj.CustomPhysicalProperties,
                        Surfaces = {
                            Top = obj.TopSurface,
                            Bottom = obj.BottomSurface,
                            Left = obj.LeftSurface,
                            Right = obj.RightSurface,
                            Front = obj.FrontSurface,
                            Back = obj.BackSurface,
                        }
                    }

                    -- bekukan part
                    obj.Anchored = true
                    obj.Velocity = Vector3.zero
                    obj.RotVelocity = Vector3.zero

                    -- bikin super stabil, gak licin, gak mantul
                    obj.CustomPhysicalProperties = PhysicalProperties.new(0, 1, 0, 100, 100)

                    -- bikin climbable dari segala sisi
                    obj.TopSurface = Enum.SurfaceType.Studs
                    obj.BottomSurface = Enum.SurfaceType.Studs
                    obj.LeftSurface = Enum.SurfaceType.Studs
                    obj.RightSurface = Enum.SurfaceType.Studs
                    obj.FrontSurface = Enum.SurfaceType.Studs
                    obj.BackSurface = Enum.SurfaceType.Studs
                end
            end
        end
    end)

    tool.Unequipped:Connect(function()
        for obj, state in pairs(originalStates) do
            if obj and obj.Parent then
                obj.Anchored = state.Anchored
                obj.CustomPhysicalProperties = state.CustomPhysicalProperties
                obj.TopSurface = state.Surfaces.Top
                obj.BottomSurface = state.Surfaces.Bottom
                obj.LeftSurface = state.Surfaces.Left
                obj.RightSurface = state.Surfaces.Right
                obj.FrontSurface = state.Surfaces.Front
                obj.BackSurface = state.Surfaces.Back
            end
        end
        originalStates = {}
    end)
end

-- ==========================
-- TOOL: Block
-- ==========================
local function createBlockTool()
    local tool = Instance.new("Tool")
    tool.Name = "Block"
    tool.RequiresHandle = false
    tool.Parent = Player.Backpack

    local blockPart -- reference biar bisa hapus lagi

    tool.Equipped:Connect(function()
        local char = Player.Character or Player.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")

        -- buat part lantai
        blockPart = Instance.new("Part")
        blockPart.Size = Vector3.new(900, 0.1, 900)
        blockPart.Anchored = true
        blockPart.CanCollide = true
        blockPart.Color = Color3.fromRGB(0, 255, 0)
        blockPart.Transparency = 0.9
        blockPart.Name = "BlockPlatform"

        -- posisinya tepat di bawah kaki
        blockPart.Position = (hrp.Position - Vector3.new(0, (hrp.Size.Y/2) + 2, 0))

        blockPart.Parent = workspace
    end)

    tool.Unequipped:Connect(function()
        if blockPart and blockPart.Parent then
            blockPart:Destroy()
            blockPart = nil
        end
    end)
end

-- ==========================
-- TOOL: Tower (Auto-Grow Truss)
-- ==========================
local function createTowerTool()
    local tool = Instance.new("Tool")
    tool.Name = "Tower"
    tool.RequiresHandle = false
    tool.Parent = Player.Backpack

    local truss
    local growing = false
    local lastClimbTime = 0
    local runConn
    local cleanupToken = 0 -- untuk batalkan timer 15 detik saat re-equip

    local function destroyTruss()
        if truss then
            truss:Destroy()
            truss = nil
        end
        if runConn then
            runConn:Disconnect()
            runConn = nil
        end
    end

    tool.Equipped:Connect(function()
        local char = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")

        -- batalkan countdown 15 detik jika ada
        cleanupToken += 1

        -- buat / posisikan ulang truss 3 stud di depan
        if not truss then
            truss = Instance.new("TrussPart")
            truss.Size = Vector3.new(5, 20, 1) -- tinggi awal 20
            truss.Anchored = true
            truss.Name = "TowerTruss"
            truss.Parent = workspace
        end
        -- posisikan sehingga dasar tetap di tempat saat nanti tumbuh
        truss.CFrame = CFrame.new(
            (hrp.Position + hrp.CFrame.LookVector * 3) - Vector3.new(0, truss.Size.Y/2, 0)
        )

        growing = true
        lastClimbTime = tick()

        if not runConn then
            runConn = RunService.Heartbeat:Connect(function()
                if not truss then return end

                local c = Players.LocalPlayer.Character
                local hum = c and c:FindFirstChildOfClass("Humanoid")
                if not hum then return end

                if growing then
                    if hum:GetState() == Enum.HumanoidStateType.Climbing then
                        lastClimbTime = tick()
                        local head = c:FindFirstChild("Head")
                        if head then
                            local topY = truss.Position.Y + (truss.Size.Y * 0.5)
                            local gap = topY - head.Position.Y
                            if gap <= 5 then
                                -- tambah tinggi 10, geser center +5 agar dasar tetap
                                truss.Size = Vector3.new(truss.Size.X, truss.Size.Y + 10, truss.Size.Z)
                                truss.Position = truss.Position + Vector3.new(0, 5, 0)
                            end
                        end
                    else
                        -- saat EQUIPPED: auto-hilang jika tidak dipanjat > 10 detik
                        if tick() - lastClimbTime > 10 then
                            destroyTruss()
                        end
                    end
                else
                    -- saat NOT EQUIPPED: jangan apa-apa di loop; countdown 15 dtk di-handle terpisah
                end
            end)
        end
    end)

    tool.Unequipped:Connect(function()
        -- berhenti tumbuh, tapi JANGAN hapus langsung
        growing = false

        -- mulai countdown 15 detik; kalau re-equip, token berubah & batalkan hapus
        cleanupToken += 1
        local myToken = cleanupToken
        task.delay(15, function()
            if myToken == cleanupToken then
                destroyTruss()
            end
        end)
    end)
end

-- ==========================
-- Fungsi Spawn Parts
-- ==========================
local function spawnParts()
    local character = Player.Character or Player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")

    -- hapus part lama
    for _, p in ipairs(spawnedParts) do
        if p and p.Parent then
            p:Destroy()
        end
    end
    table.clear(spawnedParts)

    local radius = 10
    for i, item in ipairs(items) do
        -- skip kalau tool sudah ada
        if not (Player.Backpack:FindFirstChild(item.ToolName) or character:FindFirstChild(item.ToolName)) then
            local angle = math.rad((i-1) * (360 / #items))
            local offset = Vector3.new(math.cos(angle)*radius,0,math.sin(angle)*radius)
            local pos = hrp.Position + offset

            -- raycast ke tanah
            local rayOrigin = pos + Vector3.new(0,50,0)
            local rayDirection = Vector3.new(0,-100,0)
            local rayParams = RaycastParams.new()
            rayParams.FilterDescendantsInstances = {character}
            rayParams.FilterType = Enum.RaycastFilterType.Blacklist

            local rayResult = workspace:Raycast(rayOrigin, rayDirection, rayParams)
            local partY = rayResult and rayResult.Position.Y + 0.5 or pos.Y

            local part = Instance.new("Part")
            part.Size = Vector3.new(2,1,2)
            part.Position = Vector3.new(pos.X, partY, pos.Z)
            part.Anchored = true
            part.CanCollide = false
            part.Name = item.Name
            part.Parent = workspace

            -- billboard
            local billboard = Instance.new("BillboardGui")
            billboard.Size = UDim2.new(0,120,0,50)
            billboard.StudsOffset = Vector3.new(0,2,0)
            billboard.Adornee = part
            billboard.AlwaysOnTop = true
            billboard.Parent = part

            local textLabel = Instance.new("TextLabel")
            textLabel.Size = UDim2.new(1,0,1,0)
            textLabel.BackgroundTransparency = 1
            textLabel.Text = item.Name
            textLabel.TextColor3 = Color3.fromRGB(255,255,255)
            textLabel.TextScaled = true
            textLabel.Parent = billboard

            -- disentuh (per part debounce)
            local debounce = false
            part.Touched:Connect(function(hit)
                if debounce then return end
                local hum = hit.Parent:FindFirstChildOfClass("Humanoid")
                if hum and hit.Parent == character then
                    debounce = true
                    if item.Name == "Speed" then
                        createSpeedTool()
                    elseif item.Name == "M. Carpet" then
                        createCarpetTool()
                    elseif item.Name == "L. Board" then
                        createLeaderboardTool()
                    elseif item.Name == "Vision" then
                        createVisionTool()
                    elseif item.Name == "Freeze" then
                        createFreezeTool()
                    elseif item.Name == "Block" then
                        createBlockTool()
                    elseif item.Name == "Tower" then
                        createTowerTool()
                    end
                    part:Destroy()
                end
            end)

            table.insert(spawnedParts, part)
        end
    end
end

Button.MouseButton1Click:Connect(spawnParts)
