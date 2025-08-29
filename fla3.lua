-- DOFLAMINGO UI (Responsive)

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TitleBar = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local CloseButton = Instance.new("TextButton")
local MinimizeButton = Instance.new("TextButton")
local ContentFrame = Instance.new("Frame")
local SearchBox = Instance.new("TextBox")
local ButtonsFrame = Instance.new("Frame")


-- Parent
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- MainFrame
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.3, 0, 0.2, 0)
MainFrame.Size = UDim2.new(0, 450, 0, 350)

-- TitleBar
TitleBar.Parent = MainFrame
TitleBar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
TitleBar.Size = UDim2.new(1, 0, 0, 30)

Title.Parent = TitleBar
Title.Text = "DOFLAMINGO"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.Position = UDim2.new(0.02, 0, 0, 0)
Title.Size = UDim2.new(0, 200, 1, 0)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1

CloseButton.Parent = TitleBar
CloseButton.Text = "X"
CloseButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Size = UDim2.new(0, 30, 1, 0)
CloseButton.Position = UDim2.new(1, -30, 0, 0)

MinimizeButton.Parent = TitleBar
MinimizeButton.Text = "-"
MinimizeButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.Size = UDim2.new(0, 30, 1, 0)
MinimizeButton.Position = UDim2.new(1, -60, 0, 0)

-- BUTTON SPEED --
--// Ambil service player
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")

--// Simpan speed normal & fast
local normalSpeed = humanoid.WalkSpeed
local fastSpeed = normalSpeed * 3 -- multiplier bisa diganti sesuai kebutuhan

--// Buat Button Speed di Header
local SpeedButton = Instance.new("TextButton")
SpeedButton.Name = "SpeedButton"
SpeedButton.Parent = TitleBar -- taruh di header
SpeedButton.Size = UDim2.new(0, 30, 1, 0)
SpeedButton.Position = UDim2.new(1, -90, 0, 0)
SpeedButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SpeedButton.Text = "S"
SpeedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedButton.Font = Enum.Font.SourceSansBold
SpeedButton.AutoButtonColor = true
SpeedButton.TextSize = 14


--// Variabel mode
-- 0 = Off, 1 = Mode 1 (Shift), 2 = Mode 2 (Always On)
local speedMode = 0
local shiftHeld = false

--// Fungsi update tombol & warna
local function updateButton()
	if speedMode == 0 then
		SpeedButton.Text = "S"
		SpeedButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		humanoid.WalkSpeed = normalSpeed
	elseif speedMode == 1 then
		SpeedButton.Text = "S1"
		SpeedButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
		-- jalan normal dulu, boost nanti saat shift ditekan
		if shiftHeld then
			humanoid.WalkSpeed = fastSpeed
		else
			humanoid.WalkSpeed = normalSpeed
		end
	elseif speedMode == 2 then
		SpeedButton.Text = "S2"
		SpeedButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
		humanoid.WalkSpeed = fastSpeed
	end
end

--// Toggle mode saat klik tombol
SpeedButton.MouseButton1Click:Connect(function()
	speedMode = (speedMode + 1) % 3
	updateButton()
end)

--// Deteksi Shift untuk Mode 1
UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.LeftShift then
		shiftHeld = true
		if speedMode == 1 then
			humanoid.WalkSpeed = fastSpeed
		end
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.LeftShift then
		shiftHeld = false
		if speedMode == 1 then
			humanoid.WalkSpeed = normalSpeed
		end
	end
end)

--// Refresh kalau respawn
player.CharacterAdded:Connect(function(newChar)
	char = newChar
	humanoid = newChar:WaitForChild("Humanoid")
	normalSpeed = humanoid.WalkSpeed
	updateButton()
end)

-- Inisialisasi
updateButton()
-- BUTTON SPEED OFF --

-- -- BUTTON BLOCK KECIL --
-- local BlockButton = Instance.new("TextButton")
-- BlockButton.Name = "BlockButton"
-- BlockButton.Parent = TitleBar
-- BlockButton.Size = UDim2.new(0, 30, 1, 0)
-- BlockButton.Position = UDim2.new(1, -120, 0, 0)
-- BlockButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
-- BlockButton.Text = "B"
-- BlockButton.TextColor3 = Color3.fromRGB(255, 255, 255)
-- BlockButton.Font = Enum.Font.SourceSansBold
-- BlockButton.TextSize = 14
-- BlockButton.AutoButtonColor = true
-- -- BUTTON BLOCK KECIL OFF --

