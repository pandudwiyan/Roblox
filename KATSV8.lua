-- === Script Spawn Part di Bawah Kaki (Mode ON/OFF + Input Size + Deteksi Jump) ===
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local CAS = game:GetService("ContextActionService")

-- ==== Buat GUI ====
local gui = Instance.new("ScreenGui")
gui.Name = "SpawnPartUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
local parentContainer = (gethui and gethui()) or game:FindFirstChildOfClass("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")
gui.Parent = parentContainer

-- ==== Frame utama ====
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 150, 0, 80)
frame.Position = UDim2.new(1, -160, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.BorderSizePixel = 0
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

-- ==== Input angka untuk ukuran part ====
local inputBox = Instance.new("TextBox")
inputBox.Size = UDim2.new(1, -20, 0, 30)
inputBox.Position = UDim2.new(0, 10, 0, 10)
inputBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
inputBox.PlaceholderText = "Ukuran (default 10)"
inputBox.Text = "10"
inputBox.ClearTextOnFocus = false
inputBox.Parent = frame
Instance.new("UICorner", inputBox).CornerRadius = UDim.new(0, 8)

-- ==== Tombol ON/OFF ====
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(1, -20, 0, 30)
toggleButton.Position = UDim2.new(0, 10, 0, 45)
toggleButton.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
toggleButton.Text = "OFF"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Parent = frame
Instance.new("UICorner", toggleButton).CornerRadius = UDim.new(0, 8)

-- ==== Draggable Frame ====
local function makeDraggable(frame)
	local dragging, dragInput, dragStart, startPos
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
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	frame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
	UIS.InputChanged:Connect(function(input)
		if input == dragInput and dragging then update(input) end
	end)
end
makeDraggable(frame)

-- ==== Variabel Mode ====
local enabled = false

-- ==== Fungsi Spawn Part ====
local function spawnPartUnderFeet()
	if not enabled then return end
	if LocalPlayer.Character 
	and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") 
	and LocalPlayer.Character:FindFirstChild("Humanoid") then
		
		local root = LocalPlayer.Character.HumanoidRootPart
		local humanoid = LocalPlayer.Character.Humanoid
		
		-- Ambil ukuran dari input
		local sizeNumber = tonumber(inputBox.Text) or 10
		if sizeNumber <= 0 then sizeNumber = 10 end
		
		local part = Instance.new("Part")
		part.Size = Vector3.new(sizeNumber, 0.5, sizeNumber)
		part.Anchored = true
		part.Color = Color3.fromRGB(255, 255, 255)
		part.Transparency = 0.9
		
		-- Hitung posisi tepat di bawah kaki
		local footY = root.Position.Y - (root.Size.Y/2) - humanoid.HipHeight
		local offsetY = part.Size.Y / 2
		part.CFrame = CFrame.new(root.Position.X, footY - offsetY, root.Position.Z)
		
		part.Parent = workspace
		game:GetService("Debris"):AddItem(part, 3)
	end
end

-- ==== Toggle Button ====
toggleButton.MouseButton1Click:Connect(function()
	enabled = not enabled
	if enabled then
		toggleButton.Text = "ON"
		toggleButton.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
	else
		toggleButton.Text = "OFF"
		toggleButton.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
	end
end)

-- ==== Deteksi Jump (PC + Mobile) ====
-- PC / Keyboard (Space)
UIS.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.KeyCode == Enum.KeyCode.Space then
		spawnPartUnderFeet()
	end
end)

-- Mobile / JumpButton (pakai ContextActionService)
CAS:BindAction("DetectJumpPress", function(_, inputState)
	if inputState == Enum.UserInputState.Begin then
		spawnPartUnderFeet()
	end
end, false, Enum.PlayerActions.CharacterJump)
