--[[
    ╔══════════════════════════════════════════════════════════════════════════════╗
    ║                                                                              ║
    ║   ███╗   ██╗██████╗ ███████╗██╗  ██╗████████╗     ██╗  ██╗██╗   ██╗██████╗   ║
    ║   ████╗  ██║██╔══██╗██╔════╝╚██╗██╔╝╚══██╔══╝     ██║  ██║██║   ██║██╔══██╗  ║
    ║   ██╔██╗ ██║██████╔╝█████╗   ╚███╔╝    ██║        ███████║██║   ██║██████╔╝  ║
    ║   ██║╚██╗██║██╔══██╗██╔══╝   ██╔██╗    ██║        ██╔══██║██║   ██║██╔══██╗  ║
    ║   ██║ ╚████║██║  ██║███████╗██╔╝ ██╗   ██║        ██║  ██║╚██████╔╝██████╔╝  ║
    ║   ╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝   ╚═╝        ╚═╝  ╚═╝ ╚═════╝ ╚═════╝   ║
    ║                                                                              ║
    ║                    X R E Z T   H U B   —   P R E M I U M                     ║
    ║                         U I   L I B R A R Y   F R A M E W O R K              ║
    ║                                                                              ║
    ║   A Production-Grade Roblox UI Framework                                     ║
    ║   Glassmorphism • Smooth Animations • Responsive • Professional              ║
    ║                                                                              ║
    ╚══════════════════════════════════════════════════════════════════════════════╝
]]

local XreztHub = {}
XreztHub.__index = XreztHub

-- ═══════════════════════════════════════════════════════════════════════════════
-- SERVICES & UTILITIES
-- ═══════════════════════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Utility Functions
local function Create(className, properties)
    local instance = Instance.new(className)
    for prop, value in pairs(properties or {}) do
        instance[prop] = value
    end
    return instance
end

local function Tween(instance, properties, duration, easingStyle, easingDirection, callback)
    local tween = TweenService:Create(instance, TweenInfo.new(
        duration or 0.3,
        easingStyle or Enum.EasingStyle.Quart,
        easingDirection or Enum.EasingDirection.Out
    ), properties)
    if callback then
        tween.Completed:Connect(callback)
    end
    tween:Play()
    return tween
end

local function Round(num, decimals)
    local mult = 10 ^ (decimals or 0)
    return math.floor(num * mult + 0.5) / mult
end

local function Clamp(value, min, max)
    return math.max(min, math.min(max, value))
end

local function Lerp(a, b, t)
    return a + (b - a) * t
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- THEME ENGINE
-- ═══════════════════════════════════════════════════════════════════════════════

local Themes = {
    ["Midnight Slate"] = {
        Background = Color3.fromRGB(15, 17, 24),
        Surface = Color3.fromRGB(25, 28, 38),
        SurfaceHover = Color3.fromRGB(35, 39, 52),
        Primary = Color3.fromRGB(99, 102, 241),
        PrimaryHover = Color3.fromRGB(129, 132, 255),
        Secondary = Color3.fromRGB(139, 92, 246),
        Accent = Color3.fromRGB(56, 189, 248),
        TextPrimary = Color3.fromRGB(243, 244, 246),
        TextSecondary = Color3.fromRGB(156, 163, 175),
        TextMuted = Color3.fromRGB(107, 114, 128),
        Success = Color3.fromRGB(34, 197, 94),
        Error = Color3.fromRGB(239, 68, 68),
        Warning = Color3.fromRGB(245, 158, 11),
        Info = Color3.fromRGB(59, 130, 246),
        Border = Color3.fromRGB(55, 65, 81),
        Shadow = Color3.fromRGB(0, 0, 0),
        GradientStart = Color3.fromRGB(99, 102, 241),
        GradientEnd = Color3.fromRGB(139, 92, 246),
    },
    ["Ocean Blue"] = {
        Background = Color3.fromRGB(12, 20, 35),
        Surface = Color3.fromRGB(20, 35, 60),
        SurfaceHover = Color3.fromRGB(30, 50, 85),
        Primary = Color3.fromRGB(14, 165, 233),
        PrimaryHover = Color3.fromRGB(56, 189, 248),
        Secondary = Color3.fromRGB(6, 182, 212),
        Accent = Color3.fromRGB(45, 212, 191),
        TextPrimary = Color3.fromRGB(240, 249, 255),
        TextSecondary = Color3.fromRGB(125, 211, 252),
        TextMuted = Color3.fromRGB(56, 189, 248),
        Success = Color3.fromRGB(45, 212, 191),
        Error = Color3.fromRGB(248, 113, 113),
        Warning = Color3.fromRGB(251, 191, 36),
        Info = Color3.fromRGB(96, 165, 250),
        Border = Color3.fromRGB(30, 58, 95),
        Shadow = Color3.fromRGB(0, 0, 0),
        GradientStart = Color3.fromRGB(14, 165, 233),
        GradientEnd = Color3.fromRGB(6, 182, 212),
    },
    ["Aurora"] = {
        Background = Color3.fromRGB(17, 24, 28),
        Surface = Color3.fromRGB(28, 38, 45),
        SurfaceHover = Color3.fromRGB(40, 55, 65),
        Primary = Color3.fromRGB(232, 121, 249),
        PrimaryHover = Color3.fromRGB(240, 171, 252),
        Secondary = Color3.fromRGB(167, 139, 250),
        Accent = Color3.fromRGB(103, 232, 249),
        TextPrimary = Color3.fromRGB(250, 245, 255),
        TextSecondary = Color3.fromRGB(216, 180, 254),
        TextMuted = Color3.fromRGB(168, 85, 247),
        Success = Color3.fromRGB(134, 239, 172),
        Error = Color3.fromRGB(252, 165, 165),
        Warning = Color3.fromRGB(253, 186, 116),
        Info = Color3.fromRGB(147, 197, 253),
        Border = Color3.fromRGB(55, 65, 81),
        Shadow = Color3.fromRGB(0, 0, 0),
        GradientStart = Color3.fromRGB(232, 121, 249),
        GradientEnd = Color3.fromRGB(103, 232, 249),
    },
    ["Sunset"] = {
        Background = Color3.fromRGB(28, 25, 23),
        Surface = Color3.fromRGB(41, 37, 36),
        SurfaceHover = Color3.fromRGB(60, 54, 52),
        Primary = Color3.fromRGB(251, 146, 60),
        PrimaryHover = Color3.fromRGB(253, 186, 116),
        Secondary = Color3.fromRGB(244, 63, 94),
        Accent = Color3.fromRGB(250, 204, 21),
        TextPrimary = Color3.fromRGB(255, 247, 237),
        TextSecondary = Color3.fromRGB(254, 215, 170),
        TextMuted = Color3.fromRGB(251, 146, 60),
        Success = Color3.fromRGB(52, 211, 153),
        Error = Color3.fromRGB(252, 165, 165),
        Warning = Color3.fromRGB(253, 224, 71),
        Info = Color3.fromRGB(147, 197, 253),
        Border = Color3.fromRGB(68, 64, 60),
        Shadow = Color3.fromRGB(0, 0, 0),
        GradientStart = Color3.fromRGB(251, 146, 60),
        GradientEnd = Color3.fromRGB(244, 63, 94),
    },
    ["Emerald"] = {
        Background = Color3.fromRGB(6, 26, 18),
        Surface = Color3.fromRGB(10, 40, 28),
        SurfaceHover = Color3.fromRGB(16, 60, 42),
        Primary = Color3.fromRGB(16, 185, 129),
        PrimaryHover = Color3.fromRGB(52, 211, 153),
        Secondary = Color3.fromRGB(20, 184, 166),
        Accent = Color3.fromRGB(132, 204, 22),
        TextPrimary = Color3.fromRGB(236, 253, 245),
        TextSecondary = Color3.fromRGB(167, 243, 208),
        TextMuted = Color3.fromRGB(52, 211, 153),
        Success = Color3.fromRGB(34, 197, 94),
        Error = Color3.fromRGB(252, 165, 165),
        Warning = Color3.fromRGB(253, 224, 71),
        Info = Color3.fromRGB(147, 197, 253),
        Border = Color3.fromRGB(20, 83, 45),
        Shadow = Color3.fromRGB(0, 0, 0),
        GradientStart = Color3.fromRGB(16, 185, 129),
        GradientEnd = Color3.fromRGB(20, 184, 166),
    },
    ["Rose"] = {
        Background = Color3.fromRGB(28, 20, 23),
        Surface = Color3.fromRGB(40, 28, 33),
        SurfaceHover = Color3.fromRGB(58, 42, 48),
        Primary = Color3.fromRGB(244, 63, 94),
        PrimaryHover = Color3.fromRGB(251, 113, 133),
        Secondary = Color3.fromRGB(217, 70, 239),
        Accent = Color3.fromRGB(251, 146, 60),
        TextPrimary = Color3.fromRGB(255, 241, 242),
        TextSecondary = Color3.fromRGB(254, 205, 211),
        TextMuted = Color3.fromRGB(244, 63, 94),
        Success = Color3.fromRGB(52, 211, 153),
        Error = Color3.fromRGB(252, 165, 165),
        Warning = Color3.fromRGB(253, 224, 71),
        Info = Color3.fromRGB(147, 197, 253),
        Border = Color3.fromRGB(68, 48, 55),
        Shadow = Color3.fromRGB(0, 0, 0),
        GradientStart = Color3.fromRGB(244, 63, 94),
        GradientEnd = Color3.fromRGB(217, 70, 239),
    },
    ["Graphite"] = {
        Background = Color3.fromRGB(23, 23, 23),
        Surface = Color3.fromRGB(38, 38, 38),
        SurfaceHover = Color3.fromRGB(52, 52, 52),
        Primary = Color3.fromRGB(163, 163, 163),
        PrimaryHover = Color3.fromRGB(212, 212, 212),
        Secondary = Color3.fromRGB(115, 115, 115),
        Accent = Color3.fromRGB(212, 212, 212),
        TextPrimary = Color3.fromRGB(250, 250, 250),
        TextSecondary = Color3.fromRGB(163, 163, 163),
        TextMuted = Color3.fromRGB(115, 115, 115),
        Success = Color3.fromRGB(74, 222, 128),
        Error = Color3.fromRGB(248, 113, 113),
        Warning = Color3.fromRGB(250, 204, 21),
        Info = Color3.fromRGB(96, 165, 250),
        Border = Color3.fromRGB(64, 64, 64),
        Shadow = Color3.fromRGB(0, 0, 0),
        GradientStart = Color3.fromRGB(163, 163, 163),
        GradientEnd = Color3.fromRGB(115, 115, 115),
    },
    ["Obsidian"] = {
        Background = Color3.fromRGB(8, 8, 10),
        Surface = Color3.fromRGB(16, 16, 20),
        SurfaceHover = Color3.fromRGB(24, 24, 30),
        Primary = Color3.fromRGB(220, 38, 38),
        PrimaryHover = Color3.fromRGB(248, 113, 113),
        Secondary = Color3.fromRGB(153, 27, 27),
        Accent = Color3.fromRGB(239, 68, 68),
        TextPrimary = Color3.fromRGB(254, 242, 242),
        TextSecondary = Color3.fromRGB(254, 202, 202),
        TextMuted = Color3.fromRGB(220, 38, 38),
        Success = Color3.fromRGB(74, 222, 128),
        Error = Color3.fromRGB(248, 113, 113),
        Warning = Color3.fromRGB(250, 204, 21),
        Info = Color3.fromRGB(96, 165, 250),
        Border = Color3.fromRGB(60, 20, 20),
        Shadow = Color3.fromRGB(0, 0, 0),
        GradientStart = Color3.fromRGB(220, 38, 38),
        GradientEnd = Color3.fromRGB(153, 27, 27),
    },
    ["Crystal"] = {
        Background = Color3.fromRGB(248, 250, 252),
        Surface = Color3.fromRGB(255, 255, 255),
        SurfaceHover = Color3.fromRGB(241, 245, 249),
        Primary = Color3.fromRGB(59, 130, 246),
        PrimaryHover = Color3.fromRGB(96, 165, 250),
        Secondary = Color3.fromRGB(139, 92, 246),
        Accent = Color3.fromRGB(14, 165, 233),
        TextPrimary = Color3.fromRGB(15, 23, 42),
        TextSecondary = Color3.fromRGB(71, 85, 105),
        TextMuted = Color3.fromRGB(148, 163, 184),
        Success = Color3.fromRGB(34, 197, 94),
        Error = Color3.fromRGB(239, 68, 68),
        Warning = Color3.fromRGB(245, 158, 11),
        Info = Color3.fromRGB(59, 130, 246),
        Border = Color3.fromRGB(226, 232, 240),
        Shadow = Color3.fromRGB(148, 163, 184),
        GradientStart = Color3.fromRGB(59, 130, 246),
        GradientEnd = Color3.fromRGB(139, 92, 246),
    },
    ["Frost"] = {
        Background = Color3.fromRGB(236, 245, 255),
        Surface = Color3.fromRGB(255, 255, 255),
        SurfaceHover = Color3.fromRGB(224, 242, 254),
        Primary = Color3.fromRGB(14, 165, 233),
        PrimaryHover = Color3.fromRGB(56, 189, 248),
        Secondary = Color3.fromRGB(99, 102, 241),
        Accent = Color3.fromRGB(45, 212, 191),
        TextPrimary = Color3.fromRGB(15, 23, 42),
        TextSecondary = Color3.fromRGB(71, 85, 105),
        TextMuted = Color3.fromRGB(148, 163, 184),
        Success = Color3.fromRGB(34, 197, 94),
        Error = Color3.fromRGB(239, 68, 68),
        Warning = Color3.fromRGB(245, 158, 11),
        Info = Color3.fromRGB(59, 130, 246),
        Border = Color3.fromRGB(203, 213, 225),
        Shadow = Color3.fromRGB(148, 163, 184),
        GradientStart = Color3.fromRGB(14, 165, 233),
        GradientEnd = Color3.fromRGB(99, 102, 241),
    }
}

