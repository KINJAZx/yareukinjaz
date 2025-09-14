local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Character references
local function getCharacterSafely()
    return player.Character or player.CharacterAdded:Wait()
end

local character = getCharacterSafely()
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Data
local checkpoints = {
    Vector3.new(-122, 124.531, -52.5),   -- 1
    Vector3.new(-171, 158.426, 500),    -- 2
    Vector3.new(-215.916, 97.6634, 755.176),   -- 3
    Vector3.new(-664, 314.615, 979),   -- 4
    Vector3.new(-892.396, 450.297, 1065.05),   -- 5
    Vector3.new(-1125, 526.5, 1057),   -- 6
    Vector3.new(-1139.46, 524.5, 1307),   -- 7
    Vector3.new(-1169, 514.5, 1843),   -- 8
    Vector3.new(-870.701, 694.193, 1810.75),   -- 9
    Vector3.new(-865.10, 815.32, 1785.16),   -- summit
}

-- Settings
local settings = {
    processingDelay = 1.5,
    flySpeed = 50,
    walkSpeed = 50
}

local autoSummitEnabled = false
local flyEnabled = false
local speedEnabled = false
local minimized = false
local maximized = false
local guiVisible = true

-- Timer variables
local startTime = 0
local runningTime = 0
local timerRunning = false
local summitsCompleted = 0

-- Connections
local summitCoroutine = nil
local godModeConnection = nil
local flyConnection = nil
local timerConnection = nil
local bodyVelocity = nil
local toggleConnection = nil

-- Color palette
local colors = {
    background = Color3.fromRGB(25, 25, 25),
    panel = Color3.fromRGB(35, 35, 35),
    accent = Color3.fromRGB(100, 149, 237),
    text = Color3.fromRGB(255, 255, 255),
    textSecondary = Color3.fromRGB(180, 180, 180),
    toggleActive = Color3.fromRGB(76, 175, 80),
    toggleInactive = Color3.fromRGB(60, 60, 60),
    closeBtn = Color3.fromRGB(255, 95, 86),
    minimizeBtn = Color3.fromRGB(255, 189, 46),
    maximizeBtn = Color3.fromRGB(40, 201, 64),
    success = Color3.fromRGB(76, 175, 80),
    warning = Color3.fromRGB(255, 193, 7)
}

-- Create main GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KinjazHUB"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Main container (smaller without sidebar)
local mainContainer = Instance.new("Frame")
mainContainer.Name = "MainContainer"
mainContainer.Size = UDim2.new(0, 500, 0, 450)
mainContainer.Position = UDim2.new(0.5, -250, 0.5, -225)
mainContainer.BackgroundColor3 = colors.background
mainContainer.BorderSizePixel = 0
mainContainer.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainContainer

-- Title bar
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 50)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = colors.panel
titleBar.BorderSizePixel = 0
titleBar.Parent = mainContainer

local titleBarCorner = Instance.new("UICorner")
titleBarCorner.CornerRadius = UDim.new(0, 12)
titleBarCorner.Parent = titleBar