-- UserList
local UserList = Instance.new("ScrollingFrame")
UserList.Parent = ContentFrame
UserList.BackgroundColor3 = Color3.fromRGB(120, 120, 120)
UserList.AnchorPoint = Vector2.new(0,1) -- anchor di bawah
UserList.Position = UDim2.new(0,10,1,-10) -- selalu 10px dari bawah
UserList.Size = UDim2.new(1,-1,1,-140) -- tinggi menyesuaikan, kasih padding
UserList.ScrollBarThickness = 6 -- ketebalan scrollbar
UserList.CanvasSize = UDim2.new(0,0,0,0) -- bakal auto diatur sama UIListLayout
UserList.AutomaticCanvasSize = Enum.AutomaticSize.Y
UserList.ScrollBarImageColor3 = Color3.fromRGB(180,180,180) -- warna scrollbar

-- layout di dalam userlist
local listLayout = Instance.new("UIListLayout", UserList)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 5)

listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	UserList.CanvasSize = UDim2.new(0,0,0,listLayout.AbsoluteContentSize.Y + 10)
end)

local padding = Instance.new("UIPadding", UserList)
padding.PaddingTop = UDim.new(0,5)
padding.PaddingLeft = UDim.new(0,5)
padding.PaddingRight = UDim.new(0,5)
padding.PaddingBottom = UDim.new(0,5)

-- Content Frame
ContentFrame.Parent = MainFrame
ContentFrame.BackgroundTransparency = 1
ContentFrame.Position = UDim2.new(0, 0, 0, 30)
ContentFrame.Size = UDim2.new(1, 0, 1, -30)

-- Layout otomatis untuk ContentFrame
local contentLayout = Instance.new("UIListLayout")
contentLayout.Parent = ContentFrame
contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
contentLayout.Padding = UDim.new(0, 10)

local contentPadding = Instance.new("UIPadding")
contentPadding.Parent = ContentFrame
contentPadding.PaddingTop = UDim.new(0, 10)
contentPadding.PaddingLeft = UDim.new(0, 10)
contentPadding.PaddingRight = UDim.new(0, 10)

-- SEARCH --
local SearchBox = Instance.new("TextBox")
SearchBox.Parent = ContentFrame
SearchBox.PlaceholderText = "search"
SearchBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SearchBox.Size = UDim2.new(1, 0, 0, 30)
SearchBox.Position = UDim2.new(0, 10, 0, 10)
SearchBox.ClearTextOnFocus = false

-- ScrollingFrame buat shortcut
local ShortcutContainer = Instance.new("ScrollingFrame")
ShortcutContainer.Name = "ShortcutContainer"
ShortcutContainer.Parent = ContentFrame
ShortcutContainer.BackgroundTransparency = 1
ShortcutContainer.Size = UDim2.new(1, 0, 0, 30)
ShortcutContainer.Position = UDim2.new(0, 10, 0, 45)
ShortcutContainer.ScrollBarThickness = 4
ShortcutContainer.ScrollingDirection = Enum.ScrollingDirection.X
ShortcutContainer.CanvasSize = UDim2.new(0, 0, 0, 0)

-- Layout horizontal
local layout = Instance.new("UIListLayout")
layout.Parent = ShortcutContainer
layout.FillDirection = Enum.FillDirection.Horizontal
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 5)

-- Daftar shortcut
local shortcuts = {
	{label = "Players", value = "Players:"},
	{label = "Checkpoint", value = "Workspace:Check"},
	{label = "Workspace", value = "Workspace:"},
	{label = "Bunsin", value = "Workspace:Bunsin"},
}

-- Buat tombol shortcut
for _, sc in ipairs(shortcuts) do
	local btn = Instance.new("TextButton")
	btn.Parent = ShortcutContainer
	btn.Text = sc.label
	btn.Size = UDim2.new(0, 140, 0, 25)
	btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.MouseButton1Click:Connect(function()
		SearchBox.Text = sc.value
	end)
end

-- Update canvas size biar scroll bisa jalan
layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	ShortcutContainer.CanvasSize = UDim2.new(0, layout.AbsoluteContentSize.X, 0, 0)
end)
--