local CurrentTheme = Themes["Midnight Slate"]

-- ═══════════════════════════════════════════════════════════════════════════════
-- SOUND SYSTEM
-- ═══════════════════════════════════════════════════════════════════════════════

local SoundEffects = {
    Hover = "rbxassetid://9114488953",
    Click = "rbxassetid://9114489631",
    Toggle = "rbxassetid://9114490526",
    Success = "rbxassetid://9114491307",
    Error = "rbxassetid://9114492194",
    Open = "rbxassetid://9114492983",
    Close = "rbxassetid://9114493801"
}

local function PlaySound(soundId, volume)
    local sound = Create("Sound", {
        SoundId = soundId,
        Volume = volume or 0.3,
        Parent = CoreGui
    })
    sound:Play()
    task.delay(sound.TimeLength + 0.1, function()
        sound:Destroy()
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- NOTIFICATION SYSTEM
-- ═══════════════════════════════════════════════════════════════════════════════

local NotificationQueue = {}
local ActiveNotifications = {}
local MaxNotifications = 5

local NotificationStyles = {
    Success = { Icon = "✓", Color = CurrentTheme.Success },
    Error = { Icon = "✕", Color = CurrentTheme.Error },
    Warning = { Icon = "!", Color = CurrentTheme.Warning },
    Info = { Icon = "i", Color = CurrentTheme.Info }
}

function XreztHub:Notify(options)
    options = options or {}
    local style = options.Style or "Info"
    local title = options.Title or "Notification"
    local message = options.Message or ""
    local duration = options.Duration or 4
    
    table.insert(NotificationQueue, {
        Style = style,
        Title = title,
        Message = message,
        Duration = duration
    })
    
    self:ProcessNotificationQueue()
end

function XreztHub:ProcessNotificationQueue()
    while #NotificationQueue > 0 and #ActiveNotifications < MaxNotifications do
        local data = table.remove(NotificationQueue, 1)
        self:CreateNotification(data)
    end
end

function XreztHub:CreateNotification(data)
    local styleData = NotificationStyles[data.Style] or NotificationStyles.Info
    
    local notifContainer = self.NotificationContainer or Create("ScreenGui", {
        Name = "XreztNotifications",
        Parent = CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })
    self.NotificationContainer = notifContainer
    
    local notifFrame = Create("Frame", {
        Name = "Notification",
        Size = UDim2.new(0, 320, 0, 80),
        Position = UDim2.new(1, 20, 0, 20 + (#ActiveNotifications * 95)),
        BackgroundColor3 = CurrentTheme.Surface,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = notifContainer
    })
    
    local corner = Create("UICorner", {
        CornerRadius = UDim.new(0, 16),
        Parent = notifFrame
    })
    
    local stroke = Create("UIStroke", {
        Color = CurrentTheme.Border,
        Thickness = 1,
        Transparency = 0.5,
        Parent = notifFrame
    })
    
    local shadow = Create("ImageLabel", {
        Name = "Shadow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 4),
        Size = UDim2.new(1, 20, 1, 20),
        BackgroundTransparency = 1,
        Image = "rbxassetid://1316045217",
        ImageColor3 = CurrentTheme.Shadow,
        ImageTransparency = 0.6,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(10, 10, 118, 118),
        ZIndex = -1,
        Parent = notifFrame
    })
    
    local iconFrame = Create("Frame", {
        Name = "IconFrame",
        Size = UDim2.new(0, 44, 0, 44),
        Position = UDim2.new(0, 16, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = styleData.Color,
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        Parent = notifFrame
    })
    
    local iconCorner = Create("UICorner", {
        CornerRadius = UDim.new(0, 12),
        Parent = iconFrame
    })
    
    local iconLabel = Create("TextLabel", {
        Name = "Icon",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = styleData.Icon,
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        Parent = iconFrame
    })
    
    local titleLabel = Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, -80, 0, 22),
        Position = UDim2.new(0, 72, 0, 14),
        BackgroundTransparency = 1,
        Text = data.Title,
        TextColor3 = CurrentTheme.TextPrimary,
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = notifFrame
    })
    
    local messageLabel = Create("TextLabel", {
        Name = "Message",
        Size = UDim2.new(1, -80, 0, 36),
        Position = UDim2.new(0, 72, 0, 36),
        BackgroundTransparency = 1,
        Text = data.Message,
        TextColor3 = CurrentTheme.TextSecondary,
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        Parent = notifFrame
    })
    
    local progressBar = Create("Frame", {
        Name = "ProgressBar",
        Size = UDim2.new(1, 0, 0, 3),
        Position = UDim2.new(0, 0, 1, -3),
        BackgroundColor3 = styleData.Color,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Parent = notifFrame
    })
    
    table.insert(ActiveNotifications, notifFrame)
    
    -- Animate in
    Tween(notifFrame, { Position = UDim2.new(1, -340, 0, notifFrame.Position.Y.Offset) }, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    
    -- Progress bar animation
    Tween(progressBar, { Size = UDim2.new(0, 0, 0, 3) }, data.Duration, Enum.EasingStyle.Linear)
    
    -- Auto dismiss
    task.delay(data.Duration, function()
        self:DismissNotification(notifFrame)
    end)
    
    -- Click to dismiss
    notifFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self:DismissNotification(notifFrame)
        end
    end)
end

function XreztHub:DismissNotification(frame)
    for i, notif in ipairs(ActiveNotifications) do
        if notif == frame then
            table.remove(ActiveNotifications, i)
            break
        end
    end
    
    Tween(frame, { Position = UDim2.new(1, 20, 0, frame.Position.Y.Offset), BackgroundTransparency = 1 }, 0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In, function()
        frame:Destroy()
    end)
    
    -- Reposition remaining notifications
    task.delay(0.1, function()
        for i, notif in ipairs(ActiveNotifications) do
            Tween(notif, { Position = UDim2.new(1, -340, 0, 20 + ((i - 1) * 95)) }, 0.3, Enum.EasingStyle.Quart)
        end
        self:ProcessNotificationQueue()
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- LOADING SCREEN
-- ═══════════════════════════════════════════════════════════════════════════════

function XreztHub:CreateLoadingScreen()
    local loadingGui = Create("ScreenGui", {
        Name = "XreztLoading",
        Parent = CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })
    
    local mainFrame = Create("Frame", {
        Name = "MainFrame",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = CurrentTheme.Background,
        BorderSizePixel = 0,
        Parent = loadingGui
    })
    
    -- Animated gradient background
    local gradientFrame = Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Parent = mainFrame
    })
    
    local gradient = Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, CurrentTheme.GradientStart),
            ColorSequenceKeypoint.new(0.5, CurrentTheme.GradientEnd),
            ColorSequenceKeypoint.new(1, CurrentTheme.GradientStart)
        }),
        Rotation = 45,
        Parent = gradientFrame
    })
    
    -- X Shape Logo Container
    local logoContainer = Create("Frame", {
        Name = "LogoContainer",
        Size = UDim2.new(0, 200, 0, 200),
        Position = UDim2.new(0.5, 0, 0.4, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Parent = mainFrame
    })
    
    -- X Shape using two rotated frames
    local xLeft = Create("Frame", {
        Name = "XLeft",
        Size = UDim2.new(0, 20, 0, 120),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = CurrentTheme.Primary,
        BorderSizePixel = 0,
        Rotation = 45,
        Parent = logoContainer
    })
    
    local xRight = Create("Frame", {
        Name = "XRight",
        Size = UDim2.new(0, 20, 0, 120),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = CurrentTheme.Secondary,
        BorderSizePixel = 0,
        Rotation = -45,
        Parent = logoContainer
    })
    
    local xLeftCorner = Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = xLeft })
    local xRightCorner = Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = xRight })
    
    -- Floating particles
    local particles = {}
    for i = 1, 20 do
        local particle = Create("Frame", {
            Size = UDim2.new(0, math.random(4, 12), 0, math.random(4, 12)),
            Position = UDim2.new(math.random(), 0, math.random(), 0),
            BackgroundColor3 = math.random() > 0.5 and CurrentTheme.Primary or CurrentTheme.Secondary,
            BackgroundTransparency = math.random(0.3, 0.7),
            BorderSizePixel = 0,
            Parent = mainFrame
        })
        local pCorner = Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = particle })
        table.insert(particles, {
            Frame = particle,
            SpeedX = (math.random() - 0.5) * 0.5,
            SpeedY = (math.random() - 0.5) * 0.5,
            BaseY = particle.Position.Y.Scale
        })
    end
    
    -- Logo text
    local logoText = Create("TextLabel", {
        Name = "LogoText",
        Size = UDim2.new(0, 300, 0, 50),
        Position = UDim2.new(0.5, 0, 0.55, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Text = "XREZT HUB",
        TextColor3 = CurrentTheme.TextPrimary,
        Font = Enum.Font.GothamBlack,
        TextSize = 42,
        Parent = mainFrame
    })
    
    local subtitleText = Create("TextLabel", {
        Name = "Subtitle",
        Size = UDim2.new(0, 300, 0, 24),
        Position = UDim2.new(0.5, 0, 0.6, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Text = "PREMIUM UI FRAMEWORK",
        TextColor3 = CurrentTheme.TextSecondary,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        Parent = mainFrame
    })
    
    -- Progress container
    local progressContainer = Create("Frame", {
        Name = "ProgressContainer",
        Size = UDim2.new(0, 300, 0, 6),
        Position = UDim2.new(0.5, 0, 0.68, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = CurrentTheme.Surface,
        BorderSizePixel = 0,
        Parent = mainFrame
    })
    
    local progressCorner = Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = progressContainer })
    
    local progressFill = Create("Frame", {
        Name = "ProgressFill",
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = CurrentTheme.Primary,
        BorderSizePixel = 0,
        Parent = progressContainer
    })
    
    local fillCorner = Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = progressFill })
    
    local progressGlow = Create("Frame", {
        Size = UDim2.new(0, 30, 1, 4),
        Position = UDim2.new(1, -15, 0, -2),
        BackgroundColor3 = CurrentTheme.Primary,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        Parent = progressFill
    })
    
    local glowCorner = Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = progressGlow })
    
    local percentText = Create("TextLabel", {
        Name = "Percent",
        Size = UDim2.new(0, 100, 0, 24),
        Position = UDim2.new(0.5, 0, 0.72, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Text = "0%",
        TextColor3 = CurrentTheme.TextPrimary,
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        Parent = mainFrame
    })
    
    local statusText = Create("TextLabel", {
        Name = "Status",
        Size = UDim2.new(0, 400, 0, 20),
        Position = UDim2.new(0.5, 0, 0.76, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Text = "Initializing...",
        TextColor3 = CurrentTheme.TextMuted,
        Font = Enum.Font.Gotham,
        TextSize = 13,
        Parent = mainFrame
    })
    
    -- Animation connections
    local rotation = 0
    local particleConnection = RunService.RenderStepped:Connect(function(dt)
        rotation = rotation + dt * 15
        gradient.Rotation = rotation
        
        for _, p in ipairs(particles) do
            local newX = p.Frame.Position.X.Scale + p.SpeedX * dt
            local newY = p.BaseY + math.sin(tick() * 2 + p.SpeedX * 10) * 0.05
            p.Frame.Position = UDim2.new(newX % 1, 0, newY, 0)
        end
    end)
    
    -- Logo pulse animation
    local logoPulse = true
    task.spawn(function()
        while logoPulse do
            Tween(xLeft, { Size = UDim2.new(0, 22, 0, 125) }, 1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            Tween(xRight, { Size = UDim2.new(0, 22, 0, 125) }, 1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(1)
            Tween(xLeft, { Size = UDim2.new(0, 20, 0, 120) }, 1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            Tween(xRight, { Size = UDim2.new(0, 20, 0, 120) }, 1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(1)
        end
    end)
    
    local loadingStates = {
        { Text = "Initializing core systems...", Progress = 0.1 },
        { Text = "Loading theme engine...", Progress = 0.25 },
        { Text = "Building component library...", Progress = 0.45 },
        { Text = "Configuring animations...", Progress = 0.65 },
        { Text = "Optimizing performance...", Progress = 0.8 },
        { Text = "Finalizing setup...", Progress = 0.95 },
        { Text = "Ready", Progress = 1 }
    }
    
    local function UpdateProgress(state)
        Tween(progressFill, { Size = UDim2.new(state.Progress, 0, 1, 0) }, 0.8, Enum.EasingStyle.Quart)
        percentText.Text = math.floor(state.Progress * 100) .. "%"
        statusText.Text = state.Text
    end
    
    return {
        Gui = loadingGui,
        UpdateProgress = UpdateProgress,
        States = loadingStates,
        Cleanup = function()
            logoPulse = false
            particleConnection:Disconnect()
            Tween(mainFrame, { BackgroundTransparency = 1 }, 0.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, function()
                loadingGui:Destroy()
            end)
        end
    }
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- TOGGLE BUTTON SPAWNER
-- ═══════════════════════════════════════════════════════════════════════════════

function XreztHub:CreateToggleButton()
    local toggleGui = Create("ScreenGui", {
        Name = "XreztToggle",
        Parent = CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })
    
    local toggleButton = Create("Frame", {
        Name = "ToggleButton",
        Size = UDim2.new(0, 56, 0, 56),
        Position = UDim2.new(0, 20, 0.5, 0),
        BackgroundColor3 = CurrentTheme.Surface,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        Parent = toggleGui
    })
    
    local corner = Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = toggleButton })
    
    local stroke = Create("UIStroke", {
        Color = CurrentTheme.Primary,
        Thickness = 2,
        Transparency = 0.3,
        Parent = toggleButton
    })
    
    local shadow = Create("ImageLabel", {
        Name = "Shadow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 4),
        Size = UDim2.new(1, 16, 1, 16),
        BackgroundTransparency = 1,
        Image = "rbxassetid://1316045217",
        ImageColor3 = CurrentTheme.Shadow,
        ImageTransparency = 0.7,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(10, 10, 118, 118),
        ZIndex = -1,
        Parent = toggleButton
    })
    
    local iconLabel = Create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "✕",
        TextColor3 = CurrentTheme.Primary,
        Font = Enum.Font.GothamBlack,
        TextSize = 24,
        Parent = toggleButton
    })
    
    -- Draggable functionality
    local dragging = false
    local dragStart, startPos
    
    toggleButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = toggleButton.Position
            
            Tween(toggleButton, { Size = UDim2.new(0, 52, 0, 52) }, 0.1)
            PlaySound(SoundEffects.Click)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            toggleButton.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            Tween(toggleButton, { Size = UDim2.new(0, 56, 0, 56) }, 0.2, Enum.EasingStyle.Back)
            
            -- Snap to edges
            local absPos = toggleButton.AbsolutePosition
            local screenSize = Camera.ViewportSize
            local targetX = absPos.X < screenSize.X / 2 and 20 or screenSize.X - 76
            local targetY = Clamp(absPos.Y, 20, screenSize.Y - 76)
            
            Tween(toggleButton, {
                Position = UDim2.new(0, targetX, 0, targetY)
            }, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        end
    end)
    
    -- Hover effects
    toggleButton.MouseEnter:Connect(function()
        Tween(toggleButton, { BackgroundTransparency = 0 }, 0.2)
        Tween(stroke, { Transparency = 0 }, 0.2)
        Tween(iconLabel, { TextColor3 = CurrentTheme.PrimaryHover }, 0.2)
    end)
    
    toggleButton.MouseLeave:Connect(function()
        Tween(toggleButton, { BackgroundTransparency = 0.1 }, 0.2)
        Tween(stroke, { Transparency = 0.3 }, 0.2)
        Tween(iconLabel, { TextColor3 = CurrentTheme.Primary }, 0.2)
    end)
    
    return {
        Button = toggleButton,
        Icon = iconLabel,
        Gui = toggleGui
    }
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- MAIN WINDOW
-- ═══════════════════════════════════════════════════════════════════════════════

function XreztHub:CreateWindow(options)
    options = options or {}
    local windowTitle = options.Title or "Xrezt Hub"
    local windowSubtitle = options.Subtitle or "Premium UI Framework"
    local size = options.Size or UDim2.new(0, 700, 0, 500)
    
    -- Show loading screen
    local loadingScreen = self:CreateLoadingScreen()
    
    for _, state in ipairs(loadingScreen.States) do
        loadingScreen.UpdateProgress(state)
        task.wait(0.4)
    end
    
    task.wait(0.5)
    loadingScreen.Cleanup()
    
    -- Create main UI
    local mainGui = Create("ScreenGui", {
        Name = "XreztHub",
        Parent = CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })
    
    self.MainGui = mainGui
    
    -- Main container with blur
    local mainContainer = Create("Frame", {
        Name = "MainContainer",
        Size = size,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = CurrentTheme.Background,
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = mainGui
    })
    
    local mainCorner = Create("UICorner", { CornerRadius = UDim.new(0, 24), Parent = mainContainer })
    
    local mainStroke = Create("UIStroke", {
        Color = CurrentTheme.Border,
        Thickness = 1,
        Transparency = 0.4,
        Parent = mainContainer
    })
    
    -- Shadow
    local mainShadow = Create("ImageLabel", {
        Name = "Shadow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 8),
        Size = UDim2.new(1, 40, 1, 40),
        BackgroundTransparency = 1,
        Image = "rbxassetid://1316045217",
        ImageColor3 = CurrentTheme.Shadow,
        ImageTransparency = 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(10, 10, 118, 118),
        ZIndex = -1,
        Parent = mainContainer
    })
    
    -- Background gradient accent
    local bgGradient = Create("Frame", {
        Name = "BgGradient",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Parent = mainContainer
    })
    
    local bgGradientEffect = Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, CurrentTheme.GradientStart),
            ColorSequenceKeypoint.new(0.5, Color3.new(0, 0, 0)),
            ColorSequenceKeypoint.new(1, CurrentTheme.GradientEnd)
        }),
        Rotation = 135,
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.97),
            NumberSequenceKeypoint.new(0.5, 1),
            NumberSequenceKeypoint.new(1, 0.97)
        }),
        Parent = bgGradient
    })
    
    -- Header
    local header = Create("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 64),
        BackgroundColor3 = CurrentTheme.Surface,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Parent = mainContainer
    })
    
    local headerCorner = Create("UICorner", { CornerRadius = UDim.new(0, 24), Parent = header })
    
    local headerBottomFix = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 24),
        Position = UDim2.new(0, 0, 1, -24),
        BackgroundColor3 = CurrentTheme.Surface,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Parent = header
    })
    
    -- Logo
    local logoFrame = Create("Frame", {
        Name = "Logo",
        Size = UDim2.new(0, 36, 0, 36),
        Position = UDim2.new(0, 20, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = CurrentTheme.Primary,
        BorderSizePixel = 0,
        Parent = header
    })
    
    local logoCorner = Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = logoFrame })
    
    local logoText = Create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "X",
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.GothamBlack,
        TextSize = 20,
        Parent = logoFrame
    })
    
    local titleLabel = Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(0, 200, 0, 22),
        Position = UDim2.new(0, 68, 0, 12),
        BackgroundTransparency = 1,
        Text = windowTitle,
        TextColor3 = CurrentTheme.TextPrimary,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = header
    })
    
    local subtitleLabel = Create("TextLabel", {
        Name = "Subtitle",
        Size = UDim2.new(0, 200, 0, 18),
        Position = UDim2.new(0, 68, 0, 34),
        BackgroundTransparency = 1,
        Text = windowSubtitle,
        TextColor3 = CurrentTheme.TextMuted,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = header
    })
    
    -- Header buttons
    local function CreateHeaderButton(name, icon, position)
        local btn = Create("TextButton", {
            Name = name,
            Size = UDim2.new(0, 36, 0, 36),
            Position = position,
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundColor3 = CurrentTheme.SurfaceHover,
            BackgroundTransparency = 1,
            Text = icon,
            TextColor3 = CurrentTheme.TextSecondary,
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            Parent = header
        })
        local btnCorner = Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = btn })
        
        btn.MouseEnter:Connect(function()
            Tween(btn, { BackgroundTransparency = 0.5, TextColor3 = CurrentTheme.TextPrimary }, 0.2)
        end)
        btn.MouseLeave:Connect(function()
            Tween(btn, { BackgroundTransparency = 1, TextColor3 = CurrentTheme.TextSecondary }, 0.2)
        end)
        
        return btn
    end
    
    local closeBtn = CreateHeaderButton("Close", "✕", UDim2.new(1, -16, 0.5, 0))
    local minimizeBtn = CreateHeaderButton("Minimize", "−", UDim2.new(1, -58, 0.5, 0))
    local settingsBtn = CreateHeaderButton("Settings", "⚙", UDim2.new(1, -100, 0.5, 0))
    local searchBtn = CreateHeaderButton("Search", "⌕", UDim2.new(1, -142, 0.5, 0))
    
    -- Tab container (left side)
    local tabContainer = Create("Frame", {
        Name = "TabContainer",
        Size = UDim2.new(0, 180, 1, -64),
        Position = UDim2.new(0, 0, 0, 64),
        BackgroundColor3 = CurrentTheme.Surface,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        Parent = mainContainer
    })
    
    local tabCorner = Create("UICorner", { CornerRadius = UDim.new(0, 0), Parent = tabContainer })
    
    local tabList = Create("ScrollingFrame", {
        Name = "TabList",
        Size = UDim2.new(1, -16, 1, -20),
        Position = UDim2.new(0, 8, 0, 10),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = CurrentTheme.Primary,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Parent = tabContainer
    })
    
    local tabListLayout = Create("UIListLayout", {
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = tabList
    })
    
    -- Content area
    local contentContainer = Create("Frame", {
        Name = "ContentContainer",
        Size = UDim2.new(1, -196, 1, -80),
        Position = UDim2.new(0, 188, 0, 72),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = mainContainer
    })
    
    -- Window management
    local isMinimized = false
    local isVisible = true
    
    closeBtn.MouseButton1Click:Connect(function()
        PlaySound(SoundEffects.Close)
        Tween(mainContainer, { Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1 }, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In, function()
            mainGui.Enabled = false
        end)
    end)
    
    minimizeBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then
            Tween(mainContainer, { Size = UDim2.new(0, 700, 0, 64) }, 0.4, Enum.EasingStyle.Back)
        else
            Tween(mainContainer, { Size = size }, 0.4, Enum.EasingStyle.Back)
        end
    end)
    
    -- Draggable header
    local dragging = false
    local dragStart, startPos
    
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainContainer.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainContainer.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    -- Tab management
    local tabs = {}
    local activeTab = nil
    
    local window = {
        Gui = mainGui,
        Container = mainContainer,
        Content = contentContainer,
        TabList = tabList,
        Tabs = tabs,
        ActiveTab = nil,
        ToggleButton = nil
    }
    
    -- Create toggle button
    local toggleData = self:CreateToggleButton()
    window.ToggleButton = toggleData.Button
    
    toggleData.Button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and not dragging then
            isVisible = not isVisible
            mainGui.Enabled = isVisible
            if isVisible then
                mainContainer.Size = UDim2.new(0, 0, 0, 0)
                mainContainer.BackgroundTransparency = 1
                mainGui.Enabled = true
                Tween(mainContainer, { Size = size, BackgroundTransparency = 0.15 }, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                PlaySound(SoundEffects.Open)
            else
                Tween(mainContainer, { Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1 }, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In, function()
                    mainGui.Enabled = false
                end)
                PlaySound(SoundEffects.Close)
            end
        end
    end)
    
    -- Animate in
    mainContainer.Size = UDim2.new(0, 0, 0, 0)
    mainContainer.BackgroundTransparency = 1
    Tween(mainContainer, { Size = size, BackgroundTransparency = 0.15 }, 0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    PlaySound(SoundEffects.Open)
    
    return window
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- TAB SYSTEM
-- ═══════════════════════════════════════════════════════════════════════════════

function XreztHub:CreateTab(window, options)
    options = options or {}
    local tabName = options.Name or "Tab"
    local tabIcon = options.Icon or "◆"
    
    local tabButton = Create("TextButton", {
        Name = tabName .. "Button",
        Size = UDim2.new(1, -8, 0, 42),
        BackgroundColor3 = CurrentTheme.SurfaceHover,
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        Parent = window.TabList
    })
    
    local tabCorner = Create("UICorner", { CornerRadius = UDim.new(0, 12), Parent = tabButton })
    
    local tabIndicator = Create("Frame", {
        Name = "Indicator",
        Size = UDim2.new(0, 3, 0, 0),
        Position = UDim2.new(0, 6, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = CurrentTheme.Primary,
        BorderSizePixel = 0,
        Parent = tabButton
    })
    
    local indicatorCorner = Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = tabIndicator })
    
    local iconLabel = Create("TextLabel", {
        Name = "Icon",
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(0, 12, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        Text = tabIcon,
        TextColor3 = CurrentTheme.TextMuted,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        Parent = tabButton
    })
    
    local nameLabel = Create("TextLabel", {
        Name = "Name",
        Size = UDim2.new(1, -52, 1, 0),
        Position = UDim2.new(0, 46, 0, 0),
        BackgroundTransparency = 1,
        Text = tabName,
        TextColor3 = CurrentTheme.TextSecondary,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = tabButton
    })
    
    -- Content frame
    local contentFrame = Create("ScrollingFrame", {
        Name = tabName .. "Content",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = CurrentTheme.Primary,
        ScrollBarImageTransparency = 0.7,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Visible = false,
        Parent = window.Content
    })
    
    local contentLayout = Create("UIListLayout", {
        Padding = UDim.new(0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = contentFrame
    })
    
    local contentPadding = Create("UIPadding", {
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        PaddingTop = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 8),
        Parent = contentFrame
    })
    
    -- Auto update canvas size
    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        contentFrame.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 16)
    end)
    
    -- Tab activation
    local function Activate()
        if window.ActiveTab == self then return end
        
        if window.ActiveTab then
            window.ActiveTab:Deactivate()
        end
        
        window.ActiveTab = self
        contentFrame.Visible = true
        
        Tween(tabButton, { BackgroundTransparency = 0.3 }, 0.3)
        Tween(tabIndicator, { Size = UDim2.new(0, 3, 0, 20) }, 0.3, Enum.EasingStyle.Back)
        Tween(iconLabel, { TextColor3 = CurrentTheme.Primary }, 0.3)
        Tween(nameLabel, { TextColor3 = CurrentTheme.TextPrimary }, 0.3)
        
        Tween(contentFrame, { CanvasPosition = Vector2.new(0, 0) }, 0)
    end
    
    local function Deactivate()
        contentFrame.Visible = false
        Tween(tabButton, { BackgroundTransparency = 1 }, 0.3)
        Tween(tabIndicator, { Size = UDim2.new(0, 3, 0, 0) }, 0.3)
        Tween(iconLabel, { TextColor3 = CurrentTheme.TextMuted }, 0.3)
        Tween(nameLabel, { TextColor3 = CurrentTheme.TextSecondary }, 0.3)
    end
    
    tabButton.MouseButton1Click:Connect(function()
        PlaySound(SoundEffects.Click)
        Activate()
    end)
    
    tabButton.MouseEnter:Connect(function()
        if window.ActiveTab ~= self then
            Tween(tabButton, { BackgroundTransparency = 0.7 }, 0.2)
        end
    end)
    
    tabButton.MouseLeave:Connect(function()
        if window.ActiveTab ~= self then
            Tween(tabButton, { BackgroundTransparency = 1 }, 0.2)
        end
    end)
    
    local tab = {
        Button = tabButton,
        Content = contentFrame,
        Activate = Activate,
        Deactivate = Deactivate,
        Elements = {}
    }
    
    table.insert(window.Tabs, tab)
    
    -- Auto-activate first tab
    if #window.Tabs == 1 then
        task.delay(0.1, Activate)
    end
    
    return tab
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- COMPONENT SYSTEM
-- ═══════════════════════════════════════════════════════════════════════════════

