--[[
    SILENT HUB v1.0 — PREMIUM DARK EDITION (FINAL UPDATE)
    Dark · Grey · White | Glossy | Full Drag | Animated Minimize
    Dev: MASGAL x DRKY | Team: SILENT TEAM
]]

-- ================================================================
-- BYPASS (UNCHANGED)
-- ================================================================
local MemoryStoreService = game:GetService("MemoryStoreService")
local Bypass = { Hooks = {}, Stealth = {}, Patterns = {}, KillFakeHandshake = {} }
local function killFakeHandshake()
    local fake = MemoryStoreService:FindFirstChild("Hyphon_Check")
    if fake and fake:IsA("RemoteEvent") then pcall(function() fake:Destroy() end) end
end
killFakeHandshake()
Bypass.Hooks = {
    Trampoline = function(target, hook)
        local mt = getmetatable(target)
        if mt and mt.__index then local orig = mt.__index; mt.__index = function(self,k) if k=="FindPartOnRay" or k=="FireServer" then return hook end; return orig(self,k) end; return hook end
    end,
    Environment = function()
        local env = getfenv(2)
        setfenv(2, setmetatable({},{__index=function(t,k) if k=="debug" or k=="shared" then return nil end; return env[k] end, __newindex=function(t,k,v) if k~="LoadLibrary" then env[k]=v end end}))
    end,
    LightBypass = function()
        local mt = getmetatable(game:GetService("Lighting"))
        if mt and mt.__newindex then mt.__newindex = newcclosure(function(self,k,v) if k=="Brightness" or k=="GlobalShadows" or k=="FogEnd" then return rawset(self,k,v) end; return mt.__newindex(self,k,v) end) end
    end
}
Bypass.Stealth = {
    Memory = function()
        local mt = getmetatable(game)
        if mt and mt.__index then mt.__index = newcclosure(function(self,k) if k=="Players" or k=="Workspace" then return rawget(self,k) end; return mt.__index(self,k) end) end
    end,
    Drawing = function()
        local mt = getmetatable(Drawing)
        if mt and mt.__index then mt.__index = newcclosure(function(self,k) if k=="new" or k=="Create" then return function(...) local obj=mt.__index(self,k)(...); obj.Visible=false; return obj end end; return mt.__index(self,k) end) end
    end,
    Terrain = function()
        local terrain = workspace:FindFirstChild("Terrain")
        if terrain then local mt=getmetatable(terrain); if mt and mt.__index then mt.__index=newcclosure(function(self,k) if k=="WaterWaveSize" or k=="WaterWaveSpeed" then return function() return 0 end end; return mt.__index(self,k) end) end end
    end
}
Bypass.Patterns = {
    Randomize = function()
        local mt = getmetatable(workspace)
        if mt and mt.__index then mt.__index=newcclosure(function(self,k) if k=="GetChildren" or k=="FindFirstChild" then return function(...) local r=mt.__index(self,k)(...); if type(r)=="table" then table.sort(r,function() return math.random()>.5 end) end; return r end end; return mt.__index(self,k) end) end
    end,
    Obfuscate = function()
        local mt = getmetatable(game:GetService("Players"))
        if mt and mt.__index then mt.__index=newcclosure(function(self,k) if k=="LocalPlayer" then return nil end; return mt.__index(self,k) end) end
    end,
}
Bypass.Executor = function()
    while true do
        pcall(Bypass.Hooks.Environment); pcall(Bypass.Stealth.Memory); pcall(Bypass.Stealth.Drawing)
        pcall(Bypass.Patterns.Randomize); pcall(Bypass.Patterns.Obfuscate); pcall(Bypass.Hooks.LightBypass)
        pcall(Bypass.Stealth.Terrain); wait(math.random(0.3,1.5))
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
local Players    = game:GetService("Players")
local TS         = game:GetService("TweenService")
local UIS        = game:GetService("UserInputService")
local RS         = game:GetService("RunService")
local Camera     = workspace.CurrentCamera
local Lighting   = game:GetService("Lighting")
local lp         = Players.LocalPlayer
local PGui       = lp:WaitForChild("PlayerGui")

for _, old in pairs(PGui:GetChildren()) do if old.Name=="SilentHub" then old:Destroy() end end
task.wait(0.05)

-- ================================================================
-- PALETTE
-- ================================================================
local C = {
    BG       = Color3.fromRGB(10,  10,  13),
    SURF     = Color3.fromRGB(18,  18,  24),
    SURF2    = Color3.fromRGB(26,  26,  34),
    SURF3    = Color3.fromRGB(34,  34,  44),
    BORDER   = Color3.fromRGB(55,  55,  68),
    BORDERL  = Color3.fromRGB(85,  85,  100),
    TEXT     = Color3.fromRGB(235, 235, 240),
    TEXTM    = Color3.fromRGB(160, 160, 175),
    TEXTD    = Color3.fromRGB(90,  90,  108),
    WHITE    = Color3.fromRGB(255, 255, 255),
    GREY     = Color3.fromRGB(130, 130, 148),
    GREY2    = Color3.fromRGB(75,  75,  90),
    ACC      = Color3.fromRGB(200, 200, 215),
    ACCB     = Color3.fromRGB(255, 255, 255),
    GREEN    = Color3.fromRGB(72,  215, 115),
    RED      = Color3.fromRGB(255, 80,  80),
    YELLOW   = Color3.fromRGB(255, 205, 60),
    BLUE     = Color3.fromRGB(88,  101, 242),
    TIER1    = Color3.fromRGB(130, 220, 130),
    TIER2    = Color3.fromRGB(255, 213, 170),
    TIER3    = Color3.fromRGB(100, 149, 237),
}

-- ================================================================
-- TWEEN HELPER
-- ================================================================
local function tw(obj, props, t, sty, dir)
    TS:Create(obj, TweenInfo.new(t or .18, sty or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), props):Play()
end
local function twReturn(obj, props, t, sty, dir)
    local tr = TS:Create(obj, TweenInfo.new(t or .18, sty or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), props)
    tr:Play(); return tr
end

-- ================================================================
-- DRAGGABLE
-- ================================================================
local function makeDraggable(handle, target)
    local drag, ds, sp = false, nil, nil
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag=true; ds=i.Position; sp=target.Position
        end
    end)
    handle.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag=false end
    end)
    UIS.InputChanged:Connect(function(i)
        if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local d = i.Position - ds
            target.Position = UDim2.new(sp.X.Scale, sp.X.Offset+d.X, sp.Y.Scale, sp.Y.Offset+d.Y)
        end
    end)
end

-- ================================================================
-- SCREEN GUI
-- ================================================================
local Gui = Instance.new("ScreenGui")
Gui.Name="SilentHub"; Gui.ResetOnSpawn=false; Gui.IgnoreGuiInset=true
Gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; Gui.DisplayOrder=100; Gui.Parent=PGui

-- ================================================================
-- WINDOW
-- ================================================================
local WW, WH = 380, 340
local TH     = 44
local TBH    = 28
local CH     = WH - TH - TBH

local Win = Instance.new("Frame", Gui)
Win.Name="Win"
Win.Size     = UDim2.new(0,WW,0,WH)
Win.Position = UDim2.new(0.5,-WW/2,0.5,-WH/2)
Win.BackgroundColor3 = C.BG
Win.BorderSizePixel  = 0
Win.ClipsDescendants = false
Instance.new("UICorner", Win).CornerRadius = UDim.new(0,14)

local gloss = Instance.new("Frame", Win)
gloss.Size=UDim2.new(1,-20,0,1); gloss.Position=UDim2.new(0,10,0,1)
gloss.BackgroundColor3=Color3.fromRGB(255,255,255); gloss.BackgroundTransparency=0.72
gloss.BorderSizePixel=0; gloss.ZIndex=200
Instance.new("UICorner", gloss).CornerRadius=UDim.new(0,1)

local winStk = Instance.new("UIStroke", Win)
winStk.Thickness=1.5; winStk.Transparency=0
local strokeGrad = Instance.new("UIGradient", winStk)
strokeGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0,   Color3.fromRGB(180,180,195)),
    ColorSequenceKeypoint.new(0.35,Color3.fromRGB(255,255,255)),
    ColorSequenceKeypoint.new(0.65,Color3.fromRGB(255,255,255)),
    ColorSequenceKeypoint.new(1,   Color3.fromRGB(180,180,195)),
}
strokeGrad.Transparency = NumberSequence.new{
    NumberSequenceKeypoint.new(0,0.7),
    NumberSequenceKeypoint.new(0.15,0.05),
    NumberSequenceKeypoint.new(0.85,0.05),
    NumberSequenceKeypoint.new(1,0.7),
}
task.spawn(function()
    while Win and Win.Parent do
        tw(strokeGrad,{Rotation=(strokeGrad.Rotation or 0)+360},4.5,Enum.EasingStyle.Linear)
        task.wait(4.5)
    end
end)

-- ================================================================
-- TOP BAR
-- ================================================================
local TopBar = Instance.new("Frame", Win)
TopBar.Size=UDim2.new(1,0,0,TH); TopBar.Position=UDim2.new(0,0,0,0)
TopBar.BackgroundColor3=C.SURF; TopBar.BorderSizePixel=0; TopBar.ZIndex=5
Instance.new("UICorner", TopBar).CornerRadius=UDim.new(0,14)
local tbFix=Instance.new("Frame",TopBar); tbFix.Size=UDim2.new(1,0,0,14); tbFix.Position=UDim2.new(0,0,1,-14)
tbFix.BackgroundColor3=C.SURF; tbFix.BorderSizePixel=0
local tGloss=Instance.new("Frame",TopBar); tGloss.Size=UDim2.new(0.8,0,0,1); tGloss.Position=UDim2.new(0.1,0,0,1)
tGloss.BackgroundColor3=C.WHITE; tGloss.BackgroundTransparency=0.65; tGloss.BorderSizePixel=0; tGloss.ZIndex=6
local tbSep=Instance.new("Frame",TopBar); tbSep.Size=UDim2.new(1,0,0,1); tbSep.Position=UDim2.new(0,0,1,-1)
tbSep.BackgroundColor3=C.BORDER; tbSep.BorderSizePixel=0

makeDraggable(TopBar, Win)

local dot=Instance.new("Frame",TopBar); dot.Size=UDim2.new(0,7,0,7); dot.Position=UDim2.new(0,14,0.5,-3.5)
dot.BackgroundColor3=C.ACCB; dot.BorderSizePixel=0; dot.ZIndex=6; Instance.new("UICorner",dot).CornerRadius=UDim.new(0.5,0)
local dotGlow=Instance.new("Frame",dot); dotGlow.Size=UDim2.new(2,0,2,0); dotGlow.Position=UDim2.new(-0.5,0,-0.5,0)
dotGlow.BackgroundColor3=C.ACCB; dotGlow.BackgroundTransparency=0.7; dotGlow.BorderSizePixel=0; dotGlow.ZIndex=5
Instance.new("UICorner",dotGlow).CornerRadius=UDim.new(0.5,0)
task.spawn(function()
    while dot and dot.Parent do
        tw(dotGlow,{BackgroundTransparency=0.4,Size=UDim2.new(2.8,0,2.8,0),Position=UDim2.new(-0.9,0,-0.9,0)},0.9,Enum.EasingStyle.Sine)
        task.wait(0.9)
        tw(dotGlow,{BackgroundTransparency=0.85,Size=UDim2.new(2,0,2,0),Position=UDim2.new(-0.5,0,-0.5,0)},0.9,Enum.EasingStyle.Sine)
        task.wait(0.9)
    end
end)

