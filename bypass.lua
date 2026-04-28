--[[
    XYLENT HUB v1.0
    Dev: MASGAL x DRKY  |  Team: XYLENT TEAM
    Fitur: Silent Aim, NoClip, Aimbot, Player ESP, Stamina (opsional), Teleport, dll.
    Bypass Anti-Cheat aktif.
]]

-- ================================================================
-- BYPASS ANTI-CHEAT (Silent)
-- ================================================================
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

-- ================================================================
-- SERVICES
-- ================================================================
local Players      = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS          = game:GetService("UserInputService")
local RunService   = game:GetService("RunService")
local Camera       = workspace.CurrentCamera

local lp        = Players.LocalPlayer
local PlayerGui = lp:WaitForChild("PlayerGui")

-- cleanup
for _, old in pairs(PlayerGui:GetChildren()) do
    if old.Name == "XylentHub" then old:Destroy() end
end
task.wait(0.05)

-- ================================================================
-- PALETTE  (Light / White Clean)
-- ================================================================
local C = {
    BG       = Color3.fromRGB(245, 247, 252),
    SURF     = Color3.fromRGB(255, 255, 255),
    CARD     = Color3.fromRGB(237, 241, 251),
    CARD2    = Color3.fromRGB(226, 233, 248),
    STROKE   = Color3.fromRGB(208, 218, 238),
    STRKHI   = Color3.fromRGB(130, 165, 230),
    ACC      = Color3.fromRGB(66, 133, 244),
    ACCDIM   = Color3.fromRGB(180, 205, 248),
    ACCGLOW  = Color3.fromRGB(40, 100, 220),
    TEXT     = Color3.fromRGB(28, 32, 48),
    TEXTMID  = Color3.fromRGB(90, 100, 130),
    TEXTDIM  = Color3.fromRGB(160, 170, 195),
    GREEN    = Color3.fromRGB(52, 168, 83),
    RED      = Color3.fromRGB(220, 55, 68),
    GOLD     = Color3.fromRGB(218, 162, 0),
    DISCORD  = Color3.fromRGB(88, 101, 242),
    TIER1    = Color3.fromRGB(130, 220, 130),
    TIER2    = Color3.fromRGB(255, 213, 170),
    TIER3    = Color3.fromRGB(100, 149, 237),
    WHITE    = Color3.fromRGB(255, 255, 255),
    BLACK    = Color3.fromRGB(0, 0, 0),
}

-- ================================================================
-- TWEEN HELPER
-- ================================================================
local function tw(obj, props, t, sty, dir)
    TweenService:Create(obj,
        TweenInfo.new(t or 0.18,
            sty  or Enum.EasingStyle.Quint,
            dir  or Enum.EasingDirection.Out),
        props):Play()
end

local function makeDraggable(handle, target)
    local drag, ds, sp = false, nil, nil
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            drag = true; ds = i.Position; sp = target.Position
        end
    end)
    handle.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            drag = false
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement
                  or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - ds
            target.Position = UDim2.new(
                sp.X.Scale, sp.X.Offset + d.X,
                sp.Y.Scale, sp.Y.Offset + d.Y)
        end
    end)
end

-- ================================================================
-- SCREEN GUI ROOT
-- ================================================================
local Gui = Instance.new("ScreenGui")
Gui.Name             = "XylentHub"
Gui.ResetOnSpawn     = false
Gui.IgnoreGuiInset   = true
Gui.ZIndexBehavior   = Enum.ZIndexBehavior.Sibling
Gui.DisplayOrder     = 100
Gui.Parent           = PlayerGui

-- ================================================================
-- WINDOW   460 × 340  (compact)
-- ================================================================
local WW, WH = 460, 340
local TH     = 44   -- topbar
local TBH    = 30   -- tabbar
local CH     = WH - TH - TBH

local Win = Instance.new("Frame", Gui)
Win.Size             = UDim2.new(0, WW, 0, WH)
Win.Position         = UDim2.new(0.5, -WW/2, 0.5, -WH/2)
Win.BackgroundColor3 = C.BG
Win.BorderSizePixel  = 0
Win.ClipsDescendants = false
Instance.new("UICorner", Win).CornerRadius = UDim.new(0, 12)

local winStk = Instance.new("UIStroke", Win)
winStk.Color     = C.STROKE
winStk.Thickness = 1.2

-- drop shadow
local shadow = Instance.new("ImageLabel", Win)
shadow.Size               = UDim2.new(1, 30, 1, 30)
shadow.Position           = UDim2.new(0, -15, 0, -10)
shadow.BackgroundTransparency = 1
shadow.Image              = "rbxassetid://5554236805"
shadow.ImageColor3        = Color3.fromRGB(100, 130, 200)
shadow.ImageTransparency  = 0.82
shadow.ScaleType          = Enum.ScaleType.Slice
shadow.SliceCenter        = Rect.new(23,23,277,277)
shadow.ZIndex             = 0

-- ================================================================
-- TOPBAR
-- ================================================================
local TopBar = Instance.new("Frame", Win)
TopBar.Size             = UDim2.new(1, 0, 0, TH)
TopBar.BackgroundColor3 = C.SURF
TopBar.BorderSizePixel  = 0
TopBar.ZIndex           = 5
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 12)
-- fix lower corners
local tbFix = Instance.new("Frame", TopBar)
tbFix.Size             = UDim2.new(1, 0, 0, 12)
tbFix.Position         = UDim2.new(0, 0, 1, -12)
tbFix.BackgroundColor3 = C.SURF
tbFix.BorderSizePixel  = 0
-- separator
local tbSep = Instance.new("Frame", TopBar)
tbSep.Size             = UDim2.new(1, 0, 0, 1)
tbSep.Position         = UDim2.new(0, 0, 1, -1)
tbSep.BackgroundColor3 = C.STROKE
tbSep.BorderSizePixel  = 0

