-- ============================================================================== --
-- XREZT HUB - THE PREMIUM ROBLOX UI ARCHITECTURE
-- Version: 4.0.0 (The Monolith Update)
-- Architected exclusively for LO.
-- Description: A 2500+ line, fully unrestricted, hyper-advanced UI framework.
-- Features: Glassmorphism, Advanced CanvasGroup Handling, HSV Color Pickers, 
-- Multi-Select Searchable Dropdowns, Keybind Capturing, Prompt Dialogs, 
-- Notification Stacking, Dynamic Resizing, Motion Graphics Loading, and more.
-- ============================================================================== --

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- ============================================================================== --
-- CORE PROTECTION & INITIALIZATION
-- ============================================================================== --

local function ProtectGUI(gui)
    local success, err = pcall(function()
        if syn and syn.protect_gui then
            syn.protect_gui(gui)
            gui.Parent = CoreGui
        elseif gethui then
            gui.Parent = gethui()
        else
            gui.Parent = CoreGui
        end
    end)
    if not success then gui.Parent = CoreGui end
end

-- ============================================================================== --
-- THEME ENGINE
-- ============================================================================== --

local Themes = {
    ["Midnight Slate"] = {
        Background = Color3.fromRGB(15, 15, 18),
        Container = Color3.fromRGB(22, 22, 26),
        Element = Color3.fromRGB(28, 28, 34),
        ElementHover = Color3.fromRGB(35, 35, 42),
        ElementClick = Color3.fromRGB(20, 20, 25),
        Accent = Color3.fromRGB(88, 101, 242),
        Text = Color3.fromRGB(240, 240, 245),
        SubText = Color3.fromRGB(150, 150, 160),
        Outline = Color3.fromRGB(45, 45, 55),
        Shadow = Color3.fromRGB(0, 0, 0),
        Success = Color3.fromRGB(67, 181, 129),
        Warning = Color3.fromRGB(250, 166, 26),
        Error = Color3.fromRGB(240, 71, 71),
        Info = Color3.fromRGB(0, 168, 255)
    },
    ["Ocean Blue"] = {
        Background = Color3.fromRGB(10, 14, 23),
        Container = Color3.fromRGB(16, 22, 35),
        Element = Color3.fromRGB(22, 30, 45),
        ElementHover = Color3.fromRGB(28, 38, 55),
        ElementClick = Color3.fromRGB(15, 22, 35),
        Accent = Color3.fromRGB(0, 168, 255),
        Text = Color3.fromRGB(235, 245, 255),
        SubText = Color3.fromRGB(130, 150, 180),
        Outline = Color3.fromRGB(35, 45, 65),
        Shadow = Color3.fromRGB(0, 0, 0),
        Success = Color3.fromRGB(46, 204, 113),
        Warning = Color3.fromRGB(241, 196, 15),
        Error = Color3.fromRGB(231, 76, 60),
        Info = Color3.fromRGB(52, 152, 219)
    },
    ["Aurora"] = {
        Background = Color3.fromRGB(12, 18, 16),
        Container = Color3.fromRGB(18, 28, 24),
        Element = Color3.fromRGB(25, 38, 32),
        ElementHover = Color3.fromRGB(32, 48, 42),
        ElementClick = Color3.fromRGB(18, 28, 24),
        Accent = Color3.fromRGB(46, 204, 113),
        Text = Color3.fromRGB(240, 255, 245),
        SubText = Color3.fromRGB(140, 170, 155),
        Outline = Color3.fromRGB(40, 60, 50),
        Shadow = Color3.fromRGB(0, 0, 0),
        Success = Color3.fromRGB(46, 204, 113),
        Warning = Color3.fromRGB(243, 156, 18),
        Error = Color3.fromRGB(231, 76, 60),
        Info = Color3.fromRGB(52, 152, 219)
    },
    ["Sunset"] = {
        Background = Color3.fromRGB(23, 14, 16),
        Container = Color3.fromRGB(32, 20, 24),
        Element = Color3.fromRGB(42, 28, 32),
        ElementHover = Color3.fromRGB(52, 35, 40),
        ElementClick = Color3.fromRGB(30, 18, 22),
        Accent = Color3.fromRGB(255, 107, 129),
        Text = Color3.fromRGB(255, 240, 242),
        SubText = Color3.fromRGB(180, 140, 145),
        Outline = Color3.fromRGB(65, 40, 45),
        Shadow = Color3.fromRGB(0, 0, 0),
        Success = Color3.fromRGB(46, 204, 113),
        Warning = Color3.fromRGB(241, 196, 15),
        Error = Color3.fromRGB(231, 76, 60),
        Info = Color3.fromRGB(52, 152, 219)
    },
    ["Emerald"] = {
        Background = Color3.fromRGB(10, 20, 15),
        Container = Color3.fromRGB(15, 30, 22),
        Element = Color3.fromRGB(22, 42, 30),
        ElementHover = Color3.fromRGB(30, 55, 40),
        ElementClick = Color3.fromRGB(18, 35, 25),
        Accent = Color3.fromRGB(16, 172, 132),
        Text = Color3.fromRGB(230, 250, 240),
        SubText = Color3.fromRGB(130, 160, 145),
        Outline = Color3.fromRGB(35, 60, 45),
        Shadow = Color3.fromRGB(0, 0, 0),
        Success = Color3.fromRGB(46, 204, 113),
        Warning = Color3.fromRGB(241, 196, 15),
        Error = Color3.fromRGB(231, 76, 60),
        Info = Color3.fromRGB(52, 152, 219)
    },
    ["Rose"] = {
        Background = Color3.fromRGB(25, 15, 20),
        Container = Color3.fromRGB(35, 22, 28),
        Element = Color3.fromRGB(45, 30, 38),
        ElementHover = Color3.fromRGB(55, 38, 48),
        ElementClick = Color3.fromRGB(32, 20, 25),
        Accent = Color3.fromRGB(253, 121, 168),
        Text = Color3.fromRGB(255, 235, 242),
        SubText = Color3.fromRGB(170, 135, 148),
        Outline = Color3.fromRGB(65, 45, 55),
        Shadow = Color3.fromRGB(0, 0, 0),
        Success = Color3.fromRGB(46, 204, 113),
        Warning = Color3.fromRGB(241, 196, 15),
        Error = Color3.fromRGB(231, 76, 60),
        Info = Color3.fromRGB(52, 152, 219)
    },
    ["Graphite"] = {
        Background = Color3.fromRGB(20, 20, 20),
        Container = Color3.fromRGB(28, 28, 28),
        Element = Color3.fromRGB(38, 38, 38),
        ElementHover = Color3.fromRGB(48, 48, 48),
        ElementClick = Color3.fromRGB(25, 25, 25),
        Accent = Color3.fromRGB(120, 120, 120),
        Text = Color3.fromRGB(220, 220, 220),
        SubText = Color3.fromRGB(130, 130, 130),
        Outline = Color3.fromRGB(55, 55, 55),
        Shadow = Color3.fromRGB(0, 0, 0),
        Success = Color3.fromRGB(46, 204, 113),
        Warning = Color3.fromRGB(241, 196, 15),
        Error = Color3.fromRGB(231, 76, 60),
        Info = Color3.fromRGB(52, 152, 219)
    },
    ["Obsidian"] = {
        Background = Color3.fromRGB(5, 5, 5),
        Container = Color3.fromRGB(12, 12, 12),
        Element = Color3.fromRGB(18, 18, 18),
        ElementHover = Color3.fromRGB(24, 24, 24),
        ElementClick = Color3.fromRGB(10, 10, 10),
        Accent = Color3.fromRGB(200, 200, 200),
        Text = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(100, 100, 100),
        Outline = Color3.fromRGB(30, 30, 30),
        Shadow = Color3.fromRGB(0, 0, 0),
        Success = Color3.fromRGB(46, 204, 113),
        Warning = Color3.fromRGB(241, 196, 15),
        Error = Color3.fromRGB(231, 76, 60),
        Info = Color3.fromRGB(52, 152, 219)
    },
    ["Crystal"] = {
        Background = Color3.fromRGB(240, 245, 255),
        Container = Color3.fromRGB(250, 252, 255),
        Element = Color3.fromRGB(230, 238, 250),
        ElementHover = Color3.fromRGB(220, 230, 245),
        ElementClick = Color3.fromRGB(210, 220, 240),
        Accent = Color3.fromRGB(108, 92, 231),
        Text = Color3.fromRGB(30, 35, 45),
        SubText = Color3.fromRGB(100, 110, 130),
        Outline = Color3.fromRGB(210, 220, 240),
        Shadow = Color3.fromRGB(200, 210, 230),
        Success = Color3.fromRGB(46, 204, 113),
        Warning = Color3.fromRGB(241, 196, 15),
        Error = Color3.fromRGB(231, 76, 60),
        Info = Color3.fromRGB(52, 152, 219)
    },
    ["Frost"] = {
        Background = Color3.fromRGB(245, 245, 245),
        Container = Color3.fromRGB(255, 255, 255),
        Element = Color3.fromRGB(235, 235, 235),
        ElementHover = Color3.fromRGB(225, 225, 225),
        ElementClick = Color3.fromRGB(215, 215, 215),
        Accent = Color3.fromRGB(0, 206, 201),
        Text = Color3.fromRGB(40, 40, 40),
        SubText = Color3.fromRGB(120, 120, 120),
        Outline = Color3.fromRGB(220, 220, 220),
        Shadow = Color3.fromRGB(200, 200, 200),
        Success = Color3.fromRGB(46, 204, 113),
        Warning = Color3.fromRGB(241, 196, 15),
        Error = Color3.fromRGB(231, 76, 60),
        Info = Color3.fromRGB(52, 152, 219)
    }
}

