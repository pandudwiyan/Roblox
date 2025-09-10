-- LocalScript (StarterPlayerScripts)

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- ==========================
-- TOOL: Speed Coil (Minimalist UI)
-- ==========================
local function createSpeedTool()
    local tool = Instance.new("Tool")
    tool.Name = "Speed Coil"
    tool.RequiresHandle = false
    tool.Parent = Player.Backpack

    local humanoid
    local speed = 25 -- default coil speed

    -- GUI
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SpeedGui"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = PlayerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 50, 0, 100) -- sempit
    frame.Position = UDim2.new(1, -60, 0.7, 0) -- kanan bawah agak ke tengah
    frame.BackgroundTransparency = 1 -- transparan full
    frame.Active = true
    frame.Draggable = true
    frame.Visible = false
    frame.Parent = screenGui

    -- tombol UP
    local upBtn = Instance.new("TextButton")
    upBtn.Size = UDim2.new(1, 0, 0.5, 0)
    upBtn.Position = UDim2.new(0, 0, 0, 0)
    upBtn.Text = "▲"
    upBtn.TextColor3 = Color3.new(1, 1, 1)
    upBtn.BackgroundTransparency = 1
    upBtn.TextScaled = true
    upBtn.Parent = frame

    -- tombol DOWN
    local downBtn = Instance.new("TextButton")
    downBtn.Size = UDim2.new(1, 0, 0.5, 0)
    downBtn.Position = UDim2.new(0, 0, 0.5, 0)
    downBtn.Text = "▼"
    downBtn.TextColor3 = Color3.new(1, 1, 1)
    downBtn.BackgroundTransparency = 1
    downBtn.TextScaled = true
    downBtn.Parent = frame

    -- fungsi update speed
    local function updateSpeed(newSpeed)
        speed = newSpeed
        if humanoid then
            humanoid.WalkSpeed = speed
        end
    end

    -- tombol logic
    upBtn.MouseButton1Click:Connect(function()
        updateSpeed(speed * 2)
    end)

    downBtn.MouseButton1Click:Connect(function()
        updateSpeed(math.max(25, speed / 2)) -- minimal 25
    end)

    tool.Equipped:Connect(function()
        local char = Player.Character or Player.CharacterAdded:Wait()
        humanoid = char:WaitForChild("Humanoid")
        updateSpeed(25) -- reset default
        frame.Visible = true
    end)

    tool.Unequipped:Connect(function()
        if humanoid then
            humanoid.WalkSpeed = 16 -- balik ke default game
        end
        frame.Visible = false
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

    -- GUI untuk mobile (pojok kanan bawah)
    local screen = Instance.new("ScreenGui")
    screen.Name = "CarpetGui"
    screen.ResetOnSpawn = false
    screen.Parent = PlayerGui
    screen.Enabled = false -- default mati

    local mobileGui = Instance.new("Frame")
    mobileGui.Size = UDim2.new(0,80,0,80)
    mobileGui.Position = UDim2.new(1,-100,1,-120) -- pojok kanan bawah
    mobileGui.BackgroundColor3 = Color3.fromRGB(0,0,0)
    mobileGui.BackgroundTransparency = 0.4
    mobileGui.Parent = screen

    local upBtn = Instance.new("TextButton")
    upBtn.Size = UDim2.new(1,0,0.5,0)
    upBtn.Position = UDim2.new(0,0,0,0)
    upBtn.Text = "▲"
    upBtn.TextSize = 18
    upBtn.TextColor3 = Color3.new(1,1,1)
    upBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
    upBtn.BackgroundTransparency = 0.2
    upBtn.Parent = mobileGui

    local downBtn = Instance.new("TextButton")
    downBtn.Size = UDim2.new(1,0,0.5,0)
    downBtn.Position = UDim2.new(0,0,0.5,0)
    downBtn.Text = "▼"
    downBtn.TextSize = 18
    downBtn.TextColor3 = Color3.new(1,1,1)
    downBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
    downBtn.BackgroundTransparency = 0.2
    downBtn.Parent = mobileGui

    -- event tombol
    upBtn.MouseButton1Down:Connect(function() up = true end)
    upBtn.MouseButton1Up:Connect(function() up = false end)
    downBtn.MouseButton1Down:Connect(function() down = true end)
    downBtn.MouseButton1Up:Connect(function() down = false end)

    tool.Equipped:Connect(function()
        flying = true
        mobileGui.Visible = true
        screen.Enabled = true

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

                -- keyboard naik turun (untuk PC)
                if UIS:IsKeyDown(Enum.KeyCode.Space) then yVel = 50 end
                if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then yVel = -50 end

                BV.Velocity = Vector3.new(moveDir.X, yVel, moveDir.Z)
            end
        end)
    end)

    tool.Unequipped:Connect(function()
        flying = false
        mobileGui.Visible = false
        screen.Enabled = false
        if BV then BV:Destroy() BV = nil end
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
    Frame.BackgroundTransparency = 0.2
    Frame.BorderSizePixel = 0
    Frame.Active = true
    Frame.Draggable = true
    Frame.Parent = ScreenGui

    -- Rounded corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = Frame

    local header = Instance.new("Frame")
    header.Size = UDim2.new(1,0,0,40)
    header.BackgroundColor3 = Color3.fromRGB(50,50,50)
    header.BackgroundTransparency = 0.1
    header.Parent = Frame

    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 10)
    headerCorner.Parent = header

    local function createHeader(text, pos, size)
        local lbl = Instance.new("TextLabel")
        lbl.Size = size
        lbl.Position = pos
        lbl.BackgroundTransparency = 1
        lbl.TextColor3 = Color3.new(1, 1, 1) -- putih sama seperti user list
        lbl.Font = Enum.Font.SourceSansBold   -- sama dengan user list
        lbl.TextSize = 15                     -- manual size, biar konsisten
        lbl.TextScaled = false                -- jangan auto-scale
        lbl.TextXAlignment = Enum.TextXAlignment.Center -- rata tengah horizontal
        lbl.TextYAlignment = Enum.TextYAlignment.Center -- rata tengah vertical
        lbl.Text = text
        lbl.Parent = header
    end

    createHeader("Nickname (Username)", UDim2.new(0,0,0,0), UDim2.new(0.35,0,1,0))
    createHeader("CP", UDim2.new(0.35,0,0,0), UDim2.new(0.15,0,1,0))
    createHeader("Spectate", UDim2.new(0.5,0,0,0), UDim2.new(0.25,0,1,0))
    createHeader("Teleport", UDim2.new(0.75,0,0,0), UDim2.new(0.25,0,1,0))

    local Scrolling = Instance.new("ScrollingFrame")
    Scrolling.Size = UDim2.new(1,0,1,-40)
    Scrolling.Position = UDim2.new(0,0,0,40)
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
            nameLabel.Position = UDim2.new(0, 10, 0, 0) -- geser 10px ke kanan
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
-- TOOL: Freeze (Medium Freeze)
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
                        },
                        DisabledInstances = {} -- untuk constraint/bodymover
                    }

                    -- freeze part
                    obj.Anchored = true
                    obj.Velocity = Vector3.zero
                    obj.RotVelocity = Vector3.zero
                    obj.CustomPhysicalProperties = PhysicalProperties.new(0, 1, 0, 100, 100)

                    -- bikin climbable
                    obj.TopSurface = Enum.SurfaceType.Studs
                    obj.BottomSurface = Enum.SurfaceType.Studs
                    obj.LeftSurface = Enum.SurfaceType.Studs
                    obj.RightSurface = Enum.SurfaceType.Studs
                    obj.FrontSurface = Enum.SurfaceType.Studs
                    obj.BackSurface = Enum.SurfaceType.Studs

                    -- disable constraint & bodymover
                    for _, child in ipairs(obj:GetChildren()) do
                        if child:IsA("BodyMover") or child:IsA("Constraint") then
                            if child:IsA("Constraint") and child.Enabled then
                                table.insert(originalStates[obj].DisabledInstances, child)
                                child.Enabled = false
                            elseif child:IsA("BodyMover") then
                                table.insert(originalStates[obj].DisabledInstances, child)
                                child.Archivable = false -- tandai agar tidak restore baru
                                child:Destroy() -- hapus biar ga paksa gerak
                            end
                        end
                    end
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

                -- enable kembali constraint yang sempat dimatikan
                for _, inst in ipairs(state.DisabledInstances) do
                    if inst and inst.Parent then
                        if inst:IsA("Constraint") then
                            inst.Enabled = true
                        end
                    end
                end
            end
        end
        originalStates = {}
    end)