makeDraggable(TopBar, Win)

-- Logo dot
local dot = Instance.new("Frame", TopBar)
dot.Size             = UDim2.new(0, 8, 0, 8)
dot.Position         = UDim2.new(0, 14, 0.5, -4)
dot.BackgroundColor3 = C.ACC
dot.BorderSizePixel  = 0
dot.ZIndex           = 6
Instance.new("UICorner", dot).CornerRadius = UDim.new(0.5, 0)

task.spawn(function()
    while dot and dot.Parent do
        tw(dot, {BackgroundTransparency = 0.7}, 0.7, Enum.EasingStyle.Sine)
        task.wait(0.7)
        tw(dot, {BackgroundTransparency = 0}, 0.7, Enum.EasingStyle.Sine)
        task.wait(0.7)
    end
end)

-- Title
local titleL = Instance.new("TextLabel", TopBar)
titleL.Size              = UDim2.new(0, 220, 1, 0)
titleL.Position          = UDim2.new(0, 28, 0, 0)
titleL.BackgroundTransparency = 1
titleL.RichText          = true
titleL.Text = '<b><font color="rgb(28,32,48)">XYLENT</font></b><font color="rgb(90,100,130)"> HUB</font>'
titleL.TextColor3        = C.TEXT
titleL.Font              = Enum.Font.GothamBlack
titleL.TextSize          = 13
titleL.TextXAlignment    = Enum.TextXAlignment.Left
titleL.ZIndex            = 6

-- Version badge
local verF = Instance.new("Frame", TopBar)
verF.Size             = UDim2.new(0, 34, 0, 16)
verF.Position         = UDim2.new(0, 140, 0.5, -8)
verF.BackgroundColor3 = C.CARD
verF.BorderSizePixel  = 0
verF.ZIndex           = 6
Instance.new("UICorner", verF).CornerRadius = UDim.new(0, 4)
Instance.new("UIStroke", verF).Color = C.STROKE
local verL = Instance.new("TextLabel", verF)
verL.Size = UDim2.new(1,0,1,0); verL.BackgroundTransparency = 1
verL.Text = "v1.0"; verL.Font = Enum.Font.GothamBold
verL.TextSize = 8; verL.TextColor3 = C.TEXTMID; verL.ZIndex = 7

-- Close button
local closeBtn = Instance.new("TextButton", Win)
closeBtn.Size             = UDim2.new(0, 22, 0, 22)
closeBtn.Position         = UDim2.new(1, -32, 0, TH/2-11)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 235, 235)
closeBtn.Text             = "×"
closeBtn.TextColor3       = C.RED
closeBtn.Font             = Enum.Font.GothamBold
closeBtn.TextSize         = 14
closeBtn.BorderSizePixel  = 0
closeBtn.ZIndex           = 10
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0.5, 0)
closeBtn.MouseButton1Click:Connect(function()
    tw(Win, {Size = UDim2.new(0,0,0,0)}, 0.22, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    task.delay(0.25, function() Gui:Destroy() end)
end)
closeBtn.MouseEnter:Connect(function()
    tw(closeBtn, {BackgroundColor3 = C.RED}, 0.1)
    tw(closeBtn, {TextColor3 = C.WHITE}, 0.1)
end)
closeBtn.MouseLeave:Connect(function()
    tw(closeBtn, {BackgroundColor3 = Color3.fromRGB(255,235,235)}, 0.1)
    tw(closeBtn, {TextColor3 = C.RED}, 0.1)
end)

-- Minimize button
local minBtn = Instance.new("TextButton", Win)
minBtn.Size             = UDim2.new(0, 22, 0, 22)
minBtn.Position         = UDim2.new(1, -58, 0, TH/2-11)
minBtn.BackgroundColor3 = Color3.fromRGB(235, 240, 255)
minBtn.Text             = "—"
minBtn.TextColor3       = C.ACC
minBtn.Font             = Enum.Font.GothamBold
minBtn.TextSize         = 11
minBtn.BorderSizePixel  = 0
minBtn.ZIndex           = 10
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0.5, 0)

