local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Сетевая синхронизация для других юзеров софта
pcall(function() LocalPlayer:SetAttribute("MemeSense_User", true) end)

if CoreGui:FindFirstChild("MemeSense_UI") then
    CoreGui.MemeSense_UI:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MemeSense_UI"
screenGui.ResetOnSpawn = false
screenGui.Parent = CoreGui

-- Глобальный конфиг
local Config = {
    AimEnabled = false,
    AimRadius = 100,
    AimBind = "MouseButton2",
    AimTargetMode = "Head",
    
    EspPlayers = false,
    EspRoles = false,
    EspGun = false,
    ShowClanTags = true,
    
    KillAura = false,
    AuraRadius = 15,
    AutoShoot = false,
    AutoGrabGun = false,
    FlingTarget = "",
    FlingMurderer = false,
    
    WalkSpeed = 16,
    AntiFling = true,
    FastBHop = false,
    WallHop = false,
    StretchedResolution = 70 -- FOV / Растяг
}

-- === ФАЙЛОВАЯ СИСТЕМА КОНФИГОВ ===
local ConfigFolder = "MemeSense_Configs"
local SelectedConfig = "default"

local makefolder = makefolder or function() end
local listfiles = listfiles or function() return {} end
local writefile = writefile or print
local readfile = readfile or function() return "{}" end
local isfile = isfile or function() return false end
local delfile = delfile or function() end

pcall(function() makefolder(ConfigFolder) end)

local function GetConfigsList()
    local files = {}
    local success, result = pcall(function() return listfiles(ConfigFolder) end)
    if success and type(result) == "table" then
        for _, path in ipairs(result) do
            local fileName = path:match("([^/\\]+)%.json$")
            if fileName then table.insert(files, fileName) end
        end
    end
    return files
end

local function SaveConfig(name)
    if not name or name == "" then return end
    local path = ConfigFolder .. "/" .. name .. ".json"
    local success, json = pcall(function() return HttpService:JSONEncode(Config) end)
    if success then writefile(path, json) end
end

local function LoadConfig(name)
    local path = ConfigFolder .. "/" .. name .. ".json"
    if isfile(path) then
        local success, data = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
        if success and type(data) == "table" then
            for k, v in pairs(data) do Config[k] = v end
        end
    end
end

local function DeleteConfig(name)
    local path = ConfigFolder .. "/" .. name .. ".json"
    if isfile(path) then pcall(function() delfile(path) end) end
end

-- === АУТЕНТИЧНЫЙ ИНТЕРФЕЙС (ФИКС ТЕКСТА) ===
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 680, 0, 470)
mainFrame.Position = UDim2.new(0.5, -340, 0.5, -235)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mainFrame.BorderColor3 = Color3.fromRGB(35, 35, 35)
mainFrame.BorderSizePixel = 1
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
sideBar.BorderSizePixel = 1
sideBar.Parent = mainFrame

-- Белая надпись Meme, Красная Sense
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

local menuVisible = true
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert then
        menuVisible = not menuVisible
        mainFrame.Visible = menuVisible
    end
end)

local dragging, dragInput, dragStart, startPos
mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = input.Position; startPos = mainFrame.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
mainFrame.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- === БИБЛИОТЕКА ЭЛЕМЕНТОВ (БЕЗ ВЫЛЕЗАНИЙ ТЕКСТА) ===
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
    title.TextTruncate = Enum.TextTruncate.AtEnd
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
    list.Padding = UDim.new(0, 6)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Parent = content

    return content
end

