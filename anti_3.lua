-- LocalScript di StarterPlayerScripts
-- Fitur: Search, Select Target, Snap Camera, Teleport 12 stud di belakang target
-- UI transparan, draggable, list dinamis

--// VARIABEL UTAMA
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local SelectedTarget = nil
local SearchResults = {}

--// BUAT UI
local ScreenGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 220, 0, 90)
MainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
MainFrame.BackgroundTransparency = 0.3
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0

local UIListLayout = Instance.new("UIListLayout", MainFrame)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Search box
local SearchBox = Instance.new("TextBox", MainFrame)
SearchBox.Size = UDim2.new(1, -10, 0, 30)
SearchBox.BackgroundTransparency = 0.5
SearchBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SearchBox.BorderSizePixel = 0
SearchBox.PlaceholderText = "Search..."
SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SearchBox.ClearTextOnFocus = false
SearchBox.LayoutOrder = 1
SearchBox.TextSize = 14

-- Teleport button
local TeleportBtn = Instance.new("TextButton", MainFrame)
TeleportBtn.Size = UDim2.new(1, -10, 0, 30)
TeleportBtn.BackgroundTransparency = 0.5
TeleportBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
TeleportBtn.BorderSizePixel = 0
TeleportBtn.Text = "Teleport"
TeleportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TeleportBtn.LayoutOrder = 2
TeleportBtn.TextSize = 14

-- List container (awalnya kosong)
local ListFrame = Instance.new("Frame", MainFrame)
ListFrame.Size = UDim2.new(1, -10, 0, 0)
ListFrame.BackgroundTransparency = 1
ListFrame.BorderSizePixel = 0
ListFrame.LayoutOrder = 3

local ListLayout = Instance.new("UIListLayout", ListFrame)
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Padding = UDim.new(0, 2)

--// DRAGGABLE
local dragging, dragStart, startPos
MainFrame.Active = true

MainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
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

UserInputService.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		MainFrame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

--// FUNGSI AMBIL TEKS DARI TARGET
local function getObjectLabels(obj)
	local labels = {}

	-- Ambil name
	if obj.Name and obj.Name ~= "" then
		table.insert(labels, obj.Name:lower())
	end

	-- Kalau ada Player
	local plr = Players:GetPlayerFromCharacter(obj)
	if plr then
		table.insert(labels, plr.Name:lower())
		if plr.DisplayName then
			table.insert(labels, plr.DisplayName:lower())
		end
	end

	-- Cari GUI Text
	for _, descendant in ipairs(obj:GetDescendants()) do
		if descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
			if descendant.Text and descendant.Text ~= "" then
				table.insert(labels, descendant.Text:lower())
			end
		end
	end

	return labels
end

--// CARI TARGET
local function searchTargets(keyword)
	SearchResults = {}
	keyword = keyword:lower()

	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("Model") or obj:IsA("BasePart") then
			local labels = getObjectLabels(obj)
			for _, text in ipairs(labels) do
				if string.find(text, keyword) then
					table.insert(SearchResults, obj)
					break
				end
			end
		end
	end
end

--// UPDATE LIST
local function updateList()
	for _, child in ipairs(ListFrame:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	if #SearchResults == 0 then
		ListFrame.Size = UDim2.new(1, -10, 0, 0)
		return
	end

	for _, obj in ipairs(SearchResults) do
		local btn = Instance.new("TextButton", ListFrame)
		btn.Size = UDim2.new(1, 0, 0, 25)
		btn.BackgroundTransparency = 0.5
		btn.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
		btn.BorderSizePixel = 0
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		btn.TextSize = 12
		btn.Text = obj.Name

		btn.MouseButton1Click:Connect(function()
			SelectedTarget = obj
			if obj:IsA("Model") and obj.PrimaryPart then
				Camera.CameraType = Enum.CameraType.Scriptable
				Camera.CFrame = CFrame.new(Camera.CFrame.Position, obj.PrimaryPart.Position)
			elseif obj:IsA("BasePart") then
				Camera.CameraType = Enum.CameraType.Scriptable
				Camera.CFrame = CFrame.new(Camera.CFrame.Position, obj.Position)
			end
		end)
	end

	ListFrame.Size = UDim2.new(1, -10, 0, (#SearchResults * 27))
end

--// INPUT SEARCH
SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
	local text = SearchBox.Text
	if text == "" then
		SearchResults = {}
		updateList()
		return
	end
	searchTargets(text)
	updateList()
end)

--// TELEPORT
TeleportBtn.MouseButton1Click:Connect(function()
	if SelectedTarget and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
		local hrp = LocalPlayer.Character.HumanoidRootPart
		local targetPos

		if SelectedTarget:IsA("Model") and SelectedTarget.PrimaryPart then
			targetPos = SelectedTarget.PrimaryPart.CFrame
		elseif SelectedTarget:IsA("BasePart") then
			targetPos = SelectedTarget.CFrame
		end

		if targetPos then
			local behind = targetPos * CFrame.new(0, 0, 12)
			hrp.CFrame = behind
		end
	end
end)

--// Biar POV masih bisa gerak
RunService.RenderStepped:Connect(function()
	if Camera.CameraType == Enum.CameraType.Scriptable and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
		local delta = UserInputService:GetMouseDelta()
		local angleX = math.rad(-delta.Y * 0.3)
		local angleY = math.rad(-delta.X * 0.3)
		local camCF = Camera.CFrame
		Camera.CFrame = camCF * CFrame.Angles(angleX, angleY, 0)
	end
end)