local bodyVisible = true
minBtn.MouseButton1Click:Connect(function()
    bodyVisible = not bodyVisible
    if bodyVisible then
        tw(Win, {Size = UDim2.new(0, WW, 0, WH)}, 0.25, Enum.EasingStyle.Back)
    else
        tw(Win, {Size = UDim2.new(0, WW, 0, TH+1)}, 0.22, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    end
end)

-- ================================================================
-- TAB BAR  (horizontal)
-- ================================================================
local TabBar = Instance.new("Frame", Win)
TabBar.Size             = UDim2.new(1, 0, 0, TBH)
TabBar.Position         = UDim2.new(0, 0, 0, TH)
TabBar.BackgroundColor3 = C.SURF
TabBar.BorderSizePixel  = 0
TabBar.ZIndex           = 4

local tbBot = Instance.new("Frame", TabBar)
tbBot.Size             = UDim2.new(1, 0, 0, 1)
tbBot.Position         = UDim2.new(0, 0, 1, -1)
tbBot.BackgroundColor3 = C.STROKE
tbBot.BorderSizePixel  = 0

-- Content area
local Content = Instance.new("Frame", Win)
Content.Size             = UDim2.new(1, 0, 0, CH)
Content.Position         = UDim2.new(0, 0, 0, TH + TBH)
Content.BackgroundColor3 = C.BG
Content.BorderSizePixel  = 0
Content.ClipsDescendants = true
Content.ZIndex           = 3

local TAB_NAMES = {"Main", "Combat", "Visual", "ESP", "Credit"}
local tabPages, tabBtns, activeIdx = {}, {}, 0
local tabW = WW / #TAB_NAMES

local function mkPage()
    local sf = Instance.new("ScrollingFrame", Content)
    sf.Size                = UDim2.new(1, 0, 1, 0)
    sf.BackgroundTransparency = 1
    sf.BorderSizePixel     = 0
    sf.ScrollBarThickness  = 3
    sf.ScrollBarImageColor3 = C.ACCDIM
    sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sf.CanvasSize          = UDim2.new(0, 0, 0, 0)
    sf.Visible             = false
    sf.ZIndex              = 4
    local ll = Instance.new("UIListLayout", sf)
    ll.SortOrder = Enum.SortOrder.LayoutOrder
    ll.Padding   = UDim.new(0, 8)
    local pd = Instance.new("UIPadding", sf)
    pd.PaddingTop    = UDim.new(0, 10)
    pd.PaddingBottom = UDim.new(0, 10)
    pd.PaddingLeft   = UDim.new(0, 10)
    pd.PaddingRight  = UDim.new(0, 10)
    return sf
end

local function setTabActive(btn, on)
    tw(btn, {BackgroundColor3 = on and C.CARD2 or C.SURF}, 0.12)
    local lb = btn:FindFirstChildOfClass("TextLabel")
    if lb then tw(lb, {TextColor3 = on and C.ACC or C.TEXTDIM}, 0.12) end
    local ab = btn:FindFirstChild("_ab")
    if ab then tw(ab, {BackgroundTransparency = on and 0 or 1}, 0.12) end
end

local function switchTab(i)
    if activeIdx > 0 and tabPages[activeIdx] then
        local old = tabPages[activeIdx]
        tw(old, {Position = UDim2.new(0, -8, 0, 0)}, 0.14, Enum.EasingStyle.Quint)
        task.delay(0.1, function()
            old.Visible   = false
            old.Position  = UDim2.new(0, 0, 0, 0)
        end)
        setTabActive(tabBtns[activeIdx], false)
    end
    activeIdx = i
    local pg = tabPages[i]
    pg.Visible   = true
    pg.Position  = UDim2.new(0, 8, 0, 0)
    tw(pg, {Position = UDim2.new(0, 0, 0, 0)}, 0.18, Enum.EasingStyle.Quint)
    setTabActive(tabBtns[i], true)
end

for i, name in ipairs(TAB_NAMES) do
    local btn = Instance.new("TextButton", TabBar)
    btn.Size             = UDim2.new(0, tabW, 1, 0)
    btn.Position         = UDim2.new(0, (i-1)*tabW, 0, 0)
    btn.BackgroundColor3 = C.SURF
    btn.BorderSizePixel  = 0
    btn.Text             = ""
    btn.ZIndex           = 5

    local lb = Instance.new("TextLabel", btn)
    lb.Size              = UDim2.new(1, 0, 1, 0)
    lb.BackgroundTransparency = 1
    lb.Text              = name
    lb.Font              = Enum.Font.GothamBold
    lb.TextSize          = 9
    lb.TextColor3        = C.TEXTDIM
    lb.ZIndex            = 6

    local ab = Instance.new("Frame", btn)
    ab.Name              = "_ab"
    ab.Size              = UDim2.new(0.55, 0, 0, 2)
    ab.AnchorPoint       = Vector2.new(0.5, 0)
    ab.Position          = UDim2.new(0.5, 0, 1, -2)
    ab.BackgroundColor3  = C.ACC
    ab.BorderSizePixel   = 0
    ab.BackgroundTransparency = 1
    ab.ZIndex            = 7
    Instance.new("UICorner", ab).CornerRadius = UDim.new(0.5, 0)

    if i < #TAB_NAMES then
        local sep = Instance.new("Frame", btn)
        sep.Size             = UDim2.new(0, 1, 0.5, 0)
        sep.Position         = UDim2.new(1, -1, 0.25, 0)
        sep.BackgroundColor3 = C.STROKE
        sep.BorderSizePixel  = 0
    end

    tabBtns[i]  = btn
    tabPages[i] = mkPage()
    btn.MouseButton1Click:Connect(function() switchTab(i) end)
end

-- ================================================================
-- WIDGET HELPERS
-- ================================================================
local function mkSection(page, txt, order)
    local r = Instance.new("Frame", page)
    r.Size                = UDim2.new(1, 0, 0, 18)
    r.BackgroundTransparency = 1
    r.LayoutOrder         = order
    local l = Instance.new("TextLabel", r)
    l.Size              = UDim2.new(1, -4, 1, 0)
    l.Position          = UDim2.new(0, 4, 0, 0)
    l.BackgroundTransparency = 1
    l.Text              = txt:upper()
    l.Font              = Enum.Font.GothamBold
    l.TextSize          = 7
    l.TextColor3        = C.TEXTDIM
    l.TextXAlignment    = Enum.TextXAlignment.Left
    l.ZIndex            = 5
    local line = Instance.new("Frame", r)
    line.Size             = UDim2.new(1, 0, 0, 1)
    line.Position         = UDim2.new(0, 0, 1, -1)
    line.BackgroundColor3 = C.STROKE
    line.BorderSizePixel  = 0
end

local function mkCard(page, h, order)
    local f = Instance.new("Frame", page)
    f.Size             = UDim2.new(1, 0, 0, h or 38)
    f.BackgroundColor3 = C.SURF
    f.BorderSizePixel  = 0
    f.LayoutOrder      = order or 0
    f.ZIndex           = 4
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)
    local s = Instance.new("UIStroke", f)
    s.Color = C.STROKE; s.Thickness = 1
    return f