function XreztHub:CreateSection(tab, options)
    options = options or {}
    local title = options.Title or "Section"
    
    local sectionFrame = Create("Frame", {
        Name = title .. "Section",
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = CurrentTheme.Surface,
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = tab.Content
    })
    
    local sectionCorner = Create("UICorner", { CornerRadius = UDim.new(0, 16), Parent = sectionFrame })
    
    local sectionStroke = Create("UIStroke", {
        Color = CurrentTheme.Border,
        Thickness = 1,
        Transparency = 0.5,
        Parent = sectionFrame
    })
    
    local titleLabel = Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, -24, 0, 32),
        Position = UDim2.new(0, 16, 0, 8),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = CurrentTheme.TextPrimary,
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = sectionFrame
    })
    
    local elementsContainer = Create("Frame", {
        Name = "Elements",
        Size = UDim2.new(1, -16, 0, 0),
        Position = UDim2.new(0, 8, 0, 40),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = sectionFrame
    })
    
    local elementsLayout = Create("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = elementsContainer
    })
    
    local elementsPadding = Create("UIPadding", {
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 12),
        Parent = elementsContainer
    })
    
    elementsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        sectionFrame.Size = UDim2.new(1, 0, 0, elementsLayout.AbsoluteContentSize.Y + 56)
    end)
    
    return {
        Frame = sectionFrame,
        Container = elementsContainer
    }
