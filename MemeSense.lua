-- ==========================================
-- MEMESENSE MM2 | FULL EDITION v5 (Anti-Aim)
-- ==========================================

local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

pcall(function()
    if CoreGui:FindFirstChild("MemeSense_UI") then CoreGui.MemeSense_UI:Destroy() end
    if CoreGui:FindFirstChild("MemeESP") then CoreGui.MemeESP:Destroy() end
end)

-- ===== CONFIG =====
local Config = {
    -- Aimbot
    AimEnabled = false, AimRadius = 100, AimSmoothness = 1,
    AimBind = "MouseButton2", AimTargetMode = "Head",
    AimVisibleOnly = false, AimPrediction = false, ShowFOV = true,

    -- Trigger
    TriggerBot = false, TriggerBind = "T",
    TriggerDelay = 50, TriggerOnlyMurderer = true,

    -- ESP
    EspPlayers = false, EspBoxes = true, EspNames = true,
    EspHealth = true, EspDistance = false, EspRoles = true,
    EspGun = false, ShowClanTags = true, ShowOwnTag = true,

    -- Combat
    KillAura = false, KillAuraBind = "F", AuraRadius = 15,
    AutoShoot = false, AutoShootBind = "G",
    AutoGrabGun = false, AutoGrabBind = "H",
    SilentAim = false,
    FlingTarget = "", FlingMurderer = false, FlingBind = "V",

    -- Weapon
    NoRecoil = false, NoSpread = false, InstantReload = false,

    -- Movement
    WalkSpeed = 16, JumpPower = 50,
    InfiniteJump = false, InfJumpBind = "None",
    AntiFling = true, FastBHop = false, BHopBind = "Space",
    WallHop = false, NoClip = false, NoClipBind = "N",

    -- Visuals
    StretchedResolution = 70, FullBright = false, RemoveFog = false,

    -- ===== ANTI-AIM =====
    AntiAimEnabled = false,
    AntiAimBind = "None",
    AntiAimPitch = "None",       -- None / Up / Down / Zero
    AntiAimYaw = "Static",       -- Static / Backwards / Spin / Jitter / Random / Sideways
    AntiAimYawOffset = 0,        -- в градусах
    AntiAimSpinSpeed = 15,
    AntiAimDesync = false,       -- визуальный десинк (нижняя часть в одну сторону, верх в другую)
    AntiAimDesyncAngle = 60,
    AntiAimFakeLag = false,      -- прерывистое обновление
    AntiAimFakeLagInterval = 3,
    AntiAimSlowWalk = false,     -- медленная ходьба
    AntiAimAtTargets = false,    -- смотреть НА врагов (ломает aim-логику)
    AntiAimShowIndicator = true,

    -- Панические бинды
    PanicBind = "End",
    MenuBind = "Insert",
}

-- ===== CONFIG SYSTEM =====
local ConfigFolder = "MemeSense_Configs"
local CurrentConfigName = "default"

pcall(function()
    if makefolder and not (isfolder and isfolder(ConfigFolder)) then makefolder(ConfigFolder) end
end)

local function GetConfigsList()
    local files = {}
    pcall(function()
        if listfiles then
            for _, path in ipairs(listfiles(ConfigFolder)) do
                local name = path:match("([^/\\]+)%.json$")
                if name then table.insert(files, name) end
            end
        end
    end)
    return files
end

local function SaveConfig(name)
    if not name or name == "" then return false end
    local path = ConfigFolder .. "/" .. name .. ".json"
    return pcall(function()
        if writefile then writefile(path, HttpService:JSONEncode(Config)) end
    end)
end

local function LoadConfig(name)
    local path = ConfigFolder .. "/" .. name .. ".json"
    return pcall(function()
        if isfile and isfile(path) then
            local data = HttpService:JSONDecode(readfile(path))
            if type(data) == "table" then
                for k, v in pairs(data) do Config[k] = v end
            end
        end
    end)
end

local function DeleteConfig(name)
    local path = ConfigFolder .. "/" .. name .. ".json"
    pcall(function()
        if delfile and isfile(path) then delfile(path) end
    end)
end

-- ===== TAG =====
local function giveTagMarker()
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if not bp or bp:FindFirstChild("MemeSense_Tag") then return end
    local tool = Instance.new("Tool")
    tool.Name = "MemeSense_Tag"
    tool.RequiresHandle = false
    tool.CanBeDropped = false
    tool.Parent = bp
end

local function removeTagMarker()
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if bp then local m = bp:FindFirstChild("MemeSense_Tag"); if m then m:Destroy() end end
    if LocalPlayer.Character then
        local m = LocalPlayer.Character:FindFirstChild("MemeSense_Tag")
        if m then m:Destroy() end
    end
end

local function createTagGui(character)
    if not character then return end
    local head = character:FindFirstChild("Head")
    if not head or head:FindFirstChild("MemeSense_ClanTag") then return end

    local bg = Instance.new("BillboardGui")
    bg.Name = "MemeSense_ClanTag"
    bg.Adornee = head
    bg.Size = UDim2.new(0, 200, 0, 30)
    bg.StudsOffset = Vector3.new(0, 3, 0)
    bg.AlwaysOnTop = true
    bg.LightInfluence = 0
    bg.Parent = head

    local tag = Instance.new("TextLabel")
    tag.Size = UDim2.new(1, 0, 1, 0)
    tag.BackgroundTransparency = 1
    tag.RichText = true
    tag.Text = '<font color="rgb(235,50,75)">★ </font><font color="rgb(255,255,255)">Meme</font><font color="rgb(235,50,75)">Sense</font><font color="rgb(235,50,75)"> ★</font>'
    tag.Font = Enum.Font.GothamBold
    tag.TextSize = 16
    tag.TextStrokeTransparency = 0
    tag.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    tag.Parent = bg
end

local function removeTagGui(character)
    if not character then return end
    local head = character:FindFirstChild("Head")
    if head then local t = head:FindFirstChild("MemeSense_ClanTag"); if t then t:Destroy() end end
end

giveTagMarker()
if LocalPlayer.Character and Config.ShowOwnTag then createTagGui(LocalPlayer.Character) end

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    giveTagMarker()
    if Config.ShowOwnTag then createTagGui(char) end
end)

