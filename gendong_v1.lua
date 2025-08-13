-- Auto Grab Nearest Player (Delta Executor)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function getNearestPlayer()
    local nearest, dist = nil, math.huge
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return nil end
    local myPos = myChar.HumanoidRootPart.Position

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local targetPos = plr.Character.HumanoidRootPart.Position
            local mag = (myPos - targetPos).Magnitude
            if mag < dist then
                dist = mag
                nearest = plr
            end
        end
    end
    return nearest
end

print("Tekan tombol X untuk menghentikan Auto Grab.")

local running = true

-- Tombol stop
game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.X then
        running = false
        print("Auto Grab dihentikan.")
    end
end)

while running do
    local target = getNearestPlayer()
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local targetHRP = target.Character.HumanoidRootPart
        local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if myHRP then
            targetHRP.CFrame = myHRP.CFrame * CFrame.new(0, 0, -3) -- 3 stud di depan
            targetHRP.AssemblyLinearVelocity = Vector3.zero
            targetHRP.AssemblyAngularVelocity = Vector3.zero
        end
    end
    task.wait()
end