function UI:CreateCheckbox(parent, text, varName)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 20)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local box = Instance.new("TextButton")
    box.Size = UDim2.new(0, 14, 0, 14)
    box.Position = UDim2.new(0, 0, 0, 3)
    box.BackgroundColor3 = Config[varName] and Color3.fromRGB(235, 50, 75) or Color3.fromRGB(25, 25, 25)
    box.BorderColor3 = Color3.fromRGB(45, 45, 45)
    box.Text = ""
    box.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -24, 1, 0)
    label.Position = UDim2.new(0, 22, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(180, 180, 180)
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextTruncate = Enum.TextTruncate.AtEnd
    label.Parent = frame

    box.MouseButton1Click:Connect(function()
        Config[varName] = not Config[varName]
        box.BackgroundColor3 = Config[varName] and Color3.fromRGB(235, 50, 75) or Color3.fromRGB(25, 25, 25)
    end)
end

function UI:CreateSlider(parent, text, min, max, varName)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 32)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -45, 0, 14)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(160, 160, 160)
    label.Font = Enum.Font.Gotham
    label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextTruncate = Enum.TextTruncate.AtEnd
    label.Parent = frame

    local bar = Instance.new("TextButton")
    bar.Size = UDim2.new(1, -45, 0, 4)
    bar.Position = UDim2.new(0, 0, 0, 20)
    bar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    bar.BorderSizePixel = 0
    bar.Text = ""
    bar.Parent = frame

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((Config[varName] - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(235, 50, 75)
    fill.BorderSizePixel = 0
    fill.Parent = bar

    local val = Instance.new("TextLabel")
    val.Size = UDim2.new(0, 40, 0, 14)
    val.Position = UDim2.new(1, -40, 0, 15)
    val.BackgroundTransparency = 1
    val.Text = tostring(Config[varName])
    val.TextColor3 = Color3.fromRGB(140, 140, 140)
    val.Font = Enum.Font.Gotham
    val.TextSize = 11
    val.Parent = frame

    local snap = false
    bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then snap = true end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then snap = false end end)
    UserInputService.InputChanged:Connect(function(input)
        if snap and input.UserInputType == Enum.UserInputType.MouseMovement then
            local percent = math.clamp((UserInputService:GetMouseLocation().X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            fill.Size = UDim2.new(percent, 0, 1, 0)
            local res = math.floor(min + (max - min) * percent)
            val.Text = tostring(res)
            Config[varName] = res
        end
    end)
end

function UI:CreateBindButton(parent, text, varName)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 22)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -85, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(175, 175, 175)
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextTruncate = Enum.TextTruncate.AtEnd
    label.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 80, 0, 18)
    btn.Position = UDim2.new(1, -80, 0, 2)
    btn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    btn.BorderColor3 = Color3.fromRGB(45, 45, 45)
    btn.Text = Config[varName]
    btn.TextColor3 = Color3.fromRGB(230, 230, 230)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 11
    btn.Parent = frame

    local listening = false
    btn.MouseButton1Click:Connect(function() listening = true; btn.Text = "..." end)
    UserInputService.InputBegan:Connect(function(input)
        if listening then
            listening = false
            local key = input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode.Name or input.UserInputType.Name
            Config[varName] = key; btn.Text = key
        end
    end)
end

function UI:CreateInput(parent, text, varName)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 24)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -105, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(175, 175, 175)
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextTruncate = Enum.TextTruncate.AtEnd
    label.Parent = frame

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0, 100, 0, 18)
    box.Position = UDim2.new(1, -100, 0, 3)
    box.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    box.BorderColor3 = Color3.fromRGB(45, 45, 45)
    box.Text = Config[varName]
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.Font = Enum.Font.Gotham
    box.TextSize = 11
    box.Parent = frame
    box.FocusLost:Connect(function() Config[varName] = box.Text end)
end

-- === ГЕНЕРАЦИЯ ВКЛАДОК ===
local tabs = {"Legitbot", "Visuals", "Movement", "MM2 Exploit", "Configs"}
local activePage, activeTabBtn, activeIndicator = nil, nil, nil