end

-- ==========================
-- TOOL: Block (Advanced Version - Auto Clear on Unequip)
-- ==========================
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local function createBlockTool()
    local tool = Instance.new("Tool")
    tool.Name = "Block"
    tool.RequiresHandle = false
    tool.Parent = Player.Backpack

    -- state variables
    local blockOn = false
    local blockConnections = {}
    local lastBlockTime = 0
    local blockCooldown = 0.3
    local landedBlockActive = false
    local lastLandedPos = nil
    local specialBlockActive = false

    local activeBlocks = {} -- simpan semua block yang dibuat

    -- helper: register block biar bisa dihapus nanti
    local function trackBlock(block, lifetime)
        table.insert(activeBlocks, block)
        if lifetime then
            task.delay(lifetime, function()
                if block and block.Parent and blockOn then
                    block:Destroy()
                end
            end)
        end
    end

    -- helper: bikin block biasa (abu-abu)
    local function createBlock(char)
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local block = Instance.new("Part")
        block.Size = Vector3.new(10, 0.1, 10)
        block.Anchored = true
        block.CanCollide = true
        block.BrickColor = BrickColor.new("Medium stone grey")
        block.Transparency = 0.9
        block.CFrame = CFrame.new(hrp.Position.X, hrp.Position.Y - 3, hrp.Position.Z)
        block.Parent = workspace
        trackBlock(block, 2)
    end

    -- helper: bikin block landed (biru / kuning)
    local function createLandedBlock(char)
        if landedBlockActive then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local landedPos = Vector3.new(
            math.floor(hrp.Position.X/5),
            0,
            math.floor(hrp.Position.Z/5)
        )

        if lastLandedPos and (landedPos - lastLandedPos).Magnitude < 1 then
            if specialBlockActive then return end
            specialBlockActive = true
            local special = Instance.new("Part")
            special.Size = Vector3.new(900, 0.1, 900)
            special.Anchored = true
            special.CanCollide = true
            special.BrickColor = BrickColor.new("Bright yellow")
            special.Transparency = 0.9
            special.CFrame = CFrame.new(hrp.Position.X, hrp.Position.Y - 5.8, hrp.Position.Z)
            special.Parent = workspace
            trackBlock(special) -- tidak auto-destroy, manual saat unequip
            task.delay(5, function()
                if special and special.Parent then
                    special:Destroy()
                end
                specialBlockActive = false
            end)
        else
            landedBlockActive = true
            local block = Instance.new("Part")
            block.Size = Vector3.new(10, 0.1, 10)
            block.Anchored = true
            block.CanCollide = true
            block.BrickColor = BrickColor.new("Really blue")
            block.Transparency = 0.9
            block.CFrame = CFrame.new(hrp.Position.X, hrp.Position.Y - 5.8, hrp.Position.Z)
            block.Parent = workspace
            trackBlock(block, 2)
            task.delay(1, function()
                landedBlockActive = false
            end)
        end

        lastLandedPos = landedPos
    end

    -- helper: pasang touched listener
    local function hookTouchedOnPart(part, char, hum)
        if not part:IsA("BasePart") then return end
        local conn = part.Touched:Connect(function(hit)
            if not blockOn or specialBlockActive then return end
            if not hit or not hit:IsA("BasePart") or not hit.CanCollide then return end
            if hit:IsDescendantOf(char) then return end
            if hum and hum.FloorMaterial ~= Enum.Material.Air then return end
            local now = tick()
            if now - lastBlockTime < blockCooldown then return end
            lastBlockTime = now
            createBlock(char)
        end)
        table.insert(blockConnections, conn)
    end

    -- aktifkan saat tool di equip
    tool.Equipped:Connect(function()
        blockOn = true
        local char = Player.Character or Player.CharacterAdded:Wait()
        local hum = char:WaitForChild("Humanoid")

        -- cleanup dulu
        for _,c in ipairs(blockConnections) do c:Disconnect() end
        table.clear(blockConnections)

        -- pasang listener touched di semua part tubuh
        for _,d in ipairs(char:GetDescendants()) do
            if d:IsA("BasePart") then
                hookTouchedOnPart(d, char, hum)
            end
        end

        -- deteksi landed
        table.insert(blockConnections, hum.StateChanged:Connect(function(_, new)
            if not blockOn or specialBlockActive then return end
            if new == Enum.HumanoidStateType.Landed then
                createLandedBlock(char)
            end
        end))

        -- kalau ada part baru
        table.insert(blockConnections, char.DescendantAdded:Connect(function(d)
            if d:IsA("BasePart") then
                hookTouchedOnPart(d, char, hum)
            end
        end))
    end)

    -- nonaktifkan saat tool unequipped
    tool.Unequipped:Connect(function()
        blockOn = false
        for _,c in ipairs(blockConnections) do c:Disconnect() end
        table.clear(blockConnections)

        -- hancurin semua block yang masih ada
        for _,b in ipairs(activeBlocks) do
            if b and b.Parent then
                b:Destroy()
            end
        end
        table.clear(activeBlocks)
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
            (hrp.Position + hrp.CFrame.LookVector * 1) - Vector3.new(0, truss.Size.Y/2, 0)
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
-- TOOL: Reverse (5 detik)
-- ==========================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer

local function createReverseTool()
    local tool = Instance.new("Tool")
    tool.Name = "Reverse"
    tool.RequiresHandle = false
    tool.Parent = Player.Backpack

    local buffer = {} -- simpan CFrame
    local maxSeconds = 5
    local fps = 60
    local maxFrames = maxSeconds * fps
    local recording = true
    local reverseActive = false
    local hrp

    -- rekam posisi tiap RenderStepped
    local conn
    local function startRecording()
        conn = RunService.RenderStepped:Connect(function()
            local char = Player.Character
            hrp = char and char:FindFirstChild("HumanoidRootPart")
            if recording and hrp then
                table.insert(buffer, hrp.CFrame)
                if #buffer > maxFrames then
                    table.remove(buffer, 1) -- buang frame paling lama
                end
            end
        end)
    end

    local function stopRecording()
        if conn then
            conn:Disconnect()
            conn = nil
        end
    end

    tool.Equipped:Connect(function()
        local char = Player.Character
        hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        -- stop recording saat reverse aktif
        recording = false
        reverseActive = true

        -- jalankan reverse
        task.spawn(function()
            for i = #buffer, 1, -1 do
                if not reverseActive or not hrp then break end
                hrp.CFrame = buffer[i] -- langsung set ke frame
                task.wait(1/fps)
            end
            reverseActive = false
            recording = true -- lanjut rekam lagi setelah selesai
        end)
    end)

    tool.Unequipped:Connect(function()
        reverseActive = false
        recording = true
    end)

    -- start rekam otomatis
    startRecording()
end

-- ==========================
-- TOOL: Pil (Regen + Kebal saat aktif)
-- ==========================
local function createPilTool()
    local tool = Instance.new("Tool")
    tool.Name = "Pil"
    tool.RequiresHandle = false
    tool.Parent = Player.Backpack

    local hum
    local stats
    local thirst, energy
    local active = false
    local aura
    local healthConn

    -- fungsi regen pintar
    local function regenLoop()
        while active and hum do
            -- regen cepat (hanya sampai full)
            if hum.Health < hum.MaxHealth then
                hum.Health = math.min(hum.MaxHealth, hum.Health + (hum.MaxHealth / 40))
            end

            -- leaderstats bonus
            if thirst and thirst.Value < 100 then
                thirst.Value = math.min(100, thirst.Value + 2)
            end
            if energy and energy.Value < 100 then
                energy.Value = math.min(100, energy.Value + 2)
            end

            task.wait(0.1)
        end
    end

    -- efek aura hijau
    local function createAura(char)
        if aura then aura:Destroy() end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        aura = Instance.new("ParticleEmitter")
        aura.Name = "PilAura"
        aura.Texture = "rbxassetid://241594419"
        aura.Color = ColorSequence.new(Color3.fromRGB(0,255,0))
        aura.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.5),
            NumberSequenceKeypoint.new(1, 1)
        })
        aura.Size = NumberSequence.new(1.5)
        aura.LightEmission = 0.7
        aura.Rate = 20
        aura.Lifetime = NumberRange.new(0.5, 1)
        aura.Speed = NumberRange.new(0,0)
        aura.Rotation = NumberRange.new(0,360)
        aura.RotSpeed = NumberRange.new(-30,30)
        aura.Parent = hrp
    end

    local function removeAura()
        if aura then
            aura:Destroy()
            aura = nil
        end
    end

    tool.Equipped:Connect(function()
        local char = Player.Character or Player.CharacterAdded:Wait()
        hum = char:WaitForChild("Humanoid")

        stats = Player:FindFirstChild("leaderstats")
        thirst = stats and stats:FindFirstChild("Thirst") or nil
        energy = stats and stats:FindFirstChild("Energy") or nil

        active = true
        task.spawn(regenLoop)
        createAura(char)

        -- aktifkan kebal: kalau health turun, langsung balikin
        healthConn = hum.HealthChanged:Connect(function(hp)
            if active and hp < hum.MaxHealth then
                hum.Health = hum.MaxHealth
            end
        end)
    end)

    tool.Unequipped:Connect(function()
        active = false
        removeAura()

        if healthConn then
            healthConn:Disconnect()
            healthConn = nil
        end

        -- reset normal (tapi tetap isi penuh)
        if hum then
            hum.Health = hum.MaxHealth
        end
        if thirst then thirst.Value = 100 end
        if energy then energy.Value = 100 end
    end)
