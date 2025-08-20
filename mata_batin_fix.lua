-- Transparency Scanner Mini Button
-- Semua yang Transparency == 1 -> Transparency = 0 + Color = Hijau
-- Saat OFF -> dikembalikan ke semula

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

local modified = {} -- simpan {Transparency, Color}
local connections = {}
local isOn = false
local dragging = false

-- Cek target yang bisa diubah
local function isTarget(inst)
	return inst:IsA("BasePart")
end

-- Simpan dan ubah
local function apply(inst)
	if not isTarget(inst) then return end
	if inst.Transparency == 1 then
		if not modified[inst] then
			modified[inst] = {
				Transparency = inst.Transparency,
				Color = inst.Color
			}
		end
		inst.Transparency = 0
		inst.Color = Color3.fromRGB(0,255,0) -- hijau
	end
end

-- Scan semua benda
local function scanAll()
	for _,d in ipairs(workspace:GetDescendants()) do
		apply(d)
	end
end

-- Pulihkan
local function restoreAll()
	for inst,data in pairs(modified) do
		if inst and inst.Parent then
			inst.Transparency = data.Transparency
			inst.Color = data.Color
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

-- ===================================
-- Floating Button GUI
-- ===================================
local gui = Instance.new("ScreenGui")
gui.Name = "MiniScanner"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")

local button = Instance.new("TextButton")
button.Size = UDim2.fromOffset(60,60)
button.Position = UDim2.fromOffset(80,200)
button.BackgroundColor3 = Color3.fromRGB(200,50,50) -- merah = OFF
button.Text = "OFF"
button.TextColor3 = Color3.new(1,1,1)
button.Font = Enum.Font.GothamBold
button.TextSize = 18
button.Parent = gui
Instance.new("UICorner", button).CornerRadius = UDim.new(1,0) -- bulat

-- Dragging
local dragInput, dragStart, startPos
button.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = button.Position
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
		local goal = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		button.Position = goal
	end
end)

-- Toggle ON/OFF
local function refreshUI()
	if isOn then
		button.Text = "ON"
		button.BackgroundColor3 = Color3.fromRGB(50,180,70) -- hijau
	else
		button.Text = "OFF"
		button.BackgroundColor3 = Color3.fromRGB(200,50,50) -- merah
	end
end

button.MouseButton1Click:Connect(function()
	if isOn then turnOff() else turnOn() end
	refreshUI()
end)

refreshUI()
