--[[
    SILENT HUB V2 - LIGHT THEME SIDEBAR GUI
    Tanpa Key System, Langsung tampil.
    Dilengkapi Bypass Anti-Cheat.
]]

-- ====================== BYPASS ANTI-CHEAT =======================
local Bypass = {
    Hooks = {},
    Stealth = {},
    Patterns = {}
}

Bypass.Hooks = {
    Trampoline = function(target, hook)
        local mt = getmetatable(target)
        if mt and mt.__index then
            local orig = mt.__index
            mt.__index = function(self, k)
                if k == "FindPartOnRay" or k == "FireServer" then
                    return hook
                end
                return orig(self, k)
            end
        end
        return hook
    end,
    Environment = function()
        local env = getfenv(2)
        setfenv(2, setmetatable({}, {
            __index = function(t, k)
                if k == "debug" or k == "shared" then return nil end
                return env[k]
            end,
            __newindex = function(t, k, v)
                if k ~= "LoadLibrary" then env[k] = v end
            end
        }))
    end
}

Bypass.Stealth = {
    Memory = function()
        local mt = getmetatable(game)
        if mt and mt.__index then
            mt.__index = newcclosure(function(self, k)
                if k == "Players" or k == "Workspace" then return rawget(self, k) end
                return mt.__index(self, k)
            end)
        end
    end,
    Drawing = function()
        local mt = getmetatable(Drawing)
        if mt and mt.__index then
            mt.__index = newcclosure(function(self, k)
                if k == "new" or k == "Create" then
                    return function(...)
                        local obj = mt.__index(self, k)(...)
                        obj.Visible = false
                        return obj
                    end
                end
                return mt.__index(self, k)
            end)
        end
    end
}

Bypass.Patterns = {
    Randomize = function()
        local mt = getmetatable(workspace)
        if mt and mt.__index then
            mt.__index = newcclosure(function(self, k)
                if k == "GetChildren" or k == "FindFirstChild" then
                    return function(...)
                        local result = mt.__index(self, k)(...)
                        if type(result) == "table" then
                            table.sort(result, function(a,b) return math.random() end)
                        end
                        return result
                    end
                end
                return mt.__index(self, k)
            end)
        end
    end,
    Obfuscate = function()
        local mt = getmetatable(game:GetService("Players"))
        if mt and mt.__index then
            mt.__index = newcclosure(function(self, k)
                if k == "LocalPlayer" then return nil end
                return mt.__index(self, k)
            end)
        end
    end
}

Bypass.Executor = function()
    while true do
        pcall(Bypass.Hooks.Environment)
        pcall(Bypass.Stealth.Memory)
        pcall(Bypass.Stealth.Drawing)
        pcall(Bypass.Patterns.Randomize)
        pcall(Bypass.Patterns.Obfuscate)
        wait(math.random(0.3, 1.5))
    end
end

spawn(function()
    Bypass.Executor()
    Bypass.Hooks.Trampoline(workspace, function(...) return nil end)
    Bypass.Hooks.Trampoline(game:GetService("ReplicatedStorage"), function(...) return nil end)
end)

-- ====================== SERVICES =======================
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ====================== FITUR STATE =======================
local Features = {
    NoClip = false,
    Wallbang = false,
    FlyVehicle = false,
    Aimbot = false,
    ESP = true,
    SpeedValue = 16,
    PlayerName = "",
    PlayerUsername = "",
    TierColor = "Default",
    ESPObjects = {}
}

-- ====================== FUNGSI UTILITY =======================
local function FindClosestPlayer()
    local closest, distance = nil, math.huge
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= Player and plr.Character and plr.Character:FindFirstChild("Head") then
            local headPos = plr.Character.Head.Position
            local camPos = Camera.CFrame.Position
            local dist = (headPos - camPos).Magnitude
            if dist < distance then
                distance = dist
                closest = plr
            end
        end
    end
    return closest
end