-- Buttons
ButtonsFrame.Parent = ContentFrame
ButtonsFrame.Size = UDim2.new(1, 0, 0, 40)
ButtonsFrame.Position = UDim2.new(0, 10, 0, 80)
ButtonsFrame.BackgroundTransparency = 1

-- Layout untuk tombol atas
local topLayout = Instance.new("UIListLayout", ButtonsFrame)
topLayout.FillDirection = Enum.FillDirection.Horizontal
topLayout.Padding = UDim.new(0, 10)
topLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left

local function MakeButton(name, text, textColor)
	local btn = Instance.new("TextButton")
	btn.Parent = ButtonsFrame
	btn.Name = name
	btn.Text = text
	btn.Size = UDim2.new(0.1811, 0, 1, 0) -- 19% biar masih ada ruang padding
	btn.BackgroundColor3 = Color3.fromRGB(0,0,0)
	btn.TextColor3 = textColor
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 14
	return btn
end

local ScanBtn = MakeButton("Scan", "SCAN", Color3.fromRGB(255,140,0))
local FreeCamBtn = MakeButton("FreeCam", "FREE CAM", Color3.fromRGB(255,255,255))
local BunsinBtn = MakeButton("Bunsin", "BUNSIN", Color3.fromRGB(255,255,255))
local BlockBtn = MakeButton("Block", "BLOCK : OFF", Color3.fromRGB(255,255,255))
local BarierBtn = MakeButton("Barier", "BARIER : OFF", Color3.fromRGB(255,255,255))

-- === SCAN FUNCTION FIX ===
local Camera = workspace.CurrentCamera
local LocalPlayer = game.Players.LocalPlayer

local function ClearUserList()
	for _, c in ipairs(UserList:GetChildren()) do
		if not c:IsA("UIListLayout") and not c:IsA("UIPadding") then
			c:Destroy()
		end
	end
end

-- cek apakah punya BasePart
local function hasAnyBasePartIn(inst)
	if inst:IsA("BasePart") then return true end
	if inst:IsA("Model") then
		return inst:FindFirstChildWhichIsA("BasePart") ~= nil
	end
	return false
end

-- bikin row hasil scan
local function MakeRow(nameText, color)
	local row = Instance.new("Frame")
	row.Parent = UserList
	row.Size = UDim2.new(1,0,0,30)
	row.BackgroundColor3 = color or Color3.fromRGB(80,80,80)

	-- layout horizontal utama
	local rowLayout = Instance.new("UIListLayout")
	rowLayout.Parent = row
	rowLayout.FillDirection = Enum.FillDirection.Horizontal
	rowLayout.SortOrder = Enum.SortOrder.LayoutOrder
	rowLayout.Padding = UDim.new(0,5)

	-- kiri: label
	local labelFrame = Instance.new("Frame")
	labelFrame.Parent = row
	labelFrame.BackgroundTransparency = 1
	labelFrame.Size = UDim2.new(1, -200, 1, 0) -- sisa 200px buat tombol

	local label = Instance.new("TextLabel")
	label.Parent = labelFrame
	label.Size = UDim2.new(1,0,1,0)
	label.BackgroundTransparency = 1
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextColor3 = Color3.fromRGB(255,255,255)
	label.Font = Enum.Font.SourceSansBold
	label.TextSize = 14
	label.Text = nameText

	-- kanan: tombol container
	local btnFrame = Instance.new("Frame")
	btnFrame.Parent = row
	btnFrame.BackgroundTransparency = 1
	btnFrame.Size = UDim2.new(0,200,1,0)

	local btnLayout = Instance.new("UIListLayout")
	btnLayout.Parent = btnFrame
	btnLayout.FillDirection = Enum.FillDirection.Horizontal
	btnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	btnLayout.Padding = UDim.new(0,5)

	return row, btnFrame
end

-- bikin mini button di dalam btnFrame
local function MakeMiniBtn(btnFrame, text, callback)
	local b = Instance.new("TextButton")
	b.Parent = btnFrame
	b.Size = UDim2.new(0,80,1,0)
	b.BackgroundColor3 = Color3.fromRGB(60,60,60)
	b.TextColor3 = Color3.fromRGB(255,255,255)
	b.Font = Enum.Font.SourceSansBold
	b.TextSize = 14
	b.Text = text
	b.MouseButton1Click:Connect(callback)
	return b
