-- Floating UI + Infinite Jump (Natural Jump, works for PC & Mobile)
-- Client-Side Only - LocalScript di StarterPlayerScripts

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- GUI setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FloatingUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true -- Memastikan posisi GUI konsisten
screenGui.Parent = playerGui

local panel = Instance.new("Frame")
panel.Name = "MainPanel"
panel.Size = UDim2.new(0, 160, 0, 60)
panel.Position = UDim2.new(0.05, 0, 0.7, 0)
panel.BackgroundColor3 = Color3.fromRGB(0,0,0)
panel.BackgroundTransparency = 0.3
panel.Active = true
panel.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = panel

local title = Instance.new("TextLabel")
title.Text = "Tools"
title.Size = UDim2.new(1, -10, 0, 20)
title.Position = UDim2.new(0, 5, 0, 3)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255,255,255)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.SourceSansBold
title.TextSize = 14
title.Parent = panel

-- Vision Button
local visionBtn = Instance.new("TextButton")
visionBtn.Name = "VisionButton"
visionBtn.Size = UDim2.new(0, 70, 0, 28)
visionBtn.Position = UDim2.new(0, 8, 0, 28)
visionBtn.Text = "Vision"
visionBtn.BackgroundColor3 = Color3.fromRGB(120,120,120)
visionBtn.TextColor3 = Color3.new(1,1,1)
visionBtn.Font = Enum.Font.SourceSans
visionBtn.TextSize = 14
visionBtn.Parent = panel
local vc = Instance.new("UICorner", visionBtn)
vc.CornerRadius = UDim.new(0,8)

-- Jump Button
local jumpBtn = Instance.new("TextButton")
jumpBtn.Name = "JumpButton"
jumpBtn.Size = UDim2.new(0, 70, 0, 28)
jumpBtn.Position = UDim2.new(0, 82, 0, 28)
jumpBtn.Text = "Jump"
jumpBtn.BackgroundColor3 = Color3.fromRGB(120,120,120)
jumpBtn.TextColor3 = Color3.new(1,1,1)
jumpBtn.Font = Enum.Font.SourceSans
jumpBtn.TextSize = 14
jumpBtn.Parent = panel
local jc = Instance.new("UICorner", jumpBtn)
jc.CornerRadius = UDim.new(0,8)

-- Selection Menu
local selectionMenu = Instance.new("Frame")
selectionMenu.Name = "SelectionMenu"
selectionMenu.Size = UDim2.new(0, 150, 0, 100)
selectionMenu.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
selectionMenu.BorderSizePixel = 0
selectionMenu.Visible = false
selectionMenu.Parent = screenGui

local selectionCorner = Instance.new("UICorner")
selectionCorner.CornerRadius = UDim.new(0, 8)
selectionCorner.Parent = selectionMenu

local bringBtn = Instance.new("TextButton")
bringBtn.Name = "BringButton"
bringBtn.Size = UDim2.new(0, 130, 0, 25)
bringBtn.Position = UDim2.new(0, 10, 0, 10)
bringBtn.Text = "Bring"
bringBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
bringBtn.TextColor3 = Color3.new(1,1,1)
bringBtn.Font = Enum.Font.SourceSans
bringBtn.TextSize = 14
bringBtn.Parent = selectionMenu
local bringCorner = Instance.new("UICorner", bringBtn)
bringCorner.CornerRadius = UDim.new(0, 4)

local deleteBtn = Instance.new("TextButton")
deleteBtn.Name = "DeleteButton"
deleteBtn.Size = UDim2.new(0, 130, 0, 25)
deleteBtn.Position = UDim2.new(0, 10, 0, 40)
deleteBtn.Text = "Delete"
deleteBtn.BackgroundColor3 = Color3.fromRGB(215, 0, 0)
deleteBtn.TextColor3 = Color3.new(1,1,1)
deleteBtn.Font = Enum.Font.SourceSans
deleteBtn.TextSize = 14
deleteBtn.Parent = selectionMenu
local deleteCorner = Instance.new("UICorner", deleteBtn)
deleteCorner.CornerRadius = UDim.new(0, 4)

