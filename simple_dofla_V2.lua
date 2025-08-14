local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local targetPlayer = nil
local focusOnTarget = false

-- Fungsi buat draggable frame
local function makeDraggable(frame)
    local dragging, dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                   startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
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
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

-- Buat UI
local gui = Instance.new("ScreenGui")
gui.ResetOnSpawn = false
gui.Parent = game.CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 180)
mainFrame.Position = UDim2.new(0.5, -150, 0.3, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
mainFrame.BackgroundTransparency = 0.4
mainFrame.BorderSizePixel = 0
mainFrame.Parent = gui
local mainCorner = Instance.new("UICorner", mainFrame)
mainCorner.CornerRadius = UDim.new(0, 15)
makeDraggable(mainFrame)

-- Search box
local searchBox = Instance.new("TextBox")
searchBox.PlaceholderText = "SEARCH"
searchBox.Size = UDim2.new(1, -20, 0, 40)
searchBox.Position = UDim2.new(0, 10, 0, 10)
searchBox.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
searchBox.ClearTextOnFocus = false
searchBox.BorderSizePixel = 0
searchBox.Parent = mainFrame
local searchCorner = Instance.new("UICorner", searchBox)
searchCorner.CornerRadius = UDim.new(0, 10)

-- Scroll list untuk hasil search
local resultsFrame = Instance.new("ScrollingFrame")
resultsFrame.Size = UDim2.new(1, -20, 0, 70)
resultsFrame.Position = UDim2.new(0, 10, 0, 55)
resultsFrame.BackgroundTransparency = 1
resultsFrame.BorderSizePixel = 0
resultsFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
resultsFrame.ScrollBarThickness = 4
resultsFrame.Parent = mainFrame

local layout = Instance.new("UIListLayout", resultsFrame)
layout.Padding = UDim.new(0, 5)
layout.SortOrder = Enum.SortOrder.LayoutOrder

-- Tombol teleport
local teleportBtn = Instance.new("TextButton")
teleportBtn.Size = UDim2.new(1, -20, 0, 40)
teleportBtn.Position = UDim2.new(0, 10, 1, -50)
teleportBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
teleportBtn.Text = "Teleport"
teleportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
teleportBtn.BorderSizePixel = 0
teleportBtn.Parent = mainFrame
local teleportCorner = Instance.new("UICorner", teleportBtn)
teleportCorner.CornerRadius = UDim.new(0, 10)

-- Fungsi pencarian player
local function searchPlayers(query)
	resultsFrame:ClearAllChildren()
	if query == "" then 
		resultsFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
		return 
	end
	
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			if string.find(string.lower(plr.Name), string.lower(query)) 
			or string.find(string.lower(plr.DisplayName), string.lower(query)) then
				local btn = Instance.new("TextButton")
				btn.Size = UDim2.new(1, 0, 0, 30)
				btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
				btn.TextColor3 = Color3.fromRGB(255, 255, 255)
				btn.Text = plr.DisplayName .. " (" .. plr.Name .. ")"
				btn.Parent = resultsFrame
				local corner = Instance.new("UICorner", btn)
				corner.CornerRadius = UDim.new(0, 8)
				btn.MouseButton1Click:Connect(function()
					if plr.Character and plr.Character:FindFirstChild("Humanoid") then
						targetPlayer = plr
						focusOnTarget = true
					end
				end)
			end
		end
	end
	
	resultsFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
end

-- Update list saat mengetik
searchBox:GetPropertyChangedSignal("Text"):Connect(function()
	searchPlayers(searchBox.Text)
end)

-- Kamera fokus
RunService.RenderStepped:Connect(function()
	if focusOnTarget and targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Humanoid") then
		Camera.CameraSubject = targetPlayer.Character.Humanoid
		-- kalau bergerak/loncat balik ke player sendiri
		if UIS:IsKeyDown(Enum.KeyCode.W) or UIS:IsKeyDown(Enum.KeyCode.A) 
		or UIS:IsKeyDown(Enum.KeyCode.S) or UIS:IsKeyDown(Enum.KeyCode.D) 
		or UIS:IsKeyDown(Enum.KeyCode.Space) then
			Camera.CameraSubject = LocalPlayer.Character:FindFirstChild("Humanoid")
		end
	end
end)

-- Teleport
teleportBtn.MouseButton1Click:Connect(function()
	if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
		local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if hrp then
			local targetHRP = targetPlayer.Character.HumanoidRootPart
			hrp.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 12)
		end
	end
end)
