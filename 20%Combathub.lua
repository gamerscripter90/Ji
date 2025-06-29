-- PART 1: Utilities and Popups

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

-- RAINBOW BORDER UTILITY
local function createRainbowBorder(parent, thickness)
    thickness = thickness or 4
    local border = Instance.new("Frame")
    border.Size = UDim2.new(1, thickness*2, 1, thickness*2)
    border.Position = UDim2.new(0, -thickness, 0, -thickness)
    border.BackgroundTransparency = 1
    border.BorderSizePixel = 0
    border.ZIndex = (parent.ZIndex or 1) + 1
    border.Parent = parent
    local uicorner = Instance.new("UICorner", border)
    uicorner.CornerRadius = UDim.new(0, 12)
    local uiStroke = Instance.new("UIStroke", border)
    uiStroke.Thickness = thickness
    uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    local t = 0
    RunService.RenderStepped:Connect(function()
        t += 0.0125
        uiStroke.Color = Color3.fromHSV((t)%1,1,1)
    end)
    return border
end

-- DRAGGABLE
local function makeDraggable(frame)
    local dragging, dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then update(input) end
    end)
end

-- NOTIFY FUNCTION
local function notify(text)
    local gui = Instance.new("ScreenGui")
    gui.Name = "NotifyGui"
    gui.Parent = player:FindFirstChild("PlayerGui") or player.PlayerGui
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 300, 0, 40)
    label.Position = UDim2.new(1, -310, 0, 10)
    label.AnchorPoint = Vector2.new(1, 0)
    label.BackgroundColor3 = Color3.new(0, 0, 0)
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 18
    label.Text = text
    label.Parent = gui
    task.delay(2.5, function() gui:Destroy() end)
end

-- === POPUPS ===

-- Device popup logic
local function showDevicePopup(deviceCB)
    local gui = Instance.new("ScreenGui")
    gui.Name = "DevicePopup"
    gui.Parent = player:FindFirstChild("PlayerGui") or player.PlayerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 350, 0, 180)
    frame.Position = UDim2.new(0.5, -175, 0.5, -90)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    frame.Parent = gui
    frame.AnchorPoint = Vector2.new(0.5,0.5)
    createRainbowBorder(frame, 4)

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 10)
    title.Text = "Which device are you using?"
    title.TextColor3 = Color3.new(1,1,1)
    title.TextSize = 20
    title.Font = Enum.Font.SourceSansBold
    title.BackgroundTransparency = 1

    local mobileBtn = Instance.new("TextButton", frame)
    mobileBtn.Size = UDim2.new(0.4, -10, 0, 40)
    mobileBtn.Position = UDim2.new(0.1, 0, 1, -55)
    mobileBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    mobileBtn.Text = "📱 Mobile"
    mobileBtn.TextColor3 = Color3.new(1,1,1)
    mobileBtn.TextSize = 18
    mobileBtn.Font = Enum.Font.SourceSansBold

    local pcBtn = Instance.new("TextButton", frame)
    pcBtn.Size = UDim2.new(0.4, -10, 0, 40)
    pcBtn.Position = UDim2.new(0.5, 10, 1, -55)
    pcBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 170)
    pcBtn.Text = "💻 PC"
    pcBtn.TextColor3 = Color3.new(1,1,1)
    pcBtn.TextSize = 18
    pcBtn.Font = Enum.Font.SourceSansBold

    local okBtn = Instance.new("TextButton", frame)
    okBtn.Size = UDim2.new(0.8, 0, 0, 38)
    okBtn.Position = UDim2.new(0.1, 0, 1, -10)
    okBtn.BackgroundColor3 = Color3.fromRGB(50, 170, 50)
    okBtn.Text = "OK"
    okBtn.TextColor3 = Color3.new(1, 1, 1)
    okBtn.Font = Enum.Font.SourceSansBold
    okBtn.TextSize = 20
    okBtn.AutoButtonColor = false
    okBtn.Active = false
    okBtn.TextTransparency = 0.5

    local selectedDevice = nil
    local function selectDevice(device)
        selectedDevice = device
        mobileBtn.BackgroundColor3 = device == "Mobile" and Color3.fromRGB(0,170,0) or Color3.fromRGB(0, 170, 255)
        pcBtn.BackgroundColor3 = device == "PC" and Color3.fromRGB(0,170,0) or Color3.fromRGB(0, 255, 170)
        okBtn.Active = true
        okBtn.TextTransparency = 0
    end

    mobileBtn.MouseButton1Click:Connect(function() selectDevice("Mobile") end)
    pcBtn.MouseButton1Click:Connect(function() selectDevice("PC") end)

    okBtn.MouseButton1Click:Connect(function()
        if not selectedDevice then return end
        gui:Destroy()
        if deviceCB then deviceCB(selectedDevice) end
    end)