local function checkOtherTags()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local bp = p:FindFirstChild("Backpack")
            local hasMarker = (bp and bp:FindFirstChild("MemeSense_Tag")) or p.Character:FindFirstChild("MemeSense_Tag")
            if hasMarker and Config.ShowClanTags then
                createTagGui(p.Character)
            else
                removeTagGui(p.Character)
            end
        end
    end
end

-- ===== FLING =====
local function FlingPlayer(targetChar)
    local lpChar = LocalPlayer.Character
    if not lpChar or not targetChar then return end
    local hrp = lpChar:FindFirstChild("HumanoidRootPart")
    local targetHrp = targetChar:FindFirstChild("HumanoidRootPart")
    if not hrp or not targetHrp then return end

    local oldCFrame = hrp.CFrame
    local frame = 0
    local con
    con = RunService.Heartbeat:Connect(function()
        if not targetHrp.Parent or not hrp.Parent then con:Disconnect() return end
        frame += 1
        hrp.AssemblyLinearVelocity = Vector3.new(99999, 99999, 99999)
        hrp.AssemblyAngularVelocity = Vector3.new(99999, 99999, 99999)
        hrp.CFrame = targetHrp.CFrame * CFrame.new(math.sin(frame)*0.1, 0, math.cos(frame)*0.1)
    end)
    task.wait(0.6)
    con:Disconnect()
    if hrp.Parent then
        hrp.CFrame = oldCFrame
        hrp.AssemblyLinearVelocity = Vector3.new()
        hrp.AssemblyAngularVelocity = Vector3.new()
    end
end

-- ===== UI =====
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MemeSense_UI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 680, 0, 470)
mainFrame.Position = UDim2.new(0.5, -340, 0.5, -235)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mainFrame.BorderColor3 = Color3.fromRGB(35, 35, 35)
mainFrame.Active = true
mainFrame.Parent = screenGui

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 2)
topBar.BackgroundColor3 = Color3.fromRGB(235, 50, 75)
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 28, 0, 22)
closeBtn.Position = UDim2.new(1, -32, 0, 6)
closeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
closeBtn.BorderColor3 = Color3.fromRGB(60, 60, 60)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(235, 50, 75)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.AutoButtonColor = false
closeBtn.ZIndex = 10
closeBtn.Parent = mainFrame

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 28, 0, 22)
minBtn.Position = UDim2.new(1, -64, 0, 6)
minBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
minBtn.BorderColor3 = Color3.fromRGB(60, 60, 60)
minBtn.Text = "—"
minBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 14
minBtn.AutoButtonColor = false
minBtn.ZIndex = 10
minBtn.Parent = mainFrame

closeBtn.MouseEnter:Connect(function() closeBtn.BackgroundColor3 = Color3.fromRGB(235,50,75); closeBtn.TextColor3 = Color3.fromRGB(255,255,255) end)
closeBtn.MouseLeave:Connect(function() closeBtn.BackgroundColor3 = Color3.fromRGB(30,30,30); closeBtn.TextColor3 = Color3.fromRGB(235,50,75) end)

local UNLOADED = false
local unloadCheat
unloadCheat = function()
    UNLOADED = true
    pcall(function() screenGui:Destroy() end)
    pcall(function() if CoreGui:FindFirstChild("MemeESP") then CoreGui.MemeESP:Destroy() end end)
    pcall(function() if CoreGui:FindFirstChild("AntiAim_HUD") then CoreGui.AntiAim_HUD:Destroy() end end)
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character then removeTagGui(p.Character) end
    end
    removeTagMarker()
    Camera.FieldOfView = 70
    if LocalPlayer.Character then
        local h = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if h then h.WalkSpeed = 16; h.JumpPower = 50 end
    end
    print("[MemeSense] Unloaded")
end
closeBtn.MouseButton1Click:Connect(unloadCheat)
minBtn.MouseButton1Click:Connect(function() mainFrame.Visible = false end)

local sideBar = Instance.new("Frame")
sideBar.Size = UDim2.new(0, 150, 1, -2)
sideBar.Position = UDim2.new(0, 0, 0, 2)
sideBar.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
sideBar.BorderColor3 = Color3.fromRGB(25, 25, 25)
sideBar.Parent = mainFrame

local logo = Instance.new("TextLabel")
logo.Size = UDim2.new(1, 0, 0, 45)
logo.BackgroundTransparency = 1
logo.RichText = true
logo.Text = '<font color="rgb(255,255,255)">Meme</font><font color="rgb(235,50,75)">Sense</font>'
logo.Font = Enum.Font.GothamBold
logo.TextSize = 18
logo.Parent = sideBar

local pagesContainer = Instance.new("Frame")
pagesContainer.Size = UDim2.new(1, -160, 1, -35)
pagesContainer.Position = UDim2.new(0, 155, 0, 30)
pagesContainer.BackgroundTransparency = 1
pagesContainer.Parent = mainFrame

-- Drag
local dragging, dragStart, startPos
mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = input.Position; startPos = mainFrame.Position
    end
end)
mainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- ===== UI LIB =====
local UI = {}
local allCheckboxes, allSliders, allBinds, allDropdowns = {}, {}, {}, {}

function UI:CreateSection(parent, name, size, pos)
    local section = Instance.new("Frame")
    section.Size = size; section.Position = pos
    section.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    section.BorderColor3 = Color3.fromRGB(28, 28, 28)
    section.Parent = parent

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -16, 0, 22)
    title.Position = UDim2.new(0, 10, 0, 2)
    title.Text = name
    title.TextColor3 = Color3.fromRGB(210, 210, 210)
    title.Font = Enum.Font.GothamMedium
    title.TextSize = 12
    title.BackgroundTransparency = 1
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = section

    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, -20, 0, 1)
    line.Position = UDim2.new(0, 10, 0, 24)
    line.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    line.BorderSizePixel = 0
    line.Parent = section

    local content = Instance.new("ScrollingFrame")
    content.Size = UDim2.new(1, -20, 1, -30)
    content.Position = UDim2.new(0, 10, 0, 28)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 3
    content.ScrollBarImageColor3 = Color3.fromRGB(235, 50, 75)
    content.CanvasSize = UDim2.new(0, 0, 0, 0)
    content.Parent = section

    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 4)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Parent = content

    list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        content.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y + 5)
    end)

    return content
end

