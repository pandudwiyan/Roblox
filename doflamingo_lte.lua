-- Floating Tools UI (PC + Mobile)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

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
panel.Size = UDim2.new(0,160,0,60)
panel.Position = UDim2.new(0.05,0,0.7,0)
panel.BackgroundColor3 = Color3.fromRGB(0,0,0)
panel.BackgroundTransparency = 0.3
panel.Active = true
panel.Parent = gui

Instance.new("UICorner",panel).CornerRadius = UDim.new(0,12)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,-10,0,20)
title.Position = UDim2.new(0,5,0,3)
title.BackgroundTransparency = 1
title.Text = "Tools"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.SourceSansBold
title.TextXAlignment = Enum.TextXAlignment.Left
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

	Instance.new("UICorner",btn)

	return btn

end

local visionBtn = createButton("Vision",8)
local jumpBtn = createButton("Jump",82)

-------------------------------------------------
-- SELECTION MENU
-------------------------------------------------

local menu = Instance.new("Frame")
menu.Size = UDim2.new(0,150,0,160)
menu.BackgroundColor3 = Color3.fromRGB(40,40,40)
menu.Visible = false
menu.Parent = gui

Instance.new("UICorner",menu)

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

	Instance.new("UICorner",b)

	return b

end

local bringBtn = createMenuButton("Bring",10,Color3.fromRGB(0,120,215))
local teleportBtn = createMenuButton("Teleport",40,Color3.fromRGB(0,170,0))
local copyBtn = createMenuButton("Copy",70,Color3.fromRGB(255,170,0))
local pasteBtn = createMenuButton("Paste",100,Color3.fromRGB(120,120,255))
local deleteBtn = createMenuButton("Delete",130,Color3.fromRGB(215,0,0))

-------------------------------------------------
-- VARIABLES
-------------------------------------------------

local selectedObject
local selectedOriginalColor

local copiedObject
local broughtObjects = {}

local lastClick = 0
local lastObject

local originalTransparency = {}
local originalColors = {}

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
-- VISION
-------------------------------------------------

local function toggleVision()

	local on = toggle(visionBtn)

	if on then

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
-- CLICK PC
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

-------------------------------------------------
-- TAP MOBILE
-------------------------------------------------

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
		hrp.CFrame = selectedObject.CFrame + Vector3.new(0,5,0)
	end

end)

copyBtn.MouseButton1Click:Connect(function()

	if selectedObject then
		copiedObject = selectedObject:Clone()
	end

end)

pasteBtn.MouseButton1Click:Connect(function()

	if not copiedObject then return end

	local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

	if hrp then

		local clone = copiedObject:Clone()
		clone.Parent = Workspace
		clone.CFrame = hrp.CFrame + hrp.CFrame.LookVector*5

	end

end)

deleteBtn.MouseButton1Click:Connect(function()

	if selectedObject then
		selectedObject:Destroy()
		menu.Visible = false
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

end)
