-- Transparency Replacer Tool
-- Cari semua object dengan Transparency == InputA lalu ubah jadi InputB
-- Tombol Reset mengembalikan semua ke kondisi awal

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer

local modified = {} -- [Instance] = {Transparency, Color}
local dragging = false
local isMinimized = false

-- ============== LOGIC =================
local function isTarget(inst)
	return inst:IsA("BasePart")
end

local function applyChanges(fromValue, toValue)
	for _, inst in ipairs(workspace:GetDescendants()) do
		if isTarget(inst) and inst.Transparency == fromValue then
			if not modified[inst] then
				modified[inst] = {
					Transparency = inst.Transparency,
					Color = inst.Color
				}
			end
			inst.Transparency = toValue
			inst.Color = Color3.fromRGB(0,255,0) -- kasih hijau supaya kelihatan
		end
	end
end

local function resetAll()
	for inst, data in pairs(modified) do
		if inst and inst.Parent then
			inst.Transparency = data.Transparency
			inst.Color = data.Color
		end
	end
	table.clear(modified)
end

-- ============== GUI =================
local gui = Instance.new("ScreenGui")
gui.Name = "TransparencyTool"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(260,160)
frame.Position = UDim2.fromOffset(100,200)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.BackgroundTransparency = 0.2
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1,0,0,28)
titleBar.BackgroundColor3 = Color3.fromRGB(15,15,15)
titleBar.BackgroundTransparency = 0.2
titleBar.Parent = frame
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0,12)

local title = Instance.new("TextLabel")
title.Text = "Transparency Replacer"
title.Size = UDim2.new(1,-60,1,0)
title.Position = UDim2.fromOffset(8,0)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

-- Close & Minimize
local btnClose = Instance.new("TextButton")
btnClose.Size = UDim2.fromOffset(24,24)
btnClose.Position = UDim2.new(1,-28,0,2)
btnClose.BackgroundColor3 = Color3.fromRGB(180,50,50)
btnClose.Text = "×"
btnClose.TextColor3 = Color3.new(1,1,1)
btnClose.Font = Enum.Font.GothamBold
btnClose.TextSize = 16
btnClose.Parent = titleBar
Instance.new("UICorner", btnClose).CornerRadius = UDim.new(1,0)

local btnMin = Instance.new("TextButton")
btnMin.Size = UDim2.fromOffset(24,24)
btnMin.Position = UDim2.new(1,-56,0,2)
btnMin.BackgroundColor3 = Color3.fromRGB(60,60,60)
btnMin.Text = "–"
btnMin.TextColor3 = Color3.new(1,1,1)
btnMin.Font = Enum.Font.GothamBold
btnMin.TextSize = 16
btnMin.Parent = titleBar
Instance.new("UICorner", btnMin).CornerRadius = UDim.new(1,0)

-- Content
local content = Instance.new("Frame")
content.Size = UDim2.new(1,-20,1,-40)
content.Position = UDim2.fromOffset(10,34)
content.BackgroundTransparency = 1
content.Parent = frame

local labelA = Instance.new("TextLabel")
labelA.Text = "From Transparency:"
labelA.Size = UDim2.new(1,0,0,20)
labelA.BackgroundTransparency = 1
labelA.TextColor3 = Color3.new(1,1,1)
labelA.Font = Enum.Font.Gotham
labelA.TextSize = 14
labelA.TextXAlignment = Enum.TextXAlignment.Left
labelA.Parent = content

local inputA = Instance.new("TextBox")
inputA.Size = UDim2.new(1,0,0,24)
inputA.Position = UDim2.fromOffset(0,22)
inputA.BackgroundColor3 = Color3.fromRGB(40,40,40)
inputA.PlaceholderText = "contoh: 1"
inputA.Text = ""
inputA.TextColor3 = Color3.new(1,1,1)
inputA.Font = Enum.Font.Gotham
inputA.TextSize = 14
inputA.Parent = content
Instance.new("UICorner", inputA).CornerRadius = UDim.new(0,8)

local labelB = Instance.new("TextLabel")
labelB.Text = "To Transparency:"
labelB.Size = UDim2.new(1,0,0,20)
labelB.Position = UDim2.fromOffset(0,50)
labelB.BackgroundTransparency = 1
labelB.TextColor3 = Color3.new(1,1,1)
labelB.Font = Enum.Font.Gotham
labelB.TextSize = 14
labelB.TextXAlignment = Enum.TextXAlignment.Left
labelB.Parent = content

local inputB = Instance.new("TextBox")
inputB.Size = UDim2.new(1,0,0,24)
inputB.Position = UDim2.fromOffset(0,72)
inputB.BackgroundColor3 = Color3.fromRGB(40,40,40)
inputB.PlaceholderText = "contoh: 0.1"
inputB.Text = ""
inputB.TextColor3 = Color3.new(1,1,1)
inputB.Font = Enum.Font.Gotham
inputB.TextSize = 14
inputB.Parent = content
Instance.new("UICorner", inputB).CornerRadius = UDim.new(0,8)

local applyBtn = Instance.new("TextButton")
applyBtn.Size = UDim2.new(0.48,0,0,28)
applyBtn.Position = UDim2.fromScale(0,1)
applyBtn.AnchorPoint = Vector2.new(0,1)
applyBtn.BackgroundColor3 = Color3.fromRGB(50,160,80)
applyBtn.Text = "Apply"
applyBtn.TextColor3 = Color3.new(1,1,1)
applyBtn.Font = Enum.Font.GothamBold
applyBtn.TextSize = 14
applyBtn.Parent = content
Instance.new("UICorner", applyBtn).CornerRadius = UDim.new(0,8)

local resetBtn = Instance.new("TextButton")
resetBtn.Size = UDim2.new(0.48,0,0,28)
resetBtn.Position = UDim2.fromScale(1,1)
resetBtn.AnchorPoint = Vector2.new(1,1)
resetBtn.BackgroundColor3 = Color3.fromRGB(200,50,50)
resetBtn.Text = "Reset"
resetBtn.TextColor3 = Color3.new(1,1,1)
resetBtn.Font = Enum.Font.GothamBold
resetBtn.TextSize = 14
resetBtn.Parent = content
Instance.new("UICorner", resetBtn).CornerRadius = UDim.new(0,8)

-- ============== DRAG =================
local dragInput, dragStart, startPos
titleBar.InputBegan:Connect(function(input)
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
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UIS.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- ============== EVENTS =================
applyBtn.MouseButton1Click:Connect(function()
	local fromVal = tonumber(inputA.Text)
	local toVal = tonumber(inputB.Text)
	if fromVal and toVal then
		applyChanges(fromVal,toVal)
	end
end)

resetBtn.MouseButton1Click:Connect(function()
	resetAll()
end)

btnClose.MouseButton1Click:Connect(function()
	resetAll()
	gui:Destroy()
end)

btnMin.MouseButton1Click:Connect(function()
	isMinimized = not isMinimized
	if isMinimized then
		content.Visible = false
		frame.Size = UDim2.fromOffset(160,30)
	else
		content.Visible = true
		frame.Size = UDim2.fromOffset(260,160)
	end
end)
