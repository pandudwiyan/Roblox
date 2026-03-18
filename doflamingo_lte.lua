-- Floating Tools UI (PC + Mobile) - Ghost Sphere Rev 7 (Modified)
-- Fitur: Vision, Jump, Ghost, Teleport/Marking Coordinate, Minimize UI

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
panel.Size = UDim2.new(0,250,0,95) 
panel.Position = UDim2.new(0.05,0,0.7,0)
panel.BackgroundColor3 = Color3.fromRGB(0,0,0)
panel.BackgroundTransparency = 0.3
panel.Active = true
panel.Parent = gui

Instance.new("UICorner",panel).CornerRadius = UDim.new(0,8)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -30, 0, 20) -- Diperkecil agar tidak bertabrakan dengan tombol minimize
title.Position = UDim2.new(0, 5, 0, 3)
title.BackgroundTransparency = 1
title.Text = "SKIZOO"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.SourceSansBold
title.TextXAlignment = Enum.TextXAlignment.Left -- Rata kiri biar rapi
title.TextSize = 14
title.Parent = panel

-- Tombol Minimize
local minBtn = Instance.new("TextButton")
minBtn.Name = "MinimizeBtn"
minBtn.Size = UDim2.new(0, 20, 0, 20)
minBtn.Position = UDim2.new(1, -25, 0, 3) -- Pojok kanan atas
minBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
minBtn.TextColor3 = Color3.new(1,1,1)
minBtn.Font = Enum.Font.SourceSansBold
minBtn.TextSize = 16
minBtn.Text = "-"
minBtn.Parent = panel
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 4)

-------------------------------------------------
-- BUTTON CREATOR
-------------------------------------------------

local function createButton(text,x,y)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0,70,0,28)
	btn.Position = UDim2.new(0,x,0,y or 28)
	btn.Text = text
	btn.BackgroundColor3 = Color3.fromRGB(120,120,120)
	btn.TextColor3 = Color3.new(1,1,1)
	btn.Font = Enum.Font.SourceSans
	btn.TextSize = 14
	btn.Parent = panel
	Instance.new("UICorner",btn).CornerRadius = UDim.new(0,6)
	return btn
end

-- Baris 1
local visionBtn = createButton("Vision",10)
local jumpBtn = createButton("Jump",90)
local ghostBtn = createButton("Ghost",170)

-- Baris 2 (Layout Baru: Marking Kiri, Teleport Kanan)
local markingBtn = createButton("Marking", 10, 60) -- Pindah ke kiri (X: 10)
markingBtn.Size = UDim2.new(0, 110, 0, 28)
markingBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 150)

local tpMarkBtn = createButton("Teleport", 130, 60) -- Pindah ke kanan (X: 130)
tpMarkBtn.Size = UDim2.new(0, 110, 0, 28)
tpMarkBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 150)

-------------------------------------------------
-- SELECTION MENU
-------------------------------------------------

local menu = Instance.new("Frame")
menu.Size = UDim2.new(0,150,0,140) 
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
local markBtn = createMenuButton("Mark",70,Color3.fromRGB(100, 0, 150))
local deleteBtn = createMenuButton("Delete",100,Color3.fromRGB(255, 0, 0))

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
local mobileControls = nil

-- Variabel Mark & Teleport
local markedCFrame = nil 
local tempMarkCFrame = nil 
local isUndoMode = false 
local undoThread = nil 

-------------------------------------------------
-- FITUR MINIMIZE
-------------------------------------------------

local isMinimized = false
local originalSize = panel.Size

minBtn.MouseButton1Click:Connect(function()
	isMinimized = not isMinimized
	if isMinimized then
		panel.Size = UDim2.new(0, 250, 0, 30) -- Ukuran minimized (hanya header)
		minBtn.Text = "+"
		-- Sembunyikan semua tombol
		visionBtn.Visible = false
		jumpBtn.Visible = false
		ghostBtn.Visible = false
		markingBtn.Visible = false
		tpMarkBtn.Visible = false
	else
		panel.Size = originalSize
		minBtn.Text = "-"
		-- Tampilkan semua tombol
		visionBtn.Visible = true
		jumpBtn.Visible = true
		ghostBtn.Visible = true
		markingBtn.Visible = true
		tpMarkBtn.Visible = true
	end
end)

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
-- GHOST SPHERE FEATURE
-------------------------------------------------