local titleL=Instance.new("TextLabel",TopBar); titleL.Size=UDim2.new(0,160,1,0); titleL.Position=UDim2.new(0,28,0,0)
titleL.BackgroundTransparency=1; titleL.RichText=true
titleL.Text='<b><font color="rgb(255,255,255)">SILENT</font></b><font color="rgb(150,150,165)"> HUB</font>'
titleL.Font=Enum.Font.GothamBlack; titleL.TextSize=12; titleL.TextXAlignment=Enum.TextXAlignment.Left; titleL.ZIndex=6

local verF=Instance.new("Frame",TopBar); verF.Size=UDim2.new(0,28,0,13); verF.Position=UDim2.new(0,115,0.5,-6.5)
verF.BackgroundColor3=C.SURF2; verF.BorderSizePixel=0; verF.ZIndex=6; Instance.new("UICorner",verF).CornerRadius=UDim.new(0,4)
Instance.new("UIStroke",verF).Color=C.BORDER
local verL=Instance.new("TextLabel",verF); verL.Size=UDim2.new(1,0,1,0); verL.BackgroundTransparency=1
verL.Text="v1.0"; verL.Font=Enum.Font.GothamBold; verL.TextSize=7; verL.TextColor3=C.TEXTM; verL.ZIndex=7

local btnGroup = Instance.new("Frame", TopBar)
btnGroup.Size        = UDim2.new(0, 54, 0, 24)
btnGroup.Position    = UDim2.new(1, -62, 0.5, -12)
btnGroup.BackgroundTransparency = 1
btnGroup.ZIndex      = 10

local function makeWinBtn(parent, xPos, bgCol, fgCol, label)
    local shadow = Instance.new("Frame", parent)
    shadow.Size              = UDim2.new(0, 22, 0, 22)
    shadow.Position          = UDim2.new(0, xPos+1, 0.5, -10)
    shadow.BackgroundColor3  = Color3.fromRGB(0,0,0)
    shadow.BackgroundTransparency = 0.55
    shadow.BorderSizePixel   = 0
    shadow.ZIndex            = 9
    Instance.new("UICorner", shadow).CornerRadius = UDim.new(0.5,0)

    local btn = Instance.new("TextButton", parent)
    btn.Size             = UDim2.new(0, 22, 0, 22)
    btn.Position         = UDim2.new(0, xPos, 0.5, -11)
    btn.BackgroundColor3 = bgCol
    btn.Text             = label
    btn.TextColor3       = fgCol
    btn.Font             = Enum.Font.GothamBold
    btn.TextSize         = 14
    btn.BorderSizePixel  = 0
    btn.ZIndex           = 10
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0.5, 0)

    local stk = Instance.new("UIStroke", btn)
    stk.Color        = C.BORDERL
    stk.Thickness    = 0.8
    stk.Transparency = 0.5

    btn.MouseEnter:Connect(function()
        tw(btn, {BackgroundColor3 = fgCol, TextColor3 = bgCol}, .12)
        tw(shadow, {BackgroundTransparency = 0.35}, .12)
    end)
    btn.MouseLeave:Connect(function()
        tw(btn, {BackgroundColor3 = bgCol, TextColor3 = fgCol}, .12)
        tw(shadow, {BackgroundTransparency = 0.55}, .12)
    end)
    return btn
end

local closeBtn = makeWinBtn(btnGroup, 32, Color3.fromRGB(55,15,15), Color3.fromRGB(255,80,80), "×")
local minBtn   = makeWinBtn(btnGroup,  0, C.SURF2,                  C.GREY,                     "—")

closeBtn.MouseButton1Click:Connect(function()
    tw(Win,{Size=UDim2.new(0,0,0,0),BackgroundTransparency=1},0.22,Enum.EasingStyle.Back,Enum.EasingDirection.In)
    task.delay(0.25,function() Gui:Destroy() end)
end)

-- ================================================================
-- MINIMIZE HEADER
-- ================================================================
local minHeader = nil
local isMin     = false

local function buildMinHeader()
    if minHeader then minHeader:Destroy() end
    local mh = Instance.new("TextButton", Gui)
    mh.Name="MinHeader"
    mh.Size=UDim2.new(0,0,0,0)
    mh.Position=UDim2.new(0,14,0.5,-23)
    mh.BackgroundColor3=C.SURF
    mh.Text=""; mh.ZIndex=200
    mh.BorderSizePixel=0
    Instance.new("UICorner",mh).CornerRadius=UDim.new(0,13)
    minHeader=mh

    local outerStk=Instance.new("UIStroke",mh)
    outerStk.Color=Color3.fromRGB(145,145,160); outerStk.Thickness=2.2

    local innerRing=Instance.new("Frame",mh)
    innerRing.Size=UDim2.new(1,-8,1,-8); innerRing.Position=UDim2.new(0,4,0,4)
    innerRing.BackgroundTransparency=1; innerRing.ZIndex=201
    Instance.new("UICorner",innerRing).CornerRadius=UDim.new(0,9)
    local innerStk=Instance.new("UIStroke",innerRing)
    innerStk.Color=Color3.fromRGB(85,85,100); innerStk.Thickness=1.2

    local sheen=Instance.new("Frame",mh); sheen.Size=UDim2.new(0.7,0,0,1)
    sheen.Position=UDim2.new(0.15,0,0,2); sheen.BackgroundColor3=C.WHITE
    sheen.BackgroundTransparency=0.55; sheen.BorderSizePixel=0; sheen.ZIndex=202
    Instance.new("UICorner",sheen).CornerRadius=UDim.new(0,1)

    local sLbl=Instance.new("TextLabel",mh)
    sLbl.Size=UDim2.new(1,0,1,0); sLbl.BackgroundTransparency=1
    sLbl.Text="S"; sLbl.TextColor3=C.TEXT
    sLbl.Font=Enum.Font.GothamBlack; sLbl.TextSize=0
    sLbl.TextXAlignment=Enum.TextXAlignment.Center; sLbl.TextYAlignment=Enum.TextYAlignment.Center
    sLbl.ZIndex=203

    task.spawn(function()
        tw(mh,{Size=UDim2.new(0,46,0,46)},0.3,Enum.EasingStyle.Back,Enum.EasingDirection.Out)
        task.wait(0.18)
        tw(sLbl,{TextSize=28,TextTransparency=0},0.25,Enum.EasingStyle.Quint)
    end)

    mh.MouseEnter:Connect(function()
        tw(mh,{BackgroundColor3=C.SURF2},.14)
        tw(outerStk,{Color=C.ACCB,Transparency=0},.14)
    end)
    mh.MouseLeave:Connect(function()
        tw(mh,{BackgroundColor3=C.SURF},.14)
        tw(outerStk,{Color=Color3.fromRGB(145,145,160)},.14)
    end)

    mh.MouseButton1Click:Connect(function()
        isMin=false
        tw(sLbl,{TextSize=0,TextTransparency=1},0.15,Enum.EasingStyle.Quint)
        tw(mh,{Size=UDim2.new(0,0,0,0)},0.22,Enum.EasingStyle.Back,Enum.EasingDirection.In)
        task.delay(0.22,function() if mh and mh.Parent then mh:Destroy() end; minHeader=nil end)
        Win.Visible=true
        Win.Size=UDim2.new(0,0,0,0); Win.BackgroundTransparency=1
        tw(Win,{Size=UDim2.new(0,WW,0,WH),BackgroundTransparency=0},0.35,Enum.EasingStyle.Back,Enum.EasingDirection.Out)
    end)
end

minBtn.MouseButton1Click:Connect(function()
    if isMin then return end
    isMin=true
    local shrink=twReturn(Win,{Size=UDim2.new(0,0,0,0),BackgroundTransparency=1},0.2,Enum.EasingStyle.Back,Enum.EasingDirection.In)
    shrink.Completed:Connect(function()
        if isMin then Win.Visible=false; buildMinHeader() end
    end)
end)

-- ================================================================
-- TAB BAR (ORDER: MAIN, PLAYER, TELEPORT, ESP, OPTI, CREDIT)
-- ================================================================
local TAB_NAMES = {"Main","Player","Teleport","ESP","Opti","Credit"}
local tabW      = WW / #TAB_NAMES

local TabBar=Instance.new("Frame",Win)
TabBar.Size=UDim2.new(1,0,0,TBH); TabBar.Position=UDim2.new(0,0,0,TH)
TabBar.BackgroundColor3=C.SURF; TabBar.BorderSizePixel=0; TabBar.ZIndex=4
local tbBot=Instance.new("Frame",TabBar); tbBot.Size=UDim2.new(1,0,0,1); tbBot.Position=UDim2.new(0,0,1,-1)
tbBot.BackgroundColor3=C.BORDER; tbBot.BorderSizePixel=0

local Content=Instance.new("Frame",Win)
Content.Size=UDim2.new(1,0,0,CH); Content.Position=UDim2.new(0,0,0,TH+TBH)
Content.BackgroundColor3=C.BG; Content.BorderSizePixel=0; Content.ClipsDescendants=true; Content.ZIndex=3

local tabPages,tabBtns,activeIdx={},{},0

local function mkPage()
    local sf=Instance.new("ScrollingFrame",Content)
    sf.Size=UDim2.new(1,0,1,0); sf.BackgroundTransparency=1; sf.BorderSizePixel=0
    sf.ScrollBarThickness=2; sf.ScrollBarImageColor3=C.GREY2
    sf.AutomaticCanvasSize=Enum.AutomaticSize.Y; sf.CanvasSize=UDim2.new(0,0,0,0)
    sf.Visible=false; sf.ZIndex=4
    local ll=Instance.new("UIListLayout",sf); ll.SortOrder=Enum.SortOrder.LayoutOrder; ll.Padding=UDim.new(0,5)
    local pd=Instance.new("UIPadding",sf)
    pd.PaddingTop=UDim.new(0,7); pd.PaddingBottom=UDim.new(0,7)
    pd.PaddingLeft=UDim.new(0,7); pd.PaddingRight=UDim.new(0,7)
    return sf
end

local function setTabActive(btn, on)
    tw(btn,{BackgroundColor3=on and C.SURF2 or C.SURF},0.14)
    local lb=btn:FindFirstChildOfClass("TextLabel"); if lb then tw(lb,{TextColor3=on and C.ACC or C.TEXTD},0.14) end
    local ab=btn:FindFirstChild("_ab"); if ab then tw(ab,{BackgroundTransparency=on and 0 or 1,Size=on and UDim2.new(0.7,0,0,2) or UDim2.new(0.3,0,0,2)},0.18) end
end