local closeBtn = Instance.new("TextButton")
closeBtn.Name = "CloseButton"
closeBtn.Size = UDim2.new(0, 130, 0, 25)
closeBtn.Position = UDim2.new(0, 10, 0, 70)
closeBtn.Text = "Close"
closeBtn.BackgroundColor3 = Color3.fromRGB(120, 120, 120)
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Font = Enum.Font.SourceSans
closeBtn.TextSize = 14
closeBtn.Parent = selectionMenu
local closeCorner = Instance.new("UICorner", closeBtn)
closeCorner.CornerRadius = UDim.new(0, 4)

-- Attribute system
if jumpBtn:GetAttribute("Active") == nil then jumpBtn:SetAttribute("Active", false) end
if visionBtn:GetAttribute("Active") == nil then visionBtn:SetAttribute("Active", false) end

-- Vision mode variables
local originalTransparency = {}
local originalColors = {}
local selectedObject = nil
local selectedObjectOriginalColor = nil
local broughtObjects = {} -- Menyimpan posisi asli objek yang sudah di-"bring"

-- Double-click detection variables
local lastClickTime = 0
local lastClickedObject = nil
local doubleClickTimeLimit = 0.5

local function applyButtonVisual(btn)
	btn.BackgroundColor3 = (btn:GetAttribute("Active") and Color3.fromRGB(0,200,0)) or Color3.fromRGB(120,120,120)
end
applyButtonVisual(jumpBtn)
applyButtonVisual(visionBtn)

local function toggleButton(btn)
	local active = not (btn:GetAttribute("Active") or false)
	btn:SetAttribute("Active", active)
	applyButtonVisual(btn)
	return active
end

-- Drag system (mobile + pc)
local dragging, dragInput, dragStart, startPos
local function updateDrag(input)
	local delta = input.Position - dragStart
	panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

panel.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = panel.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then dragging = false end
		end)
	end
end)
panel.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if dragging and input == dragInput then updateDrag(input) end
end)

------------------------------------------------------------
-- INFINITE JUMP SYSTEM (natural height)
------------------------------------------------------------
local function setupInfiniteJumpForCharacter(character)
	local humanoid = character:WaitForChild("Humanoid")
	local debounce = false

	local function doJump()
		if not (jumpBtn:GetAttribute("Active") or false) then return end
		if debounce then return end
		debounce = true

		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		humanoid:Move(Vector3.zero)
		humanoid.Jump = true

		task.delay(0.2, function()
			debounce = false
		end)
	end

	UserInputService.JumpRequest:Connect(doJump)
	humanoid:GetPropertyChangedSignal("Jump"):Connect(function()
		if humanoid.Jump then
			doJump()
		end
	end)
end

------------------------------------------------------------
-- VISION SYSTEM
------------------------------------------------------------
local function toggleVisionMode()
	local isActive = toggleButton(visionBtn)

	if isActive then
		for _, obj in pairs(Workspace:GetDescendants()) do
			if obj:IsA("BasePart") then
				if originalTransparency[obj] == nil then
					originalTransparency[obj] = obj.Transparency
				end
				if originalColors[obj] == nil then
					originalColors[obj] = obj.Color
				end

				if obj.Name ~= "HumanoidRootPart" then
					obj.Transparency = 0
				end

				if obj.CanCollide then
					obj.Color = Color3.fromRGB(0, 255, 0)
				end
			end
		end
	else
		for obj, transparency in pairs(originalTransparency) do
			if obj and obj.Parent then
				obj.Transparency = transparency
			end
		end

		for obj, color in pairs(originalColors) do
			if obj and obj.Parent then
				obj.Color = color
			end
		end

		originalTransparency = {}
		originalColors = {}

		if selectedObject then
			selectedObject = nil
			selectedObjectOriginalColor = nil
		end
		selectionMenu.Visible = false
	end
end

