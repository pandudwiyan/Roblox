-- === Script Button Spawn Part di Depan Kamera ===
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

-- ==== Buat GUI ====
local gui = Instance.new("ScreenGui")
gui.Name = "SpawnPartUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true

local parentContainer = (gethui and gethui()) or game:FindFirstChildOfClass("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")
gui.Parent = parentContainer

-- ==== Buat Tombol ====
local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 100, 0, 40) -- lebih kecil
button.Position = UDim2.new(1, -110, 0, 10) -- pojok kanan atas
button.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
button.Text = "Spawn"
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.BorderSizePixel = 0
button.Parent = gui

do
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 12)
	c.Parent = button
end

-- ==== Fungsi Drag Tombol ====
local function makeDraggable(frame)
	local dragging = false
	local dragInput, dragStart, startPos

	local function update(input)
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y
		)
	end

	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	frame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UIS.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			update(input)
		end
	end)
end
makeDraggable(button)

-- ==== Fungsi Spawn Part ====
local function spawnPartInFront()
	if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
		-- Menggunakan posisi dan rotasi kamera
		local camCFrame = Camera.CFrame
		local spawnPos = camCFrame.Position + camCFrame.LookVector * 15

		local part = Instance.new("Part")
		part.Size = Vector3.new(10, 5, 10)
		part.Anchored = true
		part.Color = Color3.fromRGB(255, 255, 255) -- putih
		part.Transparency = 0.75 -- 75% transparan
		part.CFrame = CFrame.new(spawnPos, camCFrame.Position + camCFrame.LookVector * 30)
		part.Parent = workspace
	end
end

-- ==== Klik Tombol ====
button.MouseButton1Click:Connect(spawnPartInFront)

-- ==== Shortcut Q ====
UIS.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.KeyCode == Enum.KeyCode.Q then
		spawnPartInFront()
	end
end)
