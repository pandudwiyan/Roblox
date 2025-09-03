-- LocalScript di StarterGui

local player = game.Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "CustomPanel"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- Panel utama (dibesarkan biar tombol muat)
local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 550, 0, 100) -- lebar lebih besar supaya semua tombol muat
panel.Position = UDim2.new(0.5, -275, 1, -120) -- tengah bawah layar
panel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
panel.BorderSizePixel = 0
panel.Active = true
panel.Draggable = true
panel.Parent = gui

-- Titlebar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 20)
titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
titleBar.BorderSizePixel = 0
titleBar.Parent = panel

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -50, 1, 0)
titleLabel.Position = UDim2.new(0, 8, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Control Panel"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 14
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

-- Tombol close
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 20, 1, 0)
closeBtn.Position = UDim2.new(1, -22, 0, 0)
closeBtn.Text = "X"
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextScaled = true
closeBtn.Parent = titleBar

-- Tombol minimize
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 20, 1, 0)
minimizeBtn.Position = UDim2.new(1, -44, 0, 0)
minimizeBtn.Text = "-"
minimizeBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.TextScaled = true
minimizeBtn.Parent = titleBar

-- Container tombol
local buttonHolder = Instance.new("Frame")
buttonHolder.Size = UDim2.new(1, -10, 1, -30)
buttonHolder.Position = UDim2.new(0, 5, 0, 25)
buttonHolder.BackgroundTransparency = 1
buttonHolder.Parent = panel

-- Layout horizontal
local uiList = Instance.new("UIListLayout")
uiList.FillDirection = Enum.FillDirection.Horizontal
uiList.HorizontalAlignment = Enum.HorizontalAlignment.Center
uiList.VerticalAlignment = Enum.VerticalAlignment.Center
uiList.SortOrder = Enum.SortOrder.LayoutOrder
uiList.Padding = UDim.new(0, 5)
uiList.Parent = buttonHolder

-- Nama tombol
local buttonNames = {"Kekai", "Freeze", "H Ladder", "Inventory", "Snap C", "Teleport", "Spectate"}

for _, name in ipairs(buttonNames) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 70, 0, 40) -- dibesarkan biar lebih rapi
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = name
    btn.TextSize = 12
    btn.Font = Enum.Font.SourceSansSemibold
    btn.Parent = buttonHolder
end

-- MAIN FUNCTION
-- fungsi tombol kekai
local kekaiOn = false
local originalProperties = {} -- untuk simpan kondisi semula
local kekaiBtn            -- <-- penting: deklarasi dulu supaya applyKekai menangkap variabel lokal ini

-- pastikan attribute status ada
if player:GetAttribute("KekaiOn") == nil then
    player:SetAttribute("KekaiOn", false)
end

-- fungsi apply / reset
local function applyKekai(state)
    kekaiOn = state
    player:SetAttribute("KekaiOn", kekaiOn)

    -- guard kalau tombol belum ketemu / hilang
    if not (kekaiBtn and kekaiBtn.Parent) then return end

    if kekaiOn then
        -- ubah tombol jadi hijau
        kekaiBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)

        -- simpan kondisi awal & ubah tampilannya
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                if not originalProperties[obj] then
                    originalProperties[obj] = {
                        Transparency = obj.Transparency,
                        Color = obj.Color
                    }
                end
                obj.Transparency = 0
                if obj.CanCollide then
                    obj.Color = Color3.fromRGB(0, 255, 0) -- hijau untuk yang bisa dipijak
                end
            end
        end
    else
        -- ubah tombol kembali ke abu-abu
        kekaiBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)

        -- kembalikan kondisi semula
        for part, props in pairs(originalProperties) do
            if part and part.Parent then
                part.Transparency = props.Transparency
                part.Color = props.Color
            end
        end
    end
end

-- cari tombol "Kekai" yang sudah dibuat di buttonHolder
for _, child in ipairs(buttonHolder:GetChildren()) do
    if child:IsA("TextButton") and child.Text == "Kekai" then
        kekaiBtn = child
        break
    end
end

if kekaiBtn then
    -- toggle saat diklik
    kekaiBtn.MouseButton1Click:Connect(function()
        applyKekai(not kekaiOn)
    end)

    -- set ulang status saat GUI dibuat (misal setelah respawn)
    applyKekai(player:GetAttribute("KekaiOn"))
else
    warn("Tombol 'Kekai' tidak ditemukan.")
end
-- end kekai

