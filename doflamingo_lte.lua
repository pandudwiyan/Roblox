-- Floating Tools UI (PC + Mobile) - Ghost Sphere Rev 2

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-------------------------------------------------
-- GUI
-------------------------------------------------

local gui = Instance.new("ScreenGui")
gui.Name = "ToolsUI"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local panel = Instance.new("Frame")
panel.Size = UDim2.new(0,250,0,65)
panel.Position = UDim2.new(0.05,0,0.7,0)
panel.BackgroundColor3 = Color3.fromRGB(0,0,0)
panel.BackgroundTransparency = 0.3
panel.Active = true
panel.Parent = gui

Instance.new("UICorner",panel).CornerRadius = UDim.new(0,8)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 20)
title.Position = UDim2.new(0, 0, 0, 3)
title.BackgroundTransparency = 1
title.Text = "Skizoo Cheat"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.SourceSansBold
title.TextXAlignment = Enum.TextXAlignment.Center
title.TextSize = 14
title.Parent = panel

-------------------------------------------------
-- BUTTON CREATOR
-------------------------------------------------

local function createButton(text,x)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0,70,0,28)
	btn.Position = UDim2.new(0,x,0,28)
	btn.Text = text
	btn.BackgroundColor3 = Color3.fromRGB(120,120,120)
	btn.TextColor3 = Color3.new(1,1,1)
	btn.Font = Enum.Font.SourceSans
	btn.TextSize = 14
	btn.Parent = panel
	Instance.new("UICorner",btn).CornerRadius = UDim.new(0,6)
	return btn
end

local visionBtn = createButton("Vision",10)
local jumpBtn = createButton("Jump",90)
local ghostBtn = createButton("Ghost",170)

-------------------------------------------------
-- SELECTION MENU
-------------------------------------------------

local menu = Instance.new("Frame")
menu.Size = UDim2.new(0,150,0,70)
menu.BackgroundColor3 = Color3.fromRGB(40,40,40)
menu.Visible = false
menu.Parent = gui

Instance.new("UICorner",menu).CornerRadius = UDim.new(0,8)

local function createMenuButton(text,y,color)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0,130,0,25)
	b.Position = UDim2.new(0,10,0,y)
	b.Text = text
	b.BackgroundColor3 = color
	b.TextColor3 = Color3.new(1,1,1)
	b.Font = Enum.Font.SourceSans
	b.TextSize = 14
	b.Parent = menu
	Instance.new("UICorner",b).CornerRadius = UDim.new(0,6)
	return b
end

local bringBtn = createMenuButton("Bring",10,Color3.fromRGB(0,120,215))
local teleportBtn = createMenuButton("Teleport",40,Color3.fromRGB(0,170,0))

-------------------------------------------------
-- VARIABLES
-------------------------------------------------

local selectedObject
local selectedOriginalColor
local broughtObjects = {}
local lastClick = 0
local lastObject
local originalTransparency = {}
local originalColors = {}
local objectLabels = {}

-- Variabel Ghost
local ghostSphere = nil
local ghostConnections = {}
local mobileControls = nil -- Frame untuk kontrol HP

-------------------------------------------------
-- BUTTON TOGGLE
-------------------------------------------------

local function toggle(btn)
	local on = not btn:GetAttribute("Active")
	btn:SetAttribute("Active",on)
	btn.BackgroundColor3 =
		on and Color3.fromRGB(0,200,0)
		or Color3.fromRGB(120,120,120)
	return on
end

-------------------------------------------------
-- DRAG UI
-------------------------------------------------

local dragging
local dragStart
local startPos

panel.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = panel.Position
	end
end)

panel.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging then
		local delta = input.Position - dragStart
		panel.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

-------------------------------------------------
-- INFINITE JUMP
-------------------------------------------------

local function setupJump(char)
	local hum = char:WaitForChild("Humanoid")
	UserInputService.JumpRequest:Connect(function()
		if jumpBtn:GetAttribute("Active") then
			hum:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end)
end

-------------------------------------------------
-- GHOST SPHERE FEATURE (PC + MOBILE)
-------------------------------------------------

