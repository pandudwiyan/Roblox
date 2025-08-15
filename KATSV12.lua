--[[
    Mode Button Script (PC & Mobile)
    - Off: Tidak spawn apapun
    - Mode1: Spawn part di kaki saat bergerak
    - Mode2: Spawn part saat turun dari lompatan (setelah titik tertinggi)
    - Mode3: Spawn part setelah landed dari jump, block menjaga agar tidak turun dibawah titik awal loncat
]]

-- Pastikan ini LocalScript di StarterPlayerScripts
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local PhysicsService = game:GetService("PhysicsService")
local Debris = game:GetService("Debris")

local player = Players.LocalPlayer or Players.PlayerAdded:Wait()
local playerGui = player:WaitForChild("PlayerGui")

-- Tunggu karakter spawn
local function getCharacter()
	local char = player.Character or player.CharacterAdded:Wait()
	local humanoid = char:WaitForChild("Humanoid")
	local hrp = char:WaitForChild("HumanoidRootPart")
	return char, humanoid, hrp
end
local char, humanoid, hrp = getCharacter()

-- Collision group khusus untuk player ini
local myGroup = "MyCollideOnly"
pcall(function()
    PhysicsService:CreateCollisionGroup(myGroup)
end)
PhysicsService:SetPartCollisionGroup(hrp, myGroup)
PhysicsService:CollisionGroupSetCollidable(myGroup, "Default", false)

-- GUI Setup
local gui = Instance.new("ScreenGui")
gui.ResetOnSpawn = false
gui.Parent = playerGui

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 80, 0, 30)
button.Position = UDim2.new(1, -90, 0, 10)
button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.Text = "Mode: Off"
button.Parent = gui

-- Draggable UI tanpa bentrok klik
local dragging, dragInput, dragStart, startPos
local dragDistance = 0
button.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = button.Position
		dragDistance = 0
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
		dragDistance = math.abs(delta.X) + math.abs(delta.Y)
		if dragDistance > 5 then
			button.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end
end)

-- Mode Logic
local modes = {"off", "mode1", "mode2", "mode3"}
local modeIndex = 1
local currentMode = modes[modeIndex]

local function toggleMode()
	modeIndex += 1
	if modeIndex > #modes then
		modeIndex = 1
	end
	currentMode = modes[modeIndex]
	button.Text = "Mode: " .. string.upper(string.sub(currentMode, 1, 1)) .. string.sub(currentMode, 2)
end

button.MouseButton1Click:Connect(function()
	if dragDistance < 5 then
		toggleMode()
	end
end)

-- Shortcut toggle (PC only)
UIS.InputBegan:Connect(function(input, processed)
	if not processed and input.KeyCode == Enum.KeyCode.Q then
		toggleMode()
	end
end)

-- Spawn Part Function
local function spawnPart(yOffset)
	local part = Instance.new("Part")
	part.Size = Vector3.new(10, 2, 10)
	part.Anchored = true
	part.CanCollide = true
	part.Color = Color3.new(1, 1, 1)
	part.Transparency = 0.25

	-- Posisi top part persis di bawah kaki
	part.CFrame = CFrame.new(hrp.Position.X, hrp.Position.Y - (humanoid.HipHeight + (part.Size.Y/2) - (yOffset or 0)), hrp.Position.Z)

	-- Set collision hanya untuk player ini
	PhysicsService:SetPartCollisionGroup(part, myGroup)
	part.Parent = workspace
	Debris:AddItem(part, 30)
end

-- Mode1: detect movement
local lastSpawnTime1 = 0
RS.RenderStepped:Connect(function()
	if currentMode == "mode1" and humanoid.MoveDirection.Magnitude > 0 then
		if tick() - lastSpawnTime1 > 0.3 then
			spawnPart()
			lastSpawnTime1 = tick()
		end
	end
end)

-- Mode2 & Mode3: detect jump / landed
local jumped = false
local jumpStartY = nil
humanoid.StateChanged:Connect(function(old, new)
	if new == Enum.HumanoidStateType.Jumping then
		jumped = true
		jumpStartY = hrp.Position.Y
	elseif jumped and new == Enum.HumanoidStateType.Landed then
		if currentMode == "mode2" then
			spawnPart()
		elseif currentMode == "mode3" then
			-- Spawn part di ketinggian minimal titik loncat
			local spawnY = math.max(hrp.Position.Y, jumpStartY)
			local part = Instance.new("Part")
			part.Size = Vector3.new(10, 2, 10)
			part.Anchored = true
			part.CanCollide = true
			part.Color = Color3.new(1, 1, 1)
			part.Transparency = 0.25
			part.CFrame = CFrame.new(hrp.Position.X, spawnY - (part.Size.Y/2), hrp.Position.Z)
			PhysicsService:SetPartCollisionGroup(part, myGroup)
			part.Parent = workspace
			Debris:AddItem(part, 30)
		end
		jumped = false
	end
end)

-- Respawn handler
player.CharacterAdded:Connect(function(newChar)
	char = newChar
	humanoid = char:WaitForChild("Humanoid")
	hrp = char:WaitForChild("HumanoidRootPart")
	PhysicsService:SetPartCollisionGroup(hrp, myGroup)
end)