function UI:CreateCheckbox(parent, text, varName)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -6, 0, 18)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local box = Instance.new("TextButton")
    box.Size = UDim2.new(0, 12, 0, 12)
    box.Position = UDim2.new(0, 0, 0, 3)
    box.BackgroundColor3 = Config[varName] and Color3.fromRGB(235, 50, 75) or Color3.fromRGB(25, 25, 25)
    box.BorderColor3 = Color3.fromRGB(45, 45, 45)
    box.Text = ""
    box.AutoButtonColor = false
    box.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -22, 1, 0)
    label.Position = UDim2.new(0, 20, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(180, 180, 180)
    label.Font = Enum.Font.Gotham
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    box.MouseButton1Click:Connect(function()
        Config[varName] = not Config[varName]
        box.BackgroundColor3 = Config[varName] and Color3.fromRGB(235, 50, 75) or Color3.fromRGB(25, 25, 25)
    end)

    allCheckboxes[varName] = box
end

function UI:CreateSlider(parent, text, min, max, varName)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -6, 0, 30)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -45, 0, 12)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(160, 160, 160)
    label.Font = Enum.Font.Gotham
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local bar = Instance.new("TextButton")
    bar.Size = UDim2.new(1, -45, 0, 4)
    bar.Position = UDim2.new(0, 0, 0, 18)
    bar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    bar.BorderSizePixel = 0
    bar.Text = ""
    bar.AutoButtonColor = false
    bar.Parent = frame

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(math.clamp((Config[varName] - min) / (max - min), 0, 1), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(235, 50, 75)
    fill.BorderSizePixel = 0
    fill.Parent = bar

    local val = Instance.new("TextLabel")
    val.Size = UDim2.new(0, 40, 0, 12)
    val.Position = UDim2.new(1, -40, 0, 14)
    val.BackgroundTransparency = 1
    val.Text = tostring(Config[varName])
    val.TextColor3 = Color3.fromRGB(140, 140, 140)
    val.Font = Enum.Font.Gotham
    val.TextSize = 10
    val.Parent = frame

    local sliding = false
    bar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding = true end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mp = UserInputService:GetMouseLocation()
            local percent = math.clamp((mp.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            fill.Size = UDim2.new(percent, 0, 1, 0)
            local res = math.floor(min + (max - min) * percent)
            val.Text = tostring(res)
            Config[varName] = res
        end
    end)

    allSliders[varName] = {fill = fill, val = val, min = min, max = max}
end

local currentBindCallback = nil
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if currentBindCallback then
        local key = input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode.Name or input.UserInputType.Name
        currentBindCallback(key)
        currentBindCallback = nil
    end
end)

function UI:CreateBindButton(parent, text, varName)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -6, 0, 20)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -85, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(175, 175, 175)
    label.Font = Enum.Font.Gotham
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 80, 0, 16)
    btn.Position = UDim2.new(1, -80, 0, 2)
    btn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    btn.BorderColor3 = Color3.fromRGB(45, 45, 45)
    btn.Text = Config[varName]
    btn.TextColor3 = Color3.fromRGB(230, 230, 230)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 10
    btn.AutoButtonColor = false
    btn.Parent = frame

    btn.MouseButton1Click:Connect(function()
        btn.Text = "..."
        currentBindCallback = function(key)
            Config[varName] = key
            btn.Text = key
        end
    end)
    btn.MouseButton2Click:Connect(function()
        Config[varName] = "None"; btn.Text = "None"
    end)

    allBinds[varName] = btn
end

function UI:CreateDropdown(parent, text, options, varName)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -6, 0, 20)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, -5, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(175, 175, 175)
    label.Font = Enum.Font.Gotham
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.5, 0, 0, 16)
    btn.Position = UDim2.new(0.5, 0, 0, 2)
    btn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    btn.BorderColor3 = Color3.fromRGB(45, 45, 45)
    btn.Text = Config[varName]
    btn.TextColor3 = Color3.fromRGB(230, 230, 230)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 10
    btn.AutoButtonColor = false
    btn.Parent = frame

    local idx = 1
    for i, v in ipairs(options) do if v == Config[varName] then idx = i end end

    btn.MouseButton1Click:Connect(function()
        idx = idx + 1
        if idx > #options then idx = 1 end
        Config[varName] = options[idx]
        btn.Text = options[idx]
    end)

    allDropdowns[varName] = {btn = btn, opts = options}
end

function UI:CreateInput(parent, text, varName)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -6, 0, 22)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -105, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(175, 175, 175)
    label.Font = Enum.Font.Gotham
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0, 100, 0, 16)
    box.Position = UDim2.new(1, -100, 0, 3)
    box.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    box.BorderColor3 = Color3.fromRGB(45, 45, 45)
    box.Text = Config[varName] or ""
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.Font = Enum.Font.Gotham
    box.TextSize = 10
    box.Parent = frame

    box.FocusLost:Connect(function() Config[varName] = box.Text end)
end

function UI:CreateButton(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -6, 0, 20)
    btn.BackgroundColor3 = Color3.fromRGB(235, 50, 75)
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.Parent = parent
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function refreshUI()
    for varName, box in pairs(allCheckboxes) do
        if Config[varName] ~= nil then
            box.BackgroundColor3 = Config[varName] and Color3.fromRGB(235, 50, 75) or Color3.fromRGB(25, 25, 25)
        end
    end
    for varName, data in pairs(allSliders) do
        if Config[varName] ~= nil then
            data.fill.Size = UDim2.new(math.clamp((Config[varName] - data.min) / (data.max - data.min), 0, 1), 0, 1, 0)
            data.val.Text = tostring(Config[varName])
        end
    end
    for varName, btn in pairs(allBinds) do
        if Config[varName] ~= nil then btn.Text = Config[varName] end
    end
    for varName, data in pairs(allDropdowns) do
        if Config[varName] ~= nil then data.btn.Text = Config[varName] end
    end
end

-- ===== TABS =====
local tabs = {"Legitbot", "Ragebot", "Anti-Aim", "Visuals", "Movement", "MM2 Exploit", "Configs", "Misc"}
local activePage, activeTabBtn, activeIndicator