-- fungsi tombol freeze
local freezeOn = false
local freezeOriginal = {} -- simpan kondisi awal anchored
local freezeBtn

-- pastikan attribute status ada
if player:GetAttribute("FreezeOn") == nil then
    player:SetAttribute("FreezeOn", false)
end

-- helper: cek apakah part milik humanoid
local function isPartOfHumanoid(part)
    local model = part:FindFirstAncestorOfClass("Model")
    if model and model:FindFirstChildOfClass("Humanoid") then
        return true
    end
    return false
end

-- fungsi apply / reset freeze
local function applyFreeze(state)
    freezeOn = state
    player:SetAttribute("FreezeOn", freezeOn)

    if not (freezeBtn and freezeBtn.Parent) then return end

    if freezeOn then
        -- ubah tombol jadi hijau
        freezeBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)

        -- simpan kondisi awal & ubah anchored
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not isPartOfHumanoid(obj) then
                if not freezeOriginal[obj] then
                    freezeOriginal[obj] = obj.Anchored
                end
                if not obj.Anchored then
                    obj.Anchored = true
                end
            end
        end
    else
        -- ubah tombol kembali ke abu-abu
        freezeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)

        -- kembalikan kondisi anchored semula
        for part, wasAnchored in pairs(freezeOriginal) do
            if part and part.Parent then
                part.Anchored = wasAnchored
            end
        end
    end
end

-- cari tombol "Freeze" yang sudah dibuat di buttonHolder
for _, child in ipairs(buttonHolder:GetChildren()) do
    if child:IsA("TextButton") and child.Text == "Freeze" then
        freezeBtn = child
        break
    end
end

if freezeBtn then
    -- toggle saat diklik
    freezeBtn.MouseButton1Click:Connect(function()
        applyFreeze(not freezeOn)
    end)

    -- saat pertama kali GUI dibuat → reset OFF
    applyFreeze(false)

    -- reset otomatis saat respawn (character added)
    player.CharacterAdded:Connect(function()
        applyFreeze(false)
        player:SetAttribute("FreezeOn", false)
        if freezeBtn then
            freezeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        end
    end)
else
    warn("Tombol 'Freeze' tidak ditemukan.")
end
-- end freeze

-- fungsi tombol H Ladder
local hLadderState = 0 -- 0=off, 1=growing, 2=stop growth
local ladderPart = nil
local ladderConnection = nil
local hLadderBtn

-- cari tombol "H Ladder"
for _, child in ipairs(buttonHolder:GetChildren()) do
    if child:IsA("TextButton") and child.Text == "H Ladder" then
        hLadderBtn = child
        break
    end
end

-- fungsi utama
local function applyHLadder(state)
    hLadderState = state

    if not (hLadderBtn and hLadderBtn.Parent) then return end

    -- reset semua dulu
    if ladderConnection then
        ladderConnection:Disconnect()
        ladderConnection = nil
    end

    if state == 0 then
        -- OFF
        hLadderBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        if ladderPart then
            ladderPart:Destroy()
            ladderPart = nil
        end

    elseif state == 1 then
        -- Growing
        hLadderBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)

        -- spawn truss jika belum ada
        if not ladderPart then
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local hrp = char.HumanoidRootPart

                ladderPart = Instance.new("TrussPart")
                ladderPart.Size = Vector3.new(4, 20, 4)
                ladderPart.Anchored = true
                ladderPart.CanCollide = true
                ladderPart.Position = (hrp.Position + hrp.CFrame.LookVector * 2) -- 2 stud di depan player
                ladderPart.Position = Vector3.new(ladderPart.Position.X, hrp.Position.Y - 5, ladderPart.Position.Z)
                ladderPart.Parent = workspace
            end
        end

        -- jalankan loop growth
        ladderConnection = game:GetService("RunService").Heartbeat:Connect(function()
            if ladderPart and ladderPart.Parent then
                local char = player.Character
                if char and char:FindFirstChild("Head") then
                    local head = char.Head
                    local topY = ladderPart.Position.Y + ladderPart.Size.Y/2
                    if (topY - head.Position.Y) < 5 then
                        -- tambah tinggi 10 stud
                        ladderPart.Size = ladderPart.Size + Vector3.new(0, 10, 0)
                        ladderPart.CFrame = CFrame.new(ladderPart.Position) -- pastikan center tetap
                    end
                end
            end
        end)

    elseif state == 2 then
        -- Stop growth
        hLadderBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        -- ladder tetap ada tapi tidak ada loop growth
    end