end

-- Subscription popup logic
local function showSubscribePopup(deviceCB)
    local gui = Instance.new("ScreenGui")
    gui.Name = "SubscribePopup"
    gui.Parent = player:FindFirstChild("PlayerGui") or player.PlayerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 350, 0, 180)
    frame.Position = UDim2.new(0.5, -175, 0.5, -90)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.Parent = gui
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    createRainbowBorder(frame, 4)

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 10)
    title.Text = "Are you subscribed?"
    title.TextColor3 = Color3.new(1,1,1)
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 24
    title.BackgroundTransparency = 1

    local desc = Instance.new("TextLabel", frame)
    desc.Size = UDim2.new(1, -20, 0, 30)
    desc.Position = UDim2.new(0, 10, 0, 60)
    desc.Text = "You must be subscribed to use this script!"
    desc.TextColor3 = Color3.new(1,1,1)
    desc.Font = Enum.Font.SourceSans
    desc.TextSize = 18
    desc.BackgroundTransparency = 1

    local yesBtn = Instance.new("TextButton", frame)
    yesBtn.Size = UDim2.new(0.4, -10, 0, 40)
    yesBtn.Position = UDim2.new(0.1, 0, 1, -55)
    yesBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    yesBtn.Text = "✅ Yes"
    yesBtn.TextColor3 = Color3.new(1, 1, 1)
    yesBtn.Font = Enum.Font.SourceSansBold
    yesBtn.TextSize = 20

    local noBtn = Instance.new("TextButton", frame)
    noBtn.Size = UDim2.new(0.4, -10, 0, 40)
    noBtn.Position = UDim2.new(0.5, 10, 1, -55)
    noBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
    noBtn.Text = "❌ No"
    noBtn.TextColor3 = Color3.new(1, 1, 1)
    noBtn.Font = Enum.Font.SourceSansBold
    noBtn.TextSize = 20

    yesBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
        showDevicePopup(deviceCB)
    end)
    noBtn.MouseButton1Click:Connect(function()
        player:Kick("You must subscribe to use this script!")
    end)
end

-- [END OF PART 1]

-- PART 2: Main GUI, Tabs, and Feature Logic

-- === MAIN GUI SETUP (hidden at start, shown via popup flow) ===
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PlatformUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local platformPanel = Instance.new("Frame")
platformPanel.Size = UDim2.new(0, 620, 0, 460)
platformPanel.Position = UDim2.new(0.3, 0, 0.2, 0)
platformPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
platformPanel.BorderSizePixel = 0
platformPanel.Active = true
platformPanel.Draggable = true
platformPanel.Visible = false
platformPanel.Parent = screenGui
makeDraggable(platformPanel)
createRainbowBorder(platformPanel, 5)

local uiToggle = Instance.new("TextButton")
uiToggle.Size = UDim2.new(0, 120, 0, 35)
uiToggle.Position = UDim2.new(0, 10, 1, -45)
uiToggle.BackgroundColor3 3)
uiToggle.Visible = false
local uiVisible = false

-- === TABS SETUP ===
local tabs = {"Update Logs", "Main", "Misc", "Player", "Tech", "Combo", "Other"}
local tabButtons, tabContents = {}, {}
local tabBar = Instance.new("Frame", platformPanel)
tabBar.Size = UDim2.new(0, 100, 1, 0)
tabBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)

for i, name in ipairs(tabs) do
    local btn = Instance.new("TextButton", tabBar)
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.Position = UDim2.new(0, 0, 0, (i - 1) * 40)
    btn.BackgroundColor3 = Color3.new(0, 0, 0)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 18
    btn.Text = name
    tabButtons[name] = btn

    local content = Instance.new("Frame", platformPanel)
    content.Size = UDim2.new(1, -1, 0)
    content.Position = UDim2.new(0, 100, 0, 0)
    content.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    content.Visible = false
    tabContents[name] = content
end

tabContents["Update Logs"].Visible = true
tabButtons["Update Logs"].BackgroundColor3 = Color3.fromRGB(50, 50, 50)