local function switchTab(i)
    if activeIdx>0 and tabPages[activeIdx] then
        local old=tabPages[activeIdx]
        tw(old,{Position=UDim2.new(0,-6,0,0)},0.13); task.delay(0.1,function() old.Visible=false; old.Position=UDim2.new(0,0,0,0) end)
        setTabActive(tabBtns[activeIdx],false)
    end
    activeIdx=i; local pg=tabPages[i]; pg.Visible=true; pg.Position=UDim2.new(0,6,0,0)
    tw(pg,{Position=UDim2.new(0,0,0,0)},0.18); setTabActive(tabBtns[i],true)
end

for i, name in ipairs(TAB_NAMES) do
    local btn=Instance.new("TextButton",TabBar)
    btn.Size=UDim2.new(0,tabW,1,0); btn.Position=UDim2.new(0,(i-1)*tabW,0,0)
    btn.BackgroundColor3=C.SURF; btn.BorderSizePixel=0; btn.Text=""; btn.ZIndex=5
    local lb=Instance.new("TextLabel",btn); lb.Size=UDim2.new(1,0,1,0); lb.BackgroundTransparency=1
    lb.Text=name; lb.Font=Enum.Font.GothamBold; lb.TextSize=8; lb.TextColor3=C.TEXTD; lb.ZIndex=6
    local ab=Instance.new("Frame",btn); ab.Name="_ab"
    ab.Size=UDim2.new(0.3,0,0,2); ab.AnchorPoint=Vector2.new(0.5,0); ab.Position=UDim2.new(0.5,0,1,-2)
    ab.BackgroundColor3=C.ACCB; ab.BorderSizePixel=0; ab.BackgroundTransparency=1; ab.ZIndex=7
    Instance.new("UICorner",ab).CornerRadius=UDim.new(0.5,0)
    if i<#TAB_NAMES then
        local sep=Instance.new("Frame",btn); sep.Size=UDim2.new(0,1,0.4,0); sep.Position=UDim2.new(1,-1,0.3,0)
        sep.BackgroundColor3=C.BORDER; sep.BorderSizePixel=0
    end
    tabBtns[i]=btn; tabPages[i]=mkPage()
    btn.MouseButton1Click:Connect(function() switchTab(i) end)
end

-- ================================================================
-- WIDGET HELPERS
-- ================================================================
local function mkSection(page, txt, order)
    local r=Instance.new("Frame",page); r.Size=UDim2.new(1,0,0,14); r.BackgroundTransparency=1; r.LayoutOrder=order
    local l=Instance.new("TextLabel",r); l.Size=UDim2.new(1,-4,1,0); l.Position=UDim2.new(0,4,0,0)
    l.BackgroundTransparency=1; l.Text=txt:upper(); l.Font=Enum.Font.GothamBold; l.TextSize=6; l.TextColor3=C.TEXTD
    l.TextXAlignment=Enum.TextXAlignment.Left; l.ZIndex=5
    local ln=Instance.new("Frame",r); ln.Size=UDim2.new(1,0,0,1); ln.Position=UDim2.new(0,0,1,-1)
    ln.BackgroundColor3=C.BORDER; ln.BorderSizePixel=0
end

local function mkCard(page, h, order)
    local f=Instance.new("Frame",page); f.Size=UDim2.new(1,0,0,h or 34)
    f.BackgroundColor3=C.SURF2; f.BorderSizePixel=0; f.LayoutOrder=order or 0; f.ZIndex=4
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,8)
    Instance.new("UIStroke",f).Color=C.BORDER
    local g=Instance.new("Frame",f); g.Size=UDim2.new(0.6,0,0,1); g.Position=UDim2.new(0.2,0,0,1)
    g.BackgroundColor3=C.WHITE; g.BackgroundTransparency=0.8; g.BorderSizePixel=0; g.ZIndex=5
    return f
end

local function mkAlertCard(page, shadowColor, title, text, order)
    local con=Instance.new("Frame",page); con.Size=UDim2.new(1,0,0,56); con.BackgroundTransparency=1; con.LayoutOrder=order; con.ZIndex=4; con.ClipsDescendants=false
    local sh=Instance.new("Frame",con); sh.Size=UDim2.new(1,-2,1,-2); sh.Position=UDim2.new(0,1.5,0,1.5)
    sh.BackgroundColor3=shadowColor; sh.BackgroundTransparency=0.7; sh.BorderSizePixel=0; sh.ZIndex=5
    Instance.new("UICorner",sh).CornerRadius=UDim.new(0,9)
    local mc=Instance.new("Frame",con); mc.Size=UDim2.new(1,0,1,-3); mc.Position=UDim2.new(0,0,0,-1.5)
    mc.BackgroundColor3=C.SURF2; mc.BorderSizePixel=0; mc.ZIndex=6
    Instance.new("UICorner",mc).CornerRadius=UDim.new(0,8)
    Instance.new("UIStroke",mc).Color=shadowColor
    local highGloss=Instance.new("Frame",mc); highGloss.Size=UDim2.new(1,0,0,2); highGloss.Position=UDim2.new(0,0,0,0)
    highGloss.BackgroundColor3=C.WHITE; highGloss.BackgroundTransparency=0.7; highGloss.BorderSizePixel=0; highGloss.ZIndex=7
    Instance.new("UICorner",highGloss).CornerRadius=UDim.new(0,2)
    local tl=Instance.new("TextLabel",mc); tl.Size=UDim2.new(1,-12,0,16); tl.Position=UDim2.new(0,6,0,5)
    tl.BackgroundTransparency=1; tl.Text=title; tl.Font=Enum.Font.GothamBold; tl.TextSize=10; tl.TextColor3=C.TEXT
    tl.TextXAlignment=Enum.TextXAlignment.Left; tl.ZIndex=7
    local bl=Instance.new("TextLabel",mc); bl.Size=UDim2.new(1,-12,0,22); bl.Position=UDim2.new(0,6,0,23)
    bl.BackgroundTransparency=1; bl.Text=text; bl.Font=Enum.Font.Gotham; bl.TextSize=7; bl.TextColor3=C.TEXTM
    bl.TextXAlignment=Enum.TextXAlignment.Left; bl.TextWrapped=true; bl.ZIndex=7
    return con
end

local function mkToggle(page, txt, sub, order, cb)
    local h = sub and 40 or 32
    local row=Instance.new("TextButton",page); row.Size=UDim2.new(1,0,0,h)
    row.BackgroundColor3=C.SURF2; row.BorderSizePixel=0; row.LayoutOrder=order; row.Text=""; row.ZIndex=4
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,8)
    Instance.new("UIStroke",row).Color=C.BORDER
    local g2=Instance.new("Frame",row); g2.Size=UDim2.new(0.7,0,0,1); g2.Position=UDim2.new(0.15,0,0,1)
    g2.BackgroundColor3=C.WHITE; g2.BackgroundTransparency=0.82; g2.BorderSizePixel=0; g2.ZIndex=5
    local lbl=Instance.new("TextLabel",row); lbl.Size=UDim2.new(1,-48,0,14); lbl.Position=UDim2.new(0,8,0,sub and 6 or 9)
    lbl.BackgroundTransparency=1; lbl.Text=txt; lbl.Font=Enum.Font.GothamBold; lbl.TextSize=9; lbl.TextColor3=C.TEXT
    lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=5
    if sub then
        local sl=Instance.new("TextLabel",row); sl.Size=UDim2.new(1,-48,0,10); sl.Position=UDim2.new(0,8,0,23)
        sl.BackgroundTransparency=1; sl.Text=sub; sl.Font=Enum.Font.Gotham; sl.TextSize=7; sl.TextColor3=C.TEXTM
        sl.TextXAlignment=Enum.TextXAlignment.Left; sl.ZIndex=5
    end
    local pill=Instance.new("Frame",row); pill.Size=UDim2.new(0,28,0,14); pill.Position=UDim2.new(1,-36,0.5,-7)
    pill.BackgroundColor3=C.GREY2; pill.BorderSizePixel=0; pill.ZIndex=5
    Instance.new("UICorner",pill).CornerRadius=UDim.new(0.5,0)
    local knob=Instance.new("Frame",pill); knob.Size=UDim2.new(0,10,0,10); knob.Position=UDim2.new(0,2,0.5,-5)
    knob.BackgroundColor3=C.WHITE; knob.BorderSizePixel=0; knob.ZIndex=6
    Instance.new("UICorner",knob).CornerRadius=UDim.new(0.5,0)
    local on=false
    local function setState(v)
        on=v
        tw(pill,{BackgroundColor3=on and C.GREEN or C.GREY2},0.16)
        tw(knob,{Position=on and UDim2.new(1,-12,0.5,-5) or UDim2.new(0,2,0.5,-5)},0.16)
        tw(lbl,{TextColor3=on and C.ACCB or C.TEXT},0.14)
        if cb then cb(on) end
    end
    row.MouseButton1Click:Connect(function() setState(not on) end)
    return row, setState
end

local function mkSlider(page, label, minV, maxV, defV, order, cb)
    local row=mkCard(page,46,order)
    local lbl=Instance.new("TextLabel",row); lbl.Size=UDim2.new(0.6,0,0,15); lbl.Position=UDim2.new(0,8,0,5)
    lbl.BackgroundTransparency=1; lbl.Text=label; lbl.Font=Enum.Font.GothamBold; lbl.TextSize=9; lbl.TextColor3=C.TEXT
    lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=5
    local valL=Instance.new("TextLabel",row); valL.Size=UDim2.new(0.4,-8,0,15); valL.Position=UDim2.new(0.6,0,0,5)
    valL.BackgroundTransparency=1; valL.Text=tostring(defV); valL.Font=Enum.Font.GothamBold; valL.TextSize=9; valL.TextColor3=C.ACCB
    valL.TextXAlignment=Enum.TextXAlignment.Right; lbl.ZIndex=5
    local track=Instance.new("Frame",row); track.Size=UDim2.new(1,-16,0,3); track.Position=UDim2.new(0,8,0,31)
    track.BackgroundColor3=C.SURF3; track.BorderSizePixel=0; Instance.new("UICorner",track).CornerRadius=UDim.new(0,2)
    local fill=Instance.new("Frame",track); fill.Size=UDim2.new((defV-minV)/(maxV-minV),0,1,0)
    fill.BackgroundColor3=C.ACCB; fill.BorderSizePixel=0; Instance.new("UICorner",fill).CornerRadius=UDim.new(0,2)
    local knob=Instance.new("Frame",track); knob.Size=UDim2.new(0,11,0,11); knob.AnchorPoint=Vector2.new(0.5,0.5)
    knob.Position=UDim2.new((defV-minV)/(maxV-minV),0,0.5,0); knob.BackgroundColor3=C.WHITE; knob.BorderSizePixel=0; knob.ZIndex=6
    Instance.new("UICorner",knob).CornerRadius=UDim.new(0.5,0)
    local ks=Instance.new("UIStroke",knob); ks.Color=C.GREY; ks.Thickness=1
    local hit=Instance.new("TextButton",track); hit.Size=UDim2.new(1,0,0,18); hit.Position=UDim2.new(0,0,0.5,-9)
    hit.BackgroundTransparency=1; hit.Text=""; hit.ZIndex=7
    local cur,sd=defV,false
    local function applyX(x)
        local ax,aw=track.AbsolutePosition.X,track.AbsoluteSize.X; if aw<=0 then return end
        local rel=math.clamp((x-ax)/aw,0,1); cur=math.floor(minV+(maxV-minV)*rel)
        fill.Size=UDim2.new(rel,0,1,0); knob.Position=UDim2.new(rel,0,0.5,0); valL.Text=tostring(cur)
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
    return row
