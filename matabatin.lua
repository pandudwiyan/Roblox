-- Transparency Scanner GUI (rapi, drag mulus, transparansi ubah jadi 0.3)
-- LocalScript, taruh di StarterPlayerScripts / StarterGui
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- ===============================
-- Transparency Logic
-- ===============================
local modified = {}
local connections = {}
local isOn = false
local isMinimized = false

local function isTarget(inst)
	return inst:IsA("BasePart") or inst:IsA("Decal") or inst:IsA("Texture")
end

local function safeGet(inst)
	local ok,v = pcall(function() return inst.Transparency end)
	return ok and v or nil
end

local function safeSet(inst, val)
	pcall(function() inst.Transparency = val end)
end

local function apply(inst)
	if not isTarget(inst) then return end
	local t = safeGet(inst)
	if t and t == 1 then
		if modified[inst] == nil then
			modified[inst] = t
		end
		safeSet(inst, 0.3) -- ubah ke 0.3
	end
end

local function scanAll()
	for _,d in ipairs(workspace:GetDescendants()) do
		apply(d)
	end
end

local function restoreAll()
	for inst,orig in pairs(modified) do
		if inst and inst.Parent then
			safeSet(inst, orig)
		end
	end
	table.clear(modified)
end

local function disconnectAll()
	for _,c in ipairs(connections) do
		if c.Disconnect then c:Disconnect() end
	end
	table.clear(connections)
end

local function turnOn()
	if isOn then return end
	isOn = true
	scanAll()
	table.insert(connections, workspace.DescendantAdded:Connect(function(d) apply(d) end))
end

local function turnOff()
	if not isOn then return end
	isOn = false
	disconnectAll()
	restoreAll()
end

-- ===============================
-- GUI
-- ===============================
local gui = Instance.new("ScreenGui")
gui.Name = "TransparencyScanner"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(240,140)
frame.Position = UDim2.fromOffset(60,120)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.BackgroundTransparency = 0.2
frame.BorderSizePixel = 0
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0,16)

local shadow = Instance.new("ImageLabel")
shadow.AnchorPoint = Vector2.new(0.5,0.5)
shadow.Position = UDim2.fromScale(0.5,0.5)
shadow.Size = UDim2.new(1,30,1,30)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://5028857084"
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(24,24,276,276)
shadow.Parent = frame
shadow.ZIndex = 0

local top = Instance.new("Frame")
top.Size = UDim2.new(1,0,0,30)
top.BackgroundColor3 = Color3.fromRGB(15,15,15)
top.BackgroundTransparency = 0.2
top.BorderSizePixel = 0
top.Parent = frame
Instance.new("UICorner", top).CornerRadius = UDim.new(0,16)

local title = Instance.new("TextLabel")
title.Text = "Transparency Scanner"
title.Size = UDim2.new(1,-70,1,0)
title.Position = UDim2.fromOffset(10,0)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = top

local btnClose = Instance.new("TextButton")
btnClose.Size = UDim2.fromOffset(24,24)
btnClose.Position = UDim2.new(1,-28,0,3)
btnClose.BackgroundColor3 = Color3.fromRGB(180,50,50)
btnClose.Text = "×"
btnClose.TextColor3 = Color3.new(1,1,1)
btnClose.Font = Enum.Font.GothamBold
btnClose.TextSize = 16
btnClose.Parent = top
Instance.new("UICorner", btnClose).CornerRadius = UDim.new(1,0)

local btnMin = Instance.new("TextButton")
btnMin.Size = UDim2.fromOffset(24,24)
btnMin.Position = UDim2.new(1,-56,0,3)
btnMin.BackgroundColor3 = Color3.fromRGB(60,60,60)
btnMin.Text = "–"
btnMin.TextColor3 = Color3.new(1,1,1)
btnMin.Font = Enum.Font.GothamBold
btnMin.TextSize = 16
btnMin.Parent = top
Instance.new("UICorner", btnMin).CornerRadius = UDim.new(1,0)

local content = Instance.new("Frame")
content.Size = UDim2.new(1,-20,1,-40)
content.Position = UDim2.fromOffset(10,36)
content.BackgroundTransparency = 1
content.Parent = frame

local status = Instance.new("TextLabel")
status.Text = "Status: OFF"
status.Size = UDim2.new(1,0,0,20)
status.BackgroundTransparency = 1
status.Font = Enum.Font.Gotham
status.TextSize = 14
status.TextColor3 = Color3.new(1,1,1)
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = content

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(1,0,0,36)
toggle.Position = UDim2.fromOffset(0,30)
toggle.BackgroundColor3 = Color3.fromRGB(200,50,50)
toggle.Text = "Turn ON"
toggle.TextColor3 = Color3.new(1,1,1)
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 16
toggle.Parent = content
Instance.new("UICorner", toggle).CornerRadius = UDim.new(0,12)

-- ===============================
-- Interactions
-- ===============================
-- Drag
local dragging, dragInput, dragStart, startPos
top.InputBegan:Connect(function(input)
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
UIS.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		dragInput = input
	end
end)
UIS.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		local goal = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		TweenService:Create(frame,TweenInfo.new(0.1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position=goal}):Play()
	end
end)

-- Toggle
local function refreshUI()
	if isOn then
		status.Text = "Status: ON"
		toggle.Text = "Turn OFF"
		toggle.BackgroundColor3 = Color3.fromRGB(50,160,80)
	else
		status.Text = "Status: OFF"
		toggle.Text = "Turn ON"
		toggle.BackgroundColor3 = Color3.fromRGB(200,50,50)
	end
end

toggle.MouseButton1Click:Connect(function()
	if isOn then turnOff() else turnOn() end
	refreshUI()
end)

btnMin.MouseButton1Click:Connect(function()
	isMinimized = not isMinimized
	content.Visible = not isMinimized
	if isMinimized then
		frame.Size = UDim2.fromOffset(240,34)
	else
		frame.Size = UDim2.fromOffset(240,140)
	end
end)

btnClose.MouseButton1Click:Connect(function()
	turnOff()
	gui:Destroy()
end)

refreshUI()