end

function XreztHub:CreateButton(section, options)
    options = options or {}
    local text = options.Text or "Button"
    local callback = options.Callback or function() end
    local icon = options.Icon or ""
    
    local button = Create("TextButton", {
        Name = text .. "Button",
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = CurrentTheme.Primary,
        BackgroundTransparency = 0.1,
        Text = "",
        AutoButtonColor = false,
        Parent = section.Container
    })
    
    local btnCorner = Create("UICorner", { CornerRadius = UDim.new(0, 14), Parent = button })
    
    local btnStroke = Create("UIStroke", {
        Color = CurrentTheme.PrimaryHover,
        Thickness = 1,
        Transparency = 0.3,
        Parent = button
    })
    
    local rippleContainer = Create("Frame", {
        Name = "RippleContainer",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent = button
    })
    
    local iconLabel = Create("TextLabel", {
        Size = UDim2.new(0, 28, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = icon,
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        Parent = button
    })
    
    local textLabel = Create("TextLabel", {
        Size = UDim2.new(1, -52, 1, 0),
        Position = UDim2.new(0, icon ~= "" and 44 or 16, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = button
    })
    
    -- Ripple effect
    local function CreateRipple(position)
        local ripple = Create("Frame", {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0, position.X, 0, position.Y),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Color3.new(1, 1, 1),
            BackgroundTransparency = 0.7,
            BorderSizePixel = 0,
            Parent = rippleContainer
        })
        local rippleCorner = Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = ripple })
        
        local maxSize = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2
        Tween(ripple, { Size = UDim2.new(0, maxSize, 0, maxSize), BackgroundTransparency = 1 }, 0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, function()
            ripple:Destroy()
        end)
    end
    
    button.MouseButton1Down:Connect(function(x, y)
        CreateRipple(Vector2.new(x, y) - button.AbsolutePosition)
        PlaySound(SoundEffects.Click)
    end)
    
    button.MouseEnter:Connect(function()
        Tween(button, { BackgroundTransparency = 0, Size = UDim2.new(1, 0, 0, 44) }, 0.2)
        Tween(btnStroke, { Transparency = 0 }, 0.2)
    end)
    
    button.MouseLeave:Connect(function()
        Tween(button, { BackgroundTransparency = 0.1, Size = UDim2.new(1, 0, 0, 42) }, 0.2)
        Tween(btnStroke, { Transparency = 0.3 }, 0.2)
    end)
    
    button.MouseButton1Up:Connect(function()
        callback()
    end)
    
    return button