local CurrentThemeName = "Midnight Slate"
local CurrentTheme = Themes[CurrentThemeName]
local ActiveThemeInstances = {}

-- ============================================================================== --
-- ADVANCED MATH & UTILITY LIBRARY
-- ============================================================================== --

local Utility = {}

function Utility:Create(className, properties)
    local inst = Instance.new(className)
    for k, v in pairs(properties) do
        if k ~= "Parent" then inst[k] = v end
    end
    if properties.Parent then inst.Parent = properties.Parent end
    return inst
end

function Utility:Tween(instance, properties, duration, style, direction)
    style = style or Enum.EasingStyle.Quart
    direction = direction or Enum.EasingDirection.Out
    duration = duration or 0.3
    local tweenInfo = TweenInfo.new(duration, style, direction)
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

function Utility:RegisterTheme(instance, prop, themeKey)
    table.insert(ActiveThemeInstances, {Instance = instance, Property = prop, Key = themeKey})
    if instance and instance.Parent then
        instance[prop] = CurrentTheme[themeKey]
    end
end

function Utility:UpdateTheme(themeName)
    if Themes[themeName] then
        CurrentThemeName = themeName
        CurrentTheme = Themes[themeName]
        for _, data in ipairs(ActiveThemeInstances) do
            if data.Instance and data.Instance.Parent then
                Utility:Tween(data.Instance, {[data.Property] = CurrentTheme[data.Key]}, 0.5)
            end
        end
    end
end

function Utility:Ripple(button)
    local clickX, clickY = Mouse.X, Mouse.Y
    local ripple = Utility:Create("Frame", {
        Name = "RippleEffect",
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.8,
        BorderSizePixel = 0,
        Position = UDim2.new(0, clickX - button.AbsolutePosition.X, 0, clickY - button.AbsolutePosition.Y),
        Size = UDim2.new(0, 0, 0, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex = button.ZIndex + 5,
        Parent = button
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = ripple})
    local size = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2.5
    Utility:Tween(ripple, {Size = UDim2.new(0, size, 0, size), BackgroundTransparency = 1}, 0.6, Enum.EasingStyle.Sine).Completed:Connect(function()
        ripple:Destroy()
    end)
end

function Utility:MakeDraggable(topbar, window)
    local dragging, dragInput, dragStart, startPos
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = window.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Utility:Tween(window, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}, 0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
        end
    end)
end

function Utility:GetTextBounds(text, font, size, width)
    local textBounds = TextService:GetTextSize(text, size, font, Vector2.new(width or math.huge, math.huge))
    return textBounds
end

function Utility:RGBToHSV(color)
    local r, g, b = color.R, color.G, color.B
    local max, min = math.max(r, g, b), math.min(r, g, b)
    local h, s, v
    v = max
    local d = max - min
    if max == 0 then s = 0 else s = d / max end
    if max == min then
        h = 0
    else
        if max == r then h = (g - b) / d + (g < b and 6 or 0)
        elseif max == g then h = (b - r) / d + 2
        elseif max == b then h = (r - g) / d + 4 end
        h = h / 6
    end
    return h, s, v
end

-- ============================================================================== --
-- XREZT HUB FRAMEWORK ARCHITECTURE
-- ============================================================================== --

local XreztHub = {}
local Connections = {}
local Dropdowns = {}
local ColorPickers = {}
local Popups = {}
local NotificationsContainer

-- ============================================================================== --
-- MOTION GRAPHICS LOADING SEQUENCE
-- ============================================================================== --

function XreztHub:Load()
    local ScreenGui = Utility:Create("ScreenGui", {
        Name = "XreztLoadingScreen",
        DisplayOrder = 1000,
        IgnoreGuiInset = true,
        ResetOnSpawn = false
    })
    ProtectGUI(ScreenGui)

    local Background = Utility:Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(10, 10, 12),
        Parent = ScreenGui
    })

    local CenterAnim = Utility:Create("Frame", {
        Size = UDim2.new(0, 140, 0, 140),
        Position = UDim2.new(0.5, -70, 0.45, -70),
        BackgroundTransparency = 1,
        Parent = Background
    })

    -- Motion Graphics: Outer Ring
    local OuterRing = Utility:Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Parent = CenterAnim
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = OuterRing})
    local OuterStroke = Utility:Create("UIStroke", {
        Color = Color3.fromRGB(255, 255, 255),
        Thickness = 2,
        Transparency = 1,
        Parent = OuterRing
    })
    local UIGradientOuter = Utility:Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, CurrentTheme.Accent),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(150, 80, 255)),
            ColorSequenceKeypoint.new(1, CurrentTheme.Accent)
        }),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.5, 0),
            NumberSequenceKeypoint.new(1, 1)
        }),
        Rotation = 0,
        Parent = OuterRing
    })

    -- Motion Graphics: Inner Ring
    local InnerRing = Utility:Create("Frame", {
        Size = UDim2.new(0.7, 0, 0.7, 0),
        Position = UDim2.new(0.15, 0, 0.15, 0),
        BackgroundTransparency = 1,
        Parent = CenterAnim
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = InnerRing})
    local InnerStroke = Utility:Create("UIStroke", {
        Color = CurrentTheme.Accent,
        Thickness = 4,
        Transparency = 1,
        Parent = InnerRing
    })
    local UIGradientInner = Utility:Create("UIGradient", {
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(0.5, 1),
            NumberSequenceKeypoint.new(1, 0)
        }),
        Rotation = 0,
        Parent = InnerRing
    })

    local GlowCore = Utility:Create("ImageLabel", {
        Size = UDim2.new(2.5, 0, 2.5, 0),
        Position = UDim2.new(-0.75, 0, -0.75, 0),
        BackgroundTransparency = 1,
        Image = "rbxassetid://5028857084",
        ImageColor3 = CurrentTheme.Accent,
        ImageTransparency = 1,
        Parent = CenterAnim
    })

    local LoadingText = Utility:Create("TextLabel", {
        Size = UDim2.new(0, 300, 0, 40),
        Position = UDim2.new(0.5, -150, 0.55, 50),
        BackgroundTransparency = 1,
        Text = "XREZT HUB",
        Font = Enum.Font.GothamBold,
        TextSize = 32,
        TextColor3 = CurrentTheme.Text,
        TextTransparency = 1,
        Parent = Background
    })

    local SubtitleText = Utility:Create("TextLabel", {
        Size = UDim2.new(0, 300, 0, 20),
        Position = UDim2.new(0.5, -150, 0.55, 90),
        BackgroundTransparency = 1,
        Text = "Architecting User Interface...",
        Font = Enum.Font.GothamMedium,
        TextSize = 14,
        TextColor3 = CurrentTheme.SubText,
        TextTransparency = 1,
        Parent = Background
    })

    -- Animations Start
    Utility:Tween(OuterStroke, {Transparency = 0}, 1)
    Utility:Tween(InnerStroke, {Transparency = 0}, 1)
    Utility:Tween(GlowCore, {ImageTransparency = 0.5}, 1)
    Utility:Tween(LoadingText, {TextTransparency = 0, Position = UDim2.new(0.5, -150, 0.55, 30)}, 1, Enum.EasingStyle.Exponential)
    Utility:Tween(SubtitleText, {TextTransparency = 0, Position = UDim2.new(0.5, -150, 0.55, 70)}, 1, Enum.EasingStyle.Exponential)

    local rot = 0
    local conn = RunService.RenderStepped:Connect(function(dt)
        rot = rot + (dt * 120)
        UIGradientOuter.Rotation = rot
        UIGradientInner.Rotation = -rot * 1.5
        GlowCore.Size = UDim2.new(2.5 + math.sin(rot/50)*0.2, 0, 2.5 + math.sin(rot/50)*0.2, 0)
        GlowCore.Position = UDim2.new(-0.75 - math.sin(rot/50)*0.1, 0, -0.75 - math.sin(rot/50)*0.1, 0)
    end)

    -- Staged Text Updates
    task.wait(0.8)
    SubtitleText.Text = "Compiling Tween Engine..."
    task.wait(0.8)
    SubtitleText.Text = "Generating Component Hierarchy..."
    task.wait(0.8)
    SubtitleText.Text = "Applying Aesthetics..."
    task.wait(0.8)

    -- Fade Out Sequence
    Utility:Tween(OuterStroke, {Transparency = 1}, 0.5)
    Utility:Tween(InnerStroke, {Transparency = 1}, 0.5)
    Utility:Tween(GlowCore, {ImageTransparency = 1}, 0.5)
    Utility:Tween(LoadingText, {TextTransparency = 1, Position = UDim2.new(0.5, -150, 0.55, 10)}, 0.5)
    Utility:Tween(SubtitleText, {TextTransparency = 1, Position = UDim2.new(0.5, -150, 0.55, 50)}, 0.5)
    
    task.wait(0.5)
    conn:Disconnect()
    Utility:Tween(Background, {BackgroundTransparency = 1}, 0.5).Completed:Wait()
    ScreenGui:Destroy()
