-- Floating Tools UI (PC + Mobile) - Ghost Sphere Rev 20 (Gojo Shield Update)
-- Update: Fixed Shield Geometry (Sealed Corners) & Thickness for Anti-Penetration

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local PhysicsService = game:GetService("PhysicsService") -- Ditambahkan untuk Collision Group

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-------------------------------------------------
-- GUI MAIN PANEL
-------------------------------------------------

local gui = Instance.new("ScreenGui")
gui.Name = "ToolsUI"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 245, 0, 95)
panel.Position = UDim2.new(0.05, 0, 0.7, 0)
panel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
panel.BackgroundTransparency = 0.3
panel.Active = true
panel.Parent = gui

Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -105, 0, 20)
title.Position = UDim2.new(0, 10, 0, 5)
title.BackgroundTransparency = 1
title.Text = "SKIZOO"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextSize = 14
title.Parent = panel

-- Tombol Minimize (Pojok Kanan)
local minBtn = Instance.new("TextButton")
minBtn.Name = "MinimizeBtn"
minBtn.Size = UDim2.new(0, 20, 0, 20)
minBtn.Position = UDim2.new(1, -25, 0, 5)
minBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
minBtn.TextColor3 = Color3.new(1, 1, 1)
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 14
minBtn.Text = "-"
minBtn.Parent = panel
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 4)

-- Tombol Pin (Kiri Minimize)
local pinBtn = Instance.new("TextButton")
pinBtn.Name = "PinBtn"
pinBtn.Size = UDim2.new(0, 25, 0, 20)
pinBtn.Position = UDim2.new(1, -55, 0, 5)
pinBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
pinBtn.TextColor3 = Color3.new(1, 1, 1)
pinBtn.Font = Enum.Font.GothamBold
pinBtn.TextSize = 12
pinBtn.Text = "pin"
pinBtn.Parent = panel
Instance.new("UICorner", pinBtn).CornerRadius = UDim.new(0, 4)

-- Tombol Evil (Kiri Pin)
local evilBtn = Instance.new("TextButton")
evilBtn.Name = "EvilBtn"
evilBtn.Size = UDim2.new(0, 35, 0, 20)
evilBtn.Position = UDim2.new(1, -95, 0, 5)
evilBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
evilBtn.TextColor3 = Color3.new(1, 1, 1)
evilBtn.Font = Enum.Font.GothamBold
evilBtn.TextSize = 12
evilBtn.Text = "Evil"
evilBtn.Parent = panel
Instance.new("UICorner", evilBtn).CornerRadius = UDim.new(0, 4)

-------------------------------------------------
-- VARIABLES
-------------------------------------------------

local isPinned = false
local autoMarkingActive = false

local selectedObject
local selectedOriginalColor
local broughtObjects = {}
local lastClick = 0
local lastObject
local originalTransparency = {}
local originalColors = {}
local objectLabels = {}

local ghostSphere = nil
local ghostConnections = {}
local mobileControls = nil

local markedCFrame = nil
local tempMarkCFrame = nil
local isUndoMode = false
local undoThread = nil

local spectatingPlayer = nil
local spectatingConnection = nil
local playerRows = {}

local isEvilMode = false
local isMinimized = false
local originalSize = panel.Size

local currentSearchResults = {} 
local currentSearchTerm = ""
local searchLoopConnection = nil

-------------------------------------------------
-- FUNCTIONS
-------------------------------------------------

local function showRainbowNotification(text)
	local character = player.Character
	if not character then return end

	local hrp = character:FindFirstChild("HumanoidRootPart")
	local head = character:FindFirstChild("Head")
	if not hrp then return end

	local oldGui = character:FindFirstChild("RainbowNotify")
	if oldGui then oldGui:Destroy() end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "RainbowNotify"
	billboard.Adornee = head or hrp
	billboard.Size = UDim2.new(0, 200, 0, 50)
	billboard.StudsOffset = Vector3.new(0, 3, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = character

	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = text
	textLabel.TextColor3 = Color3.new(1, 1, 1)
	textLabel.TextStrokeTransparency = 0.8
	textLabel.Font = Enum.Font.GothamBold
	textLabel.TextSize = 20
	textLabel.Parent = billboard

	local rainbowConn
	rainbowConn = RunService.RenderStepped:Connect(function()
		if not billboard or not billboard.Parent then 
			rainbowConn:Disconnect()
			return 
		end
		local hue = tick() % 5 / 5
		textLabel.TextColor3 = Color3.fromHSV(hue, 1, 1)
	end)

	task.delay(3, function()
		if rainbowConn then rainbowConn:Disconnect() end
		if billboard then billboard:Destroy() end
	end)
end

local function makeDraggable(frame)
	local dragging
	local dragStart
	local startPos

	frame.InputBegan:Connect(function(input)
		if isPinned then return end 

		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
			frame.ZIndex = 10 
		end
	end)

	frame.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
			frame.ZIndex = 1
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging then
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				local delta = input.Position - dragStart
				frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			end
		end
	end)
end

-------------------------------------------------
-- TAMENG TOOL FUNCTION (GHOST IDENTITY - SAFE MODE)
-- Konsep: Mengubah nama Humanoid agar NPC tidak mengenali pemain sebagai target.
-- Kelebihan: Tidak mengubah fisika, jalan normal, tidak tembus pandang.
-------------------------------------------------