-- ====================== ESP (Drawing) =======================
local function UpdateESP()
    if not Features.ESP then
        for _, obj in pairs(Features.ESPObjects) do
            pcall(function() obj:Remove() end)
        end
        Features.ESPObjects = {}
        return
    end
    -- Hapus drawing lama
    for _, obj in pairs(Features.ESPObjects) do
        pcall(function() obj:Remove() end)
    end
    Features.ESPObjects = {}

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= Player then
            local char = plr.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local head = char:FindFirstChild("Head")
                if head then
                    local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                    if onScreen then
                        -- Nama
                        local nameText = Drawing.new("Text")
                        nameText.Text = plr.Name
                        nameText.Position = Vector2.new(pos.X - 30, pos.Y - 35)
                        nameText.Color = Color3.fromRGB(255,255,255)
                        nameText.Size = 16
                        nameText.Outline = true
                        nameText.Visible = true
                        table.insert(Features.ESPObjects, nameText)

                        -- Health bar (simulasi, karena tidak ada health, kita isi 100)
                        local healthBar = Drawing.new("Square")
                        healthBar.Position = Vector2.new(pos.X - 35, pos.Y + 10)
                        healthBar.Size = Vector2.new(70, 8)
                        healthBar.Color = Color3.fromRGB(255,0,0)
                        healthBar.Thickness = 1
                        healthBar.Filled = true
                        healthBar.Visible = true
                        table.insert(Features.ESPObjects, healthBar)

                        -- Box
                        local box = Drawing.new("Square")
                        box.Position = Vector2.new(pos.X - 35, pos.Y - 30)
                        box.Size = Vector2.new(70, 80)
                        box.Color = Color3.fromRGB(255,255,255)
                        box.Thickness = 1
                        box.Filled = false
                        box.Visible = true
                        table.insert(Features.ESPObjects, box)

                        -- Tracer
                        local tracer = Drawing.new("Line")
                        tracer.From = Vector2.new(pos.X, pos.Y)
                        tracer.To = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                        tracer.Color = Color3.fromRGB(255,0,0)
                        tracer.Thickness = 1
                        tracer.Visible = true
                        table.insert(Features.ESPObjects, tracer)
                    end
                end
            end
        end
    end
end

-- Loop ESP setiap frame
RunService.RenderStepped:Connect(function()
    pcall(UpdateESP)
end)

-- ====================== FITUR LOOPS =======================
local noclipConnection
local function ToggleNoClip()
    Features.NoClip = not Features.NoClip
    if Features.NoClip then
        noclipConnection = RunService.Stepped:Connect(function()
            local char = Player.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if noclipConnection then noclipConnection:Disconnect() end
    end
end

local wallbangConnection
local function ToggleWallbang()
    Features.Wallbang = not Features.Wallbang
    if Features.Wallbang then
        wallbangConnection = RunService.Stepped:Connect(function()
            local ray = Ray.new(Camera.CFrame.Position, Camera.CFrame.LookVector * 500)
            local hit, pos = Workspace:FindPartOnRay(ray, Player.Character)
            if hit and ReplicatedStorage:FindFirstChild("RemoteEvents") then
                ReplicatedStorage.RemoteEvents.FireServer:FireServer({Position = pos, Force = Vector3.new(9999,9999,9999)})
            end
        end)
    else
        if wallbangConnection then wallbangConnection:Disconnect() end
    end
end

local flyConnection
local function ToggleFlyVehicle()
    Features.FlyVehicle = not Features.FlyVehicle
    if Features.FlyVehicle then
        flyConnection = RunService.Stepped:Connect(function()
            local char = Player.Character
            if char and char:FindFirstChild("VehicleSeat") then
                local seat = char.VehicleSeat
                if seat and seat:FindFirstChild("PrimaryPart") then
                    local part = seat.PrimaryPart
                    part.Velocity = Vector3.zero
                    part.RotVelocity = Vector3.zero
                    part.CFrame = part.CFrame + Camera.CFrame.LookVector * 5
                end
            end
        end)
    else
        if flyConnection then flyConnection:Disconnect() end
    end
end

local aimbotConnection
local function ToggleAimbot()
    Features.Aimbot = not Features.Aimbot
    if Features.Aimbot then
        aimbotConnection = RunService.RenderStepped:Connect(function()
            local target = FindClosestPlayer()
            if target and target.Character and target.Character:FindFirstChild("Head") then
                local headPos = target.Character.Head.Position
                local screenPos, onScreen = Camera:WorldToViewportPoint(headPos)
                if onScreen then
                    UserInputService:SetMouseDeltaEnabled(false)
                    UserInputService:SetMousePosition(screenPos.X, screenPos.Y)
                end
            end
        end)
    else
        if aimbotConnection then aimbotConnection:Disconnect() end
    end
end

-- Slider Speed
local function SetSpeed(value)
    Features.SpeedValue = value
    local char = Player.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = value
        char.Humanoid.JumpPower = value
    end
end

-- Ganti nama (asumsi struktur game, sesuaikan)
local function ChangeName(value)
    local nameLabel = Workspace:FindFirstChild("Characters") and Workspace.Characters:FindFirstChild(Player.Name) and Workspace.Characters[Player.Name]:FindFirstChild("Head") and Workspace.Characters[Player.Name].Head:FindFirstChild("NameTag") and Workspace.Characters[Player.Name].Head.NameTag:FindFirstChild("MainFrame") and Workspace.Characters[Player.Name].Head.NameTag.MainFrame:FindFirstChild("NameLabel")
    if nameLabel then nameLabel.Text = value end
end

local function ChangeUsername(value)
    local usernameLabel = Workspace:FindFirstChild("Characters") and Workspace.Characters:FindFirstChild(Player.Name) and Workspace.Characters[Player.Name]:FindFirstChild("Head") and Workspace.Characters[Player.Name].Head:FindFirstChild("RankTag") and Workspace.Characters[Player.Name].Head.RankTag:FindFirstChild("MainFrame") and Workspace.Characters[Player.Name].Head.RankTag.MainFrame:FindFirstChild("NameLabel")
    if usernameLabel then usernameLabel.Text = value end
end

local TierColors = {
    Default = Color3.fromRGB(255,255,255),
    [1] = Color3.fromRGB(150,255,150),
    [2] = Color3.fromRGB(255,218,185),
    [3] = Color3.fromRGB(100,149,237)
}

local function SetTierColor(tier)
    Features.TierColor = tier
    local usernameLabel = Workspace:FindFirstChild("Characters") and Workspace.Characters:FindFirstChild(Player.Name) and Workspace.Characters[Player.Name]:FindFirstChild("Head") and Workspace.Characters[Player.Name].Head:FindFirstChild("RankTag") and Workspace.Characters[Player.Name].Head.RankTag:FindFirstChild("MainFrame") and Workspace.Characters[Player.Name].Head.RankTag.MainFrame:FindFirstChild("NameLabel")
    if usernameLabel then
        if tier == "Default" then
            usernameLabel.TextColor3 = Color3.fromRGB(255,255,255)
        else
            local tierNum = tonumber(string.match(tier, "%d"))
            if tierNum then usernameLabel.TextColor3 = TierColors[tierNum] end
        end
    end
end

-- ====================== GUI LIGHT THEME (SIDEBAR) =======================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SilentHubGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

-- Container utama (600x400)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 600, 0, 400)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(245,245,245)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0,12)
MainCorner.Parent = MainFrame
local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(200,200,200)
MainStroke.Thickness = 1
MainStroke.Parent = MainFrame