-- Title text
local titleText = Instance.new("TextLabel")
titleText.Name = "TitleText"
titleText.Size = UDim2.new(0, 300, 1, 0)
titleText.Position = UDim2.new(0, 15, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "KinjazHUB - Gunung Yareu"
titleText.TextColor3 = colors.text
titleText.TextSize = 16
titleText.Font = Enum.Font.GothamBold
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = titleBar

-- Window controls container
local controlsContainer = Instance.new("Frame")
controlsContainer.Name = "ControlsContainer"
controlsContainer.Size = UDim2.new(0, 90, 0, 25)
controlsContainer.Position = UDim2.new(1, -100, 0, 12)
controlsContainer.BackgroundTransparency = 1
controlsContainer.Parent = titleBar

-- Minimize button
local minBtn = Instance.new("TextButton")
minBtn.Name = "MinimizeBtn"
minBtn.Size = UDim2.new(0, 25, 0, 25)
minBtn.Position = UDim2.new(0, 0, 0, 0)
minBtn.BackgroundColor3 = colors.minimizeBtn
minBtn.Text = "−"
minBtn.TextColor3 = Color3.new(0, 0, 0)
minBtn.TextSize = 14
minBtn.Font = Enum.Font.GothamBold
minBtn.BorderSizePixel = 0
minBtn.Parent = controlsContainer

local minBtnCorner = Instance.new("UICorner")
minBtnCorner.CornerRadius = UDim.new(0, 4)
minBtnCorner.Parent = minBtn

-- Maximize button
local maxBtn = Instance.new("TextButton")
maxBtn.Name = "MaximizeBtn"
maxBtn.Size = UDim2.new(0, 25, 0, 25)
maxBtn.Position = UDim2.new(0, 30, 0, 0)
maxBtn.BackgroundColor3 = colors.maximizeBtn
maxBtn.Text = "□"
maxBtn.TextColor3 = Color3.new(0, 0, 0)
maxBtn.TextSize = 12
maxBtn.Font = Enum.Font.GothamBold
maxBtn.BorderSizePixel = 0
maxBtn.Parent = controlsContainer

local maxBtnCorner = Instance.new("UICorner")
maxBtnCorner.CornerRadius = UDim.new(0, 4)
maxBtnCorner.Parent = maxBtn

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Name = "CloseBtn"
closeBtn.Size = UDim2.new(0, 25, 0, 25)
closeBtn.Position = UDim2.new(0, 60, 0, 0)
closeBtn.BackgroundColor3 = colors.closeBtn
closeBtn.Text = "×"
closeBtn.TextColor3 = colors.text
closeBtn.TextSize = 16
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
closeBtn.Parent = controlsContainer

local closeBtnCorner = Instance.new("UICorner")
closeBtnCorner.CornerRadius = UDim.new(0, 4)
closeBtnCorner.Parent = closeBtn

-- Main Panel (full width now)
local mainPanel = Instance.new("ScrollingFrame")
mainPanel.Name = "MainPanel"
mainPanel.Size = UDim2.new(1, -20, 1, -70)
mainPanel.Position = UDim2.new(0, 10, 0, 60)
mainPanel.BackgroundColor3 = colors.panel
mainPanel.BorderSizePixel = 0
mainPanel.ScrollBarThickness = 4
mainPanel.CanvasSize = UDim2.new(0, 0, 0, 800)
mainPanel.Parent = mainContainer

local mainPanelCorner = Instance.new("UICorner")
mainPanelCorner.CornerRadius = UDim.new(0, 8)
mainPanelCorner.Parent = mainPanel

-- Timer display
local timerFrame = Instance.new("Frame")
timerFrame.Size = UDim2.new(1, -20, 0, 60)
timerFrame.Position = UDim2.new(0, 10, 0, 10)
timerFrame.BackgroundColor3 = colors.background
timerFrame.BorderSizePixel = 0
timerFrame.Parent = mainPanel

local timerFrameCorner = Instance.new("UICorner")
timerFrameCorner.CornerRadius = UDim.new(0, 8)
timerFrameCorner.Parent = timerFrame

local timerLabel = Instance.new("TextLabel")
timerLabel.Size = UDim2.new(0.5, 0, 1, 0)
timerLabel.Position = UDim2.new(0, 10, 0, 0)
timerLabel.BackgroundTransparency = 1
timerLabel.Text = "⏱️ Runtime: 00:00:00"
timerLabel.TextColor3 = colors.text
timerLabel.TextSize = 14
timerLabel.Font = Enum.Font.GothamBold
timerLabel.TextXAlignment = Enum.TextXAlignment.Left
timerLabel.Parent = timerFrame

local summitCountLabel = Instance.new("TextLabel")
summitCountLabel.Size = UDim2.new(0.5, 0, 1, 0)
summitCountLabel.Position = UDim2.new(0.5, 0, 0, 0)
summitCountLabel.BackgroundTransparency = 1
summitCountLabel.Text = "🏔️ Summits: 0"
summitCountLabel.TextColor3 = colors.text
summitCountLabel.TextSize = 14
summitCountLabel.Font = Enum.Font.GothamBold
summitCountLabel.TextXAlignment = Enum.TextXAlignment.Right
summitCountLabel.Parent = timerFrame

-- Helper functions for creating controls
local function createToggleSwitch(parent, x, y)
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 50, 0, 25)
    toggle.Position = UDim2.new(0, x, 0, y)
    toggle.BackgroundColor3 = colors.toggleInactive
    toggle.Text = ""
    toggle.BorderSizePixel = 0
    toggle.Parent = parent
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 12)
    toggleCorner.Parent = toggle
    
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 21, 0, 21)
    dot.Position = UDim2.new(0, 2, 0, 2)
    dot.BackgroundColor3 = colors.text
    dot.BorderSizePixel = 0
    dot.Parent = toggle
    
    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(0, 10)
    dotCorner.Parent = dot
    
    return toggle, dot