end

-- klik toggle 0 -> 1 -> 2 -> 0
if hLadderBtn then
    hLadderBtn.MouseButton1Click:Connect(function()
        local nextState = (hLadderState + 1) % 3
        applyHLadder(nextState)
    end)

    -- saat pertama kali GUI dibuat → reset OFF
    applyHLadder(0)

    -- reset otomatis saat respawn
    player.CharacterAdded:Connect(function()
        applyHLadder(0)
    end)
else
    warn("Tombol 'H Ladder' tidak ditemukan.")
end
-- end

-- fungsi tombol Inventory (client-side only)
local inventoryOn = false
local givers = {} -- simpan part giver biar bisa dihapus lagi

-- helper: bikin tool Speed Coil
local function createSpeedCoil()
    local tool = Instance.new("Tool")
    tool.Name = "Speed Coil"
    tool.RequiresHandle = false

    tool.Activated:Connect(function()
        local char = player.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                if hum.WalkSpeed <= 16 then
                    hum.WalkSpeed = 50
                else
                    hum.WalkSpeed = 16
                end
            end
        end
    end)

    return tool
end

-- helper: bikin tool Fly Coil
local function createFlyCoil()
    local tool = Instance.new("Tool")
    tool.Name = "Fly Coil"
    tool.RequiresHandle = false

    local flying = false
    local bodyVel

    tool.Activated:Connect(function()
        local char = player.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                flying = not flying
                if flying then
                    bodyVel = Instance.new("BodyVelocity")
                    bodyVel.Velocity = Vector3.new(0, 50, 0) -- dorong ke atas
                    bodyVel.MaxForce = Vector3.new(0, math.huge, 0)
                    bodyVel.Parent = hrp
                else
                    if bodyVel then bodyVel:Destroy() end
                end
            end
        end
    end)

    return tool
end

-- fungsi spawn / hapus giver
local function applyInventory(state)
    inventoryOn = state
    if not inventoryBtn then return end

    if inventoryOn then
        inventoryBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)

        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local hrp = char.HumanoidRootPart
            local basePos = hrp.Position + hrp.CFrame.LookVector * 8

            -- kotak merah (Fly giver)
            local redBox = Instance.new("Part")
            redBox.Size = Vector3.new(4, 1, 4)
            redBox.Color = Color3.fromRGB(200, 0, 0)
            redBox.Anchored = true
            redBox.Position = basePos + Vector3.new(-3, 0, 0)
            redBox.Parent = workspace
            table.insert(givers, redBox)

            redBox.Touched:Connect(function(hit)
                local plrChar = hit.Parent
                if plrChar == char then
                    if not player.Backpack:FindFirstChild("Fly Coil") then
                        createFlyCoil().Parent = player.Backpack
                    end
                end
            end)

            -- kotak biru (Speed giver)
            local blueBox = Instance.new("Part")
            blueBox.Size = Vector3.new(4, 1, 4)
            blueBox.Color = Color3.fromRGB(0, 0, 200)
            blueBox.Anchored = true
            blueBox.Position = basePos + Vector3.new(3, 0, 0)
            blueBox.Parent = workspace
            table.insert(givers, blueBox)

            blueBox.Touched:Connect(function(hit)
                local plrChar = hit.Parent
                if plrChar == char then
                    if not player.Backpack:FindFirstChild("Speed Coil") then
                        createSpeedCoil().Parent = player.Backpack
                    end
                end
            end)
        end
    else
        inventoryBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        -- hapus giver yang ada
        for _, part in ipairs(givers) do
            if part and part.Parent then
                part:Destroy()
            end
        end
        givers = {}
    end
end

-- cari tombol "Inventory"
for _, child in ipairs(buttonHolder:GetChildren()) do
    if child:IsA("TextButton") and child.Text == "Inventory" then
        inventoryBtn = child
        break
    end
end

if inventoryBtn then
    inventoryBtn.MouseButton1Click:Connect(function()
        applyInventory(not inventoryOn)
    end)
    applyInventory(false)
else
    warn("Tombol 'Inventory' tidak ditemukan.")
end

-- END


-- Fungsi close
closeBtn.MouseButton1Click:Connect(function()
    panel.Visible = false
end)

-- Fungsi minimize
local minimized = false
minimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        buttonHolder.Visible = false
        panel.Size = UDim2.new(0, 550, 0, 20)
    else
        buttonHolder.Visible = true
        panel.Size = UDim2.new(0, 550, 0, 100)
    end
end)
