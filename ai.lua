--// Auto Play / Auto Move AI
-- by ChatGPT

local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local LocalPlayer = Players.LocalPlayer
local Humanoid = LocalPlayer.Character:WaitForChild("Humanoid")
local HRP = LocalPlayer.Character:WaitForChild("HumanoidRootPart")

-- UI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 180, 0, 60)
Frame.Position = UDim2.new(1, -200, 0, 50)
Frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
Frame.Active = true
Frame.Draggable = true

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1,0,0,25)
Title.BackgroundColor3 = Color3.fromRGB(45,45,45)
Title.Text = "🤖 AutoPlay AI"
Title.TextColor3 = Color3.new(1,1,1)

local Toggle = Instance.new("TextButton", Frame)
Toggle.Size = UDim2.new(1,-20,0,25)
Toggle.Position = UDim2.new(0,10,0,30)
Toggle.Text = "AutoPlay [OFF]"
Toggle.BackgroundColor3 = Color3.fromRGB(60,60,60)
Toggle.TextColor3 = Color3.new(1,1,1)

local Close = Instance.new("TextButton", Frame)
Close.Size = UDim2.new(0,25,0,25)
Close.Position = UDim2.new(1,-25,0,0)
Close.Text = "X"
Close.TextColor3 = Color3.fromRGB(1,0.3,0.3)

-- logic toggle
local running = false
Toggle.MouseButton1Click:Connect(function()
    running = not running
    Toggle.Text = "AutoPlay ["..(running and "ON" or "OFF").."]"
    Toggle.BackgroundColor3 = running and Color3.fromRGB(80,150,80) or Color3.fromRGB(60,60,60)
end)
Close.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- AI routine
task.spawn(function()
    while task.wait(2) do
        if running then
            -- cari part terdekat yang bisa dipijak
            local closest, dist = nil, math.huge
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and obj.CanCollide and obj.Size.Magnitude > 5 then
                    local d = (obj.Position - HRP.Position).Magnitude
                    if d < dist and d < 100 then
                        dist = d
                        closest = obj
                    end
                end
            end

            if closest then
                -- bikin path ke object itu
                local path = PathfindingService:CreatePath()
                path:ComputeAsync(HRP.Position, closest.Position)

                if path.Status == Enum.PathStatus.Success then
                    local waypoints = path:GetWaypoints()
                    for _, wp in ipairs(waypoints) do
                        if not running then break end
                        Humanoid:MoveTo(wp.Position)
                        Humanoid.MoveToFinished:Wait()
                    end
                end
            end
        end
    end
end)