end

-- Toggle with pill
local function mkToggle(page, txt, sub, order, cb)
    local h   = sub and 44 or 36
    local row = Instance.new("TextButton", page)
    row.Size             = UDim2.new(1, 0, 0, h)
    row.BackgroundColor3 = C.SURF
    row.BorderSizePixel  = 0
    row.LayoutOrder      = order
    row.Text             = ""
    row.ZIndex           = 4
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", row).Color = C.STROKE

    local lbl = Instance.new("TextLabel", row)
    lbl.Size              = UDim2.new(1, -52, 0, 16)
    lbl.Position          = UDim2.new(0, 10, 0, sub and 7 or 10)
    lbl.BackgroundTransparency = 1
    lbl.Text              = txt
    lbl.Font              = Enum.Font.GothamBold
    lbl.TextSize          = 10
    lbl.TextColor3        = C.TEXT
    lbl.TextXAlignment    = Enum.TextXAlignment.Left
    lbl.ZIndex            = 5

    if sub then
        local sl = Instance.new("TextLabel", row)
        sl.Size              = UDim2.new(1, -52, 0, 12)
        sl.Position          = UDim2.new(0, 10, 0, 25)
        sl.BackgroundTransparency = 1
        sl.Text              = sub
        sl.Font              = Enum.Font.Gotham
        sl.TextSize          = 8
        sl.TextColor3        = C.TEXTMID
        sl.TextXAlignment    = Enum.TextXAlignment.Left
        sl.ZIndex            = 5
    end

    local pill = Instance.new("Frame", row)
    pill.Size             = UDim2.new(0, 32, 0, 17)
    pill.Position         = UDim2.new(1, -42, 0.5, -8)
    pill.BackgroundColor3 = C.STROKE
    pill.BorderSizePixel  = 0
    pill.ZIndex           = 5
    Instance.new("UICorner", pill).CornerRadius = UDim.new(0.5, 0)

    local knob = Instance.new("Frame", pill)
    knob.Size             = UDim2.new(0, 12, 0, 12)
    knob.Position         = UDim2.new(0, 2, 0.5, -6)
    knob.BackgroundColor3 = C.WHITE
    knob.BorderSizePixel  = 0
    knob.ZIndex           = 6
    Instance.new("UICorner", knob).CornerRadius = UDim.new(0.5, 0)

    local on = false
    local function setState(v)
        on = v
        tw(pill,  {BackgroundColor3 = on and C.ACC or C.STROKE}, 0.16)
        tw(knob,  {
            Position         = on and UDim2.new(1,-14,0.5,-6) or UDim2.new(0,2,0.5,-6),
            BackgroundColor3 = on and C.WHITE or C.SURF,
        }, 0.16)
        tw(lbl, {TextColor3 = on and C.ACC or C.TEXT}, 0.12)
    end

    row.MouseButton1Click:Connect(function() setState(not on); if cb then cb(on) end end)
    row.MouseEnter:Connect(function() tw(row, {BackgroundColor3 = C.CARD}, 0.1) end)
    row.MouseLeave:Connect(function() tw(row, {BackgroundColor3 = C.SURF}, 0.1) end)
    return row, setState
end

-- Slider
local function mkSlider(page, label, minV, maxV, defV, order, cb)
    local row = mkCard(page, 52, order)

    local lbl = Instance.new("TextLabel", row)
    lbl.Size              = UDim2.new(0.65, 0, 0, 18)
    lbl.Position          = UDim2.new(0, 10, 0, 6)
    lbl.BackgroundTransparency = 1
    lbl.Text              = label
    lbl.Font              = Enum.Font.GothamBold
    lbl.TextSize          = 10
    lbl.TextColor3        = C.TEXT
    lbl.TextXAlignment    = Enum.TextXAlignment.Left
    lbl.ZIndex            = 5

    local valL = Instance.new("TextLabel", row)
    valL.Size              = UDim2.new(0.35, -10, 0, 18)
    valL.Position          = UDim2.new(0.65, 0, 0, 6)
    valL.BackgroundTransparency = 1
    valL.Text              = tostring(defV)
    valL.Font              = Enum.Font.GothamBold
    valL.TextSize          = 10
    valL.TextColor3        = C.ACC
    valL.TextXAlignment    = Enum.TextXAlignment.Right
    valL.ZIndex            = 5

    local track = Instance.new("Frame", row)
    track.Size             = UDim2.new(1, -20, 0, 5)
    track.Position         = UDim2.new(0, 10, 0, 34)
    track.BackgroundColor3 = C.CARD
    track.BorderSizePixel  = 0
    Instance.new("UICorner", track).CornerRadius = UDim.new(0, 3)

    local fill = Instance.new("Frame", track)
    fill.Size             = UDim2.new((defV-minV)/(maxV-minV), 0, 1, 0)
    fill.BackgroundColor3 = C.ACC
    fill.BorderSizePixel  = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 3)

    local knob = Instance.new("Frame", track)
    knob.Size             = UDim2.new(0, 13, 0, 13)
    knob.AnchorPoint      = Vector2.new(0.5, 0.5)
    knob.Position         = UDim2.new((defV-minV)/(maxV-minV), 0, 0.5, 0)
    knob.BackgroundColor3 = C.WHITE
    knob.BorderSizePixel  = 0
    knob.ZIndex           = 6
    Instance.new("UICorner", knob).CornerRadius = UDim.new(0.5, 0)
    local ks = Instance.new("UIStroke", knob); ks.Color = C.ACC; ks.Thickness = 1.5

    local hit = Instance.new("TextButton", track)
    hit.Size                 = UDim2.new(1, 0, 1, 20)
    hit.Position             = UDim2.new(0, 0, 0.5, -10)
    hit.BackgroundTransparency = 1
    hit.Text                 = ""
    hit.ZIndex               = 7

    local cur, sd = defV, false
    local function applyX(x)
        local ax, aw = track.AbsolutePosition.X, track.AbsoluteSize.X
        if aw <= 0 then return end
        local rel = math.clamp((x-ax)/aw, 0, 1)
        cur = math.floor(minV + (maxV-minV)*rel)
        fill.Size     = UDim2.new(rel, 0, 1, 0)
        knob.Position = UDim2.new(rel, 0, 0.5, 0)
        valL.Text     = tostring(cur)
        if cb then cb(cur) end
    end
    hit.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            sd=true; applyX(i.Position.X)
        end
    end)
    hit.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then sd=false end
    end)
    UIS.InputChanged:Connect(function(i)
        if not sd then return end
        if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then applyX(i.Position.X) end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then sd=false end
    end)
    return row
