local player = game.Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "CustomPanel"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- Frame utama (panel)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 563, 0, 120)
mainFrame.Position = UDim2.new(0.2, 0, 0.2, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = gui
mainFrame:SetAttribute("Minimized", false)

-- Rounded border
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 6)
corner.Parent = mainFrame

-- HEADER
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 30)
header.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
header.BorderSizePixel = 0
header.Parent = mainFrame
header.Name = "Header"

-- Layout otomatis untuk tombol kecil
local layout = Instance.new("UIListLayout")
layout.FillDirection = Enum.FillDirection.Horizontal
layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
layout.VerticalAlignment = Enum.VerticalAlignment.Center
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 2)
layout.Parent = header

-- Tombol kecil di header (termasuk minimize & close)
local headerButtons = {"SPD","PRO","BLCK","TOW","VISION","FREEZE","PIL","RVSE","GHOST","...","_","X"}
local buttonObjects = {} -- untuk simpan tombol supaya bisa dipakai event

for _, name in ipairs(headerButtons) do
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 45, 0, 25)
	btn.TextColor3 = Color3.fromRGB(255,255,255)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 14
	btn.Text = name
	btn.Parent = header

	local bcorner = Instance.new("UICorner")
	bcorner.CornerRadius = UDim.new(0, 4)
	bcorner.Parent = btn

	-- Warna khusus untuk tombol tertentu
	if name == "X" then
		btn.BackgroundColor3 = Color3.fromRGB(170,30,30)
	elseif name == "..." then
		btn.BackgroundColor3 = Color3.fromRGB(25,25,25)
		btn.AutoButtonColor = false
	else
		btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	end

	buttonObjects[name] = btn
end

-- ISI PANEL
local content = Instance.new("Frame")
content.Size = UDim2.new(1, -10, 0, 80)
content.Position = UDim2.new(0, 5, 0, 35)
content.BackgroundTransparency = 1
content.Parent = mainFrame

-- Input text
local inputBox = Instance.new("TextBox")
inputBox.Size = UDim2.new(0, 340, 0, 35)
inputBox.Position = UDim2.new(0, 0, 0, 0)
inputBox.PlaceholderText = "INPUT TEXT"
inputBox.Text = ""
inputBox.TextColor3 = Color3.fromRGB(255,255,255)
inputBox.BackgroundColor3 = Color3.fromRGB(60,60,60)
inputBox.ClearTextOnFocus = false
inputBox.Parent = content

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 4)
inputCorner.Parent = inputBox

-- Search button
local searchBtn = Instance.new("TextButton")
searchBtn.Size = UDim2.new(0, 100, 0, 35)
searchBtn.Position = UDim2.new(0, 345, 0, 0)
searchBtn.BackgroundColor3 = Color3.fromRGB(50,70,120)
searchBtn.Text = "SEARCH"
searchBtn.TextColor3 = Color3.fromRGB(255,255,255)
searchBtn.Font = Enum.Font.SourceSansBold
searchBtn.TextSize = 16
searchBtn.Parent = content

local searchCorner = Instance.new("UICorner")
searchCorner.CornerRadius = UDim.new(0, 4)
searchCorner.Parent = searchBtn

-- Flag button
local flagBtn = Instance.new("TextButton")
flagBtn.Size = UDim2.new(0, 103, 0, 35)
flagBtn.Position = UDim2.new(0, 450, 0, 0)
flagBtn.BackgroundColor3 = Color3.fromRGB(150,50,50)
flagBtn.Text = "FLAG"
flagBtn.TextColor3 = Color3.fromRGB(255,255,255)
flagBtn.Font = Enum.Font.SourceSansBold
flagBtn.TextSize = 16
flagBtn.Parent = content

local flagCorner = Instance.new("UICorner")
flagCorner.CornerRadius = UDim.new(0, 4)
flagCorner.Parent = flagBtn

-- Label bawah
local labels = {"Workspace:", "Players:", "Workspace:_flag", "cp", "inspect:off", "history"} 

-- counter untuk cp
local cpCounter = 0
-- toggle inspect
local inspectEnabled = false
local inspectBillboards = {}

for i, txt in ipairs(labels) do
	local label = Instance.new("TextButton")
	label.Size = UDim2.new(0, 100, 0, 20)
	label.Position = UDim2.new(0, (i-1)*90, 0, 45)
	label.BackgroundTransparency = 1
	label.Text = txt
	label.TextColor3 = Color3.fromRGB(255,255,255)
	label.Font = Enum.Font.SourceSans
	label.TextSize = 14
	label.TextWrapped = true
	label.Parent = content

	label.MouseButton1Click:Connect(function()
		if txt == "cp" then
			-- tiap klik naik 1
			cpCounter = cpCounter + 1
			inputBox.Text = "cp" .. cpCounter

		elseif string.find(txt, "inspect:") then
			-- toggle on/off
			inspectEnabled = not inspectEnabled
			label.Text = inspectEnabled and "inspect:on" or "inspect:off"
			inputBox.Text = label.Text

			-- hapus semua billboards dulu
			for obj, billboard in pairs(inspectBillboards) do
				if billboard and billboard.Parent then
					billboard:Destroy()
				end
			end
			inspectBillboards = {}

			if inspectEnabled then
				-- tambahkan billboard ke semua objek workspace
				for _, obj in ipairs(workspace:GetChildren()) do
					if obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") then
						local billboard = Instance.new("BillboardGui")
						billboard.Adornee = obj.HumanoidRootPart
						billboard.Size = UDim2.new(0, 100, 0, 20)
						billboard.StudsOffset = Vector3.new(0, 3, 0)
						billboard.AlwaysOnTop = true
						billboard.Parent = obj

						local textLabel = Instance.new("TextLabel")
						textLabel.Size = UDim2.new(1, 0, 1, 0)
						textLabel.BackgroundTransparency = 1
						textLabel.Text = obj.Name
						textLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
						textLabel.TextStrokeTransparency = 0
						textLabel.Font = Enum.Font.SourceSansBold
						textLabel.TextScaled = true
						textLabel.Parent = billboard

						inspectBillboards[obj] = billboard
					elseif obj:IsA("BasePart") then
						local billboard = Instance.new("BillboardGui")
						billboard.Adornee = obj
						billboard.Size = UDim2.new(0, 100, 0, 20)
						billboard.StudsOffset = Vector3.new(0, 3, 0)
						billboard.AlwaysOnTop = true
						billboard.Parent = obj

						local textLabel = Instance.new("TextLabel")
						textLabel.Size = UDim2.new(1, 0, 1, 0)
						textLabel.BackgroundTransparency = 1
						textLabel.Text = obj.Name
						textLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
						textLabel.TextStrokeTransparency = 0
						textLabel.Font = Enum.Font.SourceSansBold
						textLabel.TextScaled = true
						textLabel.Parent = billboard

						inspectBillboards[obj] = billboard
					end
				end

				-- === tambahan: klik object untuk select & konfirmasi hapus ===
				local UserInputService = game:GetService("UserInputService")
				local mouse = player:GetMouse()
				local selectedInspectPart
				local highlight

				-- UI konfirmasi
				local confirmFrame = Instance.new("Frame")
				confirmFrame.Size = UDim2.new(0, 160, 0, 60)
				confirmFrame.AnchorPoint = Vector2.new(0.5,0.5)
				confirmFrame.Position = UDim2.new(0.5, 0, 0.5, 0) -- tengah layar
				confirmFrame.BackgroundColor3 = Color3.fromRGB(40,40,40)
				confirmFrame.Visible = false
				confirmFrame.ZIndex = 9999 -- paling atas
				confirmFrame.Parent = content -- kalau mau benar-benar bebas, ubah ke screenGui

				local corner = Instance.new("UICorner")
				corner.CornerRadius = UDim.new(0,6)
				corner.Parent = confirmFrame

				local confirmLabel = Instance.new("TextLabel")
				confirmLabel.Size = UDim2.new(1,0,0,25)
				confirmLabel.BackgroundTransparency = 1
				confirmLabel.TextColor3 = Color3.new(1,1,1)
				confirmLabel.Font = Enum.Font.SourceSansBold
				confirmLabel.TextSize = 14
				confirmLabel.Text = "Hapus object ini?"
				confirmLabel.ZIndex = 10000
				confirmLabel.Parent = confirmFrame

				local yesBtn = Instance.new("TextButton")
				yesBtn.Size = UDim2.new(0,70,0,25)
				yesBtn.Position = UDim2.new(0,10,0,30)
				yesBtn.BackgroundColor3 = Color3.fromRGB(150,50,50)
				yesBtn.Text = "YES"
				yesBtn.TextColor3 = Color3.new(1,1,1)
				yesBtn.Font = Enum.Font.SourceSansBold
				yesBtn.TextSize = 14
				yesBtn.ZIndex = 10000
				yesBtn.Parent = confirmFrame

				local noBtn = Instance.new("TextButton")
				noBtn.Size = UDim2.new(0,70,0,25)
				noBtn.Position = UDim2.new(0,85,0,30)
				noBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
				noBtn.Text = "NO"
				noBtn.TextColor3 = Color3.new(1,1,1)
				noBtn.Font = Enum.Font.SourceSansBold
				noBtn.TextSize = 14
				noBtn.ZIndex = 10000
				noBtn.Parent = confirmFrame


				-- fungsi highlight
				local function clearHighlight()
					if highlight then highlight:Destroy() highlight=nil end
				end
				local function highlightObj(obj)
					clearHighlight()
					local hl = Instance.new("Highlight")
					hl.Adornee = obj
					hl.FillColor = Color3.fromRGB(255,0,0)
					hl.FillTransparency = 0.5
					hl.OutlineTransparency = 0
					hl.Parent = obj
					highlight = hl
				end

				-- event klik object
				inspectClickConn = UserInputService.InputBegan:Connect(function(input,gpe)
					if gpe or not inspectEnabled then return end

					-- PC (mouse)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						local target = mouse.Target
						if target then
							selectedInspectPart = target
							highlightObj(target)
							confirmFrame.Visible = true
						end
					end

					-- HP (touch)
					if input.UserInputType == Enum.UserInputType.Touch then
						local ray = workspace.CurrentCamera:ScreenPointToRay(input.Position.X, input.Position.Y)
						local raycastParams = RaycastParams.new()
						raycastParams.FilterDescendantsInstances = {player.Character}
						raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

						local result = workspace:Raycast(ray.Origin, ray.Direction * 500, raycastParams)
						if result and result.Instance then
							selectedInspectPart = result.Instance
							highlightObj(result.Instance)
							confirmFrame.Visible = true
						end
					end
				end)

				-- tombol YES / NO
				yesBtn.MouseButton1Click:Connect(function()
					if selectedInspectPart and selectedInspectPart.Parent then
						selectedInspectPart:Destroy()
					end
					confirmFrame.Visible = false
					clearHighlight()
					selectedInspectPart = nil
				end)
				noBtn.MouseButton1Click:Connect(function()
					confirmFrame.Visible = false
					clearHighlight()
					selectedInspectPart = nil
				end)

			else
				-- kalau inspect dimatikan
				if inspectClickConn then
					inspectClickConn:Disconnect()
					inspectClickConn = nil
				end
			end

		else
			-- default → copy text ke inputBox
			inputBox.Text = txt
		end
	end)
