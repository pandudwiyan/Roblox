--// Teleport GUI Script (Delta Exploit)
--// Checkpoint Version (CP13 - CP40)

if game.CoreGui:FindFirstChild("TeleportUI") then
    game.CoreGui.TeleportUI:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "TeleportUI"
gui.Parent = game.CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 450)
frame.Position = UDim2.new(0, 50, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 2
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
title.Text = "Teleport Panel"
title.TextColor3 = Color3.fromRGB(255, 255, 0)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.Parent = frame

local function teleportTo(pos)
    local player = game.Players.LocalPlayer
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(pos)
    end
end

-- Daftar checkpoint urut CP13 - CP40
local checkpoints = {
    {"CP13", Vector3.new(-613.79, 3286.17, 1919.97)},
    {"CP14", Vector3.new(-237.50, 3405.37, 2578.94)},
    {"CP15", Vector3.new(309.96, 3542.17, 3041.96)},
    {"CP16", Vector3.new(439.63, 3598.17, 3562.56)},
    {"CP17", Vector3.new(913.02, 3666.17, 4151.22)},
    {"CP18", Vector3.new(1422.11, 3906.17, 4996.96)},
    {"CP19", Vector3.new(1668.22, 4286.17, 5193.27)},
    {"CP20", Vector3.new(1721.12, 4469.97, 5171.88)},
    {"CP21", Vector3.new(1862.86, 4654.09, 5201.69)},
    {"CP22", Vector3.new(1900.72, 4962.17, 5156.13)},
    {"CP23", Vector3.new(2847.50, 5074.17, 5241.92)},
    {"CP24", Vector3.new(3459.49, 5242.17, 5121.06)},
    {"CP25", Vector3.new(4578.36, 5478.17, 5267.37)},
    {"CP26", Vector3.new(4635.98, 4950.05, 5235.59)},
    {"CP27", Vector3.new(4626.76, 4565.76, 5243.68)},
    {"CP28 (Water)", Vector3.new(4880.66, 3985.86, 5184.27)},
    {"CP29", Vector3.new(5830.06, 3997.85, 5741.35)},
    {"CP30", Vector3.new(6632.73, 4223.57, 5577.83)},
    {"CP31", Vector3.new(7474.53, 4223.10, 5305.50)},
    {"CP32", Vector3.new(8210.79, 4330.17, 4893.81)},
    {"CP33", Vector3.new(8696.03, 4482.11, 4545.91)},
    {"CP34", Vector3.new(8786.96, 4538.16, 4347.60)},
    {"CP35", Vector3.new(9198.62, 5074.17, 2466.44)},
    {"CP36", Vector3.new(9188.99, 5321.94, 2460.10)},
    {"CP37", Vector3.new(9079.95, 5893.41, 2041.92)},
    {"CP38", Vector3.new(9188.45, 6217.98, 1988.47)},
    {"CP39", Vector3.new(9062.20, 6498.57, 1827.87)},
    {"CP40", Vector3.new(8697.10, 6530.01, 1292.58)},
    {"CP41", Vector3.new(8396.11, 6557.98, 1144.27)},
    {"CP42", Vector3.new(7993.31, 6608.77, 1015.79)},
    {"CP43", Vector3.new(7139.38, 6774.17, 375.86)},
    {"CP44", Vector3.new(6572.58, 6967.02, 255.21)},
    {"CP45", Vector3.new(6040.21, 6966.17, 251.92)},
    {"CP46", Vector3.new(4873.80, 7146.17, 680.08)},
    {"CP47", Vector3.new(5396.93, 8109.97, 2205.45)},
}

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -10, 1, -40)
scroll.Position = UDim2.new(0, 5, 0, 35)
scroll.CanvasSize = UDim2.new(0, 0, 0, #checkpoints * 35)
scroll.ScrollBarThickness = 6
scroll.Parent = frame

for i, cp in ipairs(checkpoints) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 30)
    btn.Position = UDim2.new(0, 5, 0, (i-1)*35)
    btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 16
    btn.Text = cp[1]
    btn.Parent = scroll

    btn.MouseButton1Click:Connect(function()
        teleportTo(cp[2])
    end)
end