local function createTamengTool()
	local tool = Instance.new("Tool")
	tool.Name = "NPC"
	tool.RequiresHandle = false
	tool.Parent = player.Backpack

	local originalNames = {}
	local connection = nil
	-- Nama palsu yang tidak dicari oleh NPC
	local FAKE_NAME = "Object_Dummy_" .. math.random(1, 10000) 

	tool.Equipped:Connect(function()
		local char = player.Character
		if not char then return end

		-- 1. Simpan nama asli dan ubah nama (Metode Anti-Detection)
		local hum = char:FindFirstChild("Humanoid")
		local hrp = char:FindFirstChild("HumanoidRootPart")

		-- Ubah nama Humanoid (Target utama sensor NPC)
		if hum then
			originalNames[hum] = hum.Name
			hum.Name = FAKE_NAME
		end

		-- Ubah nama HumanoidRootPart (Target sekunder sensor NPC)
		if hrp then
			originalNames[hrp] = hrp.Name
			hrp.Name = "DummyRoot_" .. math.random(1, 10000)
		end

		showRainbowNotification("Ghost Identity Active! NPC Ignore You.")

		-- 2. Loop Pengaman:
		-- Beberapa game memiliki script yang otomatis memperbaiki nama (Anti-Exploit).
		-- Loop ini memastikan nama tetap tersembunyi selama tool dipakai.
		connection = RunService.Heartbeat:Connect(function()
			if not char or not char.Parent then
				if connection then connection:Disconnect() end
				return
			end

			-- Paksa nama tetap palsu jika game mencoba mengubahnya kembali
			if hum and hum.Parent and hum.Name ~= FAKE_NAME then
				hum.Name = FAKE_NAME
			end
		end)
	end)

	tool.Unequipped:Connect(function()
		-- Hentikan loop pengaman
		if connection then connection:Disconnect() end

		local char = player.Character
		if not char then return end

		-- 3. Kembalikan nama asli dengan AMAN
		-- Kita tidak menyentuh CanCollide/Transparency, jadi tidak akan ada glitch jalan.
		for obj, name in pairs(originalNames) do
			if obj and obj.Parent then
				obj.Name = name
			end
		end

		originalNames = {}
	end)
end

-------------------------------------------------
-- BUTTON CREATOR
-------------------------------------------------

local BTN_WIDTH = 75
local BTN_HEIGHT = 28
local BTN_GAP = 5
local START_X = 5

local function createButton(text, x, y, color)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, BTN_WIDTH, 0, BTN_HEIGHT)
	btn.Position = UDim2.new(0, x, 0, y)
	btn.Text = text
	btn.BackgroundColor3 = color or Color3.fromRGB(70, 70, 70)
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 13
	btn.Parent = panel
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
	return btn
end

-------------------------------------------------
-- FEATURE BUTTONS
-------------------------------------------------

local visionBtn = createButton("Vision", START_X, 30, Color3.fromRGB(70, 70, 70))
local jumpBtn = createButton("Jump", START_X + (BTN_WIDTH + BTN_GAP), 30, Color3.fromRGB(70, 70, 70))
local ghostBtn = createButton("Ghost", START_X + (BTN_WIDTH + BTN_GAP) * 2, 30, Color3.fromRGB(70, 70, 70))
local playerListBtn = createButton("Player", START_X, 62, Color3.fromRGB(150, 50, 50))
local markingBtn = createButton("Marking", START_X + (BTN_WIDTH + BTN_GAP), 62, Color3.fromRGB(0, 100, 150))
local tpMarkBtn = createButton("Teleport", START_X + (BTN_WIDTH + BTN_GAP) * 2, 62, Color3.fromRGB(100, 0, 150))

local featureButtons = {visionBtn, jumpBtn, ghostBtn, playerListBtn, markingBtn, tpMarkBtn}

-------------------------------------------------
-- EVIL MODE UI
-------------------------------------------------

local cmdBox = Instance.new("TextBox")
cmdBox.Name = "CommandBox"
cmdBox.Size = UDim2.new(1, -10, 0, 25)
cmdBox.Position = UDim2.new(0, 5, 0, 30)
cmdBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
cmdBox.TextColor3 = Color3.new(1, 1, 1)
cmdBox.PlaceholderText = "command here (e.g w:cp)"
cmdBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
cmdBox.Font = Enum.Font.Gotham
cmdBox.TextSize = 14
cmdBox.Text = ""
cmdBox.Visible = false
cmdBox.ClearTextOnFocus = false
cmdBox.Parent = panel
Instance.new("UICorner", cmdBox).CornerRadius = UDim.new(0, 4)

local enterBtn = Instance.new("TextButton")
enterBtn.Name = "EnterBtn"
enterBtn.Size = UDim2.new(1, -10, 0, 28)
enterBtn.Position = UDim2.new(0, 5, 0, 60)
enterBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
enterBtn.TextColor3 = Color3.new(1, 1, 1)
enterBtn.Font = Enum.Font.GothamBold
enterBtn.TextSize = 14
enterBtn.Text = "Enter"
enterBtn.Visible = false
enterBtn.Parent = panel
Instance.new("UICorner", enterBtn).CornerRadius = UDim.new(0, 6)

-------------------------------------------------
-- WORKSPACE SEARCH RESULT UI
-------------------------------------------------

local searchResultPanel = Instance.new("Frame")
searchResultPanel.Name = "SearchResultPanel"
searchResultPanel.Size = UDim2.new(0, 400, 0, 300)
searchResultPanel.Position = UDim2.new(0.5, -200, 0.5, -150)
searchResultPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
searchResultPanel.BackgroundTransparency = 0.1
searchResultPanel.Active = true
searchResultPanel.Visible = false
searchResultPanel.Parent = gui
Instance.new("UICorner", searchResultPanel).CornerRadius = UDim.new(0, 8)