end

-- teleport ke belakang target
local function TeleportBehind(target)
	local char = LocalPlayer.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end

	local pos
	if target:IsA("Model") then
		local p = target.PrimaryPart or target:FindFirstChildWhichIsA("BasePart")
		if not p then return end
		pos = p.Position
	elseif target:IsA("BasePart") then
		pos = target.Position
	elseif target:FindFirstChild("HumanoidRootPart") then
		pos = target.HumanoidRootPart.Position
	else
		return
	end

	local behind = pos + (Camera.CFrame.LookVector * 5)
	char.HumanoidRootPart.CFrame = CFrame.new(behind, pos)
end

-- toggle view
local viewingTarget = nil
local function ToggleView(target)
	if viewingTarget == target then
		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
			Camera.CameraSubject = LocalPlayer.Character.Humanoid
		end
		viewingTarget = nil
	else
		if target:IsA("Model") and target:FindFirstChild("Humanoid") then
			Camera.CameraSubject = target.Humanoid
		elseif target:IsA("BasePart") then
			Camera.CameraSubject = target
		elseif target:FindFirstChild("HumanoidRootPart") then
			Camera.CameraSubject = target.HumanoidRootPart
		end
		viewingTarget = target
	end
end

-- scan workspace
local UsingBunsin = false
local OriginalChar = nil
local function scanWorkspace(filter)
	for _, obj in ipairs(workspace:GetChildren()) do
		if hasAnyBasePartIn(obj) and (filter == "" or obj.Name:lower():find(filter)) then
			local row, btnFrame = MakeRow(obj.Name, Color3.fromRGB(90,90,90))
			MakeMiniBtn(btnFrame, "Teleport", function() TeleportBehind(obj) end)
			MakeMiniBtn(btnFrame, "View", function() ToggleView(obj) end)
			if obj:IsA("Model") and obj.Name:lower():find("bunsin") then
				local useBtn
				useBtn = MakeMiniBtn(btnFrame, "Use", function()
					local bunsin = obj
					local humanoid = bunsin:FindFirstChildOfClass("Humanoid")
					local hrp = bunsin:FindFirstChild("HumanoidRootPart")

					if not humanoid or not hrp then return end

					if not UsingBunsin then
						OriginalChar = LocalPlayer.Character
						LocalPlayer.Character = bunsin
						workspace.CurrentCamera.CameraSubject = humanoid
						workspace.CurrentCamera.CFrame = CFrame.new(hrp.Position + Vector3.new(0,5,10), hrp.Position)

						UsingBunsin = true
						useBtn.Text = "Unuse"
					else
						if OriginalChar and OriginalChar:FindFirstChildOfClass("Humanoid") then
							LocalPlayer.Character = OriginalChar
							workspace.CurrentCamera.CameraSubject = OriginalChar:FindFirstChildOfClass("Humanoid")
						end

						UsingBunsin = false
						useBtn.Text = "Use"
					end
				end)
			end

		end
	end
end

-- scan players
local function scanPlayers(filter)
	for _, plr in ipairs(game.Players:GetPlayers()) do
		local char = plr.Character
		if char and char:FindFirstChild("HumanoidRootPart") then
			local disp = plr.DisplayName or plr.Name
			if filter == "" or disp:lower():find(filter) or char.Name:lower():find(filter) then
				local row, btnFrame = MakeRow(disp.." ("..char.Name..")", Color3.fromRGB(100,100,100))
				MakeMiniBtn(btnFrame, "Teleport", function() TeleportBehind(char) end)
				MakeMiniBtn(btnFrame, "View", function() ToggleView(char) end)
			end
		end
	end
end


-- event tombol SCAN
ScanBtn.MouseButton1Click:Connect(function()
	ClearUserList()
	local q = (SearchBox.Text or ""):lower()
	local parent, rawFilter = q:match("^([^:]+):%s*(.*)$")
	if not parent then return end
	local filter = rawFilter or ""

	if parent == "workspace" then
		scanWorkspace(filter)
	elseif parent == "players" then
		scanPlayers(filter)
	end
end)
-- === END SCAN FUNCTION ===

