-- UI Buat Delta Executor Roblox
-- Versi aman (PlayerGui), support Delta & executor lain

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

repeat task.wait() until LocalPlayer:FindFirstChild("PlayerGui")

local targetPlayer = nil
local focusOnTarget = false

-- Buat UI ScreenGui
local gui = Instance.new("ScreenGui")
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer.PlayerGui -- Parent aman untuk Delta

-- Frame utama
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 200)
mainFrame.Position = UDim2.new(0.5, 0, 0.3, 0)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
mainFrame.BackgroundTransparency = 0.4
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.ClipsDescendants = true
mainFrame.Parent = gui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 15)
mainCorner.Parent = mainFrame

-- Kolom Search
local searchBox = Instance.new("TextBox")
searchBox.PlaceholderText = "SEARCH"
searchBox.Size = UDim2.new(1, -20, 0, 40)
searchBox.Position = UDim2.new(0, 10, 0, 10)
searchBox.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
searchBox.ClearTextOnFocus = false
searchBox.BorderSizePixel = 0
searchBox.Parent = mainFrame

local searchCorner = Instance.new("UICorner")
searchCorner.CornerRadius = UDim.new(0, 10)
searchCorner.Parent = searchBox

-- List hasil search
local resultsFrame = Instance.new("Frame")
resultsFrame.Size = UDim2.new(1, -20, 0, 40)
resultsFrame.Position = UDim2.new(0, 10, 0, 55)
resultsFrame.BackgroundTransparency = 1
resultsFrame.Parent = mainFrame

-- Tombol Clear Search
local clearBtn = Instance.new("TextButton")
clearBtn.Size = UDim2.new(1, -20, 0, 40)
clearBtn.Position = UDim2.new(0, 10, 0, 100)
clearBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
clearBtn.Text = "Clear Search"
clearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
clearBtn.BorderSizePixel = 0
clearBtn.Parent = mainFrame

local clearCorner = Instance.new("UICorner")
clearCorner.CornerRadius = UDim.new(0, 10)
clearCorner.Parent = clearBtn

clearBtn.MouseButton1Click:Connect(function()
	searchBox.Text = ""
	resultsFrame:ClearAllChildren()
end)

-- Tombol Teleport
local teleportBtn = Instance.new("TextButton")
teleportBtn.Size = UDim2.new(1, -20, 0, 40)
teleportBtn.Position = UDim2.new(0, 10, 1, -50)
teleportBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
teleportBtn.Text = "Teleport"
teleportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
teleportBtn.BorderSizePixel = 0
teleportBtn.Parent = mainFrame

local teleportCorner = Instance.new("UICorner")
teleportCorner.CornerRadius = UDim.new(0, 10)
teleportCorner.Parent = teleportBtn

-- Fungsi mencari player
local function searchPlayers(query)
	resultsFrame:ClearAllChildren()
	if query == "" then return end
	local y = 0
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			if string.find(string.lower(plr.Name), string.lower(query)) 
			or string.find(string.lower(plr.DisplayName), string.lower(query)) then
				local btn = Instance.new("TextButton")
				btn.Size = UDim2.new(1, 0, 0, 30)
				btn.Position = UDim2.new(0, 0, 0, y)
				btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
				btn.TextColor3 = Color3.fromRGB(255, 255, 255)
				btn.Text = plr.DisplayName .. " (" .. plr.Name .. ")"
				btn.Parent = resultsFrame

				local corner = Instance.new("UICorner")
				corner.CornerRadius = UDim.new(0, 8)
				corner.Parent = btn

				btn.MouseButton1Click:Connect(function()
					if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
						targetPlayer = plr
						focusOnTarget = true
						searchBox.Text = "" 
						resultsFrame:ClearAllChildren()
					end
				end)
				y = y + 35
			end
		end
	end
end

-- Event pencarian
searchBox:GetPropertyChangedSignal("Text"):Connect(function()
	searchPlayers(searchBox.Text)
end)

-- Fokus kamera
RunService.RenderStepped:Connect(function()
	if focusOnTarget and targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
		if not UIS:IsKeyDown(Enum.KeyCode.W) and not UIS:IsKeyDown(Enum.KeyCode.A) 
		and not UIS:IsKeyDown(Enum.KeyCode.S) and not UIS:IsKeyDown(Enum.KeyCode.D) 
		and not UIS:IsKeyDown(Enum.KeyCode.Space) then
			Camera.CameraSubject = targetPlayer.Character:FindFirstChild("Humanoid")
		else
			Camera.CameraSubject = LocalPlayer.Character:FindFirstChild("Humanoid")
			focusOnTarget = false
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