end

local function mkTextbox(page, label, placeholder, order, cb)
    local wrap=mkCard(page,50,order)
    local lbl=Instance.new("TextLabel",wrap); lbl.Size=UDim2.new(1,-16,0,13); lbl.Position=UDim2.new(0,8,0,5)
    lbl.BackgroundTransparency=1; lbl.Text=label; lbl.Font=Enum.Font.GothamBold; lbl.TextSize=8; lbl.TextColor3=C.TEXTM
    lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=5
    local box=Instance.new("TextBox",wrap); box.Size=UDim2.new(1,-16,0,20); box.Position=UDim2.new(0,8,0,21)
    box.BackgroundColor3=C.SURF3; box.Font=Enum.Font.Gotham; box.TextSize=10; box.TextColor3=C.TEXT
    box.PlaceholderText=placeholder or "Type here..."; box.PlaceholderColor3=C.TEXTD
    box.Text=""; box.BorderSizePixel=0; box.ClearTextOnFocus=false; box.ZIndex=5
    Instance.new("UICorner",box).CornerRadius=UDim.new(0,5)
    local bs=Instance.new("UIStroke",box); bs.Color=C.BORDER; bs.Thickness=1
    local bp=Instance.new("UIPadding",box); bp.PaddingLeft=UDim.new(0,6)
    box.Focused:Connect(function() tw(bs,{Color=C.ACCB,Thickness=1.5},0.15) end)
    box.FocusLost:Connect(function(enter) tw(bs,{Color=C.BORDER,Thickness=1},0.15); if cb and enter then cb(box.Text) end end)
    return wrap, box
end

local function mkDropdown(page, label, options, order, cb)
    local h=20+#options*22
    local wrap=mkCard(page,h,order)
    local lbl=Instance.new("TextLabel",wrap); lbl.Size=UDim2.new(1,-16,0,15); lbl.Position=UDim2.new(0,8,0,3)
    lbl.BackgroundTransparency=1; lbl.Text=label; lbl.Font=Enum.Font.GothamBold; lbl.TextSize=8; lbl.TextColor3=C.TEXTM
    lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=5
    local btns={}
    for idx,opt in ipairs(options) do
        local ob=Instance.new("TextButton",wrap); ob.Size=UDim2.new(1,-16,0,18); ob.Position=UDim2.new(0,8,0,18+(idx-1)*21)
        ob.BackgroundColor3=C.SURF3; ob.Font=Enum.Font.GothamBold; ob.TextSize=8; ob.TextColor3=C.TEXTM
        ob.Text=opt; ob.BorderSizePixel=0; ob.ZIndex=5
        Instance.new("UICorner",ob).CornerRadius=UDim.new(0,5)
        local obs=Instance.new("UIStroke",ob); obs.Color=C.BORDER; obs.Thickness=1
        btns[opt]={btn=ob,stk=obs}
        ob.MouseButton1Click:Connect(function()
            for _,bd in pairs(btns) do
                tw(bd.btn,{BackgroundColor3=C.SURF3},0.12); bd.btn.TextColor3=C.TEXTM; bd.stk.Color=C.BORDER
            end
            tw(ob,{BackgroundColor3=C.GREY2},0.12); ob.TextColor3=C.TEXT; obs.Color=C.ACCB
            if cb then cb(opt) end
        end)
    end
    return wrap
end

local function mkBtn(page, txt, order, col, cb)
    local btn=Instance.new("TextButton",page); btn.Size=UDim2.new(1,0,0,28)
    btn.BackgroundColor3=col or C.SURF2; btn.BorderSizePixel=0; btn.Text=txt
    btn.TextColor3=col and C.WHITE or C.TEXT; btn.Font=Enum.Font.GothamBold; btn.TextSize=9
    btn.LayoutOrder=order; btn.ZIndex=4
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,8)
    local bs=Instance.new("UIStroke",btn); bs.Color=col or C.BORDER
    btn.MouseEnter:Connect(function() tw(btn,{BackgroundColor3=C.SURF3},.12) end)
    btn.MouseLeave:Connect(function() tw(btn,{BackgroundColor3=col or C.SURF2},.12) end)
    if cb then btn.MouseButton1Click:Connect(cb) end
    return btn
end

-- ================================================================
-- PAGE 1 — MAIN (dengan tambahan Panel Control)
-- ================================================================
local pMain = tabPages[1]
mkAlertCard(pMain,C.GREEN,"SAFE","Fitur di tab ini aman digunakan. Tidak membahayakan akun dan player lain.",0)
mkSection(pMain,"Movement",1)

local walkspeedEnabled=false; local currentWalkspeed=16
local _,setWalkspeed=mkToggle(pMain,"Walk Speed","Enable custom walkspeed",2,function(v)
    walkspeedEnabled=v
    local hum=lp.Character and lp.Character:FindFirstChild("Humanoid")
    if hum then hum.WalkSpeed=v and currentWalkspeed or 16 end
end)
mkSlider(pMain,"Walk Speed Value",16,21,16,3,function(v)
    currentWalkspeed=v
    if walkspeedEnabled then local hum=lp.Character and lp.Character:FindFirstChild("Humanoid"); if hum then hum.WalkSpeed=v end end
end)
lp.CharacterAdded:Connect(function(char)
    task.wait(0.5); if walkspeedEnabled then local hum=char:FindFirstChild("Humanoid"); if hum then hum.WalkSpeed=currentWalkspeed end end
end)

local staminaHooked=false; local heartbeatConn=nil
mkToggle(pMain,"Infinite Stamina","Stamina tidak pernah habis",4,function(v)
    if v and not staminaHooked then
        for _,gc in pairs(getgc(true)) do
            if type(gc)=="table" then
                for k,_ in pairs(gc) do
                    if k=="Stamina" then
                        local mt=getmetatable(gc); if mt then
                            pcall(function()
                                setreadonly(mt,false); local oi=mt.__index
                                mt.__index=function(t,k2) if k2=="Stamina" then return 100 end; return oi and oi(t,k2) end
                            end)
                            staminaHooked=true
                            heartbeatConn=RS.Heartbeat:Connect(function() if v then pcall(function() gc.Stamina=100 end) end end)
                            break
                        end
                    end
                end
            end
            if staminaHooked then break end
        end
    elseif not v and heartbeatConn then heartbeatConn:Disconnect(); heartbeatConn=nil end
end)

mkSection(pMain,"Identity",5)
local _,nameBox=mkTextbox(pMain,"Change Name","Enter display name...",6,function(text)
    if text=="" then return end
    pcall(function()
        local char=workspace.Characters:FindFirstChild(lp.Name)
        if char and char.Head and char.Head.NameTag then char.Head.NameTag.MainFrame.NameLabel.Text=text end
    end)
end)
local _,usnBox=mkTextbox(pMain,"Change Username","Enter username...",7,function(text)
    if text=="" then return end
    pcall(function()
        local char=workspace.Characters:FindFirstChild(lp.Name)
        if char and char.Head and char.Head.RankTag then char.Head.RankTag.MainFrame.NameLabel.Text=text end
    end)
end)

mkSection(pMain,"Username Color",8)
local tierColors={["Default"]=Color3.new(1,1,1),["Tier 1 (Green)"]=C.TIER1,["Tier 2 (Peach)"]=C.TIER2,["Tier 3 (Blue)"]=C.TIER3}
mkDropdown(pMain,"Select Tier Color",{"Default","Tier 1 (Green)","Tier 2 (Peach)","Tier 3 (Blue)"},9,function(sel)
    local col=tierColors[sel]; if not col then return end
    pcall(function()
        local char=workspace.Characters:FindFirstChild(lp.Name)
        if char and char.Head and char.Head.RankTag then char.Head.RankTag.MainFrame.NameLabel.TextColor3=col end
    end)
end)

mkSection(pMain,"Delete Wall",10)
local deleteWallEnabled=false; local hoverPart=nil; local mouse=lp:GetMouse(); local deletedHistory={}; local MAX_HISTORY=20
local function savePartForUndo(part)
    if #deletedHistory>=MAX_HISTORY then table.remove(deletedHistory,1) end
    table.insert(deletedHistory,{name=part.Name,parent=part.Parent,cframe=part.CFrame,size=part.Size,
        transparency=part.Transparency,color=part.Color,material=part.Material,canCollide=part.CanCollide,anchored=part.Anchored})
end
local function undoLastDelete()
    if #deletedHistory==0 then return end; local d=deletedHistory[#deletedHistory]; table.remove(deletedHistory)
    local p=Instance.new("Part"); p.Name=d.name; p.Size=d.size; p.CFrame=d.cframe; p.Transparency=d.transparency
    p.Color=d.color; p.Material=d.material; p.CanCollide=d.canCollide; p.Anchored=d.anchored; p.Parent=d.parent
end
mkToggle(pMain,"Delete Wall Mode","E = hapus, U = undo",11,function(v) deleteWallEnabled=v end)
RS.RenderStepped:Connect(function()
    if deleteWallEnabled then
        local tgt=mouse.Target
        if tgt and tgt:IsA("BasePart") then
            local imp=tgt:IsDescendantOf(lp.Character) or (tgt.Parent and Players:GetPlayerFromCharacter(tgt.Parent)~=nil) or tgt:IsA("VehicleSeat")
            hoverPart=imp and nil or tgt
        else hoverPart=nil end
    end
end)
UIS.InputBegan:Connect(function(input,gp)
    if gp then return end
    if deleteWallEnabled and input.KeyCode==Enum.KeyCode.E and hoverPart then savePartForUndo(hoverPart); hoverPart:Destroy(); hoverPart=nil end
    if deleteWallEnabled and input.KeyCode==Enum.KeyCode.U then undoLastDelete() end
end)

-- ========== PANEL CONTROL (JOYSTICK STYLE) ==========
mkSection(pMain,"Control Panel",12)
local controlPanelOpen = false
local controlGui = nil