for i, tName in ipairs(tabs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.Position = UDim2.new(0, 0, 0, 55 + (i-1)*32)
    btn.BackgroundTransparency = 1
    btn.Text = "     " .. tName
    btn.TextColor3 = i == 1 and Color3.fromRGB(235, 50, 75) or Color3.fromRGB(135, 135, 135)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
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
        if activePage then activePage.Visible = false end
        if activeTabBtn then activeTabBtn.TextColor3 = Color3.fromRGB(135, 135, 135) end
        if activeIndicator then activeIndicator.Visible = false end
        
        page.Visible = true; activePage = page
        btn.TextColor3 = Color3.fromRGB(235, 50, 75); activeTabBtn = btn
        indicator.Visible = true; activeIndicator = indicator
    end)

    if tName == "Legitbot" then
        local sec = UI:CreateSection(page, "Aimbot Settings", UDim2.new(0, 245, 0, 210), UDim2.new(0, 5, 0, 5))
        UI:CreateCheckbox(sec, "Enable Aim", "AimEnabled")
        UI:CreateSlider(sec, "FOV Radius", 10, 400, "AimRadius")
        UI:CreateBindButton(sec, "Aim Bind", "AimBind")
        
        local secTarget = UI:CreateSection(page, "Target Mode", UDim2.new(0, 245, 0, 90), UDim2.new(0, 260, 0, 5))
        local modeBtn = Instance.new("TextButton")
        modeBtn.Size = UDim2.new(1, 0, 0, 24)
        modeBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
        modeBtn.BorderColor3 = Color3.fromRGB(45, 45, 45)
        modeBtn.Text = "Target: Head"
        modeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        modeBtn.Font = Enum.Font.Gotham
        modeBtn.TextSize = 11
        modeBtn.Parent = secTarget
        modeBtn.MouseButton1Click:Connect(function()
            Config.AimTargetMode = (Config.AimTargetMode == "Head") and "Gun" or "Head"
            modeBtn.Text = (Config.AimTargetMode == "Head") and "Target: Head" or "Target: Gun (Sheriff)"
        end)

    elseif tName == "Visuals" then
        local sec = UI:CreateSection(page, "ESP Core", UDim2.new(0, 245, 0, 180), UDim2.new(0, 5, 0, 5))
        UI:CreateCheckbox(sec, "Box ESP", "EspPlayers")
        UI:CreateCheckbox(sec, "Filter Roles", "EspRoles")
        UI:CreateCheckbox(sec, "Dropped Gun ESP", "EspGun")
        UI:CreateCheckbox(sec, "Show MemeSense ClanTags", "ShowClanTags")
        
        local secCam = UI:CreateSection(page, "Camera / Screen", UDim2.new(0, 245, 0, 100), UDim2.new(0, 260, 0, 5))
        UI:CreateSlider(secCam, "Stretched FOV", 70, 120, "StretchedResolution")

    elseif tName == "Movement" then
        local sec = UI:CreateSection(page, "Player Movement", UDim2.new(0, 245, 0, 220), UDim2.new(0, 5, 0, 5))
        UI:CreateSlider(sec, "WalkSpeed", 16, 60, "WalkSpeed")
        UI:CreateCheckbox(sec, "Fast BHop (Hold Space)", "FastBHop")
        UI:CreateCheckbox(sec, "WallHop Exploit", "WallHop")
        UI:CreateCheckbox(sec, "Anti-Fling Protection", "AntiFling")

    elseif tName == "MM2 Exploit" then
        local sec = UI:CreateSection(page, "Combat", UDim2.new(0, 245, 0, 180), UDim2.new(0, 5, 0, 5))
        UI:CreateCheckbox(sec, "KillAura (Murderer)", "KillAura")
        UI:CreateCheckbox(sec, "Auto Shoot (Sheriff)", "AutoShoot")
        UI:CreateCheckbox(sec, "Auto Grab Gun", "AutoGrabGun")
        
        local secFling = UI:CreateSection(page, "Fling Exploits", UDim2.new(0, 245, 0, 130), UDim2.new(0, 260, 0, 5))
        UI:CreateInput(secFling, "Target Name", "FlingTarget")
        UI:CreateCheckbox(secFling, "Auto Fling Murderer", "FlingMurderer")
        
        local flingBtn = Instance.new("TextButton")
        flingBtn.Size = UDim2.new(1, 0, 0, 24)
        flingBtn.BackgroundColor3 = Color3.fromRGB(235, 50, 75)
        flingBtn.BorderSizePixel = 0
        flingBtn.Text = "Execute Fling"
        flingBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        flingBtn.Font = Enum.Font.GothamBold
        flingBtn.TextSize = 11
        flingBtn.Parent = secFling
        flingBtn.MouseButton1Click:Connect(function()
            local target = Players:FindFirstChild(Config.FlingTarget)
            if target and target.Character then FlingPlayer(target.Character) end
        end)

    elseif tName == "Configs" then
        local listSec = UI:CreateSection(page, "Config List", UDim2.new(0, 240, 0, 430), UDim2.new(0, 5, 0, 5))
        local scrollFrame = Instance.new("ScrollingFrame")
        scrollFrame.Size = UDim2.new(1, 0, 1, 0)
        scrollFrame.BackgroundTransparency = 1
        scrollFrame.BorderSizePixel = 0
        scrollFrame.ScrollBarThickness = 3
        scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(235, 50, 75)
        scrollFrame.Parent = listSec

        local scrollLayout = Instance.new("UIListLayout")
        scrollLayout.Padding = UDim.new(0, 5)
        scrollLayout.Parent = scrollFrame

        local manageSec = UI:CreateSection(page, "Manage Configs", UDim2.new(0, 250, 0, 240), UDim2.new(0, 255, 0, 5))
        
        local nameBox = Instance.new("TextBox")
        nameBox.Size = UDim2.new(1, 0, 0, 24)
        nameBox.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        nameBox.BorderColor3 = Color3.fromRGB(45, 45, 45)
        nameBox.Text = SelectedConfig
        nameBox.PlaceholderText = "Config name..."
        nameBox.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameBox.Font = Enum.Font.Gotham
        nameBox.TextSize = 11
        nameBox.Parent = manageSec

        nameBox.FocusLost:Connect(function()
            if nameBox.Text ~= "" then SelectedConfig = nameBox.Text end
        end)

        local function RefreshConfigsUI()
            for _, child in pairs(scrollFrame:GetChildren()) do
                if child:IsA("TextButton") then child:Destroy() end
            end
            
            local files = GetConfigsList()
            for _, cfgName in ipairs(files) do
                local cfgBtn = Instance.new("TextButton")
                cfgBtn.Size = UDim2.new(1, -6, 0, 24)
                cfgBtn.BackgroundColor3 = (cfgName == SelectedConfig) and Color3.fromRGB(235, 50, 75) or Color3.fromRGB(25, 25, 25)
                cfgBtn.BorderColor3 = Color3.fromRGB(40, 40, 40)
                cfgBtn.Text = cfgName
                cfgBtn.TextColor3 = Color3.fromRGB(230, 230, 230)
                cfgBtn.Font = Enum.Font.Gotham
                cfgBtn.TextSize = 11
                cfgBtn.Parent = scrollFrame
                
                cfgBtn.MouseButton1Click:Connect(function()
                    SelectedConfig = cfgName
                    nameBox.Text = cfgName
                    RefreshConfigsUI()
                end)
            end
            scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #files * 29)
        end

        local function CreateActionButton(text, color, callback)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 26)
            btn.BackgroundColor3 = color
            btn.BorderSizePixel = 0
            btn.Text = text
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 11
            btn.Parent = manageSec
            btn.MouseButton1Click:Connect(callback)
            return btn
        end

        CreateActionButton("Create / Save Config", Color3.fromRGB(235, 50, 75), function() SaveConfig(nameBox.Text); RefreshConfigsUI() end)
        CreateActionButton("Load Config", Color3.fromRGB(35, 35, 35), function() LoadConfig(nameBox.Text) end)
        CreateActionButton("Delete Config", Color3.fromRGB(150, 30, 45), function() DeleteConfig(nameBox.Text); RefreshConfigsUI() end)
        CreateActionButton("Refresh List", Color3.fromRGB(45, 45, 45), function() RefreshConfigsUI() end)

        RefreshConfigsUI()
    end
