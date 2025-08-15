-- === Script Button Spawn Part di Depan Karakter (Revisi) ===
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
button.Size = UDim2.new(0, 150, 0, 50)
button.Position = UDim2.new(1, -160, 0, 10) -- pojok kanan atas
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
		local hrp = LocalPlayer.Character.HumanoidRootPart
		
		-- Buat Part
		local part = Instance.new("Part")
		part.Size = Vector3.new(10, 5, 10) -- tinggi 5
		part.Anchored = true
		part.Color = Color3.fromRGB(255, 255, 255) -- putih
		part.Transparency = 0.5 -- transparan 50%
		part.Position = (hrp.CFrame * CFrame.new(0, 0, -15)).Position -- depan karakter
		part.Parent = workspace
	end
end

-- ==== Klik Tombol ====
button.MouseButton1Click:Connect(spawnPartInFront)
