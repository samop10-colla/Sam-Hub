--[[
    Sam's UI Library — Love Edition
    A UI framework for Roblox
    Reusable component library, not a standalone script.
    Compatible with most executors.
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ══════════════════════════════════════════════════════════════
-- THEME CONFIGURATION
-- ══════════════════════════════════════════════════════════════

local Theme = {
    Background = Color3.fromRGB(25, 15, 20),
    WindowBackground = Color3.fromRGB(30, 18, 24),
    TitleBar = Color3.fromRGB(40, 22, 32),
    TabBar = Color3.fromRGB(28, 16, 22),
    TabActive = Color3.fromRGB(255, 107, 138),
    TabInactive = Color3.fromRGB(120, 70, 90),
    TabHover = Color3.fromRGB(180, 90, 120),
    ElementBackground = Color3.fromRGB(45, 28, 38),
    ElementBackgroundHover = Color3.fromRGB(55, 35, 45),
    ElementBorder = Color3.fromRGB(70, 40, 55),
    Primary = Color3.fromRGB(255, 107, 138),
    PrimaryDark = Color3.fromRGB(232, 71, 124),
    Accent = Color3.fromRGB(201, 160, 220),
    Gold = Color3.fromRGB(255, 215, 0),
    TextPrimary = Color3.fromRGB(255, 240, 245),
    TextSecondary = Color3.fromRGB(180, 140, 160),
    TextDimmed = Color3.fromRGB(120, 90, 105),
    ToggleOn = Color3.fromRGB(255, 107, 138),
    ToggleOff = Color3.fromRGB(70, 45, 55),
    SliderFill = Color3.fromRGB(255, 107, 138),
    SliderTrack = Color3.fromRGB(60, 38, 48),
    SliderHandle = Color3.fromRGB(255, 220, 230),
    DropdownBackground = Color3.fromRGB(35, 22, 28),
    DropdownItemHover = Color3.fromRGB(50, 32, 40),
    NotifyInfo = Color3.fromRGB(100, 140, 200),
    NotifySuccess = Color3.fromRGB(100, 200, 130),
    NotifyWarning = Color3.fromRGB(230, 180, 80),
    NotifyError = Color3.fromRGB(230, 90, 90),
    Shadow = Color3.fromRGB(10, 5, 8),
    LoadingBar = Color3.fromRGB(255, 107, 138),
    LoadingBarBg = Color3.fromRGB(50, 30, 40),
    LoadingText = Color3.fromRGB(255, 200, 215),
    CornerRadius = UDim.new(0, 8),
    CornerRadiusSmall = UDim.new(0, 6),
    CornerRadiusLarge = UDim.new(0, 12),
    Font = Enum.Font.Gotham,
    FontBold = Enum.Font.GothamBold,
    FontMedium = Enum.Font.GothamMedium,
    FontSemibold = Enum.Font.GothamSemibold,
    TextSizeTitle = 16,
    TextSizeElement = 14,
    TextSizeSmall = 12,
    TextSizeTiny = 11,
    ElementHeight = 38,
    TabWidth = 150,
    Padding = 8,
    AnimationSpeed = 0.25,
    AnimationSpeedFast = 0.15,
    AnimationEasing = Enum.EasingStyle.Quint,
    AnimationDirection = Enum.EasingDirection.Out,
}

-- ══════════════════════════════════════════════════════════════
-- UTILITY FUNCTIONS
-- ══════════════════════════════════════════════════════════════

local Utility = {}

function Utility.Create(className, properties)
    local instance = Instance.new(className)
    for property, value in pairs(properties) do
        if property ~= "Parent" then
            pcall(function()
                instance[property] = value
            end)
        end
    end
    if properties.Parent then
        instance.Parent = properties.Parent
    end
    return instance
end

function Utility.Tween(instance, properties, duration, easingStyle, easingDirection)
    local tweenInfo = TweenInfo.new(
        duration or Theme.AnimationSpeed,
        easingStyle or Theme.AnimationEasing,
        easingDirection or Theme.AnimationDirection
    )
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

function Utility.TweenFast(instance, properties)
    return Utility.Tween(instance, properties, Theme.AnimationSpeedFast)
end

function Utility.AddCorner(parent, radius)
    return Utility.Create("UICorner", {
        CornerRadius = radius or Theme.CornerRadius,
        Parent = parent,
    })
end

function Utility.AddStroke(parent, color, thickness, transparency)
    return Utility.Create("UIStroke", {
        Color = color or Theme.ElementBorder,
        Thickness = thickness or 1,
        Transparency = transparency or 0.5,
        Parent = parent,
    })
end

function Utility.AddPadding(parent, top, bottom, left, right)
    local p = top or Theme.Padding
    return Utility.Create("UIPadding", {
        PaddingTop = UDim.new(0, top or p),
        PaddingBottom = UDim.new(0, bottom or p),
        PaddingLeft = UDim.new(0, left or p),
        PaddingRight = UDim.new(0, right or p),
        Parent = parent,
    })
end

function Utility.AddListLayout(parent, padding, direction, hAlign, sortOrder)
    return Utility.Create("UIListLayout", {
        Padding = UDim.new(0, padding or 6),
        FillDirection = direction or Enum.FillDirection.Vertical,
        HorizontalAlignment = hAlign or Enum.HorizontalAlignment.Center,
        SortOrder = sortOrder or Enum.SortOrder.LayoutOrder,
        Parent = parent,
    })
end

function Utility.IsMobile()
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

function Utility.MakeDraggable(dragHandle, dragTarget)
    local dragging = false
    local dragInput = nil
    local dragStart = nil
    local startPos = nil

    local function updateDrag(input)
        if not dragStart or not startPos then return end
        local delta = input.Position - dragStart
        local newPos = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
        Utility.Tween(dragTarget, {Position = newPos}, 0.08)
    end

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = dragTarget.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            updateDrag(input)
        end
    end)
end

function Utility.CreateRipple(parent, position)
    local pos
    if position then
        pos = UDim2.new(0, position.X - parent.AbsolutePosition.X, 0, position.Y - parent.AbsolutePosition.Y)
    else
        pos = UDim2.new(0.5, 0, 0.5, 0)
    end

    local ripple = Utility.Create("Frame", {
        Name = "Ripple",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.7,
        Position = pos,
        Size = UDim2.new(0, 0, 0, 0),
        Parent = parent,
    })
    Utility.AddCorner(ripple, UDim.new(1, 0))

    local maxSize = math.max(parent.AbsoluteSize.X, parent.AbsoluteSize.Y) * 2.5
    local expandTween = Utility.Tween(ripple, {
        Size = UDim2.new(0, maxSize, 0, maxSize),
        BackgroundTransparency = 1,
    }, 0.5, Enum.EasingStyle.Quad)

    expandTween.Completed:Connect(function()
        ripple:Destroy()
    end)
end

function Utility.Truncate(text, maxLen)
    if #text <= maxLen then return text end
    return string.sub(text, 1, maxLen - 3) .. "..."
end

function Utility.Lerp(a, b, t)
    return a + (b - a) * t
end

function Utility.Color3ToHex(color)
    return string.format("#%02X%02X%02X",
        math.floor(color.R * 255 + 0.5),
        math.floor(color.G * 255 + 0.5),
        math.floor(color.B * 255 + 0.5)
    )
end

function Utility.HexToColor3(hex)
    hex = hex:gsub("#", "")
    local r = tonumber(hex:sub(1, 2), 16) or 0
    local g = tonumber(hex:sub(3, 4), 16) or 0
    local b = tonumber(hex:sub(5, 6), 16) or 0
    return Color3.fromRGB(r, g, b)
end

function Utility.ProtectGui(gui)
    local success = pcall(function()
        if typeof(gethui) == "function" then
            gui.Parent = gethui()
            return
        end
    end)
    if success then return end

    success = pcall(function()
        if syn and syn.protect_gui then
            syn.protect_gui(gui)
            gui.Parent = game:GetService("CoreGui")
            return
        end
    end)
    if success then return end

    success = pcall(function()
        gui.Parent = game:GetService("CoreGui")
    end)
    if not success then
        gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
end

-- ══════════════════════════════════════════════════════════════
-- HEART SHAPE BUILDER
-- ══════════════════════════════════════════════════════════════

local function CreateHeartIcon(parent, size, color, transparency)
    local heartContainer = Utility.Create("Frame", {
        Name = "HeartIcon",
        Size = UDim2.new(0, size, 0, size),
        BackgroundTransparency = 1,
        Parent = parent,
    })

    local heartColor = color or Theme.Primary
    local heartTransp = transparency or 0

    Utility.Create("Frame", {
        Name = "LeftBubble",
        Size = UDim2.new(0, size * 0.52, 0, size * 0.52),
        Position = UDim2.new(0, size * 0.05, 0, size * 0.1),
        BackgroundColor3 = heartColor,
        BackgroundTransparency = heartTransp,
        Parent = heartContainer,
    })
    Utility.AddCorner(heartContainer.LeftBubble, UDim.new(1, 0))

    Utility.Create("Frame", {
        Name = "RightBubble",
        Size = UDim2.new(0, size * 0.52, 0, size * 0.52),
        Position = UDim2.new(0, size * 0.43, 0, size * 0.1),
        BackgroundColor3 = heartColor,
        BackgroundTransparency = heartTransp,
        Parent = heartContainer,
    })
    Utility.AddCorner(heartContainer.RightBubble, UDim.new(1, 0))

    Utility.Create("Frame", {
        Name = "BottomPoint",
        Size = UDim2.new(0, size * 0.62, 0, size * 0.62),
        Position = UDim2.new(0, size * 0.19, 0, size * 0.28),
        Rotation = 45,
        BackgroundColor3 = heartColor,
        BackgroundTransparency = heartTransp,
        Parent = heartContainer,
    })

    return heartContainer
end

-- ══════════════════════════════════════════════════════════════
-- NOTIFICATION SYSTEM
-- ══════════════════════════════════════════════════════════════

local NotificationSystem = {}
NotificationSystem.__index = NotificationSystem

function NotificationSystem.new(screenGui)
    local self = setmetatable({}, NotificationSystem)

    self.Container = Utility.Create("Frame", {
        Name = "NotificationContainer",
        Size = UDim2.new(0, 300, 1, 0),
        Position = UDim2.new(1, -310, 0, 10),
        BackgroundTransparency = 1,
        Parent = screenGui,
    })

    Utility.AddListLayout(self.Container, 6, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Right)
    Utility.AddPadding(self.Container, 10, 10, 10, 10)

    return self
end

function NotificationSystem:Notify(config)
    local notifType = config.Type or "Info"
    local accentColor = Theme.NotifyInfo
    if notifType == "Success" then
        accentColor = Theme.NotifySuccess
    elseif notifType == "Warning" then
        accentColor = Theme.NotifyWarning
    elseif notifType == "Error" then
        accentColor = Theme.NotifyError
    end

    local notif = Utility.Create("Frame", {
        Name = "Notification",
        Size = UDim2.new(1, 0, 0, 70),
        BackgroundColor3 = Theme.WindowBackground,
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent = self.Container,
    })
    Utility.AddCorner(notif, Theme.CornerRadius)
    Utility.AddStroke(notif, accentColor, 1, 0.3)

    Utility.Create("Frame", {
        Name = "AccentBar",
        Size = UDim2.new(0, 3, 1, -8),
        Position = UDim2.new(0, 4, 0, 4),
        BackgroundColor3 = accentColor,
        Parent = notif,
    })
    Utility.AddCorner(notif.AccentBar, UDim.new(0, 2))

    local titleLabel = Utility.Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, -20, 0, 22),
        Position = UDim2.new(0, 14, 0, 8),
        BackgroundTransparency = 1,
        Text = config.Title or "Notification",
        TextColor3 = Theme.TextPrimary,
        TextSize = Theme.TextSizeElement,
        Font = Theme.FontBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTransparency = 1,
        Parent = notif,
    })

    local msgLabel = Utility.Create("TextLabel", {
        Name = "Message",
        Size = UDim2.new(1, -20, 0, 30),
        Position = UDim2.new(0, 14, 0, 32),
        BackgroundTransparency = 1,
        Text = config.Message or "",
        TextColor3 = Theme.TextSecondary,
        TextSize = Theme.TextSizeSmall,
        Font = Theme.Font,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        TextTransparency = 1,
        Parent = notif,
    })

    Utility.Tween(notif, {BackgroundTransparency = 0}, 0.3)
    Utility.Tween(titleLabel, {TextTransparency = 0}, 0.3)
    Utility.Tween(msgLabel, {TextTransparency = 0}, 0.3)

    local duration = config.Duration or 4
    task.delay(duration, function()
        Utility.Tween(notif, {BackgroundTransparency = 1}, 0.3)
        Utility.Tween(titleLabel, {TextTransparency = 1}, 0.3)
        local fadeTween = Utility.Tween(msgLabel, {TextTransparency = 1}, 0.3)
        fadeTween.Completed:Connect(function()
            Utility.Tween(notif, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
            task.delay(0.25, function()
                notif:Destroy()
            end)
        end)
    end)
end

-- ══════════════════════════════════════════════════════════════
-- LOADING SCREEN
-- ══════════════════════════════════════════════════════════════

local function ShowLoadingScreen(screenGui, libraryName)
    local loadingFrame = Utility.Create("Frame", {
        Name = "LoadingScreen",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(12, 6, 10),
        BackgroundTransparency = 0,
        ZIndex = 100,
        Parent = screenGui,
    })

    local centerContainer = Utility.Create("Frame", {
        Name = "Center",
        Size = UDim2.new(0, 320, 0, 220),
        Position = UDim2.new(0.5, -160, 0.5, -110),
        BackgroundTransparency = 1,
        ZIndex = 101,
        Parent = loadingFrame,
    })

    local heartIcon = CreateHeartIcon(centerContainer, 50, Theme.Primary)
    heartIcon.Position = UDim2.new(0.5, -25, 0, 10)
    heartIcon.ZIndex = 101
    for _, child in pairs(heartIcon:GetChildren()) do
        if child:IsA("GuiObject") then
            child.ZIndex = 101
        end
    end

    Utility.Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0, 0, 0, 70),
        BackgroundTransparency = 1,
        Text = libraryName,
        TextColor3 = Theme.Primary,
        TextSize = 22,
        Font = Theme.FontBold,
        ZIndex = 101,
        Parent = centerContainer,
    })

    Utility.Create("TextLabel", {
        Name = "Subtitle",
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0, 100),
        BackgroundTransparency = 1,
        Text = "Love Edition",
        TextColor3 = Theme.Accent,
        TextSize = Theme.TextSizeSmall,
        Font = Theme.FontMedium,
        ZIndex = 101,
        Parent = centerContainer,
    })

    local barBackground = Utility.Create("Frame", {
        Name = "LoadingBarBg",
        Size = UDim2.new(0, 260, 0, 6),
        Position = UDim2.new(0.5, -130, 0, 140),
        BackgroundColor3 = Theme.LoadingBarBg,
        ZIndex = 101,
        Parent = centerContainer,
    })
    Utility.AddCorner(barBackground, UDim.new(1, 0))

    local barFill = Utility.Create("Frame", {
        Name = "LoadingBarFill",
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Theme.LoadingBar,
        ZIndex = 102,
        Parent = barBackground,
    })
    Utility.AddCorner(barFill, UDim.new(1, 0))

    Utility.Create("Frame", {
        Name = "BarGlow",
        Size = UDim2.new(1, 4, 1, 4),
        Position = UDim2.new(0, -2, 0, -2),
        BackgroundColor3 = Theme.Primary,
        BackgroundTransparency = 0.7,
        ZIndex = 101,
        Parent = barFill,
    })
    Utility.AddCorner(barFill.BarGlow, UDim.new(1, 0))

    local statusLabel = Utility.Create("TextLabel", {
        Name = "Status",
        Size = UDim2.new(1, 0, 0, 18),
        Position = UDim2.new(0, 0, 0, 158),
        BackgroundTransparency = 1,
        Text = "Initializing...",
        TextColor3 = Theme.TextDimmed,
        TextSize = Theme.TextSizeTiny,
        Font = Theme.Font,
        ZIndex = 101,
        Parent = centerContainer,
    })

    local percentLabel = Utility.Create("TextLabel", {
        Name = "Percent",
        Size = UDim2.new(1, 0, 0, 18),
        Position = UDim2.new(0, 0, 0, 176),
        BackgroundTransparency = 1,
        Text = "0%",
        TextColor3 = Theme.TextDimmed,
        TextSize = Theme.TextSizeTiny,
        Font = Theme.Font,
        ZIndex = 101,
        Parent = centerContainer,
    })

    local loadingStages = {
        {progress = 0.15, text = "Loading theme engine..."},
        {progress = 0.30, text = "Building components..."},
        {progress = 0.50, text = "Initializing input handlers..."},
        {progress = 0.65, text = "Configuring mobile support..."},
        {progress = 0.80, text = "Preparing notifications..."},
        {progress = 0.92, text = "Finalizing layout..."},
        {progress = 1.00, text = "Ready <3"},
    }

    local pulseRunning = true
    task.spawn(function()
        while pulseRunning and heartIcon and heartIcon.Parent do
            Utility.Tween(heartIcon, {Size = UDim2.new(0, 55, 0, 55), Position = UDim2.new(0.5, -27, 0, 8)}, 0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(0.4)
            if not pulseRunning then break end
            Utility.Tween(heartIcon, {Size = UDim2.new(0, 50, 0, 50), Position = UDim2.new(0.5, -25, 0, 10)}, 0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(0.4)
        end
    end)

    for _, stage in ipairs(loadingStages) do
        local targetWidth = 260 * stage.progress
        statusLabel.Text = stage.text
        Utility.Tween(barFill, {Size = UDim2.new(0, targetWidth, 1, 0)}, 0.35, Enum.EasingStyle.Quad)
        percentLabel.Text = tostring(math.floor(stage.progress * 100)) .. "%"
        task.wait(math.random(25, 45) / 100)
    end

    task.wait(0.4)
    pulseRunning = false

    Utility.Tween(loadingFrame, {BackgroundTransparency = 1}, 0.5)
    Utility.Tween(centerContainer, {Position = UDim2.new(0.5, -160, 0.5, -130)}, 0.5)

    for _, descendant in pairs(centerContainer:GetDescendants()) do
        if descendant:IsA("TextLabel") then
            Utility.Tween(descendant, {TextTransparency = 1}, 0.4)
        elseif descendant:IsA("GuiObject") then
            Utility.Tween(descendant, {BackgroundTransparency = 1}, 0.4)
        end
    end

    task.wait(0.6)
    loadingFrame:Destroy()
end

-- ══════════════════════════════════════════════════════════════
-- COMPONENT: SECTION
-- ══════════════════════════════════════════════════════════════

local function CreateSection(parent, config)
    local sectionFrame = Utility.Create("Frame", {
        Name = "Section",
        Size = UDim2.new(1, -16, 0, 28),
        BackgroundTransparency = 1,
        Parent = parent,
    })

    Utility.Create("Frame", {
        Name = "Line",
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 0.5, 0),
        BackgroundColor3 = Theme.ElementBorder,
        BackgroundTransparency = 0.5,
        Parent = sectionFrame,
    })

    if config.Name then
        Utility.Create("TextLabel", {
            Name = "Label",
            Size = UDim2.new(0, 0, 1, 0),
            Position = UDim2.new(0, 8, 0, 0),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundColor3 = Theme.WindowBackground,
            BackgroundTransparency = 0,
            Text = "  " .. config.Name .. "  ",
            TextColor3 = Theme.TextDimmed,
            TextSize = Theme.TextSizeTiny,
            Font = Theme.FontSemibold,
            Parent = sectionFrame,
        })
    end

    return sectionFrame
end

-- ══════════════════════════════════════════════════════════════
-- COMPONENT: LABEL
-- ══════════════════════════════════════════════════════════════

local function CreateLabel(parent, config)
    local labelFrame = Utility.Create("Frame", {
        Name = "LabelElement",
        Size = UDim2.new(1, -16, 0, 28),
        BackgroundTransparency = 1,
        Parent = parent,
    })

    local label = Utility.Create("TextLabel", {
        Name = "Text",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = config.Name or "Label",
        TextColor3 = Theme.TextSecondary,
        TextSize = Theme.TextSizeSmall,
        Font = Theme.FontMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = labelFrame,
    })

    return label
end

-- ══════════════════════════════════════════════════════════════
-- COMPONENT: BUTTON
-- ══════════════════════════════════════════════════════════════

local function CreateButton(parent, config)
    local buttonFrame = Utility.Create("Frame", {
        Name = "ButtonElement",
        Size = UDim2.new(1, -16, 0, Theme.ElementHeight),
        BackgroundTransparency = 1,
        Parent = parent,
    })

    local button = Utility.Create("TextButton", {
        Name = "Button",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Theme.ElementBackground,
        Text = config.Name or "Button",
        TextColor3 = Theme.TextPrimary,
        TextSize = Theme.TextSizeElement,
        Font = Theme.FontMedium,
        AutoButtonColor = false,
        ClipsDescendants = true,
        Parent = buttonFrame,
    })
    Utility.AddCorner(button, Theme.CornerRadiusSmall)
    Utility.AddStroke(button, Theme.ElementBorder, 1, 0.6)

    button.MouseEnter:Connect(function()
        Utility.TweenFast(button, {BackgroundColor3 = Theme.ElementBackgroundHover})
    end)
    button.MouseLeave:Connect(function()
        Utility.TweenFast(button, {BackgroundColor3 = Theme.ElementBackground})
    end)

    button.MouseButton1Click:Connect(function()
        Utility.CreateRipple(button)
        Utility.TweenFast(button, {BackgroundColor3 = Theme.Primary})
        task.delay(0.15, function()
            Utility.TweenFast(button, {BackgroundColor3 = Theme.ElementBackground})
        end)
        if config.Callback then
            task.spawn(config.Callback)
        end
    end)

    return buttonFrame
end

-- ══════════════════════════════════════════════════════════════
-- COMPONENT: TOGGLE
-- ══════════════════════════════════════════════════════════════

local function CreateToggle(parent, config)
    local toggled = config.Default or false

    local toggleFrame = Utility.Create("Frame", {
        Name = "ToggleElement",
        Size = UDim2.new(1, -16, 0, Theme.ElementHeight),
        BackgroundColor3 = Theme.ElementBackground,
        Parent = parent,
    })
    Utility.AddCorner(toggleFrame, Theme.CornerRadiusSmall)
    Utility.AddStroke(toggleFrame, Theme.ElementBorder, 1, 0.6)

    Utility.Create("TextLabel", {
        Name = "Label",
        Size = UDim2.new(1, -60, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = config.Name or "Toggle",
        TextColor3 = Theme.TextPrimary,
        TextSize = Theme.TextSizeElement,
        Font = Theme.Font,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = toggleFrame,
    })

    local switchBgColor = Theme.ToggleOff
    if toggled then switchBgColor = Theme.ToggleOn end

    local switchOuter = Utility.Create("Frame", {
        Name = "SwitchOuter",
        Size = UDim2.new(0, 44, 0, 22),
        Position = UDim2.new(1, -54, 0.5, -11),
        BackgroundColor3 = switchBgColor,
        Parent = toggleFrame,
    })
    Utility.AddCorner(switchOuter, UDim.new(1, 0))

    local innerPos = UDim2.new(0, 3, 0.5, -8)
    if toggled then innerPos = UDim2.new(1, -19, 0.5, -8) end

    local switchInner = Utility.Create("Frame", {
        Name = "SwitchInner",
        Size = UDim2.new(0, 16, 0, 16),
        Position = innerPos,
        BackgroundColor3 = Theme.TextPrimary,
        Parent = switchOuter,
    })
    Utility.AddCorner(switchInner, UDim.new(1, 0))

    local glowPos = UDim2.new(0, 0, 0.5, -11)
    local glowTransp = 1
    if toggled then
        glowPos = UDim2.new(1, -22, 0.5, -11)
        glowTransp = 0.6
    end

    local switchGlow = Utility.Create("Frame", {
        Name = "Glow",
        Size = UDim2.new(0, 22, 0, 22),
        Position = glowPos,
        BackgroundColor3 = Theme.Primary,
        BackgroundTransparency = glowTransp,
        Parent = switchOuter,
    })
    Utility.AddCorner(switchGlow, UDim.new(1, 0))

    local function updateVisual()
        if toggled then
            Utility.Tween(switchOuter, {BackgroundColor3 = Theme.ToggleOn})
            Utility.Tween(switchInner, {Position = UDim2.new(1, -19, 0.5, -8)})
            Utility.Tween(switchGlow, {Position = UDim2.new(1, -22, 0.5, -11), BackgroundTransparency = 0.6})
        else
            Utility.Tween(switchOuter, {BackgroundColor3 = Theme.ToggleOff})
            Utility.Tween(switchInner, {Position = UDim2.new(0, 3, 0.5, -8)})
            Utility.Tween(switchGlow, {Position = UDim2.new(0, 0, 0.5, -11), BackgroundTransparency = 1})
        end
    end

    local clickButton = Utility.Create("TextButton", {
        Name = "Clickable",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = toggleFrame,
    })

    clickButton.MouseButton1Click:Connect(function()
        toggled = not toggled
        updateVisual()
        if config.Callback then
            task.spawn(config.Callback, toggled)
        end
    end)

    toggleFrame.MouseEnter:Connect(function()
        Utility.TweenFast(toggleFrame, {BackgroundColor3 = Theme.ElementBackgroundHover})
    end)
    toggleFrame.MouseLeave:Connect(function()
        Utility.TweenFast(toggleFrame, {BackgroundColor3 = Theme.ElementBackground})
    end)

    local toggleObj = {Frame = toggleFrame}
    function toggleObj:Set(value)
        toggled = value
        updateVisual()
        if config.Callback then
            task.spawn(config.Callback, toggled)
        end
    end
    return toggleObj
end

-- ══════════════════════════════════════════════════════════════
-- COMPONENT: SLIDER
-- ══════════════════════════════════════════════════════════════

local function CreateSlider(parent, config)
    local minVal = config.Min or 0
    local maxVal = config.Max or 100
    local increment = config.Increment or 1
    local currentVal = math.clamp(config.Default or minVal, minVal, maxVal)

    local sliderFrame = Utility.Create("Frame", {
        Name = "SliderElement",
        Size = UDim2.new(1, -16, 0, 50),
        BackgroundColor3 = Theme.ElementBackground,
        Parent = parent,
    })
    Utility.AddCorner(sliderFrame, Theme.CornerRadiusSmall)
    Utility.AddStroke(sliderFrame, Theme.ElementBorder, 1, 0.6)

    local topRow = Utility.Create("Frame", {
        Name = "TopRow",
        Size = UDim2.new(1, -16, 0, 22),
        Position = UDim2.new(0, 8, 0, 4),
        BackgroundTransparency = 1,
        Parent = sliderFrame,
    })

    Utility.Create("TextLabel", {
        Name = "Label",
        Size = UDim2.new(0.7, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = config.Name or "Slider",
        TextColor3 = Theme.TextPrimary,
        TextSize = Theme.TextSizeElement,
        Font = Theme.Font,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = topRow,
    })

    local valueLabel = Utility.Create("TextLabel", {
        Name = "Value",
        Size = UDim2.new(0.3, 0, 1, 0),
        Position = UDim2.new(0.7, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = tostring(currentVal),
        TextColor3 = Theme.Primary,
        TextSize = Theme.TextSizeSmall,
        Font = Theme.FontSemibold,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = topRow,
    })

    local track = Utility.Create("Frame", {
        Name = "Track",
        Size = UDim2.new(1, -16, 0, 6),
        Position = UDim2.new(0, 8, 0, 32),
        BackgroundColor3 = Theme.SliderTrack,
        Parent = sliderFrame,
    })
    Utility.AddCorner(track, UDim.new(1, 0))

    local fillPercent = 0
    if maxVal ~= minVal then
        fillPercent = (currentVal - minVal) / (maxVal - minVal)
    end

    local fill = Utility.Create("Frame", {
        Name = "Fill",
        Size = UDim2.new(fillPercent, 0, 1, 0),
        BackgroundColor3 = Theme.SliderFill,
        Parent = track,
    })
    Utility.AddCorner(fill, UDim.new(1, 0))

    Utility.Create("Frame", {
        Name = "FillGlow",
        Size = UDim2.new(1, 2, 1, 2),
        Position = UDim2.new(0, -1, 0, -1),
        BackgroundColor3 = Theme.Primary,
        BackgroundTransparency = 0.7,
        ZIndex = 0,
        Parent = fill,
    })
    Utility.AddCorner(fill.FillGlow, UDim.new(1, 0))

    local handle = Utility.Create("Frame", {
        Name = "Handle",
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(fillPercent, -8, 0.5, -8),
        BackgroundColor3 = Theme.SliderHandle,
        ZIndex = 3,
        Parent = track,
    })
    Utility.AddCorner(handle, UDim.new(1, 0))

    Utility.Create("Frame", {
        Name = "HandleGlow",
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(0.5, -12, 0.5, -12),
        BackgroundColor3 = Theme.Primary,
        BackgroundTransparency = 0.75,
        ZIndex = 2,
        Parent = handle,
    })
    Utility.AddCorner(handle.HandleGlow, UDim.new(1, 0))

    local isDragging = false

    local function updateSlider(inputX)
        local trackAbsPos = track.AbsolutePosition.X
        local trackAbsSize = track.AbsoluteSize.X
        if trackAbsSize == 0 then return end
        local relativeX = math.clamp((inputX - trackAbsPos) / trackAbsSize, 0, 1)

        local rawValue = minVal + (maxVal - minVal) * relativeX
        local snapped = math.floor(rawValue / increment + 0.5) * increment
        snapped = math.clamp(snapped, minVal, maxVal)
        currentVal = snapped

        local newPercent = 0
        if maxVal ~= minVal then
            newPercent = (snapped - minVal) / (maxVal - minVal)
        end
        Utility.TweenFast(fill, {Size = UDim2.new(newPercent, 0, 1, 0)})
        Utility.TweenFast(handle, {Position = UDim2.new(newPercent, -8, 0.5, -8)})
        valueLabel.Text = tostring(snapped)

        if config.Callback then
            task.spawn(config.Callback, snapped)
        end
    end

    local sliderButton = Utility.Create("TextButton", {
        Name = "SliderClickArea",
        Size = UDim2.new(1, 0, 0, 24),
        Position = UDim2.new(0, 0, 0, 26),
        BackgroundTransparency = 1,
        Text = "",
        Parent = sliderFrame,
    })

    sliderButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            updateSlider(input.Position.X)
        end
    end)

    sliderButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input.Position.X)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = false
        end
    end)

    sliderFrame.MouseEnter:Connect(function()
        Utility.TweenFast(sliderFrame, {BackgroundColor3 = Theme.ElementBackgroundHover})
    end)
    sliderFrame.MouseLeave:Connect(function()
        Utility.TweenFast(sliderFrame, {BackgroundColor3 = Theme.ElementBackground})
    end)

    local sliderObj = {Frame = sliderFrame}
    function sliderObj:Set(value)
        value = math.clamp(value, minVal, maxVal)
        currentVal = value
        local p = 0
        if maxVal ~= minVal then
            p = (value - minVal) / (maxVal - minVal)
        end
        Utility.Tween(fill, {Size = UDim2.new(p, 0, 1, 0)})
        Utility.Tween(handle, {Position = UDim2.new(p, -8, 0.5, -8)})
        valueLabel.Text = tostring(value)
        if config.Callback then
            task.spawn(config.Callback, value)
        end
    end
    return sliderObj
end

-- ══════════════════════════════════════════════════════════════
-- COMPONENT: DROPDOWN
-- ══════════════════════════════════════════════════════════════

local function CreateDropdown(parent, config)
    local options = config.Options or {}
    local isMulti = config.MultiSelect or false
    local selectedSingle = config.Default
    if not selectedSingle and #options > 0 then
        selectedSingle = options[1]
    end
    selectedSingle = selectedSingle or ""
    local selectedMulti = {}
    local isOpen = false

    if isMulti and config.Default then
        selectedMulti[config.Default] = true
    end

    local dropdownFrame = Utility.Create("Frame", {
        Name = "DropdownElement",
        Size = UDim2.new(1, -16, 0, Theme.ElementHeight),
        BackgroundColor3 = Theme.ElementBackground,
        ClipsDescendants = false,
        Parent = parent,
    })
    Utility.AddCorner(dropdownFrame, Theme.CornerRadiusSmall)
    Utility.AddStroke(dropdownFrame, Theme.ElementBorder, 1, 0.6)

    Utility.Create("TextLabel", {
        Name = "Label",
        Size = UDim2.new(0.5, -8, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = config.Name or "Dropdown",
        TextColor3 = Theme.TextPrimary,
        TextSize = Theme.TextSizeElement,
        Font = Theme.Font,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = dropdownFrame,
    })

    local initSelectedText = selectedSingle
    if isMulti then initSelectedText = "None" end

    local selectedLabel = Utility.Create("TextLabel", {
        Name = "Selected",
        Size = UDim2.new(0.45, -8, 1, 0),
        Position = UDim2.new(0.5, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = initSelectedText,
        TextColor3 = Theme.TextSecondary,
        TextSize = Theme.TextSizeSmall,
        Font = Theme.FontMedium,
        TextXAlignment = Enum.TextXAlignment.Right,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = dropdownFrame,
    })

    local arrow = Utility.Create("TextLabel", {
        Name = "Arrow",
        Size = UDim2.new(0, 20, 1, 0),
        Position = UDim2.new(1, -24, 0, 0),
        BackgroundTransparency = 1,
        Text = "v",
        TextColor3 = Theme.TextDimmed,
        TextSize = 12,
        Font = Theme.FontBold,
        Parent = dropdownFrame,
    })

    local optionsContainer = Utility.Create("ScrollingFrame", {
        Name = "Options",
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 1, 4),
        BackgroundColor3 = Theme.DropdownBackground,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.Primary,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 50,
        ClipsDescendants = true,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Parent = dropdownFrame,
    })
    Utility.AddCorner(optionsContainer, Theme.CornerRadiusSmall)
    Utility.AddStroke(optionsContainer, Theme.ElementBorder, 1, 0.4)
    local optionsLayout = Utility.AddListLayout(optionsContainer, 2)
    Utility.AddPadding(optionsContainer, 4, 4, 4, 4)

    local function getMultiText()
        local selected = {}
        for _, opt in ipairs(options) do
            if selectedMulti[opt] then
                table.insert(selected, opt)
            end
        end
        if #selected == 0 then return "None" end
        if #selected > 2 then return tostring(#selected) .. " selected" end
        return table.concat(selected, ", ")
    end

    local function buildOptions()
        for _, child in pairs(optionsContainer:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end

        for i, option in ipairs(options) do
            local isSelected
            if isMulti then
                isSelected = (selectedMulti[option] == true)
            else
                isSelected = (option == selectedSingle)
            end

            local bgColor = Color3.fromRGB(0, 0, 0)
            local bgTransp = 1
            local txtColor = Theme.TextSecondary
            local txtFont = Theme.Font
            local prefix = ""

            if isSelected then
                bgColor = Theme.Primary
                bgTransp = 0.7
                txtColor = Theme.TextPrimary
                txtFont = Theme.FontMedium
                if isMulti then prefix = ">> " end
            end

            local optButton = Utility.Create("TextButton", {
                Name = "Option_" .. i,
                Size = UDim2.new(1, -8, 0, 30),
                BackgroundColor3 = bgColor,
                BackgroundTransparency = bgTransp,
                Text = prefix .. option,
                TextColor3 = txtColor,
                TextSize = Theme.TextSizeSmall,
                Font = txtFont,
                TextXAlignment = Enum.TextXAlignment.Left,
                AutoButtonColor = false,
                ZIndex = 51,
                LayoutOrder = i,
                Parent = optionsContainer,
            })
            Utility.AddCorner(optButton, UDim.new(0, 4))
            Utility.AddPadding(optButton, 0, 0, 8, 8)

            optButton.MouseEnter:Connect(function()
                local sel
                if isMulti then sel = selectedMulti[option] else sel = (option == selectedSingle) end
                if not sel then
                    Utility.TweenFast(optButton, {BackgroundColor3 = Theme.DropdownItemHover, BackgroundTransparency = 0})
                end
            end)
            optButton.MouseLeave:Connect(function()
                local sel
                if isMulti then sel = selectedMulti[option] else sel = (option == selectedSingle) end
                if not sel then
                    Utility.TweenFast(optButton, {BackgroundTransparency = 1})
                end
            end)

            optButton.MouseButton1Click:Connect(function()
                if isMulti then
                    selectedMulti[option] = not selectedMulti[option]
                    selectedLabel.Text = getMultiText()
                    buildOptions()
                    if config.Callback then
                        local selected = {}
                        for _, o in ipairs(options) do
                            if selectedMulti[o] then table.insert(selected, o) end
                        end
                        task.spawn(config.Callback, selected)
                    end
                else
                    selectedSingle = option
                    selectedLabel.Text = option
                    buildOptions()
                    isOpen = false
                    Utility.Tween(optionsContainer, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
                    task.delay(0.2, function()
                        optionsContainer.Visible = false
                    end)
                    Utility.Tween(arrow, {Rotation = 0}, 0.2)
                    if config.Callback then
                        task.spawn(config.Callback, option)
                    end
                end
            end)
        end

        optionsContainer.CanvasSize = UDim2.new(0, 0, 0, optionsLayout.AbsoluteContentSize.Y + 8)
    end

    buildOptions()

    local clickButton = Utility.Create("TextButton", {
        Name = "DropdownClick",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 2,
        Parent = dropdownFrame,
    })

    clickButton.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            optionsContainer.Visible = true
            local targetHeight = math.min(#options * 34 + 10, 180)
            Utility.Tween(optionsContainer, {Size = UDim2.new(1, 0, 0, targetHeight)}, 0.25)
            Utility.Tween(arrow, {Rotation = 180}, 0.25)
        else
            Utility.Tween(optionsContainer, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
            task.delay(0.2, function()
                optionsContainer.Visible = false
            end)
            Utility.Tween(arrow, {Rotation = 0}, 0.2)
        end
    end)

    dropdownFrame.MouseEnter:Connect(function()
        Utility.TweenFast(dropdownFrame, {BackgroundColor3 = Theme.ElementBackgroundHover})
    end)
    dropdownFrame.MouseLeave:Connect(function()
        Utility.TweenFast(dropdownFrame, {BackgroundColor3 = Theme.ElementBackground})
    end)

    local dropObj = {Frame = dropdownFrame}
    function dropObj:Set(value)
        if isMulti and type(value) == "table" then
            selectedMulti = {}
            for _, v in ipairs(value) do selectedMulti[v] = true end
            selectedLabel.Text = getMultiText()
        else
            selectedSingle = value
            selectedLabel.Text = tostring(value)
        end
        buildOptions()
    end
    function dropObj:Refresh(newOptions)
        options = newOptions
        buildOptions()
    end
    return dropObj
end

-- ══════════════════════════════════════════════════════════════
-- COMPONENT: TEXT INPUT
-- ══════════════════════════════════════════════════════════════

local function CreateTextInput(parent, config)
    local inputFrame = Utility.Create("Frame", {
        Name = "TextInputElement",
        Size = UDim2.new(1, -16, 0, Theme.ElementHeight + 10),
        BackgroundColor3 = Theme.ElementBackground,
        Parent = parent,
    })
    Utility.AddCorner(inputFrame, Theme.CornerRadiusSmall)
    Utility.AddStroke(inputFrame, Theme.ElementBorder, 1, 0.6)

    Utility.Create("TextLabel", {
        Name = "Label",
        Size = UDim2.new(1, -16, 0, 18),
        Position = UDim2.new(0, 8, 0, 4),
        BackgroundTransparency = 1,
        Text = config.Name or "Input",
        TextColor3 = Theme.TextPrimary,
        TextSize = Theme.TextSizeSmall,
        Font = Theme.Font,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = inputFrame,
    })

    local textBox = Utility.Create("TextBox", {
        Name = "TextBox",
        Size = UDim2.new(1, -16, 0, 22),
        Position = UDim2.new(0, 8, 0, 22),
        BackgroundColor3 = Theme.DropdownBackground,
        Text = config.Default or "",
        PlaceholderText = config.Placeholder or "Type here...",
        PlaceholderColor3 = Theme.TextDimmed,
        TextColor3 = Theme.TextPrimary,
        TextSize = Theme.TextSizeSmall,
        Font = Theme.Font,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        ClipsDescendants = true,
        Parent = inputFrame,
    })
    Utility.AddCorner(textBox, UDim.new(0, 4))
    Utility.AddPadding(textBox, 0, 0, 6, 6)

    local inputStroke = Utility.AddStroke(textBox, Theme.ElementBorder, 1, 0.7)

    textBox.Focused:Connect(function()
        Utility.Tween(inputStroke, {Color = Theme.Primary, Transparency = 0.2})
    end)
    textBox.FocusLost:Connect(function(enterPressed)
        Utility.Tween(inputStroke, {Color = Theme.ElementBorder, Transparency = 0.7})
        if config.Callback then
            task.spawn(config.Callback, textBox.Text)
        end
    end)

    local inputObj = {Frame = inputFrame}
    function inputObj:Set(value)
        textBox.Text = value
    end
    return inputObj
end

-- ══════════════════════════════════════════════════════════════
-- COMPONENT: KEYBIND
-- ══════════════════════════════════════════════════════════════

local function CreateKeybind(parent, config)
    local currentKey = config.Default or Enum.KeyCode.Unknown
    local listening = false

    local keybindFrame = Utility.Create("Frame", {
        Name = "KeybindElement",
        Size = UDim2.new(1, -16, 0, Theme.ElementHeight),
        BackgroundColor3 = Theme.ElementBackground,
        Parent = parent,
    })
    Utility.AddCorner(keybindFrame, Theme.CornerRadiusSmall)
    Utility.AddStroke(keybindFrame, Theme.ElementBorder, 1, 0.6)

    Utility.Create("TextLabel", {
        Name = "Label",
        Size = UDim2.new(0.6, 0, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = config.Name or "Keybind",
        TextColor3 = Theme.TextPrimary,
        TextSize = Theme.TextSizeElement,
        Font = Theme.Font,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = keybindFrame,
    })

    local keyText = "None"
    if currentKey ~= Enum.KeyCode.Unknown then
        keyText = currentKey.Name
    end

    local keyDisplay = Utility.Create("TextButton", {
        Name = "KeyDisplay",
        Size = UDim2.new(0, 80, 0, 26),
        Position = UDim2.new(1, -90, 0.5, -13),
        BackgroundColor3 = Theme.DropdownBackground,
        Text = keyText,
        TextColor3 = Theme.Primary,
        TextSize = Theme.TextSizeSmall,
        Font = Theme.FontMedium,
        AutoButtonColor = false,
        Parent = keybindFrame,
    })
    Utility.AddCorner(keyDisplay, UDim.new(0, 4))
    Utility.AddStroke(keyDisplay, Theme.Primary, 1, 0.6)

    keyDisplay.MouseButton1Click:Connect(function()
        listening = true
        keyDisplay.Text = "..."
        Utility.Tween(keyDisplay, {BackgroundColor3 = Theme.Primary})
        Utility.Tween(keyDisplay, {TextColor3 = Theme.TextPrimary})
    end)

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if listening then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                listening = false
                currentKey = input.KeyCode
                keyDisplay.Text = input.KeyCode.Name
                Utility.Tween(keyDisplay, {BackgroundColor3 = Theme.DropdownBackground})
                Utility.Tween(keyDisplay, {TextColor3 = Theme.Primary})
                if config.Callback then
                    task.spawn(config.Callback, currentKey)
                end
            end
        elseif input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == currentKey then
            if config.Callback then
                task.spawn(config.Callback, currentKey)
            end
        end
    end)

    keybindFrame.MouseEnter:Connect(function()
        Utility.TweenFast(keybindFrame, {BackgroundColor3 = Theme.ElementBackgroundHover})
    end)
    keybindFrame.MouseLeave:Connect(function()
        Utility.TweenFast(keybindFrame, {BackgroundColor3 = Theme.ElementBackground})
    end)

    local keybindObj = {Frame = keybindFrame}
    function keybindObj:Set(key)
        currentKey = key
        keyDisplay.Text = key.Name
    end
    return keybindObj
end

-- ══════════════════════════════════════════════════════════════
-- COMPONENT: COLOR PICKER
-- ══════════════════════════════════════════════════════════════

local function CreateColorPicker(parent, config)
    local currentColor = config.Default or Theme.Primary
    local isOpen = false
    local currentH, currentS, currentV = currentColor:ToHSV()

    local pickerFrame = Utility.Create("Frame", {
        Name = "ColorPickerElement",
        Size = UDim2.new(1, -16, 0, Theme.ElementHeight),
        BackgroundColor3 = Theme.ElementBackground,
        ClipsDescendants = false,
        Parent = parent,
    })
    Utility.AddCorner(pickerFrame, Theme.CornerRadiusSmall)
    Utility.AddStroke(pickerFrame, Theme.ElementBorder, 1, 0.6)

    Utility.Create("TextLabel", {
        Name = "Label",
        Size = UDim2.new(0.6, 0, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = config.Name or "Color",
        TextColor3 = Theme.TextPrimary,
        TextSize = Theme.TextSizeElement,
        Font = Theme.Font,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = pickerFrame,
    })

    local previewSwatch = Utility.Create("Frame", {
        Name = "Swatch",
        Size = UDim2.new(0, 30, 0, 22),
        Position = UDim2.new(1, -42, 0.5, -11),
        BackgroundColor3 = currentColor,
        Parent = pickerFrame,
    })
    Utility.AddCorner(previewSwatch, UDim.new(0, 4))
    Utility.AddStroke(previewSwatch, Theme.ElementBorder, 1, 0.4)

    local expandedPanel = Utility.Create("Frame", {
        Name = "ExpandedPanel",
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 1, 4),
        BackgroundColor3 = Theme.DropdownBackground,
        ClipsDescendants = true,
        Visible = false,
        ZIndex = 50,
        Parent = pickerFrame,
    })
    Utility.AddCorner(expandedPanel, Theme.CornerRadiusSmall)
    Utility.AddStroke(expandedPanel, Theme.ElementBorder, 1, 0.4)

    local satValBox = Utility.Create("ImageLabel", {
        Name = "SatValBox",
        Size = UDim2.new(1, -20, 0, 100),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundColor3 = Color3.fromHSV(currentH, 1, 1),
        Image = "rbxassetid://4155801252",
        ZIndex = 51,
        Parent = expandedPanel,
    })
    Utility.AddCorner(satValBox, UDim.new(0, 4))

    local satValCursor = Utility.Create("Frame", {
        Name = "Cursor",
        Size = UDim2.new(0, 10, 0, 10),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(currentS, 0, 1 - currentV, 0),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        ZIndex = 52,
        Parent = satValBox,
    })
    Utility.AddCorner(satValCursor, UDim.new(1, 0))
    Utility.AddStroke(satValCursor, Color3.fromRGB(0, 0, 0), 2, 0)

    local hueBar = Utility.Create("Frame", {
        Name = "HueBar",
        Size = UDim2.new(1, -20, 0, 16),
        Position = UDim2.new(0, 10, 0, 118),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        ZIndex = 51,
        Parent = expandedPanel,
    })
    Utility.AddCorner(hueBar, UDim.new(0, 4))

    Utility.Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)),
            ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
        }),
        Parent = hueBar,
    })

    local hueCursor = Utility.Create("Frame", {
        Name = "HueCursor",
        Size = UDim2.new(0, 6, 1, 4),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(currentH, 0, 0.5, 0),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        ZIndex = 52,
        Parent = hueBar,
    })
    Utility.AddCorner(hueCursor, UDim.new(0, 2))
    Utility.AddStroke(hueCursor, Color3.fromRGB(0, 0, 0), 1, 0)

    local hexInput = Utility.Create("TextBox", {
        Name = "HexInput",
        Size = UDim2.new(1, -20, 0, 24),
        Position = UDim2.new(0, 10, 0, 142),
        BackgroundColor3 = Theme.ElementBackground,
        Text = Utility.Color3ToHex(currentColor),
        TextColor3 = Theme.TextPrimary,
        TextSize = Theme.TextSizeSmall,
        Font = Theme.Font,
        ZIndex = 51,
        ClearTextOnFocus = false,
        Parent = expandedPanel,
    })
    Utility.AddCorner(hexInput, UDim.new(0, 4))
    Utility.AddPadding(hexInput, 0, 0, 6, 6)

    local function updateColor()
        currentColor = Color3.fromHSV(currentH, currentS, currentV)
        previewSwatch.BackgroundColor3 = currentColor
        satValBox.BackgroundColor3 = Color3.fromHSV(currentH, 1, 1)
        satValCursor.Position = UDim2.new(currentS, 0, 1 - currentV, 0)
        hueCursor.Position = UDim2.new(currentH, 0, 0.5, 0)
        hexInput.Text = Utility.Color3ToHex(currentColor)
        if config.Callback then
            task.spawn(config.Callback, currentColor)
        end
    end

    local draggingSV = false
    local draggingHue = false

    satValBox.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingSV = true
            local relX = math.clamp((input.Position.X - satValBox.AbsolutePosition.X) / satValBox.AbsoluteSize.X, 0, 1)
            local relY = math.clamp((input.Position.Y - satValBox.AbsolutePosition.Y) / satValBox.AbsoluteSize.Y, 0, 1)
            currentS = relX
            currentV = 1 - relY
            updateColor()
        end
    end)

    hueBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingHue = true
            local relX = math.clamp((input.Position.X - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
            currentH = relX
            updateColor()
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if draggingSV and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local relX = math.clamp((input.Position.X - satValBox.AbsolutePosition.X) / satValBox.AbsoluteSize.X, 0, 1)
            local relY = math.clamp((input.Position.Y - satValBox.AbsolutePosition.Y) / satValBox.AbsoluteSize.Y, 0, 1)
            currentS = relX
            currentV = 1 - relY
            updateColor()
        elseif draggingHue and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local relX = math.clamp((input.Position.X - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
            currentH = relX
            updateColor()
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingSV = false
            draggingHue = false
        end
    end)

    hexInput.FocusLost:Connect(function()
        local success, color = pcall(Utility.HexToColor3, hexInput.Text)
        if success then
            currentH, currentS, currentV = color:ToHSV()
            updateColor()
        else
            hexInput.Text = Utility.Color3ToHex(currentColor)
        end
    end)

    local clickBtn = Utility.Create("TextButton", {
        Name = "PickerClick",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 2,
        Parent = pickerFrame,
    })

    clickBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            expandedPanel.Visible = true
            Utility.Tween(expandedPanel, {Size = UDim2.new(1, 0, 0, 176)}, 0.25)
        else
            Utility.Tween(expandedPanel, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
            task.delay(0.2, function()
                expandedPanel.Visible = false
            end)
        end
    end)

    pickerFrame.MouseEnter:Connect(function()
        Utility.TweenFast(pickerFrame, {BackgroundColor3 = Theme.ElementBackgroundHover})
    end)
    pickerFrame.MouseLeave:Connect(function()
        Utility.TweenFast(pickerFrame, {BackgroundColor3 = Theme.ElementBackground})
    end)

    local pickerObj = {Frame = pickerFrame}
    function pickerObj:Set(color)
        currentH, currentS, currentV = color:ToHSV()
        updateColor()
    end
    return pickerObj
end

-- ══════════════════════════════════════════════════════════════
-- TAB SYSTEM
-- ══════════════════════════════════════════════════════════════

local TabSystem = {}
TabSystem.__index = TabSystem

function TabSystem.new(tabBar, contentArea)
    local self = setmetatable({}, TabSystem)
    self.TabBar = tabBar
    self.ContentArea = contentArea
    self.Tabs = {}
    self.ActiveTab = nil
    return self
end

function TabSystem:CreateTab(config)
    local tabIndex = #self.Tabs + 1
    local tabName = config.Name or ("Tab " .. tabIndex)

    local tabButton = Utility.Create("TextButton", {
        Name = "Tab_" .. tabName,
        Size = UDim2.new(1, -8, 0, 36),
        BackgroundColor3 = Theme.TabInactive,
        BackgroundTransparency = 0.8,
        Text = "",
        AutoButtonColor = false,
        LayoutOrder = tabIndex,
        Parent = self.TabBar,
    })
    Utility.AddCorner(tabButton, Theme.CornerRadiusSmall)

    local iconMap = {
        heart = "<<3",
        star = "*",
        gear = "@",
        shield = "#",
        bolt = "!",
        eye = "o",
        home = "^",
        user = "&",
        tool = "+",
    }

    local iconText = "<<3"
    if config.Icon and iconMap[config.Icon] then
        iconText = iconMap[config.Icon]
    elseif config.Icon then
        iconText = config.Icon
    end

    local iconLabel = Utility.Create("TextLabel", {
        Name = "Icon",
        Size = UDim2.new(0, 20, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1,
        Text = iconText,
        TextColor3 = Theme.TextDimmed,
        TextSize = 12,
        Font = Theme.FontBold,
        Parent = tabButton,
    })

    local tabLabel = Utility.Create("TextLabel", {
        Name = "Label",
        Size = UDim2.new(1, -38, 1, 0),
        Position = UDim2.new(0, 30, 0, 0),
        BackgroundTransparency = 1,
        Text = tabName,
        TextColor3 = Theme.TextDimmed,
        TextSize = Theme.TextSizeSmall,
        Font = Theme.Font,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = tabButton,
    })

    local activeIndicator = Utility.Create("Frame", {
        Name = "ActiveIndicator",
        Size = UDim2.new(0, 3, 0.6, 0),
        Position = UDim2.new(0, 0, 0.2, 0),
        BackgroundColor3 = Theme.Primary,
        BackgroundTransparency = 1,
        Parent = tabButton,
    })
    Utility.AddCorner(activeIndicator, UDim.new(0, 2))

    local contentPage = Utility.Create("ScrollingFrame", {
        Name = "TabContent_" .. tabName,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Visible = false,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.Primary,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Parent = self.ContentArea,
    })

    local contentLayout = Utility.AddListLayout(contentPage, 6)
    Utility.AddPadding(contentPage, 8, 8, 8, 8)

    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        contentPage.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 20)
    end)

    local tabData = {
        Button = tabButton,
        Content = contentPage,
        Label = tabLabel,
        Icon = iconLabel,
        Indicator = activeIndicator,
        Index = tabIndex,
        Name = tabName,
    }

    table.insert(self.Tabs, tabData)

    tabButton.MouseEnter:Connect(function()
        if self.ActiveTab ~= tabData then
            Utility.TweenFast(tabButton, {BackgroundColor3 = Theme.TabHover, BackgroundTransparency = 0.5})
        end
    end)
    tabButton.MouseLeave:Connect(function()
        if self.ActiveTab ~= tabData then
            Utility.TweenFast(tabButton, {BackgroundColor3 = Theme.TabInactive, BackgroundTransparency = 0.8})
        end
    end)

    tabButton.MouseButton1Click:Connect(function()
        self:SwitchTo(tabData)
    end)

    if tabIndex == 1 then
        self:SwitchTo(tabData)
    end

    local tabInterface = {}
    tabInterface.Name = tabName

    function tabInterface:CreateToggle(cfg)
        return CreateToggle(contentPage, cfg)
    end
    function tabInterface:CreateSlider(cfg)
        return CreateSlider(contentPage, cfg)
    end
    function tabInterface:CreateDropdown(cfg)
        return CreateDropdown(contentPage, cfg)
    end
    function tabInterface:CreateButton(cfg)
        return CreateButton(contentPage, cfg)
    end
    function tabInterface:CreateLabel(cfg)
        return CreateLabel(contentPage, cfg)
    end
    function tabInterface:CreateTextInput(cfg)
        return CreateTextInput(contentPage, cfg)
    end
    function tabInterface:CreateKeybind(cfg)
        return CreateKeybind(contentPage, cfg)
    end
    function tabInterface:CreateColorPicker(cfg)
        return CreateColorPicker(contentPage, cfg)
    end
    function tabInterface:CreateSection(cfg)
        return CreateSection(contentPage, cfg)
    end

    return tabInterface
end

function TabSystem:SwitchTo(tabData)
    if self.ActiveTab == tabData then return end

    if self.ActiveTab then
        local prev = self.ActiveTab
        Utility.Tween(prev.Button, {BackgroundColor3 = Theme.TabInactive, BackgroundTransparency = 0.8})
        Utility.Tween(prev.Label, {TextColor3 = Theme.TextDimmed})
        Utility.Tween(prev.Icon, {TextColor3 = Theme.TextDimmed})
        Utility.Tween(prev.Indicator, {BackgroundTransparency = 1})
        prev.Content.Visible = false
    end

    self.ActiveTab = tabData
    Utility.Tween(tabData.Button, {BackgroundColor3 = Theme.TabActive, BackgroundTransparency = 0.7})
    Utility.Tween(tabData.Label, {TextColor3 = Theme.TextPrimary})
    Utility.Tween(tabData.Icon, {TextColor3 = Theme.Primary})
    Utility.Tween(tabData.Indicator, {BackgroundTransparency = 0})
    tabData.Content.Visible = true
end

-- ══════════════════════════════════════════════════════════════
-- WINDOW SYSTEM
-- ══════════════════════════════════════════════════════════════

local WindowSystem = {}
WindowSystem.__index = WindowSystem

function WindowSystem.new(screenGui, config, notificationSystem)
    local self = setmetatable({}, WindowSystem)

    self.ScreenGui = screenGui
    self.NotificationSystem = notificationSystem
    self.Visible = true
    self.Minimized = false
    self.ToggleKey = config.ToggleKey or Enum.KeyCode.RightShift

    local windowSize = config.Size or UDim2.new(0, 520, 0, 380)
    local windowPos = config.Position or UDim2.new(0.5, -260, 0.5, -190)

    if Utility.IsMobile() then
        windowSize = UDim2.new(0.92, 0, 0.7, 0)
        windowPos = UDim2.new(0.04, 0, 0.15, 0)
    end

    self.MainFrame = Utility.Create("Frame", {
        Name = "SamsUIWindow",
        Size = windowSize,
        Position = windowPos,
        BackgroundColor3 = Theme.WindowBackground,
        ClipsDescendants = true,
        Parent = screenGui,
    })
    Utility.AddCorner(self.MainFrame, Theme.CornerRadiusLarge)
    Utility.AddStroke(self.MainFrame, Theme.PrimaryDark, 1.5, 0.3)

    pcall(function()
        Utility.Create("ImageLabel", {
            Name = "Shadow",
            Size = UDim2.new(1, 30, 1, 30),
            Position = UDim2.new(0, -15, 0, -15),
            BackgroundTransparency = 1,
            Image = "rbxassetid://5554236805",
            ImageColor3 = Theme.Shadow,
            ImageTransparency = 0.4,
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(23, 23, 277, 277),
            ZIndex = 0,
            Parent = self.MainFrame,
        })
    end)

    self.TitleBar = Utility.Create("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Theme.TitleBar,
        Parent = self.MainFrame,
    })
    Utility.AddCorner(self.TitleBar, Theme.CornerRadiusLarge)

    Utility.Create("Frame", {
        Name = "BottomCover",
        Size = UDim2.new(1, 0, 0, 14),
        Position = UDim2.new(0, 0, 1, -14),
        BackgroundColor3 = Theme.TitleBar,
        Parent = self.TitleBar,
    })

    local heartDecor = CreateHeartIcon(self.TitleBar, 18, Theme.Primary)
    heartDecor.Position = UDim2.new(0, 12, 0.5, -9)

    Utility.Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(0.6, -40, 1, 0),
        Position = UDim2.new(0, 36, 0, 0),
        BackgroundTransparency = 1,
        Text = config.Title or "Sam's UI",
        TextColor3 = Theme.TextPrimary,
        TextSize = Theme.TextSizeTitle,
        Font = Theme.FontBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.TitleBar,
    })

    Utility.Create("TextLabel", {
        Name = "Edition",
        Size = UDim2.new(0, 80, 0, 14),
        Position = UDim2.new(0, 36, 0, 24),
        BackgroundTransparency = 1,
        Text = "<3 Love Edition",
        TextColor3 = Theme.Accent,
        TextSize = 9,
        Font = Theme.FontMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.TitleBar,
    })

    local minimizeBtn = Utility.Create("TextButton", {
        Name = "MinimizeBtn",
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -68, 0.5, -15),
        BackgroundColor3 = Theme.ElementBackground,
        BackgroundTransparency = 0.5,
        Text = "-",
        TextColor3 = Theme.TextSecondary,
        TextSize = 18,
        Font = Theme.FontBold,
        AutoButtonColor = false,
        Parent = self.TitleBar,
    })
    Utility.AddCorner(minimizeBtn, UDim.new(0, 6))

    minimizeBtn.MouseEnter:Connect(function()
        Utility.TweenFast(minimizeBtn, {BackgroundTransparency = 0, BackgroundColor3 = Theme.Accent})
    end)
    minimizeBtn.MouseLeave:Connect(function()
        Utility.TweenFast(minimizeBtn, {BackgroundTransparency = 0.5, BackgroundColor3 = Theme.ElementBackground})
    end)

    local closeBtn = Utility.Create("TextButton", {
        Name = "CloseBtn",
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -34, 0.5, -15),
        BackgroundColor3 = Theme.ElementBackground,
        BackgroundTransparency = 0.5,
        Text = "X",
        TextColor3 = Theme.TextSecondary,
        TextSize = 12,
        Font = Theme.FontBold,
        AutoButtonColor = false,
        Parent = self.TitleBar,
    })
    Utility.AddCorner(closeBtn, UDim.new(0, 6))

    closeBtn.MouseEnter:Connect(function()
        Utility.TweenFast(closeBtn, {BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(200, 60, 60)})
    end)
    closeBtn.MouseLeave:Connect(function()
        Utility.TweenFast(closeBtn, {BackgroundTransparency = 0.5, BackgroundColor3 = Theme.ElementBackground})
    end)

    Utility.MakeDraggable(self.TitleBar, self.MainFrame)

    local bodyContainer = Utility.Create("Frame", {
        Name = "Body",
        Size = UDim2.new(1, 0, 1, -40),
        Position = UDim2.new(0, 0, 0, 40),
        BackgroundTransparency = 1,
        Parent = self.MainFrame,
    })

    local tabBarWidth = 150
    if Utility.IsMobile() then tabBarWidth = 120 end

    local tabBar = Utility.Create("Frame", {
        Name = "TabBar",
        Size = UDim2.new(0, tabBarWidth, 1, -8),
        Position = UDim2.new(0, 4, 0, 4),
        BackgroundColor3 = Theme.TabBar,
        Parent = bodyContainer,
    })
    Utility.AddCorner(tabBar, Theme.CornerRadiusSmall)
    Utility.AddListLayout(tabBar, 4)
    Utility.AddPadding(tabBar, 6, 6, 4, 4)

    local contentArea = Utility.Create("Frame", {
        Name = "ContentArea",
        Size = UDim2.new(1, -(tabBarWidth + 12), 1, -8),
        Position = UDim2.new(0, tabBarWidth + 8, 0, 4),
        BackgroundTransparency = 1,
        Parent = bodyContainer,
    })

    self.TabSystem = TabSystem.new(tabBar, contentArea)

    self.MinimizedIcon = Utility.Create("TextButton", {
        Name = "MinimizedIcon",
        Size = UDim2.new(0, 48, 0, 48),
        Position = UDim2.new(0.5, -24, 0, 20),
        BackgroundColor3 = Theme.PrimaryDark,
        Text = "<3",
        TextColor3 = Theme.TextPrimary,
        TextSize = 18,
        Font = Theme.FontBold,
        AutoButtonColor = false,
        Visible = false,
        ZIndex = 90,
        Parent = screenGui,
    })
    Utility.AddCorner(self.MinimizedIcon, UDim.new(1, 0))
    Utility.AddStroke(self.MinimizedIcon, Theme.Primary, 2, 0.3)
    Utility.MakeDraggable(self.MinimizedIcon, self.MinimizedIcon)

    minimizeBtn.MouseButton1Click:Connect(function()
        self:Minimize()
    end)

    self.MinimizedIcon.MouseButton1Click:Connect(function()
        self:Restore()
    end)

    closeBtn.MouseButton1Click:Connect(function()
        self:Destroy()
    end)

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == self.ToggleKey then
            self:Toggle()
        end
    end)

    if Utility.IsMobile() then
        local mobileToggle = Utility.Create("TextButton", {
            Name = "MobileToggle",
            Size = UDim2.new(0, 40, 0, 40),
            Position = UDim2.new(1, -50, 0, 10),
            BackgroundColor3 = Theme.PrimaryDark,
            BackgroundTransparency = 0.3,
            Text = "<3",
            TextColor3 = Theme.TextPrimary,
            TextSize = 14,
            Font = Theme.FontBold,
            AutoButtonColor = false,
            ZIndex = 99,
            Parent = screenGui,
        })
        Utility.AddCorner(mobileToggle, UDim.new(1, 0))
        Utility.MakeDraggable(mobileToggle, mobileToggle)

        mobileToggle.MouseButton1Click:Connect(function()
            self:Toggle()
        end)
    end

    return self