for i, tName in ipairs(tabs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 26)
    btn.Position = UDim2.new(0, 0, 0, 55 + (i-1)*26)
    btn.BackgroundTransparency = 1
    btn.Text = "  " .. tName
    btn.TextColor3 = i == 1 and Color3.fromRGB(235, 50, 75) or Color3.fromRGB(135, 135, 135)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.AutoButtonColor = false
    btn.Parent = sideBar

    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 2, 1, 0)
    indicator.BackgroundColor3 = Color3.fromRGB(235, 50, 75)
    indicator.BorderSizePixel = 0
    indicator.Visible = (i == 1)
    indicator.Parent = btn

    local page = Instance.new("Frame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = (i == 1)
    page.Parent = pagesContainer

    if i == 1 then activePage = page; activeTabBtn = btn; activeIndicator = indicator end

    btn.MouseButton1Click:Connect(function()
        activePage.Visible = false
        activeTabBtn.TextColor3 = Color3.fromRGB(135, 135, 135)
        activeIndicator.Visible = false
        page.Visible = true
        activePage = page
        btn.TextColor3 = Color3.fromRGB(235, 50, 75)
        activeTabBtn = btn
        indicator.Visible = true
        activeIndicator = indicator
    end)

    if tName == "Legitbot" then
        local s1 = UI:CreateSection(page, "Aimbot", UDim2.new(0, 245, 0, 220), UDim2.new(0, 5, 0, 5))
        UI:CreateCheckbox(s1, "Enable Aim", "AimEnabled")
        UI:CreateBindButton(s1, "Aim Key", "AimBind")
        UI:CreateSlider(s1, "FOV Radius", 10, 400, "AimRadius")
        UI:CreateSlider(s1, "Smoothness", 1, 20, "AimSmoothness")
        UI:CreateDropdown(s1, "Target", {"Head", "Torso", "Gun"}, "AimTargetMode")
        UI:CreateCheckbox(s1, "Prediction", "AimPrediction")
        UI:CreateCheckbox(s1, "Show FOV Circle", "ShowFOV")

        local s2 = UI:CreateSection(page, "TriggerBot", UDim2.new(0, 245, 0, 130), UDim2.new(0, 260, 0, 5))
        UI:CreateCheckbox(s2, "Enable TriggerBot", "TriggerBot")
        UI:CreateBindButton(s2, "Trigger Key", "TriggerBind")
        UI:CreateSlider(s2, "Delay (ms)", 0, 500, "TriggerDelay")
        UI:CreateCheckbox(s2, "Only Murderer", "TriggerOnlyMurderer")

        local s3 = UI:CreateSection(page, "Weapon", UDim2.new(0, 245, 0, 100), UDim2.new(0, 260, 0, 140))
        UI:CreateCheckbox(s3, "No Recoil", "NoRecoil")
        UI:CreateCheckbox(s3, "No Spread", "NoSpread")
        UI:CreateCheckbox(s3, "Instant Reload", "InstantReload")

    elseif tName == "Ragebot" then
        local s1 = UI:CreateSection(page, "Silent Aim", UDim2.new(0, 245, 0, 100), UDim2.new(0, 5, 0, 5))
        UI:CreateCheckbox(s1, "Silent Aim (Sheriff)", "SilentAim")

        local s2 = UI:CreateSection(page, "Kill Aura", UDim2.new(0, 245, 0, 130), UDim2.new(0, 260, 0, 5))
        UI:CreateCheckbox(s2, "Kill Aura (Murderer)", "KillAura")
        UI:CreateBindButton(s2, "KillAura Key", "KillAuraBind")
        UI:CreateSlider(s2, "Aura Radius", 5, 50, "AuraRadius")

        local s3 = UI:CreateSection(page, "Auto Shoot", UDim2.new(0, 245, 0, 100), UDim2.new(0, 5, 0, 115))
        UI:CreateCheckbox(s3, "Auto Shoot Murderer", "AutoShoot")
        UI:CreateBindButton(s3, "AutoShoot Key", "AutoShootBind")

        local s4 = UI:CreateSection(page, "Auto Pickup", UDim2.new(0, 245, 0, 90), UDim2.new(0, 260, 0, 145))
        UI:CreateCheckbox(s4, "Auto Grab Dropped Gun", "AutoGrabGun")
        UI:CreateBindButton(s4, "AutoGrab Key", "AutoGrabBind")

    elseif tName == "Anti-Aim" then
        local s1 = UI:CreateSection(page, "Core", UDim2.new(0, 245, 0, 130), UDim2.new(0, 5, 0, 5))
        UI:CreateCheckbox(s1, "Enable Anti-Aim", "AntiAimEnabled")
        UI:CreateBindButton(s1, "AntiAim Key", "AntiAimBind")
        UI:CreateCheckbox(s1, "Show HUD Indicator", "AntiAimShowIndicator")
        UI:CreateCheckbox(s1, "Slow Walk", "AntiAimSlowWalk")

        local s2 = UI:CreateSection(page, "Angles", UDim2.new(0, 245, 0, 180), UDim2.new(0, 260, 0, 5))
        UI:CreateDropdown(s2, "Pitch", {"None", "Up", "Down", "Zero"}, "AntiAimPitch")
        UI:CreateDropdown(s2, "Yaw", {"Static", "Backwards", "Spin", "Jitter", "Random", "Sideways"}, "AntiAimYaw")
        UI:CreateSlider(s2, "Yaw Offset", -180, 180, "AntiAimYawOffset")
        UI:CreateSlider(s2, "Spin Speed", 1, 50, "AntiAimSpinSpeed")

        local s3 = UI:CreateSection(page, "Advanced", UDim2.new(0, 500, 0, 140), UDim2.new(0, 5, 0, 140))
        UI:CreateCheckbox(s3, "Desync (Legs vs Body)", "AntiAimDesync")
        UI:CreateSlider(s3, "Desync Angle", 0, 180, "AntiAimDesyncAngle")
        UI:CreateCheckbox(s3, "Fake Lag (choke ticks)", "AntiAimFakeLag")
        UI:CreateSlider(s3, "Fake Lag Interval", 1, 10, "AntiAimFakeLagInterval")
        UI:CreateCheckbox(s3, "Look At Enemies (break aimbot)", "AntiAimAtTargets")

    elseif tName == "Visuals" then
        local s1 = UI:CreateSection(page, "ESP", UDim2.new(0, 245, 0, 175), UDim2.new(0, 5, 0, 5))
        UI:CreateCheckbox(s1, "Enable ESP", "EspPlayers")
        UI:CreateCheckbox(s1, "Boxes", "EspBoxes")
        UI:CreateCheckbox(s1, "Names", "EspNames")
        UI:CreateCheckbox(s1, "Health", "EspHealth")
        UI:CreateCheckbox(s1, "Distance", "EspDistance")
        UI:CreateCheckbox(s1, "Color by Role", "EspRoles")
        UI:CreateCheckbox(s1, "Dropped Gun ESP", "EspGun")

        local s2 = UI:CreateSection(page, "ClanTags", UDim2.new(0, 245, 0, 110), UDim2.new(0, 260, 0, 5))
        UI:CreateCheckbox(s2, "Show My Own Tag", "ShowOwnTag")
        UI:CreateCheckbox(s2, "Show Others' Tags", "ShowClanTags")
        UI:CreateButton(s2, "Refresh Tag", function()
            giveTagMarker()
            if LocalPlayer.Character then createTagGui(LocalPlayer.Character) end
        end)

        local s3 = UI:CreateSection(page, "World", UDim2.new(0, 500, 0, 90), UDim2.new(0, 5, 0, 185))
        UI:CreateSlider(s3, "Camera FOV", 70, 120, "StretchedResolution")
        UI:CreateCheckbox(s3, "Full Bright", "FullBright")
        UI:CreateCheckbox(s3, "Remove Fog", "RemoveFog")

    elseif tName == "Movement" then
        local s1 = UI:CreateSection(page, "Speed & Jump", UDim2.new(0, 245, 0, 160), UDim2.new(0, 5, 0, 5))
        UI:CreateSlider(s1, "WalkSpeed", 16, 100, "WalkSpeed")
        UI:CreateSlider(s1, "JumpPower", 50, 200, "JumpPower")
        UI:CreateCheckbox(s1, "Infinite Jump", "InfiniteJump")
        UI:CreateBindButton(s1, "InfJump Key", "InfJumpBind")

        local s2 = UI:CreateSection(page, "Exploits", UDim2.new(0, 245, 0, 180), UDim2.new(0, 260, 0, 5))
        UI:CreateCheckbox(s2, "Fast BHop", "FastBHop")
        UI:CreateBindButton(s2, "BHop Key", "BHopBind")
        UI:CreateCheckbox(s2, "WallHop", "WallHop")
        UI:CreateCheckbox(s2, "NoClip", "NoClip")
        UI:CreateBindButton(s2, "NoClip Key", "NoClipBind")
        UI:CreateCheckbox(s2, "Anti-Fling", "AntiFling")

    elseif tName == "MM2 Exploit" then
        local s1 = UI:CreateSection(page, "Fling", UDim2.new(0, 245, 0, 180), UDim2.new(0, 5, 0, 5))
        UI:CreateInput(s1, "Target Name", "FlingTarget")
        UI:CreateCheckbox(s1, "Auto Fling Murderer", "FlingMurderer")
        UI:CreateBindButton(s1, "Fling Key", "FlingBind")
        UI:CreateButton(s1, "Execute Fling", function()
            local target = Players:FindFirstChild(Config.FlingTarget)
            if target and target.Character then FlingPlayer(target.Character) end
        end)

        local s2 = UI:CreateSection(page, "Teleports", UDim2.new(0, 245, 0, 180), UDim2.new(0, 260, 0, 5))
        UI:CreateInput(s2, "TP Target", "FlingTarget")
        UI:CreateButton(s2, "TP to Player", function()
            local target = Players:FindFirstChild(Config.FlingTarget)
            local char = LocalPlayer.Character
            if target and target.Character and char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(2,0,0)
            end
        end)
        UI:CreateButton(s2, "TP to Gun", function()
            local gun = Workspace:FindFirstChild("GunDrop")
            local char = LocalPlayer.Character
            if gun and char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = gun.CFrame
            end
        end)

    elseif tName == "Configs" then
        local listSec = UI:CreateSection(page, "Configs List", UDim2.new(0, 245, 0, 400), UDim2.new(0, 5, 0, 5))
        local actSec = UI:CreateSection(page, "Actions", UDim2.new(0, 245, 0, 260), UDim2.new(0, 260, 0, 5))

        local nameInput = Instance.new("TextBox")
        nameInput.Size = UDim2.new(1, -6, 0, 22)
        nameInput.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        nameInput.BorderColor3 = Color3.fromRGB(45, 45, 45)
        nameInput.Text = ""
        nameInput.PlaceholderText = "Config name..."
        nameInput.TextColor3 = Color3.fromRGB(255,255,255)
        nameInput.Font = Enum.Font.Gotham
        nameInput.TextSize = 11
        nameInput.Parent = actSec

        local selectedLbl = Instance.new("TextLabel")
        selectedLbl.Size = UDim2.new(1, -6, 0, 20)
        selectedLbl.BackgroundTransparency = 1
        selectedLbl.Text = "Selected: " .. CurrentConfigName
        selectedLbl.TextColor3 = Color3.fromRGB(200, 200, 200)
        selectedLbl.Font = Enum.Font.GothamBold
        selectedLbl.TextSize = 11
        selectedLbl.TextXAlignment = Enum.TextXAlignment.Left
        selectedLbl.Parent = actSec

        local function refreshList()
            for _, c in pairs(listSec:GetChildren()) do
                if c:IsA("TextButton") then c:Destroy() end
            end
            for _, name in ipairs(GetConfigsList()) do
                local b = Instance.new("TextButton")
                b.Size = UDim2.new(1, -6, 0, 20)
                b.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                b.BorderColor3 = Color3.fromRGB(45, 45, 45)
                b.Text = "  " .. name
                b.TextColor3 = Color3.fromRGB(200,200,200)
                b.Font = Enum.Font.Gotham
                b.TextSize = 11
                b.TextXAlignment = Enum.TextXAlignment.Left
                b.AutoButtonColor = false
                b.Parent = listSec
                b.MouseButton1Click:Connect(function()
                    CurrentConfigName = name
                    nameInput.Text = name
                    selectedLbl.Text = "Selected: " .. name
                end)
            end
        end

        UI:CreateButton(actSec, "Save Config", function()
            local n = nameInput.Text ~= "" and nameInput.Text or CurrentConfigName
            if SaveConfig(n) then
                CurrentConfigName = n
                selectedLbl.Text = "Selected: " .. n
                refreshList()
            end
        end)
        UI:CreateButton(actSec, "Load Config", function()
            local n = nameInput.Text ~= "" and nameInput.Text or CurrentConfigName
            if LoadConfig(n) then
                CurrentConfigName = n
                selectedLbl.Text = "Selected: " .. n
                refreshUI()
            end
        end)
        UI:CreateButton(actSec, "Delete Config", function()
            local n = nameInput.Text ~= "" and nameInput.Text or CurrentConfigName
            DeleteConfig(n); refreshList()
        end)
        UI:CreateButton(actSec, "Refresh List", refreshList)

        refreshList()

    elseif tName == "Misc" then
        local s1 = UI:CreateSection(page, "Info", UDim2.new(0, 500, 0, 90), UDim2.new(0, 5, 0, 5))
        local info = Instance.new("TextLabel")
        info.Size = UDim2.new(1, -6, 0, 55)
        info.BackgroundTransparency = 1
        info.RichText = true
        info.Text = "<font color='rgb(235,50,75)'>MemeSense MM2 v5</font> | Anti-Aim added\nПКМ по бинду = сбросить"
        info.TextColor3 = Color3.fromRGB(180, 180, 180)
        info.Font = Enum.Font.Gotham
        info.TextSize = 12
        info.TextXAlignment = Enum.TextXAlignment.Left
        info.TextYAlignment = Enum.TextYAlignment.Top
        info.Parent = s1

        local s2 = UI:CreateSection(page, "Global Binds", UDim2.new(0, 245, 0, 100), UDim2.new(0, 5, 0, 105))
        UI:CreateBindButton(s2, "Menu Toggle", "MenuBind")
        UI:CreateBindButton(s2, "Panic Key (disable all)", "PanicBind")

        local s3 = UI:CreateSection(page, "Server", UDim2.new(0, 245, 0, 130), UDim2.new(0, 260, 0, 105))
        UI:CreateButton(s3, "Rejoin Server", function()
            game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
        end)
        UI:CreateButton(s3, "Reset Character", function()
            if LocalPlayer.Character then
                local h = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if h then h.Health = 0 end
            end
        end)
        UI:CreateButton(s3, "UNLOAD MemeSense", unloadCheat)
    end
end

-- ===== ANTI-AIM HUD =====
local aaHud = Instance.new("ScreenGui")
aaHud.Name = "AntiAim_HUD"
aaHud.ResetOnSpawn = false
aaHud.Parent = CoreGui

local aaLabel = Instance.new("TextLabel")
aaLabel.Size = UDim2.new(0, 200, 0, 22)
aaLabel.Position = UDim2.new(0.5, -100, 1, -60)
aaLabel.BackgroundTransparency = 1
aaLabel.RichText = true
aaLabel.Text = ""
aaLabel.Font = Enum.Font.GothamBold
aaLabel.TextSize = 14
aaLabel.TextStrokeTransparency = 0
aaLabel.TextStrokeColor3 = Color3.new(0,0,0)
aaLabel.Visible = false
aaLabel.Parent = aaHud

-- ===== FOV CIRCLE =====
local FOVCircle
if Drawing then
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Thickness = 1
    FOVCircle.NumSides = 60
    FOVCircle.Filled = false
    FOVCircle.Color = Color3.fromRGB(235, 50, 75)
    FOVCircle.Visible = false
end

local function GetRole(p)
    if not p or not p.Character then return "Innocent" end
    local bp = p:FindFirstChild("Backpack")
    if (bp and bp:FindFirstChild("Knife")) or p.Character:FindFirstChild("Knife") then return "Murderer" end
    if (bp and bp:FindFirstChild("Gun")) or p.Character:FindFirstChild("Gun") then return "Sheriff" end
    return "Innocent"
end

local EspFolder = Instance.new("Folder")
EspFolder.Name = "MemeESP"
EspFolder.Parent = CoreGui

local function isBindPressed(bindStr)
    if not bindStr or bindStr == "None" then return false end
    if bindStr:find("MouseButton") then
        local num = tonumber(bindStr:match("%d+"))
        if num == 1 then return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
        elseif num == 2 then return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) end
    else
        local ok, k = pcall(function() return Enum.KeyCode[bindStr] end)
        if ok and k then return UserInputService:IsKeyDown(k) end
    end
    return false
