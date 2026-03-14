-- Floating UI + Infinite Jump
-- Client-Side Only - LocalScript

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-------------------------------------------------
-- GUI SETUP
-------------------------------------------------

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FloatingUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

local panel = Instance.new("Frame")
panel.Size = UDim2.new(0,160,0,60)
panel.Position = UDim2.new(0.05,0,0.7,0)
panel.BackgroundColor3 = Color3.fromRGB(0,0,0)
panel.BackgroundTransparency = 0.3
panel.Active = true
panel.Parent = screenGui

Instance.new("UICorner",panel).CornerRadius = UDim.new(0,12)

local title = Instance.new("TextLabel")
title.Text = "Tools"
title.Size = UDim2.new(1,-10,0,20)
title.Position = UDim2.new(0,5,0,3)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.SourceSansBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextSize = 14
title.Parent = panel

-------------------------------------------------
-- BUTTONS
-------------------------------------------------

local function createButton(name,text,x)

	local btn = Instance.new("TextButton")
	btn.Name = name
	btn.Size = UDim2.new(0,70,0,28)
	btn.Position = UDim2.new(0,x,0,28)
	btn.Text = text
	btn.BackgroundColor3 = Color3.fromRGB(120,120,120)
	btn.TextColor3 = Color3.new(1,1,1)
	btn.Font = Enum.Font.SourceSans
	btn.TextSize = 14
	btn.Parent = panel

	Instance.new("UICorner",btn).CornerRadius = UDim.new(0,8)

	return btn
end

local visionBtn = createButton("VisionButton","Vision",8)
local jumpBtn = createButton("JumpButton","Jump",82)

-------------------------------------------------
-- SELECTION MENU
-------------------------------------------------

local selectionMenu = Instance.new("Frame")
selectionMenu.Size = UDim2.new(0,150,0,160)
selectionMenu.BackgroundColor3 = Color3.fromRGB(40,40,40)
selectionMenu.BorderSizePixel = 0
selectionMenu.Visible = false
selectionMenu.Parent = screenGui

Instance.new("UICorner",selectionMenu).CornerRadius = UDim.new(0,8)

local function createMenuButton(text,y,color)

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0,130,0,25)
	btn.Position = UDim2.new(0,10,0,y)
	btn.Text = text
	btn.BackgroundColor3 = color
	btn.TextColor3 = Color3.new(1,1,1)
	btn.Font = Enum.Font.SourceSans
	btn.TextSize = 14
	btn.Parent = selectionMenu

	Instance.new("UICorner",btn).CornerRadius = UDim.new(0,4)

	return btn
end

local bringBtn = createMenuButton("Bring",10,Color3.fromRGB(0,120,215))
local teleportBtn = createMenuButton("Teleport",40,Color3.fromRGB(0,170,0))
local copyBtn = createMenuButton("Copy",70,Color3.fromRGB(255,170,0))
local pasteBtn = createMenuButton("Paste",100,Color3.fromRGB(120,120,255))
local deleteBtn = createMenuButton("Delete",130,Color3.fromRGB(215,0,0))

-------------------------------------------------
-- VARIABLES
-------------------------------------------------

visionBtn:SetAttribute("Active",false)
jumpBtn:SetAttribute("Active",false)

local originalTransparency = {}
local originalColors = {}

local selectedObject = nil
local selectedObjectOriginalColor = nil

local broughtObjects = {}
local copiedObject = nil

-------------------------------------------------
-- BUTTON VISUAL
-------------------------------------------------

local function toggleButton(btn)

	local active = not btn:GetAttribute("Active")
	btn:SetAttribute("Active",active)

	btn.BackgroundColor3 =
		active and Color3.fromRGB(0,200,0)
		or Color3.fromRGB(120,120,120)

	return active

end

-------------------------------------------------
-- DRAG PANEL
-------------------------------------------------

local dragging,dragStart,startPos

panel.InputBegan:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = panel.Position
	end

end)

panel.InputEnded:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end