local srTitle = Instance.new("TextLabel")
srTitle.Size = UDim2.new(1, -60, 0, 25)
srTitle.Position = UDim2.new(0, 10, 0, 5)
srTitle.BackgroundTransparency = 1
srTitle.Text = "Search Result"
srTitle.TextColor3 = Color3.new(1, 1, 1)
srTitle.Font = Enum.Font.GothamBold
srTitle.TextXAlignment = Enum.TextXAlignment.Left
srTitle.TextSize = 14
srTitle.Parent = searchResultPanel

local srMinBtn = Instance.new("TextButton")
srMinBtn.Size = UDim2.new(0, 20, 0, 20)
srMinBtn.Position = UDim2.new(1, -50, 0, 5)
srMinBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
srMinBtn.TextColor3 = Color3.new(1, 1, 1)
srMinBtn.Font = Enum.Font.GothamBold
srMinBtn.TextSize = 14
srMinBtn.Text = "-"
srMinBtn.Parent = searchResultPanel
Instance.new("UICorner", srMinBtn).CornerRadius = UDim.new(0, 4)

local srCloseBtn = Instance.new("TextButton")
srCloseBtn.Size = UDim2.new(0, 20, 0, 20)
srCloseBtn.Position = UDim2.new(1, -25, 0, 5)
srCloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
srCloseBtn.TextColor3 = Color3.new(1, 1, 1)
srCloseBtn.Font = Enum.Font.GothamBold
srCloseBtn.TextSize = 14
srCloseBtn.Text = "X"
srCloseBtn.Parent = searchResultPanel
Instance.new("UICorner", srCloseBtn).CornerRadius = UDim.new(0, 4)

local srContainer = Instance.new("Frame")
srContainer.Size = UDim2.new(1, -10, 1, -35)
srContainer.Position = UDim2.new(0, 5, 0, 30)
srContainer.BackgroundTransparency = 1
srContainer.Parent = searchResultPanel

local srHeader = Instance.new("Frame")
srHeader.Size = UDim2.new(1, 0, 0, 25)
srHeader.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
srHeader.Parent = srContainer
Instance.new("UICorner", srHeader).CornerRadius = UDim.new(0, 4)

local srColWidths = {40, 180, 80, 80}
local srHeaders = {"No", "Name", "Distance", "Action"}
local srXPos = 5
for i, h in ipairs(srHeaders) do
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(0, srColWidths[i], 1, 0)
	lbl.Position = UDim2.new(0, srXPos, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = h
	lbl.TextColor3 = Color3.new(1, 1, 1)
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 12
	lbl.Parent = srHeader
	srXPos = srXPos + srColWidths[i]
end

local srScroll = Instance.new("ScrollingFrame")
srScroll.Size = UDim2.new(1, 0, 1, -28)
srScroll.Position = UDim2.new(0, 0, 0, 28)
srScroll.BackgroundTransparency = 1
srScroll.ScrollBarThickness = 4
srScroll.Parent = srContainer

local srLayout = Instance.new("UIListLayout")
srLayout.SortOrder = Enum.SortOrder.LayoutOrder
srLayout.Parent = srScroll

local isSearchMinimized = false
srMinBtn.MouseButton1Click:Connect(function()
	isSearchMinimized = not isSearchMinimized
	if isSearchMinimized then
		searchResultPanel.Size = UDim2.new(0, 400, 0, 30)
		srMinBtn.Text = "+"
		srContainer.Visible = false
	else
		searchResultPanel.Size = UDim2.new(0, 400, 0, 300)
		srMinBtn.Text = "-"
		srContainer.Visible = true
	end
end)

srCloseBtn.MouseButton1Click:Connect(function()
	searchResultPanel.Visible = false
end)

-------------------------------------------------
-- PLAYER LIST GUI
-------------------------------------------------

local playerListPanel = Instance.new("Frame")
playerListPanel.Name = "PlayerListPanel"
playerListPanel.Size = UDim2.new(0, 480, 0, 300)
playerListPanel.Position = UDim2.new(0.3, 0, 0.3, 0)
playerListPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
playerListPanel.BackgroundTransparency = 0.1
playerListPanel.Active = true
playerListPanel.Visible = false
playerListPanel.Parent = gui
Instance.new("UICorner", playerListPanel).CornerRadius = UDim.new(0, 8)

local plTitle = Instance.new("TextLabel")
plTitle.Size = UDim2.new(1, -60, 0, 25)
plTitle.Position = UDim2.new(0, 10, 0, 5)
plTitle.BackgroundTransparency = 1
plTitle.Text = "Player (0 Player)"
plTitle.TextColor3 = Color3.new(1, 1, 1)
plTitle.Font = Enum.Font.GothamBold
plTitle.TextXAlignment = Enum.TextXAlignment.Left
plTitle.TextSize = 14
plTitle.Parent = playerListPanel

local plMinBtn = Instance.new("TextButton")
plMinBtn.Size = UDim2.new(0, 20, 0, 20)
plMinBtn.Position = UDim2.new(1, -50, 0, 5)
plMinBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
plMinBtn.TextColor3 = Color3.new(1, 1, 1)
plMinBtn.Font = Enum.Font.GothamBold
plMinBtn.TextSize = 14
plMinBtn.Text = "-"
plMinBtn.Parent = playerListPanel
Instance.new("UICorner", plMinBtn).CornerRadius = UDim.new(0, 4)

local plCloseBtn = Instance.new("TextButton")
plCloseBtn.Size = UDim2.new(0, 20, 0, 20)
plCloseBtn.Position = UDim2.new(1, -25, 0, 5)
plCloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
plCloseBtn.TextColor3 = Color3.new(1, 1, 1)
plCloseBtn.Font = Enum.Font.GothamBold
plCloseBtn.TextSize = 14
plCloseBtn.Text = "X"
plCloseBtn.Parent = playerListPanel
Instance.new("UICorner", plCloseBtn).CornerRadius = UDim.new(0, 4)

local searchBox = Instance.new("TextBox")
searchBox.Name = "SearchBox"
searchBox.Size = UDim2.new(1, -20, 0, 25)
searchBox.Position = UDim2.new(0, 10, 0, 32)
searchBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
searchBox.TextColor3 = Color3.new(1, 1, 1)
searchBox.PlaceholderText = "Search Name / NickName..."
searchBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
searchBox.Font = Enum.Font.Gotham
searchBox.TextSize = 14
searchBox.Text = ""
searchBox.ClearTextOnFocus = false
searchBox.Parent = playerListPanel
Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0, 4)