end

local function createSlider(parent, x, y, width, minVal, maxVal, currentVal)
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(0, width, 0, 20)
    sliderBg.Position = UDim2.new(0, x, 0, y)
    sliderBg.BackgroundColor3 = colors.toggleInactive
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = parent
    
    local sliderBgCorner = Instance.new("UICorner")
    sliderBgCorner.CornerRadius = UDim.new(0, 10)
    sliderBgCorner.Parent = sliderBg
    
    local fill = Instance.new("Frame")
    local fillPercent = (currentVal - minVal) / (maxVal - minVal)
    fill.Size = UDim2.new(fillPercent, 0, 1, 0)
    fill.Position = UDim2.new(0, 0, 0, 0)
    fill.BackgroundColor3 = colors.accent
    fill.BorderSizePixel = 0
    fill.Parent = sliderBg
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 10)
    fillCorner.Parent = fill
    
    return sliderBg, fill
end

-- Auto Summit controls (adjusted width)
local autoSummitFrame = Instance.new("Frame")
autoSummitFrame.Size = UDim2.new(1, -20, 0, 50)
autoSummitFrame.Position = UDim2.new(0, 10, 0, 80)
autoSummitFrame.BackgroundColor3 = colors.background
autoSummitFrame.BorderSizePixel = 0
autoSummitFrame.Parent = mainPanel

local autoFrameCorner = Instance.new("UICorner")
autoFrameCorner.CornerRadius = UDim.new(0, 8)
autoFrameCorner.Parent = autoSummitFrame

local autoLabel = Instance.new("TextLabel")
autoLabel.Size = UDim2.new(0.7, 0, 1, 0)
autoLabel.Position = UDim2.new(0, 10, 0, 0)
autoLabel.BackgroundTransparency = 1
autoLabel.Text = "🏔️ Auto Summit"
autoLabel.TextColor3 = colors.text
autoLabel.TextSize = 14
autoLabel.Font = Enum.Font.GothamBold
autoLabel.TextXAlignment = Enum.TextXAlignment.Left
autoLabel.Parent = autoSummitFrame

local autoToggle, autoDot = createToggleSwitch(autoSummitFrame, 350, 12)

-- Delay controls (adjusted width)
local delayFrame = Instance.new("Frame")
delayFrame.Size = UDim2.new(1, -20, 0, 70)
delayFrame.Position = UDim2.new(0, 10, 0, 140)
delayFrame.BackgroundColor3 = colors.background
delayFrame.BorderSizePixel = 0
delayFrame.Parent = mainPanel

local delayFrameCorner = Instance.new("UICorner")
delayFrameCorner.CornerRadius = UDim.new(0, 8)
delayFrameCorner.Parent = delayFrame

local delayLabel = Instance.new("TextLabel")
delayLabel.Size = UDim2.new(1, -20, 0, 25)
delayLabel.Position = UDim2.new(0, 10, 0, 5)
delayLabel.BackgroundTransparency = 1
delayLabel.Text = "⏱️ Teleport Delay: " .. settings.processingDelay .. "s"
delayLabel.TextColor3 = colors.text
delayLabel.TextSize = 12
delayLabel.Font = Enum.Font.Gotham
delayLabel.TextXAlignment = Enum.TextXAlignment.Left
delayLabel.Parent = delayFrame

local delaySlider, delayFill = createSlider(delayFrame, 10, 35, 400, 0.5, 5, settings.processingDelay)

-- Fly controls (adjusted width)
local flyFrame = Instance.new("Frame")
flyFrame.Size = UDim2.new(1, -20, 0, 70)
flyFrame.Position = UDim2.new(0, 10, 0, 220)
flyFrame.BackgroundColor3 = colors.background
flyFrame.BorderSizePixel = 0
flyFrame.Parent = mainPanel

