--[[
    Mode Button Script (PC & Mobile)
    - Off: Tidak spawn apapun
    - Mode1: Spawn part di kaki saat bergerak
    - Mode2: Spawn part saat turun dari lompatan (setelah titik tertinggi)
]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")
local hrp = char:WaitForChild("HumanoidRootPart")

-- UI Setup
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.ResetOnSpawn = false

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 60, 0, 30)
button.Position = UDim2.new(1, -70, 0, 10)
button.AnchorPoint = Vector2.new(0, 0)
button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.Text = "Mode: Off"
button.Parent = gui

-- Draggable
local dragging, dragInput, dragStart, startPos
button.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = button.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

button.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UIS.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		button.Position = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y
		)
	end
end)

-- Mode Logic
local modes = {"off", "mode1", "mode2"}
local modeIndex = 1
local currentMode = modes[modeIndex]

local function toggleMode()
	modeIndex = modeIndex + 1
	if modeIndex > #modes then
		modeIndex = 1
	end
	currentMode = modes[modeIndex]
	button.Text = "Mode: " .. string.upper(string.sub(currentMode, 1, 1)) .. string.sub(currentMode, 2)
end

button.MouseButton1Click:Connect(toggleMode)

-- Shortcut toggle (PC only)
UIS.InputBegan:Connect(function(input, processed)
	if not processed and input.KeyCode == Enum.KeyCode.Q then
		toggleMode()
	end
end)

-- Spawn Part Function
local function spawnPart()
	local part = Instance.new("Part")
	part.Size = Vector3.new(10, 0.5, 10) -- tipis kayak lantai
	part.Anchored = true
	part.CanCollide = true -- biar bisa diinjak
	part.Color = Color3.new(1, 1, 1)
	part.Transparency = 0.25

	-- hitung posisi supaya atas blok pas nempel di bawah kaki
	local yPos = hrp.Position.Y - (hrp.Size.Y/2 + part.Size.Y/2)
	part.CFrame = CFrame.new(hrp.Position.X, yPos, hrp.Position.Z)

	part.Parent = workspace
	game:GetService("Debris"):AddItem(part, 30)
end


-- Mode1: Detect movement
RS.RenderStepped:Connect(function()
	if currentMode == "mode1" then
		if humanoid.MoveDirection.Magnitude > 0 then
			spawnPart()
			task.wait(0.3) -- Cooldown supaya ga spam terlalu cepat
		end
	end
end)

-- Mode2: Detect jump apex
local isJumping = false
local peakY = nil
RS.RenderStepped:Connect(function()
	if currentMode == "mode2" then
		local vy = hrp.Velocity.Y
		if not isJumping and humanoid:GetState() == Enum.HumanoidStateType.Jumping then
			isJumping = true
			peakY = hrp.Position.Y
		end

		if isJumping then
			if hrp.Position.Y > peakY then
				peakY = hrp.Position.Y
			end
			if vy < -1 and hrp.Position.Y < peakY - 1 then
				spawnPart()
				isJumping = false
			end
		end

		if humanoid:GetState() == Enum.HumanoidStateType.Landed then
			isJumping = false
		end
	end
end)