-- Fungsi untuk membuat kontrol Mobile
local function createMobileControls()
	local frame = Instance.new("Frame")
	frame.Name = "MobileGhostControls"
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundTransparency = 1
	frame.Parent = gui

	-- Fungsi pembuat tombol
	local function mBtn(text, size, pos)
		local b = Instance.new("TextButton")
		b.Text = text
		b.Size = size
		b.Position = pos
		b.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		b.BackgroundTransparency = 0.3
		b.TextColor3 = Color3.new(1,1,1)
		b.TextSize = 20
		b.Font = Enum.Font.SourceSansBold
		b.Parent = frame
		Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
		return b
	end

	-- D-PAD (Kiri Bawah)
	local fwd = mBtn("▲", UDim2.new(0, 60, 0, 50), UDim2.new(0, 10, 1, -160))
	local bck = mBtn("▼", UDim2.new(0, 60, 0, 50), UDim2.new(0, 10, 1, -60))
	local lft = mBtn("◄", UDim2.new(0, 50, 0, 50), UDim2.new(0, 80, 1, -110))
	local rgt = mBtn("►", UDim2.new(0, 50, 0, 50), UDim2.new(0, 150, 1, -110))

	-- Up/Down (Kanan Bawah)
	local upB = mBtn("UP", UDim2.new(0, 60, 0, 50), UDim2.new(1, -140, 1, -160))
	local dnB = mBtn("DN", UDim2.new(0, 60, 0, 50), UDim2.new(1, -140, 1, -60))

	-- Return tabel tombol agar mudah diakses
	return {
		Frame = frame,
		Fwd = fwd, Bck = bck, Lft = lft, Rgt = rgt,
		Up = upB, Dn = dnB
	}
end

local function toggleGhost()
	local on = toggle(ghostBtn)
	local char = player.Character
	if not char then return end

	local hum = char:FindFirstChild("Humanoid")

	if on then
		-- 1. Buat Sphere
		ghostSphere = Instance.new("Part")
		ghostSphere.Name = player.Name .. "_eye"
		ghostSphere.Shape = Enum.PartType.Ball
		ghostSphere.Size = Vector3.new(2, 2, 2)
		ghostSphere.Transparency = 0.7
		ghostSphere.Anchored = true
		ghostSphere.CanCollide = false
		ghostSphere.Material = Enum.Material.Neon
		ghostSphere.Color = Color3.fromRGB(255, 255, 255)

		-- Posisi awal
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if hrp then
			ghostSphere.CFrame = hrp.CFrame * CFrame.new(0, 2, -5)
		end
		ghostSphere.Parent = Workspace

		-- 2. Kamera & Player State
		Workspace.CurrentCamera.CameraSubject = ghostSphere

		-- ANCHOR PLAYER (Player tidak bisa gerak, tidak jatuh)
		for _, part in pairs(char:GetDescendants()) do
			if part:IsA("BasePart") then
				part.Anchored = true
			end
		end
		-- Pastikan Humanoid tidak mencoba mereset anchor
		if hum then
			hum.PlatformStand = true
		end

		-- 3. Logic Gerakan
		local keysPressed = {} -- Untuk PC
		local mobileInput = { x = 0, y = 0, z = 0 } -- Untuk Mobile
		local SPEED = 2

		-- Input PC (Keyboard)
		local inputCon = UserInputService.InputBegan:Connect(function(input, gp)
			if gp then return end
			keysPressed[input.KeyCode] = true
		end)
		table.insert(ghostConnections, inputCon)

		local inputEndCon = UserInputService.InputEnded:Connect(function(input)
			keysPressed[input.KeyCode] = nil
		end)
		table.insert(ghostConnections, inputEndCon)

		-- Input Mobile (UI Buttons)
		if UserInputService.TouchEnabled then
			mobileControls = createMobileControls()

			-- Helper untuk tombol mobile
			local function setupMobileBtn(btn, axis, value)
				local btnCon1 = btn.InputBegan:Connect(function()
					if axis == "x" then mobileInput.x = value
					elseif axis == "y" then mobileInput.y = value
					elseif axis == "z" then mobileInput.z = value end
				end)
				local btnCon2 = btn.InputEnded:Connect(function()
					if axis == "x" then mobileInput.x = 0
					elseif axis == "y" then mobileInput.y = 0
					elseif axis == "z" then mobileInput.z = 0 end
				end)
				table.insert(ghostConnections, btnCon1)
				table.insert(ghostConnections, btnCon2)
			end

			-- Mapping Tombol
			setupMobileBtn(mobileControls.Fwd, "x", 1)  -- Maju (relatif nanti)
			setupMobileBtn(mobileControls.Bck, "x", -1)
			setupMobileBtn(mobileControls.Lft, "z", -1)
			setupMobileBtn(mobileControls.Rgt, "z", 1)
			setupMobileBtn(mobileControls.Up, "y", 1)
			setupMobileBtn(mobileControls.Dn, "y", -1)
		end

		-- Loop Gerakan (Gabungan PC + Mobile)
		local renderCon = RunService.RenderStepped:Connect(function()
			if not ghostSphere or not ghostSphere.Parent then return end

			local cam = Workspace.CurrentCamera
			local moveDir = Vector3.new(0,0,0)

			-- Kalkulasi PC
			local camCF = cam.CFrame
			local lookVector = Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z).Unit
			local rightVector = Vector3.new(camCF.RightVector.X, 0, camCF.RightVector.Z).Unit

			if keysPressed[Enum.KeyCode.W] then moveDir = moveDir + lookVector end
			if keysPressed[Enum.KeyCode.S] then moveDir = moveDir - lookVector end
			if keysPressed[Enum.KeyCode.D] then moveDir = moveDir + rightVector end
			if keysPressed[Enum.KeyCode.A] then moveDir = moveDir - rightVector end
			if keysPressed[Enum.KeyCode.Space] then moveDir = moveDir + Vector3.new(0,1,0) end
			if keysPressed[Enum.KeyCode.Q] then moveDir = moveDir - Vector3.new(0,1,0) end

			-- Kalkulasi Mobile (Tambahkan ke moveDir)
			-- Mobile X = Maju/Mundur relatif terhadap kamera
			moveDir = moveDir + (lookVector * mobileInput.x)
			moveDir = moveDir + (rightVector * mobileInput.z)
			moveDir = moveDir + (Vector3.new(0, 1, 0) * mobileInput.y)

			-- Terapkan Gerakan
			if moveDir.Magnitude > 0 then
				ghostSphere.CFrame = ghostSphere.CFrame + (moveDir * SPEED)
			end
		end)
		table.insert(ghostConnections, renderCon)

	else
		-- MATIKAN GHOST MODE

		-- Hapus Sphere
		if ghostSphere then
			ghostSphere:Destroy()
			ghostSphere = nil
		end

		-- Hapus Kontrol Mobile
		if mobileControls then
			mobileControls.Frame:Destroy()
			mobileControls = nil
		end

		-- Putuskan koneksi
		for _, conn in pairs(ghostConnections) do
			if conn then conn:Disconnect() end
		end
		ghostConnections = {}

		-- UNANCHOR PLAYER (Kembalikan normal)
		if char then
			for _, part in pairs(char:GetDescendants()) do
				if part:IsA("BasePart") then
					part.Anchored = false
				end
			end
		end

		-- Kembalikan Kamera & Humanoid
		if hum then
			hum.PlatformStand = false
			Workspace.CurrentCamera.CameraSubject = hum
		end
	end