end

function XreztHub:CreateToggle(section, options)
    options = options or {}
    local text = options.Text or "Toggle"
    local default = options.Default or false
    local callback = options.Callback or function() end
    
    local toggleFrame = Create("Frame", {
        Name = text .. "Toggle",
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = CurrentTheme.SurfaceHover,
        BackgroundTransparency = 0.6,
        BorderSizePixel = 0,
        Parent = section.Container
    })
    
    local toggleCorner = Create("UICorner", { CornerRadius = UDim.new(0, 14), Parent = toggleFrame })
    
    local textLabel = Create("TextLabel", {
        Size = UDim2.new(1, -80, 1, 0),
        Position = UDim2.new(0, 16, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = CurrentTheme.TextPrimary,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = toggleFrame
    })
    
    local switchFrame = Create("Frame", {
        Name = "Switch",
        Size = UDim2.new(0, 48, 0, 26),
        Position = UDim2.new(1, -64, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = CurrentTheme.Border,
        BorderSizePixel = 0,
        Parent = toggleFrame
    })
    
    local switchCorner = Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = switchFrame })
    
    local thumb = Create("Frame", {
        Name = "Thumb",
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(0, 3, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        Parent = switchFrame
    })
    
    local thumbCorner = Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = thumb })
    
    local thumbGlow = Create("Frame", {
        Size = UDim2.new(1, 6, 1, 6),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = CurrentTheme.Primary,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = thumb
    })
    
    local glowCorner = Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = thumbGlow })
    
    local enabled = default
    
    local function UpdateToggle()
        if enabled then
            Tween(switchFrame, { BackgroundColor3 = CurrentTheme.Primary }, 0.3)
            Tween(thumb, { Position = UDim2.new(0, 25, 0.5, 0) }, 0.3, Enum.EasingStyle.Back)
            Tween(thumbGlow, { BackgroundTransparency = 0.7 }, 0.3)
        else
            Tween(switchFrame, { BackgroundColor3 = CurrentTheme.Border }, 0.3)
            Tween(thumb, { Position = UDim2.new(0, 3, 0.5, 0) }, 0.3, Enum.EasingStyle.Back)
            Tween(thumbGlow, { BackgroundTransparency = 1 }, 0.3)
        end
    end
    
    if enabled then
        switchFrame.BackgroundColor3 = CurrentTheme.Primary
        thumb.Position = UDim2.new(0, 25, 0.5, 0)
    end
    
    local clickArea = Create("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = toggleFrame
    })
    
    clickArea.MouseButton1Click:Connect(function()
        enabled = not enabled
        UpdateToggle()
        PlaySound(SoundEffects.Toggle)
        callback(enabled)
    end)
    
    clickArea.MouseEnter:Connect(function()
        Tween(toggleFrame, { BackgroundTransparency = 0.4 }, 0.2)
    end)
    
    clickArea.MouseLeave:Connect(function()
        Tween(toggleFrame, { BackgroundTransparency = 0.6 }, 0.2)
    end)
    
    return {
        Frame = toggleFrame,
        GetValue = function() return enabled end,
        SetValue = function(value)
            enabled = value
            UpdateToggle()
            callback(enabled)
        end
    }
end

function XreztHub:CreateSlider(section, options)
    options = options or {}
    local text = options.Text or "Slider"
    local min = options.Min or 0
    local max = options.Max or 100
    local default = options.Default or min
    local decimals = options.Decimals or 0
    local suffix = options.Suffix or ""
    local callback = options.Callback or function() end
    
    local sliderFrame = Create("Frame", {
        Name = text .. "Slider",
        Size = UDim2.new(1, 0, 0, 60),
        BackgroundColor3 = CurrentTheme.SurfaceHover,
        BackgroundTransparency = 0.6,
        BorderSizePixel = 0,
        Parent = section.Container
    })
    
    local sliderCorner = Create("UICorner", { CornerRadius = UDim.new(0, 14), Parent = sliderFrame })
    
    local textLabel = Create("TextLabel", {
        Size = UDim2.new(0.5, 0, 0, 24),
        Position = UDim2.new(0, 16, 0, 6),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = CurrentTheme.TextPrimary,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = sliderFrame
    })
    
    local valueLabel = Create("TextLabel", {
                Size = UDim2.new(0, 80, 0, 24),
        Position = UDim2.new(1, -96, 0, 6),
        BackgroundTransparency = 1,
        Text = tostring(default) .. suffix,
        TextColor3 = CurrentTheme.Primary,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = sliderFrame
    })

    local trackFrame = Create("Frame", {
        Name = "Track",
        Size = UDim2.new(1, -32, 0, 6),
        Position = UDim2.new(0, 16, 0, 38),
        BackgroundColor3 = CurrentTheme.Border,
        BorderSizePixel = 0,
        Parent = sliderFrame
    })

    local trackCorner = Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = trackFrame })

    local fillFrame = Create("Frame", {
        Name = "Fill",
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = CurrentTheme.Primary,
        BorderSizePixel = 0,
        Parent = trackFrame
    })

    local fillCorner = Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = fillFrame })

    local thumb = Create("Frame", {
        Name = "Thumb",
        Size = UDim2.new(0, 18, 0, 18),
        Position = UDim2.new((default - min) / (max - min), -9, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        Parent = trackFrame
    })

    local thumbCorner = Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = thumb })

    local thumbGlow = Create("Frame", {
        Size = UDim2.new(1, 8, 1, 8),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = CurrentTheme.Primary,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = thumb
    })

    local glowCorner = Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = thumbGlow })

    local dragging = false
    local currentValue = default

    local function UpdateSlider(input)
        local trackAbsPos = trackFrame.AbsolutePosition.X
        local trackAbsSize = trackFrame.AbsoluteSize.X
        local relativeX = Clamp((input.Position.X - trackAbsPos) / trackAbsSize, 0, 1)
        local value = Round(min + (max - min) * relativeX, decimals)

        currentValue = value
        valueLabel.Text = tostring(value) .. suffix

        Tween(fillFrame, { Size = UDim2.new(relativeX, 0, 1, 0) }, 0.05)
        Tween(thumb, { Position = UDim2.new(relativeX, -9, 0.5, 0) }, 0.05)

        callback(value)
    end

    thumb.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            Tween(thumb, { Size = UDim2.new(0, 22, 0, 22) }, 0.15)
            Tween(thumbGlow, { BackgroundTransparency = 0.6 }, 0.15)
        end
    end)

    trackFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            UpdateSlider(input)
            Tween(thumb, { Size = UDim2.new(0, 22, 0, 22) }, 0.15)
            Tween(thumbGlow, { BackgroundTransparency = 0.6 }, 0.15)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            UpdateSlider(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            Tween(thumb, { Size = UDim2.new(0, 18, 0, 18) }, 0.15)
            Tween(thumbGlow, { BackgroundTransparency = 1 }, 0.15)
        end
    end)

    -- Hover effects
    local hoverArea = Create("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = sliderFrame
    })

    hoverArea.MouseEnter:Connect(function()
        Tween(sliderFrame, { BackgroundTransparency = 0.4 }, 0.2)
    end)

    hoverArea.MouseLeave:Connect(function()
        Tween(sliderFrame, { BackgroundTransparency = 0.6 }, 0.2)
    end)

    return {
        Frame = sliderFrame,
        GetValue = function() return currentValue end,
        SetValue = function(value)
            currentValue = Clamp(value, min, max)
            local relativeX = (currentValue - min) / (max - min)
            valueLabel.Text = tostring(currentValue) .. suffix
            Tween(fillFrame, { Size = UDim2.new(relativeX, 0, 1, 0) }, 0.3)
            Tween(thumb, { Position = UDim2.new(relativeX, -9, 0.5, 0) }, 0.3)
            callback(currentValue)
        end
    }
