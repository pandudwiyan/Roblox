--[[
  Transparency Scanner GUI (Studio-safe)
  ----------------------------------------------------
  • Pakai di game milikmu sendiri / Roblox Studio untuk testing.
  • GUI kecil, draggable, ON/OFF, minimize, close, dan Scan Once.
  • Saat ON: memindai Workspace, semua BasePart/Decal/Texture dengan Transparency == 1 akan diubah ke 0.7.
  • Saat OFF: mengembalikan objek yang diubah tadi ke nilai semula (1).
  • Seluruh perubahan bersifat lokal (client) saat testing.

  Cara pakai:
  1) Tempatkan script ini sebagai LocalScript di StarterPlayerScripts (Studio/testing).
  2) Play test; GUI muncul, lalu gunakan tombol ON/OFF atau Scan Once.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Peringatan ringan jika tidak dijalankan di Studio (tetap lanjut, tapi dianjurkan hanya untuk testing di game sendiri)
if not RunService:IsStudio() then
	warn("Transparency Scanner: Direkomendasikan hanya untuk Roblox Studio / pengalaman milik sendiri.")
end

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- STATE
local scanning = false
local minimized = false
local changedSet = {}  -- [Instance] = originalTransparency
local conAdded: RBXScriptConnection? = nil

-- UI FACTORY
local screen = Instance.new("ScreenGui")
screen.Name = "TransparencyScannerGUI"
screen.ResetOnSpawn = false
screen.IgnoreGuiInset = true
screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screen.Parent = playerGui

local main = Instance.new("Frame")
main.Name = "Main"
main.AnchorPoint = Vector2.new(0, 0)
main.Position = UDim2.new(0, 20, 0, 80)
main.Size = UDim2.new(0, 240, 0, 140)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
main.BackgroundTransparency = 0.1
main.BorderSizePixel = 0
main.Parent = screen

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = main

local shadow = Instance.new("UIStroke")
shadow.Thickness = 1
shadow.Color = Color3.fromRGB(60, 60, 70)
shadow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
shadow.Parent = main

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 32)
padding.PaddingLeft = UDim.new(0, 10)
padding.PaddingRight = UDim.new(0, 10)
padding.PaddingBottom = UDim.new(0, 10)
padding.Parent = main

local topbar = Instance.new("Frame")
topbar.Name = "Topbar"
topbar.Parent = main
topbar.Position = UDim2.new(0,0,0,0)
topbar.Size = UDim2.new(1,0,0,28)
topbar.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
topbar.BorderSizePixel = 0

local topbarCorner = Instance.new("UICorner")
topbarCorner.CornerRadius = UDim.new(0, 10)
topbarCorner.Parent = topbar

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Parent = topbar

title.Text = "Transparency Scanner"
title.Font = Enum.Font.GothamBold

-- Gunakan TextScaled agar enak di mobile
local titleConstraint = Instance.new("UITextSizeConstraint")
titleConstraint.MaxTextSize = 18

title.TextScaled = true

title.TextColor3 = Color3.fromRGB(235, 235, 245)
title.AnchorPoint = Vector2.new(0, 0)
title.Position = UDim2.new(0, 10, 0, 4)
title.Size = UDim2.new(1, -80, 1, -8)

title.BackgroundTransparency = 1

titleConstraint.Parent = title

local btnMin = Instance.new("TextButton")
btnMin.Name = "Minimize"
btnMin.Parent = topbar
btnMin.Text = "–"
btnMin.Font = Enum.Font.GothamBold
btnMin.TextScaled = true
local btnMinConstraint = Instance.new("UITextSizeConstraint")
btnMinConstraint.MaxTextSize = 20
btnMinConstraint.Parent = btnMin
btnMin.TextColor3 = Color3.fromRGB(235,235,245)
btnMin.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
btnMin.AutoButtonColor = true
btnMin.AnchorPoint = Vector2.new(1, 0)
btnMin.Position = UDim2.new(1, -56, 0, 4)
btnMin.Size = UDim2.new(0, 24, 0, 20)
local btnMinCorner = Instance.new("UICorner")
btnMinCorner.CornerRadius = UDim.new(0, 6)
btnMinCorner.Parent = btnMin

local btnClose = Instance.new("TextButton")
btnClose.Name = "Close"
btnClose.Parent = topbar
btnClose.Text = "✕"
btnClose.Font = Enum.Font.GothamBold
btnClose.TextScaled = true
local btnCloseConstraint = Instance.new("UITextSizeConstraint")
btnCloseConstraint.MaxTextSize = 20
btnCloseConstraint.Parent = btnClose
btnClose.TextColor3 = Color3.fromRGB(235,235,245)
btnClose.BackgroundColor3 = Color3.fromRGB(55, 35, 40)
btnClose.AutoButtonColor = true
btnClose.AnchorPoint = Vector2.new(1, 0)
btnClose.Position = UDim2.new(1, -28, 0, 4)
btnClose.Size = UDim2.new(0, 24, 0, 20)
local btnCloseCorner = Instance.new("UICorner")
btnCloseCorner.CornerRadius = UDim.new(0, 6)
btnCloseCorner.Parent = btnClose

-- BODY
local body = Instance.new("Frame")
body.Name = "Body"
body.Parent = main
body.BackgroundTransparency = 1
body.Position = UDim2.new(0,0,0,32)
body.Size = UDim2.new(1,0,1,-36)