-- FREE CAM SCRIPT + UI ARAH + WASD --
local freecamOn = false
local freecamClone
local moveConnection
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = game.Players.LocalPlayer
local Camera = workspace.CurrentCamera
local speed = 1 -- kecepatan gerak freecam

-- simpan data asli player
local originalWalkSpeed, originalJumpPower

-- UI tombol arah (dibuat sekali aja)
local FreecamGui = Instance.new("ScreenGui") -- ganti nama variabel & instans
FreecamGui.Name = "FreecamUI"
FreecamGui.ResetOnSpawn = false
FreecamGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- frame utama arah
local MoveFrame = Instance.new("Frame")
MoveFrame.Size = UDim2.new(0, 150, 0, 150)
MoveFrame.Position = UDim2.new(0, 20, 1, -170)
MoveFrame.BackgroundTransparency = 1
MoveFrame.Visible = false
MoveFrame.Parent = FreecamGui

-- buat tombol
local function makeBtn(txt, pos)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 40, 0, 40)
	btn.Position = pos
	btn.Text = txt
	btn.TextColor3 = Color3.new(1,1,1)
	btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
	btn.BackgroundTransparency = 0.3
	btn.Parent = MoveFrame
	btn.AutoButtonColor = true
	btn.Font = Enum.Font.SourceSansBold
	btn.TextScaled = true
	return btn
end

local BtnUp = makeBtn("↑", UDim2.new(0.33, 0, 0, 0))
local BtnDown = makeBtn("↓", UDim2.new(0.33, 0, 0, 80))
local BtnLeft = makeBtn("←", UDim2.new(0, 0, 0, 40))
local BtnRight = makeBtn("→", UDim2.new(0.66, 0, 0, 40))
local BtnAscend = makeBtn("⤒", UDim2.new(0.33, 0, 0, -40))
local BtnDescend = makeBtn("⤓", UDim2.new(0.33, 0, 0, 120))

-- status tombol ditekan
local moveState = {
	Up = false,
	Down = false,
	Left = false,
	Right = false,
	Ascend = false,
	Descend = false,
}

-- fungsi toggle tombol
local function bindBtn(btn, key)
	btn.MouseButton1Down:Connect(function() moveState[key] = true end)
	btn.MouseButton1Up:Connect(function() moveState[key] = false end)
	btn.MouseLeave:Connect(function() moveState[key] = false end)
end
bindBtn(BtnUp, "Up")
bindBtn(BtnDown, "Down")
bindBtn(BtnLeft, "Left")
bindBtn(BtnRight, "Right")
bindBtn(BtnAscend, "Ascend")
bindBtn(BtnDescend, "Descend")

-- WASD + Space/Ctrl input PC
local kbState = {
	Up = false,
	Down = false,
	Left = false,
	Right = false,
	Ascend = false,
	Descend = false,
}

UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe or not freecamOn then return end
	if input.KeyCode == Enum.KeyCode.W then kbState.Up = true end
	if input.KeyCode == Enum.KeyCode.S then kbState.Down = true end
	if input.KeyCode == Enum.KeyCode.A then kbState.Left = true end
	if input.KeyCode == Enum.KeyCode.D then kbState.Right = true end
	if input.KeyCode == Enum.KeyCode.Space then kbState.Ascend = true end
	if input.KeyCode == Enum.KeyCode.LeftControl then kbState.Descend = true end
end)

UserInputService.InputEnded:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.W then kbState.Up = false end
	if input.KeyCode == Enum.KeyCode.S then kbState.Down = false end
	if input.KeyCode == Enum.KeyCode.A then kbState.Left = false end
	if input.KeyCode == Enum.KeyCode.D then kbState.Right = false end
	if input.KeyCode == Enum.KeyCode.Space then kbState.Ascend = false end
	if input.KeyCode == Enum.KeyCode.LeftControl then kbState.Descend = false end
end)

