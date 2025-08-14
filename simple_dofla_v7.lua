-- // UI Buat Delta Executor Roblox (revisi drag + kamera balik ke kita setelah teleport + clear search otomatis)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- ==== State ====
local targetPlayer = nil
local spectateActive = false

local function isMoving()
	return UIS:IsKeyDown(Enum.KeyCode.W)
		or UIS:IsKeyDown(Enum.KeyCode.A)
		or UIS:IsKeyDown(Enum.KeyCode.S)
		or UIS:IsKeyDown(Enum.KeyCode.D)
		or UIS:IsKeyDown(Enum.KeyCode.Space)
end

local function startSpectate(plr)
	if plr and plr.Character and plr.Character:FindFirstChild("Humanoid") then
		targetPlayer = plr
		spectateActive = true
		Camera.CameraSubject = plr.Character.Humanoid
	end
end

local function stopSpectate()
	spectateActive = false
	if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
		Camera.CameraSubject = LocalPlayer.Character.Humanoid
	end
end

-- ==== ScreenGui aman tampil ====
local gui = Instance.new("ScreenGui")
gui.Name = "DeltaSearchTP"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function() if syn and syn.protect_gui then syn.protect_gui(gui) end end)
local parentContainer = (gethui and gethui()) or game:FindFirstChildOfClass("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")
gui.Parent = parentContainer

-- ==== Main Frame ====
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 210)
mainFrame.Position = UDim2.new(0.5, -150, 0.3, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
mainFrame.BackgroundTransparency = 0.4
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = gui

do
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 15)
	corner.Parent = mainFrame
end

-- == Make Draggable (manual, smooth & reliable) ==
local function makeDraggable(frame)
	local dragging = false
	local dragInput, dragStart, startPos

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
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	frame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UIS.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			update(input)
		end
	end)
end
makeDraggable(mainFrame)

-- ==== Search Box ====
local searchBox = Instance.new("TextBox")
searchBox.PlaceholderText = "SEARCH"
searchBox.Size = UDim2.new(1, -20, 0, 40)
searchBox.Position = UDim2.new(0, 10, 0, 10)
searchBox.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
searchBox.Text = ""
searchBox.ClearTextOnFocus = false
searchBox.BorderSizePixel = 0
searchBox.Parent = mainFrame
do
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 10)
	c.Parent = searchBox
end

-- ==== Hasil Search (Scrolling) ====
local resultsFrame = Instance.new("ScrollingFrame")
resultsFrame.Size = UDim2.new(1, -20, 0, 60)
resultsFrame.Position = UDim2.new(0, 10, 0, 55)
resultsFrame.BackgroundTransparency = 1
resultsFrame.BorderSizePixel = 0
resultsFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
resultsFrame.ScrollBarThickness = 4
resultsFrame.Parent = mainFrame

local list = Instance.new("UIListLayout")
list.Padding = UDim.new(0, 5)
list.FillDirection = Enum.FillDirection.Vertical
list.SortOrder = Enum.SortOrder.LayoutOrder
list.Parent = resultsFrame
list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	resultsFrame.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y)
end)

-- ==== Tombol Clear Search ====
local clearBtn = Instance.new("TextButton")
clearBtn.Size = UDim2.new(1, -20, 0, 36)
clearBtn.Position = UDim2.new(0, 10, 0, 122)
clearBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
clearBtn.Text = "Clear Search"
clearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
clearBtn.BorderSizePixel = 0
clearBtn.AutoButtonColor = true
clearBtn.Parent = mainFrame
do
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 10)
	c.Parent = clearBtn
end
clearBtn.MouseButton1Click:Connect(function()
	searchBox.Text = ""
	for _, child in ipairs(resultsFrame:GetChildren()) do
		if child:IsA("TextButton") then child:Destroy() end
	end
end)

-- ==== Tombol Teleport ====
local teleportBtn = Instance.new("TextButton")
teleportBtn.Size = UDim2.new(1, -20, 0, 40)
teleportBtn.Position = UDim2.new(0, 10, 1, -50)
teleportBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
teleportBtn.Text = "Teleport"
teleportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
teleportBtn.BorderSizePixel = 0
teleportBtn.AutoButtonColor = true
teleportBtn.Parent = mainFrame
do
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 10)
	c.Parent = teleportBtn
end

-- ==== Search logic revisi (otomatis clear) ====
local function clearResults()
	for _, child in ipairs(resultsFrame:GetChildren()) do
		if child:IsA("TextButton") then child:Destroy() end
	end
end

local function clearSearch()
	searchBox.Text = ""
	clearResults()
end

local function addResultButton(plr)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 30)
	btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Text = (plr.DisplayName .. " (" .. plr.Name .. ")")
	btn.BorderSizePixel = 0
	btn.Parent = resultsFrame

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 8)
	c.Parent = btn

	btn.MouseButton1Click:Connect(function()
		if plr.Character and plr.Character:FindFirstChild("Humanoid") then
			startSpectate(plr)
			clearSearch() -- otomatis clear saat pilih pemain
		end
	end)
end

local function searchPlayers(query)
	clearResults()
	if query == "" then return end
	query = string.lower(query)
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			local name = string.lower(plr.Name)
			local dname = string.lower(plr.DisplayName)
			if string.find(name, query) or string.find(dname, query) then
				addResultButton(plr)
			end
		end
	end
end

searchBox:GetPropertyChangedSignal("Text"):Connect(function()
	searchPlayers(searchBox.Text)
end)

-- ==== Kamera Update ====
RunService.RenderStepped:Connect(function()
	if spectateActive then
		if isMoving() then
			stopSpectate() -- bergerak -> balik ke kita dan berhenti spectate
			return
		end
		if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Humanoid") then
			if Camera.CameraSubject ~= targetPlayer.Character.Humanoid then
				Camera.CameraSubject = targetPlayer.Character.Humanoid
			end
		else
			stopSpectate() -- target invalid (respawn/leave)
		end
	end
end)

-- ==== Teleport action revisi (otomatis clear search) ====
teleportBtn.MouseButton1Click:Connect(function()
	if targetPlayer
		and targetPlayer.Character
		and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
		and LocalPlayer.Character
		and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then

		local hrp = LocalPlayer.Character.HumanoidRootPart
		local targetHRP = targetPlayer.Character.HumanoidRootPart
		hrp.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 12)

		-- setelah teleport, kamera balik ke kita
		stopSpectate()

		-- otomatis clear search
		clearSearch()
	end
end)