local function createControlPanel()
    if controlGui then controlGui:Destroy() end
    local cGui = Instance.new("ScreenGui")
    cGui.Name = "ControlPanel"
    cGui.ResetOnSpawn = false
    cGui.IgnoreGuiInset = true
    cGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    cGui.Parent = PGui

    local cWin = Instance.new("Frame")
    cWin.Parent = cGui
    cWin.Size = UDim2.new(0, 180, 0, 180)
    cWin.Position = UDim2.new(0.5, -90, 0.5, -90)
    cWin.BackgroundColor3 = C.BG
    cWin.BorderSizePixel = 0
    cWin.ClipsDescendants = false
    Instance.new("UICorner", cWin).CornerRadius = UDim.new(0, 12)

    -- header mirror
    local cTop = Instance.new("Frame", cWin)
    cTop.Size = UDim2.new(1, 0, 0, 30)
    cTop.BackgroundColor3 = C.SURF
    cTop.BorderSizePixel = 0
    Instance.new("UICorner", cTop).CornerRadius = UDim.new(0, 12)
    local cTitle = Instance.new("TextLabel", cTop)
    cTitle.Size = UDim2.new(1, 0, 1, 0)
    cTitle.BackgroundTransparency = 1
    cTitle.Text = "CONTROL PANEL"
    cTitle.Font = Enum.Font.GothamBold
    cTitle.TextSize = 10
    cTitle.TextColor3 = C.TEXT
    cTitle.ZIndex = 6
    local cClose = Instance.new("TextButton", cTop)
    cClose.Size = UDim2.new(0, 18, 0, 18)
    cClose.Position = UDim2.new(1, -22, 0.5, -9)
    cClose.BackgroundColor3 = Color3.fromRGB(55,15,15)
    cClose.Text = "X"
    cClose.TextColor3 = Color3.fromRGB(255,80,80)
    cClose.Font = Enum.Font.GothamBold
    cClose.TextSize = 10
    cClose.BorderSizePixel = 0
    Instance.new("UICorner", cClose).CornerRadius = UDim.new(0.5,0)
    cClose.MouseButton1Click:Connect(function() cGui:Destroy(); controlPanelOpen = false; controlGui = nil end)
    makeDraggable(cTop, cWin)

    -- container tombol (grid)
    local btnSize = 40
    local spacing = 10
    local startX = (cWin.AbsoluteSize.X - (btnSize*3 + spacing*2)) / 2
    local startY = (cWin.AbsoluteSize.Y - (btnSize*3 + spacing*2)) / 2 + 10

    -- fungsi untuk membuat tombul
    local function makeBtn(parent, text, posX, posY)
        local btn = Instance.new("TextButton", parent)
        btn.Size = UDim2.new(0, btnSize, 0, btnSize)
        btn.Position = UDim2.new(0, posX, 0, posY)
        btn.BackgroundColor3 = C.SURF2
        btn.Text = text
        btn.TextColor3 = C.TEXT
        btn.Font = Enum.Font.GothamBlack
        btn.TextSize = 18
        btn.BorderSizePixel = 0
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        Instance.new("UIStroke", btn).Color = C.BORDER
        return btn
    end

    -- layout grid:
    --    W
    -- A  S  D
    --    Q
    local buttons = {}
    -- baris 0 (tengah atas) : W
    local wBtn = makeBtn(cWin, "W", (cWin.Size.X.Offset/2)-btnSize/2, 15)
    table.insert(buttons, wBtn)
    -- baris 1 (tengah) : A, S, D
    local aBtn = makeBtn(cWin, "A", (cWin.Size.X.Offset/2)-btnSize-spacing, 15+btnSize+5)
    local sBtn = makeBtn(cWin, "S", (cWin.Size.X.Offset/2)-btnSize/2, 15+btnSize+5)
    local dBtn = makeBtn(cWin, "D", (cWin.Size.X.Offset/2)+spacing, 15+btnSize+5)
    table.insert(buttons, aBtn)
    table.insert(buttons, sBtn)
    table.insert(buttons, dBtn)
    -- baris 2 (bawah) : Q
    local qBtn = makeBtn(cWin, "Q", (cWin.Size.X.Offset/2)-btnSize/2, 15+2*(btnSize+5))
    table.insert(buttons, qBtn)
    -- tambahan E (opsional) di samping Q? sesuai permintaan: W A S D Q E, E bisa di kanan Q? tapi layout standar: letak E di kanan Q atau di samping? kita tambah di kanan Q
    local eBtn = makeBtn(cWin, "E", (cWin.Size.X.Offset/2)+btnSize/2+spacing, 15+2*(btnSize+5))
    table.insert(buttons, eBtn)

    -- fungsi untuk mengirim input (simulasi key press)
    local function sendKey(key, isDown)
        pcall(function()
            local ks = game:GetService("VirtualInputManager")
            if ks then
                if isDown then
                    ks:SendKeyEvent(true, key, false, nil)
                else
                    ks:SendKeyEvent(false, key, false, nil)
                end
            end
        end)
    end

    -- event handler untuk setiap tombol
    for _, btn in ipairs(buttons) do
        local key = btn.Text
        local keyCode = Enum.KeyCode[key]
        btn.MouseButton1Down:Connect(function()
            sendKey(keyCode, true)
        end)
        btn.MouseButton1Up:Connect(function()
            sendKey(keyCode, false)
        end)
        -- juga handle ketika mouse meninggalkan tombol
        btn.MouseLeave:Connect(function()
            sendKey(keyCode, false)
        end)
    end

    controlGui = cGui
    controlPanelOpen = true
end

local controlBtn = mkBtn(pMain, "Open Control Panel", 13, C.GREY2, function()
    if controlPanelOpen and controlGui then
        controlGui:Destroy()
        controlPanelOpen = false
        controlGui = nil
    else
        createControlPanel()
    end
end)
controlBtn.TextColor3 = C.TEXT

-- ================================================================
-- PAGE 2 — PLAYER (dengan tambahan Vehicle Fly)
-- ================================================================
local pPlayer = tabPages[2]
mkAlertCard(pPlayer,C.RED,"HARD WARNING !","Resiko ditanggung sendiri. Jangan terlalu sering dipakai.",0)
mkSection(pPlayer,"Silent Aim + Wallbang",1)

local SilentAim=false; local SilentAimPart="HumanoidRootPart"; local SilentAimWallbang=true
local MaxWallbangDistance=500; local FastCastHooked=false; local lastTarget=nil; local lastTargetTime=0

local FovCircle=Drawing.new("Circle")
FovCircle.Radius=150; FovCircle.NumSides=64; FovCircle.Thickness=1.2
FovCircle.Visible=false; FovCircle.Color=Color3.fromRGB(200,200,215); FovCircle.Transparency=0.5; FovCircle.Filled=false

RS.RenderStepped:Connect(function() FovCircle.Position=UIS:GetMouseLocation(); FovCircle.Visible=SilentAim end)

local function GetFovTarget()
    local now=tick()
    if lastTarget and (now-lastTargetTime)<0.1 then
        local char=lastTarget.Character
        if char and char:FindFirstChild(SilentAimPart) and char:FindFirstChild("Humanoid") and char.Humanoid.Health>0 then return lastTarget end
    end
    local Target,Lowest=nil,math.huge; local cp=FovCircle.Position
    for _,v in ipairs(Players:GetPlayers()) do
        if v~=lp then
            local Char=v.Character
            if Char then
                local Part=Char:FindFirstChild(SilentAimPart); local Hum=Char:FindFirstChild("Humanoid")
                if Part and Hum and Hum.Health>0 then
                    local sp,on=Camera:WorldToViewportPoint(Part.Position)
                    if on then
                        local d=(cp-Vector2.new(sp.X,sp.Y)).Magnitude
                        if d<FovCircle.Radius and d<Lowest then Target=v; Lowest=d end
                    end
                end
            end
        end
    end
    lastTarget=Target; lastTargetTime=now; return Target
end

local function SetupFastCastHook()
    if FastCastHooked then return true end
    local CastBL,CastWL=nil,nil
    for _,v in pairs(getgc(true)) do
        if type(v)=="function" then
            local info=debug.getinfo(v)
            if info then
                if info.name=="CastBlacklist" then CastBL=v elseif info.name=="CastWhitelist" then CastWL=v end
            end
        end
    end
    if CastBL then
        local success=pcall(function()
            hookfunction(CastBL,function(origin,direction,blacklist)
                if SilentAim then
                    local tgt=GetFovTarget()
                    if tgt and tgt.Character then
                        local tp=tgt.Character:FindFirstChild(SilentAimPart)
                        if tp then
                            local nd=tp.Position-origin; local dist=nd.Magnitude
                            if SilentAimWallbang then
                                if dist<=MaxWallbangDistance then
                                    if CastWL then return CastWL(origin,nd,{tgt.Character})
                                    else
                                        local rp=RaycastParams.new(); rp.FilterType=Enum.RaycastFilterType.Blacklist
                                        rp.FilterDescendantsInstances={lp.Character}; return workspace:Raycast(origin,nd,rp)
                                    end
                                end
                            else
                                local rp=RaycastParams.new(); rp.FilterType=Enum.RaycastFilterType.Blacklist
                                rp.FilterDescendantsInstances=blacklist or {}
                                local rr=workspace:Raycast(origin,nd,rp)
                                if rr and rr.Instance and rr.Instance:IsDescendantOf(tgt.Character) then return rr end
                            end
                        end
                    end
                end
                local rp=RaycastParams.new(); rp.FilterType=Enum.RaycastFilterType.Blacklist
                rp.FilterDescendantsInstances=blacklist or {}; return workspace:Raycast(origin,direction,rp)
            end)
        end)
        if success then FastCastHooked=true; return true end
    end
    return false
end
task.wait(0.5); SetupFastCastHook()
if not FastCastHooked then task.wait(2); SetupFastCastHook() end
if not FastCastHooked then task.wait(3); SetupFastCastHook() end

mkToggle(pPlayer,"Silent Aim","Auto-aim ke target dalam FOV",2,function(v) SilentAim=v; if not v then lastTarget=nil end end)
mkSlider(pPlayer,"Silent Aim FOV",10,500,150,3,function(v) FovCircle.Radius=v end)
mkSection(pPlayer,"Target Settings",4)
mkDropdown(pPlayer,"Target Part",{"Head","HumanoidRootPart","UpperTorso","LowerTorso"},5,function(v) SilentAimPart=v; lastTarget=nil end)
local _,setWallbang=mkToggle(pPlayer,"Wallbang","Tembus tembok & object",6,function(v) SilentAimWallbang=v end)
setWallbang(true)
mkSlider(pPlayer,"Max Wallbang Distance",10,2000,500,7,function(v) MaxWallbangDistance=v end)
local wbCard=mkCard(pPlayer,28,8)
local wbL=Instance.new("TextLabel",wbCard); wbL.Size=UDim2.new(1,-16,1,0); wbL.Position=UDim2.new(0,8,0,0)
wbL.BackgroundTransparency=1; wbL.Text="Wallbang: ACTIVE"; wbL.Font=Enum.Font.GothamBold; wbL.TextSize=8
wbL.TextColor3=C.GREEN; wbL.TextXAlignment=Enum.TextXAlignment.Left; wbL.ZIndex=5

mkSection(pPlayer,"Noclip",9)
local noclipEnabled=false; local opp={}
local function shp(inst,prop,val) pcall(function() sethiddenproperty(inst,prop,val) end) end
local function excl(part)
    return (part.Name=="default") or (part.Name=="Sidewalk") or (part.Name=="Floor") or
        (part.Name=="Collision") or part:IsDescendantOf(lp.Character) or
        (part.Parent and Players:GetPlayerFromCharacter(part.Parent)~=nil) or part:IsA("VehicleSeat")
end
local function updNoclip()
    local pp=Camera.CFrame.Position; local r=15
    local region=Region3.new(pp-Vector3.new(r,r,r),pp+Vector3.new(r,r,r))
    for _,part in ipairs(workspace:FindPartsInRegion3(region,nil,math.huge)) do
        if part:IsA("BasePart") and not excl(part) and not opp[part] then
            opp[part]={CanCollide=part.CanCollide}; shp(part,"CanCollide",false)
        end
    end
