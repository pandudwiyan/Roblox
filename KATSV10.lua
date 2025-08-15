-- LocalScript di StarterPlayerScripts
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local Debris = game:GetService("Debris")
local PhysicsService = game:GetService("PhysicsService")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")

-- Collision group khusus supaya part bisa diinjak tapi tidak tabrakan dengan player lain
local groupName = "PlayerOnly_"..player.UserId
pcall(function() PhysicsService:CreateCollisionGroup(groupName) end)
PhysicsService:CollisionGroupSetCollidable(groupName, groupName, true)
for _, g in ipairs(PhysicsService:GetCollisionGroups()) do
	if g.name ~= groupName then
		PhysicsService:CollisionGroupSetCollidable(groupName, g.name, false)
	end
end
for _, part in ipairs(char:GetDescendants()) do
	if part:IsA("BasePart") then
		PhysicsService:SetPartCollisionGroup(part, groupName)
	end
end
char.DescendantAdded:Connect(function(d)
	if d:IsA("BasePart") and d:IsA("BasePart") then
		PhysicsService:SetPartCollisionGroup(d, groupName)
	end
end)

-- ===== GUI Setup =====
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.ResetOnSpawn = false

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 60, 0, 30)
button.Position = UDim2.new(0.5, -30, 0, 10) -- tengah atas
button.BackgroundColor3 = Color3.fromRGB(50,50,50)
button.BackgroundTransparency = 0.4
button.TextColor3 = Color3.fromRGB(255,255,255)
button.Text = "Mode: Off"
button.Parent = gui
local uic = Instance.new("UICorner", button)
uic.CornerRadius = UDim.new(0,10)

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
	if dragging and input == dragInput then
		local delta = input.Position - dragStart
		button.Position = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y
		)
	end
end)

-- Toggle Mode
local modes = {"Off","Mode1","Mode2","Mode3"}
local modeIndex = 1
local currentMode = modes[modeIndex]

local function toggleMode()
	modeIndex = modeIndex + 1
	if modeIndex > #modes then modeIndex = 1 end
	currentMode = modes[modeIndex]
	button.Text = "Mode: "..currentMode
end

button.MouseButton1Click:Connect(toggleMode)
UIS.InputBegan:Connect(function(input, processed)
	if not processed and input.KeyCode == Enum.KeyCode.Q then toggleMode() end
end)

-- ===== Spawn Part =====
local function spawnPart(posY)
	local part = Instance.new("Part")
	part.Size = Vector3.new(10, 2, 10)
	part.Anchored = true
	part.CanCollide = true
	part.Color = Color3.fromRGB(255,255,255)
	part.Transparency = 0.75
	part.Position = Vector3.new(hrp.Position.X, posY or hrp.Position.Y - hum.HipHeight - 1, hrp.Position.Z)
	part.Parent = workspace
	PhysicsService:SetPartCollisionGroup(part, groupName)
	Debris:AddItem(part,5)
end

-- ===== Mode Logic =====
local moving = false
local jumping = false
local peakY = nil
local jumpStartY = nil

hum.StateChanged:Connect(function(old,new)
	-- Mode2: turun dari lompatan
	if currentMode == "Mode2" then
		if new == Enum.HumanoidStateType.Jumping then
			jumping = true
			peakY = hrp.Position.Y
		elseif jumping and new == Enum.HumanoidStateType.Freefall then
			if hrp.Position.Y < peakY then
				spawnPart()
				jumping = false
			else
				peakY = math.max(peakY, hrp.Position.Y)
			end
		elseif new == Enum.HumanoidStateType.Landed then
			jumping = false
		end
	-- Mode3: spawn saat landed dari titik lompat
	elseif currentMode == "Mode3" then
		if new == Enum.HumanoidStateType.Jumping then
			jumping = true
			jumpStartY = hrp.Position.Y
		elseif jumping and new == Enum.HumanoidStateType.Landed then
			spawnPart(jumpStartY - hum.HipHeight -1)
			jumping = false
		end
	end
end)

RS.Heartbeat:Connect(function()
	if currentMode == "Mode1" then
		local isMoving = hum.MoveDirection.Magnitude > 0
		if isMoving and not moving then
			spawnPart()
		end
		moving = isMoving
	end
end)