local function createMobileControls()
	local frame = Instance.new("Frame")
	frame.Name = "MobileGhostControls"
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundTransparency = 1
	frame.Parent = gui

	local function mBtn(text, size, pos)
		local b = Instance.new("TextButton")
		b.Text = text
		b.Size = size
		b.Position = pos
		b.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
		b.BackgroundTransparency = 0.4
		b.TextColor3 = Color3.new(1,1,1)
		b.TextSize = 24 
		b.Font = Enum.Font.SourceSansBold
		b.BorderSizePixel = 0
		b.Parent = frame
		Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)
		return b
	end

	local btnSize = UDim2.new(0, 45, 0, 45)

	local fwd = mBtn("▲", btnSize, UDim2.new(0, 60, 1, -140))
	local lft = mBtn("◄", btnSize, UDim2.new(0, 20, 1, -100))
	local rgt = mBtn("►", btnSize, UDim2.new(0, 100, 1, -100))
	local bck = mBtn("▼", btnSize, UDim2.new(0, 60, 1, -60))

	local upB = mBtn("UP", btnSize, UDim2.new(1, -145, 1, -105))
	local dnB = mBtn("DN", btnSize, UDim2.new(1, -145, 1, -60))

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
		ghostSphere = Instance.new("Part")
		ghostSphere.Name = player.Name .. "_eye"
		ghostSphere.Shape = Enum.PartType.Ball
		ghostSphere.Size = Vector3.new(2, 2, 2)
		ghostSphere.Transparency = 0.7
		ghostSphere.Anchored = true
		ghostSphere.CanCollide = false
		ghostSphere.Material = Enum.Material.Neon
		ghostSphere.Color = Color3.fromRGB(255, 255, 255)

		local hrp = char:FindFirstChild("HumanoidRootPart")
		if hrp then
			ghostSphere.CFrame = hrp.CFrame * CFrame.new(0, 2, -5)
		end
		ghostSphere.Parent = Workspace

		Workspace.CurrentCamera.CameraSubject = ghostSphere

		for _, part in pairs(char:GetDescendants()) do
			if part:IsA("BasePart") then
				part.Anchored = true
			end
		end
		if hum then hum.PlatformStand = true end

		local keysPressed = {}
		local moveDir = { forward = 0, strafe = 0, vertical = 0 }
		local SPEED = 2

		local inputCon = UserInputService.InputBegan:Connect(function(input, gp)
			if gp then return end
			keysPressed[input.KeyCode] = true
		end)
		table.insert(ghostConnections, inputCon)

		local inputEndCon = UserInputService.InputEnded:Connect(function(input)
			keysPressed[input.KeyCode] = nil
		end)
		table.insert(ghostConnections, inputEndCon)

		if UserInputService.TouchEnabled then
			mobileControls = createMobileControls()

			local function setupMobileBtn(btn, axis, value)
				local btnCon1 = btn.InputBegan:Connect(function()
					moveDir[axis] = value
				end)
				local btnCon2 = btn.InputEnded:Connect(function()
					moveDir[axis] = 0
				end)
				table.insert(ghostConnections, btnCon1)
				table.insert(ghostConnections, btnCon2)
			end

			setupMobileBtn(mobileControls.Fwd, "forward", 1)
			setupMobileBtn(mobileControls.Bck, "forward", -1)
			setupMobileBtn(mobileControls.Lft, "strafe", -1)
			setupMobileBtn(mobileControls.Rgt, "strafe", 1)
			setupMobileBtn(mobileControls.Up, "vertical", 1)
			setupMobileBtn(mobileControls.Dn, "vertical", -1)
		end

		local renderCon = RunService.RenderStepped:Connect(function()
			if not ghostSphere or not ghostSphere.Parent then return end

			local cam = Workspace.CurrentCamera
			local finalMove = Vector3.new(0,0,0)

			local camCF = cam.CFrame
			local camLook = camCF.LookVector
			local camRight = camCF.RightVector

			if keysPressed[Enum.KeyCode.W] then finalMove = finalMove + camLook end
			if keysPressed[Enum.KeyCode.S] then finalMove = finalMove - camLook end
			if keysPressed[Enum.KeyCode.D] then finalMove = finalMove + camRight end
			if keysPressed[Enum.KeyCode.A] then finalMove = finalMove - camRight end
			if keysPressed[Enum.KeyCode.Space] then finalMove = finalMove + Vector3.new(0,1,0) end
			if keysPressed[Enum.KeyCode.Q] then finalMove = finalMove - Vector3.new(0,1,0) end

			finalMove = finalMove + (camLook * moveDir.forward)
			finalMove = finalMove + (camRight * moveDir.strafe)
			finalMove = finalMove + (Vector3.new(0,1,0) * moveDir.vertical)

			if finalMove.Magnitude > 0 then
				ghostSphere.CFrame = ghostSphere.CFrame + (finalMove * SPEED)
			end
		end)
		table.insert(ghostConnections, renderCon)

	else
		if ghostSphere then
			ghostSphere:Destroy()
			ghostSphere = nil
		end

		if mobileControls then
			mobileControls.Frame:Destroy()
			mobileControls = nil
		end

		for _, conn in pairs(ghostConnections) do
			if conn then conn:Disconnect() end
		end
		ghostConnections = {}

		if char then
			for _, part in pairs(char:GetDescendants()) do
				if part:IsA("BasePart") then
					part.Anchored = false
				end
			end
		end

		if hum then
			hum.PlatformStand = false
			Workspace.CurrentCamera.CameraSubject = hum
		end
	end
end

ghostBtn.MouseButton1Click:Connect(toggleGhost)