end

-- ===== TOGGLE BINDS =====
UserInputService.InputBegan:Connect(function(input, gp)
    if UNLOADED or gp or currentBindCallback then return end
    local key = input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode.Name or input.UserInputType.Name

    if key == Config.MenuBind then mainFrame.Visible = not mainFrame.Visible end
    if key == Config.PanicBind then
        Config.AimEnabled = false; Config.TriggerBot = false
        Config.KillAura = false; Config.AutoShoot = false
        Config.EspPlayers = false; Config.FlingMurderer = false
        Config.NoClip = false; Config.AntiAimEnabled = false
        refreshUI()
    end
    if key == Config.AntiAimBind and Config.AntiAimBind ~= "None" then
        Config.AntiAimEnabled = not Config.AntiAimEnabled; refreshUI()
    end
    if key == Config.KillAuraBind and Config.KillAuraBind ~= "None" then
        Config.KillAura = not Config.KillAura; refreshUI()
    end
    if key == Config.AutoShootBind and Config.AutoShootBind ~= "None" then
        Config.AutoShoot = not Config.AutoShoot; refreshUI()
    end
    if key == Config.AutoGrabBind and Config.AutoGrabBind ~= "None" then
        Config.AutoGrabGun = not Config.AutoGrabGun; refreshUI()
    end
    if key == Config.NoClipBind and Config.NoClipBind ~= "None" then
        Config.NoClip = not Config.NoClip; refreshUI()
    end
    if key == Config.FlingBind and Config.FlingBind ~= "None" then
        local target = Players:FindFirstChild(Config.FlingTarget)
        if target and target.Character then FlingPlayer(target.Character) end
    end
end)