end

-- === МЕХАНИКА (ФЛИНГ, WALLHOP, BHOP, ANTI-FLING) ===
function FlingPlayer(targetChar)
    local lpChar = LocalPlayer.Character
    if not lpChar or not targetChar:FindFirstChild("HumanoidRootPart") or not lpChar:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = lpChar.HumanoidRootPart
    local targetHrp = targetChar.HumanoidRootPart
    local oldCFrame = hrp.CFrame
    
    local velocityFrame = 0
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not targetHrp or not hrp then connection:Disconnect() return end
        velocityFrame = velocityFrame + 1
        hrp.AssemblyLinearVelocity = Vector3.new(99999, 99999, 99999)
        hrp.AssemblyAngularVelocity = Vector3.new(99999, 99999, 99999)
        hrp.CFrame = targetHrp.CFrame * CFrame.new(math.sin(velocityFrame)*0.1, 0, math.cos(velocityFrame)*0.1)
    end)
    task.wait(0.6)
    connection:Disconnect()
    hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
    hrp.AssemblyAngularVelocity = Vector3.new(0,0,0)
    hrp.CFrame = oldCFrame
end

-- Физика движка
RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("Humanoid") or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    local hum = char.Humanoid

    -- Растяг (Stretched FOV)
    if Camera.FieldOfView ~= Config.StretchedResolution then
        Camera.FieldOfView = Config.StretchedResolution
    end

    -- Fast BHop
    if Config.FastBHop and UserInputService:IsKeyDown(Enum.KeyCode.Space) and hum.MoveDirection.Magnitude > 0 then
        hum.Jump = true
        hrp.CFrame = hrp.CFrame + (hum.MoveDirection * 0.15)
    end

    -- WallHop (Отталкивание от стен при прыжке в MM2)
    if Config.WallHop and hum:GetState() == Enum.HumanoidStateType.Freefall then
        local ray = Ray.new(hrp.Position, hrp.CFrame.LookVector * 2.5)
        local hit = workspace:FindPartOnRayWithIgnoreList(ray, {char})
        if hit and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
            hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 35, hrp.AssemblyLinearVelocity.Z)
        end
    end

    -- Anti-Fling (Удаление коллизии с игроками у которых бешеная скорость)
    if Config.AntiFling then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local otherHrp = p.Character.HumanoidRootPart
                if otherHrp.AssemblyLinearVelocity.Magnitude > 45 or otherHrp.AssemblyAngularVelocity.Magnitude > 45 then
                    for _, part in pairs(p.Character:GetChildren()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end
            end
        end
    end
end)