local layout = Instance.new("UIListLayout")
layout.Parent = body
layout.FillDirection = Enum.FillDirection.Vertical
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 8)

local status = Instance.new("TextLabel")
status.Name = "Status"
status.Parent = body
status.Text = "Status: OFF"
status.Font = Enum.Font.Gotham
status.TextScaled = true
local statusConstraint = Instance.new("UITextSizeConstraint")
statusConstraint.MaxTextSize = 16
statusConstraint.Parent = status
status.TextColor3 = Color3.fromRGB(220, 220, 230)
status.BackgroundTransparency = 1
status.Size = UDim2.new(1, -4, 0, 22)

local toggle = Instance.new("TextButton")
toggle.Name = "Toggle"
toggle.Parent = body
toggle.Text = "Turn ON"
toggle.Font = Enum.Font.GothamBold
toggle.TextScaled = true
local toggleConstraint = Instance.new("UITextSizeConstraint")
toggleConstraint.MaxTextSize = 16
toggleConstraint.Parent = toggle
toggle.TextColor3 = Color3.fromRGB(245,245,255)
toggle.BackgroundColor3 = Color3.fromRGB(30, 120, 60)
toggle.AutoButtonColor = true
toggle.Size = UDim2.new(1, -4, 0, 26)
local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
toggleCorner.Parent = toggle

local scanOnce = Instance.new("TextButton")
scanOnce.Name = "ScanOnce"
scanOnce.Parent = body
scanOnce.Text = "Scan Once"
scanOnce.Font = Enum.Font.GothamBold
scanOnce.TextScaled = true
local scanOnceConstraint = Instance.new("UITextSizeConstraint")
scanOnceConstraint.MaxTextSize = 16
scanOnceConstraint.Parent = scanOnce
scanOnce.TextColor3 = Color3.fromRGB(245,245,255)
scanOnce.BackgroundColor3 = Color3.fromRGB(55, 90, 160)
scanOnce.AutoButtonColor = true
scanOnce.Size = UDim2.new(1, -4, 0, 26)
local scanOnceCorner = Instance.new("UICorner")
scanOnceCorner.CornerRadius = UDim.new(0, 8)
scanOnceCorner.Parent = scanOnce

-- DRAGGING (mouse & touch)
local dragging = false
local dragStart
local startPos

local function updateDrag(input)
	local delta = input.Position - dragStart
	main.Position = UDim2.new(
		main.Position.X.Scale,
		main.Position.X.Offset + delta.X,
		main.Position.Y.Scale,
		main.Position.Y.Offset + delta.Y
	)
end

topbar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = main.Position
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

-- LOGIC
local function trackChange(obj, original)
	-- Simpan hanya bila belum tercatat dan originalnya tepat 1
	if changedSet[obj] == nil then
		changedSet[obj] = original
	end
end

local function applyIfTransparent1(obj)
	if not obj or not obj.Parent then return end
	-- BasePart
	if obj:IsA("BasePart") then
		local ok, current = pcall(function() return obj.Transparency end)
		if ok and current == 1 then
			trackChange(obj, 1)
			pcall(function() obj.Transparency = 0.7 end)
		end
	-- Decal & Texture (punya property Transparency)
	elseif obj:IsA("Decal") or obj:IsA("Texture") then
		local ok, current = pcall(function() return obj.Transparency end)
		if ok and current == 1 then
			trackChange(obj, 1)
			pcall(function() obj.Transparency = 0.7 end)
		end
	end
end

local function scanAll()
	for _, d in ipairs(workspace:GetDescendants()) do
		applyIfTransparent1(d)
	end
end

local function revertAll()
	for inst, orig in pairs(changedSet) do
		if inst and inst.Parent and typeof(orig) == "number" then
			pcall(function()
				if inst:IsA("BasePart") or inst:IsA("Decal") or inst:IsA("Texture") then
					inst.Transparency = orig
				end
			end)
		end
	end
	table.clear(changedSet)
end

local function setScanning(on)
	scanning = on
	if scanning then
		status.Text = "Status: ON"
		toggle.Text = "Turn OFF"
		toggle.BackgroundColor3 = Color3.fromRGB(160, 80, 30)
		scanAll()
		conAdded = workspace.DescendantAdded:Connect(applyIfTransparent1)
	else
		status.Text = "Status: OFF"
		toggle.Text = "Turn ON"
		toggle.BackgroundColor3 = Color3.fromRGB(30, 120, 60)
		if conAdded then
			conAdded:Disconnect()
			conAdded = nil
		end
		revertAll()
	end
end

-- BUTTON HOOKS
btnClose.MouseButton1Click:Connect(function()
	if conAdded then conAdded:Disconnect() end
	revertAll()
	screen:Destroy()
end)

btnMin.MouseButton1Click:Connect(function()
	minimized = not minimized
	body.Visible = not minimized
	if minimized then
		main.Size = UDim2.new(0, 240, 0, 36)
	else
		main.Size = UDim2.new(0, 240, 0, 140)
	end
end)

toggle.MouseButton1Click:Connect(function()
	setScanning(not scanning)
end)

scanOnce.MouseButton1Click:Connect(function()
	scanAll()
end)

-- Init
setScanning(false)