local lastTrigger = 0
local function tryTrigger()
    if tick() - lastTrigger < Config.TriggerDelay/1000 then return end
    local char = LocalPlayer.Character
    if not char then return end
    local gun = char:FindFirstChild("Gun")
    if not gun then return end
    local mouse = LocalPlayer:GetMouse()
    local target = mouse.Target
    if not target then return end
    local plr = Players:GetPlayerFromCharacter(target.Parent) or Players:GetPlayerFromCharacter(target.Parent.Parent)
    if plr and plr ~= LocalPlayer then
        if Config.TriggerOnlyMurderer and GetRole(plr) ~= "Murderer" then return end
        pcall(function() gun:Activate() end)
        lastTrigger = tick()
    end
end

-- ===== NO RECOIL / NO SPREAD =====
task.spawn(function()
    while not UNLOADED do
        if Config.NoRecoil or Config.NoSpread then
            local char = LocalPlayer.Character
            if char then
                local gun = char:FindFirstChild("Gun")
                if gun then
                    for _, v in pairs(gun:GetDescendants()) do
                        if v:IsA("NumberValue") or v:IsA("IntValue") then
                            local n = v.Name:lower()
                            if Config.NoRecoil and (n:find("recoil") or n:find("kick")) then pcall(function() v.Value = 0 end) end
                            if Config.NoSpread and (n:find("spread") or n:find("accuracy") or n:find("bloom")) then pcall(function() v.Value = 0 end) end
                        end
                    end
                end
            end
        end
        task.wait(0.1)
    end
end)