end

-- ==========================
-- TOOL: Spider (Grapple Hook)
-- ==========================
local function createSpiderTool()
    local tool = Instance.new("Tool")
    tool.Name = "Spider"
    tool.RequiresHandle = false
    tool.Parent = Player.Backpack

    local mouse = Player:GetMouse()
    local char, hrp
    local conn

    tool.Equipped:Connect(function()
        char = Player.Character or Player.CharacterAdded:Wait()
        hrp = char:WaitForChild("HumanoidRootPart")

        -- aktifkan mode targeting (klik kiri)
        conn = mouse.Button1Down:Connect(function()
            if not hrp then return end
            local targetPos = mouse.Hit and mouse.Hit.Position
            if not targetPos then return end

            -- buat attachment + rope visual (opsional)
            local attachment0 = Instance.new("Attachment", hrp)
            local rope = Instance.new("Beam")
            rope.Attachment0 = attachment0
            rope.FaceCamera = true
            rope.Width0, rope.Width1 = 0.2, 0.2
            rope.Color = ColorSequence.new(Color3.new(1,1,1))
            rope.Parent = hrp

            local targetPart = Instance.new("Part")
            targetPart.Anchored = true
            targetPart.CanCollide = false
            targetPart.Transparency = 1
            targetPart.Position = targetPos
            targetPart.Parent = workspace

            local attachment1 = Instance.new("Attachment", targetPart)
            rope.Attachment1 = attachment1

            -- tarik ke arah target (tween biar smooth)
            local tweenService = game:GetService("TweenService")
            local distance = (targetPos - hrp.Position).Magnitude
            local time = math.clamp(distance / 100, 0.3, 2) -- makin jauh makin lama

            local tween = tweenService:Create(hrp, TweenInfo.new(time, Enum.EasingStyle.Linear), {
                CFrame = CFrame.new(targetPos + Vector3.new(0, 5, 0)) -- sedikit di atas biar tidak nabrak tanah
            })
            tween:Play()
            tween.Completed:Connect(function()
                rope:Destroy()
                attachment0:Destroy()
                targetPart:Destroy()
            end)
        end)
    end)

    tool.Unequipped:Connect(function()
        if conn then conn:Disconnect() end
        conn = nil
    end)