end

-- TextBox input
local function mkTextbox(page, label, placeholder, order, cb)
    local wrap = mkCard(page, 56, order)

    local lbl = Instance.new("TextLabel", wrap)
    lbl.Size              = UDim2.new(1, -20, 0, 14)
    lbl.Position          = UDim2.new(0, 10, 0, 6)
    lbl.BackgroundTransparency = 1
    lbl.Text              = label
    lbl.Font              = Enum.Font.GothamBold
    lbl.TextSize          = 9
    lbl.TextColor3        = C.TEXTMID
    lbl.TextXAlignment    = Enum.TextXAlignment.Left
    lbl.ZIndex            = 5

    local box = Instance.new("TextBox", wrap)
    box.Size              = UDim2.new(1, -20, 0, 24)
    box.Position          = UDim2.new(0, 10, 0, 24)
    box.BackgroundColor3  = C.CARD
    box.Font              = Enum.Font.Gotham
    box.TextSize          = 11
    box.TextColor3        = C.TEXT
    box.PlaceholderText   = placeholder or "Type here..."
    box.PlaceholderColor3 = C.TEXTDIM
    box.Text              = ""
    box.BorderSizePixel   = 0
    box.ClearTextOnFocus  = false
    box.ZIndex            = 5
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
    local bs = Instance.new("UIStroke", box); bs.Color = C.STROKE; bs.Thickness = 1
    local bp = Instance.new("UIPadding", box)
    bp.PaddingLeft = UDim.new(0, 8)

    box.Focused:Connect(function()
        tw(bs, {Color = C.ACC, Thickness = 1.5}, 0.15)
    end)
    box.FocusLost:Connect(function(enter)
        tw(bs, {Color = C.STROKE, Thickness = 1}, 0.15)
        if cb and enter then cb(box.Text) end
    end)

    return wrap, box
end

-- Dropdown (simple selector)
local function mkDropdown(page, label, options, order, cb)
    local h    = 24 + #options * 28
    local wrap = mkCard(page, h, order)

    local lbl = Instance.new("TextLabel", wrap)
    lbl.Size              = UDim2.new(1, -20, 0, 18)
    lbl.Position          = UDim2.new(0, 10, 0, 4)
    lbl.BackgroundTransparency = 1
    lbl.Text              = label
    lbl.Font              = Enum.Font.GothamBold
    lbl.TextSize          = 9
    lbl.TextColor3        = C.TEXTMID
    lbl.TextXAlignment    = Enum.TextXAlignment.Left
    lbl.ZIndex            = 5

    local selected = nil
    local btns = {}

    for idx, opt in ipairs(options) do
        local ob = Instance.new("TextButton", wrap)
        ob.Size             = UDim2.new(1, -20, 0, 22)
        ob.Position         = UDim2.new(0, 10, 0, 22 + (idx-1)*26)
        ob.BackgroundColor3 = C.CARD
        ob.Font             = Enum.Font.GothamBold
        ob.TextSize         = 9
        ob.TextColor3       = C.TEXTMID
        ob.Text             = opt
        ob.BorderSizePixel  = 0
        ob.ZIndex           = 5
        Instance.new("UICorner", ob).CornerRadius = UDim.new(0, 5)
        local obs = Instance.new("UIStroke", ob); obs.Color = C.STROKE; obs.Thickness = 1
        btns[opt] = {btn=ob, stk=obs}

        ob.MouseButton1Click:Connect(function()
            selected = opt
            for _, bd in pairs(btns) do
                tw(bd.btn, {BackgroundColor3 = C.CARD}, 0.12)
                bd.btn.TextColor3 = C.TEXTMID
                bd.stk.Color = C.STROKE
            end
            tw(ob, {BackgroundColor3 = C.ACCDIM}, 0.12)
            ob.TextColor3 = C.ACC
            obs.Color = C.ACC
            if cb then cb(opt) end
        end)
    end
    return wrap
end

