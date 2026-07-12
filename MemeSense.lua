-- ==========================================
-- MEMESENSE MM2 | FULL EDITION
-- Всё на твой страх и риск
-- ==========================================

local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

pcall(function()
    if CoreGui:FindFirstChild("MemeSense_UI") then
        CoreGui.MemeSense_UI:Destroy()
    end
end)

-- ===== CONFIG =====
local Config = {
    -- Aimbot
    AimEnabled = false,
    AimRadius = 100,
    AimSmoothness = 1,
    AimBind = "MouseButton2",
    AimTargetMode = "Head",
    AimTeamCheck = false,
    AimVisibleOnly = false,
    AimPrediction = false,
    ShowFOV = true,
    FOVColor = Color3.fromRGB(235, 50, 75),

    -- Triggerbot
    TriggerBot = false,
    TriggerBind = "T",
    TriggerDelay = 50,
    TriggerOnlyMurderer = true,

    -- ESP
    EspPlayers = false,
    EspBoxes = true,
    EspNames = true,
    EspHealth = true,
    EspDistance = false,
    EspTracers = false,
    EspRoles = true,
    EspGun = false,
    ShowClanTags = true,

    -- Combat
    KillAura = false,
    AuraRadius = 15,
    AutoShoot = false,
    AutoGrabGun = false,
    SilentAim = false,
    FlingTarget = "",
    FlingMurderer = false,

    -- Movement
    WalkSpeed = 16,
    JumpPower = 50,
    InfiniteJump = false,
    AntiFling = true,
    FastBHop = false,
    WallHop = false,
    NoClip = false,

    -- Visuals
    StretchedResolution = 70,
    FullBright = false,
    RemoveFog = false,
    ThirdPerson = false,
}

-- ===== TAG TOOL =====
local function giveTagTool()
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack or backpack:FindFirstChild("MemeSense_Tag") then return end
    local tool = Instance.new("Tool")
    tool.Name = "MemeSense_Tag"
    tool.RequiresHandle = false
    tool.CanBeDropped = false
    tool.Parent = backpack
end
giveTagTool()
LocalPlayer.CharacterAdded:Connect(function() task.wait(1) giveTagTool() end)

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
mainFrame.BorderSizePixel = 1
mainFrame.Active = true
mainFrame.Parent = screenGui

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 2)
topBar.BackgroundColor3 = Color3.fromRGB(235, 50, 75)
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame

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
pagesContainer.Size = UDim2.new(1, -160, 1, -20)
pagesContainer.Position = UDim2.new(0, 155, 0, 12)
pagesContainer.BackgroundTransparency = 1
pagesContainer.Parent = mainFrame

-- Toggle
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert then
        mainFrame.Visible = not mainFrame.Visible
    end
end)

-- Drag
local dragging, dragStart, startPos
mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
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

function UI:CreateSection(parent, name, size, pos)
    local section = Instance.new("Frame")
    section.Size = size
    section.Position = pos
    section.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    section.BorderColor3 = Color3.fromRGB(28, 28, 28)
    section.BorderSizePixel = 1
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

    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -20, 1, -30)
    content.Position = UDim2.new(0, 10, 0, 28)
    content.BackgroundTransparency = 1
    content.Parent = section

    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 4)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Parent = content

    return content
end

function UI:CreateCheckbox(parent, text, varName)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 18)
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
end

function UI:CreateSlider(parent, text, min, max, varName)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 30)
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
            local mousePos = UserInputService:GetMouseLocation()
            local percent = math.clamp((mousePos.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            fill.Size = UDim2.new(percent, 0, 1, 0)
            local res = math.floor(min + (max - min) * percent)
            val.Text = tostring(res)
            Config[varName] = res
        end
    end)
end

-- Bind
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
    frame.Size = UDim2.new(1, 0, 0, 20)
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
end

function UI:CreateDropdown(parent, text, options, varName)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 20)
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
end