end

ghostBtn.MouseButton1Click:Connect(toggleGhost)

-------------------------------------------------
-- VISION
-------------------------------------------------

local function toggleVision()
	local on = toggle(visionBtn)

	if on then
		local processedPlayers = {} 

		for _,obj in pairs(Workspace:GetDescendants()) do
			if obj:IsA("BasePart") then
				originalTransparency[obj] = obj.Transparency
				originalColors[obj] = obj.Color
				obj.Transparency = 0
				if obj.CanCollide then
					obj.Color = Color3.fromRGB(0,255,0)
				end

				local characterModel = obj:FindFirstAncestorWhichIsA("Model")
				local playerFromCharacter = characterModel and Players:GetPlayerFromCharacter(characterModel)

				if playerFromCharacter then
					if not processedPlayers[playerFromCharacter] then
						local head = characterModel:FindFirstChild("Head")
						if head then
							local labelText = string.format("%s | %s", playerFromCharacter.Name, playerFromCharacter.DisplayName)
							local label = Instance.new("BillboardGui")
							label.Name = "NameLabel"
							label.Size = UDim2.new(0, 100, 0, 20)
							label.StudsOffset = Vector3.new(0, 2.5, 0) 
							label.Parent = head 
							local textLabel = Instance.new("TextLabel")
							textLabel.Size = UDim2.new(1, 0, 1, 0)
							textLabel.BackgroundTransparency = 1
							textLabel.Text = labelText
							textLabel.TextColor3 = Color3.new(1, 1, 1)
							textLabel.TextStrokeTransparency = 0
							textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
							textLabel.Font = Enum.Font.SourceSansBold 
							textLabel.TextSize = 14
							textLabel.Parent = label
							objectLabels[head] = label 
							processedPlayers[playerFromCharacter] = true 
						end
					end
				else
					if obj.Name ~= "" then
						local label = Instance.new("BillboardGui")
						label.Name = "NameLabel"
						label.Size = UDim2.new(0, 100, 0, 20)
						label.StudsOffset = Vector3.new(0, 2, 0)
						label.Parent = obj
						local textLabel = Instance.new("TextLabel")
						textLabel.Size = UDim2.new(1, 0, 1, 0)
						textLabel.BackgroundTransparency = 1
						textLabel.Text = obj.Name
						textLabel.TextColor3 = Color3.new(1, 1, 1)
						textLabel.TextStrokeTransparency = 0
						textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
						textLabel.Font = Enum.Font.SourceSans
						textLabel.TextSize = 14
						textLabel.Parent = label
						objectLabels[obj] = label
					end
				end
			end
		end
	else
		for obj,val in pairs(originalTransparency) do
			if obj and obj.Parent then
				obj.Transparency = val
			end
		end
		for obj,val in pairs(originalColors) do
			if obj and obj.Parent then
				obj.Color = val
			end
		end
		for _, label in pairs(objectLabels) do
			if label and label.Parent then
				label:Destroy()
			end
		end
		objectLabels = {}
		menu.Visible = false
	end
