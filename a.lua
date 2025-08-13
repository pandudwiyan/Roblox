-- Object Scanner v3 (Workspace-only)
-- Fitur: Scan ClassName → list instance → teleport, draggable, scroll, minimize

-- Hapus GUI lama
local parentGui = (gethui and gethui()) or game:FindFirstChildOfClass("CoreGui")
if parentGui:FindFirstChild("ObjectScanner") then parentGui.ObjectScanner:Destroy() end

local Players = game:GetService("Players")
local UIS     = game:GetService("UserInputService")
local LP      = Players.LocalPlayer

-- ===== GUI =====
local gui = Instance.new("ScreenGui")
gui.Name = "ObjectScanner"
gui.ResetOnSpawn = false
gui.Parent = parentGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 320, 0, 420)
main.Position = UDim2.new(0.3, 0, 0.25, 0)
main.BackgroundColor3 = Color3.fromRGB(35,35,35)
main.BorderSizePixel = 0
main.Parent = gui

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 32)
header.BackgroundColor3 = Color3.fromRGB(140, 0, 0)
header.BorderSizePixel = 0
header.Parent = main

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Position = UDim2.new(0, 8, 0, 0)
title.Size = UDim2.new(1, -96, 1, 0)
title.Text = "Object Scanner"
title.Font = Enum.Font.SourceSansBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextColor3 = Color3.new(1,1,1)
title.Parent = header

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 32, 1, 0)
minBtn.Position = UDim2.new(1, -64, 0, 0)
minBtn.Text = "-"
minBtn.TextColor3 = Color3.new(1,1,1)
minBtn.BackgroundColor3 = Color3.fromRGB(110,0,0)
minBtn.Parent = header

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 32, 1, 0)
closeBtn.Position = UDim2.new(1, -32, 0, 0)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.BackgroundColor3 = Color3.fromRGB(170,0,0)
closeBtn.Parent = header

local body = Instance.new("Frame")
body.Size = UDim2.new(1, 0, 1, -32)
body.Position = UDim2.new(0, 0, 0, 32)
body.BackgroundTransparency = 1
body.Parent = main

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -12, 1, -12)
scroll.Position = UDim2.new(0, 6, 0, 6)
scroll.ScrollBarThickness = 8
scroll.BackgroundTransparency = 1
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.Parent = body

local layout = Instance.new("UIListLayout")
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 4)
layout.Parent = scroll

local scanBtn = Instance.new("TextButton")
scanBtn.Size = UDim2.new(1, -12, 0, 44)
scanBtn.Position = UDim2.new(0, 6, 0, 6)
scanBtn.Text = "🔍 Scan ClassName (Workspace)"
scanBtn.TextColor3 = Color3.new(1,1,1)
scanBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
scanBtn.Parent = body

local statusLbl = Instance.new("TextLabel")
statusLbl.BackgroundTransparency = 1
statusLbl.Size = UDim2.new(1, -12, 0, 20)
statusLbl.Position = UDim2.new(0, 6, 0, 56)
statusLbl.Text = ""
statusLbl.TextColor3 = Color3.fromRGB(200,200,200)
statusLbl.TextXAlignment = Enum.TextXAlignment.Left
statusLbl.Parent = body

-- ===== Drag (manual, biar pasti jalan) =====
do
    local dragging, startPos, startInput
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            startPos = input.Position
            startInput = input
        end
    end)
    header.InputEnded:Connect(function(input)
        if input == startInput then dragging = false end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - startPos
            startPos = input.Position
            main.Position = UDim2.new(
                main.Position.X.Scale, main.Position.X.Offset + delta.X,
                main.Position.Y.Scale, main.Position.Y.Offset + delta.Y
            )
        end
    end)
end

-- ===== Helpers =====
local function makeButton(text, height)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, height or 28)
    b.BackgroundColor3 = Color3.fromRGB(60,60,60)
    b.TextColor3 = Color3.new(1,1,1)
    b.TextWrapped = true
    b.Text = text
    b.Parent = scroll
    return b
end

local function clearList()
    for _, c in ipairs(scroll:GetChildren()) do
        if c:IsA("GuiObject") then c:Destroy() end
    end
end

local function tpToCFrame(cf)
    local char = LP.Character or LP.CharacterAdded:Wait()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        char:PivotTo(cf + Vector3.new(0, 3, 0))
    end
end

-- ===== Scan logic =====
local function scanClasses()
    statusLbl.Text = "Scanning classes..."
    clearList()
    task.wait()

    -- Hanya Workspace supaya nggak berat
    local counts = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        local c = obj.ClassName
        counts[c] = (counts[c] or 0) + 1
    end

    -- Urutkan by jumlah desc
    local arr = {}
    for cname, n in pairs(counts) do table.insert(arr, {cname, n}) end
    table.sort(arr, function(a,b) return a[2] > b[2] end)

    for _, item in ipairs(arr) do
        local cname, n = item[1], item[2]
        local btn = makeButton(string.format("%s : %d", cname, n))
        btn.MouseButton1Click:Connect(function()
            -- Scan khusus class ini
            statusLbl.Text = "Scanning "..cname.."..."
            clearList()
            task.spawn(function()
                local list = {}
                for _, o in ipairs(workspace:GetDescendants()) do
                    if o.ClassName == cname then table.insert(list, o) end
                end
                -- tombol back
                local back = makeButton("‹ Back to classes", 28)
                back.BackgroundColor3 = Color3.fromRGB(110,0,0)
                back.MouseButton1Click:Connect(function()
                    clearList()
                    scanClasses()
                end)

                -- tampilkan instance
                for i, o in ipairs(list) do
                    local label = o.Name ~= "" and o.Name or ("(no name)")
                    local ib = makeButton(string.format("%s #%d  (%s)", cname, i, label), 28)
                    ib.MouseButton1Click:Connect(function()
                        -- Tentukan CFrame tujuan
                        local cf
                        if o:IsA("BasePart") then
                            cf = o.CFrame
                        elseif o:IsA("Model") then
                            cf = o:GetPivot()
                        elseif o:IsA("Attachment") then
                            cf = CFrame.new(o.WorldPosition)
                        elseif o:IsA("Humanoid") and o.Parent then
                            local hrp = o.Parent:FindFirstChild("HumanoidRootPart")
                            if hrp then cf = hrp.CFrame end
                        elseif o:IsA("Decal") and o.Parent and o.Parent:IsA("BasePart") then
                            cf = o.Parent.CFrame
                        end
                        if cf then tpToCFrame(cf) else
                            statusLbl.Text = "Tidak bisa teleport ke objek ini."
                        end
                    end)
                end
                statusLbl.Text = ("Found %d %s"):format(#list, cname)
            end)
        end)
    end

    statusLbl.Text = "Done."
end

-- ===== Buttons =====
scanBtn.MouseButton1Click:Connect(function()
    scanBtn.Visible = false
    statusLbl.Text = ""
    scroll.Visible = true
    scanClasses()
end)

minBtn.MouseButton1Click:Connect(function()
    body.Visible = not body.Visible
    main.Size = body.Visible and UDim2.new(0,320,0,420) or UDim2.new(0,320,0,32)
end)

closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- Awal: hanya tombol scan yang kelihatan
scroll.Visible = false
statusLbl.Text = "Klik 'Scan ClassName' untuk mulai."