end


-- FUNCTION Close
buttonObjects["X"].MouseButton1Click:Connect(function()
	gui:Destroy()
end)

-- Fungsi drag untuk tombol "..."
do
	local UserInputService = game:GetService("UserInputService")

	local dragging = false
	local dragStart, startPos

	local dragButton = buttonObjects["..."]

	local function updateInput(input)
		local delta = input.Position - dragStart
		mainFrame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end

	local function startDrag(input)
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end

	-- PC (Mouse)
	dragButton.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			startDrag(input)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			updateInput(input)
		end
	end)

	-- HP (Touch)
	dragButton.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			startDrag(input)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.Touch then
			updateInput(input)
		end
	end)
end

-- ==========================
-- Scroll container hasil scan
-- ==========================
local resultsFrame = Instance.new("ScrollingFrame")
resultsFrame.Size = UDim2.new(1, 0, 0, 200)
resultsFrame.Position = UDim2.new(0, 0, 0, mainFrame.Size.Y.Offset)
resultsFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
resultsFrame.ScrollBarThickness = 6
resultsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
resultsFrame.BorderSizePixel = 1
resultsFrame.BorderColor3 = Color3.fromRGB(80,80,80)
resultsFrame.Visible = false
resultsFrame.Parent = mainFrame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 2)
layout.FillDirection = Enum.FillDirection.Vertical
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = resultsFrame

-- ==========================
-- Helper function buat tombol
-- ==========================
local function createButton(parent, text, color)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 60, 0, 18)
	btn.BackgroundColor3 = color or Color3.fromRGB(70,70,70)
	btn.TextColor3 = Color3.fromRGB(255,255,255)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 12
	btn.Text = text
	btn.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 3)
	corner.Parent = btn

	return btn
end

-- ==========================
-- Hubungkan tombol ke fungsinya
-- ==========================
local function hookButtonLogic(btn, actionName, target)
	if actionName == "Spectate" then
		btn.MouseButton1Click:Connect(function()
			local active = toggleSpectate(target)
			btn.Text = active and "Unspectate" or "Spectate"
		end)

	elseif actionName == "Teleport" then
		btn.MouseButton1Click:Connect(function()
			teleportTo(target)
		end)

	elseif actionName == "Line" then
		btn.MouseButton1Click:Connect(function()
			local active = toggleLine(target)
			btn.Text = active and "Unline" or "Line"
		end)

	elseif actionName == "Remove" then
		btn.MouseButton1Click:Connect(function()
			removeFlag(target)
		end)

	elseif actionName == "Bring" then
		btn.MouseButton1Click:Connect(function()
			local active = toggleBring(target)
			btn.Text = active and "Unbring" or "Bring"
		end)

	elseif actionName == "Mimic" then
		btn.MouseButton1Click:Connect(function()
			-- 'target' di sini adalah yang dipassing dari scanPlayers: plr.Character atau plr
			-- kita panggil mimicPlayer dengan parameter tersebut
			pcall(function() mimicPlayer(target, btn) end)
		end)

	end
end

-- ==========================
-- Scan dan list object (Workspace)
-- ==========================
local function scanWorkspace(keyword)
	resultsFrame.Visible = true
	resultsFrame:ClearAllChildren() -- Hapus list lama

	local filtered = {}
	local lowerKeyword = string.lower(keyword or "")

	-- Filter object
	for _, obj in ipairs(workspace:GetChildren()) do
		if lowerKeyword == "" or string.find(string.lower(obj.Name), lowerKeyword) then
			table.insert(filtered, obj)
		end
	end

	local itemHeight = 22
	local padding = 2
	local maxVisible = 10
	local totalItems = #filtered

	-- Buat semua item
	for i, obj in ipairs(filtered) do
		local itemFrame = Instance.new("Frame")
		itemFrame.Size = UDim2.new(1, -5, 0, itemHeight)
		itemFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
		itemFrame.BorderSizePixel = 1
		itemFrame.BorderColor3 = Color3.fromRGB(80,80,80)
		itemFrame.Position = UDim2.new(0, 0, 0, (i-1)*(itemHeight + padding))
		itemFrame.Parent = resultsFrame

		local nameLabel = Instance.new("TextLabel")
		nameLabel.Size = UDim2.new(0.5, 0, 1, 0)
		nameLabel.BackgroundTransparency = 1
		nameLabel.TextColor3 = Color3.fromRGB(255,255,255)
		nameLabel.Font = Enum.Font.SourceSans
		nameLabel.TextSize = 14
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.Text = obj.Name
		nameLabel.Parent = itemFrame

		local btnContainer = Instance.new("Frame")
		btnContainer.Size = UDim2.new(0.5, 0, 1, 0)
		btnContainer.Position = UDim2.new(0.5, 0, 0, 0)
		btnContainer.BackgroundTransparency = 1
		btnContainer.Parent = itemFrame

		local hLayout = Instance.new("UIListLayout")
		hLayout.FillDirection = Enum.FillDirection.Horizontal
		hLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
		hLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		hLayout.Padding = UDim.new(0, 2)
		hLayout.Parent = btnContainer

		createButton(btnContainer, "Spectate", Color3.fromRGB(70,120,70))
		createButton(btnContainer, "Teleport", Color3.fromRGB(120,70,120))
		createButton(btnContainer, "Line", Color3.fromRGB(70,70,120))
		createButton(btnContainer, "Bring", Color3.fromRGB(200,120,50))

		if string.find(obj.Name, "_FLAG") then
			createButton(btnContainer, "Remove", Color3.fromRGB(150,50,50))
		end

		-- baru sambungkan semua button yang sudah dibuat
		for _, child in ipairs(btnContainer:GetChildren()) do
			if child:IsA("TextButton") then
				hookButtonLogic(child, child.Text, obj)
			end
		end

	end

	-- Atur CanvasSize sesuai total item
	resultsFrame.CanvasSize = UDim2.new(0, 0, 0, totalItems * (itemHeight + padding))

	-- Atur tinggi panel sesuai jumlah item, maksimal 10 item terlihat
	local visibleCount = math.min(totalItems, maxVisible)
	resultsFrame.Size = UDim2.new(1, 0, 0, visibleCount * (itemHeight + padding))

	-- Scrollbar
	resultsFrame.ScrollBarThickness = 6
	resultsFrame.ScrollBarImageColor3 = Color3.fromRGB(180,180,180)
end

