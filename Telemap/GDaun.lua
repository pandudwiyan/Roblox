--// MAP GUNUNG DAUN Teleport Panel (Toggle Spectate)

local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))

-- Frame utama
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 350, 0, 300)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BackgroundTransparency = 0.2
MainFrame.BorderSizePixel = 0

-- Header
local Header = Instance.new("Frame", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 30)
Header.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Header.BorderSizePixel = 0

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "MAP GUNUNG DAUN"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Tombol Minimize
local MinBtn = Instance.new("TextButton", Header)
MinBtn.Size = UDim2.new(0, 25, 0, 25)
MinBtn.Position = UDim2.new(1, -55, 0, 2)
MinBtn.Text = "-"
MinBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
MinBtn.TextColor3 = Color3.fromRGB(255,255,255)
MinBtn.Font = Enum.Font.SourceSansBold
MinBtn.TextSize = 20

-- Tombol Close
local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -28, 0, 2)
CloseBtn.Text = "X"
CloseBtn.BackgroundColor3 = Color3.fromRGB(150,50,50)
CloseBtn.TextColor3 = Color3.fromRGB(255,255,255)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 18

-- Scroll list
local ListFrame = Instance.new("ScrollingFrame", MainFrame)
ListFrame.Size = UDim2.new(1, -20, 1, -40)
ListFrame.Position = UDim2.new(0, 10, 0, 35)
ListFrame.BackgroundTransparency = 1
ListFrame.CanvasSize = UDim2.new(0,0,0,0)
ListFrame.ScrollBarThickness = 6

-- Dragable
local UIS = game:GetService("UserInputService")
local dragging, dragInput, dragStart, startPos

local function update(input)
	local delta = input.Position - dragStart
	MainFrame.Position = UDim2.new(
		startPos.X.Scale,
		startPos.X.Offset + delta.X,
		startPos.Y.Scale,
		startPos.Y.Offset + delta.Y
	)
end

Header.InputBegan:Connect(function(input)
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

Header.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)

UIS.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		update(input)
	end
end)

-- Data koordinat
local Locations = {
    {name = "Base", pos = Vector3.new(-6.45, 14.90, -9.29)},
    {name = "cp1", pos = Vector3.new(-622.84, 251.27, -385.33)},
    {name = "cp2", pos = Vector3.new(-1203.66, 262.67, -486.82)},
    {name = "cp3", pos = Vector3.new(-1399.26, 579.38, -951.27)},
    {name = "cp4", pos = Vector3.new(-1701.29, 817.61, -1399.51)},
    {name = "Summit", pos = Vector3.new(-3227.82, 1716.93, -2588.45)},
}

-- Fungsi Teleport
local function teleportTo(v3)
	local plr = game.Players.LocalPlayer
	if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
		plr.Character.HumanoidRootPart.CFrame = CFrame.new(v3)
	end
end

-- Fungsi kamera
local function returnCamera()
	local plr = game.Players.LocalPlayer
	local cam = workspace.CurrentCamera
	if plr.Character and plr.Character:FindFirstChild("Humanoid") then
		cam.CameraSubject = plr.Character.Humanoid
		cam.CameraType = Enum.CameraType.Custom
	end
end

local function setSpectate(v3)
	local cam = workspace.CurrentCamera
	cam.CameraType = Enum.CameraType.Scriptable
	cam.CFrame = CFrame.new(v3 + Vector3.new(0,5,0), v3)
end

-- Buat list
for i, loc in ipairs(Locations) do
	local ItemFrame = Instance.new("Frame", ListFrame)
	ItemFrame.Size = UDim2.new(1, -5, 0, 30)
	ItemFrame.Position = UDim2.new(0, 0, 0, (i-1)*35)
	ItemFrame.BackgroundColor3 = Color3.fromRGB(35,35,35)
	ItemFrame.BorderSizePixel = 0

	local Label = Instance.new("TextLabel", ItemFrame)
	Label.Size = UDim2.new(0.4, 0, 1, 0)
	Label.Position = UDim2.new(0, 5, 0, 0)
	Label.BackgroundTransparency = 1
	Label.Text = loc.name
	Label.TextColor3 = Color3.fromRGB(255,255,255)
	Label.Font = Enum.Font.SourceSans
	Label.TextSize = 16
	Label.TextXAlignment = Enum.TextXAlignment.Left

	local TpBtn = Instance.new("TextButton", ItemFrame)
	TpBtn.Size = UDim2.new(0.25, -5, 0.8, 0)
	TpBtn.Position = UDim2.new(0.45, 0, 0.1, 0)
	TpBtn.BackgroundColor3 = Color3.fromRGB(80,150,80)
	TpBtn.Text = "Teleport"
	TpBtn.TextColor3 = Color3.fromRGB(255,255,255)
	TpBtn.Font = Enum.Font.SourceSansBold
	TpBtn.TextSize = 14

	local SpBtn = Instance.new("TextButton", ItemFrame)
	SpBtn.Size = UDim2.new(0.25, -5, 0.8, 0)
	SpBtn.Position = UDim2.new(0.72, 0, 0.1, 0)
	SpBtn.BackgroundColor3 = Color3.fromRGB(70,100,150)
	SpBtn.Text = "🙈" -- mata merem awal
	SpBtn.TextColor3 = Color3.fromRGB(255,255,255)
	SpBtn.Font = Enum.Font.SourceSansBold
	SpBtn.TextSize = 18

	local spectating = false
	TpBtn.MouseButton1Click:Connect(function()
		teleportTo(loc.pos)
	end)

	SpBtn.MouseButton1Click:Connect(function()
		spectating = not spectating
		if spectating then
			SpBtn.Text = "👀" -- mata melek
			setSpectate(loc.pos)
		else
			SpBtn.Text = "🙈" -- mata merem
			returnCamera()
		end
	end)
end

-- Update canvas scroll
ListFrame.CanvasSize = UDim2.new(0,0,0,#Locations * 35)

-- Tombol Minimize
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	if minimized then
		ListFrame.Visible = false
		MainFrame.Size = UDim2.new(0,350,0,30)
	else
		ListFrame.Visible = true
		MainFrame.Size = UDim2.new(0,350,0,300)
	end
end)

-- Tombol Close
CloseBtn.MouseButton1Click:Connect(function()
	ScreenGui:Destroy()
end)
