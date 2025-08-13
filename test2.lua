local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function getLeaderstatsValue(statName)
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    if leaderstats then
        local stat = leaderstats:FindFirstChild(statName)
        if stat then
            return stat.Value
        end
    end
    return nil
end

-- Buat GUI untuk menampilkan Shelter & Summit
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "StageInfoUI"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 200, 0, 100)
MainFrame.Position = UDim2.new(1, -220, 0, 20) -- kanan atas layar
MainFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local ShelterLabel = Instance.new("TextLabel")
ShelterLabel.Size = UDim2.new(1, -10, 0, 40)
ShelterLabel.Position = UDim2.new(0, 5, 0, 5)
ShelterLabel.BackgroundTransparency = 1
ShelterLabel.TextColor3 = Color3.fromRGB(255,255,255)
ShelterLabel.Font = Enum.Font.SourceSansBold
ShelterLabel.TextSize = 20
ShelterLabel.Text = "Shelter: Loading..."
ShelterLabel.Parent = MainFrame

local SummitLabel = Instance.new("TextLabel")
SummitLabel.Size = UDim2.new(1, -10, 0, 40)
SummitLabel.Position = UDim2.new(0, 5, 0, 50)
SummitLabel.BackgroundTransparency = 1
SummitLabel.TextColor3 = Color3.fromRGB(255,255,255)
SummitLabel.Font = Enum.Font.SourceSansBold
SummitLabel.TextSize = 20
SummitLabel.Text = "Summit: Loading..."
SummitLabel.Parent = MainFrame

-- Update nilai setiap 1 detik
while true do
    local shelterVal = getLeaderstatsValue("Shelter")
    local summitVal = getLeaderstatsValue("Summit")
    if shelterVal then
        ShelterLabel.Text = "Shelter: " .. tostring(shelterVal)
    else
        ShelterLabel.Text = "Shelter: N/A"
    end
    if summitVal then
        SummitLabel.Text = "Summit: " .. tostring(summitVal)
    else
        SummitLabel.Text = "Summit: N/A"
    end
    wait(1)
end