end
local function resetNoclip() for part,props in pairs(opp) do if part:IsA("BasePart") then shp(part,"CanCollide",props.CanCollide) end end; opp={} end
mkToggle(pPlayer,"Noclip (Tembus Dinding)","Melewati semua dinding & objek",10,function(enabled)
    noclipEnabled=enabled
    if noclipEnabled then spawn(function() while noclipEnabled do updNoclip(); wait(0.1) end end)
    else resetNoclip() end
end)

mkSection(pPlayer,"Aimbot",11)
local aimbotEnabled=false; local aimbotFov=200; local aimbotConn=nil
local function FindAimbotTarget()
    local cl,dist=nil,math.huge
    for _,v in ipairs(Players:GetPlayers()) do
        if v~=lp then
            local char=v.Character
            if char and char:FindFirstChild("Head") and char:FindFirstChild("Humanoid") and char.Humanoid.Health>0 then
                local sp,on=Camera:WorldToViewportPoint(char.Head.Position)
                if on then
                    local d=(Vector2.new(sp.X,sp.Y)-UIS:GetMouseLocation()).Magnitude
                    if d<aimbotFov and d<dist then dist=d; cl=v end
                end
            end
        end
    end
    return cl
end
mkToggle(pPlayer,"Aimbot","Magnet mouse ke target",12,function(v)
    aimbotEnabled=v
    if aimbotEnabled then
        if aimbotConn then aimbotConn:Disconnect() end
        aimbotConn=RS.RenderStepped:Connect(function()
            local tgt=FindAimbotTarget()
            if tgt and tgt.Character and tgt.Character:FindFirstChild("Head") then
                local sp,on=Camera:WorldToViewportPoint(tgt.Character.Head.Position)
                if on then UIS:SetMouseDeltaEnabled(false); pcall(function() UIS:SetMousePosition(sp.X,sp.Y) end) end
            end
        end)
    else if aimbotConn then aimbotConn:Disconnect(); aimbotConn=nil end end
end)
mkSlider(pPlayer,"Aimbot FOV",10,400,200,13,function(v) aimbotFov=v end)

-- ========== VEHICLE FLY (dengan kontrol W A S D E Q mengikuti kamera) ==========
mkSection(pPlayer,"Vehicle Fly",14)
local vehicleFlyEnabled = false
local flySpeed = 50
local flyConnection = nil
local activeKeys = {W=false, A=false, S=false, D=false, E=false, Q=false}
local vehiclePart = nil -- kendaraan yang sedang dikendarai (seat atau model)

-- fungsi untuk mendapatkan kendaraan saat ini
local function getCurrentVehicle()
    local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
    local seat = hum and hum.SeatPart
    if seat then
        local vehicle = seat:FindFirstAncestorWhichIsA("Model")
        if vehicle then return vehicle, seat end
        return seat, seat
    end
    return nil, nil
end

local function updateFly(dt)
    if not vehicleFlyEnabled then return end
    local vehicle, seat = getCurrentVehicle()
    if not vehicle then return end
    local primary = vehicle:IsA("Model") and vehicle.PrimaryPart or seat
    if not primary then return end
    local camCFrame = workspace.CurrentCamera.CFrame
    local forward = camCFrame.LookVector
    local right = camCFrame.RightVector
    local up = camCFrame.UpVector
    local moveDir = Vector3.new(0,0,0)
    if activeKeys.W then moveDir = moveDir + forward end
    if activeKeys.S then moveDir = moveDir - forward end
    if activeKeys.D then moveDir = moveDir + right end
    if activeKeys.A then moveDir = moveDir - right end
    if activeKeys.E then moveDir = moveDir + up end
    if activeKeys.Q then moveDir = moveDir - up end
    if moveDir.Magnitude > 0 then
        moveDir = moveDir.Unit * flySpeed * dt
        primary.CFrame = primary.CFrame + moveDir
        -- set velocity nol agar tidak jatuh
        if primary:IsA("BasePart") then
            primary.Velocity = Vector3.new(0,0,0)
            primary.RotVelocity = Vector3.new(0,0,0)
        end
    end
end

local function startFly()
    if flyConnection then flyConnection:Disconnect() end
    flyConnection = RS.RenderStepped:Connect(updateFly)
end

local function stopFly()
    if flyConnection then flyConnection:Disconnect(); flyConnection = nil end
end

local flyToggle, setFlyToggle = mkToggle(pPlayer, "Vehicle Fly", "Kendaraan terbang dengan kontrol W A S D E Q (ikuti kamera)", 15, function(v)
    vehicleFlyEnabled = v
    if v then
        startFly()
        -- reset active keys
        for k in pairs(activeKeys) do activeKeys[k] = false end
    else
        stopFly()
    end
end)

-- slider untuk kecepatan fly
mkSlider(pPlayer, "Fly Speed", 20, 200, 50, 16, function(v) flySpeed = v end)

-- keyboard handler untuk W A S D E Q
UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if not vehicleFlyEnabled then return end
    local key = input.KeyCode
    if key == Enum.KeyCode.W then activeKeys.W = true end
    if key == Enum.KeyCode.A then activeKeys.A = true end
    if key == Enum.KeyCode.S then activeKeys.S = true end
    if key == Enum.KeyCode.D then activeKeys.D = true end
    if key == Enum.KeyCode.E then activeKeys.E = true end
    if key == Enum.KeyCode.Q then activeKeys.Q = true end
end)

UIS.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if not vehicleFlyEnabled then return end
    local key = input.KeyCode
    if key == Enum.KeyCode.W then activeKeys.W = false end
    if key == Enum.KeyCode.A then activeKeys.A = false end
    if key == Enum.KeyCode.S then activeKeys.S = false end
    if key == Enum.KeyCode.D then activeKeys.D = false end
    if key == Enum.KeyCode.E then activeKeys.E = false end
    if key == Enum.KeyCode.Q then activeKeys.Q = false end
end)

-- ================================================================
-- PAGE 3 — TELEPORT (seperti sebelumnya)
-- ================================================================
local pTeleport = tabPages[3]
mkAlertCard(pTeleport, C.YELLOW, "WARNING MEDIUM !", "Pilih mode lalu lokasi.", 0)
mkSection(pTeleport, "Teleport Mode", 1)

local useRespawnMode = false
local modeCard = mkCard(pTeleport, 40, 2)
local modeContainer = Instance.new("Frame", modeCard)
modeContainer.Size = UDim2.new(0, 160, 0, 28)
modeContainer.Position = UDim2.new(0.5, -80, 0.5, -14)
modeContainer.BackgroundTransparency = 1

local motorModeBtn = Instance.new("TextButton", modeContainer)
motorModeBtn.Size = UDim2.new(0, 78, 1, 0)
motorModeBtn.Position = UDim2.new(0, 0, 0, 0)
motorModeBtn.BackgroundColor3 = C.BLUE
motorModeBtn.Text = "MOTOR"
motorModeBtn.Font = Enum.Font.GothamBold
motorModeBtn.TextSize = 10
motorModeBtn.BorderSizePixel = 0
Instance.new("UICorner", motorModeBtn).CornerRadius = UDim.new(0, 6)
local motorStk = Instance.new("UIStroke", motorModeBtn)
motorStk.Color = C.BORDERL

local respawnModeBtn = Instance.new("TextButton", modeContainer)
respawnModeBtn.Size = UDim2.new(0, 78, 1, 0)
respawnModeBtn.Position = UDim2.new(1, -78, 0, 0)
respawnModeBtn.BackgroundColor3 = C.SURF2
respawnModeBtn.Text = "RESPAWN"
respawnModeBtn.Font = Enum.Font.GothamBold
respawnModeBtn.TextSize = 10
respawnModeBtn.BorderSizePixel = 0
Instance.new("UICorner", respawnModeBtn).CornerRadius = UDim.new(0, 6)
local respawnStk = Instance.new("UIStroke", respawnModeBtn)
respawnStk.Color = C.BORDERL

local function setModeActive(which)
    if which == "motor" then
        useRespawnMode = false
        motorModeBtn.BackgroundColor3 = C.WHITE
        motorModeBtn.TextColor3 = C.BG
        motorStk.Color = C.GREY2
        respawnModeBtn.BackgroundColor3 = C.GREY2
        respawnModeBtn.TextColor3 = C.WHITE
        respawnStk.Color = C.BORDERL
    else
        useRespawnMode = true
        respawnModeBtn.BackgroundColor3 = C.WHITE
        respawnModeBtn.TextColor3 = C.BG
        respawnStk.Color = C.GREY2
        motorModeBtn.BackgroundColor3 = C.GREY2
        motorModeBtn.TextColor3 = C.WHITE
        motorStk.Color = C.BORDERL
    end
end

motorModeBtn.MouseButton1Click:Connect(function() setModeActive("motor") end)
respawnModeBtn.MouseButton1Click:Connect(function() setModeActive("respawn") end)
setModeActive("motor")

local cachedSeat = nil
local function updateSeatCache()
    local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
    cachedSeat = hum and hum.SeatPart or nil
end
local function hookChar(char)
    local hum = char:WaitForChild("Humanoid", 10)
    if hum then
        hum:GetPropertyChangedSignal("SeatPart"):Connect(updateSeatCache)
    end
    updateSeatCache()
end
if lp.Character then hookChar(lp.Character) end
lp.CharacterAdded:Connect(hookChar)

local tpDestination = nil
local isRespawning = false

local function onCharAdded(char)
    if not tpDestination then return end
    task.spawn(function()
        local hrp = char:WaitForChild("HumanoidRootPart", 10)
        local hum = char:WaitForChild("Humanoid", 10)
        if hrp and hum then
            repeat task.wait(0.1) until hum.Health > 0
            task.wait(0.3)
            pcall(function()
                hrp.CFrame = CFrame.new(tpDestination.x, tpDestination.y + 3, tpDestination.z)
            end)
        end
        tpDestination = nil
        isRespawning = false
    end)
end
if lp.Character then onCharAdded(lp.Character) end
lp.CharacterAdded:Connect(onCharAdded)

local function teleportTo(pos)
    if useRespawnMode then
        if isRespawning then return end
        local hum = lp.Character and lp.Character:FindFirstChild("Humanoid")
        tpDestination = {x = pos.X, y = pos.Y, z = pos.Z}
        isRespawning = true
        if hum and hum.Health > 0 then
            hum.Health = 0
        end
    else
        if not cachedSeat then return end
        local vm = cachedSeat:FindFirstAncestorWhichIsA("Model")
        if vm and vm.PrimaryPart then
            vm:SetPrimaryPartCFrame(CFrame.new(pos.X, pos.Y + 2, pos.Z))
        elseif cachedSeat then
            cachedSeat.CFrame = CFrame.new(pos.X, pos.Y + 2, pos.Z)
        end
    end
end