for name, btn in pairs(tabButtons) do
    btn.MouseButton1Click:Connect(function()
        for n, content in pairs(tabContents) do
            if n == name then
                content.Visible = true
                content.BackgroundTransparency = 1
                TweenService:Create(content, TweenInfo.new(0.35, Enum.EasingStyle.Sine), {
                    BackgroundTransparency = 0
                }):Play()
                tabButtons[n].BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            else
                TweenService:Create(content, TweenInfo.new(0.35, Enum.EasingStyle.Sine), {
                    BackgroundTransparency = 1
                }):Play()
                delay(0.35, function() content.Visible = false end)
                tabButtons[n].BackgroundColor3 = Color3.new(0, 0, 0)
            end
        end
    end)
end

-- ==== UPDATE LOGS TAB ====
local updateText = [[
📝 **Update Logs: Q2 2025**

• [NEW] Professional multi-tabbed user interface with draggable support and animated rainbow borders.
• [NEW] Device detection: Optimized for Mobile (toggle button) and PC (press B to toggle).
• [IMPROVED] No Stun now uses for smooth automation.
• [SECURITY] Improved anti-ban, anti-report, and moderator detection.
• [STABILITY] Optimized aimlock, dash, and combo loaders for seamless integration.
• [QUALITY] Refined transitions, popup animations, and update logs for a more professional look.
• [UX] Popups now explicit device selection and guide the user at every step.
• [FIXED] All popups and UI are now perfectly centered and fully responsive.

Thank you for using our script! Enjoy the latest features and improvements!
]]
local updateFrame = tabContents["Update Logs"]
local logLabel = Instance.new("TextLabel", updateFrame)
logLabel.Size = UDim2.new(1, -20, 1, -20)
logLabel.Position = UDim2.new(0, 10, 0, 10)
logLabel.Text = updateText
logLabel.BackgroundTransparency = 1
logLabel.TextWrapped = true
logLabel.TextColor3 = Color3.new(1, 1, 1)
logLabel.Font = Enum.Font.SourceSansBold
logLabel.TextSize = 18
logLabel.TextXAlignment = Enum.TextXAlignment.Left
logLabel.TextYAlignment = Enum.TextYAlignment.Top
logLabel.RichText = true

-- ==== MAIN TAB ====
local mainTab = tabContents["Main"]

local noStun = false
local desiredSpeed = 26
local defaultSpeed = 16
local speedConn, speedConn2