task.spawn(function()
    while not UNLOADED do
        pcall(checkOtherTags)
        pcall(function()
            if Config.ShowOwnTag and LocalPlayer.Character then createTagGui(LocalPlayer.Character)
            elseif not Config.ShowOwnTag and LocalPlayer.Character then removeTagGui(LocalPlayer.Character) end
            giveTagMarker()
        end)
        task.wait(1)
    end
end)

-- ============================================================
-- ===== ANTI-AIM ENGINE =====
-- ============================================================
local aaFrame = 0
local aaLagCounter = 0
local originalWalkSpeed = 16
local aaLastCFrame = nil

RunService.Heartbeat:Connect(function(dt)
    if UNLOADED or not Config.AntiAimEnabled then
        aaLabel.Visible = false
        return
    end

    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    aaFrame += 1

    -- FakeLag (choke) — обновляем позицию только каждые N тиков
    if Config.AntiAimFakeLag then
        aaLagCounter += 1
        if aaLagCounter < Config.AntiAimFakeLagInterval then
            if aaLastCFrame then
                pcall(function() hrp.CFrame = aaLastCFrame end)
            end
            return
        else
            aaLagCounter = 0
        end
    end

    -- Slow Walk
    if Config.AntiAimSlowWalk then
        hum.WalkSpeed = math.min(hum.WalkSpeed, 8)
    end

    -- Yaw
    local yaw = 0
    if Config.AntiAimYaw == "Static" then
        yaw = Config.AntiAimYawOffset
    elseif Config.AntiAimYaw == "Backwards" then
        yaw = 180 + Config.AntiAimYawOffset
    elseif Config.AntiAimYaw == "Sideways" then
        yaw = 90 + Config.AntiAimYawOffset
    elseif Config.AntiAimYaw == "Spin" then
        yaw = (aaFrame * Config.AntiAimSpinSpeed) % 360
    elseif Config.AntiAimYaw == "Jitter" then
        yaw = (aaFrame % 2 == 0) and (Config.AntiAimYawOffset + 90) or (Config.AntiAimYawOffset - 90)
    elseif Config.AntiAimYaw == "Random" then
        yaw = math.random(-180, 180)
    end

    -- LookAtEnemies — если врагов близко, поворачиваемся ЛИЦОМ на них
    if Config.AntiAimAtTargets then
        local closest, minDist = nil, 40
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local ehrp = p.Character:FindFirstChild("HumanoidRootPart")
                if ehrp then
                    local d = (hrp.Position - ehrp.Position).Magnitude
                    if d < minDist then closest = ehrp; minDist = d end
                end
            end
        end
        if closest then
            local dir = (closest.Position - hrp.Position)
            local lookYaw = math.deg(math.atan2(-dir.X, -dir.Z))
            yaw = lookYaw
        end
    end

    -- Pitch
    local pitch = 0
    if Config.AntiAimPitch == "Up" then pitch = -89
    elseif Config.AntiAimPitch == "Down" then pitch = 89
    elseif Config.AntiAimPitch == "Zero" then pitch = 0 end

    -- Собираем поворот
    local yawRad = math.rad(yaw)
    local pitchRad = math.rad(pitch)

    -- Применяем поворот к HumanoidRootPart (визуально для других)
    local pos = hrp.Position
    local newCFrame = CFrame.new(pos) * CFrame.Angles(0, yawRad, 0) * CFrame.Angles(pitchRad, 0, 0)

    -- Desync — верх туда, "ноги" (HRP) в другую сторону
    if Config.AntiAimDesync then
        local desyncRad = math.rad(Config.AntiAimDesyncAngle)
        newCFrame = CFrame.new(pos) * CFrame.Angles(0, yawRad + desyncRad, 0) * CFrame.Angles(pitchRad, 0, 0)

        -- Крутим верхнюю часть в противоположную (визуально)
        local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
        if torso then
            pcall(function()
                torso.CFrame = torso.CFrame * CFrame.Angles(0, -desyncRad * 2, 0)
            end)
        end
    end

    pcall(function() hrp.CFrame = newCFrame end)
    aaLastCFrame = newCFrame

    -- HUD
    if Config.AntiAimShowIndicator then
        local mode = Config.AntiAimYaw
        if Config.AntiAimAtTargets then mode = "LookAt" end
        aaLabel.Text = string.format(
            '<font color="rgb(235,50,75)">AA</font> <font color="rgb(255,255,255)">| %s | pitch: %s%s%s</font>',
            mode,
            Config.AntiAimPitch,
            Config.AntiAimDesync and " | DESYNC" or "",
            Config.AntiAimFakeLag and " | LAG" or ""
        )
        aaLabel.Visible = true
    else
        aaLabel.Visible = false
    end
end)