local function mkBtn(page, txt, order, col, cb)
    local btn = Instance.new("TextButton", page)
    btn.Size             = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = col or C.SURF
    btn.BorderSizePixel  = 0
    btn.Text             = txt
    btn.TextColor3       = col and C.WHITE or C.TEXT
    btn.Font             = Enum.Font.GothamBold
    btn.TextSize         = 10
    btn.LayoutOrder      = order
    btn.ZIndex           = 4
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", btn).Color = col and col or C.STROKE
    btn.MouseEnter:Connect(function() tw(btn, {BackgroundColor3 = col and Color3.new(col.R*.9,col.G*.9,col.B*.9) or C.CARD}, 0.1) end)
    btn.MouseLeave:Connect(function() tw(btn, {BackgroundColor3 = col or C.SURF}, 0.1) end)
    if cb then btn.MouseButton1Click:Connect(cb) end
    return btn
end

-- ================================================================
-- PAGE 1 — MAIN (sama seperti sebelumnya)
-- ================================================================
local pMain = tabPages[1]

mkSection(pMain, "Movement", 1)
mkSlider(pMain, "Walk Speed", 16, 21, 16, 2, function(v)
    local char = lp.Character
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = v end
end)

mkSection(pMain, "Identity", 3)

local _, nameBox = mkTextbox(pMain, "Change Name", "Enter display name...", 4, function(text)
    if text == "" then return end
    pcall(function()
        local char  = workspace.Characters:FindFirstChild(lp.Name)
        local label = char.Head.NameTag.MainFrame.NameLabel
        label.Text  = text
    end)
end)

local _, usnBox = mkTextbox(pMain, "Change Username", "Enter username...", 5, function(text)
    if text == "" then return end
    pcall(function()
        local char  = workspace.Characters:FindFirstChild(lp.Name)
        local label = char.Head.RankTag.MainFrame.NameLabel
        label.Text  = text
    end)
end)

mkSection(pMain, "Username Color", 6)

local tierOptions = {"Default", "Tier 1 (Green)", "Tier 2 (Peach)", "Tier 3 (Blue)"}
local tierColors  = {
    ["Default"]          = Color3.fromRGB(255,255,255),
    ["Tier 1 (Green)"]   = C.TIER1,
    ["Tier 2 (Peach)"]   = C.TIER2,
    ["Tier 3 (Blue)"]    = C.TIER3,
}

mkDropdown(pMain, "Select Tier Color", tierOptions, 7, function(selected)
    local col = tierColors[selected]
    if not col then return end
    pcall(function()
        local char  = workspace.Characters:FindFirstChild(lp.Name)
        local label = char.Head.RankTag.MainFrame.NameLabel
        label.TextColor3 = col
    end)
end)

-- ================================================================
-- PAGE 2 — COMBAT (Silent Aim, NoClip, Aimbot)
-- ================================================================
local pCombat = tabPages[2]

-- ========== FITUR COMBAT ==========
mkSection(pCombat, "Silent Aim", 1)

local silentAimEnabled = false
local silentAimFov = 150
local silentAimPart = "HumanoidRootPart"
local FovCircle = Drawing.new("Circle")
FovCircle.Radius = silentAimFov
FovCircle.NumSides = 64
FovCircle.Thickness = 1.5
FovCircle.Visible = false
FovCircle.Color = Color3.fromRGB(0, 255, 0)
FovCircle.Transparency = 0.6
FovCircle.Filled = false

RunService.RenderStepped:Connect(function()
    FovCircle.Position = UIS:GetMouseLocation()
    FovCircle.Visible = silentAimEnabled
end)

-- Fungsi mencari target dalam FOV (digunakan untuk Silent Aim)
local function GetFovTarget()
    local Target = nil
    local LowestDistance = math.huge
    for _, v in ipairs(Players:GetPlayers()) do
        if v ~= lp then
            local Char = v.Character
            if Char then
                local Part = Char:FindFirstChild(silentAimPart)
                local Humanoid = Char:FindFirstChild("Humanoid")
                if Part and Humanoid and Humanoid.Health > 0 then
                    local ScreenPos, OnScreen = Camera:WorldToViewportPoint(Part.Position)
                    if OnScreen then
                        local Distance = (FovCircle.Position - Vector2.new(ScreenPos.X, ScreenPos.Y)).Magnitude
                        if Distance < FovCircle.Radius and Distance < LowestDistance then
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

-- Hook CastBlacklist untuk silent aim (bypass)
local function SetupSilentAim()
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
    local CastBlacklist = SearchGc("CastBlacklist")
    local CastWhitelist = SearchGc("CastWhitelist")
    if CastBlacklist and CastWhitelist then
        local OldCastBlacklist = hookfunction(CastBlacklist, function(...)
            local Target = GetFovTarget()
            if Target and silentAimEnabled then
                local args = {...}
                local part = Target.Character and Target.Character:FindFirstChild(silentAimPart)
                if part then
                    args[2] = part.Position - args[1]
                    return CastWhitelist(unpack(args))
                end
            end
            return OldCastBlacklist(...)
        end)
    end
end

-- Jalankan setup (hanya sekali)
pcall(SetupSilentAim)

-- Silent Aim Toggle
local saToggle, setSAToggle = mkToggle(pCombat, "Silent Aim", "Auto-aim ke target dalam FOV", 2, function(v) silentAimEnabled = v end)
-- FOV Slider
mkSlider(pCombat, "Silent Aim FOV", 10, 300, 150, 3, function(v) silentAimFov = v; FovCircle.Radius = v end)

