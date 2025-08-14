--// Roblox Delta Executor - Scanner v5
--// Players + Objects by Name (BasePart only)
--// Teleport & Spectate toggle fixed, Refresh, Draggable, Minimize header, Mobile-friendly

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local UIS = game:GetService("UserInputService")
local camera = Workspace.CurrentCamera

-- UI Settings
local PANEL_WIDTH, PANEL_HEIGHT = 320, 420
local HEADER_HEIGHT = 32
local MINIMIZED_HEIGHT = HEADER_HEIGHT

-- Destroy previous
pcall(function()
	if game.CoreGui:FindFirstChild("ScanPanelV5") then
		game.CoreGui.ScanPanelV5:Destroy()
	end
end)

-- Root GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ScanPanelV5"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, PANEL_WIDTH, 0, PANEL_HEIGHT)
MainFrame.Position = UDim2.new(0.05, 0, 0.1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

-- Dragging (PC & Mobile)
do
	local dragging, dragInput, dragStart, startPos
	MainFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
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
	MainFrame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
	UIS.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

-- Header
local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, HEADER_HEIGHT)
Header.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Header.BorderSizePixel = 0

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -150, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Text = "Scanner v5"
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.TextColor3 = Color3.fromRGB(255, 255, 255)

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 40, 1, 0)
CloseBtn.Position = UDim2.new(1, -40, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 18
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.MouseButton1Click:Connect(function()
	ScreenGui:Destroy()
end)

local MinBtn = Instance.new("TextButton", Header)
MinBtn.Size = UDim2.new(0, 40, 1, 0)
MinBtn.Position = UDim2.new(1, -80, 0, 0)
MinBtn.BackgroundTransparency = 1
MinBtn.Text = "-"
MinBtn.Font = Enum.Font.SourceSansBold
MinBtn.TextSize = 18
MinBtn.TextColor3 = Color3.fromRGB(255, 220, 90)

local RefreshBtn = Instance.new("TextButton", Header)
RefreshBtn.Size = UDim2.new(0, 70, 1, 0)
RefreshBtn.Position = UDim2.new(1, -150, 0, 0)
RefreshBtn.BackgroundColor3 = Color3.fromRGB(0, 130, 0)
RefreshBtn.Text = "Refresh"
RefreshBtn.Font = Enum.Font.SourceSans
RefreshBtn.TextSize = 16
RefreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", RefreshBtn).CornerRadius = UDim.new(0, 6)

-- Content
local Scrolling = Instance.new("ScrollingFrame", MainFrame)
Scrolling.Size = UDim2.new(1, 0, 1, -HEADER_HEIGHT)
Scrolling.Position = UDim2.new(0, 0, 0, HEADER_HEIGHT)
Scrolling.BackgroundTransparency = 1
Scrolling.ScrollBarThickness = 6
Scrolling.CanvasSize = UDim2.new(0, 0, 0, 0)
Scrolling.AutomaticCanvasSize = Enum.AutomaticSize.Y

local RootList = Instance.new("UIListLayout", Scrolling)
RootList.Padding = UDim.new(0, 6)
RootList.SortOrder = Enum.SortOrder.LayoutOrder

-- Minimize behavior: header only height
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	if minimized then
		Scrolling.Visible = false
		MainFrame.Size = UDim2.new(0, PANEL_WIDTH, 0, MINIMIZED_HEIGHT)
	else
		MainFrame.Size = UDim2.new(0, PANEL_WIDTH, 0, PANEL_HEIGHT)
		Scrolling.Visible = true
	end
end)

-- Utils: player character & HRP
local function getHRP(plr)
	plr = plr or LocalPlayer
	local char = plr.Character
	if not char then return nil end
	return char:FindFirstChild("HumanoidRootPart")
end

-- Teleport
local function tpToPart(part)
	local hrp = getHRP(LocalPlayer)
	if hrp and part and part:IsA("BasePart") then
		hrp.CFrame = part.CFrame + Vector3.new(0, 3, 0)
	end
end

local function tpBehindPlayer(targetPlayer)
	local hrp = getHRP(LocalPlayer)
	local thrp = getHRP(targetPlayer)
	if hrp and thrp then
		-- 12 studs behind target
		local behind = thrp.CFrame * CFrame.new(0, 0, 12)
		hrp.CFrame = behind
	end
end

-- Spectate (toggle)
local spectatingTarget = nil
local function stopSpectate()
	camera.CameraType = Enum.CameraType.Custom
	local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	if hum then camera.CameraSubject = hum end
	spectatingTarget = nil
end

local function toggleSpectate(target)
	if spectatingTarget == target then
		stopSpectate()
		return
	end
	-- switch
	if typeof(target) == "Instance" and target:IsA("Player") then
		local hum = target.Character and target.Character:FindFirstChildOfClass("Humanoid")
		if hum then
			camera.CameraType = Enum.CameraType.Custom
			camera.CameraSubject = hum
			spectatingTarget = target
		end
	elseif typeof(target) == "Instance" and target:IsA("BasePart") then
		camera.CameraType = Enum.CameraType.Attach
		camera.CameraSubject = target
		spectatingTarget = target
	end
end