-- tombol utama untuk aktifin freecam
FreeCamBtn.MouseButton1Click:Connect(function()
	freecamOn = not freecamOn

	if freecamOn then
		FreeCamBtn.TextColor3 = Color3.fromRGB(0,255,0)
		MoveFrame.Visible = true -- tampilkan UI kontrol

		local char = LocalPlayer.Character
		if not char or not char:FindFirstChild("HumanoidRootPart") then return end
		local hum = char:FindFirstChild("Humanoid")

		-- freeze karakter utama
		if hum then
			originalWalkSpeed = hum.WalkSpeed
			originalJumpPower = hum.JumpPower
			hum.WalkSpeed = 0
			hum.JumpPower = 0
		end

		-- clone dummy freecam
		char.Archivable = true
		freecamClone = char:Clone()
		freecamClone.Name = LocalPlayer.Name.."_freecam"

		-- bikin semi transparan & noclip
		for _, part in ipairs(freecamClone:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
				part.Transparency = 0.5
				if part.Name == "HumanoidRootPart" then
					part.Anchored = true
					part.Transparency = 1
				else
					part.Anchored = false
					part.Transparency = 0.9
				end
			end
		end

		-- hapus semua script supaya ga jalan
		for _,v in ipairs(freecamClone:GetDescendants()) do
			if v:IsA("LocalScript") or v:IsA("Script") then
				v:Destroy()
			end
		end

		-- dummy biar kaku tapi bisa digerakin
		if freecamClone:FindFirstChild("Humanoid") then
			freecamClone.Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
			freecamClone.Humanoid.AutoRotate = true
		end

		-- set PrimaryPart
		if freecamClone:FindFirstChild("HumanoidRootPart") then
			freecamClone.PrimaryPart = freecamClone.HumanoidRootPart
			freecamClone:SetPrimaryPartCFrame(char.HumanoidRootPart.CFrame * CFrame.new(0,0,-5))
		end

		freecamClone.Parent = workspace

		-- kamera spectate ke clone
		Camera.CameraSubject = freecamClone:FindFirstChild("Humanoid") or freecamClone.PrimaryPart

		-- kontrol pergerakan clone
		moveConnection = RunService.RenderStepped:Connect(function()
			if not freecamOn or not freecamClone or not freecamClone.PrimaryPart then return end

			local moveDir = Vector3.new(0,0,0)

			-- input dari UI tombol (mobile)
			if moveState.Up then moveDir += Camera.CFrame.LookVector end
			if moveState.Down then moveDir -= Camera.CFrame.LookVector end
			if moveState.Left then moveDir -= Camera.CFrame.RightVector end
			if moveState.Right then moveDir += Camera.CFrame.RightVector end
			if moveState.Ascend then moveDir += Vector3.new(0,1,0) end
			if moveState.Descend then moveDir -= Vector3.new(0,1,0) end

			-- input dari keyboard (PC)
			if kbState.Up then moveDir += Camera.CFrame.LookVector end
			if kbState.Down then moveDir -= Camera.CFrame.LookVector end
			if kbState.Left then moveDir -= Camera.CFrame.RightVector end
			if kbState.Right then moveDir += Camera.CFrame.RightVector end
			if kbState.Ascend then moveDir += Vector3.new(0,1,0) end
			if kbState.Descend then moveDir -= Vector3.new(0,1,0) end

			-- rotasi clone ikut POV camera
			local root = freecamClone.PrimaryPart
			local newCFrame = CFrame.new(root.Position, root.Position + Camera.CFrame.LookVector)

			if moveDir.Magnitude > 0 then
				root.CFrame = newCFrame + (moveDir.Unit * speed)
			else
				root.CFrame = newCFrame
			end
		end)

	else
		FreeCamBtn.TextColor3 = Color3.fromRGB(255,255,255)
		MoveFrame.Visible = false -- sembunyikan UI kontrol

		-- kamera balik ke karakter asli
		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
			Camera.CameraSubject = LocalPlayer.Character.Humanoid
			LocalPlayer.Character.Humanoid.WalkSpeed = originalWalkSpeed or 16
			LocalPlayer.Character.Humanoid.JumpPower = originalJumpPower or 50
		end

		if freecamClone then
			freecamClone:Destroy()
			freecamClone = nil
		end

		if moveConnection then
			moveConnection:Disconnect()
			moveConnection = nil
		end
	end
end)
-- FREE CAM END --


-- ADVANCED BLOCK SCRIPT (3 CONDITIONS) --
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local blockOn = false
local blockConnections = {}
local lastBlockTime = 0
local blockCooldown = 0.3

-- state untuk landed
local landedBlockActive = false
local lastLandedPos = nil
local specialBlockActive = false

-- fungsi bikin block biasa
local function createBlock(char)
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	local block = Instance.new("Part")
	block.Size = Vector3.new(10, 0.1, 10)
	block.Anchored = true
	block.CanCollide = true
	block.BrickColor = BrickColor.new("Medium stone grey")
	block.Transparency = 0.9
	block.CFrame = CFrame.new(hrp.Position.X, hrp.Position.Y - 3, hrp.Position.Z)
	block.Parent = workspace
	game:GetService("Debris"):AddItem(block, 2)
end

-- fungsi bikin block landed
local function createLandedBlock(char)
	if landedBlockActive then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	-- cek lokasi landed terakhir
	local landedPos = Vector3.new(math.floor(hrp.Position.X/5), 0, math.floor(hrp.Position.Z/5))

	-- jika sama dengan terakhir -> bikin block spesial
	if lastLandedPos and (landedPos - lastLandedPos).Magnitude < 1 then
		if specialBlockActive then return end -- jangan spawn lain kalau special masih ada

		specialBlockActive = true
		local special = Instance.new("Part")
		special.Size = Vector3.new(500, 0.1, 500)
		special.Anchored = true
		special.CanCollide = true
		special.BrickColor = BrickColor.new("Bright yellow")
		special.Transparency = 0.9
		special.CFrame = CFrame.new(hrp.Position.X, hrp.Position.Y - 6, hrp.Position.Z)
		special.Parent = workspace

		task.delay(10, function()
			if special then special:Destroy() end
			specialBlockActive = false
		end)
	else
		-- block biasa landed
		landedBlockActive = true
		local block = Instance.new("Part")
		block.Size = Vector3.new(10, 0.1, 10)
		block.Anchored = true
		block.CanCollide = true
		block.BrickColor = BrickColor.new("Really blue")
		block.Transparency = 0.9
		block.CFrame = CFrame.new(hrp.Position.X, hrp.Position.Y - 5
      , hrp.Position.Z)
		block.Parent = workspace

		game:GetService("Debris"):AddItem(block, 2)
		task.delay(2, function()
			landedBlockActive = false
		end)
	end

	lastLandedPos = landedPos
end

-- pasang collision pada part tubuh
local function hookTouchedOnPart(part, char, hum)
	if not part:IsA("BasePart") then return end
	local conn = part.Touched:Connect(function(hit)
		if not blockOn or specialBlockActive then return end
		if not hit or not hit:IsA("BasePart") or not hit.CanCollide then return end
		if hit:IsDescendantOf(char) then return end

		-- harus saat di udara
		if hum and hum.FloorMaterial ~= Enum.Material.Air then return end

		local now = tick()
		if now - lastBlockTime < blockCooldown then return end
		lastBlockTime = now

		createBlock(char)
	end)
	table.insert(blockConnections, conn)
end

-- toggle button
BlockBtn.MouseButton1Click:Connect(function()
	blockOn = not blockOn

	if blockOn then
		BlockBtn.Text = "BLOCK : ON"
		BlockBtn.TextColor3 = Color3.fromRGB(0,255,0)

		local char = player.Character or player.CharacterAdded:Wait()
		local hum  = char:WaitForChild("Humanoid")

		-- bersihkan lama
		for _,c in ipairs(blockConnections) do c:Disconnect() end
		table.clear(blockConnections)

		-- pasang Touched di semua part
		for _,d in ipairs(char:GetDescendants()) do
			if d:IsA("BasePart") then
				hookTouchedOnPart(d, char, hum)
			end
		end

		-- deteksi landed
		table.insert(blockConnections, hum.StateChanged:Connect(function(_, new)
			if not blockOn or specialBlockActive then return end
			if new == Enum.HumanoidStateType.Landed then
				createLandedBlock(char)
			end
		end))

		-- kalau ada part baru
		table.insert(blockConnections, char.DescendantAdded:Connect(function(d)
			if d:IsA("BasePart") then
				hookTouchedOnPart(d, char, hum)
			end
		end))
	else
		BlockBtn.Text = "BLOCK : OFF"
		BlockBtn.TextColor3 = Color3.fromRGB(255,255,255)
		for _,c in ipairs(blockConnections) do c:Disconnect() end
		table.clear(blockConnections)
	end
end)
-- SCRIPT END --


-- BUTTON BARRIER --
-- status toggle
local barierOn = false
local changedParts = {} -- untuk nyimpan data part yang diubah

BarierBtn.MouseButton1Click:Connect(function()
	barierOn = not barierOn

	if barierOn then
		-- ubah tampilan tombol
		BarierBtn.Text = "BARIER : ON"
		BarierBtn.TextColor3 = Color3.fromRGB(0,255,0) -- hijau

		changedParts = {} -- reset list

		for _, obj in ipairs(workspace:GetDescendants()) do
			if obj:IsA("BasePart") then
				-- simpan kondisi asli
				table.insert(changedParts, {
					part = obj,
					oldTransparency = obj.Transparency,
					oldColor = obj.Color,
					oldCanCollide = obj.CanCollide
				})

				-- aturan 1: invisible jadi visible
				if obj.Transparency == 1 then
					obj.Transparency = 0
				end

				-- aturan 2: kalau collidable maka jadi hijau
				if obj.CanCollide == true then
					obj.Color = Color3.fromRGB(0,255,0)
				end
			end
		end

	else
		-- kembali ke OFF
		BarierBtn.Text = "BARIER : OFF"
		BarierBtn.TextColor3 = Color3.fromRGB(255,255,255) -- putih

		-- balikin semua yang tadi diubah ke kondisi awal
		for _, data in ipairs(changedParts) do
			if data.part and data.part.Parent and data.part:IsA("BasePart") then
				data.part.Transparency = data.oldTransparency
				data.part.Color = data.oldColor
				data.part.CanCollide = data.oldCanCollide
			end
		end
		changedParts = {} -- kosongkan lagi
	end
end)
-- BUTTON BARRIER END --

--BUTTON BUNSIN----BUTTON BUNSIN--
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local bunsinCount = 0 -- counter global untuk nomor bunsin

BunsinBtn.MouseButton1Click:Connect(function()
	local char = LocalPlayer.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end

	-- cari target posisi dari spectate
	local cam = workspace.CurrentCamera
	local target = cam.CameraSubject
	local spawnFrom = char -- default posisi dari karakter utama

	if target and target.Parent and target.Parent.Name == (LocalPlayer.Name .. "_freecam") then
		-- kalau lagi spectate freecam, posisinya ikut freecam
		spawnFrom = target.Parent
	end

	-- selalu clone karakter utama (bukan freecam!)
	char.Archivable = true
	local clone = char:Clone()

	-- increment nomor bunsin
	bunsinCount += 1
	clone.Name = LocalPlayer.Name .. "_bunsin" .. bunsinCount

	-- buang semua script biar dummy
	for _,v in ipairs(clone:GetDescendants()) do
		if v:IsA("LocalScript") or v:IsA("Script") then
			v:Destroy()
		end
	end

	-- set PrimaryPart kalau hilang
	if not clone.PrimaryPart and clone:FindFirstChild("HumanoidRootPart") then
		clone.PrimaryPart = clone.HumanoidRootPart
	end

	-- dummy biar kaku (nggak hidup)
	if clone:FindFirstChild("Humanoid") then
		clone.Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
		clone.Humanoid.AutoRotate = true
	end

	-- nonaktifkan collision tapi tetap kelihatan normal
	for _, part in ipairs(clone:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CanCollide = false
			-- JANGAN diubah transparansinya (tetap normal)
		end
	end

	-- spawn di depan objek spectate
	if clone.PrimaryPart and spawnFrom:FindFirstChild("HumanoidRootPart") then
		local rootCFrame = spawnFrom.HumanoidRootPart.CFrame
		clone:SetPrimaryPartCFrame(rootCFrame * CFrame.new(0,0,-3))
	end

	-- munculin di workspace
	clone.Parent = workspace
end)
--BUNSIN END--

-- Minimize & Close
local minimized = false
MinimizeButton.MouseButton1Click:Connect(function()
	minimized = not minimized
	if minimized then
		ContentFrame.Visible = false
		MainFrame.Size = UDim2.new(0,450,0,30)
	else
		ContentFrame.Visible = true
		MainFrame.Size = UDim2.new(0,450,0,350)
	end
end)

CloseButton.MouseButton1Click:Connect(function()
	ScreenGui:Destroy()
end)

-- Dragging
local UIS = game:GetService("UserInputService")
local dragging, dragInput, dragStart, startPos

TitleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 
		or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = MainFrame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)


TitleBar.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement 
		or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)


UIS.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)
