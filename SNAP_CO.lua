-- Delta Exploit - Snap Position Logger

-- Buat ScreenGui
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))

-- Frame utama
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 400, 0, 250)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -125)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

-- Tombol Snap
local SnapBtn = Instance.new("TextButton", MainFrame)
SnapBtn.Size = UDim2.new(0, 120, 0, 40)
SnapBtn.Position = UDim2.new(0, 20, 0, 20)
SnapBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
SnapBtn.Text = "SNAP"
SnapBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SnapBtn.Font = Enum.Font.SourceSansBold
SnapBtn.TextSize = 20

-- Frame kanan untuk list
local ListFrame = Instance.new("ScrollingFrame", MainFrame)
ListFrame.Size = UDim2.new(0, 200, 0, 180)
ListFrame.Position = UDim2.new(0, 160, 0, 20)
ListFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ListFrame.BorderSizePixel = 0
ListFrame.CanvasSize = UDim2.new(0,0,0,0)
ListFrame.ScrollBarThickness = 6

-- Tombol Copy
local CopyBtn = Instance.new("TextButton", MainFrame)
CopyBtn.Size = UDim2.new(0, 200, 0, 30)
CopyBtn.Position = UDim2.new(0, 160, 0, 210)
CopyBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
CopyBtn.Text = "COPY ALL"
CopyBtn.TextColor3 = Color3.fromRGB(255,255,255)
CopyBtn.Font = Enum.Font.SourceSansBold
CopyBtn.TextSize = 18

-- Variabel untuk menyimpan koordinat
local savedCoords = {}

-- Fungsi Snap
local function snapPosition()
    local plr = game.Players.LocalPlayer
    local char = plr.Character or plr.CharacterAdded:Wait()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        local pos = hrp.Position
        local coordText = string.format("X: %.2f, Y: %.2f, Z: %.2f", pos.X, pos.Y, pos.Z)

        -- Simpan ke list
        table.insert(savedCoords, coordText)

        -- Buat label baru di ListFrame
        local Label = Instance.new("TextLabel", ListFrame)
        Label.Size = UDim2.new(1, -10, 0, 20)
        Label.Position = UDim2.new(0, 5, 0, (#savedCoords - 1) * 22)
        Label.BackgroundTransparency = 1
        Label.Text = coordText
        Label.TextColor3 = Color3.fromRGB(255,255,255)
        Label.TextXAlignment = Enum.TextXAlignment.Left

        -- Update canvas size
        ListFrame.CanvasSize = UDim2.new(0,0,0,#savedCoords * 22)
    end
end

-- Fungsi Copy
local function copyCoords()
    if #savedCoords > 0 then
        -- Gabung semua koordinat
        local allCoords = table.concat(savedCoords, "\n")

        -- Gunakan request API delta untuk copy (jika support)
        if setclipboard then
            setclipboard(allCoords)
        end
    end
end

-- Connect tombol
SnapBtn.MouseButton1Click:Connect(snapPosition)
CopyBtn.MouseButton1Click:Connect(copyCoords)
