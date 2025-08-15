local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

-- Fungsi notifikasi
local function notify(msg)
    StarterGui:SetCore("SendNotification", {
        Title = "Mimikri",
        Text = msg,
        Duration = 5
    })
end

-- Fungsi Mimikri
local function mimicOnce(targetUserId)
    local myChar = LocalPlayer.Character
    if not myChar then
        notify("Karakter kamu belum spawn!")
        return
    end

    local myHum = myChar:FindFirstChildOfClass("Humanoid")
    if not myHum then
        notify("Tidak menemukan Humanoid kamu!")
        return
    end

    local desc
    pcall(function()
        desc = Players:GetHumanoidDescriptionFromUserId(targetUserId)
    end)

    if not desc then
        notify("Gagal mengambil avatar target.")
        return
    end

    local oldHats = myHum:GetAccessories()

    myHum:ApplyDescription(desc)

    task.delay(0.5, function()
        local newHats = myHum:GetAccessories()
        if #newHats == #oldHats then
            notify("Gagal mimikri, kemungkinan game memblokir aksesoris/avatar.")
        else
            notify("Mimikri berhasil!")
        end
    end)
end

-- UI sederhana
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 250, 0, 300)
Frame.Position = UDim2.new(0, 50, 0.5, -150)
Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

local UIListLayout = Instance.new("UIListLayout", Frame)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Isi daftar player
local function refreshList()
    for _, child in ipairs(Frame:GetChildren()) do
        if child:IsA("Frame") and child.Name == "PlayerItem" then
            child:Destroy()
        end
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local item = Instance.new("Frame", Frame)
            item.Name = "PlayerItem"
            item.Size = UDim2.new(1, -10, 0, 30)
            item.BackgroundColor3 = Color3.fromRGB(60, 60, 60)

            local nameLabel = Instance.new("TextLabel", item)
            nameLabel.Size = UDim2.new(0.6, 0, 1, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.TextColor3 = Color3.new(1,1,1)
            nameLabel.Text = plr.Name .. " | " .. plr.DisplayName
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left

            local btn = Instance.new("TextButton", item)
            btn.Size = UDim2.new(0.4, 0, 1, 0)
            btn.Position = UDim2.new(0.6, 0, 0, 0)
            btn.Text = "Mimikri"
            btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
            btn.TextColor3 = Color3.new(1,1,1)

            btn.MouseButton1Click:Connect(function()
                mimicOnce(plr.UserId)
            end)
        end
    end
end

refreshList()

Players.PlayerAdded:Connect(refreshList)
Players.PlayerRemoving:Connect(refreshList)