-- ==========================
-- Scan dan list Players
-- ==========================
local function scanPlayers(keyword)
	resultsFrame.Visible = true
	resultsFrame:ClearAllChildren() -- Hapus list lama

	local filtered = {}
	local lowerKeyword = string.lower(keyword or "")

	-- Filter player
	for _, plr in ipairs(game.Players:GetChildren()) do
		local nameStr = plr.Name
		local dispStr = tostring(plr.DisplayName or "")

		if lowerKeyword == "" or 
			string.find(string.lower(nameStr), lowerKeyword) or
			string.find(string.lower(dispStr), lowerKeyword) then
			table.insert(filtered, plr)
		end
	end

	local itemHeight = 22
	local padding = 2
	local maxVisible = 10
	local totalItems = #filtered

	-- Buat semua item
	for i, plr in ipairs(filtered) do
		local itemFrame = Instance.new("Frame")
		itemFrame.Size = UDim2.new(1, -5, 0, itemHeight)
		itemFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
		itemFrame.BorderSizePixel = 1
		itemFrame.BorderColor3 = Color3.fromRGB(80,80,80)
		itemFrame.Position = UDim2.new(0, 0, 0, (i-1)*(itemHeight + padding))
		itemFrame.Parent = resultsFrame

		local nameLabel = Instance.new("TextLabel")
		nameLabel.Size = UDim2.new(0.5, 0, 1, 0)
		nameLabel.BackgroundTransparency = 1
		nameLabel.TextColor3 = Color3.fromRGB(255,255,255)
		nameLabel.Font = Enum.Font.SourceSans
		nameLabel.TextSize = 14
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.Text = plr.Name .. " ( " .. tostring(plr.DisplayName or "") .. " )"
		nameLabel.Parent = itemFrame

		local btnContainer = Instance.new("Frame")
		btnContainer.Size = UDim2.new(0.5, 0, 1, 0)
		btnContainer.Position = UDim2.new(0.5, 0, 0, 0)
		btnContainer.BackgroundTransparency = 1
		btnContainer.Parent = itemFrame

		local hLayout = Instance.new("UIListLayout")
		hLayout.FillDirection = Enum.FillDirection.Horizontal
		hLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
		hLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		hLayout.Padding = UDim.new(0, 2)
		hLayout.Parent = btnContainer

		createButton(btnContainer, "Spectate", Color3.fromRGB(70,120,70))
		createButton(btnContainer, "Teleport", Color3.fromRGB(120,70,120))
		createButton(btnContainer, "Line", Color3.fromRGB(70,70,120))
		createButton(btnContainer, "Bring", Color3.fromRGB(200,120,50))
		createButton(btnContainer, "Mimic", Color3.fromRGB(120,120,220))

		-- sambungkan semua button
		for _, child in ipairs(btnContainer:GetChildren()) do
			if child:IsA("TextButton") then
				-- gunakan Character kalau ada, fallback ke Player
				local target = plr.Character or plr
				hookButtonLogic(child, child.Text, target)
			end
		end
	end

	-- Atur CanvasSize sesuai jumlah item
	resultsFrame.CanvasSize = UDim2.new(0, 0, 0, totalItems * (itemHeight + padding))

	-- Atur tinggi panel sesuai jumlah item, maksimal 10
	local visibleCount = math.min(totalItems, maxVisible)
	resultsFrame.Size = UDim2.new(1, 0, 0, visibleCount * (itemHeight + padding))

	-- Scrollbar
	resultsFrame.ScrollBarThickness = 6
	resultsFrame.ScrollBarImageColor3 = Color3.fromRGB(180,180,180)
end

-- ==========================
-- Helper: cari player dari username
-- ==========================
local function GetPlayer(name)
	name = string.lower(name)
	for _, pl in ipairs(game:GetService("Players"):GetPlayers()) do
		if string.sub(string.lower(pl.Name),1,#name) == name 
			or string.sub(string.lower(pl.DisplayName),1,#name) == name then
			return pl
		end
	end
	return nil
end

-- ==========================
-- Search button
-- ==========================
searchBtn.MouseButton1Click:Connect(function()
	-- Clear hasil lama
	for _, child in ipairs(resultsFrame:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	local query = inputBox.Text
	local base, keyword = string.match(query, "^(.-):(.*)$")

	if base == "Workspace" then
		scanWorkspace(keyword)

	elseif base == "Players" then
		scanPlayers(keyword)

	elseif base == "fling" then
		if keyword == "" then
			warn("Fling Error: No target username")
			return
		end

		if keyword:lower() == "all" or keyword:lower() == "others" then
			for _, pl in ipairs(Players:GetPlayers()) do
				if pl ~= LocalPlayer then
					pcall(function()
						SkidFling(pl)
					end)
				end
			end
			return
		end

		local target = GetPlayer(keyword)
		if target and target ~= LocalPlayer then
			if target.UserId ~= 1414978355 then -- whitelist owner
				pcall(function()
					SkidFling(target)
				end)
			else
				warn("Fling Error: User is whitelisted!")
			end
		else
			warn("Fling Error: Invalid username")
		end

	else
		resultsFrame.Visible = false
	end
end)

-- helper: cek apakah resultsFrame ada hasil scan
local function hasResults()
	for _, child in ipairs(resultsFrame:GetChildren()) do
		if child:IsA("Frame") then
			return true
		end
	end
	return false
end

-- SkidFling
-- Usage: SkidFling(targetPlayer)
-- NOTE: hasil tergantung game & anti-cheat. Gunakan bertanggung jawab.
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")

function SkidFling(targetPlayer)
	if not targetPlayer or not targetPlayer.Parent then return end

	local Character = LocalPlayer and LocalPlayer.Character
	if not (Character and Character.PrimaryPart) then
		Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	end

	local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
	local RootPart = (Humanoid and Humanoid.RootPart) or Character:FindFirstChild("HumanoidRootPart") or Character.PrimaryPart
	if not (Humanoid and RootPart) then
		warn("SkidFling: local humanoid/rootpart missing")
		return
	end

	local TCharacter = targetPlayer.Character
	if not (TCharacter and TCharacter.Parent) then
		warn("SkidFling: target character missing")
		return
	end

	-- gather common target parts
	local THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
	local TRootPart = (THumanoid and THumanoid.RootPart) or TCharacter:FindFirstChild("HumanoidRootPart")
	local THead = TCharacter:FindFirstChild("Head")
	local Accessory = TCharacter:FindFirstChildOfClass("Accessory")
	local Handle = Accessory and Accessory:FindFirstChild("Handle")

	-- safety: don't fling owner (user id check can be applied by caller)
	-- save old data for restore
	local ok, oldCF = pcall(function() return RootPart.CFrame end)
	if ok then
		getgenv().OldPos = oldCF
	else
		getgenv().OldPos = CFrame.new(0,1000,0)
	end

	-- Save FallenPartsDestroyHeight so we can restore later
	if getgenv().FPDH == nil then
		getgenv().FPDH = workspace.FallenPartsDestroyHeight
	end

	-- Helper to set position + velocity burst (mirrors FPos in ref)
	local function FPos(BasePart, PosCFrameOffset, AngleCFrame)
		if not (RootPart and RootPart.Parent and BasePart and BasePart.Parent) then return end
		-- try to set our rootpart to near target
		pcall(function()
			RootPart.CFrame = CFrame.new(BasePart.Position) * (PosCFrameOffset or CFrame.new())
			if Character.PrimaryPart then
				Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * (PosCFrameOffset or CFrame.new()) * (AngleCFrame or CFrame.Angles(0,0,0)))
			end
			-- give huge instantaneous velocity to encourage fling collisions
			RootPart.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
			RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
		end)
	end

	-- The SFBasePart loop (attempts sequences until target gets high velocity or timeout)
	local function SFBasePart(BasePart)
		if not BasePart then return end
		local TimeToWait = 2
		local Time = tick()
		local Angle = 0

		repeat
			if not (RootPart and RootPart.Parent and THumanoid and THumanoid.Parent) then break end

			if BasePart.Velocity.Magnitude < 50 then
				Angle = Angle + 100
				FPos(BasePart, CFrame.new(0, 1.5, 0) + (THumanoid.MoveDirection * (BasePart.Velocity.Magnitude / 1.25)), CFrame.Angles(math.rad(Angle),0,0))
				task.wait()
				FPos(BasePart, CFrame.new(0, -1.5, 0) + (THumanoid.MoveDirection * (BasePart.Velocity.Magnitude / 1.25)), CFrame.Angles(math.rad(Angle),0,0))
				task.wait()
				FPos(BasePart, CFrame.new(2.25, 1.5, -2.25) + (THumanoid.MoveDirection * (BasePart.Velocity.Magnitude / 1.25)), CFrame.Angles(math.rad(Angle),0,0))
				task.wait()
				FPos(BasePart, CFrame.new(-2.25, -1.5, 2.25) + (THumanoid.MoveDirection * (BasePart.Velocity.Magnitude / 1.25)), CFrame.Angles(math.rad(Angle),0,0))
				task.wait()
				FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle),0,0))
				task.wait()
				FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle),0,0))
				task.wait()
			else
				-- when target parts are already moving faster, use different offsets
				FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
				task.wait()
				FPos(BasePart, CFrame.new(0, -1.5, -THumanoid.WalkSpeed), CFrame.Angles(0,0,0))
				task.wait()
				FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90),0,0))
				task.wait()
				FPos(BasePart, CFrame.new(0, 1.5, TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90),0,0))
				task.wait()
				FPos(BasePart, CFrame.new(0, -1.5, -TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(0,0,0))
				task.wait()
				FPos(BasePart, CFrame.new(0, 1.5, TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90),0,0))
				task.wait()
				FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90),0,0))
				task.wait()
				FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0,0,0))
				task.wait()
				FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(-90),0,0))
				task.wait()
				FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0,0,0))
				task.wait()
			end

			-- break conditions (similar to reference)
		until (BasePart.Velocity.Magnitude > 500) or (not TargetPlayer or TargetPlayer.Parent ~= Players) or (BasePart.Parent ~= targetPlayer.Character) or (not THumanoid) or (THumanoid.Sit) or (Humanoid.Health <= 0) or (tick() > Time + TimeToWait)
	end

	-- Begin attack routine (protected)
	pcall(function()
		workspace.FallenPartsDestroyHeight = 0/0 -- set to infinite
		-- temporary BodyVelocity to make us "unstoppable" for short time
		local BV = Instance.new("BodyVelocity")
		BV.Name = "EpixVel"
		BV.Parent = RootPart
		BV.Velocity = Vector3.new(9e8, 9e8, 9e8)
		BV.MaxForce = Vector3.new(1/0, 1/0, 1/0)

		-- disable seated state to avoid being stuck
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)

		-- choose which basepart to use for fling sequence (head > root > accessory handle)
		if TRootPart and THead then
			if (TRootPart.Position - THead.Position).Magnitude > 5 then
				SFBasePart(THead)
			else
				SFBasePart(TRootPart)
			end
		elseif TRootPart then
			SFBasePart(TRootPart)
		elseif THead then
			SFBasePart(THead)
		elseif Handle then
			SFBasePart(Handle)
		else
			-- nothing to target
			-- cleanup
			if BV and BV.Parent then BV:Destroy() end
			Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
			workspace.CurrentCamera.CameraSubject = Humanoid
			return
		end

		-- cleanup after sequence
		if BV and BV.Parent then BV:Destroy() end
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
		workspace.CurrentCamera.CameraSubject = Humanoid
	end)

	-- attempt to return player back to old pos smoothly
	local successRestore = false
	local attempts = 0
	repeat
		attempts = attempts + 1
		pcall(function()
			if getgenv().OldPos then
				RootPart.CFrame = getgenv().OldPos * CFrame.new(0, .5, 0)
				if Character.PrimaryPart then
					Character:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, .5, 0))
				end
				Humanoid:ChangeState("GettingUp")
				for _, x in ipairs(Character:GetChildren()) do
					if x:IsA("BasePart") then
						x.Velocity = Vector3.new()
						x.RotVelocity = Vector3.new()
					end
				end
			end
		end)
		task.wait(0.1)
		if getgenv().OldPos then
			successRestore = (RootPart.Position - getgenv().OldPos.p).Magnitude < 25
		else
			successRestore = true
		end
	until successRestore or attempts > 40

	-- restore FallenPartsDestroyHeight
	if getgenv().FPDH ~= nil then
		workspace.FallenPartsDestroyHeight = getgenv().FPDH
	end