-- Sidebar (kiri, lebar 150)
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 150, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(255,255,255)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame
local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0,12)
SidebarCorner.Parent = Sidebar
-- Tutup sudut kanan sidebar biar rata
local SidebarMask = Instance.new("Frame")
SidebarMask.Size = UDim2.new(0, 12, 1, 0)
SidebarMask.Position = UDim2.new(1, -12, 0, 0)
SidebarMask.BackgroundColor3 = Color3.fromRGB(255,255,255)
SidebarMask.BorderSizePixel = 0
SidebarMask.Parent = Sidebar

-- Logo / Title di sidebar
local Logo = Instance.new("TextLabel")
Logo.Size = UDim2.new(1, 0, 0, 50)
Logo.Position = UDim2.new(0, 0, 0, 15)
Logo.BackgroundTransparency = 1
Logo.Text = "Silent Hub"
Logo.TextColor3 = Color3.fromRGB(66,133,244)
Logo.TextSize = 22
Logo.Font = Enum.Font.GothamBold
Logo.TextXAlignment = Enum.TextXAlignment.Center
Logo.Parent = Sidebar

-- List menu (tombol navigasi)
local MenuButtons = {}
local function CreateMenuButton(name, yPos, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.Position = UDim2.new(0.05, 0, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(240,240,240)
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(30,30,30)
    btn.TextSize = 14
    btn.Font = Enum.Font.GothamMedium
    btn.Parent = Sidebar
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0,8)
    btnCorner.Parent = btn
    btn.MouseButton1Click:Connect(callback)
    MenuButtons[name] = btn
    return btn
end

-- Area konten kanan (450x400)
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -160, 1, -20)
ContentFrame.Position = UDim2.new(0, 160, 0, 10)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- Halaman konten (stack)
local Pages = {}
local function CreatePage(name)
    local page = Instance.new("Frame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Parent = ContentFrame
    Pages[name] = page
    return page
end

-- Page General
local GeneralPage = CreatePage("General")
-- Page Combat
local CombatPage = CreatePage("Combat")
-- Page Visual
local VisualPage = CreatePage("Visual")

-- Fungsi untuk menampilkan page
local function ShowPage(name)
    for _, page in pairs(Pages) do
        page.Visible = false
    end
    if Pages[name] then
        Pages[name].Visible = true
    end
    -- Update style tombol
    for btnName, btn in pairs(MenuButtons) do
        if btnName == name then
            btn.BackgroundColor3 = Color3.fromRGB(66,133,244)
            btn.TextColor3 = Color3.fromRGB(255,255,255)
        else
            btn.BackgroundColor3 = Color3.fromRGB(240,240,240)
            btn.TextColor3 = Color3.fromRGB(30,30,30)
        end
    end
end

-- Buat tombol menu
CreateMenuButton("General", 80, function() ShowPage("General") end)
CreateMenuButton("Combat", 130, function() ShowPage("Combat") end)
CreateMenuButton("Visual", 180, function() ShowPage("Visual") end)

-- ====================== FUNGSI PEMBUAT KONTROL UI =======================
local function CreateLabel(parent, text, y)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -20, 0, 25)
    lbl.Position = UDim2.new(0, 10, 0, y)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(50,50,50)
    lbl.TextSize = 14
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = parent
    return lbl
