local player = game.Players.LocalPlayer
local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 100, 0, 50)
button.Position = UDim2.new(0.5, -50, 0.9, 0) -- di bawah tengah
button.Text = "UP"
button.BackgroundTransparency = 0.3
button.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("ScreenGui")

button.MouseButton1Click:Connect(function()
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char:MoveTo(char.HumanoidRootPart.Position + Vector3.new(0, 10, 0))
    end
end)
