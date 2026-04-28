--[[
    XYLUS X SILENT - ALL IN ONE
    Bypass Anti-Cheat (Silent) + Fitur Lengkap Xylus
    GUI: Linoria Library
]]

-- ==================== BYPASS ANTI-CHEAT (SILENT) ====================
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

-- ==================== LOAD LINORIA LIBRARY ====================
if not L then
    local libUrl = "https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"
    local libContent = game:HttpGet(libUrl)
    L = loadstring(libContent)()
end

-- ==================== SERVICES ====================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local VIM = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ==================== GUI WINDOW ====================
local Window = L:CreateWindow({
    Title = "XYLUS | All in One",
    Center = true,
    AutoShow = true,
    TabWidth = 120,
})

local CombatTab = Window:AddTab("Combat")
local PlayerTab = Window:AddTab("Player")
local TeleportTab = Window:AddTab("Teleport")
local VTeleportTab = Window:AddTab("VTeleport")
local VisualsTab = Window:AddTab("Visuals")
local SettingsTab = Window:AddTab("Settings")

-- ==================== SILENT AIM (CASTBLACKLIST HOOK) ====================
local SilentAim = false
local SilentAimPart = "HumanoidRootPart"
local SilentAimWallbang = false
local MaxWallbangDistance = 500

local FovCircle = Drawing.new("Circle")
FovCircle.Radius = 150
FovCircle.NumSides = 64
FovCircle.Thickness = 1.5
FovCircle.Visible = false
FovCircle.Color = Color3.fromRGB(0, 255, 0)
FovCircle.Transparency = 0.6
FovCircle.Filled = false

RunService.RenderStepped:Connect(function()
    FovCircle.Position = UserInputService:GetMouseLocation()
    FovCircle.Visible = SilentAim
end)

local function SearchGc(FunctionName)
    local gc = getgc(true)
    for _, v in pairs(gc) do
        if type(v) == "function" then
            local info = debug.getinfo(v)
            if info and info.name == FunctionName then
                return v
            end
        end
    end
    return nil
end

local function GetFovTarget(Circle, HitPart)
    local Target = nil
    local LowestDistance = math.huge
    for _, v in ipairs(Players:GetPlayers()) do
        if v ~= LocalPlayer then
            local Char = v.Character
            if Char then
                local Part = Char:FindFirstChild(HitPart)
                local Humanoid = Char:FindFirstChild("Humanoid")
                if Part and Humanoid and Humanoid.Health > 0 then
                    local ScreenPos, OnScreen = Camera:WorldToViewportPoint(Part.Position)
                    if OnScreen then
                        local Distance = (Circle.Position - Vector2.new(ScreenPos.X, ScreenPos.Y)).Magnitude
                        if Distance < Circle.Radius and Distance < LowestDistance then
                            Target = v
                            LowestDistance = Distance
                        end
                    end
                end
            end
        end
    end
    return Target
end

local CastBlacklist = SearchGc("CastBlacklist")
local CastWhitelist = SearchGc("CastWhitelist")

if CastBlacklist and CastWhitelist then
    local OldCastBlacklist = hookfunction(CastBlacklist, function(...)
        local Target = GetFovTarget(FovCircle, SilentAimPart)
        if Target and SilentAim then
            local args = {...}
            local part = Target.Character and Target.Character:FindFirstChild(SilentAimPart)
            if part then
                args[2] = part.Position - args[1]
                if SilentAimWallbang then
                    if args[2].Magnitude <= MaxWallbangDistance then
                        args[3] = {Target.Character}
                        return CastWhitelist(unpack(args))
                    end
                end
                return OldCastBlacklist(unpack(args))
            end
        end
        return OldCastBlacklist(...)
    end)
end