function UI:CreateInput(parent, text, varName)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 22)
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

    box.FocusLost:Connect(function()
        Config[varName] = box.Text
    end)
end

function UI:CreateButton(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 20)
    btn.BackgroundColor3 = Color3.fromRGB(235, 50, 75)
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.AutoButtonColor = true
    btn.Parent = parent
    btn.MouseButton1Click:Connect(callback)
end

-- ===== TABS =====
local tabs = {"Legitbot", "Ragebot", "Visuals", "Movement", "MM2 Exploit", "Misc"}
local activePage, activeTabBtn, activeIndicator

for i, tName in ipairs(tabs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.Position = UDim2.new(0, 0, 0, 55 + (i-1)*30)
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

    if i == 1 then
        activePage = page
        activeTabBtn = btn
        activeIndicator = indicator
    end

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

    -- ==================== LEGITBOT ====================
    if tName == "Legitbot" then
        local s1 = UI:CreateSection(page, "Aimbot", UDim2.new(0, 245, 0, 200), UDim2.new(0, 5, 0, 5))
        UI:CreateCheckbox(s1, "Enable Aim", "AimEnabled")
        UI:CreateBindButton(s1, "Aim Key", "AimBind")
        UI:CreateSlider(s1, "FOV Radius", 10, 400, "AimRadius")
        UI:CreateSlider(s1, "Smoothness", 1, 20, "AimSmoothness")
        UI:CreateDropdown(s1, "Target", {"Head", "Torso", "Gun"}, "AimTargetMode")
        UI:CreateCheckbox(s1, "Team Check", "AimTeamCheck")
        UI:CreateCheckbox(s1, "Visible Only", "AimVisibleOnly")
        UI:CreateCheckbox(s1, "Prediction", "AimPrediction")

        local s2 = UI:CreateSection(page, "TriggerBot", UDim2.new(0, 245, 0, 130), UDim2.new(0, 260, 0, 5))
        UI:CreateCheckbox(s2, "Enable TriggerBot", "TriggerBot")
        UI:CreateBindButton(s2, "Trigger Key", "TriggerBind")
        UI:CreateSlider(s2, "Delay (ms)", 0, 500, "TriggerDelay")
        UI:CreateCheckbox(s2, "Only Murderer", "TriggerOnlyMurderer")

        local s3 = UI:CreateSection(page, "FOV Circle", UDim2.new(0, 500, 0, 55), UDim2.new(0, 5, 0, 210))
        UI:CreateCheckbox(s3, "Show FOV Circle", "ShowFOV")

    -- ==================== RAGEBOT ====================
    elseif tName == "Ragebot" then
        local s1 = UI:CreateSection(page, "Silent Aim", UDim2.new(0, 245, 0, 100), UDim2.new(0, 5, 0, 5))
        UI:CreateCheckbox(s1, "Silent Aim (Sheriff)", "SilentAim")
        UI:CreateCheckbox(s1, "Auto Shoot Murderer", "AutoShoot")

        local s2 = UI:CreateSection(page, "Kill Aura", UDim2.new(0, 245, 0, 100), UDim2.new(0, 260, 0, 5))
        UI:CreateCheckbox(s2, "Kill Aura (Murderer)", "KillAura")
        UI:CreateSlider(s2, "Aura Radius", 5, 50, "AuraRadius")

        local s3 = UI:CreateSection(page, "Auto Pickup", UDim2.new(0, 245, 0, 60), UDim2.new(0, 5, 0, 115))
        UI:CreateCheckbox(s3, "Auto Grab Dropped Gun", "AutoGrabGun")

    -- ==================== VISUALS ====================
    elseif tName == "Visuals" then
        local s1 = UI:CreateSection(page, "ESP", UDim2.new(0, 245, 0, 175), UDim2.new(0, 5, 0, 5))
        UI:CreateCheckbox(s1, "Enable ESP", "EspPlayers")
        UI:CreateCheckbox(s1, "Boxes", "EspBoxes")
        UI:CreateCheckbox(s1, "Names", "EspNames")
        UI:CreateCheckbox(s1, "Health Bars", "EspHealth")
        UI:CreateCheckbox(s1, "Distance", "EspDistance")
        UI:CreateCheckbox(s1, "Tracers", "EspTracers")
        UI:CreateCheckbox(s1, "Color by Role", "EspRoles")

        local s2 = UI:CreateSection(page, "World ESP", UDim2.new(0, 245, 0, 90), UDim2.new(0, 260, 0, 5))
        UI:CreateCheckbox(s2, "Dropped Gun ESP", "EspGun")
        UI:CreateCheckbox(s2, "Show ClanTags", "ShowClanTags")

        local s3 = UI:CreateSection(page, "World", UDim2.new(0, 500, 0, 130), UDim2.new(0, 5, 0, 185))
        UI:CreateSlider(s3, "Camera FOV", 70, 120, "StretchedResolution")
        UI:CreateCheckbox(s3, "Full Bright", "FullBright")
        UI:CreateCheckbox(s3, "Remove Fog", "RemoveFog")
        UI:CreateCheckbox(s3, "Third Person", "ThirdPerson")

    -- ==================== MOVEMENT ====================
    elseif tName == "Movement" then
        local s1 = UI:CreateSection(page, "Speed & Jump", UDim2.new(0, 245, 0, 130), UDim2.new(0, 5, 0, 5))
        UI:CreateSlider(s1, "WalkSpeed", 16, 100, "WalkSpeed")
        UI:CreateSlider(s1, "JumpPower", 50, 200, "JumpPower")
        UI:CreateCheckbox(s1, "Infinite Jump", "InfiniteJump")

        local s2 = UI:CreateSection(page, "Exploits", UDim2.new(0, 245, 0, 130), UDim2.new(0, 260, 0, 5))
        UI:CreateCheckbox(s2, "Fast BHop (Hold Space)", "FastBHop")
        UI:CreateCheckbox(s2, "WallHop", "WallHop")
        UI:CreateCheckbox(s2, "NoClip", "NoClip")
        UI:CreateCheckbox(s2, "Anti-Fling", "AntiFling")

    -- ==================== MM2 EXPLOIT ====================
    elseif tName == "MM2 Exploit" then
        local s1 = UI:CreateSection(page, "Fling", UDim2.new(0, 245, 0, 160), UDim2.new(0, 5, 0, 5))
        UI:CreateInput(s1, "Target Name", "FlingTarget")
        UI:CreateCheckbox(s1, "Auto Fling Murderer", "FlingMurderer")
        UI:CreateButton(s1, "Execute Fling", function()
            local target = Players:FindFirstChild(Config.FlingTarget)
            if target and target.Character then FlingPlayer(target.Character) end
        end)

        local s2 = UI:CreateSection(page, "Teleports", UDim2.new(0, 245, 0, 160), UDim2.new(0, 260, 0, 5))
        UI:CreateInput(s2, "TP to Player", "FlingTarget")
        UI:CreateButton(s2, "Teleport", function()
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

    -- ==================== MISC ====================
    elseif tName == "Misc" then
        local s1 = UI:CreateSection(page, "Info", UDim2.new(0, 500, 0, 100), UDim2.new(0, 5, 0, 5))
        local info = Instance.new("TextLabel")
        info.Size = UDim2.new(1, 0, 0, 60)
        info.BackgroundTransparency = 1
        info.RichText = true
        info.Text = "<font color='rgb(235,50,75)'>MemeSense MM2</font> | Full Edition\nПресс <b>INSERT</b> — скрыть/показать меню\nАвтор: private build"
        info.TextColor3 = Color3.fromRGB(180, 180, 180)
        info.Font = Enum.Font.Gotham
        info.TextSize = 12
        info.TextXAlignment = Enum.TextXAlignment.Left
        info.TextYAlignment = Enum.TextYAlignment.Top
        info.Parent = s1

        local s2 = UI:CreateSection(page, "Server", UDim2.new(0, 245, 0, 90), UDim2.new(0, 5, 0, 115))
        UI:CreateButton(s2, "Rejoin Server", function()
            game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
        end)
        UI:CreateButton(s2, "Server Hop", function()
            local ts = game:GetService("TeleportService")
            pcall(function() ts:Teleport(game.PlaceId, LocalPlayer) end)
        end)

        local s3 = UI:CreateSection(page, "Character", UDim2.new(0, 245, 0, 90), UDim2.new(0, 260, 0, 115))
        UI:CreateButton(s3, "Reset Character", function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                LocalPlayer.Character:FindFirstChildOfClass("Humanoid").Health = 0
            end
        end)
        UI:CreateButton(s3, "Refresh Tag", giveTagTool)
    end
end

-- ===== FOV CIRCLE =====
local FOVCircle
if Drawing then
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Thickness = 1
    FOVCircle.NumSides = 60
    FOVCircle.Filled = false
    FOVCircle.Color = Config.FOVColor
    FOVCircle.Visible = false
end

-- ===== ROLE =====
local function GetRole(p)
    if not p or not p.Character then return "Innocent" end
    local bp = p:FindFirstChild("Backpack")
    if (bp and bp:FindFirstChild("Knife")) or p.Character:FindFirstChild("Knife") then return "Murderer" end
    if (bp and bp:FindFirstChild("Gun")) or p.Character:FindFirstChild("Gun") then return "Sheriff" end
    return "Innocent"
end

-- ===== ESP FOLDER =====
local EspFolder = Instance.new("Folder")
EspFolder.Name = "MemeESP"
EspFolder.Parent = CoreGui

-- ===== TRIGGER BOT =====
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

-- ===== MAIN LOOP =====
RunService.RenderStepped:Connect(function()
    EspFolder:ClearAllChildren()

    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    hum.WalkSpeed = Config.WalkSpeed
    hum.JumpPower = Config.JumpPower
    Camera.FieldOfView = Config.StretchedResolution

    -- FullBright
    if Config.FullBright then
        game.Lighting.Brightness = 3
        game.Lighting.Ambient = Color3.new(1,1,1)
        game.Lighting.OutdoorAmbient = Color3.new(1,1,1)
    end
    if Config.RemoveFog then
        game.Lighting.FogEnd = 100000
    end

    -- Third Person
    if Config.ThirdPerson then
        LocalPlayer.CameraMode = Enum.CameraMode.Classic
        LocalPlayer.CameraMinZoomDistance = 10
    end

    -- Infinite Jump
    if Config.InfiniteJump and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end

    -- BHop
    if Config.FastBHop and UserInputService:IsKeyDown(Enum.KeyCode.Space) and hum.MoveDirection.Magnitude > 0 then
        hum.Jump = true
        hrp.CFrame += hum.MoveDirection * 0.15
    end

    -- WallHop
    if Config.WallHop and hum:GetState() == Enum.HumanoidStateType.Freefall and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        local ray = Ray.new(hrp.Position, hrp.CFrame.LookVector * 2.5)
        local hit = Workspace:FindPartOnRayWithIgnoreList(ray, {char})
        if hit then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
            hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 35, hrp.AssemblyLinearVelocity.Z)
        end
    end

    -- NoClip
    if Config.NoClip then
        for _, p in pairs(char:GetChildren()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end

    -- Anti-Fling
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

    -- ESP
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

                local bp = p:FindFirstChild("Backpack")
                local hasTag = (bp and bp:FindFirstChild("MemeSense_Tag")) or pChar:FindFirstChild("MemeSense_Tag")
                if hasTag and Config.ShowClanTags and pHead then
                    color = Color3.fromRGB(235, 50, 75)
                    local bg = Instance.new("BillboardGui")
                    bg.Adornee = pHead
                    bg.Size = UDim2.new(0, 120, 0, 20)
                    bg.StudsOffset = Vector3.new(0, 3.5, 0)
                    bg.AlwaysOnTop = true
                    bg.Parent = EspFolder

                    local tag = Instance.new("TextLabel")
                    tag.Size = UDim2.new(1, 0, 1, 0)
                    tag.BackgroundTransparency = 1
                    tag.Text = "[MemeSense]"
                    tag.TextColor3 = Color3.fromRGB(235, 50, 75)
                    tag.Font = Enum.Font.GothamBold
                    tag.TextSize = 13
                    tag.Parent = bg
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
                    bg.StudsOffset = Vector3.new(0, 2.5, 0)
                    bg.AlwaysOnTop = true
                    bg.Parent = EspFolder

                    local txt = ""
                    if Config.EspNames then txt = txt .. p.Name .. "\n" end
                    if Config.EspHealth and pHum then
                        txt = txt .. "HP: " .. math.floor(pHum.Health) .. "\n"
                    end
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

                if Config.EspTracers then
                    local screen = Instance.new("ScreenGui")
                    screen.Parent = EspFolder
                    local line = Drawing and Drawing.new("Line")
                    if line then
                        local pos, on = Camera:WorldToViewportPoint(pChar.HumanoidRootPart.Position)
                        if on then
                            line.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                            line.To = Vector2.new(pos.X, pos.Y)
                            line.Color = color
                            line.Thickness = 1
                            line.Visible = true
                            task.delay(0.03, function() line:Remove() end)
                        end
                    end
                end
            end
        end
    end

    -- Gun ESP
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
    if Config.AutoGrabGun and gunDrop then
        hrp.CFrame = gunDrop.CFrame
    end

    -- Fling Murderer
    if Config.FlingMurderer then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and GetRole(p) == "Murderer" and p.Character then
                FlingPlayer(p.Character)
            end
        end
    end

    -- KillAura
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

    -- AutoShoot
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

    -- TriggerBot
    if Config.TriggerBot then
        local pressed = false
        if Config.TriggerBind:find("MouseButton") then
            local num = tonumber(Config.TriggerBind:match("%d+"))
            if num == 1 then pressed = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
            elseif num == 2 then pressed = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) end
        else
            local ok, k = pcall(function() return Enum.KeyCode[Config.TriggerBind] end)
            if ok and k then pressed = UserInputService:IsKeyDown(k) end
        end
        if pressed then tryTrigger() end
    end

    -- FOV Circle
    if FOVCircle then
        FOVCircle.Visible = Config.ShowFOV and Config.AimEnabled
        FOVCircle.Position = UserInputService:GetMouseLocation()
        FOVCircle.Radius = Config.AimRadius
        FOVCircle.Color = Config.FOVColor
    end

    -- Aimbot
    if Config.AimEnabled then
        local isPressed = false
        if Config.AimBind:find("MouseButton") then
            local num = tonumber(Config.AimBind:match("%d+"))
            if num == 1 then isPressed = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
            elseif num == 2 then isPressed = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) end
        else
            local ok, keyEnum = pcall(function() return Enum.KeyCode[Config.AimBind] end)
            if ok and keyEnum then isPressed = UserInputService:IsKeyDown(keyEnum) end
        end

        if isPressed then
            local target = nil
            local maxD = Config.AimRadius
            local mousePos = UserInputService:GetMouseLocation()

            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                    local role = GetRole(p)
                    if Config.AimTargetMode == "Gun" and role ~= "Sheriff" then continue end

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
                            if dist < maxD then
                                target = aimPart
                                maxD = dist
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
    end
end)

print("✅ MemeSense MM2 Full Edition LOADED | INSERT to toggle")