local listContainer = Instance.new("Frame")
listContainer.Size = UDim2.new(1, -10, 1, -70)
listContainer.Position = UDim2.new(0, 5, 0, 62)
listContainer.BackgroundTransparency = 1
listContainer.Parent = playerListPanel

local headerFrame = Instance.new("Frame")
headerFrame.Size = UDim2.new(1, 0, 0, 25)
headerFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
headerFrame.Parent = listContainer
Instance.new("UICorner", headerFrame).CornerRadius = UDim.new(0, 4)

local colWidths = {35, 115, 115, 60, 65, 65}
local headers = {"No", "Name", "NickName", "Dist", "TP", "Cam"}

local xPos = 5
for i, h in ipairs(headers) do
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(0, colWidths[i], 1, 0)
	lbl.Position = UDim2.new(0, xPos, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = h
	lbl.TextColor3 = Color3.new(1, 1, 1)
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 12
	lbl.Parent = headerFrame
	xPos = xPos + colWidths[i]
end

local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Size = UDim2.new(1, 0, 1, -28)
scrollingFrame.Position = UDim2.new(0, 0, 0, 28)
scrollingFrame.BackgroundTransparency = 1
scrollingFrame.ScrollBarThickness = 4
scrollingFrame.Parent = listContainer

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = scrollingFrame

-------------------------------------------------
-- SELECTION MENU
-------------------------------------------------

local menu = Instance.new("Frame")
menu.Size = UDim2.new(0, 150, 0, 140)
menu.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
menu.Visible = false
menu.Parent = gui
Instance.new("UICorner", menu).CornerRadius = UDim.new(0, 8)

local function createMenuButton(text, y, color)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0, 130, 0, 25)
	b.Position = UDim2.new(0, 10, 0, y)
	b.Text = text
	b.BackgroundColor3 = color
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Font = Enum.Font.Gotham
	b.TextSize = 13
	b.Parent = menu
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
	return b
end

local bringBtn = createMenuButton("Bring", 10, Color3.fromRGB(0, 120, 215))
local teleportBtn = createMenuButton("Teleport", 40, Color3.fromRGB(0, 170, 0))
local markBtn = createMenuButton("Mark", 70, Color3.fromRGB(100, 0, 150))
local deleteBtn = createMenuButton("Delete", 100, Color3.fromRGB(255, 0, 0))

-------------------------------------------------
-- TOGGLE PIN & EVIL MODE
-------------------------------------------------

pinBtn.MouseButton1Click:Connect(function()
	isPinned = not isPinned
	if isPinned then
		pinBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
	else
		pinBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	end
end)

evilBtn.MouseButton1Click:Connect(function()
	isEvilMode = not isEvilMode
	if isEvilMode then
		evilBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
		for _, btn in pairs(featureButtons) do btn.Visible = false end
		cmdBox.Visible = true
		enterBtn.Visible = true
	else
		evilBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
		for _, btn in pairs(featureButtons) do btn.Visible = true end
		cmdBox.Visible = false
		enterBtn.Visible = false
	end
end)

-------------------------------------------------
-- FITUR MINIMIZE
-------------------------------------------------

minBtn.MouseButton1Click:Connect(function()
	isMinimized = not isMinimized
	if isMinimized then
		panel.Size = UDim2.new(0, 245, 0, 30)
		minBtn.Text = "+"
		for _, btn in pairs(featureButtons) do btn.Visible = false end
		cmdBox.Visible = false
		enterBtn.Visible = false
	else
		panel.Size = originalSize
		minBtn.Text = "-"
		if isEvilMode then
			cmdBox.Visible = true
			enterBtn.Visible = true
		else
			for _, btn in pairs(featureButtons) do btn.Visible = true end
		end
	end
end)

-------------------------------------------------
-- COMMAND LOGIC
-------------------------------------------------

local function getObjectPosition(obj)
	if obj:IsA("BasePart") then
		return obj.Position
	elseif obj:IsA("Model") then
		if obj.PrimaryPart then return obj.PrimaryPart.Position end
		local hrp = obj:FindFirstChild("HumanoidRootPart")
		if hrp then return hrp.Position end
		local root = obj:FindFirstChild("RootPart")
		if root then return root.Position end
	end
	return nil
end