local groupSA = CombatTab:AddLeftGroupbox("Silent Aim")
groupSA:AddToggle("SilentToggle", {Text = "Silent Aim", Default = false, Callback = function(v) SilentAim = v end})
groupSA:AddDropdown("PartDropdown", {Text = "Target Part", Values = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"}, Default = 2, Callback = function(v) SilentAimPart = v end})
groupSA:AddSlider("FovSlider", {Text = "FOV Radius", Min = 10, Max = 500, Default = 150, Rounding = 0, Callback = function(v) FovCircle.Radius = v end})
groupSA:AddToggle("WallbangToggle", {Text = "Wallbang", Default = false, Callback = function(v) SilentAimWallbang = v end})
groupSA:AddSlider("WallbangDist", {Text = "Wallbang Distance", Min = 10, Max = 5000, Default = 500, Rounding = 0, Callback = function(v) MaxWallbangDistance = v end})

-- ==================== INFINITE STAMINA ====================
local StaminaGroup = PlayerTab:AddLeftGroupbox("Stamina")
local staminaHooked = false
local heartbeatConnection = nil

StaminaGroup:AddToggle("InfStaminaToggle", {
    Text = "Infinite Stamina",
    Default = false,
    Callback = function(Value)
        if Value and not staminaHooked then
            for _, v in pairs(getgc(true)) do
                if type(v) == "table" then
                    for k, _ in pairs(v) do
                        if k == "Stamina" then
                            local mt = getmetatable(v)
                            if mt then
                                setreadonly(mt, false)
                                local oldIndex = mt.__index
                                mt.__index = function(t, k2)
                                    if k2 == "Stamina" then return 100 end
                                    return oldIndex and oldIndex(t, k2)
                                end
                                staminaHooked = true
                            end
                            heartbeatConnection = RunService.Heartbeat:Connect(function()
                                if Value then v.Stamina = 100 end
                            end)
                            break
                        end
                    end
                end
                if staminaHooked then break end
            end
            L:Notify("✅ Infinite Stamina ON", 3)
        elseif not Value and heartbeatConnection then
            heartbeatConnection:Disconnect()
            heartbeatConnection = nil
            L:Notify("❌ Infinite Stamina OFF", 3)
        end
    end
})

-- ==================== TELEPORT (RESPAWN METHOD) ====================
local TeleportGroup = TeleportTab:AddLeftGroupbox("Teleport (Respawn)")

local tpLocs = {
    {"Dealership", 753.20, 4.63, 437.04},
    {"Jual/Beli Marshmellow", 510.996, 3.587, 598.393},
    {"Casino", 1154.86, 4.29, -46.85},
    {"GS Ujung", -465.51, 4.79, 360.47},
    {"GS Mid", 218.57, 4.65, -173.54},
    {"Apart 1 (Kompor)", 1141.80, 11.04, 450.35},
    {"Apart 2 (Kompor)", 1142.49, 11.04, 421.64},
    {"Apart 3 (Kompor)", 984.09, 11.03, 248.81},
    {"Apart 4 (Kompor)", 984.09, 11.06, 220.29},
    {"Bank", -43.01, 4.66, -353.96},
    {"Doa Turf", -331.58, 18.79, -462.96},
    {"YGZ Turf", 8.30, 17.82, 288.99},
    {"OGZ Turf", 113.04, 20.32, -509.80},
    {"GS Binary", -280.05, 4.68, 257.84},
    {"Jual Senjata", 80.45, 4.72, 37.38},
}

local tpDestination = nil
local isRespawning = false
local tpStatusLabel = TeleportGroup:AddLabel("Status: STANDBY")

local function onCharacterAdded(char)
    if not tpDestination then return end
    task.spawn(function()
        local hrp = char:WaitForChild("HumanoidRootPart", 10)
        local hum = char:WaitForChild("Humanoid", 10)
        if hrp and hum then
            repeat task.wait(0.1) until hum.Health > 0 and hum.Health == hum.MaxHealth
            task.wait(0.5)
            pcall(function() hrp.CFrame = CFrame.new(tpDestination.x, tpDestination.y + 3, tpDestination.z) end)
            tpStatusLabel:SetText("Status: ARRIVED")
            task.wait(2)
            tpStatusLabel:SetText("Status: STANDBY")
        end
        tpDestination = nil
        isRespawning = false
    end)
end

if LocalPlayer.Character then onCharacterAdded(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

local function tpTo(x, y, z)
    if isRespawning then L:Notify("Tunggu teleport selesai", 2) return end
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    tpDestination = {x = x, y = y, z = z}
    isRespawning = true
    tpStatusLabel:SetText("Status: KILL-RESPAWN-TP")
    if hum and hum.Health > 0 then hum.Health = 0 end
end

for _, loc in ipairs(tpLocs) do
    TeleportGroup:AddButton({Text = loc[1], Func = function() tpTo(loc[2], loc[3], loc[4]) end})
end

-- ==================== VEHICLE TELEPORT ====================
local VTeleportGroup = VTeleportTab:AddLeftGroupbox("Vehicle Teleport")

local cachedSeat = nil
local vehStatusLabel = VTeleportGroup:AddLabel("Kendaraan: Tidak ditemukan")

local function updateSeatCache()
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    cachedSeat = hum and hum.SeatPart or nil
    if cachedSeat then
        local vehModel = cachedSeat:FindFirstAncestorWhichIsA("Model")
        vehStatusLabel:SetText("Kendaraan: " .. (vehModel and vehModel.Name or cachedSeat.Name))
    else
        vehStatusLabel:SetText("Kendaraan: Tidak ditemukan")
    end
end

local function hookCharacter(char)
    local hum = char:WaitForChild("Humanoid", 10)
    if hum then
        hum:GetPropertyChangedSignal("SeatPart"):Connect(updateSeatCache)
        updateSeatCache()
    end
end

if LocalPlayer.Character then hookCharacter(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(hookCharacter)

local function tpVehicle(x, y, z)
    if not cachedSeat then L:Notify("Tidak di kendaraan", 2) return end
    local vehModel = cachedSeat:FindFirstAncestorWhichIsA("Model")
    if vehModel and vehModel.PrimaryPart then
        vehModel:SetPrimaryPartCFrame(CFrame.new(x, y + 2, z))
    elseif cachedSeat then
        cachedSeat.CFrame = CFrame.new(x, y + 2, z)
    end
    L:Notify("Teleport kendaraan", 2)
end

local vtpLocs = {
    {"Dealership", 753.20, 4.63, 437.04},
    {"Jual/Beli Marshmellow", 510.996, 3.587, 598.393},
    {"Casino", 1154.86, 4.29, -46.85},
    {"GS Ujung", -465.51, 4.79, 360.47},
    {"GS Mid", 218.57, 4.65, -173.54},
    {"Apart 1", 1108.93, 11.03, 455.77},
    {"Apart 2", 1109.15, 11.04, 427.29},
    {"Apart 3", 1017.93, 11.01, 243.27},
    {"Apart 4", 1018.19, 11.03, 214.68},
    {"Bank", -43.01, 4.66, -353.96},
    {"Pabrik Kentang", -493.88, 4.67, -437.11},
    {"Box", -492.35, 4.29, -38.15},
    {"Safe", 120.85, 4.30, -587.63},
}

for _, loc in ipairs(vtpLocs) do
    VTeleportGroup:AddButton({Text = loc[1], Func = function() tpVehicle(loc[2], loc[3], loc[4]) end})
end

-- ==================== VEHICLE FLY ====================
local VFlyGroup = VisualsTab:AddLeftGroupbox("Vehicle Fly")

local vFlyEnabled = false
local vFlySpeed = 60
local vFlyUp = false
local vFlyDown = false
local vFlyConn = nil
local vFlyStatusLabel = VFlyGroup:AddLabel("Status: Tidak di kendaraan")

VFlyGroup:AddToggle("VehicleFlyToggle", {
    Text = "Vehicle Fly",
    Default = false,
    Callback = function(v)
        vFlyEnabled = v
        if vFlyEnabled then
            if vFlyConn then vFlyConn:Disconnect() end
            vFlyConn = RunService.RenderStepped:Connect(function(dt)
                local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                local seat = hum and hum.SeatPart
                if not seat then
                    vFlyStatusLabel:SetText("Status: Tidak di kendaraan")
                    return
                end
                vFlyStatusLabel:SetText("Status: Terbang aktif")
                local model = seat:FindFirstAncestorOfClass("Model") or seat
                local root = model.PrimaryPart or seat
                local camCF = Camera.CFrame
                local fwd = Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z).Unit
                local rgt = Vector3.new(camCF.RightVector.X, 0, camCF.RightVector.Z).Unit
                local mv = Vector3.zero
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then mv = mv + fwd end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then mv = mv - fwd end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then mv = mv - rgt end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then mv = mv + rgt end
                if vFlyUp then mv = mv + Vector3.new(0, 1, 0) end
                if vFlyDown then mv = mv - Vector3.new(0, 1, 0) end
                pcall(function()
                    for _, p in pairs(model:GetDescendants()) do
                        if p:IsA("BasePart") then
                            p.AssemblyLinearVelocity = Vector3.zero
                            p.AssemblyAngularVelocity = Vector3.zero
                        end
                    end
                end)
                if mv.Magnitude > 0 then
                    local np = root.Position + mv.Unit * vFlySpeed * dt
                    pcall(function() model:PivotTo(CFrame.new(np, np + fwd)) end)
                end
            end)
        else
            if vFlyConn then vFlyConn:Disconnect(); vFlyConn = nil end
            vFlyUp = false; vFlyDown = false
            vFlyStatusLabel:SetText("Status: Tidak di kendaraan")
        end
    end
})

VFlyGroup:AddSlider("FlySpeedSlider", {Text = "Fly Speed", Min = 10, Max = 300, Default = 60, Rounding = 0, Callback = function(v) vFlySpeed = v end})
VFlyGroup:AddLabel("E = Naik | Q = Turun | WASD = Steer")

UserInputService.InputBegan:Connect(function(input, gpe)
    if not vFlyEnabled or gpe then return end
    if input.KeyCode == Enum.KeyCode.E then vFlyUp = true end
    if input.KeyCode == Enum.KeyCode.Q then vFlyDown = true end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.E then vFlyUp = false end
    if input.KeyCode == Enum.KeyCode.Q then vFlyDown = false end
end)

-- ==================== PLAYER ESP ====================
local ESPGroup = VisualsTab:AddRightGroupbox("Player ESP")

local espEnabled = false
local espMaxDist = 100
local espCache = {}
local espBoxColor = Color3.fromRGB(0, 255, 136)
local espNameColor = Color3.fromRGB(255, 255, 255)
local boxPadding = 4
local ESP_INTERVAL = 0.05
local espAccum = 0

local function createESP(player)
    if espCache[player] then
        for _, o in pairs(espCache[player]) do pcall(function() o:Remove() end) end
    end
    local box = Drawing.new("Square")
    box.Thickness = 1
    box.Color = espBoxColor
    box.Filled = false
    local nameL = Drawing.new("Text")
    nameL.Text = player.Name
    nameL.Size = 10
    nameL.Font = 1
    nameL.Color = espNameColor
    nameL.Outline = true
    nameL.Center = true
    local hpBg = Drawing.new("Square")
    hpBg.Thickness = 1
    hpBg.Color = Color3.fromRGB(30, 30, 30)
    hpBg.Filled = true
    local hpFl = Drawing.new("Square")
    hpFl.Thickness = 1
    hpFl.Color = Color3.fromRGB(0, 255, 80)
    hpFl.Filled = true
    local dL = Drawing.new("Text")
    dL.Size = 10
    dL.Font = 1
    dL.Color = Color3.fromRGB(180, 220, 255)
    dL.Outline = true
    dL.Center = true
    espCache[player] = {box, nameL, hpBg, hpFl, dL}
end

local function removeESP(player)
    if espCache[player] then
        for _, o in pairs(espCache[player]) do pcall(function() o:Remove() end) end
        espCache[player] = nil
    end
end

for _, plr in pairs(Players:GetPlayers()) do if plr ~= LocalPlayer then createESP(plr) end end
Players.PlayerAdded:Connect(function(p) if p ~= LocalPlayer then createESP(p) end end)
Players.PlayerRemoving:Connect(removeESP)

ESPGroup:AddToggle("PlayerESP", {Text = "Player ESP", Default = false, Callback = function(v) espEnabled = v end})
ESPGroup:AddSlider("ESPMaxDist", {Text = "Max Distance", Min = 10, Max = 500, Default = 100, Rounding = 0, Callback = function(v) espMaxDist = v end})
ESPGroup:AddLabel("Box | Name | HP Bar | Distance")

RunService.Heartbeat:Connect(function(dt)
    if not espEnabled then
        for _, drawings in pairs(espCache) do for _, o in pairs(drawings) do pcall(function() o.Visible = false end) end end
        return
    end
    espAccum = espAccum + dt
    if espAccum < ESP_INTERVAL then return end
    espAccum = 0
    local myChar = LocalPlayer.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myPos = myHRP and myHRP.Position
    local viewportX, viewportY = Camera.ViewportSize.X, Camera.ViewportSize.Y

    for player, drawings in pairs(espCache) do
        local box, nameL, hpBg, hpFl, dL = unpack(drawings)
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local head = char and char:FindFirstChild("Head")
        
        if not (char and hum and root and head and hum.Health > 0) then
            for _, o in pairs(drawings) do o.Visible = false end
        else
            local dist3D = myPos and (root.Position - myPos).Magnitude or 0
            if dist3D > espMaxDist then
                for _, o in pairs(drawings) do o.Visible = false end
            else
                local rootPos, rootOn = Camera:WorldToViewportPoint(root.Position)
                local headPos, headOn = Camera:WorldToViewportPoint(head.Position)
                local height = math.abs(headPos.Y - rootPos.Y) * 1.7 + (boxPadding * 2)
                local width = height * 0.55
                local boxX = rootPos.X - width / 2
                local boxY = headPos.Y - boxPadding
                local isVisible = (boxX + width > 0 and boxX < viewportX and boxY + height > 0 and boxY < viewportY)
                
                if not (rootOn and headOn and isVisible) then
                    for _, o in pairs(drawings) do o.Visible = false end
                else
                    box.Color = espBoxColor
                    box.Size = Vector2.new(width, height)
                    box.Position = Vector2.new(boxX, boxY)
                    box.Visible = true
                    
                    nameL.Text = player.Name
                    nameL.Color = espNameColor
                    nameL.Position = Vector2.new(rootPos.X, boxY - 14)
                    nameL.Visible = true
                    
                    local hpPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                    hpBg.Size = Vector2.new(4, height - 4)
                    hpBg.Position = Vector2.new(boxX - 8, boxY + 2)
                    hpBg.Visible = true
                    
                    hpFl.Color = Color3.fromRGB(255 * (1 - hpPercent), 255 * hpPercent, 80)
                    hpFl.Size = Vector2.new(2, (height - 6) * hpPercent)
                    hpFl.Position = Vector2.new(boxX - 7, boxY + 3 + (height - 6) * (1 - hpPercent))
                    hpFl.Visible = true
                    
                    dL.Text = math.floor(dist3D) .. "m"
                    dL.Position = Vector2.new(rootPos.X, boxY + height + 2)
                    dL.Visible = true
                end
            end
        end
    end
end)

-- ==================== SETTINGS ====================
local SettingsGroup = SettingsTab:AddLeftGroupbox("Settings")

local guiVisible = true
SettingsGroup:AddButton({
    Text = "Toggle GUI (Hide/Show)",
    Func = function()
        guiVisible = not guiVisible
        if guiVisible then Window:Show() else Window:Hide() end
    end
})

SettingsGroup:AddButton({
    Text = "Unload Script",
    Func = function()
        L:Unload()
        FovCircle:Remove()
        for _, drawings in pairs(espCache) do for _, o in pairs(drawings) do pcall(function() o:Remove() end) end end
        if heartbeatConnection then heartbeatConnection:Disconnect() end
        if vFlyConn then vFlyConn:Disconnect() end
    end
})

-- ==================== NOTIFIKASI ====================
L:Notify("XYLUS X SILENT | All in One Loaded!", 4)
print("✅ XYLUS X SILENT - Bypass aktif + Semua fitur siap")