-- Object selection with double-click
local function onObjectClick(object)
	if not visionBtn:GetAttribute("Active") then return end
	if not object:IsA("BasePart") then return end

	local currentTime = tick()

	if object == lastClickedObject and (currentTime - lastClickTime) < doubleClickTimeLimit then
		lastClickTime = 0
		lastClickedObject = nil

		if selectedObject and selectedObject.Parent then
			selectedObject.Color = selectedObjectOriginalColor
		end

		selectedObject = object
		selectedObjectOriginalColor = object.Color
		selectedObject.Color = Color3.fromRGB(255, 0, 0)

		selectionMenu.Visible = true
		selectionMenu.Position = UDim2.new(0, panel.AbsolutePosition.X + panel.AbsoluteSize.X + 10, 0, panel.AbsolutePosition.Y)

		-- Perbarui teks tombol "Bring" berdasarkan status objek
		if broughtObjects[selectedObject] then
			bringBtn.Text = "Unbring"
		else
			bringBtn.Text = "Bring"
		end

	else
		lastClickTime = currentTime
		lastClickedObject = object
	end
end

-- Bring/Unbring object (FUNGSI YANG DIPERBARUI)
local function bringObject()
	if not selectedObject or not selectedObject.Parent then return end

	-- Periksa apakah objek sudah pernah di-"bring" sebelumnya
	if broughtObjects[selectedObject] then
		-- Jika ya, kembalikan ke posisi asal (Unbring)
		selectedObject.CFrame = broughtObjects[selectedObject]
		-- Hapus dari penyimpanan untuk mereset statusnya
		broughtObjects[selectedObject] = nil
	else
		-- Jika tidak, simpan posisi sekarang dan pindahkan ke depan (Bring)
		broughtObjects[selectedObject] = selectedObject.CFrame

		local character = player.Character
		if character and character:FindFirstChild("HumanoidRootPart") then
			local hrp = character.HumanoidRootPart
			selectedObject.CFrame = hrp.CFrame + hrp.CFrame.LookVector * 5
		end
	end

	closeSelection()
end

-- Delete object
local function deleteObject()
	if not selectedObject or not selectedObject.Parent then return end

	if broughtObjects[selectedObject] then
		broughtObjects[selectedObject] = nil
	end

	originalTransparency[selectedObject] = nil
	originalColors[selectedObject] = nil

	selectedObject:Destroy()
	selectedObject = nil
	selectionMenu.Visible = false
end

-- Close selection
local function closeSelection()
	if selectedObject and selectedObject.Parent then
		selectedObject.Color = selectedObjectOriginalColor
	end
	selectedObject = nil
	selectedObjectOriginalColor = nil
	selectionMenu.Visible = false
end

-- Connect button events
bringBtn.MouseButton1Click:Connect(bringObject)
deleteBtn.MouseButton1Click:Connect(deleteObject)
closeBtn.MouseButton1Click:Connect(closeSelection)

-- Object click detection
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		local mouse = player:GetMouse()
		if mouse.Target then
			onObjectClick(mouse.Target)
		end
	end
end)

------------------------------------------------------------
-- CHARACTER EVENTS
------------------------------------------------------------
player.CharacterAdded:Connect(function(char)
	task.wait(0.5)
	setupInfiniteJumpForCharacter(char)
end)

if player.Character then
	task.delay(0.5, function()
		setupInfiniteJumpForCharacter(player.Character)
	end)
end

------------------------------------------------------------
-- BUTTON ACTIONS
------------------------------------------------------------
jumpBtn.MouseButton1Click:Connect(function()
	local isOn = toggleButton(jumpBtn)
	if isOn and player.Character then
		setupInfiniteJumpForCharacter(player.Character)
	end
end)

visionBtn.MouseButton1Click:Connect(toggleVisionMode)

-- Save vision state when player leaves
game:GetService("Players").PlayerRemoving:Connect(function(plr)
	if plr == player then
		player:SetAttribute("VisionActive", visionBtn:GetAttribute("Active"))
	end
end)

-- Restore vision state when player joins
if player:GetAttribute("VisionActive") then
	if player:GetAttribute("VisionActive") == true then
		task.wait(1)
		toggleVisionMode()
	end
end