end

local function CreateTextBox(parent, placeholder, y, callback)
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0.6, 0, 0, 35)
    box.Position = UDim2.new(0.1, 0, 0, y)
    box.BackgroundColor3 = Color3.fromRGB(255,255,255)
    box.BorderSizePixel = 0
    box.PlaceholderText = placeholder
    box.TextColor3 = Color3.fromRGB(30,30,30)
    box.Font = Enum.Font.Gotham
    box.TextSize = 14
    box.Parent = parent
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0,6)
    corner.Parent = box
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(200,200,200)
    stroke.Thickness = 1
    stroke.Parent = box
    box.FocusLost:Connect(function(enter)
        if enter then callback(box.Text) end
    end)
    return box
end

local function CreateDropdown(parent, items, default, y, callback)
    local dropdown = Instance.new("Frame")
    dropdown.Size = UDim2.new(0.4, 0, 0, 35)
    dropdown.Position = UDim2.new(0.1, 0, 0, y)
    dropdown.BackgroundColor3 = Color3.fromRGB(255,255,255)
    dropdown.BorderSizePixel = 0
    dropdown.Parent = parent
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0,6)
    corner.Parent = dropdown
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(200,200,200)
    stroke.Thickness = 1
    stroke.Parent = dropdown
    local selected = Instance.new("TextLabel")
    selected.Size = UDim2.new(1, -10, 1, 0)
    selected.Position = UDim2.new(0, 5, 0, 0)
    selected.BackgroundTransparency = 1
    selected.Text = default
    selected.TextColor3 = Color3.fromRGB(30,30,30)
    selected.TextXAlignment = Enum.TextXAlignment.Left
    selected.Font = Enum.Font.Gotham
    selected.TextSize = 14
    selected.Parent = dropdown
    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 20, 1, 0)
    arrow.Position = UDim2.new(1, -22, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.TextColor3 = Color3.fromRGB(100,100,100)
    arrow.TextSize = 12
    arrow.Parent = dropdown
    local listFrame = Instance.new("Frame")
    listFrame.Size = UDim2.new(1, 0, 0, #items * 30)
    listFrame.Position = UDim2.new(0, 0, 1, 0)
    listFrame.BackgroundColor3 = Color3.fromRGB(255,255,255)
    listFrame.BorderSizePixel = 0
    listFrame.Visible = false
    listFrame.Parent = dropdown
    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0,6)
    listCorner.Parent = listFrame
    local listStroke = Instance.new("UIStroke")
    listStroke.Color = Color3.fromRGB(200,200,200)
    listStroke.Thickness = 1
    listStroke.Parent = listFrame
    for i, item in ipairs(items) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 30)
        btn.Position = UDim2.new(0, 0, 0, (i-1)*30)
        btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
        btn.BorderSizePixel = 0
        btn.Text = item
        btn.TextColor3 = Color3.fromRGB(30,30,30)
        btn.TextSize = 13
        btn.Font = Enum.Font.Gotham
        btn.Parent = listFrame
        btn.MouseButton1Click:Connect(function()
            selected.Text = item
            listFrame.Visible = false
            callback(item)
        end)
    end
    dropdown.MouseButton1Click:Connect(function()
        listFrame.Visible = not listFrame.Visible
    end)
    return dropdown