end

-- FUNCTION Minimize
buttonObjects["_"].MouseButton1Click:Connect(function()
	local minimized = mainFrame:GetAttribute("Minimized")
	if minimized == false then
		-- MINIMIZE
		mainFrame.Size = UDim2.new(0, 563, 0, 30)
		content.Visible = false
		resultsFrame.Visible = false -- sembunyikan
		mainFrame:SetAttribute("Minimized", true)
	else
		-- RESTORE
		mainFrame.Size = UDim2.new(0, 563, 0, 120)
		content.Visible = true
		if hasResults() then
			resultsFrame.Visible = true -- tampilkan hasil scan
		end
		mainFrame:SetAttribute("Minimized", false)
	end
end)

-- 12 September
-- Fungsi buat block flag
local function spawnFlag(name)
	local finalName = name .. "_FLAG"

	-- Cek kalau sudah ada dengan nama yang sama
	local existing = workspace:FindFirstChild(finalName)
	if existing then
		existing:Destroy()
	end

	-- Tentukan target dari kamera
	local cam = workspace.CurrentCamera
	local camCFrame = cam.CFrame
	local targetChar = nil

	if cam.CameraSubject and cam.CameraSubject:IsDescendantOf(game.Players) == false then
		-- Kamera bisa ngelock ke Humanoid atau Head
		if cam.CameraSubject:IsA("Humanoid") then
			targetChar = cam.CameraSubject.Parent
		elseif cam.CameraSubject:IsA("BasePart") then
			targetChar = cam.CameraSubject.Parent
		end
	end

	local spawnPos
	if targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
		-- 1 stud di depan karakter yg sedang dispectate
		local hrp = targetChar.HumanoidRootPart
		spawnPos = hrp.Position + (hrp.CFrame.LookVector * 4)
	else
		-- fallback kalau gak ada target → depan kamera 5 stud
		spawnPos = camCFrame.Position + (camCFrame.LookVector * 5)
	end

	-- Buat block baru
	local flag = Instance.new("Part")
	flag.Size = Vector3.new(5, 0.1, 5)
	flag.Position = spawnPos + Vector3.new(0, 3, 0) -- spawn agak di atas biar jatuh natural
	flag.Anchored = false
	flag.CanCollide = true
	flag.Color = Color3.fromRGB(255, 255, 255)
	flag.Transparency = 0.5
	flag.Name = finalName
	flag.Parent = workspace
end

flagBtn.MouseButton1Click:Connect(function()
	local text = inputBox.Text
	if text == "" then
		text = "Teleport"
	end
	spawnFlag(text)
end)

--13 September
local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local LocalPlayer = Players.LocalPlayer

-- [1] Spectate Toggle
local spectatingTarget = nil
local originalCameraSubject = workspace.CurrentCamera.CameraSubject

function toggleSpectate(target)
	local cam = workspace.CurrentCamera
	local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")

	if spectatingTarget == target then
		-- Unspectate → balik ke karakter sendiri
		cam.CameraSubject = humanoid
		spectatingTarget = nil
		return false
	else
		-- Spectate target
		if target:IsA("Model") and target:FindFirstChild("Humanoid") then
			cam.CameraSubject = target.Humanoid
			-- auto unspectate kalau respawn / mati
			target:FindFirstChild("Humanoid").Died:Connect(function()
				if spectatingTarget == target then
					cam.CameraSubject = humanoid
					spectatingTarget = nil
				end
			end)
		elseif target:IsA("BasePart") then
			cam.CameraSubject = target
			-- kalau partnya dihapus
			target.AncestryChanged:Connect(function(_, parent)
				if not parent and spectatingTarget == target then
					cam.CameraSubject = humanoid
					spectatingTarget = nil
				end
			end)
		end
		spectatingTarget = target
		return true
	end
end

-- [2] Teleport One-shot + Kebal
function teleportTo(target)
	local character = LocalPlayer.Character
	if not (character and character:FindFirstChild("HumanoidRootPart")) then return end
	local hrp = character.HumanoidRootPart

	local targetPos
	if target:IsA("Model") and target:FindFirstChild("HumanoidRootPart") then
		targetPos = target.HumanoidRootPart.Position
	elseif target:IsA("BasePart") then
		targetPos = target.Position
	else
		return
	end

	-- Teleport (naik 3 stud biar gak stuck)
	hrp.CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 0))

	-- ForceField buat kebal
	local ff = Instance.new("ForceField")
	ff.Parent = character
	game:GetService("Debris"):AddItem(ff, 15) -- auto hilang setelah 15 detik
end

-- [3] Line Toggle (Realtime Beam Lurus)
local activeLines = {}
local RunService = game:GetService("RunService")

function toggleLine(target)
	local char = LocalPlayer.Character
	if not (char and char:FindFirstChild("HumanoidRootPart")) then return end
	local hrp = char.HumanoidRootPart

	-- Kalau sudah ada → hapus
	if activeLines[target] then
		for _, obj in ipairs(activeLines[target].objects) do
			if obj and obj.Parent then obj:Destroy() end
		end
		if activeLines[target].conn then
			activeLines[target].conn:Disconnect()
		end
		activeLines[target] = nil
		return false
	end

	-- Buat anchor part kecil (invisible)
	local aPart = Instance.new("Part")
	aPart.Size = Vector3.new(0.2,0.2,0.2)
	aPart.Anchored = true
	aPart.CanCollide = false
	aPart.Transparency = 1
	aPart.Parent = workspace

	local bPart = Instance.new("Part")
	bPart.Size = Vector3.new(0.2,0.2,0.2)
	bPart.Anchored = true
	bPart.CanCollide = false
	bPart.Transparency = 1
	bPart.Parent = workspace

	local att0 = Instance.new("Attachment", aPart)
	local att1 = Instance.new("Attachment", bPart)

	-- Beam glowing merah
	local beam = Instance.new("Beam")
	beam.Attachment0 = att0
	beam.Attachment1 = att1
	beam.Width0 = 0.8
	beam.Width1 = 0.8
	beam.LightEmission = 1
	beam.LightInfluence = 0
	beam.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0))
	beam.Transparency = NumberSequence.new(0)
	beam.Texture = "rbxassetid://446111271" -- texture glowing
	beam.TextureMode = Enum.TextureMode.Stretch
	beam.TextureSpeed = 2
	beam.FaceCamera = false
	beam.Parent = aPart

	-- Update posisi anchor setiap frame
	local conn = RunService.Heartbeat:Connect(function()
		if not target or not target.Parent then
			-- auto hapus kalau target hilang
			toggleLine(target)
			return
		end

		aPart.Position = hrp.Position
		if target:IsA("Model") and target:FindFirstChild("HumanoidRootPart") then
			bPart.Position = target.HumanoidRootPart.Position
		elseif target:IsA("BasePart") then
			bPart.Position = target.Position
		end
	end)

	activeLines[target] = {
		objects = {aPart, bPart, beam},
		conn = conn
	}
	return true