-------------------------------------------------
-- VISION (Rainbow Player ESP)
-------------------------------------------------

local rainbowConnection = nil

local function toggleVision()
	local on = toggle(visionBtn)

	if on then
		local processedPlayers = {} 

		if rainbowConnection then rainbowConnection:Disconnect() end

		rainbowConnection = RunService.RenderStepped:Connect(function()
			for obj, label in pairs(objectLabels) do
				if label and label.Parent then
					local isPlayer = false
					if obj:IsA("BasePart") then
						local char = obj:FindFirstAncestorWhichIsA("Model")
						if char and Players:GetPlayerFromCharacter(char) then
							isPlayer = true
						end
					end

					if isPlayer then
						local hue = tick() % 5 / 5 
						local txt = label:FindFirstChild("TextLabel")
						if txt then
							txt.TextColor3 = Color3.fromHSV(hue, 1, 1)
						end
					end
				end
			end
		end)

		for _,obj in pairs(Workspace:GetDescendants()) do
			if obj:IsA("BasePart") then
				originalTransparency[obj] = obj.Transparency
				originalColors[obj] = obj.Color
				obj.Transparency = 0

				if obj:GetAttribute("Marked") then
					obj.Color = Color3.fromRGB(0, 255, 255)
				else
					if obj.CanCollide then
						obj.Color = Color3.fromRGB(0,255,0)
					end
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
							textLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
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
						textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
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
		if rainbowConnection then
			rainbowConnection:Disconnect()
			rainbowConnection = nil
		end

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
			if selectedObject.Parent then
				selectedObject.Color = Color3.fromRGB(0,255,0) 
			end
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

		markBtn.Text = "Mark"
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

-- FITUR: MARK (Melalui Menu)
markBtn.MouseButton1Click:Connect(function()
	if not selectedObject then return end

	markedCFrame = selectedObject.CFrame

	print("--- MARK SAVED ---")
	print("Position:", markedCFrame.Position)
	print("------------------")

	selectedObject:SetAttribute("Marked", true)
	selectedObject.Color = Color3.fromRGB(0, 255, 255)

	markBtn.Text = "Marked!"
	task.wait(0.5)
	markBtn.Text = "Mark"
end)

deleteBtn.MouseButton1Click:Connect(function()
	if not selectedObject then return end

	selectedObject:Destroy()
	selectedObject = nil
	menu.Visible = false
end)

-------------------------------------------------
-- FITUR BARU: MARKING (Tombol Utama)
-------------------------------------------------

markingBtn.MouseButton1Click:Connect(function()
	local char = player.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	-- Simpan CFrame pemain saat ini
	markedCFrame = hrp.CFrame

	-- Feedback Visual
	markingBtn.Text = "Marked!"
	markingBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)

	print("--- MARKING SAVED ---")
	print("Current Position Marked:", markedCFrame.Position)
	print("---------------------")

	task.wait(0.3)

	-- Reset Tampilan
	markingBtn.Text = "Marking"
	markingBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 150)
end)

-------------------------------------------------
-- FITUR UTAMA: TP TO MARK (FIXED ROTATION)
-------------------------------------------------

tpMarkBtn.MouseButton1Click:Connect(function()
	local char = player.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	-- LOGIKA UNDO
	if isUndoMode then
		if tempMarkCFrame then
			local currentLook = hrp.CFrame.LookVector
			local targetPos = tempMarkCFrame.Position
			hrp.CFrame = CFrame.new(targetPos, targetPos + currentLook)
			print("Returned to temporary position.")
		end

		isUndoMode = false
		tempMarkCFrame = nil
		if undoThread then task.cancel(undoThread) end
		tpMarkBtn.Text = "Teleport"
		tpMarkBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 150)
		return
	end

	-- LOGIKA TELEPORT UTAMA
	if not markedCFrame then
		tpMarkBtn.Text = "No Mark!"
		task.wait(0.5)
		tpMarkBtn.Text = "Teleport"
		return
	end

	-- 1. Simpan posisi saat ini sebagai Temporary (untuk undo nanti)
	tempMarkCFrame = hrp.CFrame

	-- 2. Simpan arah muka player SEBELUM teleport
	local originalLook = hrp.CFrame.LookVector

	-- 3. Ambil posisi tujuan (Mark)
	local targetPos = markedCFrame.Position

	-- 4. Teleport
	hrp.CFrame = CFrame.new(targetPos, targetPos + originalLook)

	-- 5. Aktifkan Mode Undo & Countdown
	isUndoMode = true
	tpMarkBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 0)

	undoThread = task.spawn(function()
		for i = 10, 0, -1 do
			if not isUndoMode then break end
			tpMarkBtn.Text = "Undo ("..tostring(i)..")"
			task.wait(1)
		end

		if isUndoMode then
			isUndoMode = false
			tempMarkCFrame = nil
			tpMarkBtn.Text = "Teleport"
			tpMarkBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 150)
			print("Undo time expired.")
		end
	end)
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
	if ghostBtn:GetAttribute("Active") then
		toggleGhost()
	end
end)