end

-- ==========================
-- TOOL: Jumper (Teleport)
-- ==========================
local function createJumperTool()
    local tool = Instance.new("Tool")
    tool.Name = "Jumper"
    tool.RequiresHandle = false
    tool.Parent = Player.Backpack

    local mouse = Player:GetMouse()
    local char, hrp
    local conn

    tool.Equipped:Connect(function()
        char = Player.Character or Player.CharacterAdded:Wait()
        hrp = char:WaitForChild("HumanoidRootPart")

        -- aktifkan mode targeting (klik kiri)
        conn = mouse.Button1Down:Connect(function()
            if not hrp then return end
            local targetPos = mouse.Hit and mouse.Hit.Position
            if not targetPos then return end

            -- teleport langsung 5 stud di atas target
            hrp.CFrame = CFrame.new(targetPos + Vector3.new(0, 5, 0))
        end)
    end)

    tool.Unequipped:Connect(function()
        if conn then conn:Disconnect() end
        conn = nil
    end)
end

-- ==========================
-- TOOL: Pro J (Parabola Jump)
-- ==========================
local function createProJTool()
    local tool = Instance.new("Tool")
    tool.Name = "Pro J"
    tool.RequiresHandle = false
    tool.Parent = Player.Backpack

    local mouse = Player:GetMouse()
    local conn

    tool.Equipped:Connect(function()
        local char = Player.Character or Player.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")
        local hum = char:WaitForChild("Humanoid")

        conn = mouse.Button1Down:Connect(function()
            if not hrp then return end
            local targetPos = mouse.Hit and mouse.Hit.Position
            if not targetPos then return end

            -- hitung jarak & durasi
            local distance = (targetPos - hrp.Position).Magnitude
            local duration = math.clamp(distance / 60, 0.6, 2)

            -- ketinggian loncat
            local peakHeight = math.max(8, distance / 3)

            local startPos = hrp.Position
            local endPos = targetPos + Vector3.new(0, 3, 0) -- landing di atas tanah

            -- rotasi: hadap ke target
            local lookDir = (Vector3.new(endPos.X, startPos.Y, endPos.Z) - startPos).Unit

            hum.AutoRotate = false -- biar rotasi konsisten ke depan
            hrp.CFrame = CFrame.new(startPos, startPos + lookDir)

            -- jalankan parabola frame by frame
            local startTime = tick()
            local heartbeat = game:GetService("RunService").Heartbeat
            task.spawn(function()
                while true do
                    local t = (tick() - startTime) / duration
                    if t > 1 then break end

                    -- interpolasi linear XZ
                    local pos = startPos:Lerp(endPos, t)
                    -- tambahkan parabola di Y
                    local height = -4 * peakHeight * (t - 0.5)^2 + peakHeight
                    pos = Vector3.new(pos.X, pos.Y + height, pos.Z)

                    hrp.CFrame = CFrame.new(pos, pos + lookDir)
                    heartbeat:Wait()
                end

                -- set posisi akhir fix
                hrp.CFrame = CFrame.new(endPos, endPos + lookDir)
                hum.AutoRotate = true
            end)
        end)
    end)

    tool.Unequipped:Connect(function()
        if conn then conn:Disconnect() end
        conn = nil
    end)
end


-- ==========================
-- Fungsi Load Semua Tools
-- ==========================
local function loadAllTools()
createProJTool()
createSpeedTool()
createJumperTool()
createFreezeTool()
createBlockTool()
createVisionTool()
createReverseTool()
createTowerTool()
createPilTool()
createCarpetTool()
createSpiderTool()
createLeaderboardTool()
end

-- langsung load saat pertama kali script jalan
loadAllTools()

-- Pastikan setelah respawn tools tetap ada
Player.CharacterAdded:Connect(function()
    task.wait(1) -- tunggu karakter selesai spawn
    loadAllTools()
end)