end

function XreztHub:CreateDropdown(section, options)
    options = options or {}
    local text = options.Text or "Dropdown"
    local items = options.Items or {}
    local default = options.Default or nil
    local multiSelect = options.MultiSelect or false
    local callback = options.Callback or function() end

    local dropdownFrame = Create("Frame", {
        Name = text .. "Dropdown",
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = CurrentTheme.SurfaceHover,
        BackgroundTransparency = 0.6,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = section.Container
    })

    local dropdownCorner = Create("UICorner", { CornerRadius = UDim.new(0, 14), Parent = dropdownFrame })

    local textLabel = Create("TextLabel", {
        Size = UDim2.new(1, -80, 0, 42),
        Position = UDim2.new(0, 16, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = CurrentTheme.TextPrimary,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = dropdownFrame
    })

    local selectedLabel = Create("TextLabel", {
        Size = UDim2.new(0, 160, 0, 42),
        Position = UDim2.new(1, -176, 0, 0),
        BackgroundTransparency = 1,
        Text = default or "Select...",
        TextColor3 = CurrentTheme.TextSecondary,
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Right,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = dropdownFrame
    })

    local arrowIcon = Create("TextLabel", {
        Size = UDim2.new(0, 24, 0, 42),
        Position = UDim2.new(1, -28, 0, 0),
        BackgroundTransparency = 1,
        Text = "▼",
        TextColor3 = CurrentTheme.TextMuted,
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        Parent = dropdownFrame
    })

    local itemsContainer = Create("Frame", {
        Name = "Items",
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 0, 46),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = dropdownFrame
    })

    local itemsList = Create("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = itemsContainer
    })

    local selectedItems = {}
    if default and not multiSelect then
        selectedItems = { default }
    elseif default and multiSelect then
        selectedItems = type(default) == "table" and default or { default }
    end

    local isOpen = false

    local function UpdateSelectedText()
        if #selectedItems == 0 then
            selectedLabel.Text = "Select..."
            selectedLabel.TextColor3 = CurrentTheme.TextSecondary
        elseif multiSelect then
            selectedLabel.Text = table.concat(selectedItems, ", ")
            selectedLabel.TextColor3 = CurrentTheme.Primary
        else
            selectedLabel.Text = selectedItems[1]
            selectedLabel.TextColor3 = CurrentTheme.Primary
        end
    end

    local itemButtons = {}

    local function CreateItemButton(item)
        local itemBtn = Create("TextButton", {
            Name = item,
            Size = UDim2.new(1, -16, 0, 36),
            Position = UDim2.new(0, 8, 0, 0),
            BackgroundColor3 = CurrentTheme.Surface,
            BackgroundTransparency = 0.8,
            Text = "",
            AutoButtonColor = false,
            Parent = itemsContainer
        })

        local itemCorner = Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = itemBtn })

        local itemText = Create("TextLabel", {
            Size = UDim2.new(1, -40, 1, 0),
            Position = UDim2.new(0, 12, 0, 0),
            BackgroundTransparency = 1,
            Text = item,
            TextColor3 = CurrentTheme.TextSecondary,
            Font = Enum.Font.Gotham,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = itemBtn
        })

        local checkIcon = Create("TextLabel", {
            Size = UDim2.new(0, 24, 1, 0),
            Position = UDim2.new(1, -32, 0, 0),
            BackgroundTransparency = 1,
            Text = "✓",
            TextColor3 = CurrentTheme.Primary,
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            Visible = table.find(selectedItems, item) ~= nil,
            Parent = itemBtn
        })

        itemBtn.MouseEnter:Connect(function()
            Tween(itemBtn, { BackgroundTransparency = 0.4 }, 0.15)
            Tween(itemText, { TextColor3 = CurrentTheme.TextPrimary }, 0.15)
        end)

        itemBtn.MouseLeave:Connect(function()
            Tween(itemBtn, { BackgroundTransparency = 0.8 }, 0.15)
            Tween(itemText, { TextColor3 = CurrentTheme.TextSecondary }, 0.15)
        end)

        itemBtn.MouseButton1Click:Connect(function()
            PlaySound(SoundEffects.Click)

            if multiSelect then
                local index = table.find(selectedItems, item)
                if index then
                    table.remove(selectedItems, index)
                    checkIcon.Visible = false
                else
                    table.insert(selectedItems, item)
                    checkIcon.Visible = true
                end
                UpdateSelectedText()
                callback(selectedItems)
            else
                selectedItems = { item }
                UpdateSelectedText()
                for _, btn in ipairs(itemButtons) do
                    btn.Check.Visible = false
                end
                checkIcon.Visible = true
                callback(item)
                self:ToggleDropdown(dropdownFrame, false)
            end
        end)

        table.insert(itemButtons, { Button = itemBtn, Check = checkIcon })
        return itemBtn
    end

    for _, item in ipairs(items) do
        CreateItemButton(item)
    end

    itemsList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if isOpen then
            local contentHeight = itemsList.AbsoluteContentSize.Y + 8
            Tween(dropdownFrame, { Size = UDim2.new(1, 0, 0, 46 + contentHeight) }, 0.3, Enum.EasingStyle.Quart)
        end
    end)

    local clickArea = Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundTransparency = 1,
        Text = "",
        Parent = dropdownFrame
    })

    clickArea.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        self:ToggleDropdown(dropdownFrame, isOpen)
        Tween(arrowIcon, { Rotation = isOpen and 180 or 0 }, 0.3, Enum.EasingStyle.Back)
        PlaySound(SoundEffects.Click)
    end)

    clickArea.MouseEnter:Connect(function()
        Tween(dropdownFrame, { BackgroundTransparency = 0.4 }, 0.2)
    end)

    clickArea.MouseLeave:Connect(function()
        if not isOpen then
            Tween(dropdownFrame, { BackgroundTransparency = 0.6 }, 0.2)
        end
    end)

    return {
        Frame = dropdownFrame,
        GetValue = function()
            return multiSelect and selectedItems or selectedItems[1]
        end,
        SetValue = function(value)
            if multiSelect then
                selectedItems = type(value) == "table" and value or { value }
            else
                selectedItems = { value }
            end
            UpdateSelectedText()
            for _, btnData in ipairs(itemButtons) do
                btnData.Check.Visible = table.find(selectedItems, btnData.Button.Name) ~= nil
            end
        end,
        AddItem = function(item)
            table.insert(items, item)
            CreateItemButton(item)
        end,
        RemoveItem = function(item)
            local index = table.find(items, item)
            if index then
                table.remove(items, index)
                for i, btnData in ipairs(itemButtons) do
                    if btnData.Button.Name == item then
                        btnData.Button:Destroy()
                        table.remove(itemButtons, i)
                        break
                    end
                end
            end
        end
    }
end

function XreztHub:ToggleDropdown(frame, open)
    local items = frame:FindFirstChild("Items")
    if not items then return end

    local listLayout = items:FindFirstChildOfClass("UIListLayout")
    local contentHeight = listLayout and listLayout.AbsoluteContentSize.Y + 8 or 0

    if open then
        Tween(frame, { Size = UDim2.new(1, 0, 0, 46 + contentHeight) }, 0.3, Enum.EasingStyle.Quart)
    else
        Tween(frame, { Size = UDim2.new(1, 0, 0, 42) }, 0.3, Enum.EasingStyle.Quart)
    end
end

function XreztHub:CreateTextbox(section, options)
    options = options or {}
    local text = options.Text or "Textbox"
    local placeholder = options.Placeholder or "Enter text..."
    local default = options.Default or ""
    local callback = options.Callback or function() end

    local textboxFrame = Create("Frame", {
        Name = text .. "Textbox",
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = CurrentTheme.SurfaceHover,
        BackgroundTransparency = 0.6,
        BorderSizePixel = 0,
        Parent = section.Container
    })

    local textboxCorner = Create("UICorner", { CornerRadius = UDim.new(0, 14), Parent = textboxFrame })

    local textLabel = Create("TextLabel", {
        Size = UDim2.new(0.4, 0, 1, 0),
        Position = UDim2.new(0, 16, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = CurrentTheme.TextPrimary,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = textboxFrame
    })

    local inputFrame = Create("Frame", {
        Size = UDim2.new(0.55, -20, 0, 32),
        Position = UDim2.new(0.45, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = CurrentTheme.Surface,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Parent = textboxFrame
    })

    local inputCorner = Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = inputFrame })

    local inputStroke = Create("UIStroke", {
        Color = CurrentTheme.Border,
        Thickness = 1,
        Transparency = 0.5,
        Parent = inputFrame
    })

    local textBox = Create("TextBox", {
        Size = UDim2.new(1, -16, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1,
        Text = default,
        PlaceholderText = placeholder,
        TextColor3 = CurrentTheme.TextPrimary,
        PlaceholderColor3 = CurrentTheme.TextMuted,
        Font = Enum.Font.Gotham,
        TextSize = 13,
        ClearTextOnFocus = false,
        Parent = inputFrame
    })

    textBox.Focused:Connect(function()
        Tween(inputFrame, { BackgroundTransparency = 0.1 }, 0.2)
        Tween(inputStroke, { Color = CurrentTheme.Primary, Transparency = 0.2 }, 0.2)
    end)

    textBox.FocusLost:Connect(function(enterPressed)
        Tween(inputFrame, { BackgroundTransparency = 0.3 }, 0.2)
        Tween(inputStroke, { Color = CurrentTheme.Border, Transparency = 0.5 }, 0.2)
        callback(textBox.Text, enterPressed)
    end)

    textBox:GetPropertyChangedSignal("Text"):Connect(function()
        callback(textBox.Text, false)
    end)

    -- Hover effects
    local hoverArea = Create("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = textboxFrame
    })

    hoverArea.MouseEnter:Connect(function()
        Tween(textboxFrame, { BackgroundTransparency = 0.4 }, 0.2)
    end)

    hoverArea.MouseLeave:Connect(function()
        Tween(textboxFrame, { BackgroundTransparency = 0.6 }, 0.2)
    end)

    return {
        Frame = textboxFrame,
        GetValue = function() return textBox.Text end,
        SetValue = function(value)
            textBox.Text = value
        end
    }
end