local function clearSearchRows()
	for _, child in pairs(srScroll:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end
	currentSearchResults = {}
end

local function handleAutoMarking()
	if autoMarkingActive then
		local char = player.Character
		if char then
			local hrp = char:FindFirstChild("HumanoidRootPart")
			if hrp then
				markedCFrame = hrp.CFrame
			end
		end
	end
end

local function performSearch(searchName)
	if #searchName < 1 then return end

	clearSearchRows()
	currentSearchTerm = searchName

	local foundObjects = {}
	local myChar = player.Character
	local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")

	for _, obj in pairs(Workspace:GetDescendants()) do
		if string.find(string.lower(obj.Name), string.lower(searchName)) then
			if obj:IsA("BasePart") or obj:IsA("Model") then
				local dist = 0
				if myHrp then
					local pos = getObjectPosition(obj)
					if pos then dist = (pos - myHrp.Position).Magnitude end
				end
				table.insert(foundObjects, {Object = obj, Distance = dist})
			end
		end
	end

	table.sort(foundObjects, function(a, b) return a.Distance < b.Distance end)

	searchResultPanel.Visible = true
	srTitle.Text = "Search: " .. searchName .. " (" .. #foundObjects .. " found)"

	for i, data in pairs(foundObjects) do
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0, 25)
		row.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
		row.BackgroundTransparency = 0.5
		row.LayoutOrder = math.floor(data.Distance)
		row.Parent = srScroll
		Instance.new("UICorner", row).CornerRadius = UDim.new(0, 4)

		local xPos = 5

		local noL = Instance.new("TextLabel")
		noL.Size = UDim2.new(0, srColWidths[1], 1, 0)
		noL.Position = UDim2.new(0, xPos, 0, 0)
		noL.BackgroundTransparency = 1
		noL.Text = tostring(i)
		noL.TextColor3 = Color3.new(1, 1, 1)
		noL.Font = Enum.Font.Gotham
		noL.TextSize = 12
		noL.Parent = row
		xPos = xPos + srColWidths[1]

		local nameL = Instance.new("TextLabel")
		nameL.Size = UDim2.new(0, srColWidths[2], 1, 0)
		nameL.Position = UDim2.new(0, xPos, 0, 0)
		nameL.BackgroundTransparency = 1
		nameL.Text = data.Object.Name
		nameL.TextColor3 = Color3.new(1, 1, 1)
		nameL.Font = Enum.Font.Gotham
		nameL.TextSize = 12
		nameL.TextXAlignment = Enum.TextXAlignment.Left
		nameL.Parent = row
		xPos = xPos + srColWidths[2]

		local distL = Instance.new("TextLabel")
		distL.Size = UDim2.new(0, srColWidths[3], 1, 0)
		distL.Position = UDim2.new(0, xPos, 0, 0)
		distL.BackgroundTransparency = 1
		distL.Text = string.format("%.0f", data.Distance)
		distL.TextColor3 = Color3.new(1, 1, 1)
		distL.Font = Enum.Font.Gotham
		distL.TextSize = 12
		distL.Parent = row
		xPos = xPos + srColWidths[3]

		local tpB = Instance.new("TextButton")
		tpB.Size = UDim2.new(0, srColWidths[4] - 10, 1, -4)
		tpB.Position = UDim2.new(0, xPos + 5, 0, 2)
		tpB.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
		tpB.Text = "Teleport"
		tpB.TextColor3 = Color3.new(1, 1, 1)
		tpB.Font = Enum.Font.GothamBold
		tpB.TextSize = 11
		tpB.Parent = row
		Instance.new("UICorner", tpB).CornerRadius = UDim.new(0, 4)

		tpB.MouseButton1Click:Connect(function()
			local char = player.Character
			if char and data.Object then
				local hrp = char:FindFirstChild("HumanoidRootPart")
				local pos = getObjectPosition(data.Object)
				if hrp and pos then
					handleAutoMarking()
					hrp.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
					task.wait(0.5)
					performSearch(currentSearchTerm)
				end
			end
		end)

		table.insert(currentSearchResults, {Object = data.Object, Row = row, DistLabel = distL})
	end

	srLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		srScroll.CanvasSize = UDim2.new(0, 0, 0, srLayout.AbsoluteContentSize.Y)
	end)
	srScroll.CanvasSize = UDim2.new(0, 0, 0, srLayout.AbsoluteContentSize.Y)

	if not searchLoopConnection then
		searchLoopConnection = RunService.RenderStepped:Connect(function()
			if not searchResultPanel.Visible then return end
			local myChar = player.Character
			local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")

			for i, data in pairs(currentSearchResults) do
				if data.Object and data.Object.Parent and data.DistLabel and data.Row then
					local pos = getObjectPosition(data.Object)
					if pos and myHrp then
						local dist = (pos - myHrp.Position).Magnitude
						data.DistLabel.Text = string.format("%.0f", dist)
						data.Row.LayoutOrder = math.floor(dist)
					else
						data.DistLabel.Text = "N/A"
						data.Row.LayoutOrder = 99999
					end
				else
					if data.Row then data.Row.Visible = false end
				end
			end
		end)
	end
end

enterBtn.MouseButton1Click:Connect(function()
	local text = cmdBox.Text
	if string.sub(text, 1, 2) == "w:" then
		local searchName = string.sub(text, 3)
		performSearch(searchName)
	elseif string.lower(text) == "t:npc" then
		createTamengTool()
		cmdBox.Text = ""
	elseif string.lower(text) == "automarkingon" then
		autoMarkingActive = true
		showRainbowNotification("auto marking on")
		cmdBox.Text = ""
	elseif string.lower(text) == "automarkingoff" then
		autoMarkingActive = false
		showRainbowNotification("auto marking off")
		cmdBox.Text = ""
	end
end)

cmdBox.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		local text = cmdBox.Text
		if string.sub(text, 1, 2) == "w:" then
			local searchName = string.sub(text, 3)
			performSearch(searchName)
		elseif string.lower(text) == "t:tameng" then
			createTamengTool()
		elseif string.lower(text) == "automarkingon" then
			autoMarkingActive = true
			showRainbowNotification("auto marking on")
			cmdBox.Text = ""
		elseif string.lower(text) == "automarkingoff" then
			autoMarkingActive = false
			showRainbowNotification("auto marking off")
			cmdBox.Text = ""
		end
	end
end)

-------------------------------------------------
-- DRAG UI
-------------------------------------------------

makeDraggable(panel)
makeDraggable(playerListPanel)
makeDraggable(searchResultPanel)

-------------------------------------------------
-- BUTTON TOGGLE
-------------------------------------------------