local LOCATIONS = {
    {"Dealer NPC",       Vector3.new(770.992,  3.71,   433.75)},
    {"NPC Marshmallow",  Vector3.new(510.061,  4.476,  600.548)},
    {"Apart 1",          Vector3.new(1137.992, 9.932,  449.753)},
    {"Apart 2",          Vector3.new(1139.174, 9.932,  420.556)},
    {"Apart 3",          Vector3.new(984.856,  9.932,  247.280)},
    {"Apart 4",          Vector3.new(988.311,  9.932,  221.664)},
    {"Apart 5",          Vector3.new(923.954,  9.932,  42.202)},
    {"Apart 6",          Vector3.new(895.721,  9.932,  41.928)},
    {"Casino",           Vector3.new(1166.33,   3.36,   -29.77)},
    {"GS UJUNG",         Vector3.new(-466.525,  3.862,  357.661)},
    {"GS BINARY",        Vector3.new(-280.351,  3.742,  248.872)},
    {"GS MID",           Vector3.new(218.427,   3.737,  -176.975)},
}

mkSection(pTeleport, "Lokasi", 3)

for i, loc in ipairs(LOCATIONS) do
    local row = mkCard(pTeleport, 36, 10 + i)
    local nameLbl = Instance.new("TextLabel", row)
    nameLbl.Size = UDim2.new(0.6, 0, 1, 0)
    nameLbl.Position = UDim2.new(0, 10, 0, 0)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = loc[1]
    nameLbl.Font = Enum.Font.Gotham
    nameLbl.TextSize = 9
    nameLbl.TextColor3 = C.TEXT
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    local tpBtn = mkBtn(row, "Teleport", 0, C.GREY2, function() teleportTo(loc[2]) end)
    tpBtn.Size = UDim2.new(0, 70, 0, 24)
    tpBtn.Position = UDim2.new(1, -80, 0.5, -12)
    tpBtn.TextSize = 9
    tpBtn.TextColor3 = C.TEXT
    local btnStk = tpBtn:FindFirstChildOfClass("UIStroke")
    if btnStk then btnStk.Color = C.BORDER end
end