-- ===== MAIN LOOP =====
RunService.RenderStepped:Connect(function()
    if UNLOADED then return end
    EspFolder:ClearAllChildren()

    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    if not Config.AntiAimSlowWalk then hum.WalkSpeed = Config.WalkSpeed end
    hum.JumpPower = Config.JumpPower
    Camera.FieldOfView = Config.StretchedResolution

    if Config.FullBright then
        Lighting.Brightness = 3
        Lighting.Ambient = Color3.new(1,1,1)
        Lighting.OutdoorAmbient = Color3.new(1,1,1)
    end
    if Config.RemoveFog then Lighting.FogEnd = 100000 end

    if Config.InfiniteJump and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end

    if Config.FastBHop and isBindPressed(Config.BHopBind) and hum.MoveDirection.Magnitude > 0 then
        hum.Jump = true
        hrp.CFrame += hum.MoveDirection * 0.15
    end

    if Config.WallHop and hum:GetState() == Enum.HumanoidStateType.Freefall and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        local ray = Ray.new(hrp.Position, hrp.CFrame.LookVector * 2.5)
        local hit = Workspace:FindPartOnRayWithIgnoreList(ray, {char})
        if hit then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
            hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 35, hrp.AssemblyLinearVelocity.Z)
        end
    end

    if Config.NoClip then
        for _, p in pairs(char:GetChildren()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end

    if Config.AntiFling then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local ohrp = p.Character:FindFirstChild("HumanoidRootPart")
                if ohrp and ohrp.AssemblyLinearVelocity.Magnitude > 45 then
                    for _, part in pairs(p.Character:GetChildren()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end
            end
        end
    end

    if Config.EspPlayers then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local pChar = p.Character
                local pHead = pChar:FindFirstChild("Head")
                local pHum = pChar:FindFirstChildOfClass("Humanoid")
                local role = GetRole(p)

                local color = Color3.fromRGB(255, 255, 255)
                if Config.EspRoles then
                    if role == "Murderer" then color = Color3.fromRGB(255, 40, 40)
                    elseif role == "Sheriff" then color = Color3.fromRGB(40, 100, 255)
                    else color = Color3.fromRGB(60, 220, 60) end
                end

                if Config.EspBoxes then
                    local box = Instance.new("BoxHandleAdornment")
                    box.Size = pChar:GetExtentsSize()
                    box.Color3 = color
                    box.AlwaysOnTop = true
                    box.Transparency = 0.75
                    box.ZIndex = 5
                    box.Adornee = pChar.HumanoidRootPart
                    box.Parent = EspFolder
                end

                if (Config.EspNames or Config.EspHealth or Config.EspDistance) and pHead then
                    local bg = Instance.new("BillboardGui")
                    bg.Adornee = pHead
                    bg.Size = UDim2.new(0, 150, 0, 40)
                    bg.StudsOffset = Vector3.new(0, 2, 0)
                    bg.AlwaysOnTop = true
                    bg.Parent = EspFolder

                    local txt = ""
                    if Config.EspNames then txt = txt .. p.Name .. "\n" end
                    if Config.EspHealth and pHum then txt = txt .. "HP: " .. math.floor(pHum.Health) .. "\n" end
                    if Config.EspDistance then
                        local dist = math.floor((hrp.Position - pChar.HumanoidRootPart.Position).Magnitude)
                        txt = txt .. "[" .. dist .. "m]"
                    end

                    local lbl = Instance.new("TextLabel")
                    lbl.Size = UDim2.new(1, 0, 1, 0)
                    lbl.BackgroundTransparency = 1
                    lbl.Text = txt
                    lbl.TextColor3 = color
                    lbl.Font = Enum.Font.GothamSemibold
                    lbl.TextSize = 12
                    lbl.TextStrokeTransparency = 0.5
                    lbl.Parent = bg
                end
            end
        end
    end

    local gunDrop = Workspace:FindFirstChild("GunDrop")
    if Config.EspGun and gunDrop then
        local box = Instance.new("BoxHandleAdornment")
        box.Size = Vector3.new(2, 2, 2)
        box.Color3 = Color3.fromRGB(255, 215, 0)
        box.AlwaysOnTop = true
        box.Transparency = 0.5
        box.Adornee = gunDrop
        box.Parent = EspFolder
    end
    if Config.AutoGrabGun and gunDrop then hrp.CFrame = gunDrop.CFrame end

    if Config.FlingMurderer then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and GetRole(p) == "Murderer" and p.Character then
                FlingPlayer(p.Character)
            end
        end
    end

    if Config.KillAura and char:FindFirstChild("Knife") then
        local knife = char.Knife
        if knife:FindFirstChild("Handle") then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local thrp = p.Character:FindFirstChild("HumanoidRootPart")
                    if thrp and (hrp.Position - thrp.Position).Magnitude <= Config.AuraRadius then
                        pcall(function()
                            firetouchinterest(knife.Handle, thrp, 0)
                            firetouchinterest(knife.Handle, thrp, 1)
                        end)
                    end
                end
            end
        end
    end

    if Config.AutoShoot and char:FindFirstChild("Gun") then
        for _, p in pairs(Players:GetPlayers()) do
            if GetRole(p) == "Murderer" and p.Character then
                local mhrp = p.Character:FindFirstChild("HumanoidRootPart")
                if mhrp then
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, mhrp.Position)
                    pcall(function() char.Gun:Activate() end)
                end
            end
        end
    end

    if Config.TriggerBot and isBindPressed(Config.TriggerBind) then tryTrigger() end

    if FOVCircle then
        FOVCircle.Visible = Config.ShowFOV and Config.AimEnabled
        FOVCircle.Position = UserInputService:GetMouseLocation()
        FOVCircle.Radius = Config.AimRadius
    end

    if Config.AimEnabled and isBindPressed(Config.AimBind) then
        local target = nil
        local maxD = Config.AimRadius
        local mousePos = UserInputService:GetMouseLocation()

        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                local role = GetRole(p)
                if not (Config.AimTargetMode == "Gun" and role ~= "Sheriff") then
                    local aimPart = p.Character:FindFirstChild("Head")
                    if Config.AimTargetMode == "Torso" then aimPart = p.Character:FindFirstChild("HumanoidRootPart") or aimPart end
                    if aimPart then
                        local aimPos = aimPart.Position
                        if Config.AimPrediction then
                            local vel = aimPart.AssemblyLinearVelocity or Vector3.new()
                            aimPos = aimPos + vel * 0.15
                        end
                        local pos, onScreen = Camera:WorldToViewportPoint(aimPos)
                        if onScreen then
                            local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                            if dist < maxD then target = aimPart; maxD = dist end
                        end
                    end
                end
            end
        end

        if target then
            local goal = CFrame.new(Camera.CFrame.Position, target.Position)
            Camera.CFrame = Camera.CFrame:Lerp(goal, 1 / math.max(Config.AimSmoothness, 1))
        end
    end
end)

print("✅ MemeSense v5 LOADED | Anti-Aim available | INSERT | END = panic")