end

function WindowSystem:Minimize()
    self.Minimized = true
    Utility.Tween(self.MainFrame, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}, 0.3)
    task.delay(0.3, function()
        self.MainFrame.Visible = false
        self.MinimizedIcon.Visible = true
        Utility.Tween(self.MinimizedIcon, {Size = UDim2.new(0, 48, 0, 48)}, 0.2, Enum.EasingStyle.Back)
    end)
end

function WindowSystem:Restore()
    self.Minimized = false
    self.MinimizedIcon.Visible = false
    self.MainFrame.Visible = true
    self.MainFrame.BackgroundTransparency = 0

    local targetSize = UDim2.new(0, 520, 0, 380)
    if Utility.IsMobile() then targetSize = UDim2.new(0.92, 0, 0.7, 0) end
    Utility.Tween(self.MainFrame, {Size = targetSize, BackgroundTransparency = 0}, 0.3, Enum.EasingStyle.Back)
end

function WindowSystem:Toggle()
    self.Visible = not self.Visible
    if self.Visible then
        if self.Minimized then
            self:Restore()
        else
            self.MainFrame.Visible = true
            Utility.Tween(self.MainFrame, {BackgroundTransparency = 0}, 0.2)
            for _, desc in pairs(self.MainFrame:GetDescendants()) do
                if desc:IsA("GuiObject") and desc.Name ~= "Shadow" then
                    if desc:IsA("TextLabel") or desc:IsA("TextButton") or desc:IsA("TextBox") then
                        Utility.TweenFast(desc, {TextTransparency = 0})
                    end
                end
            end
        end
    else
        Utility.Tween(self.MainFrame, {BackgroundTransparency = 1}, 0.2)
        for _, desc in pairs(self.MainFrame:GetDescendants()) do
            if desc:IsA("GuiObject") then
                if desc:IsA("TextLabel") or desc:IsA("TextButton") or desc:IsA("TextBox") then
                    Utility.TweenFast(desc, {TextTransparency = 1})
                end
            end
        end
        task.delay(0.25, function()
            if not self.Visible then
                self.MainFrame.Visible = false
            end
        end)
    end