local stCard = mkCard(pTeleport, 26, 10 + #LOCATIONS + 1)
local stL = Instance.new("TextLabel", stCard)
stL.Size = UDim2.new(1, -16, 1, 0)
stL.Position = UDim2.new(0, 8, 0, 0)
stL.BackgroundTransparency = 1
stL.Text = "Not in vehicle"
stL.Font = Enum.Font.Gotham
stL.TextSize = 8
stL.TextColor3 = C.TEXTM
stL.TextXAlignment = Enum.TextXAlignment.Left
stL.ZIndex = 5

RS.Heartbeat:Connect(function()
    if cachedSeat then
        stL.Text = "In vehicle - Motor mode ready"
        stL.TextColor3 = C.GREEN
    else
        stL.Text = "Not in vehicle"
        stL.TextColor3 = C.TEXTM
    end
end)

-- ================================================================
-- PAGE 4 — ESP (unchanged)
-- ================================================================
local pESP = tabPages[4]
mkAlertCard(pESP, C.GREEN, "SAFE", "Hanya visual, tidak membahayakan.", 0)
mkSection(pESP, "Player ESP", 1)
local espEnabled=false; local espMaxDist=150; local espCache={}; local lastEspUpdate=0
local function createESP(player)
    if espCache[player] then for _,o in pairs(espCache[player]) do pcall(function() o:Remove() end) end end
    local box=Drawing.new("Square"); box.Thickness=1; box.Color=C.GREEN; box.Filled=false
    local nameL=Drawing.new("Text"); nameL.Text=player.Name; nameL.Size=9; nameL.Font=1; nameL.Color=C.WHITE; nameL.Outline=true; nameL.Center=true
    local hpBg=Drawing.new("Square"); hpBg.Thickness=1; hpBg.Color=Color3.fromRGB(30,30,30); hpBg.Filled=true
    local hpFl=Drawing.new("Square"); hpFl.Thickness=1; hpFl.Color=Color3.fromRGB(72,215,115); hpFl.Filled=true
    local dL=Drawing.new("Text"); dL.Size=9; dL.Font=1; dL.Color=C.TEXTM; dL.Outline=true; dL.Center=true
    espCache[player]={box,nameL,hpBg,hpFl,dL}
end
local function removeESP(p) if espCache[p] then for _,o in pairs(espCache[p]) do pcall(function() o:Remove() end) end; espCache[p]=nil end end
for _,p in pairs(Players:GetPlayers()) do if p~=lp then createESP(p) end end
Players.PlayerAdded:Connect(function(p) if p~=lp then createESP(p) end end)
Players.PlayerRemoving:Connect(removeESP)
mkToggle(pESP,"Player ESP","Box, Name, Health, Distance",2,function(v) espEnabled=v end)
mkSlider(pESP,"Maximum Distance",10,500,150,3,function(v) espMaxDist=v end)
RS.RenderStepped:Connect(function()
    if not espEnabled then for _,drawings in pairs(espCache) do for _,o in pairs(drawings) do pcall(function() o.Visible=false end) end end; return end
    local now=tick(); if now-lastEspUpdate<0.15 then return end; lastEspUpdate=now
    local myChar=lp.Character; local myHRP=myChar and myChar:FindFirstChild("HumanoidRootPart"); local myPos=myHRP and myHRP.Position
    local vX,vY=Camera.ViewportSize.X,Camera.ViewportSize.Y
    for player,drawings in pairs(espCache) do
        local box,nameL,hpBg,hpFl,dL=unpack(drawings)
        local char=player.Character; local hum=char and char:FindFirstChildOfClass("Humanoid")
        local root=char and char:FindFirstChild("HumanoidRootPart"); local head=char and char:FindFirstChild("Head")
        if not (char and hum and root and head and hum.Health>0) then
            for _,o in pairs(drawings) do o.Visible=false end
        else
            local d3=myPos and (root.Position-myPos).Magnitude or 0
            if d3>espMaxDist then for _,o in pairs(drawings) do o.Visible=false end
            else
                local rp,rOn=Camera:WorldToViewportPoint(root.Position)
                local hp,hOn=Camera:WorldToViewportPoint(head.Position)
                if rOn and hOn then
                    local height=math.abs(hp.Y-rp.Y)*1.5+8; local width=height*0.5
                    local bX=rp.X-width/2; local bY=hp.Y-4
                    if bX+width>0 and bX<vX and bY+height>0 and bY<vY then
                        box.Color=C.GREEN; box.Size=Vector2.new(width,height); box.Position=Vector2.new(bX,bY); box.Visible=true
                        nameL.Text=player.Name; nameL.Color=C.WHITE; nameL.Position=Vector2.new(rp.X,bY-12); nameL.Visible=true
                        local hpPct=math.clamp(hum.Health/hum.MaxHealth,0,1)
                        hpBg.Size=Vector2.new(3,height-4); hpBg.Position=Vector2.new(bX-7,bY+2); hpBg.Visible=true
                        hpFl.Color=Color3.fromRGB(255*(1-hpPct),255*hpPct,80)
                        hpFl.Size=Vector2.new(2,(height-6)*hpPct)
                        hpFl.Position=Vector2.new(bX-6,bY+3+(height-6)*(1-hpPct)); hpFl.Visible=true
                        dL.Text=math.floor(d3).."m"; dL.Position=Vector2.new(rp.X,bY+height+2); dL.Visible=true
                    else for _,o in pairs(drawings) do o.Visible=false end end
                else for _,o in pairs(drawings) do o.Visible=false end end
            end
        end
    end
end)

-- ================================================================
-- PAGE 5 — OPTI
-- ================================================================
local pOpti = tabPages[5]
mkAlertCard(pOpti, C.GREEN, "SAFE", "Fitur optimasi grafis untuk meningkatkan FPS.", 0)
local fpsState={lowShadow=false,noPost=false,flatMat=false,noColor=false,hideDecals=false,flatWater=false,lowRender=false,highBright=false,lowAnim=false}
local origLighting={fogEnd=Lighting.FogEnd,brightness=Lighting.Brightness,globalShadows=Lighting.GlobalShadows,postEffects={}}
for _,v in ipairs(Lighting:GetChildren()) do if v:IsA("PostEffect") then table.insert(origLighting.postEffects,v:Clone()) end end
local origParts,origDecals,origTerrain={},{},{}
local function applyLowShadow(e) Lighting.GlobalShadows=not e end
local function applyNoPost(e)
    if e then for _,v in ipairs(Lighting:GetChildren()) do if v:IsA("PostEffect") then v:Destroy() end end; Lighting.FogEnd=9e9
    else Lighting.FogEnd=origLighting.fogEnd; for _,v in ipairs(origLighting.postEffects) do v:Clone().Parent=Lighting end end
end
local function applyFlatMat(e)
    for _,inst in ipairs(workspace:GetDescendants()) do
        if inst:IsA("BasePart") and not (lp.Character and inst:IsDescendantOf(lp.Character)) then
            if e then if not origParts[inst] then origParts[inst]={Material=inst.Material,Reflectance=inst.Reflectance,Color=inst.Color} end
                inst.Material=Enum.Material.SmoothPlastic; inst.Reflectance=0
                if fpsState.noColor then inst.Color=Color3.fromRGB(120,120,120) end
            else local orig=origParts[inst]; if orig then inst.Material=orig.Material; inst.Reflectance=orig.Reflectance; inst.Color=orig.Color end end
        end
    end
end
local function applyNoColor(e) if not fpsState.flatMat then return end
    for _,inst in ipairs(workspace:GetDescendants()) do if inst:IsA("BasePart") and not (lp.Character and inst:IsDescendantOf(lp.Character)) then
        if e then if not origParts[inst] then origParts[inst]={Color=inst.Color} end; inst.Color=Color3.fromRGB(120,120,120)
        else local orig=origParts[inst]; if orig then inst.Color=orig.Color end end
    end end
end
local function applyHideDecals(e)
    for _,inst in ipairs(workspace:GetDescendants()) do if (inst:IsA("Texture") or inst:IsA("Decal")) and not (lp.Character and inst:IsDescendantOf(lp.Character)) then
        if e then if not origDecals[inst] then origDecals[inst]=inst.Transparency end; inst.Transparency=1
        elseif origDecals[inst] then inst.Transparency=origDecals[inst] end
    end end
end
local function applyFlatWater(e)
    local terrain=workspace:FindFirstChild("Terrain"); if not terrain then return end
    if e then if not origTerrain.water then origTerrain.water={waveSize=terrain.WaterWaveSize,waveSpeed=terrain.WaterWaveSpeed,reflectance=terrain.WaterReflectance,transparency=terrain.WaterTransparency} end
        terrain.WaterWaveSize=0; terrain.WaterWaveSpeed=0; terrain.WaterReflectance=0; terrain.WaterTransparency=1
    else local w=origTerrain.water; if w then terrain.WaterWaveSize=w.waveSize; terrain.WaterWaveSpeed=w.waveSpeed; terrain.WaterReflectance=w.reflectance; terrain.WaterTransparency=w.transparency end end
end
local function applyLowRender(e) pcall(function() local gs=game:GetService("UserSettings"):GetService("UserGameSettings"); gs.SavedQualityLevel=e and Enum.SavedQualitySetting.QualityLevel1 or Enum.SavedQualitySetting.Automatic; gs:Apply() end); pcall(function() settings().Rendering.QualityLevel=e and 1 or 21 end) end
local function applyHighBright(e) Lighting.Brightness=e and 2 or origLighting.brightness end
local function applyLowAnim(e) pcall(function() settings().Physics.AllowSleep=e end) end
local function refreshAll() applyLowShadow(fpsState.lowShadow); applyNoPost(fpsState.noPost); applyFlatMat(fpsState.flatMat); applyNoColor(fpsState.noColor); applyHideDecals(fpsState.hideDecals); applyFlatWater(fpsState.flatWater); applyLowRender(fpsState.lowRender); applyHighBright(fpsState.highBright); applyLowAnim(fpsState.lowAnim) end

local toggleSetters={}
local masterEnabled=false

local function simpleToggle(page,text,desc,stateKey,order,applyFn)
    local row=mkCard(page,40,order)
    local lbl=Instance.new("TextLabel",row); lbl.Size=UDim2.new(1,-48,0,15); lbl.Position=UDim2.new(0,8,0,5)
    lbl.BackgroundTransparency=1; lbl.Text=text; lbl.Font=Enum.Font.GothamBold; lbl.TextSize=9; lbl.TextColor3=C.TEXT; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=5
    local dsc=Instance.new("TextLabel",row); dsc.Size=UDim2.new(1,-48,0,11); dsc.Position=UDim2.new(0,8,0,22)
    dsc.BackgroundTransparency=1; dsc.Text=desc; dsc.Font=Enum.Font.Gotham; dsc.TextSize=7; dsc.TextColor3=C.TEXTM; dsc.TextXAlignment=Enum.TextXAlignment.Left; dsc.ZIndex=5
    local pill=Instance.new("Frame",row); pill.Size=UDim2.new(0,28,0,14); pill.Position=UDim2.new(1,-38,0.5,-7)
    pill.BackgroundColor3=C.GREY2; pill.BorderSizePixel=0; Instance.new("UICorner",pill).CornerRadius=UDim.new(0.5,0)
    local knob=Instance.new("Frame",pill); knob.Size=UDim2.new(0,10,0,10); knob.Position=UDim2.new(0,2,0.5,-5)
    knob.BackgroundColor3=C.WHITE; knob.BorderSizePixel=0; Instance.new("UICorner",knob).CornerRadius=UDim.new(0.5,0)
    local btn=Instance.new("TextButton",row); btn.Size=UDim2.new(1,0,1,0); btn.BackgroundTransparency=1; btn.Text=""
    local on=false
    local function setOn(v)
        on=v; fpsState[stateKey]=v
        tw(pill,{BackgroundColor3=on and C.GREEN or C.GREY2},0.16)
        tw(knob,{Position=on and UDim2.new(1,-12,0.5,-5) or UDim2.new(0,2,0.5,-5)},0.16)
        tw(lbl,{TextColor3=on and C.ACCB or C.TEXT},0.14)
        if applyFn then applyFn(v) end
    end
    btn.MouseButton1Click:Connect(function() setOn(not on) end)
    table.insert(toggleSetters,setOn); return setOn
end

local masterRow=mkCard(pOpti,42,1)
local mLabel=Instance.new("TextLabel",masterRow); mLabel.Size=UDim2.new(1,-48,0,18); mLabel.Position=UDim2.new(0,8,0,4)
mLabel.BackgroundTransparency=1; mLabel.Text="Master Optimizer"; mLabel.Font=Enum.Font.GothamBold; mLabel.TextSize=10; mLabel.TextColor3=C.ACCB; mLabel.TextXAlignment=Enum.TextXAlignment.Left; mLabel.ZIndex=5
local mSub=Instance.new("TextLabel",masterRow); mSub.Size=UDim2.new(1,-48,0,12); mSub.Position=UDim2.new(0,8,0,24)
mSub.BackgroundTransparency=1; mSub.Text="Aktifkan semua fitur FPS boost"; mSub.Font=Enum.Font.Gotham; mSub.TextSize=7; mSub.TextColor3=C.TEXTM; mSub.TextXAlignment=Enum.TextXAlignment.Left; mSub.ZIndex=5
local mPill=Instance.new("Frame",masterRow); mPill.Size=UDim2.new(0,28,0,14); mPill.Position=UDim2.new(1,-38,0.5,-7)
mPill.BackgroundColor3=C.GREY2; mPill.BorderSizePixel=0; Instance.new("UICorner",mPill).CornerRadius=UDim.new(0.5,0)
local mKnob=Instance.new("Frame",mPill); mKnob.Size=UDim2.new(0,10,0,10); mKnob.Position=UDim2.new(0,2,0.5,-5)
mKnob.BackgroundColor3=C.WHITE; mKnob.BorderSizePixel=0; Instance.new("UICorner",mKnob).CornerRadius=UDim.new(0.5,0)
local mBtn=Instance.new("TextButton",masterRow); mBtn.Size=UDim2.new(1,0,1,0); mBtn.BackgroundTransparency=1; mBtn.Text=""
mBtn.MouseButton1Click:Connect(function()
    masterEnabled=not masterEnabled
    for k in pairs(fpsState) do fpsState[k]=masterEnabled end; refreshAll()
    tw(mPill,{BackgroundColor3=masterEnabled and C.GREEN or C.GREY2},0.16)
    tw(mKnob,{Position=masterEnabled and UDim2.new(1,-12,0.5,-5) or UDim2.new(0,2,0.5,-5)},0.16)
    for _,setter in ipairs(toggleSetters) do setter(masterEnabled) end
end)

simpleToggle(pOpti,"Low Shadow","Disable global shadows","lowShadow",2,applyLowShadow)
simpleToggle(pOpti,"No Post Effects","Remove bloom, blur, etc","noPost",3,applyNoPost)
simpleToggle(pOpti,"Flat Materials","SmoothPlastic & zero reflectance","flatMat",4,applyFlatMat)
simpleToggle(pOpti,"No Color","Gray parts (needs Flat Mat)","noColor",5,applyNoColor)
simpleToggle(pOpti,"Hide Decals","Remove textures and decals","hideDecals",6,applyHideDecals)
simpleToggle(pOpti,"Flat Terrain","Remove water waves","flatWater",7,applyFlatWater)
simpleToggle(pOpti,"Low Render","Quality level 1 (max FPS)","lowRender",8,applyLowRender)
simpleToggle(pOpti,"High Brightness","Increase lighting brightness","highBright",9,applyHighBright)
simpleToggle(pOpti,"Low Animation","Physics sleep mode","lowAnim",10,applyLowAnim)

-- ================================================================
-- PAGE 6 — CREDIT
-- ================================================================
local pCredit = tabPages[6]
local devCard = mkCard(pCredit, 58, 1)
local dtl = Instance.new("TextLabel", devCard); dtl.Size = UDim2.new(1, -16, 0, 18); dtl.Position = UDim2.new(0, 8, 0, 6)
dtl.BackgroundTransparency = 1; dtl.Text = "SILENT HUB v1.0"; dtl.Font = Enum.Font.GothamBlack; dtl.TextSize = 12; dtl.TextColor3 = C.TEXT; dtl.TextXAlignment = Enum.TextXAlignment.Left; dtl.ZIndex = 5
local dsb = Instance.new("TextLabel", devCard); dsb.Size = UDim2.new(1, -16, 0, 12); dsb.Position = UDim2.new(0, 8, 0, 26)
dsb.BackgroundTransparency = 1; dsb.Text = "Developed by MASGAL x DRKY"; dsb.Font = Enum.Font.GothamBold; dsb.TextSize = 8; dsb.TextColor3 = C.ACCB; dsb.TextXAlignment = Enum.TextXAlignment.Left; dsb.ZIndex = 5
local dtm = Instance.new("TextLabel", devCard); dtm.Size = UDim2.new(1, -16, 0, 10); dtm.Position = UDim2.new(0, 8, 0, 40)
dtm.BackgroundTransparency = 1; dtm.Text = "Team — SILENT TEAM"; dtm.Font = Enum.Font.Gotham; dtm.TextSize = 7; dtm.TextColor3 = C.TEXTM; dtm.TextXAlignment = Enum.TextXAlignment.Left; dtm.ZIndex = 5
mkSection(pCredit, "Pricing", 2)
local priceCard = mkCard(pCredit, 46, 3)
local bar = Instance.new("Frame", priceCard); bar.Size = UDim2.new(0, 3, 0.6, 0); bar.Position = UDim2.new(0, 0, 0.2, 0)
bar.BackgroundColor3 = C.ACCB; bar.BorderSizePixel = 0; Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 2)
local nl = Instance.new("TextLabel", priceCard); nl.Size = UDim2.new(0.55, 0, 0, 16); nl.Position = UDim2.new(0, 10, 0, 6)
nl.BackgroundTransparency = 1; nl.Text = "Silent Hub"; nl.Font = Enum.Font.GothamBold; nl.TextSize = 9; nl.TextColor3 = C.TEXT; nl.TextXAlignment = Enum.TextXAlignment.Left; nl.ZIndex = 5
local pl = Instance.new("TextLabel", priceCard); pl.Size = UDim2.new(0.55, 0, 0, 12); pl.Position = UDim2.new(0, 10, 0, 24)
pl.BackgroundTransparency = 1; pl.Text = "IDR 25.000"; pl.Font = Enum.Font.Gotham; pl.TextSize = 8; pl.TextColor3 = C.TEXTM; pl.TextXAlignment = Enum.TextXAlignment.Left; pl.ZIndex = 5
local db = Instance.new("Frame", priceCard); db.Size = UDim2.new(0, 58, 0, 18); db.Position = UDim2.new(1, -66, 0.5, -9)
db.BackgroundColor3 = C.SURF3; db.BorderSizePixel = 0; db.ZIndex = 5; Instance.new("UICorner", db).CornerRadius = UDim.new(0, 4)
Instance.new("UIStroke", db).Color = C.BORDERL
local dbd = Instance.new("TextLabel", db); dbd.Size = UDim2.new(1, 0, 1, 0); dbd.BackgroundTransparency = 1; dbd.Text = "3 Days"
dbd.Font = Enum.Font.GothamBold; dbd.TextSize = 8; dbd.TextColor3 = C.ACCB; dbd.TextXAlignment = Enum.TextXAlignment.Center; dbd.ZIndex = 6
mkSection(pCredit, "Links", 4)
mkBtn(pCredit, "Copy Discord Link", 5, C.BLUE, function()
    pcall(function() if setclipboard then setclipboard("https://discord.gg/aNWNjArMQd") end end)
end)
local thF = mkCard(pCredit, 26, 6); local thL = Instance.new("TextLabel", thF)
thL.Size = UDim2.new(1, 0, 1, 0); thL.BackgroundTransparency = 1; thL.Text = "Thanks for using Silent Hub"
thL.Font = Enum.Font.GothamBold; thL.TextSize = 8; thL.TextColor3 = C.ACCB; thL.TextXAlignment = Enum.TextXAlignment.Center; thL.ZIndex = 5

-- ================================================================
-- STARTUP
-- ================================================================
Win.Size = UDim2.new(0, 0, 0, 0); Win.BackgroundTransparency = 1; Win.Position = UDim2.new(0.5, -WW/2, 0.5, -WH/2)
task.spawn(function()
    tw(Win, {Size = UDim2.new(0, WW, 0, WH), BackgroundTransparency = 0}, 0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    task.wait(0.15)
    switchTab(2) -- buka tab Player
end)

print("SILENT HUB v1.0 — Final Update loaded (Control Panel + Vehicle Fly)")