local noStunToggle = Instance.new("TextButton", mainTab)
noStunToggle.Size = UDim2.new(0, 40, 0, 40)
noStunToggle.Position = UDim2.new(0, 20, 0, 20)
noStunToggle.BackgroundColor3 = Color3.new(0, 0, 0)
noStunToggle.Text = ""
createRainbowBorder(no", mainTab)
noStunLabel.Size = UDim2.new(0, 120, 0, 40)
noStunLabel.Position = UDim2.new(0, 70, 0, 20)
noStunLabel.BackgroundTransparency = 1
noStunLabel.TextColor3 =.Font.SourceSansBold
noStunLabel.TextSize = 20
noStunLabel.TextXAlignment = Enum.TextXAlignment.Left
noStunLabel.Text = "No Stun (OP)"

local function applySpeed()
    local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if hum and hum.WalkSpeed ~= desiredSpeed then
        hum.WalkSpeed = desiredSpeed
    end
end
local function resetSpeed()
    local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = defaultSpeed
    end
end
noStunToggle.MouseButton1Click:Connect(function()
    noStun = not noStun
    noStunToggle.BackgroundColor3 = noStun and Color3.fromRGB(0, 120, 255) or Color3.new(0, 0, 0)
    if noStun then
        if speedConn then speedConn:Disconnect() end
        speedConn = RunService.RenderStepped:Connect(applySpeed)
        if not speedConn2 then
            speedConn2 = RunService.Heartbeat:Connect(applySpeed)
        end
        applySpeed()
        notify("No Stun ON")
    else
        if speedConn then speedConn:Disconnect() speedConn = nil end
        if speedConn2 then speedConn2:Disconnect() speedConn2 = nil end
        resetSpeed()
        notify("No Stun OFF")
    end
end)
player.CharacterAdded:Connect(function()
    task.wait(0.1)
    if noStun then applySpeed() else resetSpeed() end
end)

local speedLabel = Instance.new("TextLabel", mainTab)
speedLabel.Size = UDim2.new(0, 160, 0, 30)
speedLabel.Position = UDim2.new(0, 70, 0, 70)
speedLabel.BackgroundTransparency = 1
speedLabel.TextColor3 = Color3.new(1, 1, 1)
speedLabel.Font = Enum.Font.SourceSans
speedLabel.TextSize = 18
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Text = "Speed: "..desiredSpeed

local minusSpeed = Instance.new("TextButton", mainTab)
minusSpeed.Size = UDim2.new(0, 30, 0, 30)
minusSpeed.Position = UDim2.new(0, 10, 0, 70)
minusSpeed.BackgroundColor3 = Color3.new(0, 0, 0)
minusSpeed.Text = "-"
minusSpeed.TextColor3 = Color3.new(1, 1, 1)
minusSpeed.Font = Enum.Font.SourceSansBold

local plusSpeed = Instance.new("TextButton", mainTab)
plusSpeed.Size = UDim2.new(0, 30, 0, 30)
plusSpeed.Position = UDim2.new(0, 200, 0, 70)
plusSpeed.BackgroundColor3 = Color3.new(0, 0, 0)
plusSpeed.Text = "+"
plusSpeed.TextColor3 = Color3.new(1, 1, 1)
plusSpeed.Font = Enum.Font.SourceSansBold

minusSpeed.MouseButton1Click:Connect(function()
    desiredSpeed = math.max(20, desiredSpeed - 2)
    speedLabel.Text = "Speed: "..desiredSpeed
    if noStun then applySpeed() end
end)
plusSpeed.MouseButton1Click:Connect(function()
    desired.min(100, desiredSpeed + 2)
    speedLabel.Text = "Speed: "..desiredSpeed
    if noStun then applySpeed() end
end)

local aimBtn = Instance.new("TextButton", mainTab)
aimBtn.Size = UDim2.new(0, 220, 0,  Aimlock"
aimBtn.TextColor3 = Color3.new(1, 1, 1)
aimBtn.Font = Enum.Font.SourceSansBold
aimBtn.TextSize = 20
aimBtn.MouseButton1Click:Connect(function()
    local success = pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Cyborg883/TSB/main/CombatGui"))()
    end)
    notify(success and "Aimlock Loaded!" or "Aimlock Failed")
end)

-- ==== MISC TAB ====
local miscTab = tabContents["Misc"]
local instantTwistedBtn = Instance.new("TextButton", miscTab)
instantTwistedBtn.Size = UDim2.new(0, 300, 0, 50)
instantTwistedBtn.Position = UDim2.new(0, 20, 0, 20)
instantTwistedBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
instantTwistedBtn.TextColor3 = Color3.new(1, 1, 1)
instantTwistedBtn.Font = Enum.Font.SourceSansBold
instantTwistedBtn.TextSize = 20
instantTwistedBtn.Text = "Instant Twisted"
instantTwistedBtn.MouseButton1Click:Connect(function()
    local success = pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Kietba/Kietba/refs/heads/main/Auto%20Instant%20Twisted"))()
    end)
    notify(success and "Instant Twisted Loaded!" or "Failed to load Instant Twisted")
end)

-- ==== PLAYER TAB ====
local playerTab = tabContents.Player
local playersList = {}
local currentIndex = 0
local selectedPlayer = nil

local selectBtn = Instance.new("TextButton", playerTab)
selectBtn.Size = UDim2.new(0,220,0,40)
selectBtn.Position = UDim2.new(0,20,0,20)
selectBtn.BackgroundColor3 = Color3.new(0,0,0)
selectBtn.TextColor3 = Color3.new(1,1,1)
selectBtn.Font = Enum.Font.SourceSansBold
selectBtn.TextSize = 20
selectBtn.Text = "Select Player"

