--// Reveal Hidden Obstacles (Studio-safe, client-only)
--// Menjadikan part yang "tak terlihat" (Transparency ~1) menjadi 20% terlihat (0.8 transparency) di client.
--// Target: BasePart yang CanCollide/CanTouch/CanQuery (umumnya rintangan), agar tidak ganggu dekorasi non-kolisi.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- =============== CONFIG =============== --
local VISIBLE_PERCENT = 0.20            -- ingin terlihat 20%
local TARGET_ALPHA   = 1 - VISIBLE_PERCENT -- => 0.8 (80% transparan)
local INVISIBLE_EPS  = 0.98             -- ambang dianggap "tak terlihat" (≈ 100%)

-- =============== UI =================== --
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RevealHiddenUI"
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player:WaitForChild("PlayerGui")

local button = Instance.new("TextButton")
button.Name = "Reveal20Button"
button.Size = UDim2.fromOffset(120, 40)
button.AnchorPoint = Vector2.new(1, 0)
button.Position = UDim2.new(1, -12, 0, 12) -- pojok kanan atas
button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.TextScaled = true
button.Font = Enum.Font.GothamBold
button.Text = "Reveal 20%"
button.AutoButtonColor = true
button.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = button

-- Draggable (mouse & touch)
do
    local dragging = false
    local dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        button.Position = UDim2.fromOffset(startPos.X.Offset + delta.X, startPos.Y.Offset + delta.Y)
        button.AnchorPoint = Vector2.new(0, 0)
    end
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = UDim2.fromOffset(button.AbsolutePosition.X, button.AbsolutePosition.Y)
        end
    end)
    button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
end

-- =============== CORE LOGIC =============== --
-- Kita hanya mengubah LocalTransparencyModifier (client-only), tidak mengubah Transparency asli (server).
-- Simpan nilai LocalTransparencyModifier asli agar bisa dikembalikan.

local tracked = {}  -- [BasePart] = originalLocalTransparencyModifier (number)
local revealed = false

local function isHiddenObstacle(part: BasePart): boolean
    if not part:IsA("BasePart") then return false end
    -- Fokus ke sesuatu yang mungkin jadi rintangan/sengaja disembunyikan:
    local isObstacle = (part.CanCollide or part.CanTouch or part.CanQuery)
    if not isObstacle then return false end
    -- Dianggap "tak terlihat" jika Transparency atau LTM mendekati 1
    local visuallyInvisible = (part.Transparency >= INVISIBLE_EPS) or (part.LocalTransparencyModifier >= INVISIBLE_EPS)
    return visuallyInvisible
end

local function applyReveal(part: BasePart)
    if tracked[part] ~= nil then
        -- sudah ditracking; pastikan tetap di target
        part.LocalTransparencyModifier = TARGET_ALPHA
        return
    end
    -- simpan nilai LTM asli
    tracked[part] = part.LocalTransparencyModifier
    part.LocalTransparencyModifier = TARGET_ALPHA
end

local function revertPart(part: BasePart)
    local orig = tracked[part]
    if orig ~= nil then
        -- restore ke nilai semula
        part.LocalTransparencyModifier = orig
        tracked[part] = nil
    end
end

local function scanAndApply()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            if revealed then
                if isHiddenObstacle(obj) then
                    applyReveal(obj)
                else
                    -- Jika bukan target, tapi pernah ditracking, balikin
                    if tracked[obj] ~= nil then
                        revertPart(obj)
                    end
                end
            else
                -- Mode OFF: kembalikan semua yang sedang ditracking
                if tracked[obj] ~= nil then
                    revertPart(obj)
                end
            end
        end
    end
end

-- Rescan berkala buat part baru / perubahan status
task.spawn(function()
    while true do
        task.wait(1.0)
        scanAndApply()
    end
end)

-- Bersihkan saat part dihapus
workspace.DescendantRemoving:Connect(function(inst)
    if tracked[inst] ~= nil then
        tracked[inst] = nil
    end
end)

-- Toggle tombol
button.MouseButton1Click:Connect(function()
    revealed = not revealed
    button.Text = revealed and "Back Hidden" or "Reveal 20%"
    scanAndApply()
end)

-- Start dalam keadaan OFF (tidak mengubah apa pun). Klik untuk mengungkap 20%.