local function toggle(btn)
	local on = not btn:GetAttribute("Active")
	btn:SetAttribute("Active", on)
	btn.BackgroundColor3 = on and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(70, 70, 70)
	return on
end

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
		b.TextColor3 = Color3.new(1, 1, 1)
		b.TextSize = 24
		b.Font = Enum.Font.GothamBold
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

	return {Frame = frame, Fwd = fwd, Bck = bck, Lft = lft, Rgt = rgt, Up = upB, Dn = dnB}
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
		if hrp then ghostSphere.CFrame = hrp.CFrame * CFrame.new(0, 2, -5) end
		ghostSphere.Parent = Workspace

		Workspace.CurrentCamera.CameraSubject = ghostSphere

		for _, part in pairs(char:GetDescendants()) do
			if part:IsA("BasePart") then part.Anchored = true end
		end
		if hum then hum.PlatformStand = true end

		local keysPressed = {}
		local moveDir = {forward = 0, strafe = 0, vertical = 0}
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
				local btnCon1 = btn.InputBegan:Connect(function() moveDir[axis] = value end)
				local btnCon2 = btn.InputEnded:Connect(function() moveDir[axis] = 0 end)
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
			local finalMove = Vector3.new(0, 0, 0)
			local camCF = cam.CFrame
			local camLook = camCF.LookVector
			local camRight = camCF.RightVector

			if keysPressed[Enum.KeyCode.W] then finalMove = finalMove + camLook end
			if keysPressed[Enum.KeyCode.S] then finalMove = finalMove - camLook end
			if keysPressed[Enum.KeyCode.D] then finalMove = finalMove + camRight end
			if keysPressed[Enum.KeyCode.A] then finalMove = finalMove - camRight end
			if keysPressed[Enum.KeyCode.Space] then finalMove = finalMove + Vector3.new(0, 1, 0) end
			if keysPressed[Enum.KeyCode.Q] then finalMove = finalMove - Vector3.new(0, 1, 0) end

			finalMove = finalMove + (camLook * moveDir.forward)
			finalMove = finalMove + (camRight * moveDir.strafe)
			finalMove = finalMove + (Vector3.new(0, 1, 0) * moveDir.vertical)

			if finalMove.Magnitude > 0 then
				ghostSphere.CFrame = ghostSphere.CFrame + (finalMove * SPEED)
			end
		end)
		table.insert(ghostConnections, renderCon)

	else
		if ghostSphere then ghostSphere:Destroy(); ghostSphere = nil end
		if mobileControls then mobileControls.Frame:Destroy(); mobileControls = nil end
		for _, conn in pairs(ghostConnections) do if conn then conn:Disconnect() end end
		ghostConnections = {}

		if char then
			for _, part in pairs(char:GetDescendants()) do
				if part:IsA("BasePart") then part.Anchored = false end
			end
		end
		if hum then hum.PlatformStand = false; Workspace.CurrentCamera.CameraSubject = hum end
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
						if char and Players:GetPlayerFromCharacter(char) then isPlayer = true end
					end
					if isPlayer then
						local hue = tick() % 5 / 5
						local txt = label:FindFirstChild("TextLabel")
						if txt then txt.TextColor3 = Color3.fromHSV(hue, 1, 1) end
					end
				end
			end
		end)

		for _, obj in pairs(Workspace:GetDescendants()) do
			if obj:IsA("BasePart") then
				originalTransparency[obj] = obj.Transparency
				originalColors[obj] = obj.Color
				obj.Transparency = 0

				if obj:GetAttribute("Marked") then
					obj.Color = Color3.fromRGB(0, 255, 255)
				else
					if obj.CanCollide then obj.Color = Color3.fromRGB(0, 255, 0) end
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
							textLabel.Font = Enum.Font.GothamBold
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
						textLabel.Font = Enum.Font.Gotham
						textLabel.TextSize = 14
						textLabel.Parent = label
						objectLabels[obj] = label
					end
				end
			end
		end
	else
		if rainbowConnection then rainbowConnection:Disconnect(); rainbowConnection = nil end
		for obj, val in pairs(originalTransparency) do if obj and obj.Parent then obj.Transparency = val end end
		for obj, val in pairs(originalColors) do if obj and obj.Parent then obj.Color = val end end
		for _, label in pairs(objectLabels) do if label and label.Parent then label:Destroy() end end
		objectLabels = {}
		menu.Visible = false
	end
end

-------------------------------------------------
-- OBJECT SELECT
-------------------------------------------------

local function selectObject(obj)
	if not visionBtn:GetAttribute("Active") then return end
	if not obj or not obj:IsA("BasePart") then return end

	local time = tick()

	if obj == lastObject and time - lastClick < 0.5 then
		if selectedObject and selectedObject.Parent then
			selectedObject.Color = Color3.fromRGB(0, 255, 0)
		end
		selectedObject = obj
		selectedOriginalColor = obj.Color
		obj.Color = Color3.fromRGB(255, 0, 0)

		menu.Visible = true
		menu.Position = UDim2.new(0, panel.AbsolutePosition.X + panel.AbsoluteSize.X + 10, 0, panel.AbsolutePosition.Y)
		bringBtn.Text = broughtObjects[selectedObject] and "Unbring" or "Bring"
		markBtn.Text = "Mark"
	else
		lastObject = obj
		lastClick = time
	end
end

-------------------------------------------------
-- INPUTS
-------------------------------------------------

UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		local mouse = player:GetMouse()
		if mouse.Target then selectObject(mouse.Target) end
	end
end)