local flyFrameCorner = Instance.new("UICorner")
flyFrameCorner.CornerRadius = UDim.new(0, 8)
flyFrameCorner.Parent = flyFrame

local flyLabel = Instance.new("TextLabel")
flyLabel.Size = UDim2.new(0.3, 0, 0, 25)
flyLabel.Position = UDim2.new(0, 10, 0, 5)
flyLabel.BackgroundTransparency = 1
flyLabel.Text = "✈️ Fly"
flyLabel.TextColor3 = colors.text
flyLabel.TextSize = 14
flyLabel.Font = Enum.Font.GothamBold
flyLabel.TextXAlignment = Enum.TextXAlignment.Left
flyLabel.Parent = flyFrame

local flyToggle, flyDot = createToggleSwitch(flyFrame, 80, 5)

local flySpeedLabel = Instance.new("TextLabel")
flySpeedLabel.Size = UDim2.new(1, -20, 0, 25)
flySpeedLabel.Position = UDim2.new(0, 10, 0, 35)
flySpeedLabel.BackgroundTransparency = 1
flySpeedLabel.Text = "Speed: " .. settings.flySpeed
flySpeedLabel.TextColor3 = colors.text
flySpeedLabel.TextSize = 12
flySpeedLabel.Font = Enum.Font.Gotham
flySpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
flySpeedLabel.Parent = flyFrame

local flySpeedSlider, flySpeedFill = createSlider(flyFrame, 80, 35, 330, 10, 200, settings.flySpeed)

-- Speed controls (adjusted width)
local speedFrame = Instance.new("Frame")
speedFrame.Size = UDim2.new(1, -20, 0, 70)
speedFrame.Position = UDim2.new(0, 10, 0, 300)
speedFrame.BackgroundColor3 = colors.background
speedFrame.BorderSizePixel = 0
speedFrame.Parent = mainPanel

local speedFrameCorner = Instance.new("UICorner")
speedFrameCorner.CornerRadius = UDim.new(0, 8)
speedFrameCorner.Parent = speedFrame

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0.3, 0, 0, 25)
speedLabel.Position = UDim2.new(0, 10, 0, 5)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "🏃 Speed"
speedLabel.TextColor3 = colors.text
speedLabel.TextSize = 14
speedLabel.Font = Enum.Font.GothamBold
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = speedFrame

local speedToggle, speedDot = createToggleSwitch(speedFrame, 80, 5)

local walkSpeedLabel = Instance.new("TextLabel")
walkSpeedLabel.Size = UDim2.new(1, -20, 0, 25)
walkSpeedLabel.Position = UDim2.new(0, 10, 0, 35)
walkSpeedLabel.BackgroundTransparency = 1
walkSpeedLabel.Text = "Speed: " .. settings.walkSpeed
walkSpeedLabel.TextColor3 = colors.text
walkSpeedLabel.TextSize = 12
walkSpeedLabel.Font = Enum.Font.Gotham
walkSpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
walkSpeedLabel.Parent = speedFrame

local walkSpeedSlider, walkSpeedFill = createSlider(speedFrame, 80, 35, 330, 16, 200, settings.walkSpeed)

-- Functions
local function showNotification(text, color)
    StarterGui:SetCore("SendNotification", {
        Title = "KinjazHUB";
        Text = text;
        Duration = 3;
    })
end

local function updateCharacterReferences()
    character = getCharacterSafely()
    humanoid = character:WaitForChild("Humanoid")
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
end