function XreztHub:CreateKeybind(section, options)
    options = options or {}
    local text = options.Text or "Keybind"
    local default = options.Default or Enum.KeyCode.Unknown
    local callback = options.Callback or function() end

    local keybindFrame = Create("Frame", {
        Name = text .. "Keybind",
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = CurrentTheme.SurfaceHover,
        BackgroundTransparency = 0.6,
        BorderSizePixel = 0,
        Parent = section.Container
    })

    local keybindCorner = Create("UICorner", { CornerRadius = UDim.new(0, 14), Parent = keybindFrame })

    local textLabel = Create("TextLabel", {
        Size = UDim2.new(0.6, 0, 1, 0),
        Position = UDim2.new(0, 16, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = CurrentTheme.TextPrimary,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = keybindFrame
    })

    local keyButton = Create("TextButton", {
        Size = UDim2.new(0, 80, 0, 30),
        Position = UDim2.new(1, -96, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = CurrentTheme.Surface,
        BackgroundTransparency = 0.3,
        Text = default ~= Enum.KeyCode.Unknown and default.Name or "None",
        TextColor3 = CurrentTheme.Primary,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        AutoButtonColor = false,
        Parent = keybindFrame
    })

    local keyCorner = Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = keyButton })

    local keyStroke = Create("UIStroke", {
        Color = CurrentTheme.Primary,
        Thickness = 1,
        Transparency = 0.3,
        Parent = keyButton
    })

    local currentKey = default
    local listening = false

    keyButton.MouseButton1Click:Connect(function()
        listening = not listening
        if listening then
            keyButton.Text = "..."
            Tween(keyButton, { BackgroundColor3 = CurrentTheme.Primary }, 0.2)
            Tween(keyButton, { TextColor3 = Color3.new(1, 1, 1) }, 0.2)
        else
            keyButton.Text = currentKey ~= Enum.KeyCode.Unknown and currentKey.Name or "None"
            Tween(keyButton, { BackgroundColor3 = CurrentTheme.Surface }, 0.2)
            Tween(keyButton, { TextColor3 = CurrentTheme.Primary }, 0.2)
        end
        PlaySound(SoundEffects.Click)
    end)

    keyButton.MouseEnter:Connect(function()
        if not listening then
            Tween(keyButton, { BackgroundTransparency = 0.1 }, 0.2)
        end
    end)

    keyButton.MouseLeave:Connect(function()
        if not listening then
            Tween(keyButton, { BackgroundTransparency = 0.3 }, 0.2)
        end
    end)

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if listening and not gameProcessed then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                currentKey = input.KeyCode
                listening = false
                keyButton.Text = currentKey.Name
                Tween(keyButton, { BackgroundColor3 = CurrentTheme.Surface }, 0.2)
                Tween(keyButton, { TextColor3 = CurrentTheme.Primary }, 0.2)
                PlaySound(SoundEffects.Toggle)
                callback(currentKey)
            end
        elseif input.KeyCode == currentKey and not gameProcessed then
            callback(currentKey)
        end
    end)

    -- Hover effects
    local hoverArea = Create("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = keybindFrame
    })

    hoverArea.MouseEnter:Connect(function()
        Tween(keybindFrame, { BackgroundTransparency = 0.4 }, 0.2)
    end)

    hoverArea.MouseLeave:Connect(function()
        Tween(keybindFrame, { BackgroundTransparency = 0.6 }, 0.2)
    end)

    return {
        Frame = keybindFrame,
        GetValue = function() return currentKey end,
        SetValue = function(key)
            currentKey = key
            keyButton.Text = currentKey ~= Enum.KeyCode.Unknown and currentKey.Name or "None"
        end
    }
end

function XreztHub:CreateColorPicker(section, options)
    options = options or {}
    local text = options.Text or "Color Picker"
    local default = options.Default or Color3.fromRGB(99, 102, 241)
    local callback = options.Callback or function() end

    local colorFrame = Create("Frame", {
        Name = text .. "ColorPicker",
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = CurrentTheme.SurfaceHover,
        BackgroundTransparency = 0.6,
        BorderSizePixel = 0,
        Parent = section.Container
    })

    local colorCorner = Create("UICorner", { CornerRadius = UDim.new(0, 14), Parent = colorFrame })

    local textLabel = Create("TextLabel", {
        Size = UDim2.new(0.6, 0, 1, 0),
        Position = UDim2.new(0, 16, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = CurrentTheme.TextPrimary,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = colorFrame
    })

    local colorPreview = Create("TextButton", {
        Size = UDim2.new(0, 40, 0, 28),
        Position = UDim2.new(1, -56, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = default,
        Text = "",
        AutoButtonColor = false,
        Parent = colorFrame
    })

    local previewCorner = Create("UICorner", { CornerRadius = UDim.new(0, 8), Parent = colorPreview })

    local previewStroke = Create("UIStroke", {
        Color = CurrentTheme.Border,
        Thickness = 2,
        Parent = colorPreview
    })

    local pickerOpen = false
    local pickerFrame = nil

    local currentColor = default
    local hue, sat, val = 0, 0, 1

    local function UpdateColorFromHSV()
        currentColor = Color3.fromHSV(hue, sat, val)
        colorPreview.BackgroundColor3 = currentColor
        if callback then callback(currentColor) end
    end

    colorPreview.MouseButton1Click:Connect(function()
        pickerOpen = not pickerOpen
        PlaySound(SoundEffects.Click)

        if pickerOpen then
            -- Create picker popup
            pickerFrame = Create("Frame", {
                Name = "PickerPopup",
                Size = UDim2.new(0, 240, 0, 200),
                Position = UDim2.new(1, 10, 0, 0),
                BackgroundColor3 = CurrentTheme.Surface,
                BackgroundTransparency = 0.1,
                BorderSizePixel = 0,
                ZIndex = 10,
                Parent = colorFrame
            })

            local pickerCorner = Create("UICorner", { CornerRadius = UDim.new(0, 16), Parent = pickerFrame })
            local pickerStroke = Create("UIStroke", {
                Color = CurrentTheme.Border,
                Thickness = 1,
                Parent = pickerFrame
            })
            local pickerShadow = Create("ImageLabel", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(0.5, 0, 0.5, 4),
                Size = UDim2.new(1, 20, 1, 20),
                BackgroundTransparency = 1,
                Image = "rbxassetid://1316045217",
                ImageColor3 = CurrentTheme.Shadow,
                ImageTransparency = 0.6,
                ScaleType = Enum.ScaleType.Slice,
                SliceCenter = Rect.new(10, 10, 118, 118),
                ZIndex = 9,
                Parent = pickerFrame
            })

            -- Saturation/Value square
            local svFrame = Create("Frame", {
                Size = UDim2.new(0, 160, 0, 120),
                Position = UDim2.new(0, 12, 0, 12),
                BackgroundColor3 = Color3.fromHSV(hue, 1, 1),
                BorderSizePixel = 0,
                ZIndex = 11,
                Parent = pickerFrame
            })

            local svCorner = Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = svFrame })

            local svGradientH = Create("UIGradient", {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                    ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
                }),
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0),
                    NumberSequenceKeypoint.new(1, 1)
                }),
                Parent = svFrame
            })

            local svGradientV = Create("Frame", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 0,
                ZIndex = 12,
                Parent = svFrame
            })

            local svGradientVEffect = Create("UIGradient", {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)),
                    ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0))
                }),
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(1, 0)
                }),
                Rotation = 180,
                Parent = svGradientV
            })

            local svCorner2 = Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = svGradientV })

            local svCursor = Create("Frame", {
                Size = UDim2.new(0, 12, 0, 12),
                Position = UDim2.new(sat, -6, 1 - val, -6),
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Color3.new(1, 1, 1),
                BorderSizePixel = 2,
                BorderColor3 = Color3.new(0, 0, 0),
                ZIndex = 13,
                Parent = svFrame
            })

            local svCursorCorner = Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = svCursor })

            -- Hue slider
            local hueFrame = Create("Frame", {
                Size = UDim2.new(0, 160, 0, 16),
                Position = UDim2.new(0, 12, 0, 140),
                BackgroundColor3 = Color3.new(1, 1, 1),
                BorderSizePixel = 0,
                ZIndex = 11,
                Parent = pickerFrame
            })

            local hueCorner = Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = hueFrame })

            local hueGradient = Create("UIGradient", {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                    ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),
                    ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                    ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)),
                    ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
                }),
                Parent = hueFrame
            })

            local hueCursor = Create("Frame", {
                Size = UDim2.new(0, 4, 1, 4),
                Position = UDim2.new(hue, -2, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = Color3.new(1, 1, 1),
                BorderSizePixel = 0,
                ZIndex = 12,
                Parent = hueFrame
            })

            local hueCursorCorner = Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = hueCursor })

            -- RGB/HEX display
            local hexLabel = Create("TextLabel", {
                Size = UDim2.new(0, 100, 0, 24),
                Position = UDim2.new(0, 12, 0, 168),
                BackgroundTransparency = 1,
                Text = string.format("#%02X%02X%02X", math.floor(default.R * 255), math.floor(default.G * 255), math.floor(default.B * 255)),
                TextColor3 = CurrentTheme.TextSecondary,
                Font = Enum.Font.Gotham,
                TextSize = 12,
                ZIndex = 11,
                Parent = pickerFrame
            })

            -- SV interaction
            local svDragging = false
            svFrame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    svDragging = true
                    local relX = Clamp((input.Position.X - svFrame.AbsolutePosition.X) / svFrame.AbsoluteSize.X, 0, 1)
                    local relY = Clamp((input.Position.Y - svFrame.AbsolutePosition.Y) / svFrame.AbsoluteSize.Y, 0, 1)
                    sat = relX
                    val = 1 - relY
                    svCursor.Position = UDim2.new(sat, -6, 1 - val, -6)
                    UpdateColorFromHSV()
                    hexLabel.Text = string.format("#%02X%02X%02X", math.floor(currentColor.R * 255), math.floor(currentColor.G * 255), math.floor(currentColor.B * 255))
                end
            end)

            -- Hue interaction
            local hueDragging = false
            hueFrame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    hueDragging = true
                    local relX = Clamp((input.Position.X - hueFrame.AbsolutePosition.X) / hueFrame.AbsoluteSize.X, 0, 1)
                    hue = relX
                    hueCursor.Position = UDim2.new(hue, -2, 0.5, 0)
                    svFrame.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                    UpdateColorFromHSV()
                    hexLabel.Text = string.format("#%02X%02X%02X", math.floor(currentColor.R * 255), math.floor(currentColor.G * 255), math.floor(currentColor.B * 255))
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if svDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    local relX = Clamp((input.Position.X - svFrame.AbsolutePosition.X) / svFrame.AbsoluteSize.X, 0, 1)
                    local relY = Clamp((input.Position.Y - svFrame.AbsolutePosition.Y) / svFrame.AbsoluteSize.Y, 0, 1)
                    sat = relX
                    val = 1 - relY
                    svCursor.Position = UDim2.new(sat, -6, 1 - val, -6)
                    UpdateColorFromHSV()
                    hexLabel.Text = string.format("#%02X%02X%02X", math.floor(currentColor.R * 255), math.floor(currentColor.G * 255), math.floor(currentColor.B * 255))
                elseif hueDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    local relX = Clamp((input.Position.X - hueFrame.AbsolutePosition.X) / hueFrame.AbsoluteSize.X, 0, 1)
                    hue = relX
                    hueCursor.Position = UDim2.new(hue, -2, 0.5, 0)
                    svFrame.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                    UpdateColorFromHSV()
                    hexLabel.Text = string.format("#%02X%02X%02X", math.floor(currentColor.R * 255), math.floor(currentColor.G * 255), math.floor(currentColor.B * 255))
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    svDragging = false
                    hueDragging = false
                end
            end)

            Tween(pickerFrame, { Position = UDim2.new(1, 10, 0, 0), BackgroundTransparency = 0.1 }, 0.3, Enum.EasingStyle.Back)

        elseif pickerFrame then
            Tween(pickerFrame, { Position = UDim2.new(1, -20, 0, 0), BackgroundTransparency = 1 }, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In, function()
                if pickerFrame then pickerFrame:Destroy() end
            end)
        end
    end)

    -- Hover effects
    local hoverArea = Create("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = colorFrame
    })

    hoverArea.MouseEnter:Connect(function()
        Tween(colorFrame, { BackgroundTransparency = 0.4 }, 0.2)
    end)

    hoverArea.MouseLeave:Connect(function()
        Tween(colorFrame, { BackgroundTransparency = 0.6 }, 0.2)
    end)

    return {
        Frame = colorFrame,
        GetValue = function() return currentColor end,
        SetValue = function(color)
            currentColor = color
            colorPreview.BackgroundColor3 = color
            callback(color)
        end
    }