-- Build category container
local function addCategory(parent, labelText)
	local container = Instance.new("Frame")
	container.BackgroundTransparency = 1
	container.Size = UDim2.new(1, -10, 0, 30)
	container.AutomaticSize = Enum.AutomaticSize.Y
	container.Parent = parent

	local innerList = Instance.new("UIListLayout", container)
	innerList.SortOrder = Enum.SortOrder.LayoutOrder
	innerList.Padding = UDim.new(0, 4)

	local catBtn = Instance.new("TextButton")
	catBtn.Size = UDim2.new(1, 0, 0, 30)
	catBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
	catBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	catBtn.Font = Enum.Font.SourceSans
	catBtn.TextSize = 16
	catBtn.Text = labelText
	catBtn.Parent = container
	Instance.new("UICorner", catBtn).CornerRadius = UDim.new(0, 6)

	local itemsHolder = Instance.new("Frame")
	itemsHolder.BackgroundTransparency = 1
	itemsHolder.Size = UDim2.new(1, 0, 0, 0)
	itemsHolder.Visible = false
	itemsHolder.AutomaticSize = Enum.AutomaticSize.Y
	itemsHolder.Parent = container

	return catBtn, itemsHolder
end

-- Item row with TP & Spectate buttons
local function addItemRow(parent, leftText, onTP, onSpec)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 26)
	row.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	row.Parent = parent
	Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)

	local label = Instance.new("TextLabel", row)
	label.Size = UDim2.new(0.45, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Position = UDim2.new(0, 8, 0, 0)
	label.Text = leftText
	label.Font = Enum.Font.SourceSans
	label.TextSize = 14
	label.TextColor3 = Color3.fromRGB(255, 255, 255)

	local tpBtn = Instance.new("TextButton", row)
	tpBtn.Size = UDim2.new(0.26, -4, 1, -6)
	tpBtn.Position = UDim2.new(0.48, 0, 0, 3)
	tpBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
	tpBtn.Text = "Teleport"
	tpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	tpBtn.Font = Enum.Font.SourceSans
	tpBtn.TextSize = 14
	Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0, 6)
	tpBtn.MouseButton1Click:Connect(function()
		onTP()
	end)

	local spBtn = Instance.new("TextButton", row)
	spBtn.Size = UDim2.new(0.26, -4, 1, -6)
	spBtn.Position = UDim2.new(0.74, 4, 0, 3)
	spBtn.BackgroundColor3 = Color3.fromRGB(0, 60, 140)
	spBtn.Text = "Spectate"
	spBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	spBtn.Font = Enum.Font.SourceSans
	spBtn.TextSize = 14
	Instance.new("UICorner", spBtn).CornerRadius = UDim.new(0, 6)
	spBtn.MouseButton1Click:Connect(function()
		onSpec()
	end)
end

-- Scanning
local function scanPlayers()
	local out = {}
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			table.insert(out, plr)
		end
	end
	return out
end

local function scanBasePartsByName()
	-- returns: map[name] = {list of BasePart}, and totals for sorting
	local byName = {}
	for _, inst in ipairs(Workspace:GetDescendants()) do
		if inst:IsA("BasePart") then
			local name = inst.Name
			if not byName[name] then byName[name] = {} end
			table.insert(byName[name], inst)
		end
	end
	return byName
end

-- Build full UI list
local function buildList()
	-- clear content
	for _, ch in ipairs(Scrolling:GetChildren()) do
		if not ch:IsA("UIListLayout") then ch:Destroy() end
	end

	-- Players
	local players = scanPlayers()
	local playersCatBtn, playersHolder = addCategory(Scrolling, ("Players : %d"):format(#players))
	local playersExpanded = false
	playersCatBtn.MouseButton1Click:Connect(function()
		playersExpanded = not playersExpanded
		playersHolder.Visible = playersExpanded
	end)
	for _, plr in ipairs(players) do
		addItemRow(
			playersHolder,
			plr.Name .. " | " .. plr.DisplayName,
			function() tpBehindPlayer(plr) end,
			function() toggleSpectate(plr) end
		)
	end

	-- Objects by Name (BasePart only, sorted by most instances)
	local byName = scanBasePartsByName()
	local nameBuckets = {}
	for n, list in pairs(byName) do
		table.insert(nameBuckets, {Name = n, Items = list, Count = #list})
	end
	table.sort(nameBuckets, function(a, b)
		if a.Count == b.Count then
			return a.Name:lower() < b.Name:lower()
		end
		return a.Count > b.Count
	end)

	for _, bucket in ipairs(nameBuckets) do
		local label = ("%s : %d"):format(bucket.Name, bucket.Count)
		local catBtn, holder = addCategory(Scrolling, label)
		local expanded = false
		catBtn.MouseButton1Click:Connect(function()
			expanded = not expanded
			holder.Visible = expanded
		end)

		-- For each BasePart instance
		for i, part in ipairs(bucket.Items) do
			local left = ("%s [%s] #%d"):format(part.Name, part.ClassName, i)
			addItemRow(
				holder,
				left,
				function() tpToPart(part) end,
				function() toggleSpectate(part) end
			)
		end
	end
end

-- Refresh
RefreshBtn.MouseButton1Click:Connect(function()
	stopSpectate()
	buildList()
end)

-- Ensure camera normal when GUI destroyed
ScreenGui.Destroying:Connect(function()
	stopSpectate()
end)

-- Initial build
buildList()
