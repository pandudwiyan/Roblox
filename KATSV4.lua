-- === Script Button Spawn Part di Bawah Kaki ===
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UIS = game:GetService("UserInputService")

-- ==== Buat GUI ====
local gui = Instance.new("ScreenGui")
gui.Name = "SpawnPartUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
local parentContainer = (gethui and gethui()) or game:FindFirstChildOfClass("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")
gui.Parent = parentContainer

-- ==== Buat Tombol ====
local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 100, 0, 40) -- kecil
button.Position = UDim2.new(1, -110, 0, 10) -- pojok kanan atas
button.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
button.Text = "Spawn"
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.BorderSizePixel = 0
button.Parent = gui
Instance.new("UICorner", button).CornerRadius = UDim.new(0, 12)

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
local function spawnPartUnderFeet()
	if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
		local root = LocalPlayer.Character.HumanoidRootPart
		local part = Instance.new("Part")
		part.Size = Vector3.new(10, 2, 10) -- tinggi 2
		part.Anchored = true
		part.Color = Color3.fromRGB(255, 255, 255)
		part.Transparency = 0.75
		part.CFrame = CFrame.new(root.Position - Vector3.new(0, root.Size.Y/2 + 1, 0)) -- di bawah kaki
		part.Parent = workspace

		-- Hilang otomatis setelah 30 detik
		game:GetService("Debris"):AddItem(part, 30)
	end
end

-- ==== Klik Tombol ====
button.MouseButton1Click:Connect(spawnPartUnderFeet)

-- ==== Shortcut Q ====
UIS.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.KeyCode == Enum.KeyCode.Q then
		spawnPartUnderFeet()
	end
end)