end)

UserInputService.InputChanged:Connect(function(input)

	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then

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

local function setupInfiniteJump(character)

	local humanoid = character:WaitForChild("Humanoid")

	UserInputService.JumpRequest:Connect(function()

		if jumpBtn:GetAttribute("Active") then
			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end

	end)

end

-------------------------------------------------
-- VISION MODE
-------------------------------------------------

local function toggleVision()

	local active = toggleButton(visionBtn)

	if active then

		for _,obj in pairs(Workspace:GetDescendants()) do

			if obj:IsA("BasePart") then

				originalTransparency[obj] = obj.Transparency
				originalColors[obj] = obj.Color

				obj.Transparency = 0

				if obj.CanCollide then
					obj.Color = Color3.fromRGB(0,255,0)
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

		selectionMenu.Visible = false

	end

end

-------------------------------------------------
-- OBJECT CLICK
-------------------------------------------------

local lastClickTime = 0
local lastObject = nil

local function onObjectClick(object)

	if not visionBtn:GetAttribute("Active") then return end
	if not object:IsA("BasePart") then return end

	local time = tick()

	if object == lastObject and time-lastClickTime < 0.5 then

		if selectedObject then
			selectedObject.Color = selectedObjectOriginalColor
		end

		selectedObject = object
		selectedObjectOriginalColor = object.Color
		object.Color = Color3.fromRGB(255,0,0)

		selectionMenu.Visible = true
		selectionMenu.Position = UDim2.new(
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
		lastObject = object
		lastClickTime = time
	end

end

-------------------------------------------------
-- BRING / UNBRING
-------------------------------------------------

local function bringObject()

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

end

-------------------------------------------------
-- TELEPORT PLAYER
-------------------------------------------------

local function teleportToObject()

	if not selectedObject then return end

	local char = player.Character
	if not char then return end

	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local offset = selectedObject.Size.Y/2 + 3

	hrp.CFrame = CFrame.new(
		selectedObject.Position + Vector3.new(0,offset,0)
	)

end

-------------------------------------------------
-- COPY
-------------------------------------------------

local function copyObject()

	if not selectedObject then return end

	copiedObject = selectedObject:Clone()

end

-------------------------------------------------
-- PASTE
-------------------------------------------------

local function pasteObject()

	if not copiedObject then return end

	local char = player.Character
	if not char then return end

	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local clone = copiedObject:Clone()
	clone.Parent = Workspace

	clone.CFrame = hrp.CFrame + hrp.CFrame.LookVector*5

end

-------------------------------------------------
-- DELETE
-------------------------------------------------

local function deleteObject()

	if not selectedObject then return end

	selectedObject:Destroy()
	selectedObject = nil
	selectionMenu.Visible = false

end

-------------------------------------------------
-- EVENTS
-------------------------------------------------

bringBtn.MouseButton1Click:Connect(bringObject)
teleportBtn.MouseButton1Click:Connect(teleportToObject)
copyBtn.MouseButton1Click:Connect(copyObject)
pasteBtn.MouseButton1Click:Connect(pasteObject)
deleteBtn.MouseButton1Click:Connect(deleteObject)

visionBtn.MouseButton1Click:Connect(toggleVision)

jumpBtn.MouseButton1Click:Connect(function()

	local on = toggleButton(jumpBtn)

	if on and player.Character then
		setupInfiniteJump(player.Character)
	end

end)

UserInputService.InputBegan:Connect(function(input,gp)

	if gp then return end

	if input.UserInputType == Enum.UserInputType.MouseButton1 then

		local mouse = player:GetMouse()

		if mouse.Target then
			onObjectClick(mouse.Target)
		end

	end

end)

-------------------------------------------------
-- CHARACTER SETUP
-------------------------------------------------

player.CharacterAdded:Connect(function(char)

	task.wait(0.5)
	setupInfiniteJump(char)

end)

if player.Character then

	task.delay(0.5,function()
		setupInfiniteJump(player.Character)
	end)

end