local function formatTime(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60
    return string.format("%02d:%02d:%02d", hours, minutes, secs)
end

local function updateTimer()
    if timerRunning then
        runningTime = os.time() - startTime
        timerLabel.Text = "⏱️ Runtime: " .. formatTime(runningTime)
    end
end

local function enableGodMode()
    if godModeConnection then godModeConnection:Disconnect() end
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
    humanoid.Health = humanoid.MaxHealth
    godModeConnection = RunService.Heartbeat:Connect(function()
        if humanoid and humanoid.Health < humanoid.MaxHealth then
            humanoid.Health = humanoid.MaxHealth
        end
    end)
end

local function disableGodMode()
    if godModeConnection then
        godModeConnection:Disconnect()
        godModeConnection = nil
    end
    if humanoid then
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
    end
end

local function teleportTo(position)
    if humanoidRootPart then
        humanoidRootPart.CFrame = CFrame.new(position + Vector3.new(0, 5, 0))
    end
end

local function updateToggleVisual(toggle, dot, enabled)
    local targetColor = enabled and colors.toggleActive or colors.toggleInactive
    local targetPosition = enabled and UDim2.new(0, 27, 0, 2) or UDim2.new(0, 2, 0, 2)
    
    local colorTween = TweenService:Create(toggle, TweenInfo.new(0.3), {BackgroundColor3 = targetColor})
    local positionTween = TweenService:Create(dot, TweenInfo.new(0.3), {Position = targetPosition})
    
    colorTween:Play()
    positionTween:Play()
end

local function enableFly()
    if bodyVelocity then bodyVelocity:Destroy() end
    
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.Parent = humanoidRootPart
    
    flyConnection = RunService.Heartbeat:Connect(function()
        if not flyEnabled then return end
        
        local moveVector = Vector3.new(0, 0, 0)
        local camera = workspace.CurrentCamera
        local forward = camera.CFrame.LookVector
        local right = camera.CFrame.RightVector
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveVector = moveVector + forward
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveVector = moveVector - forward
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveVector = moveVector - right
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveVector = moveVector + right
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveVector = moveVector + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            moveVector = moveVector - Vector3.new(0, 1, 0)
        end
        
        bodyVelocity.Velocity = moveVector * settings.flySpeed
    end)
end

local function disableFly()
    if bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
end

local function setWalkSpeed(speed)
    if humanoid then
        humanoid.WalkSpeed = speed
    end
end

local function startAutoSummit()
    if summitCoroutine then
        coroutine.close(summitCoroutine)
    end
    
    enableGodMode()
    startTime = os.time()
    timerRunning = true
    runningTime = 0
    
    timerConnection = RunService.Heartbeat:Connect(updateTimer)
    
    summitCoroutine = coroutine.create(function()
        while autoSummitEnabled do
            for i, checkpoint in ipairs(checkpoints) do
                if not autoSummitEnabled then break end
                
                teleportTo(checkpoint)
                
                wait(settings.processingDelay)
            end
            
            if autoSummitEnabled then
                summitsCompleted = summitsCompleted + 1
                summitCountLabel.Text = "🏔️ Summits: " .. summitsCompleted
                showNotification("Summit completed! Total: " .. summitsCompleted, colors.success)
                wait(2)
            end
        end
        
        timerRunning = false
        if timerConnection then
            timerConnection:Disconnect()
            timerConnection = nil
        end
        disableGodMode()
    end)
    
    coroutine.resume(summitCoroutine)
end

local function stopAutoSummit()
    autoSummitEnabled = false
    timerRunning = false
    
    if summitCoroutine then
        coroutine.close(summitCoroutine)
        summitCoroutine = nil
    end
    if timerConnection then
        timerConnection:Disconnect()
        timerConnection = nil
    end
    
    disableGodMode()
end

-- Toggle GUI visibility function
local function toggleGUI()
    guiVisible = not guiVisible
    mainContainer.Visible = guiVisible
    
    if guiVisible then
        showNotification("GUI shown! Press Shift to hide", colors.success)
    else
        showNotification("GUI hidden! Press Shift to show", colors.warning)
    end
end

-- Slider logic
local function createSliderLogic(slider, fill, label, minVal, maxVal, currentVal, callback)
    local dragging = false
    
    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local relativeX = math.clamp((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
            local newValue = minVal + (maxVal - minVal) * relativeX
            
            fill.Size = UDim2.new(relativeX, 0, 1, 0)
            callback(newValue)
        end
    end)
end

-- Setup sliders
createSliderLogic(delaySlider, delayFill, delayLabel, 0.5, 5, settings.processingDelay, function(value)
    settings.processingDelay = value
    delayLabel.Text = "⏱️ Teleport Delay: " .. string.format("%.1f", value) .. "s"
end)

createSliderLogic(flySpeedSlider, flySpeedFill, flySpeedLabel, 10, 200, settings.flySpeed, function(value)
    settings.flySpeed = value
    flySpeedLabel.Text = "Speed: " .. math.floor(value)
end)

createSliderLogic(walkSpeedSlider, walkSpeedFill, walkSpeedLabel, 16, 200, settings.walkSpeed, function(value)
    settings.walkSpeed = value
    walkSpeedLabel.Text = "Speed: " .. math.floor(value)
    if speedEnabled then
        setWalkSpeed(value)
    end
end)

-- Event connections
autoToggle.MouseButton1Click:Connect(function()
    autoSummitEnabled = not autoSummitEnabled
    updateToggleVisual(autoToggle, autoDot, autoSummitEnabled)
    
    if autoSummitEnabled then
        startAutoSummit()
        showNotification("Auto Summit started!", colors.success)
    else
        stopAutoSummit()
        showNotification("Auto Summit stopped!", colors.warning)
    end
end)

flyToggle.MouseButton1Click:Connect(function()
    flyEnabled = not flyEnabled
    updateToggleVisual(flyToggle, flyDot, flyEnabled)
    
    if flyEnabled then
        enableFly()
        showNotification("Fly enabled! Use WASD + Space/Shift", colors.success)
    else
        disableFly()
        showNotification("Fly disabled!", colors.warning)
    end
end)

speedToggle.MouseButton1Click:Connect(function()
    speedEnabled = not speedEnabled
    updateToggleVisual(speedToggle, speedDot, speedEnabled)
    
    if speedEnabled then
        setWalkSpeed(settings.walkSpeed)
        showNotification("Speed hack enabled!", colors.success)
    else
        setWalkSpeed(16)
        showNotification("Speed hack disabled!", colors.warning)
    end
end)

-- Window control functions
closeBtn.MouseButton1Click:Connect(function()
    guiVisible = false
    mainContainer.Visible = false
    showNotification("GUI closed! Press Shift to show again", colors.warning)
end)

minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    
    if minimized then
        mainPanel.Visible = false
        mainContainer.Size = UDim2.new(0, 350, 0, 50)
        titleText.Text = "KinjazHUB - Minimized"
    else
        mainPanel.Visible = true
        if maximized then
            mainContainer.Size = UDim2.new(0, 600, 0, 550)
        else
            mainContainer.Size = UDim2.new(0, 500, 0, 450)
        end
        titleText.Text = "KinjazHUB - Auto Summit"
    end
end)

maxBtn.MouseButton1Click:Connect(function()
    maximized = not maximized
    
    if not minimized then
        if maximized then
            mainContainer.Size = UDim2.new(0, 600, 0, 550)
            mainContainer.Position = UDim2.new(0.5, -300, 0.5, -275)
            maxBtn.Text = "◪"
        else
            mainContainer.Size = UDim2.new(0, 500, 0, 450)
            mainContainer.Position = UDim2.new(0.5, -250, 0.5, -225)
            maxBtn.Text = "□"
        end
    end
end)

-- Dragging functionality
local dragging = false
local dragStart = nil
local startPos = nil

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local mousePos = UserInputService:GetMouseLocation()
        local controlsPos = controlsContainer.AbsolutePosition
        local controlsSize = controlsContainer.AbsoluteSize
        
        if mousePos.X < controlsPos.X or mousePos.X > controlsPos.X + controlsSize.X then
            dragging = true
            dragStart = input.Position
            startPos = mainContainer.Position
        end
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
        local delta = input.Position - dragStart
        mainContainer.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Shift key toggle functionality
toggleConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.LeftShift then
        toggleGUI()
    end
end)

-- Character respawn handling
player.CharacterAdded:Connect(function()
    wait(2)
    updateCharacterReferences()
    if autoSummitEnabled then
        enableGodMode()
    end
    if flyEnabled then
        enableFly()
    end
    if speedEnabled then
        setWalkSpeed(settings.walkSpeed)
    end
end)

-- Initialize
updateToggleVisual(autoToggle, autoDot, false)
updateToggleVisual(flyToggle, flyDot, false)
updateToggleVisual(speedToggle, speedDot, false)

showNotification("KinjazHUB loaded! Press Shift to toggle GUI", colors.success)

wait(3)
if guiVisible then
    showNotification("All features ready to use!", colors.warning)
end

print("KinjazHUB Loaded Successfully!")