UserInputService.TouchTapInWorld:Connect(function(pos, processed)
	if processed then return end
	local cam = Workspace.CurrentCamera
	local ray = cam:ViewportPointToRay(pos.X, pos.Y)
	local result = Workspace:Raycast(ray.Origin, ray.Direction * 500)
	if result then selectObject(result.Instance) end
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
		selectedObject.CFrame = hrp.CFrame + hrp.CFrame.LookVector * 5
		bringBtn.Text = "Unbring"
	end
end)

teleportBtn.MouseButton1Click:Connect(function()
	if not selectedObject then return end
	local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if hrp then
		handleAutoMarking()
		local originalLookVector = hrp.CFrame.LookVector
		local targetPosition = selectedObject.CFrame.Position + Vector3.new(0, 5, 0)
		hrp.CFrame = CFrame.new(targetPosition, targetPosition + originalLookVector)
	end
end)

markBtn.MouseButton1Click:Connect(function()
	if not selectedObject then return end
	markedCFrame = selectedObject.CFrame
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
-- MARKING & TELEPORT MAIN BUTTONS
-------------------------------------------------

markingBtn.MouseButton1Click:Connect(function()
	local char = player.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	markedCFrame = hrp.CFrame
	markingBtn.Text = "Marked!"
	markingBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
	task.wait(0.3)
	markingBtn.Text = "Marking"
	markingBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 150)
end)

tpMarkBtn.MouseButton1Click:Connect(function()
	local char = player.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	if isUndoMode then
		if tempMarkCFrame then
			local currentLook = hrp.CFrame.LookVector
			hrp.CFrame = CFrame.new(tempMarkCFrame.Position, tempMarkCFrame.Position + currentLook)
		end
		isUndoMode = false
		tempMarkCFrame = nil
		if undoThread then task.cancel(undoThread) end
		tpMarkBtn.Text = "Teleport"
		tpMarkBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 150)
		return
	end

	if not markedCFrame then
		if autoMarkingActive then
			markedCFrame = hrp.CFrame
			tpMarkBtn.Text = "Mark Set"
			task.wait(0.5)
			tpMarkBtn.Text = "Teleport"
		else
			tpMarkBtn.Text = "No Mark!"
			task.wait(0.5)
			tpMarkBtn.Text = "Teleport"
		end
		return
	end

	if autoMarkingActive then
		local targetCFrame = markedCFrame
		markedCFrame = hrp.CFrame
		hrp.CFrame = CFrame.new(targetCFrame.Position, targetCFrame.Position + hrp.CFrame.LookVector)

		tpMarkBtn.Text = "Jump!"
		task.wait(0.5)
		tpMarkBtn.Text = "Teleport"
	else
		tempMarkCFrame = hrp.CFrame
		hrp.CFrame = CFrame.new(markedCFrame.Position, markedCFrame.Position + hrp.CFrame.LookVector)

		isUndoMode = true
		tpMarkBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
		undoThread = task.spawn(function()
			for i = 10, 0, -1 do
				if not isUndoMode then break end
				tpMarkBtn.Text = "Undo (" .. tostring(i) .. ")"
				task.wait(1)
			end
			if isUndoMode then
				isUndoMode = false
				tempMarkCFrame = nil
				tpMarkBtn.Text = "Teleport"
				tpMarkBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 150)
			end
		end)
	end
end)

-------------------------------------------------
-- PLAYER LIST SYSTEM
-------------------------------------------------

local isPlayerListMinimized = false

playerListBtn.MouseButton1Click:Connect(function()
	playerListPanel.Visible = not playerListPanel.Visible
end)

plMinBtn.MouseButton1Click:Connect(function()
	isPlayerListMinimized = not isPlayerListMinimized
	if isPlayerListMinimized then
		playerListPanel.Size = UDim2.new(0, 480, 0, 30)
		plMinBtn.Text = "+"
		listContainer.Visible = false
		searchBox.Visible = false
	else
		playerListPanel.Size = UDim2.new(0, 480, 0, 300)
		plMinBtn.Text = "-"
		listContainer.Visible = true
		searchBox.Visible = true
	end
end)

plCloseBtn.MouseButton1Click:Connect(function()
	playerListPanel.Visible = false
end)

local function stopSpectate()
	if spectatingConnection then spectatingConnection:Disconnect(); spectatingConnection = nil end
	spectatingPlayer = nil
	if player.Character and player.Character:FindFirstChild("Humanoid") then
		Workspace.CurrentCamera.CameraSubject = player.Character.Humanoid
	end
end