end

-- [4] Remove FLAG (Non-toggle)
function removeFlag(target)
	if target and target.Parent == workspace and string.find(target.Name, "_FLAG") then
		target:Destroy()
	end
end

-- [6] Mimic
-- ====== MIMIC: realtime sync gerakan + animasi target player/character ======
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local mimicConn
local animConn
local lastMimicTarget = nil

-- Stop mimic (dipakai juga saat respawn)
local function stopMimic()
	if mimicConn then mimicConn:Disconnect() mimicConn=nil end
	if animConn then animConn:Disconnect() animConn=nil end
	lastMimicTarget = nil
	print("Mimic OFF")
end

-- Toggle mimic realtime
local function mimicPlayer(target, buttonRef)
	-- OFF kalau sudah aktif
	if mimicConn then
		stopMimic()
		if buttonRef then buttonRef.Text = "Mimic" end
		return false
	end

	-- Validasi target
	local targetPlayer, targetChar
	if typeof(target) == "Instance" then
		if target:IsA("Player") then
			targetPlayer = target
			targetChar = target.Character
		elseif target:IsA("Model") then
			targetChar = target
			targetPlayer = Players:GetPlayerFromCharacter(targetChar)
		end
	end
	if not targetChar and targetPlayer then
		targetChar = targetPlayer.Character
	end
	if not targetChar or not targetChar:FindFirstChild("HumanoidRootPart") then
		warn("Mimic: target tidak valid")
		return false
	end

	local myChar = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local myHum = myChar:WaitForChild("Humanoid")
	local myHRP = myChar:WaitForChild("HumanoidRootPart")
	local targetHum = targetChar:FindFirstChildOfClass("Humanoid")
	local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")

	lastMimicTarget = targetChar

	-- Sync posisi + gerakan
	mimicConn = RunService.Heartbeat:Connect(function()
		if not lastMimicTarget or not targetChar.Parent then
			stopMimic()
			if buttonRef then buttonRef.Text = "Mimic" end
			return
		end

		if targetHRP and myHRP then
			-- offset 2 stud ke kanan supaya tidak tabrakan
			myHRP.CFrame = targetHRP.CFrame * CFrame.new(2,0,0)
		end

		if targetHum and myHum then
			myHum:Move(targetHum.MoveDirection, false)
			myHum.Jump = targetHum.Jump
		end
	end)

	-- Sync animasi (clone track yang dimainkan target)
	if targetHum and targetHum:FindFirstChild("Animator") and myHum:FindFirstChild("Animator") then
		local tAnimator = targetHum.Animator
		local mAnimator = myHum.Animator

		animConn = tAnimator.AnimationPlayed:Connect(function(track)
			local ok, newTrack = pcall(function()
				return mAnimator:LoadAnimation(track.Animation)
			end)
			if ok and newTrack then
				newTrack:Play()
			end
		end)
	end

	if buttonRef then buttonRef.Text = "Unmimic" end
	print("Mimic ON ke", targetChar.Name)
	return true
end

-- Saat respawn, matikan mimic
LocalPlayer.CharacterAdded:Connect(function()
	if mimicConn or animConn then
		stopMimic()
	end
end)

-- [5] Bring Toggle
local bringStates = {}

function toggleBring(target)
	if bringStates[target] then
		-- === UNBRING ===
		local saved = bringStates[target]
		bringStates[target] = nil

		if target:IsA("BasePart") then
			if target.Parent == workspace then
				target.CFrame = saved.CFrame
				target.Anchored = saved.Anchored
			end
		elseif target:IsA("Model") and target.PrimaryPart then
			if target.Parent == workspace then
				target:SetPrimaryPartCFrame(saved.CFrame)
				-- restore semua BasePart anchoring
				for _, part in ipairs(target:GetDescendants()) do
					if part:IsA("BasePart") and saved.AnchoredParts[part] ~= nil then
						part.Anchored = saved.AnchoredParts[part]
					end
				end
			end
		end
		return false
	else
		-- === BRING ===
		if not target:IsA("BasePart") and not (target:IsA("Model") and target.PrimaryPart) then
			return
		end

		local char = LocalPlayer.Character
		if not (char and char:FindFirstChild("HumanoidRootPart")) then return end
		local hrp = char.HumanoidRootPart
		local newPos = hrp.CFrame * CFrame.new(0, 0, -5) -- 5 stud di depan player

		if target:IsA("BasePart") then
			bringStates[target] = {
				CFrame = target.CFrame,
				Anchored = target.Anchored
			}
			target.Anchored = false
			target.CFrame = newPos
		elseif target:IsA("Model") and target.PrimaryPart then
			local savedAnchors = {}
			for _, part in ipairs(target:GetDescendants()) do
				if part:IsA("BasePart") then
					savedAnchors[part] = part.Anchored
					part.Anchored = false
				end
			end
			bringStates[target] = {
				CFrame = target.PrimaryPart.CFrame,
				AnchoredParts = savedAnchors
			}
			target:SetPrimaryPartCFrame(newPos)
		end
		return true
	end
end

-- ==========================
-- [HEADER BUTTON] SPD Toggle
-- ==========================
local SPDLevel = 0 -- 0 = off, 1–5 aktif
local NormalWalkSpeed = 16 -- default Roblox WalkSpeed

-- Helper: apply SPD ke humanoid
local function applySPD()
	local character = LocalPlayer.Character
	if not character then return end
	local hum = character:FindFirstChildOfClass("Humanoid")
	if not hum then return end

	if SPDLevel == 0 then
		hum.WalkSpeed = NormalWalkSpeed
	else
		-- rumus: normal * (2^SPDLevel)
		hum.WalkSpeed = NormalWalkSpeed * (2 ^ SPDLevel)
	end
end

-- Toggle SPD
local function toggleSPD(btn)
	SPDLevel = SPDLevel + 1
	if SPDLevel > 5 then
		SPDLevel = 0 -- balik ke off
	end

	-- update tombol
	if SPDLevel == 0 then
		btn.Text = "SPD"
		btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50) -- abu
	else
		btn.Text = "SPD" .. tostring(SPDLevel)
		btn.BackgroundColor3 = Color3.fromRGB(70, 170, 70) -- hijau
	end

	-- apply ke humanoid
	applySPD()
end

-- Hubungkan ke tombol SPD di header
buttonObjects["SPD"].MouseButton1Click:Connect(function()
	toggleSPD(buttonObjects["SPD"])
end)

-- Reapply SPD saat respawn
LocalPlayer.CharacterAdded:Connect(function(char)
	char:WaitForChild("Humanoid")
	applySPD()
end)

-- ==================================
-- [PRO] Highlight + Jump Mode + Kebal (2x klik)
-- ==================================
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local mouse = LocalPlayer:GetMouse()

local proActive = false
local proConn = {}
local activeHighlight = nil
local selectedPart = nil
local selectedPos = nil