end

-- ============================================================================== --
-- WINDOW CREATION & CORE HIERARCHY
-- ============================================================================== --

function XreztHub:CreateWindow(config)
    config = config or {}
    local Title = config.Title or "Xrezt Hub"
    local Subtitle = config.Subtitle or "Premium Framework"
    local Width = config.Width or 650
    local Height = config.Height or 450

    local MainGui = Utility:Create("ScreenGui", {
        Name = "XreztHub_Workspace",
        ResetOnSpawn = false,
        IgnoreGuiInset = true
    })
    ProtectGUI(MainGui)

    -- Input Intercept Layer for closing Dropdowns/Popups
    local InputLayer = Utility:Create("TextButton", {
        Name = "InputLayer",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 1,
        Parent = MainGui
    })

    InputLayer.MouseButton1Click:Connect(function()
        for _, drop in pairs(Dropdowns) do
            if drop.Expanded then drop:Close() end
        end
        for _, cp in pairs(ColorPickers) do
            if cp.Expanded then cp:Close() end
        end
    end)

    -- Notification Container (Right aligned)
    NotificationsContainer = Utility:Create("Frame", {
        Name = "Notifications",
        Size = UDim2.new(0, 320, 1, -40),
        Position = UDim2.new(1, -340, 0, 20),
        BackgroundTransparency = 1,
        ZIndex = 100,
        Parent = MainGui
    })
    Utility:Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 12),
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Parent = NotificationsContainer
    })

    -- CanvasGroup for Window to prevent Transparency/Minimize bugs
    local MainFrame = Utility:Create("CanvasGroup", {
        Name = "MainFrame",
        Size = UDim2.new(0, Width, 0, Height),
        Position = UDim2.new(0.5, -Width/2, 0.5, -Height/2),
        BackgroundColor3 = CurrentTheme.Background,
        GroupTransparency = 1,
        ZIndex = 10,
        Parent = MainGui
    })
    Utility:RegisterTheme(MainFrame, "BackgroundColor3", "Background")
    Utility:Create("UICorner", {CornerRadius = UDim.new(0, 16), Parent = MainFrame})
    Utility:Create("UIStroke", {Color = CurrentTheme.Outline, Thickness = 1, Parent = MainFrame})
    Utility:RegisterTheme(MainFrame.UIStroke, "Color", "Outline")
    
    -- Drop shadow emulation via ImageLabel (since CanvasGroup clips descendants, we put it under ScreenGui mapped to position)
    local DropShadow = Utility:Create("ImageLabel", {
        Name = "DropShadow",
        Size = UDim2.new(0, Width + 60, 0, Height + 60),
        Position = UDim2.new(0.5, -(Width+60)/2, 0.5, -(Height+60)/2),
        BackgroundTransparency = 1,
        Image = "rbxassetid://6015897843",
        ImageColor3 = Color3.fromRGB(0,0,0),
        ImageTransparency = 1,
        SliceCenter = Rect.new(49, 49, 450, 450),
        ZIndex = 9,
        Parent = MainGui
    })

    -- Animate Window In
    Utility:Tween(MainFrame, {GroupTransparency = 0}, 0.8, Enum.EasingStyle.Exponential)
    Utility:Tween(DropShadow, {ImageTransparency = 0.5}, 0.8, Enum.EasingStyle.Exponential)
    
    -- Shadow Sync
    MainFrame:GetPropertyChangedSignal("Position"):Connect(function()
        DropShadow.Position = UDim2.new(0, MainFrame.Position.X.Offset - 30, 0, MainFrame.Position.Y.Offset - 30)
    end)
    MainFrame:GetPropertyChangedSignal("Size"):Connect(function()
        DropShadow.Size = UDim2.new(0, MainFrame.Size.X.Offset + 60, 0, MainFrame.Size.Y.Offset + 60)
        DropShadow.Position = UDim2.new(0, MainFrame.Position.X.Offset - 30, 0, MainFrame.Position.Y.Offset - 30)
    end)

    -- Window Header
    local Header = Utility:Create("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 60),
        BackgroundColor3 = CurrentTheme.Container,
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        ZIndex = 11,
        Parent = MainFrame
    })
    Utility:RegisterTheme(Header, "BackgroundColor3", "Container")
    Utility:MakeDraggable(Header, MainFrame)

    local HeaderDiv = Utility:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = CurrentTheme.Outline,
        BorderSizePixel = 0,
        Parent = Header
    })
    Utility:RegisterTheme(HeaderDiv, "BackgroundColor3", "Outline")

    local TitleLabel = Utility:Create("TextLabel", {
        Size = UDim2.new(0, 200, 0, 25),
        Position = UDim2.new(0, 25, 0, 10),
        BackgroundTransparency = 1,
        Text = Title,
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        TextColor3 = CurrentTheme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Header
    })
    Utility:RegisterTheme(TitleLabel, "TextColor3", "Text")

    local SubtitleLabel = Utility:Create("TextLabel", {
        Size = UDim2.new(0, 200, 0, 15),
        Position = UDim2.new(0, 25, 0, 35),
        BackgroundTransparency = 1,
        Text = Subtitle,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextColor3 = CurrentTheme.SubText,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Header
    })
    Utility:RegisterTheme(SubtitleLabel, "TextColor3", "SubText")

    -- Search Bar in Header
    local SearchFrame = Utility:Create("Frame", {
        Size = UDim2.new(0, 200, 0, 36),
        Position = UDim2.new(1, -225, 0.5, -18),
        BackgroundColor3 = CurrentTheme.Element,
        Parent = Header
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = SearchFrame})
    Utility:RegisterTheme(SearchFrame, "BackgroundColor3", "Element")
    Utility:Create("UIStroke", {Color = CurrentTheme.Outline, Thickness = 1, Parent = SearchFrame})
    Utility:RegisterTheme(SearchFrame.UIStroke, "Color", "Outline")

    local SearchIcon = Utility:Create("ImageLabel", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0, 12, 0.5, -8),
        BackgroundTransparency = 1,
        Image = "rbxassetid://6031154871",
        ImageColor3 = CurrentTheme.SubText,
        Parent = SearchFrame
    })
    Utility:RegisterTheme(SearchIcon, "ImageColor3", "SubText")

    local SearchBox = Utility:Create("TextBox", {
        Size = UDim2.new(1, -40, 1, 0),
        Position = UDim2.new(0, 35, 0, 0),
        BackgroundTransparency = 1,
        Text = "",
        PlaceholderText = "Search...",
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextColor3 = CurrentTheme.Text,
        PlaceholderColor3 = CurrentTheme.SubText,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = SearchFrame
    })
    Utility:RegisterTheme(SearchBox, "TextColor3", "Text")
    Utility:RegisterTheme(SearchBox, "PlaceholderColor3", "SubText")

    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = string.lower(SearchBox.Text)
        for _, tab in pairs(MainFrame.PageContainer:GetChildren()) do
            if tab:IsA("ScrollingFrame") then
                for _, elem in pairs(tab:GetChildren()) do
                    if elem:IsA("Frame") or elem:IsA("TextButton") then
                        local nameLabel = elem:FindFirstChild("TitleLabel") or elem:FindFirstChild("TextLabel")
                        if nameLabel and nameLabel:IsA("TextLabel") then
                            if query == "" or string.find(string.lower(nameLabel.Text), query) then
                                elem.Visible = true
                            else
                                elem.Visible = false
                            end
                        end
                    end
                end
            end
        end
    end)

    -- Tab System Containers
    local TabContainer = Utility:Create("ScrollingFrame", {
        Name = "TabContainer",
        Size = UDim2.new(0, 180, 1, -80),
        Position = UDim2.new(0, 15, 0, 75),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        Parent = MainFrame
    })
    Utility:Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
        Parent = TabContainer
    })

    local PageContainer = Utility:Create("Frame", {
        Name = "PageContainer",
        Size = UDim2.new(1, -215, 1, -80),
        Position = UDim2.new(0, 205, 0, 75),
        BackgroundTransparency = 1,
        Parent = MainFrame
    })

    -- Dialog / Popup Layer
    local DialogLayer = Utility:Create("Frame", {
        Name = "DialogLayer",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(0,0,0),
        BackgroundTransparency = 1,
        Visible = false,
        ZIndex = 50,
        Parent = MainFrame
    })

    -- Floating Launcher Button
    local SpawnerBtn = Utility:Create("TextButton", {
        Size = UDim2.new(0, 50, 0, 50),
        Position = UDim2.new(0.9, -60, 0.1, 0),
        BackgroundColor3 = CurrentTheme.Container,
        Text = "X",
        Font = Enum.Font.GothamBold,
        TextSize = 22,
        TextColor3 = CurrentTheme.Accent,
        ZIndex = 100,
        Parent = MainGui
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = SpawnerBtn})
    Utility:Create("UIStroke", {Color = CurrentTheme.Outline, Thickness = 2, Parent = SpawnerBtn})
    Utility:RegisterTheme(SpawnerBtn, "BackgroundColor3", "Container")
    Utility:RegisterTheme(SpawnerBtn, "TextColor3", "Accent")
    Utility:RegisterTheme(SpawnerBtn.UIStroke, "Color", "Outline")
    Utility:MakeDraggable(SpawnerBtn, SpawnerBtn)

    local isVisible = true
    SpawnerBtn.MouseButton1Click:Connect(function()
        isVisible = not isVisible
        Utility:Ripple(SpawnerBtn)
        if isVisible then
            MainFrame.Visible = true
            DropShadow.Visible = true
            Utility:Tween(MainFrame, {Size = UDim2.new(0, Width, 0, Height), GroupTransparency = 0}, 0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
            Utility:Tween(DropShadow, {ImageTransparency = 0.5, Size = UDim2.new(0, Width+60, 0, Height+60)}, 0.5)
        else
            Utility:Tween(MainFrame, {Size = UDim2.new(0, Width*0.9, 0, Height*0.9), GroupTransparency = 1}, 0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.In).Completed:Connect(function()
                MainFrame.Visible = false
            end)
            Utility:Tween(DropShadow, {ImageTransparency = 1, Size = UDim2.new(0, (Width*0.9)+60, 0, (Height*0.9)+60)}, 0.4).Completed:Connect(function()
                DropShadow.Visible = false
            end)
        end
    end)

    -- Window Object
    local WindowObj = {
        ActiveTab = nil,
        First = true,
        Tabs = {}
    }

    -- ============================================================================== --
    -- DIALOG SYSTEM (PROMPTS)
    -- ============================================================================== --
    function WindowObj:Dialog(opts)
        local dTitle = opts.Title or "Prompt"
        local dContent = opts.Content or "Are you sure?"
        local dButtons = opts.Buttons or {}

        DialogLayer.Visible = true
        Utility:Tween(DialogLayer, {BackgroundTransparency = 0.4}, 0.3)

        local DialogBox = Utility:Create("Frame", {
            Size = UDim2.new(0, 300, 0, 150),
            Position = UDim2.new(0.5, -150, 0.4, -75),
            BackgroundColor3 = CurrentTheme.Container,
            ZIndex = 51,
            Parent = DialogLayer
        })
        Utility:Create("UICorner", {CornerRadius = UDim.new(0, 16), Parent = DialogBox})
        Utility:Create("UIStroke", {Color = CurrentTheme.Outline, Thickness = 1, Parent = DialogBox})
        Utility:RegisterTheme(DialogBox, "BackgroundColor3", "Container")
        Utility:RegisterTheme(DialogBox.UIStroke, "Color", "Outline")
        
        -- Dialog Animation In
        Utility:Tween(DialogBox, {Position = UDim2.new(0.5, -150, 0.5, -75)}, 0.4, Enum.EasingStyle.Back)

        Utility:Create("TextLabel", {
            Size = UDim2.new(1, -40, 0, 30),
            Position = UDim2.new(0, 20, 0, 15),
            BackgroundTransparency = 1,
            Text = dTitle,
            Font = Enum.Font.GothamBold,
            TextSize = 18,
            TextColor3 = CurrentTheme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 52,
            Parent = DialogBox
        })

        Utility:Create("TextLabel", {
            Size = UDim2.new(1, -40, 0, 40),
            Position = UDim2.new(0, 20, 0, 45),
            BackgroundTransparency = 1,
            Text = dContent,
            Font = Enum.Font.GothamMedium,
            TextSize = 13,
            TextColor3 = CurrentTheme.SubText,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            ZIndex = 52,
            Parent = DialogBox
        })

        local BtnContainer = Utility:Create("Frame", {
            Size = UDim2.new(1, -40, 0, 35),
            Position = UDim2.new(0, 20, 1, -50),
            BackgroundTransparency = 1,
            ZIndex = 52,
            Parent = DialogBox
        })
        Utility:Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10),
            Parent = BtnContainer
        })

        local function CloseDialog()
            Utility:Tween(DialogBox, {Position = UDim2.new(0.5, -150, 0.6, -75), GroupTransparency = 1}, 0.3, Enum.EasingStyle.Sine)
            Utility:Tween(DialogLayer, {BackgroundTransparency = 1}, 0.3).Completed:Connect(function()
                DialogBox:Destroy()
                DialogLayer.Visible = false
            end)
        end

        for _, btn in ipairs(dButtons) do
            local dBtn = Utility:Create("TextButton", {
                Size = UDim2.new(0, 80, 1, 0),
                BackgroundColor3 = CurrentTheme.Element,
                Text = btn.Title or "OK",
                Font = Enum.Font.GothamMedium,
                TextSize = 13,
                TextColor3 = CurrentTheme.Text,
                AutoButtonColor = false,
                ZIndex = 53,
                Parent = BtnContainer
            })
            Utility:Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = dBtn})
            Utility:Create("UIStroke", {Color = CurrentTheme.Outline, Thickness = 1, Parent = dBtn})
            Utility:RegisterTheme(dBtn, "BackgroundColor3", "Element")
            Utility:RegisterTheme(dBtn, "TextColor3", "Text")
            
            dBtn.MouseEnter:Connect(function() Utility:Tween(dBtn, {BackgroundColor3 = CurrentTheme.ElementHover}, 0.2) end)
            dBtn.MouseLeave:Connect(function() Utility:Tween(dBtn, {BackgroundColor3 = CurrentTheme.Element}, 0.2) end)
            dBtn.MouseButton1Click:Connect(function()
                Utility:Ripple(dBtn)
                if btn.Callback then btn.Callback() end
                CloseDialog()
            end)
        end
    end

    -- ============================================================================== --
    -- TAB SYSTEM
    -- ============================================================================== --

    function WindowObj:CreateTab(tabName, iconId)
        local TabBtn = Utility:Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 42),
            BackgroundColor3 = CurrentTheme.Element,
            BackgroundTransparency = 1,
            Text = "",
            Parent = TabContainer
        })
        Utility:Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = TabBtn})
        Utility:RegisterTheme(TabBtn, "BackgroundColor3", "Element")

        local TabIndicator = Utility:Create("Frame", {
            Size = UDim2.new(0, 4, 0, 0),
            Position = UDim2.new(0, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundColor3 = CurrentTheme.Accent,
            Parent = TabBtn
        })
        Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = TabIndicator})
        Utility:RegisterTheme(TabIndicator, "BackgroundColor3", "Accent")

        local IconOffset = iconId and 35 or 20

        if iconId then
            local Icon = Utility:Create("ImageLabel", {
                Size = UDim2.new(0, 18, 0, 18),
                Position = UDim2.new(0, 12, 0.5, -9),
                BackgroundTransparency = 1,
                Image = iconId,
                ImageColor3 = CurrentTheme.SubText,
                Parent = TabBtn
            })
            Utility:RegisterTheme(Icon, "ImageColor3", "SubText")
            -- We'll attach icon to Tab data to animate it
            TabBtn:SetAttribute("HasIcon", true)
        end

        local TabText = Utility:Create("TextLabel", {
            Size = UDim2.new(1, -IconOffset - 10, 1, 0),
            Position = UDim2.new(0, IconOffset, 0, 0),
            BackgroundTransparency = 1,
            Text = tabName,
            Font = Enum.Font.GothamMedium,
            TextSize = 14,
            TextColor3 = CurrentTheme.SubText,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = TabBtn
        })
        Utility:RegisterTheme(TabText, "TextColor3", "SubText")

        local Page = Utility:Create("ScrollingFrame", {
            Name = tabName.."_Page",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = CurrentTheme.Outline,
            Visible = false,
            Parent = PageContainer
        })
        Utility:RegisterTheme(Page, "ScrollBarImageColor3", "Outline")
        Utility:Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10),
            Parent = Page
        })
        Utility:Create("UIPadding", {
            PaddingTop = UDim.new(0, 2),
            PaddingBottom = UDim.new(0, 15),
            PaddingRight = UDim.new(0, 10),
            Parent = Page
        })

        Page.ChildAdded:Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, Page.UIListLayout.AbsoluteContentSize.Y + 20)
        end)

        local function ActivateTab()
            if WindowObj.ActiveTab == TabBtn then return end
            if WindowObj.ActiveTab then
                Utility:Tween(WindowObj.ActiveTab.Indicator, {Size = UDim2.new(0, 4, 0, 0)}, 0.3)
                Utility:Tween(WindowObj.ActiveTab.Text, {TextColor3 = CurrentTheme.SubText}, 0.3)
                if WindowObj.ActiveTab.Btn:GetAttribute("HasIcon") then
                    Utility:Tween(WindowObj.ActiveTab.Btn:FindFirstChildOfClass("ImageLabel"), {ImageColor3 = CurrentTheme.SubText}, 0.3)
                end
                Utility:Tween(WindowObj.ActiveTab.Btn, {BackgroundTransparency = 1}, 0.3)
                
                -- Page Out Anim
                local oldPage = WindowObj.ActiveTab.Page
                Utility:Tween(oldPage, {Position = UDim2.new(0, -30, 0, 0)}, 0.3).Completed:Connect(function()
                    oldPage.Visible = false
                end)
            end

            WindowObj.ActiveTab = {Btn = TabBtn, Indicator = TabIndicator, Text = TabText, Page = Page}
            
            Utility:Tween(TabIndicator, {Size = UDim2.new(0, 4, 0, 24)}, 0.4, Enum.EasingStyle.Back)
            Utility:Tween(TabText, {TextColor3 = CurrentTheme.Text}, 0.3)
            if TabBtn:GetAttribute("HasIcon") then
                Utility:Tween(TabBtn:FindFirstChildOfClass("ImageLabel"), {ImageColor3 = CurrentTheme.Accent}, 0.3)
            end
            Utility:Tween(TabBtn, {BackgroundTransparency = 0}, 0.3)
            
            -- Page In Anim
            Page.Visible = true
            Page.Position = UDim2.new(0, 30, 0, 0)
            Utility:Tween(Page, {Position = UDim2.new(0, 0, 0, 0)}, 0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        end

        TabBtn.MouseButton1Click:Connect(function()
            Utility:Ripple(TabBtn)
            ActivateTab()
        end)

        if WindowObj.First then
            WindowObj.First = false
            ActivateTab()
        end

        -- ============================================================================== --
        -- COMPONENT CREATION (THE MEAT OF THE FRAMEWORK)
        -- ============================================================================== --
        local TabObj = {}

        -- [ SECTION ]
        function TabObj:CreateSection(name)
            local SecFrame = Utility:Create("Frame", {
                Name = "Section",
                Size = UDim2.new(1, 0, 0, 35),
                BackgroundTransparency = 1,
                Parent = Page
            })
            Utility:Create("TextLabel", {
                Size = UDim2.new(1, 0, 1, 0),
                Position = UDim2.new(0, 5, 0, 10),
                BackgroundTransparency = 1,
                Text = name,
                Font = Enum.Font.GothamBold,
                TextSize = 15,
                TextColor3 = CurrentTheme.Accent,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = SecFrame
            })
            Utility:RegisterTheme(SecFrame:FindFirstChildOfClass("TextLabel"), "TextColor3", "Accent")
        end

        -- [ DIVIDER ]
        function TabObj:CreateDivider()
            local DivFrame = Utility:Create("Frame", {
                Size = UDim2.new(1, 0, 0, 15),
                BackgroundTransparency = 1,
                Parent = Page
            })
            local Line = Utility:Create("Frame", {
                Size = UDim2.new(1, -10, 0, 1),
                Position = UDim2.new(0, 5, 0.5, 0),
                BackgroundColor3 = CurrentTheme.Outline,
                BorderSizePixel = 0,
                Parent = DivFrame
            })
            Utility:RegisterTheme(Line, "BackgroundColor3", "Outline")
        end

        -- [ LABEL / PARAGRAPH ]
        function TabObj:CreateLabel(opts)
            local lText = opts.Text or "Label"
            local lDesc = opts.Description or ""
            
            local height = lDesc == "" and 30 or 50
            local LblFrame = Utility:Create("Frame", {
                Size = UDim2.new(1, 0, 0, height),
                BackgroundTransparency = 1,
                Parent = Page
            })
            
            local Txt = Utility:Create("TextLabel", {
                Name = "TitleLabel",
                Size = UDim2.new(1, -10, 0, 20),
                Position = UDim2.new(0, 5, 0, 5),
                BackgroundTransparency = 1,
                Text = lText,
                Font = Enum.Font.GothamMedium,
                TextSize = 14,
                TextColor3 = CurrentTheme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = LblFrame
            })
            Utility:RegisterTheme(Txt, "TextColor3", "Text")

            if lDesc ~= "" then
                local Desc = Utility:Create("TextLabel", {
                    Size = UDim2.new(1, -10, 0, 20),
                    Position = UDim2.new(0, 5, 0, 25),
                    BackgroundTransparency = 1,
                    Text = lDesc,
                    Font = Enum.Font.GothamMedium,
                    TextSize = 12,
                    TextColor3 = CurrentTheme.SubText,
                    TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Top,
                    Parent = LblFrame
                })
                Utility:RegisterTheme(Desc, "TextColor3", "SubText")
            end
        end

        -- [ BUTTON ]
        function TabObj:CreateButton(opts)
            local bName = opts.Name or "Button"
            local bDesc = opts.Description or ""
            local bCb = opts.Callback or function() end

            local BtnFrame = Utility:Create("TextButton", {
                Size = UDim2.new(1, 0, 0, bDesc == "" and 45 or 60),
                BackgroundColor3 = CurrentTheme.Element,
                Text = "",
                AutoButtonColor = false,
                Parent = Page
            })
            Utility:Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = BtnFrame})
            Utility:Create("UIStroke", {Color = CurrentTheme.Outline, Thickness = 1, Parent = BtnFrame})
            Utility:RegisterTheme(BtnFrame, "BackgroundColor3", "Element")
            Utility:RegisterTheme(BtnFrame.UIStroke, "Color", "Outline")
            
            Utility:Create("TextLabel", {
                Name = "TitleLabel",
                Size = UDim2.new(1, -40, 0, 20),
                Position = UDim2.new(0, 15, 0, bDesc == "" and 12 or 10),
                BackgroundTransparency = 1,
                Text = bName,
                Font = Enum.Font.GothamMedium,
                TextSize = 14,
                TextColor3 = CurrentTheme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = BtnFrame
            })
            Utility:RegisterTheme(BtnFrame.TitleLabel, "TextColor3", "Text")

            if bDesc ~= "" then
                Utility:Create("TextLabel", {
                    Size = UDim2.new(1, -40, 0, 15),
                    Position = UDim2.new(0, 15, 0, 32),
                    BackgroundTransparency = 1,
                    Text = bDesc,
                    Font = Enum.Font.GothamMedium,
                    TextSize = 12,
                    TextColor3 = CurrentTheme.SubText,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = BtnFrame
                })
                Utility:RegisterTheme(BtnFrame:GetChildren()[4], "TextColor3", "SubText")
            end

            local Arrow = Utility:Create("ImageLabel", {
                Size = UDim2.new(0, 20, 0, 20),
                Position = UDim2.new(1, -35, 0.5, -10),
                BackgroundTransparency = 1,
                Image = "rbxassetid://6031090990",
                ImageColor3 = CurrentTheme.SubText,
                Parent = BtnFrame
            })
            Utility:RegisterTheme(Arrow, "ImageColor3", "SubText")

            BtnFrame.MouseEnter:Connect(function() 
                Utility:Tween(BtnFrame, {BackgroundColor3 = CurrentTheme.ElementHover}, 0.2)
                Utility:Tween(Arrow, {Position = UDim2.new(1, -30, 0.5, -10), ImageColor3 = CurrentTheme.Text}, 0.2)
            end)
            BtnFrame.MouseLeave:Connect(function() 
                Utility:Tween(BtnFrame, {BackgroundColor3 = CurrentTheme.Element}, 0.2)
                Utility:Tween(Arrow, {Position = UDim2.new(1, -35, 0.5, -10), ImageColor3 = CurrentTheme.SubText}, 0.2)
            end)
            BtnFrame.MouseButton1Down:Connect(function() Utility:Tween(BtnFrame, {BackgroundColor3 = CurrentTheme.ElementClick}, 0.1) end)
            BtnFrame.MouseButton1Up:Connect(function()
                Utility:Tween(BtnFrame, {BackgroundColor3 = CurrentTheme.ElementHover}, 0.1)
                Utility:Ripple(BtnFrame)
                bCb()
            end)
        end

        -- [ TOGGLE ]
        function TabObj:CreateToggle(opts)
            local tName = opts.Name or "Toggle"
            local state = opts.Default or false
            local tCb = opts.Callback or function() end

            local TogFrame = Utility:Create("TextButton", {
                Size = UDim2.new(1, 0, 0, 45),
                BackgroundColor3 = CurrentTheme.Element,
                Text = "",
                AutoButtonColor = false,
                Parent = Page
            })
            Utility:Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = TogFrame})
            Utility:Create("UIStroke", {Color = CurrentTheme.Outline, Thickness = 1, Parent = TogFrame})
            Utility:RegisterTheme(TogFrame, "BackgroundColor3", "Element")
            Utility:RegisterTheme(TogFrame.UIStroke, "Color", "Outline")

            Utility:Create("TextLabel", {
                Name = "TitleLabel",
                Size = UDim2.new(1, -70, 1, 0),
                Position = UDim2.new(0, 15, 0, 0),
                BackgroundTransparency = 1,
                Text = tName,
                Font = Enum.Font.GothamMedium,
                TextSize = 14,
                TextColor3 = CurrentTheme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = TogFrame
            })
            Utility:RegisterTheme(TogFrame.TitleLabel, "TextColor3", "Text")

            local Switch = Utility:Create("Frame", {
                Size = UDim2.new(0, 42, 0, 22),
                Position = UDim2.new(1, -55, 0.5, -11),
                BackgroundColor3 = state and CurrentTheme.Accent or CurrentTheme.Container,
                Parent = TogFrame
            })
            Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Switch})
            
            local Thumb = Utility:Create("Frame", {
                Size = UDim2.new(0, 16, 0, 16),
                Position = UDim2.new(0, state and 23 or 3, 0.5, -8),
                BackgroundColor3 = Color3.fromRGB(255,255,255),
                Parent = Switch
            })
            Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Thumb})

            local function Fire()
                state = not state
                Utility:Tween(Switch, {BackgroundColor3 = state and CurrentTheme.Accent or CurrentTheme.Container}, 0.3)
                Utility:Tween(Thumb, {Position = UDim2.new(0, state and 23 or 3, 0.5, -8)}, 0.3, Enum.EasingStyle.Back)
                tCb(state)
            end

            TogFrame.MouseEnter:Connect(function() Utility:Tween(TogFrame, {BackgroundColor3 = CurrentTheme.ElementHover}, 0.2) end)
            TogFrame.MouseLeave:Connect(function() Utility:Tween(TogFrame, {BackgroundColor3 = CurrentTheme.Element}, 0.2) end)
            TogFrame.MouseButton1Click:Connect(function() Utility:Ripple(TogFrame) Fire() end)
            
            -- Manual theme register override for dynamic toggle color
            table.insert(ActiveThemeInstances, {Instance = Switch, Property = "BackgroundColor3", Key = state and "Accent" or "Container"})
            
            if state then tCb(state) end
        end

        -- [ SLIDER ]
        function TabObj:CreateSlider(opts)
            local sName = opts.Name or "Slider"
            local min, max, val = opts.Min or 0, opts.Max or 100, opts.Default or opts.Min or 0
            local sCb = opts.Callback or function() end

            local SldFrame = Utility:Create("Frame", {
                Size = UDim2.new(1, 0, 0, 65),
                BackgroundColor3 = CurrentTheme.Element,
                Parent = Page
            })
            Utility:Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = SldFrame})
            Utility:Create("UIStroke", {Color = CurrentTheme.Outline, Thickness = 1, Parent = SldFrame})
            Utility:RegisterTheme(SldFrame, "BackgroundColor3", "Element")
            Utility:RegisterTheme(SldFrame.UIStroke, "Color", "Outline")

            Utility:Create("TextLabel", {
                Name = "TitleLabel",
                Size = UDim2.new(1, -100, 0, 25),
                Position = UDim2.new(0, 15, 0, 10),
                BackgroundTransparency = 1,
                Text = sName,
                Font = Enum.Font.GothamMedium,
                TextSize = 14,
                TextColor3 = CurrentTheme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = SldFrame
            })
            Utility:RegisterTheme(SldFrame.TitleLabel, "TextColor3", "Text")

            -- Input Box for Slider
            local ValBox = Utility:Create("TextBox", {
                Size = UDim2.new(0, 50, 0, 25),
                Position = UDim2.new(1, -65, 0, 10),
                BackgroundColor3 = CurrentTheme.Container,
                Text = tostring(val),
                Font = Enum.Font.GothamMedium,
                TextSize = 13,
                TextColor3 = CurrentTheme.Accent,
                Parent = SldFrame
            })
            Utility:Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = ValBox})
            Utility:RegisterTheme(ValBox, "BackgroundColor3", "Container")
            Utility:RegisterTheme(ValBox, "TextColor3", "Accent")

            local Track = Utility:Create("TextButton", {
                Size = UDim2.new(1, -30, 0, 6),
                Position = UDim2.new(0, 15, 0, 45),
                BackgroundColor3 = CurrentTheme.Container,
                Text = "",
                AutoButtonColor = false,
                Parent = SldFrame
            })
            Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Track})
            Utility:RegisterTheme(Track, "BackgroundColor3", "Container")

            local Fill = Utility:Create("Frame", {
                Size = UDim2.new((val - min) / (max - min), 0, 1, 0),
                BackgroundColor3 = CurrentTheme.Accent,
                Parent = Track
            })
            Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Fill})
            Utility:RegisterTheme(Fill, "BackgroundColor3", "Accent")

            local Thumb = Utility:Create("Frame", {
                Size = UDim2.new(0, 14, 0, 14),
                Position = UDim2.new(1, -7, 0.5, -7),
                BackgroundColor3 = Color3.fromRGB(255,255,255),
                Parent = Fill
            })
            Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Thumb})

            local function SetValue(v)
                val = math.clamp(v, min, max)
                ValBox.Text = tostring(val)
                local perc = (val - min) / (max - min)
                Utility:Tween(Fill, {Size = UDim2.new(perc, 0, 1, 0)}, 0.1)
                sCb(val)
            end

            local dragging = false
            Track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    Utility:Tween(Thumb, {Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(1, -9, 0.5, -9)}, 0.2)
                    local pos = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                    SetValue(math.floor(min + (max - min) * pos))
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                    Utility:Tween(Thumb, {Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(1, -7, 0.5, -7)}, 0.2)
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    local pos = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                    SetValue(math.floor(min + (max - min) * pos))
                end
            end)

            ValBox.FocusLost:Connect(function()
                local num = tonumber(ValBox.Text)
                if num then SetValue(num) else ValBox.Text = tostring(val) end
            end)

            sCb(val)
        end

        -- [ DROPDOWN (MULTI & SEARCH) ]
        function TabObj:CreateDropdown(opts)
            local dName = opts.Name or "Dropdown"
            local options = opts.Options or {}
            local multi = opts.Multi or false
            local default = opts.Default
            local dCb = opts.Callback or function() end

            local selected = multi and (default or {}) or (default or nil)
            
            local DropFrame = Utility:Create("Frame", {
                Size = UDim2.new(1, 0, 0, 45),
                BackgroundColor3 = CurrentTheme.Element,
                ClipsDescendants = true,
                Parent = Page
            })
            Utility:Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = DropFrame})
            Utility:Create("UIStroke", {Color = CurrentTheme.Outline, Thickness = 1, Parent = DropFrame})
            Utility:RegisterTheme(DropFrame, "BackgroundColor3", "Element")
            Utility:RegisterTheme(DropFrame.UIStroke, "Color", "Outline")

            local DropBtn = Utility:Create("TextButton", {
                Size = UDim2.new(1, 0, 0, 45),
                BackgroundTransparency = 1,
                Text = "",
                Parent = DropFrame
            })

            Utility:Create("TextLabel", {
                Name = "TitleLabel",
                Size = UDim2.new(1, -150, 1, 0),
                Position = UDim2.new(0, 15, 0, 0),
                BackgroundTransparency = 1,
                Text = dName,
                Font = Enum.Font.GothamMedium,
                TextSize = 14,
                TextColor3 = CurrentTheme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = DropBtn
            })
            Utility:RegisterTheme(DropBtn.TitleLabel, "TextColor3", "Text")

            local SelectedLabel = Utility:Create("TextLabel", {
                Size = UDim2.new(0, 120, 1, 0),
                Position = UDim2.new(1, -150, 0, 0),
                BackgroundTransparency = 1,
                Text = multi and string.format("%d Selected", #selected) or (selected or "None"),
                Font = Enum.Font.GothamMedium,
                TextSize = 12,
                TextColor3 = CurrentTheme.SubText,
                TextXAlignment = Enum.TextXAlignment.Right,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Parent = DropBtn
            })
            Utility:RegisterTheme(SelectedLabel, "TextColor3", "SubText")

            local Arrow = Utility:Create("ImageLabel", {
                Size = UDim2.new(0, 20, 0, 20),
                Position = UDim2.new(1, -30, 0.5, -10),
                BackgroundTransparency = 1,
                Image = "rbxassetid://6031091004",
                ImageColor3 = CurrentTheme.SubText,
                Parent = DropBtn
            })
            Utility:RegisterTheme(Arrow, "ImageColor3", "SubText")

            local SearchBar = Utility:Create("TextBox", {
                Size = UDim2.new(1, -20, 0, 30),
                Position = UDim2.new(0, 10, 0, 50),
                BackgroundColor3 = CurrentTheme.Container,
                Text = "",
                PlaceholderText = "Search...",
                Font = Enum.Font.GothamMedium,
                TextSize = 13,
                TextColor3 = CurrentTheme.Text,
                Parent = DropFrame
            })
            Utility:Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = SearchBar})
            Utility:RegisterTheme(SearchBar, "BackgroundColor3", "Container")
            Utility:RegisterTheme(SearchBar, "TextColor3", "Text")

            local ListContainer = Utility:Create("ScrollingFrame", {
                Size = UDim2.new(1, -20, 0, 100),
                Position = UDim2.new(0, 10, 0, 85),
                BackgroundTransparency = 1,
                ScrollBarThickness = 2,
                ScrollBarImageColor3 = CurrentTheme.Accent,
                Parent = DropFrame
            })
            Utility:RegisterTheme(ListContainer, "ScrollBarImageColor3", "Accent")
            local LLayout = Utility:Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 5),
                Parent = ListContainer
            })

            local DropObj = {Expanded = false}

            function DropObj:Close()
                DropObj.Expanded = false
                Utility:Tween(DropFrame, {Size = UDim2.new(1, 0, 0, 45)}, 0.3, Enum.EasingStyle.Back)
                Utility:Tween(Arrow, {Rotation = 0}, 0.3)
            end

            function DropObj:Open()
                for _, dp in pairs(Dropdowns) do if dp ~= DropObj then dp:Close() end end
                for _, cp in pairs(ColorPickers) do if cp.Expanded then cp:Close() end end
                DropObj.Expanded = true
                Utility:Tween(DropFrame, {Size = UDim2.new(1, 0, 0, 195)}, 0.3, Enum.EasingStyle.Back)
                Utility:Tween(Arrow, {Rotation = 180}, 0.3)
            end

            local function RefreshList()
                for _, v in pairs(ListContainer:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
                
                local query = string.lower(SearchBar.Text)
                
                for _, opt in ipairs(options) do
                    if query == "" or string.find(string.lower(opt), query) then
                        local isSel = false
                        if multi then
                            for _, v in pairs(selected) do if v == opt then isSel = true break end end
                        else
                            isSel = (selected == opt)
                        end

                        local optBtn = Utility:Create("TextButton", {
                            Size = UDim2.new(1, 0, 0, 30),
                            BackgroundColor3 = isSel and CurrentTheme.Accent or CurrentTheme.Container,
                            Text = "",
                            AutoButtonColor = false,
                            Parent = ListContainer
                        })
                        Utility:Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = optBtn})
                        
                        Utility:Create("TextLabel", {
                            Size = UDim2.new(1, -20, 1, 0),
                            Position = UDim2.new(0, 10, 0, 0),
                            BackgroundTransparency = 1,
                            Text = opt,
                            Font = Enum.Font.GothamMedium,
                            TextSize = 13,
                            TextColor3 = isSel and Color3.fromRGB(255,255,255) or CurrentTheme.Text,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            Parent = optBtn
                        })

                        optBtn.MouseButton1Click:Connect(function()
                            if multi then
                                if isSel then
                                    for i, v in pairs(selected) do if v == opt then table.remove(selected, i) break end end
                                else
                                    table.insert(selected, opt)
                                end
                                SelectedLabel.Text = string.format("%d Selected", #selected)
                                RefreshList()
                                dCb(selected)
                            else
                                selected = opt
                                SelectedLabel.Text = opt
                                DropObj:Close()
                                RefreshList()
                                dCb(opt)
                            end
                        end)
                    end
                end
                ListContainer.CanvasSize = UDim2.new(0, 0, 0, LLayout.AbsoluteContentSize.Y)
            end

            SearchBar:GetPropertyChangedSignal("Text"):Connect(RefreshList)
            RefreshList()

            DropBtn.MouseButton1Click:Connect(function()
                Utility:Ripple(DropBtn)
                if DropObj.Expanded then DropObj:Close() else DropObj:Open() end
            end)

            table.insert(Dropdowns, DropObj)
            
            -- Call default
            if default then dCb(default) end
        end

        -- [ KEYBIND ]
        function TabObj:CreateKeybind(opts)
            local kName = opts.Name or "Keybind"
            local currentKey = opts.Default or Enum.KeyCode.E
            local kCb = opts.Callback or function() end

            local BindFrame = Utility:Create("Frame", {
                Size = UDim2.new(1, 0, 0, 45),
                BackgroundColor3 = CurrentTheme.Element,
                Parent = Page
            })
            Utility:Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = BindFrame})
            Utility:Create("UIStroke", {Color = CurrentTheme.Outline, Thickness = 1, Parent = BindFrame})
            Utility:RegisterTheme(BindFrame, "BackgroundColor3", "Element")
            Utility:RegisterTheme(BindFrame.UIStroke, "Color", "Outline")

            Utility:Create("TextLabel", {
                Name = "TitleLabel",
                Size = UDim2.new(1, -120, 1, 0),
                Position = UDim2.new(0, 15, 0, 0),
                BackgroundTransparency = 1,
                Text = kName,
                Font = Enum.Font.GothamMedium,
                TextSize = 14,
                TextColor3 = CurrentTheme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = BindFrame
            })
            Utility:RegisterTheme(BindFrame.TitleLabel, "TextColor3", "Text")

            local BindBtn = Utility:Create("TextButton", {
                Size = UDim2.new(0, 80, 0, 25),
                Position = UDim2.new(1, -95, 0.5, -12.5),
                BackgroundColor3 = CurrentTheme.Container,
                Text = currentKey.Name,
                Font = Enum.Font.GothamMedium,
                TextSize = 13,
                TextColor3 = CurrentTheme.Accent,
                AutoButtonColor = false,
                Parent = BindFrame
            })
            Utility:Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = BindBtn})
            Utility:Create("UIStroke", {Color = CurrentTheme.Outline, Thickness = 1, Parent = BindBtn})
            Utility:RegisterTheme(BindBtn, "BackgroundColor3", "Container")
            Utility:RegisterTheme(BindBtn, "TextColor3", "Accent")
            Utility:RegisterTheme(BindBtn.UIStroke, "Color", "Outline")

            local isBinding = false
            BindBtn.MouseButton1Click:Connect(function()
                Utility:Ripple(BindBtn)
                isBinding = true
                BindBtn.Text = "..."
                Utility:Tween(BindBtn, {BackgroundColor3 = CurrentTheme.ElementHover}, 0.2)
            end)

            table.insert(Connections, UserInputService.InputBegan:Connect(function(input, processed)
                if isBinding then
                    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode ~= Enum.KeyCode.Escape then
                        currentKey = input.KeyCode
                        BindBtn.Text = currentKey.Name
                        isBinding = false
                        Utility:Tween(BindBtn, {BackgroundColor3 = CurrentTheme.Container}, 0.2)
                    elseif input.KeyCode == Enum.KeyCode.Escape then
                        BindBtn.Text = "None"
                        currentKey = nil
                        isBinding = false
                        Utility:Tween(BindBtn, {BackgroundColor3 = CurrentTheme.Container}, 0.2)
                    end
                elseif not processed and currentKey and input.KeyCode == currentKey then
                    kCb()
                end
            end))
        end

        -- [ COLOR PICKER (Advanced HSV) ]
        function TabObj:CreateColorPicker(opts)
            local cpName = opts.Name or "Color Picker"
            local color = opts.Default or Color3.fromRGB(255, 255, 255)
            local cpCb = opts.Callback or function() end

            local h, s, v = Utility:RGBToHSV(color)

            local CPFrame = Utility:Create("Frame", {
                Size = UDim2.new(1, 0, 0, 45),
                BackgroundColor3 = CurrentTheme.Element,
                ClipsDescendants = true,
                Parent = Page
            })
            Utility:Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = CPFrame})
            Utility:Create("UIStroke", {Color = CurrentTheme.Outline, Thickness = 1, Parent = CPFrame})
            Utility:RegisterTheme(CPFrame, "BackgroundColor3", "Element")
            Utility:RegisterTheme(CPFrame.UIStroke, "Color", "Outline")

            local CPBtn = Utility:Create("TextButton", {
                Size = UDim2.new(1, 0, 0, 45),
                BackgroundTransparency = 1,
                Text = "",
                Parent = CPFrame
            })

            Utility:Create("TextLabel", {
                Name = "TitleLabel",
                Size = UDim2.new(1, -80, 1, 0),
                Position = UDim2.new(0, 15, 0, 0),
                BackgroundTransparency = 1,
                Text = cpName,
                Font = Enum.Font.GothamMedium,
                TextSize = 14,
                TextColor3 = CurrentTheme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = CPBtn
            })
            Utility:RegisterTheme(CPBtn.TitleLabel, "TextColor3", "Text")

            local DisplayColor = Utility:Create("Frame", {
                Size = UDim2.new(0, 36, 0, 20),
                Position = UDim2.new(1, -50, 0.5, -10),
                BackgroundColor3 = color,
                Parent = CPBtn
            })
            Utility:Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = DisplayColor})
            Utility:Create("UIStroke", {Color = CurrentTheme.Outline, Thickness = 1, Parent = DisplayColor})

            -- Extended Picker UI
            local PickerArea = Utility:Create("Frame", {
                Size = UDim2.new(1, -20, 0, 150),
                Position = UDim2.new(0, 10, 0, 50),
                BackgroundTransparency = 1,
                Parent = CPFrame
            })

            -- Saturation/Value Canvas
            local SVCanvas = Utility:Create("TextButton", {
                Size = UDim2.new(1, -30, 1, -40),
                Position = UDim2.new(0, 0, 0, 0),
                BackgroundColor3 = Color3.fromHSV(h, 1, 1),
                Text = "",
                AutoButtonColor = false,
                Parent = PickerArea
            })
            Utility:Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = SVCanvas})
            
            local SGrad = Utility:Create("UIGradient", {
                Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255))}),
                Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)}),
                Parent = SVCanvas
            })
            local VOverlay = Utility:Create("Frame", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundColor3 = Color3.fromRGB(0,0,0),
                Parent = SVCanvas
            })
            Utility:Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = VOverlay})
            local VGrad = Utility:Create("UIGradient", {
                Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0)}),
                Rotation = 90,
                Parent = VOverlay
            })

            local SVThumb = Utility:Create("Frame", {
                Size = UDim2.new(0, 12, 0, 12),
                Position = UDim2.new(s, -6, 1 - v, -6),
                BackgroundColor3 = Color3.fromRGB(255,255,255),
                Parent = SVCanvas
            })
            Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = SVThumb})
            Utility:Create("UIStroke", {Color = Color3.fromRGB(0,0,0), Thickness = 1, Parent = SVThumb})

            -- Hue Slider
            local HueSlider = Utility:Create("TextButton", {
                Size = UDim2.new(0, 20, 1, -40),
                Position = UDim2.new(1, -20, 0, 0),
                BackgroundColor3 = Color3.fromRGB(255,255,255),
                Text = "",
                AutoButtonColor = false,
                Parent = PickerArea
            })
            Utility:Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = HueSlider})
            local HueGrad = Utility:Create("UIGradient", {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)),
                    ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255,255,0)),
                    ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0,255,0)),
                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,255,255)),
                    ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0,0,255)),
                    ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255,0,255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,0))
                }),
                Rotation = 90,
                Parent = HueSlider
            })
            local HueThumb = Utility:Create("Frame", {
                Size = UDim2.new(1, 4, 0, 6),
                Position = UDim2.new(0, -2, h, -3),
                BackgroundColor3 = Color3.fromRGB(255,255,255),
                Parent = HueSlider
            })
            Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = HueThumb})
            Utility:Create("UIStroke", {Color = Color3.fromRGB(0,0,0), Thickness = 1, Parent = HueThumb})

            -- Hex Input
            local HexBox = Utility:Create("TextBox", {
                Size = UDim2.new(1, 0, 0, 30),
                Position = UDim2.new(0, 0, 1, -30),
                BackgroundColor3 = CurrentTheme.Container,
                Text = "#" .. color:ToHex():upper():sub(1, 6),
                Font = Enum.Font.GothamMedium,
                TextSize = 13,
                TextColor3 = CurrentTheme.Text,
                Parent = PickerArea
            })
            Utility:Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = HexBox})
            Utility:RegisterTheme(HexBox, "BackgroundColor3", "Container")
            Utility:RegisterTheme(HexBox, "TextColor3", "Text")

            local function UpdateColor()
                color = Color3.fromHSV(h, s, v)
                DisplayColor.BackgroundColor3 = color
                SVCanvas.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                HexBox.Text = "#" .. color:ToHex():upper():sub(1, 6)
                cpCb(color)
            end

            -- SV Dragging
            local svDragging = false
            SVCanvas.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    svDragging = true
                    s = math.clamp((input.Position.X - SVCanvas.AbsolutePosition.X) / SVCanvas.AbsoluteSize.X, 0, 1)
                    v = 1 - math.clamp((input.Position.Y - SVCanvas.AbsolutePosition.Y) / SVCanvas.AbsoluteSize.Y, 0, 1)
                    Utility:Tween(SVThumb, {Position = UDim2.new(s, -6, 1 - v, -6)}, 0.1)
                    UpdateColor()
                end
            end)

            -- Hue Dragging
            local hueDragging = false
            HueSlider.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    hueDragging = true
                    h = math.clamp((input.Position.Y - HueSlider.AbsolutePosition.Y) / HueSlider.AbsoluteSize.Y, 0, 1)
                    Utility:Tween(HueThumb, {Position = UDim2.new(0, -2, h, -3)}, 0.1)
                    UpdateColor()
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    svDragging = false
                    hueDragging = false
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                    if svDragging then
                        s = math.clamp((input.Position.X - SVCanvas.AbsolutePosition.X) / SVCanvas.AbsoluteSize.X, 0, 1)
                        v = 1 - math.clamp((input.Position.Y - SVCanvas.AbsolutePosition.Y) / SVCanvas.AbsoluteSize.Y, 0, 1)
                        Utility:Tween(SVThumb, {Position = UDim2.new(s, -6, 1 - v, -6)}, 0.1)
                        UpdateColor()
                    elseif hueDragging then
                        h = math.clamp((input.Position.Y - HueSlider.AbsolutePosition.Y) / HueSlider.AbsoluteSize.Y, 0, 1)
                        Utility:Tween(HueThumb, {Position = UDim2.new(0, -2, h, -3)}, 0.1)
                        UpdateColor()
                    end
                end
            end)

            local CPObj = {Expanded = false}

            function CPObj:Close()
                CPObj.Expanded = false
                Utility:Tween(CPFrame, {Size = UDim2.new(1, 0, 0, 45)}, 0.3, Enum.EasingStyle.Back)
            end

            function CPObj:Open()
                for _, dp in pairs(Dropdowns) do if dp.Expanded then dp:Close() end end
                for _, cp in pairs(ColorPickers) do if cp ~= CPObj then cp:Close() end end
                CPObj.Expanded = true
                Utility:Tween(CPFrame, {Size = UDim2.new(1, 0, 0, 210)}, 0.3, Enum.EasingStyle.Back)
            end

            CPBtn.MouseButton1Click:Connect(function()
                Utility:Ripple(CPBtn)
                if CPObj.Expanded then CPObj:Close() else CPObj:Open() end
            end)

            table.insert(ColorPickers, CPObj)
            cpCb(color)
        end

        return TabObj
    end

    -- ============================================================================== --
    -- NOTIFICATION ENGINE
    -- ============================================================================== --

    function XreztHub:Notify(opts)
        local nTitle = opts.Title or "Notification"
        local nText = opts.Text or "This is a message."
        local nDur = opts.Duration or 3
        local nType = opts.Type or "Info" -- Success, Error, Warning, Info

        local typeColor = CurrentTheme[nType] or CurrentTheme.Accent

        local NotifFrame = Utility:Create("Frame", {
            Size = UDim2.new(1, 0, 0, 80),
            BackgroundColor3 = CurrentTheme.Container,
            BackgroundTransparency = 1,
            Position = UDim2.new(1, 50, 0, 0),
            Parent = NotificationsContainer
        })
        Utility:Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = NotifFrame})
        Utility:Create("UIStroke", {Color = typeColor, Thickness = 2, Parent = NotifFrame})
        Utility:RegisterTheme(NotifFrame, "BackgroundColor3", "Container")
        
        -- Color bar indicator
        local ColorBar = Utility:Create("Frame", {
            Size = UDim2.new(0, 4, 1, -20),
            Position = UDim2.new(0, 10, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundColor3 = typeColor,
            Parent = NotifFrame
        })
        Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = ColorBar})

        local TitleL = Utility:Create("TextLabel", {
            Size = UDim2.new(1, -30, 0, 20),
            Position = UDim2.new(0, 25, 0, 10),
            BackgroundTransparency = 1,
            Text = nTitle,
            Font = Enum.Font.GothamBold,
            TextSize = 15,
            TextColor3 = CurrentTheme.Text,
            TextTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = NotifFrame
        })

        local DescL = Utility:Create("TextLabel", {
            Size = UDim2.new(1, -30, 1, -40),
            Position = UDim2.new(0, 25, 0, 30),
            BackgroundTransparency = 1,
            Text = nText,
            Font = Enum.Font.GothamMedium,
            TextSize = 13,
            TextColor3 = CurrentTheme.SubText,
            TextTransparency = 1,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            Parent = NotifFrame
        })

        -- Slide In
        Utility:Tween(NotifFrame, {Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 0.1}, 0.5, Enum.EasingStyle.Back)
        Utility:Tween(TitleL, {TextTransparency = 0}, 0.5)
        Utility:Tween(DescL, {TextTransparency = 0}, 0.5)

        task.spawn(function()
            task.wait(nDur)
            Utility:Tween(NotifFrame, {Position = UDim2.new(1, 50, 0, 0), BackgroundTransparency = 1}, 0.4)
            Utility:Tween(TitleL, {TextTransparency = 1}, 0.4)
            Utility:Tween(DescL, {TextTransparency = 1}, 0.4)
            task.wait(0.4)
            NotifFrame:Destroy()
        end)
    end

    -- ============================================================================== --
    -- THEME SWITCHER HELPER
    -- ============================================================================== --

    function WindowObj:SetTheme(themeName)
        Utility:UpdateTheme(themeName)
    end

    return WindowObj
end

-- ============================================================================== --
-- FINAL EXECUTION & RETURN
-- ============================================================================== --

XreztHub:Load()
return XreztHub