local function createPlayerRow(plr, index)
	if plr == player then return end

	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 25)
	row.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	row.BackgroundTransparency = 0.5
	row.Parent = scrollingFrame
	Instance.new("UICorner", row).CornerRadius = UDim.new(0, 4)

	local xPos = 5

	local noL = Instance.new("TextLabel")
	noL.Size = UDim2.new(0, colWidths[1], 1, 0)
	noL.Position = UDim2.new(0, xPos, 0, 0)
	noL.BackgroundTransparency = 1
	noL.Text = tostring(index)
	noL.TextColor3 = Color3.new(1, 1, 1)
	noL.Font = Enum.Font.Gotham
	noL.TextSize = 12
	noL.Parent = row
	xPos = xPos + colWidths[1]

	local nameL = Instance.new("TextLabel")
	nameL.Size = UDim2.new(0, colWidths[2], 1, 0)
	nameL.Position = UDim2.new(0, xPos, 0, 0)
	nameL.BackgroundTransparency = 1
	nameL.Text = plr.Name
	nameL.TextColor3 = Color3.new(1, 1, 1)
	nameL.Font = Enum.Font.Gotham
	nameL.TextSize = 12
	nameL.TextXAlignment = Enum.TextXAlignment.Left
	nameL.Parent = row
	xPos = xPos + colWidths[2]

	local nickL = Instance.new("TextLabel")
	nickL.Size = UDim2.new(0, colWidths[3], 1, 0)
	nickL.Position = UDim2.new(0, xPos, 0, 0)
	nickL.BackgroundTransparency = 1
	nickL.Text = plr.DisplayName
	nickL.TextColor3 = Color3.new(1, 1, 1)
	nickL.Font = Enum.Font.Gotham
	nickL.TextSize = 12
	nickL.TextXAlignment = Enum.TextXAlignment.Left
	nickL.Parent = row
	xPos = xPos + colWidths[3]

	local distL = Instance.new("TextLabel")
	distL.Size = UDim2.new(0, colWidths[4], 1, 0)
	distL.Position = UDim2.new(0, xPos, 0, 0)
	distL.BackgroundTransparency = 1
	distL.Text = "0"
	distL.TextColor3 = Color3.new(1, 1, 1)
	distL.Font = Enum.Font.Gotham
	distL.TextSize = 12
	distL.Parent = row
	xPos = xPos + colWidths[4]

	local tpB = Instance.new("TextButton")
	tpB.Size = UDim2.new(0, colWidths[5] - 10, 1, -4)
	tpB.Position = UDim2.new(0, xPos + 5, 0, 2)
	tpB.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
	tpB.Text = "TP"
	tpB.TextColor3 = Color3.new(1, 1, 1)
	tpB.Font = Enum.Font.GothamBold
	tpB.TextSize = 11
	tpB.Parent = row
	Instance.new("UICorner", tpB).CornerRadius = UDim.new(0, 4)

	tpB.MouseButton1Click:Connect(function()
		local char = plr.Character
		local myChar = player.Character
		if char and myChar then
			local thrp = char:FindFirstChild("HumanoidRootPart")
			local myhrp = myChar:FindFirstChild("HumanoidRootPart")
			if thrp and myhrp then
				handleAutoMarking()
				local behindPos = thrp.CFrame.Position - (thrp.CFrame.LookVector * 10)
				myhrp.CFrame = CFrame.new(behindPos)
			end
		end
	end)
	xPos = xPos + colWidths[5]

	local camB = Instance.new("TextButton")
	camB.Size = UDim2.new(0, colWidths[6] - 10, 1, -4)
	camB.Position = UDim2.new(0, xPos + 5, 0, 2)
	camB.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	camB.Text = "Cam"
	camB.TextColor3 = Color3.new(1, 1, 1)
	camB.Font = Enum.Font.GothamBold
	camB.TextSize = 11
	camB.Parent = row
	Instance.new("UICorner", camB).CornerRadius = UDim.new(0, 4)

	camB.MouseButton1Click:Connect(function()
		if spectatingPlayer == plr then
			stopSpectate()
			camB.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
			camB.Text = "Cam"
		else
			stopSpectate()
			spectatingPlayer = plr
			if plr.Character and plr.Character:FindFirstChild("Humanoid") then
				Workspace.CurrentCamera.CameraSubject = plr.Character.Humanoid
			end
			for p, rowObj in pairs(playerRows) do
				if rowObj and rowObj.CamBtn then
					if p == spectatingPlayer then
						rowObj.CamBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
						rowObj.CamBtn.Text = "Stop"
					else
						rowObj.CamBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
						rowObj.CamBtn.Text = "Cam"
					end
				end
			end
		end
	end)

	playerRows[plr] = {Row = row, DistLabel = distL, CamBtn = camB, NameLabel = nameL, NickLabel = nickL}
end

RunService.RenderStepped:Connect(function()
	local myChar = player.Character
	if not myChar then return end
	local myHrp = myChar:FindFirstChild("HumanoidRootPart")
	if not myHrp then return end

	for plr, data in pairs(playerRows) do
		if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
			local dist = (plr.Character.HumanoidRootPart.Position - myHrp.Position).Magnitude
			data.DistLabel.Text = string.format("%.0f", dist)
			data.Row.LayoutOrder = math.floor(dist)
		else
			data.DistLabel.Text = "N/A"
			data.Row.LayoutOrder = 99999
		end
	end
end)

searchBox:GetPropertyChangedSignal("Text"):Connect(function()
	local text = string.lower(searchBox.Text)
	for plr, data in pairs(playerRows) do
		local name = string.lower(plr.Name)
		local nick = string.lower(plr.DisplayName)
		if text == "" or string.find(name, text) or string.find(nick, text) then
			data.Row.Visible = true
		else
			data.Row.Visible = false
		end
	end
	scrollingFrame.CanvasPosition = Vector2.new(0, 0)
end)

local function initPlayerList()
	for _, data in pairs(playerRows) do if data.Row then data.Row:Destroy() end end
	playerRows = {}
	local i = 1
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= player then createPlayerRow(plr, i); i = i + 1 end
	end
	plTitle.Text = "Player ("..(i-1).." Player)"
	scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
end

listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
end)

Players.PlayerAdded:Connect(function(plr) task.wait(1); initPlayerList() end)
Players.PlayerRemoving:Connect(function(plr)
	if playerRows[plr] then if playerRows[plr].Row then playerRows[plr].Row:Destroy() end; playerRows[plr] = nil end
	if spectatingPlayer == plr then stopSpectate() end
	initPlayerList()
end)

initPlayerList()

-------------------------------------------------
-- EVENTS
-------------------------------------------------

visionBtn.MouseButton1Click:Connect(toggleVision)

jumpBtn.MouseButton1Click:Connect(function()
	local on = toggle(jumpBtn)
	if on and player.Character then setupJump(player.Character) end
end)

player.CharacterAdded:Connect(function(c)
	task.wait(0.5)
	setupJump(c)
	if ghostBtn:GetAttribute("Active") then toggleGhost() end
end)