end

-------------------------------------------------
-- OBJECT SELECT
-------------------------------------------------

local function selectObject(obj)
	if not visionBtn:GetAttribute("Active") then return end
	if not obj then return end
	if not obj:IsA("BasePart") then return end

	local time = tick()

	if obj == lastObject and time-lastClick < 0.5 then
		if selectedObject then
			selectedObject.Color = selectedOriginalColor
		end
		selectedObject = obj
		selectedOriginalColor = obj.Color
		obj.Color = Color3.fromRGB(255,0,0)
		menu.Visible = true
		menu.Position = UDim2.new(
			0,
			panel.AbsolutePosition.X + panel.AbsoluteSize.X + 10,
			0,
			panel.AbsolutePosition.Y
		)
		if broughtObjects[selectedObject] then
			bringBtn.Text = "Unbring"
		else
			bringBtn.Text = "Bring"
		end
	else
		lastObject = obj
		lastClick = time
	end
end

-------------------------------------------------
-- INPUTS
-------------------------------------------------

UserInputService.InputBegan:Connect(function(input,gp)
	if gp then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		local mouse = player:GetMouse()
		if mouse.Target then
			selectObject(mouse.Target)
		end
	end
end)

UserInputService.TouchTapInWorld:Connect(function(pos,processed)
	if processed then return end
	local cam = Workspace.CurrentCamera
	local ray = cam:ViewportPointToRay(pos.X,pos.Y)
	local result = Workspace:Raycast(ray.Origin,ray.Direction*500)
	if result then
		selectObject(result.Instance)
	end
end)

-------------------------------------------------
-- ACTIONS
-------------------------------------------------

bringBtn.MouseButton1Click:Connect(function()
	if not selectedObject then return end
	local char = player.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	if broughtObjects[selectedObject] then
		selectedObject.CFrame = broughtObjects[selectedObject]
		broughtObjects[selectedObject] = nil
		bringBtn.Text = "Bring"
	else
		broughtObjects[selectedObject] = selectedObject.CFrame
		selectedObject.CFrame = hrp.CFrame + hrp.CFrame.LookVector*5
		bringBtn.Text = "Unbring"
	end
end)

teleportBtn.MouseButton1Click:Connect(function()
	if not selectedObject then return end
	local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if hrp then
		local originalLookVector = hrp.CFrame.LookVector
		local targetPosition = selectedObject.CFrame.Position + Vector3.new(0,5,0)
		hrp.CFrame = CFrame.new(targetPosition, targetPosition + originalLookVector)
	end
end)

-------------------------------------------------
-- EVENTS
-------------------------------------------------

visionBtn.MouseButton1Click:Connect(toggleVision)

jumpBtn.MouseButton1Click:Connect(function()
	local on = toggle(jumpBtn)
	if on and player.Character then
		setupJump(player.Character)
	end
end)

player.CharacterAdded:Connect(function(c)
	task.wait(0.5)
	setupJump(c)

	-- Reset Ghost jika mati/respawn
	if ghostBtn:GetAttribute("Active") then
		toggleGhost() -- Matikan
	end
end)