selectBtn.MouseButton1Click:Connect(function()
    playersList = Players:GetPlayers()
    currentIndex = (currentIndex % #playersList) + 1
    if playersList[currentIndex] == player then
        currentIndex = (currentIndex % #playersList) + 1
    end
    selectedPlayer = playersList[currentIndex]
    selectBtn.Text = "Target: "..selectedPlayer.Name
    notify("Selected "..selectedPlayer.Name)
end)

-- ==== DEVICE/UI TOGGLE LOGIC ====
local function deviceCallback(deviceType)
    if deviceType == "Mobile" then
        uiToggle.Visible = true
        platformPanel.Visible = false
        uiVisible = false
        uiToggle.MouseButton1Click:Connect(function()
            uiVisible = not uiVisible
            if uiVisible then
                platformPanel.Visible = true
                platformPanel.BackgroundTransparency = 1
                TweenService:Create(platformPanel, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()
            else
                local hideTween = TweenService:Create(platformPanel, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {BackgroundTransparency = 1})
                hideTween:Play()
                hideTween.Completed:Connect(function()
                    if not uiVisible then
                        platformPanel.Visible = false
                    end
                end)
            end
        end)
    else
        uiToggle.Visible = false
        platformPanel.Visible = false
        uiVisible = false
        if _G.BToggleConn then _G.BToggleConn:Disconnect() end
        _G.BToggleConn = UserInputService.InputBegan:Connect(function(input, processed)
            if not processed and input.KeyCode == Enum.KeyCode.B then
                uiVisible = not uiVisible
                if uiVisible then
                    platformPanel.Visible = true
                    platformPanel.BackgroundTransparency = 1
                    TweenService:Create(platformPanel, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()
                else
                    local hideTween = TweenService:Create(platformPanel, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {BackgroundTransparency = 1})
                    hideTween:Play()
                    hideTween.Completed:Connect(function()
                        if not uiVisible then
                            platformPanel.Visible = false
                        end
                    end)
                end
            end
        end)
    end
end

-- ==== KICK OFF POPUP FLOW ====
showSubscribePopup(deviceCallback)

-- END OF PART 2

-- === MAIN TAB ===
local mainTab = tabContents["Main"]

-- No Stun Toggle
local noStun = false
local desiredSpeed = 26
local defaultSpeed = 16
local speedConn, speedConn2

local noStunToggle = Instance.new("TextButton", mainTab)
noStunToggle.Size = UDim2.new(0, 40, 0, 40)
noStunToggle.Position = UDim2.new(0, 20, 0, 20)
noStunToggle.BackgroundColor3 = Color3.new(0, 0, 0)
noStunToggle.Text = ""
createRainbowBorder(noStunToggle, 2)

local noStunLabel = Instance.new("TextLabel", mainTab)
noStunLabel.Size = UDim2.new(0, 120, 0, 40)
noStunLabel.Position = UDim2.new(0, 70, 0, 20)
noStunLabel.BackgroundTransparency = 1
noStunLabel.TextColor3 = Color3.new(1, 1, 1)
noStunLabel.Font = Enum.Font.SourceSansBold
noStunLabel.TextSize.TextXAlignment = Enum.TextXAlignment.Left
noStunLabel.Text = "No Stun (OP)"

local function applySpeed()
    local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if hum and hum.WalkSpeed ~= desiredSpeed then
        hum.WalkSpeed = hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = defaultSpeed
    end
end
noStunToggle.MouseButton1Click:Connect(function()
    noStun = not noStun
    noStunToggle.BackgroundColor3 = noStun and Color3.fromRGB(0, 120, 255) or Color3.new(0, 0, 0)
    if noStun then
        if speedConn then speedConn:Disconnect() end
        speedConn = RunService.RenderStepped:Connect(applySpeed)
        speedConn2:Disconnect() speedConn2 = nil end
        resetSpeed()
        notify("No Stun OFF")
    end
end)
player.CharacterAdded:Connect(function()
    task.wait(0.1)
    if noStun then applySpeed() else resetSpeed() end
end)

-- Speed Controls
.new0, 160, 0, 30)
speedLabel.Position = UDim2.new(0, 70, 0, 70)
speedLabel.BackgroundTransparency = 1
speedLabel.TextColor3 = Color3.new(1, 1, 1)
speedLabel.Font = Enum.Font.SourceSans
speedLabel.TextSize = 18
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Text = "Speed: "..desiredSpeed

local minusSpeed = Instance.new("TextButton", mainTab)
minusSpeed.Size = UDim2.new(0, 30, 0, 30)
minusSpeed.Position = UDim2.new(0, 10, 0, 70)
minusSpeed.BackgroundColor3 = Color3.new(0, 0, 0)
minusSpeed.Text = "-"
minusSpeed.TextColor3 = Color3.new(1, 1, 1)
minusSpeed.Font = Enum.Font.SourceSansBold

local plusSpeed = Instance.new("TextButton", mainTab)
plusSpeed.Size = UDim2.new(0, 30, 0, 30)
plusSpeed.Position = UDim2.new(0, 200, 0, 70)
plusSpeed.BackgroundColorColor3 = Color3.new(1, 1, 1)
plusSpeed.Font = Enum.Font.SourceSansBold

minusSpeed.MouseButton1Click:Connect(function()
    desiredSpeed = math.max(20, desiredSpeed - 2)
    speedLabel.Text = "Speed: "..desiredSpeed
    if noStun then applySpeed() end
end)
plusSpeed.MouseButton1Click:Connect(function()
    desiredSpeed = math.min(100, desiredSpeed + 2)
    speedLabel.Text = "Speed: "..desiredSpeed
    if noStun then applySpeed() end
end)

-- Aimlock Loader
local aimBtn = Instance.new("TextButton", mainTab)
aimBtn.Size = UDim2.new(0, 220, 0, 40)
aimBtn.Position = UDim2.new(0, 20, 0, 120)
aimBtn.BackgroundColor3 = Color3.new(0, 0, 0)
aimBtn.Text = "Load Aimlock"
aimBtn.TextColor3 = Color3.new(1, 1, 1)
aimBtn.Font = Enum.Font.SourceSansBold
aimBtn.TextSize = 20
aimBtn.MouseButton1Click:Connect(function()
    local success = pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/CybCombatGui"))()
    end)
    notify(success and "Aimlock Loaded!" or "Aimlock Failed")
end)

local comboTab = tabContents.Combo

local comboLoadBtn = Instance.new("TextButton", comboTab)
comboLoadBtn.Size = UDim2.new(0, 300, 0, 50)
comboLoadBtn.Position = UDim2.new(0, 20, 0, 20)
comboLoadBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
comboLoadBtn.TextColor3 = Color3.new(1, 1, 1)
comboLoadBtn.Font = Enum.Font.SourceSansBold
comboLoadBtn.TextSize = 22
comboLoadBtn.Text = "Garou Combo OP (Recommended)"
comboLoadBtn.MouseButton1Click:Connect(function()
    local success = pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Mark22028/Auto-Kyoto-Combo/refs/heads/main/Skibidi%20Sigma%20Combo.txt"))()
    end)
    notify(success combo")
end)

local techTab = tabContents.Tech

-- Utility: Dash function (teleport with offset)
local function dashTo(offset)
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local dest = hrp.Position + offset
    hrp.CFrame = CFrame.new(dest, dest + hrp.CFrame.LookVector)
end

-- Side Dash button
local sideDashBtn = Instance.new("TextButton", techTab)
sideDashBtn.Size = UDim2.new(0, 300, 0, 50)
sideDashBtn.Position = UDim2.new(0, 20, 0, 20)
sideDashBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
sideDashBtn.TextColor3 = Color3.new(1, 1, 1)
sideDashBtn.Font = Enum.Font.SourceSansBold
sideDashBtn.TextSize = 22
sideDashBtn.Text = "Side Dash"
sideDashBtn.MouseButton1Click:Connect(function()
    dashTo(Vector3.new(15, 0, 0))
end)

-- Forward Dash button
local forwardDashBtn = Instance.new("TextButton", techTab)
forwardDashBtn.Size = UDim2.new(0, 300, 0, 50)
forwardDashBtn.Position = UDim2.new(0, 20)
forwardDashBtn.TextColor3 = Color3.new(1, 1, 1)
forwardDashBtn.Font = Enum.Font.SourceSansBold
forwardDashBtn.TextSize = 22
forwardDashBtn.Text = "Forward Dash"
forwardDashBtn.MouseButton1Click:Connect(function()
    dashTo(Vector3.new(0, 0, -20))
end)

-- Lethal Oreo Dash (Garou Only) button (loads external script)
local oreoDashBtn = Instance.new("TextButton", techTab)
oreoDashBtn.Size = UDim2.new(0, 300, 0, 50)
oreoDashBtn.Position = UDim2.new(0, 20, 0, 160)
oreoDashBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
oreoDashBtn.TextColor3 = Color3.new(1, 1, 1)
oreoDashBtn.Font = Enum.Font.SourceSansBold
oreoDashBtn.TextSize = 20
oreoDashBtn.Text = "Lethal Oreo Dash (Garou Only)"
oreoDashBtn.MouseButton1Click:Connect(function()
    local success = pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Cyborg883/InstantLethal/refs/heads/main/Protected_5983112998592296.lua"))()
    end)
    notify(success and "Oreo Dash Loaded!" or "Oreo Dash Failed")
end)