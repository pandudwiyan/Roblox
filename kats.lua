-- === Script Button Spawn Part di Depan Karakter ===
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ==== Buat GUI ====
local gui = Instance.new("ScreenGui")
gui.Name = "SpawnPartUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true

local parentContainer = (gethui and gethui()) or game:FindFirstChildOfClass("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")
gui.Parent = parentContainer

-- ==== Buat Tombol ====
local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 150, 0, 50)
button.Position = UDim2.new(0.5, -75, 0.8, 0)
button.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
button.Text = "Spawn Part"
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.BorderSizePixel = 0
button.Parent = gui

do
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 12)
	c.Parent = button
end

-- ==== Fungsi Spawn Part ====
local function spawnPartInFront()
	if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
		local hrp = LocalPlayer.Character.HumanoidRootPart
		
		-- Buat Part
		local part = Instance.new("Part")
		part.Size = Vector3.new(10, 10, 10)
		part.Anchored = true
		part.Color = Color3.fromRGB(255, 0, 0)
		part.Position = (hrp.CFrame * CFrame.new(0, 0, -15)).Position -- depan karakter
		part.Parent = workspace
	end
end

-- ==== Klik Tombol ====
button.MouseButton1Click:Connect(spawnPartInFront)