-- helper: parabola jump ke targetPos
local function jumpTo(targetPos)
	local char = LocalPlayer.Character
	if not (char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid")) then return end
	local hrp = char.HumanoidRootPart
	local hum = char.Humanoid

	local startPos = hrp.Position
	local endPos = targetPos + Vector3.new(0,3,0)
	local distance = (endPos - startPos).Magnitude
	local duration = math.clamp(distance / 60, 0.6, 2)
	local peakHeight = math.max(8, distance / 3)

	local lookDir = (Vector3.new(endPos.X, startPos.Y, endPos.Z) - startPos).Unit
	hum.AutoRotate = false
	hrp.CFrame = CFrame.new(startPos, startPos + lookDir)

	local startTime = tick()
	task.spawn(function()
		while true do
			local t = (tick() - startTime) / duration
			if t > 1 then break end
			local pos = startPos:Lerp(endPos, t)
			local height = -4 * peakHeight * (t - 0.5)^2 + peakHeight
			pos = Vector3.new(pos.X, pos.Y + height, pos.Z)
			hrp.CFrame = CFrame.new(pos, pos + lookDir)
			RunService.Heartbeat:Wait()
		end
		hrp.CFrame = CFrame.new(endPos, endPos + lookDir)
		hum.AutoRotate = true
	end)
end

-- helper: ray dari mouse
local function getMouseTarget()
	if mouse.Target then
		return mouse.Target, mouse.Hit.Position
	end
	return nil, nil
end

-- ganti highlight ke part baru
local function setHighlight(part)
	if activeHighlight then
		activeHighlight:Destroy()
		activeHighlight = nil
	end
	selectedPart = nil
	selectedPos = nil

	if part and part:IsA("BasePart") then
		local hl = Instance.new("Highlight")
		hl.Adornee = part
		hl.FillColor = Color3.fromRGB(0, 170, 255) -- biru
		hl.FillTransparency = 0.6
		hl.OutlineColor = Color3.fromRGB(255, 255, 255)
		hl.OutlineTransparency = 0
		hl.Parent = part
		activeHighlight = hl

		selectedPart = part
		selectedPos = part.Position
	end
end

-- matikan PRO secara paksa
local function disablePRO()
	for _, c in ipairs(proConn) do
		c:Disconnect()
	end
	proConn = {}

	if activeHighlight then
		activeHighlight:Destroy()
		activeHighlight = nil
	end
	selectedPart, selectedPos = nil, nil

	local char = LocalPlayer.Character
	if char and char:FindFirstChild("PRO_ForceField") then
		char.PRO_ForceField:Destroy()
	end

	proActive = false
end

-- toggle PRO mode
function togglePRO()
	-- kalau lagi aktif, matikan dulu
	if proActive then
		disablePRO()
		return false
	end

	proActive = true

	-- kasih ForceField biar kebal
	local char = LocalPlayer.Character
	if char then
		local ff = Instance.new("ForceField")
		ff.Name = "PRO_ForceField"
		ff.Parent = char
	end

	-- klik logic (2 tahap)
	table.insert(proConn, mouse.Button1Down:Connect(function()
		local part, pos = getMouseTarget()
		if not part then return end

		if selectedPart and part == selectedPart then
			-- klik kedua di part yg sama -> lompat
			jumpTo(pos)
			-- reset selection biar bisa pilih ulang
			if activeHighlight then activeHighlight:Destroy() end
			activeHighlight = nil
			selectedPart, selectedPos = nil, nil
		else
			-- klik pertama atau klik beda part -> ganti highlight
			setHighlight(part)
		end
	end))

	return true
end

-- ============ Tambahan: Auto disable ketika respawn ============
LocalPlayer.CharacterAdded:Connect(function()
	if proActive then
		disablePRO()
		buttonObjects["PRO"].BackgroundColor3 = Color3.fromRGB(50,50,50) -- abu off
	end
end)


-- tombol header PRO
buttonObjects["PRO"].MouseButton1Click:Connect(function()
	local active = togglePRO()
	if active then
		buttonObjects["PRO"].BackgroundColor3 = Color3.fromRGB(70,170,70) -- hijau aktif
	else
		buttonObjects["PRO"].BackgroundColor3 = Color3.fromRGB(50,50,50) -- abu off
	end
end)

-- ==================================
-- [BLCK] Auto-block generator (toggle)
-- ==================================
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local blockActive = false
local blockConnections = {}
local activeBlocks = {}
local lastBlockTime = 0
local blockCooldown = 0.3
local landedBlockActive = false
local lastLandedPos = nil
local specialBlockActive = false

-- helper: register block biar bisa dihapus nanti
local function trackBlock(block, lifetime)
	table.insert(activeBlocks, block)
	if lifetime then
		task.delay(lifetime, function()
			if block and block.Parent and blockActive then
				block:Destroy()
			end
		end)
	end
end

-- helper: bikin block biasa (abu-abu)
local function createBlock(char)
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	local block = Instance.new("Part")
	block.Size = Vector3.new(5, 0.1, 5)
	block.Anchored = true
	block.CanCollide = true
	block.BrickColor = BrickColor.new("Medium stone grey")
	block.Transparency = 0.9
	block.CFrame = CFrame.new(hrp.Position.X, hrp.Position.Y - 3, hrp.Position.Z)
	block.Parent = workspace
	trackBlock(block, 2)
end

-- helper: bikin block landed (biru / kuning)
local function createLandedBlock(char)
	if landedBlockActive then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local landedPos = Vector3.new(
		math.floor(hrp.Position.X/5),
		0,
		math.floor(hrp.Position.Z/5)
	)

	if lastLandedPos and (landedPos - lastLandedPos).Magnitude < 1 then
		if specialBlockActive then return end
		specialBlockActive = true
		local special = Instance.new("Part")
		special.Size = Vector3.new(900, 0.1, 900)
		special.Anchored = true
		special.CanCollide = true
		special.BrickColor = BrickColor.new("Really blue")
		special.Transparency = 0.9
		special.CFrame = CFrame.new(hrp.Position.X, hrp.Position.Y - 5.8, hrp.Position.Z)
		special.Parent = workspace
		trackBlock(special) -- manual destroy
		task.delay(5, function()
			if special and special.Parent then
				special:Destroy()
			end
			specialBlockActive = false
		end)
	else
		landedBlockActive = true
		local block = Instance.new("Part")
		block.Size = Vector3.new(5, 0.1, 5)
		block.Anchored = true
		block.CanCollide = true
		block.BrickColor = BrickColor.new("Bright yellow")
		block.Transparency = 0.9
		block.CFrame = CFrame.new(hrp.Position.X, hrp.Position.Y - 5.8, hrp.Position.Z)
		block.Parent = workspace
		trackBlock(block, 2)
		task.delay(1, function()
			landedBlockActive = false
		end)
	end

	lastLandedPos = landedPos
end

-- helper: pasang touched listener
local function hookTouchedOnPart(part, char, hum)
	if not part:IsA("BasePart") then return end
	local conn = part.Touched:Connect(function(hit)
		if not blockActive or specialBlockActive then return end
		if not hit or not hit:IsA("BasePart") or not hit.CanCollide then return end
		if hit:IsDescendantOf(char) then return end
		if hum and hum.FloorMaterial ~= Enum.Material.Air then return end
		local now = tick()
		if now - lastBlockTime < blockCooldown then return end
		lastBlockTime = now
		createBlock(char)
	end)
	table.insert(blockConnections, conn)
end

-- toggle BLCK mode
function toggleBLCK()
	-- kalau udah aktif → matikan
	if blockActive then
		blockActive = false
		for _,c in ipairs(blockConnections) do c:Disconnect() end
		table.clear(blockConnections)

		-- hancurin semua block
		for _,b in ipairs(activeBlocks) do
			if b and b.Parent then
				b:Destroy()
			end
		end
		table.clear(activeBlocks)

		return false
	end

	-- aktifkan BLCK
	blockActive = true
	local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local hum = char:WaitForChild("Humanoid")

	-- cleanup dulu
	for _,c in ipairs(blockConnections) do c:Disconnect() end
	table.clear(blockConnections)

	-- pasang listener touched di semua part tubuh
	for _,d in ipairs(char:GetDescendants()) do
		if d:IsA("BasePart") then
			hookTouchedOnPart(d, char, hum)
		end
	end

	-- deteksi landed
	table.insert(blockConnections, hum.StateChanged:Connect(function(_, new)
		if not blockActive or specialBlockActive then return end
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

	return true
end

-- sambungkan ke button header BLCK
buttonObjects["BLCK"].MouseButton1Click:Connect(function()
	local active = toggleBLCK()
	buttonObjects["BLCK"].BackgroundColor3 = active and Color3.fromRGB(70,170,70) or Color3.fromRGB(50,50,50)
end)

-- ==================================
-- [TOW] Tower Truss (toggle via button)
-- ==================================
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local towerActive = false
local truss
local growing = false
local lastClimbTime = 0
local runConn
local cleanupToken = 0 -- untuk batalkan timer saat re-toggle OFF/ON

-- helper: destroy truss
local function destroyTruss()
	if truss then
		truss:Destroy()
		truss = nil
	end
	if runConn then
		runConn:Disconnect()
		runConn = nil
	end
end

-- toggle tower mode
function toggleTOW()
	-- kalau udah aktif → matikan
	if towerActive then
		towerActive = false
		growing = false

		-- mulai countdown 15 detik → auto hapus kalau nggak diaktifin lagi
		cleanupToken += 1
		local myToken = cleanupToken
		task.delay(15, function()
			if myToken == cleanupToken then
				destroyTruss()
			end
		end)

		return false
	end

	-- aktifkan tower
	towerActive = true
	local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local hrp = char:WaitForChild("HumanoidRootPart")

	-- batalkan countdown
	cleanupToken += 1

	-- bikin truss baru kalau belum ada
	if not truss then
		truss = Instance.new("TrussPart")
		truss.Size = Vector3.new(5, 20, 1)
		truss.Anchored = true
		truss.Name = "TowerTruss"
		truss.Parent = workspace
	end

	-- posisikan truss 1 stud di depan player, dasar tetap di bawah
	truss.CFrame = CFrame.new(
		(hrp.Position + hrp.CFrame.LookVector * 1) - Vector3.new(0, truss.Size.Y/2, 0)
	)

	growing = true
	lastClimbTime = tick()

	if not runConn then
		runConn = RunService.Heartbeat:Connect(function()
			if not truss then return end
			local c = LocalPlayer.Character
			local hum = c and c:FindFirstChildOfClass("Humanoid")
			if not hum then return end

			if growing then
				if hum:GetState() == Enum.HumanoidStateType.Climbing then
					lastClimbTime = tick()
					local head = c:FindFirstChild("Head")
					if head then
						local topY = truss.Position.Y + (truss.Size.Y * 0.5)
						local gap = topY - head.Position.Y
						if gap <= 5 then
							-- tambah tinggi 10, geser center +5 agar dasar tetap
							truss.Size = Vector3.new(truss.Size.X, truss.Size.Y + 10, truss.Size.Z)
							truss.Position = truss.Position + Vector3.new(0, 5, 0)
						end
					end
				else
					-- auto hilang kalau nggak dipanjat > 10 detik
					if tick() - lastClimbTime > 10 then
						destroyTruss()
					end
				end
			end
		end)
	end

	return true
end

-- sambungkan ke button header TOW
buttonObjects["TOW"].MouseButton1Click:Connect(function()
	local active = toggleTOW()
	buttonObjects["TOW"].BackgroundColor3 = active and Color3.fromRGB(70,170,70) or Color3.fromRGB(50,50,50)
end)

-- ==================================
-- [VISION] X-Ray Mode (toggle via button)
-- ==================================
local visionActive = false
local originalStates = {}

function toggleVISION()
	if visionActive then
		-- OFF: balikin semua property
		for obj, state in pairs(originalStates) do
			if obj and obj.Parent then
				obj.Transparency = state.Transparency
				obj.Color = state.Color
			end
		end
		originalStates = {}
		visionActive = false
		return false
	else
		-- ON: simpan property dan ubah tampilan
		originalStates = {}

		for _, obj in ipairs(workspace:GetDescendants()) do
			if obj:IsA("BasePart") and obj.Name ~= "HumanoidRootPart" then
				-- simpan kondisi asli
				originalStates[obj] = {
					Transparency = obj.Transparency,
					Color = obj.Color,
				}

				-- aturan vision
				if obj.Transparency == 1 then
					obj.Transparency = 0
				end
				if obj.CanCollide == true then
					obj.Color = Color3.fromRGB(0,255,0)
				end
			end
		end

		visionActive = true
		return true
	end
end

-- Hubungkan ke button header VISION
buttonObjects["VISION"].MouseButton1Click:Connect(function()
	local active = toggleVISION()
	buttonObjects["VISION"].BackgroundColor3 =
		active and Color3.fromRGB(70,170,70) or Color3.fromRGB(50,50,50)
end)

-- ==================================
-- [FREEZE] Freeze Mode (toggle via button)
-- ==================================
local freezeActive = false
local freezeStates = {}

function toggleFREEZE()
	if freezeActive then
		-- OFF: kembalikan kondisi semula
		for obj, state in pairs(freezeStates) do
			if obj and obj.Parent then
				obj.Anchored = state.Anchored
				obj.CustomPhysicalProperties = state.CustomPhysicalProperties
				obj.TopSurface = state.Surfaces.Top
				obj.BottomSurface = state.Surfaces.Bottom
				obj.LeftSurface = state.Surfaces.Left
				obj.RightSurface = state.Surfaces.Right
				obj.FrontSurface = state.Surfaces.Front
				obj.BackSurface = state.Surfaces.Back

				-- enable kembali constraint yang sempat dimatikan
				for _, inst in ipairs(state.DisabledInstances) do
					if inst and inst.Parent then
						if inst:IsA("Constraint") then
							inst.Enabled = true
						end
					end
				end
			end
		end
		freezeStates = {}
		freezeActive = false
		return false
	else
		-- ON: freeze semua BasePart (kecuali player/humanoid)
		freezeStates = {}

		for _, obj in ipairs(workspace:GetDescendants()) do
			if obj:IsA("BasePart") then
				local model = obj:FindFirstAncestorOfClass("Model")
				-- skip player/humanoid
				if not (model and model:FindFirstChildOfClass("Humanoid")) then
					-- simpan state lama
					freezeStates[obj] = {
						Anchored = obj.Anchored,
						CustomPhysicalProperties = obj.CustomPhysicalProperties,
						Surfaces = {
							Top = obj.TopSurface,
							Bottom = obj.BottomSurface,
							Left = obj.LeftSurface,
							Right = obj.RightSurface,
							Front = obj.FrontSurface,
							Back = obj.BackSurface,
						},
						DisabledInstances = {} -- untuk constraint/bodymover
					}

					-- freeze part
					obj.Anchored = true
					obj.Velocity = Vector3.zero
					obj.RotVelocity = Vector3.zero
					obj.CustomPhysicalProperties = PhysicalProperties.new(0, 1, 0, 100, 100)

					-- bikin climbable
					obj.TopSurface = Enum.SurfaceType.Studs
					obj.BottomSurface = Enum.SurfaceType.Studs
					obj.LeftSurface = Enum.SurfaceType.Studs
					obj.RightSurface = Enum.SurfaceType.Studs
					obj.FrontSurface = Enum.SurfaceType.Studs
					obj.BackSurface = Enum.SurfaceType.Studs

					-- disable constraint & bodymover
					for _, child in ipairs(obj:GetChildren()) do
						if child:IsA("BodyMover") or child:IsA("Constraint") then
							if child:IsA("Constraint") and child.Enabled then
								table.insert(freezeStates[obj].DisabledInstances, child)
								child.Enabled = false
							elseif child:IsA("BodyMover") then
								table.insert(freezeStates[obj].DisabledInstances, child)
								child.Archivable = false -- tandai agar tidak restore baru
								child:Destroy() -- hapus biar ga paksa gerak
							end
						end
					end
				end
			end
		end

		freezeActive = true
		return true
	end
end

-- Hubungkan ke button header FREEZE
buttonObjects["FREEZE"].MouseButton1Click:Connect(function()
	local active = toggleFREEZE()
	buttonObjects["FREEZE"].BackgroundColor3 =
		active and Color3.fromRGB(70,170,70) or Color3.fromRGB(50,50,50)
end)

-- ==================================
-- [PIL] Glow Light Mode
-- ==================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local pilActive = false
local lightRef = nil

-- enable glow
local function enablePIL()
	local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local hrp = char:WaitForChild("HumanoidRootPart")

	-- bikin lampu
	local light = Instance.new("PointLight")
	light.Name = "PIL_Light"
	light.Color = Color3.fromRGB(0, 200, 255) -- biru cerah
	light.Brightness = 5 -- seberapa terang
	light.Range = 20 -- radius cahaya
	light.Shadows = true
	light.Parent = hrp

	lightRef = light
	pilActive = true
end

-- disable glow
local function disablePIL()
	if lightRef and lightRef.Parent then
		lightRef:Destroy()
	end
	lightRef = nil
	pilActive = false
end

-- toggle
local function togglePIL()
	if pilActive then
		disablePIL()
	else
		enablePIL()
	end
	return pilActive
end

-- tombol binding
buttonObjects["PIL"].MouseButton1Click:Connect(function()
	local active = togglePIL()
	buttonObjects["PIL"].BackgroundColor3 =
		active and Color3.fromRGB(70,170,70) or Color3.fromRGB(50,50,50)
end)

-- respawn handling
Players.LocalPlayer.CharacterAdded:Connect(function()
	if pilActive then
		task.wait(1)
		enablePIL()
	end
end)

-- ==================================
-- [RVSE] Reverse (15 detik via button)
-- ==================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local buffer = {} -- simpan CFrame
local maxSeconds = 15
local fps = 60
local maxFrames = maxSeconds * fps
local recording = true
local reverseActive = false
local hrp
local conn

-- rekam posisi tiap RenderStepped
local function startRecording()
	if conn then conn:Disconnect() end
	conn = RunService.RenderStepped:Connect(function()
		local char = LocalPlayer.Character
		hrp = char and char:FindFirstChild("HumanoidRootPart")
		if recording and hrp then
			table.insert(buffer, hrp.CFrame)
			if #buffer > maxFrames then
				table.remove(buffer, 1) -- buang frame paling lama
			end
		end
	end)
end

local function stopRecording()
	if conn then
		conn:Disconnect()
		conn = nil
	end
end

-- toggle reverse
local function toggleReverse()
	if reverseActive then
		-- OFF
		reverseActive = false
		recording = true
		return false
	else
		-- ON (jalankan reverse)
		local char = LocalPlayer.Character
		hrp = char and char:FindFirstChild("HumanoidRootPart")
		if not hrp then return false end

		recording = false
		reverseActive = true

		task.spawn(function()
			local startTime = tick()
			for i = #buffer, 1, -1 do
				if not reverseActive or not hrp then break end
				hrp.CFrame = buffer[i]
				task.wait(1/fps)

				-- cek auto-off kalau sudah 15 detik
				if tick() - startTime >= maxSeconds then
					reverseActive = false
					recording = true
					break
				end
			end

			-- pastikan tombol balik abu-abu
			buttonObjects["RVSE"].BackgroundColor3 = Color3.fromRGB(50,50,50)

			reverseActive = false
			recording = true
		end)

		return true
	end
end

-- mulai rekam otomatis
startRecording()

-- Hubungkan ke button header RVSE
buttonObjects["RVSE"].MouseButton1Click:Connect(function()
	local active = toggleReverse()
	buttonObjects["RVSE"].BackgroundColor3 =
		active and Color3.fromRGB(70,170,70) or Color3.fromRGB(50,50,50)
end)

-- ==================================
-- [GHOST] Ruh Mode (Clone Control + Mobile UI)
-- ==================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local ghostActive = false
local ghostClone
local moveConnection
local speed = 1.5

-- simpan data asli
local originalWalkSpeed, originalJumpPower

-- input state
local moveState = {Up=false,Down=false,Left=false,Right=false,Ascend=false,Descend=false}
local kbState   = {Up=false,Down=false,Left=false,Right=false,Ascend=false,Descend=false}

-- UI arah (mobile)
local GhostGui = Instance.new("ScreenGui")
GhostGui.Name = "GhostUI"
GhostGui.ResetOnSpawn = false
GhostGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MoveFrame = Instance.new("Frame")
MoveFrame.Size = UDim2.new(0, 150, 0, 150)
MoveFrame.Position = UDim2.new(1, -170, 1, -170) -- pojok kanan bawah
MoveFrame.BackgroundTransparency = 1
MoveFrame.Visible = false
MoveFrame.Parent = GhostGui

local function makeBtn(txt, pos)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 40, 0, 40)
	btn.Position = pos
	btn.Text = txt
	btn.TextColor3 = Color3.new(1,1,1)
	btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
	btn.BackgroundTransparency = 0.3
	btn.Font = Enum.Font.SourceSansBold
	btn.TextScaled = true
	btn.Parent = MoveFrame
	return btn
end

local BtnUp     = makeBtn("↑", UDim2.new(0.33, 0, 0, 0))
local BtnDown   = makeBtn("↓", UDim2.new(0.33, 0, 0, 80))
local BtnLeft   = makeBtn("←", UDim2.new(0, 0, 0, 40))
local BtnRight  = makeBtn("→", UDim2.new(0.66, 0, 0, 40))
local BtnAscend = makeBtn("⤒", UDim2.new(0.33, 0, 0, -40))
local BtnDesc   = makeBtn("⤓", UDim2.new(0.33, 0, 0, 120))

local function bindBtn(btn, key)
	btn.MouseButton1Down:Connect(function() moveState[key] = true end)
	btn.MouseButton1Up:Connect(function() moveState[key] = false end)
	btn.MouseLeave:Connect(function() moveState[key] = false end)
end
bindBtn(BtnUp,"Up")
bindBtn(BtnDown,"Down")
bindBtn(BtnLeft,"Left")
bindBtn(BtnRight,"Right")
bindBtn(BtnAscend,"Ascend")
bindBtn(BtnDesc,"Descend")

-- Keyboard PC
UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe or not ghostActive then return end
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

-- toggle ghost
local function toggleGhost()
	if ghostActive then
		-- OFF
		ghostActive = false
		MoveFrame.Visible = false
		if moveConnection then moveConnection:Disconnect() moveConnection=nil end
		if ghostClone then ghostClone:Destroy() ghostClone=nil end

		-- kamera balik
		local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if hum then
			Camera.CameraSubject = hum
			hum.WalkSpeed = originalWalkSpeed or 16
			hum.JumpPower = originalJumpPower or 50
		end
		return false
	else
		-- ON
		local char = LocalPlayer.Character
		if not char or not char:FindFirstChild("HumanoidRootPart") then return false end
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then
			originalWalkSpeed = hum.WalkSpeed
			originalJumpPower = hum.JumpPower
			hum.WalkSpeed = 0
			hum.JumpPower = 0
		end

		-- clone ghost
		char.Archivable = true
		ghostClone = char:Clone()
		ghostClone.Name = LocalPlayer.Name.."_GHOST"
		for _, part in ipairs(ghostClone:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
				part.Anchored = true
				part.Transparency = 0.5
			end
		end
		ghostClone.Parent = workspace
		ghostClone:SetPrimaryPartCFrame(char.HumanoidRootPart.CFrame * CFrame.new(0,0,-5))

		-- kamera pindah
		local ghostHum = ghostClone:FindFirstChildOfClass("Humanoid")
		if ghostHum then
			Camera.CameraSubject = ghostHum
		else
			Camera.CameraSubject = ghostClone.PrimaryPart
		end

		-- kontrol
		moveConnection = RunService.RenderStepped:Connect(function()
			if not ghostActive or not ghostClone or not ghostClone.PrimaryPart then return end
			local moveDir = Vector3.new()
			-- mobile UI
			if moveState.Up then moveDir += Camera.CFrame.LookVector end
			if moveState.Down then moveDir -= Camera.CFrame.LookVector end
			if moveState.Left then moveDir -= Camera.CFrame.RightVector end
			if moveState.Right then moveDir += Camera.CFrame.RightVector end
			if moveState.Ascend then moveDir += Vector3.new(0,1,0) end
			if moveState.Descend then moveDir -= Vector3.new(0,1,0) end
			-- keyboard
			if kbState.Up then moveDir += Camera.CFrame.LookVector end
			if kbState.Down then moveDir -= Camera.CFrame.LookVector end
			if kbState.Left then moveDir -= Camera.CFrame.RightVector end
			if kbState.Right then moveDir += Camera.CFrame.RightVector end
			if kbState.Ascend then moveDir += Vector3.new(0,1,0) end
			if kbState.Descend then moveDir -= Vector3.new(0,1,0) end

			local root = ghostClone.PrimaryPart
			local pos = root.Position
			local look = Camera.CFrame.LookVector
			local baseCF = CFrame.new(pos,pos+look) -- hadap POV kamera

			if moveDir.Magnitude > 0 then
				ghostClone:SetPrimaryPartCFrame(baseCF + (moveDir.Unit * speed))
			else
				ghostClone:SetPrimaryPartCFrame(baseCF)
			end
		end)

		MoveFrame.Visible = true
		ghostActive = true
		return true
	end
end

-- Hubungkan ke button header GHOST
buttonObjects["GHOST"].MouseButton1Click:Connect(function()
	local active = toggleGhost()
	buttonObjects["GHOST"].BackgroundColor3 =
		active and Color3.fromRGB(70,170,70) or Color3.fromRGB(50,50,50)
end)

-- ==========================
-- HISTORY FEATURE
-- ==========================
local historyList = {}

-- fungsi tambah ke history (recent di atas, tanpa duplikat)
local function addHistory(text)
	if text == "" then return end
	-- hapus kalau sudah ada
	for i, v in ipairs(historyList) do
		if v == text then
			table.remove(historyList, i)
			break
		end
	end
	-- masukkan ke paling depan (atas)
	table.insert(historyList, 1, text)
end

-- fungsi tampilkan history
local function showHistory()
	resultsFrame.Visible = true
	resultsFrame:ClearAllChildren()

	local itemHeight = 22
	local padding = 2
	local maxVisible = 10
	local totalItems = #historyList

	for i, entry in ipairs(historyList) do
		local itemFrame = Instance.new("Frame")
		itemFrame.Size = UDim2.new(1, -5, 0, itemHeight)
		itemFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
		itemFrame.BorderSizePixel = 1
		itemFrame.BorderColor3 = Color3.fromRGB(80,80,80)
		itemFrame.Position = UDim2.new(0, 0, 0, (i-1)*(itemHeight + padding))
		itemFrame.Parent = resultsFrame

		local nameLabel = Instance.new("TextLabel")
		nameLabel.Size = UDim2.new(0.7, 0, 1, 0)
		nameLabel.BackgroundTransparency = 1
		nameLabel.TextColor3 = Color3.fromRGB(255,255,255)
		nameLabel.Font = Enum.Font.SourceSans
		nameLabel.TextSize = 14
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.Text = entry
		nameLabel.Parent = itemFrame

		local selectBtn = Instance.new("TextButton")
		selectBtn.Size = UDim2.new(0.3, -4, 1, -4)
		selectBtn.Position = UDim2.new(0.7, 2, 0, 2)
		selectBtn.BackgroundColor3 = Color3.fromRGB(70,120,70)
		selectBtn.Text = "Select"
		selectBtn.TextColor3 = Color3.fromRGB(255,255,255)
		selectBtn.Font = Enum.Font.SourceSansBold
		selectBtn.TextSize = 12
		selectBtn.Parent = itemFrame

		selectBtn.MouseButton1Click:Connect(function()
			inputBox.Text = entry
		end)
	end

	resultsFrame.CanvasSize = UDim2.new(0, 0, 0, totalItems * (itemHeight + padding))
	local visibleCount = math.min(totalItems, maxVisible)
	resultsFrame.Size = UDim2.new(1, 0, 0, visibleCount * (itemHeight + padding))
	resultsFrame.ScrollBarThickness = 6
	resultsFrame.ScrollBarImageColor3 = Color3.fromRGB(180,180,180)
end

-- ==========================
-- Integrasi ke button
-- ==========================
searchBtn.MouseButton1Click:Connect(function()
	local query = inputBox.Text
	addHistory(query) -- simpan ke history
	-- existing logic search
	local base, keyword = string.match(query, "^(.-):(.*)$")
	if base == "Workspace" then
		scanWorkspace(keyword)
	elseif base == "Players" then
		scanPlayers(keyword)
	else
		resultsFrame.Visible = false
	end
end)

flagBtn.MouseButton1Click:Connect(function()
	local text = inputBox.Text
	if text == "" then
		text = "Teleport"
	end
	addHistory(text) -- simpan ke history
	spawnFlag(text)
end)

-- ==========================
-- Integrasi ke label "history"
-- ==========================
for _, child in ipairs(content:GetChildren()) do
	if child:IsA("TextButton") and child.Text == "history" then
		child.MouseButton1Click:Connect(function()
			showHistory()
		end)
	end
end