end

function WindowSystem:CreateTab(config)
    return self.TabSystem:CreateTab(config)
end

function WindowSystem:Notify(config)
    if self.NotificationSystem then
        self.NotificationSystem:Notify(config)
    end
end

function WindowSystem:Destroy()
    Utility.Tween(self.MainFrame, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    task.delay(0.5, function()
        self.ScreenGui:Destroy()
    end)
end

-- ══════════════════════════════════════════════════════════════
-- LIBRARY CORE
-- ══════════════════════════════════════════════════════════════

local SamsUI = {}
SamsUI.__index = SamsUI
SamsUI.Version = "1.1.0"
SamsUI.Name = "Sam's UI - Love Edition"

function SamsUI:CreateWindow(config)
    config = config or {}

    local screenGui = Utility.Create("ScreenGui", {
        Name = "SamsUI_LoveEdition",
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
    })

    Utility.ProtectGui(screenGui)

    local notifSystem = NotificationSystem.new(screenGui)

    local showLoading = true
    if config.LoadingEnabled == false then
        showLoading = false
    end

    if showLoading then
        ShowLoadingScreen(screenGui, config.Title or "Sam's UI")
    end

    local window = WindowSystem.new(screenGui, config, notifSystem)

    if showLoading then
        window.MainFrame.BackgroundTransparency = 1
        Utility.Tween(window.MainFrame, {BackgroundTransparency = 0}, 0.4)
    end

    return window
end

function SamsUI:GetTheme()
    return Theme
end

function SamsUI:SetTheme(overrides)
    for key, value in pairs(overrides) do
        if Theme[key] ~= nil then
            Theme[key] = value
        end
    end
end

return SamsUI