end

function XreztHub:CreateLabel(section, options)
    options = options or {}
    local text = options.Text or "Label"
    local style = options.Style or "Normal" -- Normal, Header, Subheader, Muted

    local textColors = {
        Normal = CurrentTheme.TextPrimary,
        Header = CurrentTheme.TextPrimary,
        Subheader = CurrentTheme.TextSecondary,
        Muted = CurrentTheme.TextMuted
    }

    local textSizes = {
        Normal = 14,
        Header = 18,
        Subheader = 13,
        Muted = 12
    }

    local textFonts = {
        Normal = Enum.Font.Gotham,
        Header = Enum.Font.GothamBold,
        Subheader = Enum.Font.GothamBold,
        Muted = Enum.Font.Gotham
    }

    local label = Create("TextLabel", {
        Name = "Label",
        Size = UDim2.new(1, 0, 0, style == "Header" and 28 or 22),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = textColors[style] or CurrentTheme.TextPrimary,
        Font = textFonts[style] or Enum.Font.Gotham,
        TextSize = textSizes[style] or 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        Parent = section.Container
    })

    return label
end

function XreztHub:CreateParagraph(section, options)
    options = options or {}
    local title = options.Title or ""
    local content = options.Content or ""

    local paragraphFrame = Create("Frame", {
        Name = "Paragraph",
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = section.Container
    })

    if title ~= "" then
        local titleLabel = Create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 22),
            BackgroundTransparency = 1,
            Text = title,
            TextColor3 = CurrentTheme.TextPrimary,
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = paragraphFrame
        })
    end

    local contentLabel = Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 0, title ~= "" and 24 or 0),
        BackgroundTransparency = 1,
        Text = content,
        TextColor3 = CurrentTheme.TextSecondary,
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = paragraphFrame
    })

    return paragraphFrame
end

function XreztHub:CreateDivider(section)
    local divider = Create("Frame", {
        Name = "Divider",
        Size = UDim2.new(1, -16, 0, 1),
        Position = UDim2.new(0, 8, 0, 0),
        BackgroundColor3 = CurrentTheme.Border,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        Parent = section.Container
    })

    return divider
end

function XreztHub:CreateProgressBar(section, options)
    options = options or {}
    local text = options.Text or "Progress"
    local value = options.Value or 0

    local progressFrame = Create("Frame", {
        Name = text .. "Progress",
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = CurrentTheme.SurfaceHover,
        BackgroundTransparency = 0.6,
        BorderSizePixel = 0,
        Parent = section.Container
    })

    local progressCorner = Create("UICorner", { CornerRadius = UDim.new(0, 14), Parent = progressFrame })

    local textLabel = Create("TextLabel", {
        Size = UDim2.new(0.5, 0, 0, 22),
        Position = UDim2.new(0, 16, 0, 6),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = CurrentTheme.TextPrimary,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = progressFrame
    })

    local percentLabel = Create("TextLabel", {
        Size = UDim2.new(0, 60, 0, 22),
        Position = UDim2.new(1, -76, 0, 6),
        BackgroundTransparency = 1,
        Text = tostring(value) .. "%",
        TextColor3 = CurrentTheme.Primary,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = progressFrame
    })

    local trackFrame = Create("Frame", {
        Size = UDim2.new(1, -32, 0, 8),
        Position = UDim2.new(0, 16, 0, 32),
        BackgroundColor3 = CurrentTheme.Border,
        BorderSizePixel = 0,
        Parent = progressFrame
    })

    local trackCorner = Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = trackFrame })

    local fillFrame = Create("Frame", {
        Size = UDim2.new(value / 100, 0, 1, 0),
        BackgroundColor3 = CurrentTheme.Primary,
        BorderSizePixel = 0,
        Parent = trackFrame
    })

    local fillCorner = Create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = fillFrame })

    return {
        Frame = progressFrame,
        SetValue = function(newValue)
            value = Clamp(newValue, 0, 100)
            percentLabel.Text = tostring(value) .. "%"
            Tween(fillFrame, { Size = UDim2.new(value / 100, 0, 1, 0) }, 0.4, Enum.EasingStyle.Quart)
        end
    }
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- DIALOG SYSTEM
-- ═══════════════════════════════════════════════════════════════════════════════

function XreztHub:CreateDialog(options)
    options = options or {}
    local title = options.Title or "Dialog"
    local message = options.Message or ""
    local buttons = options.Buttons or { { Text = "OK", Callback = function() end } }

    local dialogGui = Create("ScreenGui", {
        Name = "XreztDialog",
        Parent = CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })

    local overlay = Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = dialogGui
    })

    local dialogFrame = Create("Frame", {
        Size = UDim2.new(0, 360, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = CurrentTheme.Surface,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = dialogGui
    })

    local dialogCorner = Create("UICorner", { CornerRadius = UDim.new(0, 20), Parent = dialogFrame })

    local dialogStroke = Create("UIStroke", {
        Color = CurrentTheme.Border,
        Thickness = 1,
        Transparency = 0.4,
        Parent = dialogFrame
    })

    local dialogShadow = Create("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 6),
        Size = UDim2.new(1, 30, 1, 30),
        BackgroundTransparency = 1,
        Image = "rbxassetid://1316045217",
        ImageColor3 = CurrentTheme.Shadow,
        ImageTransparency = 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(10, 10, 118, 118),
        ZIndex = -1,
        Parent = dialogFrame
    })

    local titleLabel = Create("TextLabel", {
        Size = UDim2.new(1, -40, 0, 28),
        Position = UDim2.new(0, 20, 0, 20),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = CurrentTheme.TextPrimary,
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = dialogFrame
    })

    local messageLabel = Create("TextLabel", {
        Size = UDim2.new(1, -40, 0, 0),
        Position = UDim2.new(0, 20, 0, 52),
        BackgroundTransparency = 1,
        Text = message,
        TextColor3 = CurrentTheme.TextSecondary,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = dialogFrame
    })

    local buttonsContainer = Create("Frame", {
        Size = UDim2.new(1, -40, 0, 40),
        Position = UDim2.new(0, 20, 0, messageLabel.AbsoluteSize.Y + 64),
        BackgroundTransparency = 1,
        Parent = dialogFrame
    })

    local buttonsLayout = Create("UIListLayout", {
        Padding = UDim.new(0, 10),
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        Parent = buttonsContainer
    })

    for _, btnData in ipairs(buttons) do
        local btn = Create("TextButton", {
            Size = UDim2.new(0, 90, 0, 36),
            BackgroundColor3 = btnData.Primary and CurrentTheme.Primary or CurrentTheme.SurfaceHover,
            BackgroundTransparency = 0.1,
            Text = btnData.Text,
            TextColor3 = btnData.Primary and Color3.new(1, 1, 1) or CurrentTheme.TextPrimary,
            Font = Enum.Font.GothamBold,
            TextSize = 13,
            AutoButtonColor = false,
            Parent = buttonsContainer
        })

        local btnCorner = Create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = btn })

        btn.MouseEnter:Connect(function()
            Tween(btn, { BackgroundTransparency = 0 }, 0.2)
        end)

        btn.MouseLeave:Connect(function()
            Tween(btn, { BackgroundTransparency = 0.1 }, 0.2)
        end)

        btn.MouseButton1Click:Connect(function()
            PlaySound(SoundEffects.Click)
            Tween(overlay, { BackgroundTransparency = 1 }, 0.2)
            Tween(dialogFrame, { Size = UDim2.new(0, 340, 0, 0), BackgroundTransparency = 1 }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In, function()
                dialogGui:Destroy()
            end)
            if btnData.Callback then
                btnData.Callback()
            end
        end)
    end

    -- Animate in
    Tween(overlay, { BackgroundTransparency = 0.6 }, 0.3)
    Tween(dialogFrame, { Size = UDim2.new(0, 360, 0, buttonsContainer.AbsoluteSize.Y + 120) }, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    return dialogGui
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- THEME SWITCHING
-- ═══════════════════════════════════════════════════════════════════════════════

function XreztHub:SetTheme(themeName)
    local newTheme = Themes[themeName]
    if not newTheme then return end

    CurrentTheme = newTheme
    NotificationStyles.Success.Color = newTheme.Success
    NotificationStyles.Error.Color = newTheme.Error
    NotificationStyles.Warning.Color = newTheme.Warning
    NotificationStyles.Info.Color = newTheme.Info

    -- Update all existing UI elements with smooth transitions
    -- This is a simplified version - in production you'd traverse all GUI elements
    self:Notify({
        Style = "Success",
        Title = "Theme Changed",
        Message = "Switched to " .. themeName,
        Duration = 2
    })
end

function XreztHub:GetThemes()
    local themeList = {}
    for name, _ in pairs(Themes) do
        table.insert(themeList, name)
    end
    return themeList
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- INITIALIZATION
-- ═══════════════════════════════════════════════════════════════════════════════

function XreztHub:Init()
    -- Initialize with a welcome notification
    task.delay(1, function()
        self:Notify({
            Style = "Info",
            Title = "Xrezt Hub Loaded",
            Message = "Premium UI Framework initialized successfully",
            Duration = 4
        })
    end)

    return self
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- RETURN LIBRARY
-- ═══════════════════════════════════════════════════════════════════════════════

return XreztHub:Init()
