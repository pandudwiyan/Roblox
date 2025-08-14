--// Workspace Scanner GUI v2 (Draggable + Close + Minimize + Mobile Support)
--// Made for Delta Executor Roblox

local scanParent = workspace
local player = game.Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Create GUI
local ScreenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
ScreenGui.ResetOnSpawn = false

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 400)
MainFrame.Position = UDim2.new(0, 50, 0, 100)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = false -- handled manually
MainFrame.Parent = ScreenGui

-- UI Scaling for mobile
local UIScale = Instance.new("UIScale", MainFrame)
UIScale.Scale = 1

-- Title Bar
local TitleBar = Instance.new("Frame", MainFrame)
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)

local Title = Instance.new("TextLabel", TitleBar)
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 5, 0, 0)
Title.Text = "Workspace Scanner"
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Close Button
local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.Size = UDim2.new(0, 30, 1, 0)
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.new(1, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 18

-- Minimize Button
local MinBtn = Instance.new("TextButton", TitleBar)
MinBtn.Size = UDim2.new(0, 30, 1, 0)
MinBtn.Position = UDim2.new(1, -60, 0, 0)
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.new(1, 1, 0)
MinBtn.BackgroundTransparency = 1
MinBtn.Font = Enum.Font.SourceSansBold
MinBtn.TextSize = 18

-- Content Area
local Scrolling = Instance.new("ScrollingFrame", MainFrame)
Scrolling.Size = UDim2.new(1, 0, 1, -30)
Scrolling.Position = UDim2.new(0, 0, 0, 30)
Scrolling.CanvasSize = UDim2.new(0, 0, 0, 0)
Scrolling.BackgroundTransparency = 1
Scrolling.ScrollBarThickness = 6

local UIListLayout = Instance.new("UIListLayout", Scrolling)
UIListLayout.Padding = UDim.new(0, 4)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Dragging Support (PC & Mobile)
local UserInputService = game:GetService("UserInputService")
local dragging, dragStart, startPos

local function updateDrag(input)
	MainFrame.Position = UDim2.new(
		startPos.X.Scale,
		startPos.X.Offset + (input.Position.X - dragStart.X),
		startPos.Y.Scale,
		startPos.Y.Offset + (input.Position.Y - dragStart.Y)
	)
end

TitleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
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
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		updateDrag(input)
	end
end)

-- Minimize & Close Actions
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	Scrolling.Visible = not minimized
end)

CloseBtn.MouseButton1Click:Connect(function()
	ScreenGui:Destroy()
end)

-- Scan Function
local function scanWorkspace()
	local counts = {}
	local objects = {}

	local function scanFolder(folder)
		for _, obj in ipairs(folder:GetChildren()) do
			local cname = obj.ClassName
			counts[cname] = (counts[cname] or 0) + 1
			objects[cname] = objects[cname] or {}
			table.insert(objects[cname], obj)

			if #obj:GetChildren() > 0 then
				scanFolder(obj)
			end
		end
	end

	scanFolder(scanParent)
	return counts, objects
end

-- Teleport & Spectate
local spectating = nil
local function teleportTo(object)
	if object:IsA("BasePart") then
		player.Character:MoveTo(object.Position)
	elseif object:IsA("Model") and object.PrimaryPart then
		player.Character:MoveTo(object.PrimaryPart.Position)
	end
end

local function toggleSpectate(object)
	if spectating == object then
		camera.CameraSubject = player.Character:FindFirstChildOfClass("Humanoid")
		spectating = nil
	else
		if object:IsA("BasePart") then
			camera.CameraSubject = object
		elseif object:IsA("Model") and object.PrimaryPart then
			camera.CameraSubject = object.PrimaryPart
		end
		spectating = object
	end
end

-- Build List
local counts, objects = scanWorkspace()

for cname, count in pairs(counts) do
	local catButton = Instance.new("TextButton", Scrolling)
	catButton.Size = UDim2.new(1, -10, 0, 25)
	catButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
	catButton.TextColor3 = Color3.new(1, 1, 1)
	catButton.Font = Enum.Font.SourceSans
	catButton.TextSize = 16
	catButton.Text = cname .. " : " .. count

	local expanded = false
	local itemFrames = {}

	catButton.MouseButton1Click:Connect(function()
		if expanded then
			for _, frame in ipairs(itemFrames) do
				frame:Destroy()
			end
			itemFrames = {}
			expanded = false
		else
			for i, obj in ipairs(objects[cname]) do
				local itemFrame = Instance.new("Frame", Scrolling)
				itemFrame.Size = UDim2.new(1, -10, 0, 25)
				itemFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)

				local itemLabel = Instance.new("TextLabel", itemFrame)
				itemLabel.Size = UDim2.new(0.4, 0, 1, 0)
				itemLabel.BackgroundTransparency = 1
				itemLabel.TextColor3 = Color3.new(1, 1, 1)
				itemLabel.Font = Enum.Font.SourceSans
				itemLabel.TextSize = 14
				itemLabel.Text = cname .. " " .. i

				local tpBtn = Instance.new("TextButton", itemFrame)
				tpBtn.Size = UDim2.new(0.3, 0, 1, 0)
				tpBtn.Position = UDim2.new(0.4, 0, 0, 0)
				tpBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
				tpBtn.TextColor3 = Color3.new(1, 1, 1)
				tpBtn.Text = "Teleport"
				tpBtn.MouseButton1Click:Connect(function()
					teleportTo(obj)
				end)

				local spBtn = Instance.new("TextButton", itemFrame)
				spBtn.Size = UDim2.new(0.3, 0, 1, 0)
				spBtn.Position = UDim2.new(0.7, 0, 0, 0)
				spBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 100)
				spBtn.TextColor3 = Color3.new(1, 1, 1)
				spBtn.Text = "Spectate"
				spBtn.MouseButton1Click:Connect(function()
					toggleSpectate(obj)
				end)

				table.insert(itemFrames, itemFrame)
			end
			expanded = true
		end
	end)
end

-- Update scrolling size
Scrolling.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	Scrolling.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
end)