local function GetRole(p)
    if not p.Backpack or not p.Character then return "Innocent" end
    if p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife") then return "Murderer" end
    if p.Backpack:FindFirstChild("Gun") or p.Character:FindFirstChild("Gun") then return "Sheriff" end
    return "Innocent"
end

local EspFolder = Instance.new("Folder", CoreGui)

RunService.RenderStepped:Connect(function()
    EspFolder:ClearAllChildren()
    
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = Config.WalkSpeed
    end

    -- ESP + ОТОБРАЖЕНИЕ КЛАН-ТЕГОВ ДРУГИХ СОФТЕРОВ
    if Config.EspPlayers then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local c = Color3.fromRGB(255, 255, 255)
                if Config.EspRoles then
                    local r = GetRole(p)
                    c = (r == "Murderer" and Color3.fromRGB(255,0,0)) or (r == "Sheriff" and Color3.fromRGB(0,0,255)) or Color3.fromRGB(0,255,0)
                end
                
                -- Подсветка софтеров MemeSense
                local isMemeUser = p:GetAttribute("MemeSense_User")
                if isMemeUser and Config.ShowClanTags then
                    c = Color3.fromRGB(235, 50, 75) -- Красный фирменный цвет
                    local bg = Instance.new("BillboardGui", EspFolder)
                    bg.Adornee = p.Character:FindFirstChild("Head") or p.Character.HumanoidRootPart
                    bg.Size = UDim2.new(0, 100, 0, 40)
                    bg.StudsOffset = Vector3.new(0, 2.5, 0)
                    bg.AlwaysOnTop = true
                    
                    local tag = Instance.new("TextLabel", bg)
                    tag.Size = UDim2.new(1, 0, 1, 0)
                    tag.BackgroundTransparency = 1
                    tag.Text = "[MemeSense]"
                    tag.TextColor3 = Color3.fromRGB(235, 50, 75)
                    tag.Font = Enum.Font.GothamBold
                    tag.TextSize = 13
                end

                local box = Instance.new("BoxHandleAdornment")
                box.Size = p.Character:GetExtentsSize()
                box.Color3 = c
                box.AlwaysOnTop = true
                box.Transparency = 0.75
                box.Adornee = p.Character
                box.Parent = EspFolder
            end
        end
    end

    local gunDrop = workspace:FindFirstChild("GunDrop") or (workspace:FindFirstChild("Normal") and workspace.Normal:FindFirstChild("GunDrop"))
    if Config.EspGun and gunDrop then
        local box = Instance.new("BoxHandleAdornment")
        box.Size = Vector3.new(2, 2, 2)
        box.Color3 = Color3.fromRGB(255, 215, 0)
        box.AlwaysOnTop = true
        box.Adornee = gunDrop
        box.Parent = EspFolder
    end

    if Config.AutoGrabGun and gunDrop and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = gunDrop.CFrame
    end

    if Config.FlingMurderer then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and GetRole(p) == "Murderer" and p.Character then
                FlingPlayer(p.Character)
            end
        end
    end

    if Config.KillAura and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Knife") then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (LocalPlayer.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                if dist <= Config.AuraRadius and GetRole(p) ~= "Murderer" then
                    LocalPlayer.Character.Knife:Activate()
                    firetouchinterest(LocalPlayer.Character.Knife.Handle, p.Character.HumanoidRootPart, 0)
                    firetouchinterest(LocalPlayer.Character.Knife.Handle, p.Character.HumanoidRootPart, 1)
                end
            end
        end
    end

    if Config.AutoShoot and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Gun") then
        for _, p in pairs(Players:GetPlayers()) do
            if GetRole(p) == "Murderer" and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local mHrp = p.Character.HumanoidRootPart
                local ray = Ray.new(LocalPlayer.Character.HumanoidRootPart.Position, (mHrp.Position - LocalPlayer.Character.HumanoidRootPart.Position).Unit * 300)
                local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character})
                if hit and hit:IsDescendantOf(p.Character) then
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, mHrp.Position)
                    LocalPlayer.Character.Gun:Activate()
                end
            end
        end
    end

    local isPressed = string.find(Config.AimBind, "Button") and UserInputService:IsMouseButtonPressed(Enum.UserInputType[Config.AimBind]) or UserInputService:IsKeyDown(Enum.KeyCode[Config.AimBind])
    if Config.AimEnabled and isPressed then
        local target = nil
        local maxD = Config.AimRadius
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                if Config.AimTargetMode == "Head" or (Config.AimTargetMode == "Gun" and GetRole(p) == "Sheriff") then
                    local pos, onScreen = Camera:WorldToViewportPoint(p.Character.Head.Position)
                    if onScreen then
                        local mDist = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
                        if mDist < maxD then target = p.Character.Head; maxD = mDist end
                    end
                end
            end
        end
        if target then Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position) end
    end
end)