end

local function CreateToggle(parent, text, y, getter, setter)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.9, 0, 0, 40)
    frame.Position = UDim2.new(0, 10, 0, y)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(50,50,50)
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 50, 0, 25)
    toggleBtn.Position = UDim2.new(0.8, 0, 0.5, -12)
    toggleBtn.BackgroundColor3 = getter() and Color3.fromRGB(52,168,83) or Color3.fromRGB(200,200,200)
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Text = getter() and "ON" or "OFF"
    toggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
    toggleBtn.TextSize = 12
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.Parent = frame
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1,0)
    corner.Parent = toggleBtn
    toggleBtn.MouseButton1Click:Connect(function()
        setter()
        toggleBtn.BackgroundColor3 = getter() and Color3.fromRGB(52,168,83) or Color3.fromRGB(200,200,200)
        toggleBtn.Text = getter() and "ON" or "OFF"
    end)
    return toggleBtn
end

local function CreateSlider(parent, text, min, max, default, y, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.9, 0, 0, 60)
    frame.Position = UDim2.new(0, 10, 0, y)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = text .. " (" .. default .. ")"
    label.TextColor3 = Color3.fromRGB(50,50,50)
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(0.8, 0, 0, 6)
    slider.Position = UDim2.new(0, 0, 0.5, -3)
    slider.BackgroundColor3 = Color3.fromRGB(220,220,220)
    slider.BorderSizePixel = 0
    slider.Parent = frame
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(1,0)
    sliderCorner.Parent = slider
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(66,133,244)
    fill.BorderSizePixel = 0
    fill.Parent = slider
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1,0)
    fillCorner.Parent = fill
    local knob = Instance.new("TextButton")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new((default-min)/(max-min), -8, 0.5, -8)
    knob.BackgroundColor3 = Color3.fromRGB(66,133,244)
    knob.BorderSizePixel = 0
    knob.Text = ""
    knob.Parent = slider
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1,0)
    knobCorner.Parent = knob
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.1, 0, 0, 20)
    valueLabel.Position = UDim2.new(0.85, 0, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(default)
    valueLabel.TextColor3 = Color3.fromRGB(66,133,244)
    valueLabel.TextSize = 12
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.Parent = frame

    local dragging = false
    knob.MouseButton1Down:Connect(function()
        dragging = true
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    frame.MouseMove:Connect(function()
        if dragging then
            local mousePos = UserInputService:GetMouseLocation()
            local framePos = slider.AbsolutePosition
            local width = slider.AbsoluteSize.X
            local percent = math.clamp((mousePos.X - framePos.X) / width, 0, 1)
            local newValue = math.floor(min + percent * (max - min))
            fill.Size = UDim2.new(percent, 0, 1, 0)
            knob.Position = UDim2.new(percent, -8, 0.5, -8)
            valueLabel.Text = tostring(newValue)
            label.Text = text .. " (" .. newValue .. ")"
            callback(newValue)
        end
    end)
    return slider
end

-- ====================== ISI HALAMAN =======================
-- General Page
CreateLabel(GeneralPage, "Change Name", 10)
CreateTextBox(GeneralPage, "New Name", 40, function(val) ChangeName(val) end)

CreateLabel(GeneralPage, "Change Username", 90)
CreateTextBox(GeneralPage, "New Username", 120, function(val) ChangeUsername(val) end)

CreateLabel(GeneralPage, "WalkSpeed / JumpPower", 170)
CreateSlider(GeneralPage, "Speed", 16, 50, 16, 200, function(val)
    SetSpeed(val)
end)

-- Combat Page
CreateToggle(CombatPage, "NoClip", 10, function() return Features.NoClip end, ToggleNoClip)
CreateToggle(CombatPage, "Wallbang", 60, function() return Features.Wallbang end, ToggleWallbang)
CreateToggle(CombatPage, "Fly Vehicle", 110, function() return Features.FlyVehicle end, ToggleFlyVehicle)
CreateToggle(CombatPage, "Aimbot", 160, function() return Features.Aimbot end, ToggleAimbot)

-- Visual Page
CreateToggle(VisualPage, "ESP", 10, function() return Features.ESP end, function()
    Features.ESP = not Features.ESP
end)

CreateLabel(VisualPage, "Tier Color", 70)
CreateDropdown(VisualPage, {"Default", "Tier 1", "Tier 2", "Tier 3"}, "Default", 100, function(val)
    SetTierColor(val)
end)

-- Tampilkan halaman pertama
ShowPage("General")