-- Wallbang option (optional)
local wallbangEnabled = false
local wallbangToggle, setWallbang = mkToggle(pCombat, "Wallbang", "Shoot through walls (jika didukung)", 4, function(v) wallbangEnabled = v end)

-- NoClip
mkSection(pCombat, "Movement", 5)
local noclipEnabled = false
local noclipConn = nil
local noclipToggle, setNoclip = mkToggle(pCombat, "NoClip", "Melewati dinding", 6, function(v)
    noclipEnabled = v
    if noclipEnabled then
        noclipConn = RunService.Stepped:Connect(function()
            local char = lp.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
    end
end)

-- Aimbot (menggerakkan mouse ke target)
mkSection(pCombat, "Aimbot", 7)
local aimbotEnabled = false
local aimbotFov = 200
local aimbotConn = nil

local function FindClosestAimbotTarget()
    local closest, dist = nil, math.huge
    for _, v in ipairs(Players:GetPlayers()) do
        if v ~= lp then
            local char = v.Character
            if char and char:FindFirstChild("Head") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                local headPos = char.Head.Position
                local screenPos, onScreen = Camera:WorldToViewportPoint(headPos)
                if onScreen then
                    local mousePos = UIS:GetMouseLocation()
                    local d = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if d < aimbotFov and d < dist then
                        dist = d
                        closest = v
                    end
                end
            end
        end
    end
    return closest
end

local aimbotToggle, setAimbot = mkToggle(pCombat, "Aimbot", "Magnet mouse ke target", 8, function(v)
    aimbotEnabled = v
    if aimbotEnabled then
        if aimbotConn then aimbotConn:Disconnect() end
        aimbotConn = RunService.RenderStepped:Connect(function()
            local target = FindClosestAimbotTarget()
            if target and target.Character and target.Character:FindFirstChild("Head") then
                local headPos = target.Character.Head.Position
                local screenPos, onScreen = Camera:WorldToViewportPoint(headPos)
                if onScreen then
                    UIS:SetMouseDeltaEnabled(false)
                    UIS:SetMousePosition(screenPos.X, screenPos.Y)
                end
            end
        end)
    else
        if aimbotConn then aimbotConn:Disconnect(); aimbotConn = nil end
    end
end)
mkSlider(pCombat, "Aimbot FOV", 10, 400, 200, 9, function(v) aimbotFov = v end)

-- ================================================================
-- PAGE 3 — VISUAL (placeholder/info)
-- ================================================================
local pVisual = tabPages[3]
mkSection(pVisual, "Visual", 1)

local visCard = mkCard(pVisual, 36, 2)
local visL = Instance.new("TextLabel", visCard)
visL.Size              = UDim2.new(1,-20,1,0)
visL.Position          = UDim2.new(0,10,0,0)
visL.BackgroundTransparency = 1
visL.Text              = "Customization coming soon..."
visL.Font              = Enum.Font.Gotham
visL.TextSize          = 10
visL.TextColor3        = C.TEXTDIM
visL.TextXAlignment    = Enum.TextXAlignment.Left
visL.ZIndex            = 5

-- ================================================================
-- PAGE 4 — ESP (dari source Xylus)
-- ================================================================
local pESP = tabPages[4]

mkSection(pESP, "Player ESP", 1)

local espEnabled = false
local espMaxDist = 100
local espCache = {}
local espBoxColor = C.GREEN
local espNameColor = C.WHITE
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

for _, plr in pairs(Players:GetPlayers()) do if plr ~= lp then createESP(plr) end end
Players.PlayerAdded:Connect(function(p) if p ~= lp then createESP(p) end end)
Players.PlayerRemoving:Connect(removeESP)

local espToggle, setEspToggle = mkToggle(pESP, "Player ESP", "Box, Name, Health, Distance", 2, function(v) espEnabled = v end)
mkSlider(pESP, "Maximum Distance", 10, 500, 100, 3, function(v) espMaxDist = v end)

RunService.Heartbeat:Connect(function(dt)
    if not espEnabled then
        for _, drawings in pairs(espCache) do for _, o in pairs(drawings) do pcall(function() o.Visible = false end) end end
        return
    end
    espAccum = espAccum + dt
    if espAccum < ESP_INTERVAL then return end
    espAccum = 0
    local myChar = lp.Character
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
                local padding = 4
                local height = math.abs(headPos.Y - rootPos.Y) * 1.7 + (padding * 2)
                local width = height * 0.55
                local boxX = rootPos.X - width / 2
                local boxY = headPos.Y - padding
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

-- ================================================================
-- PAGE 5 — CREDIT (sama seperti asli)
-- ================================================================
local pCredit = tabPages[5]

local devCard = mkCard(pCredit, 70, 1)

local devTitle = Instance.new("TextLabel", devCard)
devTitle.Size              = UDim2.new(1,-20,0,22)
devTitle.Position          = UDim2.new(0,10,0,8)
devTitle.BackgroundTransparency = 1
devTitle.Text              = "XYLENT HUB  v1.0"
devTitle.Font              = Enum.Font.GothamBlack
devTitle.TextSize          = 14
devTitle.TextColor3        = C.TEXT
devTitle.TextXAlignment    = Enum.TextXAlignment.Left
devTitle.ZIndex            = 5

local devSub = Instance.new("TextLabel", devCard)
devSub.Size              = UDim2.new(1,-20,0,14)
devSub.Position          = UDim2.new(0,10,0,32)
devSub.BackgroundTransparency = 1
devSub.Text              = "Developed by  MASGAL × DRKY"
devSub.Font              = Enum.Font.GothamBold
devSub.TextSize          = 10
devSub.TextColor3        = C.ACC
devSub.TextXAlignment    = Enum.TextXAlignment.Left
devSub.ZIndex            = 5

local teamL = Instance.new("TextLabel", devCard)
teamL.Size              = UDim2.new(1,-20,0,12)
teamL.Position          = UDim2.new(0,10,0,48)
teamL.BackgroundTransparency = 1
teamL.Text              = "Team  ·  XYLENT TEAM"
teamL.Font              = Enum.Font.Gotham
teamL.TextSize          = 9
teamL.TextColor3        = C.TEXTMID
teamL.TextXAlignment    = Enum.TextXAlignment.Left
teamL.ZIndex            = 5

local gLine = Instance.new("Frame", devCard)
gLine.Size             = UDim2.new(0, 40, 0, 2)
gLine.AnchorPoint      = Vector2.new(0, 0)
gLine.Position         = UDim2.new(0, 10, 1, -3)
gLine.BackgroundColor3 = C.ACC
gLine.BorderSizePixel  = 0
gLine.ZIndex           = 5
Instance.new("UICorner", gLine).CornerRadius = UDim.new(0.5, 0)
task.spawn(function()
    while devCard and devCard.Parent do
        tw(gLine, {Size = UDim2.new(0,120,0,2)}, 1, Enum.EasingStyle.Sine)
        task.wait(1)
        tw(gLine, {Size = UDim2.new(0,40,0,2)}, 1, Enum.EasingStyle.Sine)
        task.wait(1)
    end
end)

mkSection(pCredit, "Pricing", 2)

local function mkPriceCard(page, name, price, dur, order, acol)
    local f = mkCard(page, 58, order)
    local bar = Instance.new("Frame", f)
    bar.Size             = UDim2.new(0, 3, 0.6, 0)
    bar.Position         = UDim2.new(0, 0, 0.2, 0)
    bar.BackgroundColor3 = acol or C.ACC
    bar.BorderSizePixel  = 0
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 2)

    local nl = Instance.new("TextLabel", f)
    nl.Position = UDim2.new(0,14,0,8); nl.Size = UDim2.new(0.55,0,0,18)
    nl.BackgroundTransparency = 1; nl.Text = name
    nl.Font = Enum.Font.GothamBold; nl.TextSize = 11
    nl.TextColor3 = C.TEXT; nl.TextXAlignment = Enum.TextXAlignment.Left; nl.ZIndex = 5

    local pl = Instance.new("TextLabel", f)
    pl.Position = UDim2.new(0,14,0,28); pl.Size = UDim2.new(0.55,0,0,14)
    pl.BackgroundTransparency = 1; pl.Text = price
    pl.Font = Enum.Font.Gotham; pl.TextSize = 9
    pl.TextColor3 = C.TEXTMID; pl.TextXAlignment = Enum.TextXAlignment.Left; pl.ZIndex = 5

    local db = Instance.new("Frame", f)
    db.Size = UDim2.new(0,70,0,22); db.Position = UDim2.new(1,-80,0.5,-11)
    db.BackgroundColor3 = C.CARD; db.BorderSizePixel = 0; db.ZIndex = 5
    Instance.new("UICorner", db).CornerRadius = UDim.new(0,6)
    local dbs = Instance.new("UIStroke", db); dbs.Color = acol or C.STROKE; dbs.Thickness = 1

    local dl = Instance.new("TextLabel", db)
    dl.Size = UDim2.new(1,0,1,0); dl.BackgroundTransparency = 1
    dl.Text = dur; dl.Font = Enum.Font.GothamBold; dl.TextSize = 9
    dl.TextColor3 = acol or C.ACC; dl.TextXAlignment = Enum.TextXAlignment.Center; dl.ZIndex = 6
end

mkPriceCard(pCredit, "Xylent Hub",  "IDR 20.000  /  USD $1.20", "3 Days",  3, C.ACC)

mkSection(pCredit, "Links", 4)
mkBtn(pCredit, "📋  Copy Discord Link", 5, C.DISCORD, function()
    pcall(function()
        if setclipboard then setclipboard("https://discord.gg/aNWNjArMQd") end
    end)
end)

local thanksF = mkCard(pCredit, 32, 6)
local thL = Instance.new("TextLabel", thanksF)
thL.Size = UDim2.new(1,0,1,0); thL.BackgroundTransparency = 1
thL.Text = "✦  Thanks for using Xylent Hub  ✦"
thL.Font = Enum.Font.GothamBold; thL.TextSize = 9
thL.TextColor3 = C.ACC; thL.TextXAlignment = Enum.TextXAlignment.Center; thL.ZIndex = 5

task.spawn(function()
    local t = 0
    while thL and thL.Parent do
        t = t + 0.025
        thL.TextColor3 = Color3.fromRGB(
            math.floor(66  + 40*math.sin(t)),
            math.floor(133 + 30*math.sin(t+2)),
            math.floor(244 - 20*math.sin(t+4))
        )
        task.wait(0.05)
    end
end)

-- ================================================================
-- STARTUP
-- ================================================================
Win.Size = UDim2.new(0, 0, 0, 0)
Win.BackgroundTransparency = 1
tw(Win, {Size = UDim2.new(0, WW, 0, WH)}, 0.4, Enum.EasingStyle.Back)
tw(Win, {BackgroundTransparency = 0}, 0.3, Enum.EasingStyle.Sine)

task.wait(0.1)
local w = 0
repeat RunService.RenderStepped:Wait(); w = w + 1 until w >= 2 or not Gui.Parent
task.wait(0.05)
switchTab(1)
