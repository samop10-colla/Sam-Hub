--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║                      SAM'S HUB v1.0                         ║
    ║              Professional Roblox UI Framework               ║
    ║        Light-Green Royal Theme | Smooth Animations          ║
    ╚══════════════════════════════════════════════════════════════╝
    
    USAGE EXAMPLE:
    
    local SamsHub = loadstring(game:HttpGet("YOUR_RAW_URL"))()
    
    local Window = SamsHub:CreateWindow({
        Title = "My Script",
        Subtitle = "by Author",
        LoadingText = "Initializing...",
        KeySystem = false,
    })
    
    local Tab = Window:AddTab({ Name = "Main", Icon = "rbxassetid://0" })
    
    Tab:AddButton({ Name = "Click Me", Callback = function() print("Clicked!") end })
    Tab:AddToggle({ Name = "Toggle", Default = false, Callback = function(v) print(v) end })
    Tab:AddSlider({ Name = "Speed", Min = 0, Max = 100, Default = 50, Callback = function(v) print(v) end })
    Tab:AddDropdown({ Name = "Mode", Options = {"Option1","Option2"}, Default = "Option1", Callback = function(v) print(v) end })
    Tab:AddTextBox({ Name = "Input", Default = "Type here...", Callback = function(v) print(v) end })
    Tab:AddColorPicker({ Name = "Color", Default = Color3.fromRGB(80,200,120), Callback = function(v) print(v) end })
    Tab:AddKeybind({ Name = "Keybind", Default = Enum.KeyCode.F, Callback = function() print("Pressed!") end })
    Tab:AddCheckbox({ Name = "Enable Feature", Default = false, Callback = function(v) print(v) end })
    Tab:AddLabel({ Text = "This is a label" })
    Tab:AddDivider()
    Tab:AddParagraph({ Title = "Info", Content = "This is a paragraph of information." })
]]

-- ═══════════════════════════════════════════════════
--  SERVICES
-- ═══════════════════════════════════════════════════
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local Players          = game:GetService("Players")
local CoreGui          = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Mouse       = LocalPlayer:GetMouse()

-- ═══════════════════════════════════════════════════
--  LIBRARY TABLE
-- ═══════════════════════════════════════════════════
local SamsHub = {}
SamsHub.__index = SamsHub

-- ═══════════════════════════════════════════════════
--  THEME CONFIGURATION
-- ═══════════════════════════════════════════════════
local Theme = {
    -- Primary Palette
    Background       = Color3.fromRGB(12, 18, 14),
    BackgroundAlt    = Color3.fromRGB(16, 24, 18),
    Surface          = Color3.fromRGB(20, 32, 24),
    SurfaceAlt       = Color3.fromRGB(26, 40, 30),
    Border           = Color3.fromRGB(40, 70, 50),
    BorderLight      = Color3.fromRGB(55, 95, 68),

    -- Accent / Brand
    Accent           = Color3.fromRGB(80, 220, 120),
    AccentDim        = Color3.fromRGB(55, 160, 88),
    AccentGlow       = Color3.fromRGB(100, 240, 145),
    AccentDark       = Color3.fromRGB(30, 90, 50),

    -- Text
    TextPrimary      = Color3.fromRGB(220, 255, 230),
    TextSecondary    = Color3.fromRGB(140, 190, 155),
    TextMuted        = Color3.fromRGB(80, 120, 92),
    TextAccent       = Color3.fromRGB(80, 220, 120),

    -- States
    Success          = Color3.fromRGB(80, 220, 120),
    Warning          = Color3.fromRGB(240, 190, 60),
    Error            = Color3.fromRGB(240, 80, 80),
    Disabled         = Color3.fromRGB(45, 65, 50),

    -- Gradients
    GradientStart    = Color3.fromRGB(20, 32, 24),
    GradientEnd      = Color3.fromRGB(12, 22, 16),
    LoaderGrad1      = Color3.fromRGB(40, 160, 85),
    LoaderGrad2      = Color3.fromRGB(20, 100, 55),

    -- Transparency
    TransBackground  = 0.06,
    TransSurface     = 0.10,
    TransOverlay     = 0.35,
}

-- ═══════════════════════════════════════════════════
--  UTILITY FUNCTIONS
-- ═══════════════════════════════════════════════════
local Util = {}

function Util.Tween(instance, properties, duration, style, direction)
    local info = TweenInfo.new(
        duration or 0.3,
        style or Enum.EasingStyle.Quint,
        direction or Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(instance, info, properties)
    tween:Play()
    return tween
end

function Util.SpringTween(instance, properties, duration)
    return Util.Tween(instance, properties, duration or 0.45,
        Enum.EasingStyle.Back, Enum.EasingDirection.Out)
end

function Util.Lerp(a, b, t)
    return a + (b - a) * t
end

function Util.RoundCorners(instance, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = instance
    return corner
end

function Util.AddStroke(instance, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Theme.Border
    stroke.Thickness = thickness or 1
    stroke.Transparency = transparency or 0
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = instance
    return stroke
end

function Util.AddGradient(instance, rotation, colorSequence)
    local gradient = Instance.new("UIGradient")
    gradient.Rotation = rotation or 90
    gradient.Color = colorSequence or ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.GradientStart),
        ColorSequenceKeypoint.new(1, Theme.GradientEnd),
    })
    gradient.Parent = instance
    return gradient
end

function Util.AddPadding(instance, top, bottom, left, right)
    local padding = Instance.new("UIPadding")
    padding.PaddingTop    = UDim.new(0, top    or 6)
    padding.PaddingBottom = UDim.new(0, bottom or 6)
    padding.PaddingLeft   = UDim.new(0, left   or 10)
    padding.PaddingRight  = UDim.new(0, right  or 10)
    padding.Parent = instance
    return padding
end

function Util.Make(className, properties, parent)
    local inst = Instance.new(className)
    for prop, val in pairs(properties or {}) do
        inst[prop] = val
    end
    if parent then inst.Parent = parent end
    return inst
end

function Util.MakeDraggable(frame, handle)
    local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
    handle = handle or frame

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging  = true
            dragStart = input.Position
            startPos  = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ═══════════════════════════════════════════════════
--  LOADING SCREEN
-- ═══════════════════════════════════════════════════
local function CreateLoadingScreen(config)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SamsHubLoader"
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true

    -- Overlay
    local overlay = Util.Make("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.fromRGB(8, 14, 10),
        BackgroundTransparency = 0,
        ZIndex = 100,
    }, screenGui)

    -- Subtle noise/grid background
    local bgGrid = Util.Make("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        ZIndex = 100,
    }, overlay)

    -- Radial glow center
    local glowCenter = Util.Make("Frame", {
        Size = UDim2.fromOffset(600, 600),
        Position = UDim2.new(0.5, -300, 0.5, -300),
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 0.88,
        ZIndex = 101,
    }, overlay)
    Util.RoundCorners(glowCenter, 300)

    -- Animate glow pulse
    local function pulseGlow()
        Util.Tween(glowCenter, { BackgroundTransparency = 0.82, Size = UDim2.fromOffset(640, 640), Position = UDim2.new(0.5,-320,0.5,-320) }, 1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
        task.delay(1.2, function()
            Util.Tween(glowCenter, { BackgroundTransparency = 0.90, Size = UDim2.fromOffset(560, 560), Position = UDim2.new(0.5,-280,0.5,-280) }, 1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.delay(1.2, pulseGlow)
        end)
    end
    pulseGlow()

    -- Hub name
    local titleLabel = Util.Make("TextLabel", {
        Size = UDim2.fromOffset(400, 60),
        Position = UDim2.new(0.5, -200, 0.5, -120),
        BackgroundTransparency = 1,
        Text = "SAM'S HUB",
        Font = Enum.Font.GothamBold,
        TextSize = 42,
        TextColor3 = Theme.TextPrimary,
        TextTransparency = 1,
        ZIndex = 102,
    }, overlay)
    Util.AddGradient(titleLabel, 0, ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.AccentGlow),
        ColorSequenceKeypoint.new(0.5, Theme.TextPrimary),
        ColorSequenceKeypoint.new(1, Theme.Accent),
    }))

    -- Subtitle / version
    local subtitleLabel = Util.Make("TextLabel", {
        Size = UDim2.fromOffset(300, 24),
        Position = UDim2.new(0.5, -150, 0.5, -60),
        BackgroundTransparency = 1,
        Text = "v1.0  |  Professional UI Framework",
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextColor3 = Theme.TextSecondary,
        TextTransparency = 1,
        LetterSpacing = 3,
        ZIndex = 102,
    }, overlay)

    -- Loader bar background
    local barBg = Util.Make("Frame", {
        Size = UDim2.fromOffset(320, 4),
        Position = UDim2.new(0.5, -160, 0.5, 10),
        BackgroundColor3 = Theme.SurfaceAlt,
        BackgroundTransparency = 0.4,
        ZIndex = 102,
    }, overlay)
    Util.RoundCorners(barBg, 4)

    -- Loader bar fill
    local barFill = Util.Make("Frame", {
        Size = UDim2.fromOffset(0, 4),
        Position = UDim2.fromOffset(0, 0),
        BackgroundColor3 = Theme.Accent,
        ZIndex = 103,
    }, barBg)
    Util.RoundCorners(barFill, 4)
    Util.AddGradient(barFill, 0, ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.AccentDim),
        ColorSequenceKeypoint.new(1, Theme.AccentGlow),
    }))

    -- Sheen on bar
    local barSheen = Util.Make("Frame", {
        Size = UDim2.new(0, 30, 1, 0),
        Position = UDim2.fromOffset(-30, 0),
        BackgroundColor3 = Color3.fromRGB(255,255,255),
        BackgroundTransparency = 0.6,
        ZIndex = 104,
    }, barFill)
    Util.RoundCorners(barSheen, 4)

    -- Status text
    local statusLabel = Util.Make("TextLabel", {
        Size = UDim2.fromOffset(320, 20),
        Position = UDim2.new(0.5, -160, 0.5, 24),
        BackgroundTransparency = 1,
        Text = config.LoadingText or "Loading...",
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = Theme.TextMuted,
        TextTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 102,
    }, overlay)

    -- Percentage label
    local percentLabel = Util.Make("TextLabel", {
        Size = UDim2.fromOffset(60, 20),
        Position = UDim2.new(0.5, 104, 0.5, 24),
        BackgroundTransparency = 1,
        Text = "0%",
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextColor3 = Theme.TextAccent,
        TextTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex = 102,
    }, overlay)

    -- Decorative corner accents
    local corners = {
        {Position = UDim2.fromOffset(60, 60),  Rotation = 0},
        {Position = UDim2.new(1,-80,0,60),     Rotation = 90},
        {Position = UDim2.new(0,60,1,-80),     Rotation = 270},
        {Position = UDim2.new(1,-80,1,-80),    Rotation = 180},
    }
    for _, c in ipairs(corners) do
        local corner = Util.Make("Frame", {
            Size = UDim2.fromOffset(20, 20),
            Position = c.Position,
            BackgroundTransparency = 1,
            ZIndex = 102,
        }, overlay)
        Util.Make("Frame", {
            Size = UDim2.fromOffset(20, 2),
            BackgroundColor3 = Theme.AccentDim,
            BackgroundTransparency = 0.2,
            ZIndex = 102,
        }, corner)
        Util.Make("Frame", {
            Size = UDim2.fromOffset(2, 20),
            BackgroundColor3 = Theme.AccentDim,
            BackgroundTransparency = 0.2,
            ZIndex = 102,
        }, corner)
    end

    screenGui.Parent = CoreGui

    -- Animate in
    task.spawn(function()
        task.wait(0.1)
        Util.Tween(titleLabel,    { TextTransparency = 0 },   0.8, Enum.EasingStyle.Quint)
        task.wait(0.25)
        Util.Tween(subtitleLabel, { TextTransparency = 0 },   0.7, Enum.EasingStyle.Quint)
        task.wait(0.2)
        Util.Tween(statusLabel,   { TextTransparency = 0 },   0.5)
        Util.Tween(percentLabel,  { TextTransparency = 0 },   0.5)
        task.wait(0.15)

        -- Bar animation with sheen
        local loadSteps = {
            { pct = 15,  text = "Injecting modules..." },
            { pct = 35,  text = "Connecting services..." },
            { pct = 58,  text = "Building interface..." },
            { pct = 75,  text = "Applying theme..." },
            { pct = 90,  text = "Almost ready..." },
            { pct = 100, text = "Done!" },
        }

        for _, step in ipairs(loadSteps) do
            task.wait(math.random(18, 35) / 100)
            local fillWidth = (step.pct / 100) * 320
            Util.Tween(barFill, { Size = UDim2.fromOffset(fillWidth, 4) }, 0.4, Enum.EasingStyle.Quint)
            statusLabel.Text  = step.text
            percentLabel.Text = step.pct .. "%"
            -- Sheen sweep
            task.spawn(function()
                barSheen.Position = UDim2.fromOffset(-30, 0)
                Util.Tween(barSheen, { Position = UDim2.fromOffset(fillWidth + 10, 0) }, 0.55, Enum.EasingStyle.Quad)
            end)
        end

        task.wait(0.5)

        -- Fade out loading screen
        Util.Tween(overlay, { BackgroundTransparency = 1 }, 0.7, Enum.EasingStyle.Quint)
        Util.Tween(titleLabel,    { TextTransparency = 1 },   0.5)
        Util.Tween(subtitleLabel, { TextTransparency = 1 },   0.5)
        Util.Tween(statusLabel,   { TextTransparency = 1 },   0.4)
        Util.Tween(percentLabel,  { TextTransparency = 1 },   0.4)
        Util.Tween(barBg,         { BackgroundTransparency = 1 }, 0.4)
        task.wait(0.7)
        screenGui:Destroy()
    end)

    return screenGui
end

-- ═══════════════════════════════════════════════════
--  MAIN WINDOW CONSTRUCTOR
-- ═══════════════════════════════════════════════════
function SamsHub:CreateWindow(config)
    config = config or {}
    config.Title       = config.Title    or "Sam's Hub"
    config.Subtitle    = config.Subtitle or "UI Framework"
    config.LoadingText = config.LoadingText or "Loading Sam's Hub..."
    config.Size        = config.Size     or UDim2.fromOffset(580, 420)

    -- Show loading screen first
    CreateLoadingScreen(config)
    task.wait(2.6)  -- Matches loader animation duration

    -- ─── Screen GUI ────────────────────────────────
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SamsHub"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.Parent = CoreGui

    -- ─── Backdrop glow ─────────────────────────────
    local GlowBack = Util.Make("Frame", {
        Size = UDim2.new(config.Size.X.Scale, config.Size.X.Offset + 40,
                         config.Size.Y.Scale, config.Size.Y.Offset + 40),
        Position = UDim2.new(0.5, -(config.Size.X.Offset/2)-20, 0.5, -(config.Size.Y.Offset/2)-20),
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 0.88,
        ZIndex = 1,
    }, ScreenGui)
    Util.RoundCorners(GlowBack, 18)

    -- ─── Main Container ────────────────────────────
    local MainFrame = Util.Make("Frame", {
        Size = config.Size,
        Position = UDim2.new(0.5, -config.Size.X.Offset/2, 0.5, -config.Size.Y.Offset/2),
        BackgroundColor3 = Theme.Background,
        BackgroundTransparency = Theme.TransBackground,
        ZIndex = 2,
    }, ScreenGui)
    Util.RoundCorners(MainFrame, 12)
    Util.AddStroke(MainFrame, Theme.Border, 1.2, 0.2)
    Util.AddGradient(MainFrame, 135, ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.Background),
        ColorSequenceKeypoint.new(1, Theme.BackgroundAlt),
    }))

    -- Spawn animation
    MainFrame.Position = UDim2.new(0.5, -config.Size.X.Offset/2, 0.5, -config.Size.Y.Offset/2 + 20)
    MainFrame.BackgroundTransparency = 1
    GlowBack.BackgroundTransparency = 1
    Util.Tween(MainFrame, {
        Position = UDim2.new(0.5, -config.Size.X.Offset/2, 0.5, -config.Size.Y.Offset/2),
        BackgroundTransparency = Theme.TransBackground,
    }, 0.55, Enum.EasingStyle.Back)
    Util.Tween(GlowBack, { BackgroundTransparency = 0.88 }, 0.55, Enum.EasingStyle.Quint)
    Util.MakeDraggable(MainFrame)

    -- ─── Title Bar ─────────────────────────────────
    local TitleBar = Util.Make("Frame", {
        Size = UDim2.new(1, 0, 0, 46),
        BackgroundColor3 = Theme.Surface,
        BackgroundTransparency = 0.05,
        ZIndex = 3,
    }, MainFrame)
    Util.RoundCorners(TitleBar, 12)
    Util.AddGradient(TitleBar, 90, ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.Surface),
        ColorSequenceKeypoint.new(1, Theme.BackgroundAlt),
    }))

    -- Accent line under title bar
    local TitleAccent = Util.Make("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.fromOffset(0, 46),
        BackgroundColor3 = Theme.Border,
        BackgroundTransparency = 0.3,
        ZIndex = 3,
    }, MainFrame)
    Util.AddGradient(TitleAccent, 0, ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0,0,0)),
        ColorSequenceKeypoint.new(0.3, Theme.Accent),
        ColorSequenceKeypoint.new(0.7, Theme.Accent),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0,0,0)),
    }))

    -- Logo dot
    local LogoDot = Util.Make("Frame", {
        Size = UDim2.fromOffset(10, 10),
        Position = UDim2.fromOffset(16, 18),
        BackgroundColor3 = Theme.Accent,
        ZIndex = 4,
    }, TitleBar)
    Util.RoundCorners(LogoDot, 5)

    local TitleText = Util.Make("TextLabel", {
        Size = UDim2.new(0, 200, 1, 0),
        Position = UDim2.fromOffset(32, 0),
        BackgroundTransparency = 1,
        Text = config.Title,
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        TextColor3 = Theme.TextPrimary,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 4,
    }, TitleBar)

    local SubtitleText = Util.Make("TextLabel", {
        Size = UDim2.new(0, 200, 1, 0),
        Position = UDim2.fromOffset(32, 16),
        BackgroundTransparency = 1,
        Text = config.Subtitle,
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextColor3 = Theme.TextMuted,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 4,
    }, TitleBar)

    -- ─── Close & Minimize Buttons ──────────────────
    local function makeControlBtn(icon, xOff, color, callback)
        local btn = Util.Make("TextButton", {
            Size = UDim2.fromOffset(22, 22),
            Position = UDim2.new(1, xOff, 0.5, -11),
            BackgroundColor3 = color,
            BackgroundTransparency = 0.3,
            Text = icon,
            Font = Enum.Font.GothamBold,
            TextSize = 11,
            TextColor3 = Theme.TextPrimary,
            ZIndex = 5,
        }, TitleBar)
        Util.RoundCorners(btn, 6)
        btn.MouseEnter:Connect(function()
            Util.Tween(btn, { BackgroundTransparency = 0, Size = UDim2.fromOffset(24,24),
                Position = UDim2.new(1, xOff-1, 0.5, -12) }, 0.18)
        end)
        btn.MouseLeave:Connect(function()
            Util.Tween(btn, { BackgroundTransparency = 0.3, Size = UDim2.fromOffset(22,22),
                Position = UDim2.new(1, xOff, 0.5, -11) }, 0.18)
        end)
        btn.MouseButton1Click:Connect(callback)
        return btn
    end

    local CloseBtn    = makeControlBtn("✕", -14, Theme.Error,   function()
        Util.Tween(MainFrame, { Size = UDim2.fromOffset(config.Size.X.Offset, 0),
            Position = UDim2.new(0.5,-config.Size.X.Offset/2,0.5,0),
            BackgroundTransparency = 1 }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        Util.Tween(GlowBack,  { BackgroundTransparency = 1 }, 0.3)
        task.wait(0.32)
        ScreenGui:Destroy()
    end)
    local MinBtn = makeControlBtn("—", -42, Theme.Warning, function()
        local isMin = MainFrame.Size.Y.Offset < 50
        if isMin then
            Util.SpringTween(MainFrame, { Size = config.Size }, 0.45)
        else
            Util.Tween(MainFrame, { Size = UDim2.fromOffset(config.Size.X.Offset, 46) }, 0.3, Enum.EasingStyle.Quint)
        end
    end)

    -- ─── Draggable Toggle (outside window) ─────────
    local DragToggle = Util.Make("TextButton", {
        Size = UDim2.fromOffset(38, 38),
        Position = UDim2.new(0.5, -config.Size.X.Offset/2 - 52, 0.5, -19),
        BackgroundColor3 = Theme.Surface,
        Text = "⊞",
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextColor3 = Theme.Accent,
        ZIndex = 10,
    }, ScreenGui)
    Util.RoundCorners(DragToggle, 10)
    Util.AddStroke(DragToggle, Theme.Border, 1, 0.2)
    Util.MakeDraggable(DragToggle)

    local windowVisible = true
    DragToggle.MouseButton1Click:Connect(function()
        windowVisible = not windowVisible
        if windowVisible then
            MainFrame.Visible = true
            Util.SpringTween(MainFrame, {
                Size = config.Size,
                BackgroundTransparency = Theme.TransBackground
            }, 0.45)
        else
            Util.Tween(MainFrame, {
                Size = UDim2.fromOffset(config.Size.X.Offset, 0),
                BackgroundTransparency = 1
            }, 0.28, Enum.EasingStyle.Quint)
            task.delay(0.3, function() MainFrame.Visible = false end)
        end
    end)

    -- ─── Tab Navigation ────────────────────────────
    local TabBar = Util.Make("ScrollingFrame", {
        Size = UDim2.new(0, 140, 1, -46),
        Position = UDim2.fromOffset(0, 46),
        BackgroundColor3 = Theme.BackgroundAlt,
        BackgroundTransparency = 0.05,
        ScrollBarThickness = 0,
        ZIndex = 3,
    }, MainFrame)
    Util.RoundCorners(TabBar, 0)

    local TabBarLayout = Util.Make("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, TabBar)
    Util.AddPadding(TabBar, 8, 8, 8, 8)

    -- Tab/content separator
    Util.Make("Frame", {
        Size = UDim2.new(0, 1, 1, -46),
        Position = UDim2.fromOffset(140, 46),
        BackgroundColor3 = Theme.Border,
        BackgroundTransparency = 0.4,
        ZIndex = 3,
    }, MainFrame)

    -- ─── Content Area ──────────────────────────────
    local ContentArea = Util.Make("Frame", {
        Size = UDim2.new(1, -148, 1, -54),
        Position = UDim2.fromOffset(148, 54),
        BackgroundTransparency = 1,
        ZIndex = 3,
    }, MainFrame)

    local ActiveTabContent = nil
    local ActiveTabBtn     = nil

    -- ═══════════════════════════════════════════════
    --  WINDOW OBJECT
    -- ═══════════════════════════════════════════════
    local WindowObj = {}
    WindowObj._tabs = {}
    WindowObj._frame = MainFrame

    -- ─── Add Tab ───────────────────────────────────
    function WindowObj:AddTab(tabConfig)
        tabConfig = tabConfig or {}
        tabConfig.Name = tabConfig.Name or "Tab"

        -- Tab button
        local TabBtn = Util.Make("TextButton", {
            Size = UDim2.new(1, 0, 0, 32),
            BackgroundColor3 = Theme.SurfaceAlt,
            BackgroundTransparency = 0.6,
            Text = tabConfig.Name,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextColor3 = Theme.TextSecondary,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 4,
            LayoutOrder = #WindowObj._tabs + 1,
        }, TabBar)
        Util.RoundCorners(TabBtn, 7)
        Util.AddPadding(TabBtn, 0, 0, 10, 6)

        local TabIndicator = Util.Make("Frame", {
            Size = UDim2.fromOffset(3, 16),
            Position = UDim2.new(0, -8, 0.5, -8),
            BackgroundColor3 = Theme.Accent,
            BackgroundTransparency = 1,
            ZIndex = 5,
        }, TabBtn)
        Util.RoundCorners(TabIndicator, 2)

        -- Tab scroll content
        local ScrollFrame = Util.Make("ScrollingFrame", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.AccentDim,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Visible = false,
            ZIndex = 3,
        }, ContentArea)

        local ListLayout = Util.Make("UIListLayout", {
            Padding = UDim.new(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }, ScrollFrame)
        Util.AddPadding(ScrollFrame, 8, 8, 8, 8)

        ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 20)
        end)

        -- Select logic
        local function SelectTab()
            if ActiveTabContent then
                ActiveTabContent.Visible = false
                Util.Tween(ActiveTabBtn, {
                    BackgroundTransparency = 0.6,
                    TextColor3 = Theme.TextSecondary,
                }, 0.2)
                if ActiveTabBtn:FindFirstChild("Frame") then
                    Util.Tween(ActiveTabBtn.Frame, { BackgroundTransparency = 1 }, 0.2)
                end
            end
            ActiveTabContent = ScrollFrame
            ActiveTabBtn     = TabBtn
            ScrollFrame.Visible = true
            Util.Tween(TabBtn, {
                BackgroundTransparency = 0.1,
                TextColor3 = Theme.TextAccent,
            }, 0.25)
            Util.Tween(TabIndicator, { BackgroundTransparency = 0 }, 0.25)
        end

        TabBtn.MouseButton1Click:Connect(SelectTab)
        TabBtn.MouseEnter:Connect(function()
            if TabBtn ~= ActiveTabBtn then
                Util.Tween(TabBtn, { BackgroundTransparency = 0.4 }, 0.15)
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if TabBtn ~= ActiveTabBtn then
                Util.Tween(TabBtn, { BackgroundTransparency = 0.6 }, 0.15)
            end
        end)

        if #WindowObj._tabs == 0 then SelectTab() end
        table.insert(WindowObj._tabs, { btn = TabBtn, content = ScrollFrame })

        -- ═══════════════════════════════════════════
        --  TAB OBJECT (Component Builders)
        -- ═══════════════════════════════════════════
        local TabObj = {}
        TabObj._scroll = ScrollFrame
        TabObj._order  = 0

        local function nextOrder()
            TabObj._order = TabObj._order + 1
            return TabObj._order
        end

        -- ── Component Base ─────────────────────────
        local function MakeItem(height)
            local item = Util.Make("Frame", {
                Size = UDim2.new(1, -8, 0, height or 36),
                BackgroundColor3 = Theme.Surface,
                BackgroundTransparency = 0.3,
                ZIndex = 4,
                LayoutOrder = nextOrder(),
            }, ScrollFrame)
            Util.RoundCorners(item, 7)
            Util.AddStroke(item, Theme.Border, 0.8, 0.5)
            return item
        end

        -- ── BUTTON ─────────────────────────────────
        function TabObj:AddButton(cfg)
            cfg = cfg or {}
            local item = MakeItem(36)
            local btn = Util.Make("TextButton", {
                Size = UDim2.fromScale(1, 1),
                BackgroundTransparency = 1,
                Text = cfg.Name or "Button",
                Font = Enum.Font.Gotham,
                TextSize = 13,
                TextColor3 = Theme.TextPrimary,
                ZIndex = 5,
            }, item)
            Util.RoundCorners(btn, 7)

            local highlight = Util.Make("Frame", {
                Size = UDim2.fromScale(1, 1),
                BackgroundColor3 = Theme.AccentDark,
                BackgroundTransparency = 1,
                ZIndex = 4,
            }, item)
            Util.RoundCorners(highlight, 7)

            btn.MouseEnter:Connect(function()
                Util.Tween(highlight, { BackgroundTransparency = 0.6 }, 0.18)
                Util.Tween(btn, { TextColor3 = Theme.TextAccent }, 0.18)
            end)
            btn.MouseLeave:Connect(function()
                Util.Tween(highlight, { BackgroundTransparency = 1 }, 0.18)
                Util.Tween(btn, { TextColor3 = Theme.TextPrimary }, 0.18)
            end)
            btn.MouseButton1Click:Connect(function()
                Util.Tween(highlight, { BackgroundTransparency = 0.3 }, 0.08)
                task.delay(0.1, function()
                    Util.Tween(highlight, { BackgroundTransparency = 1 }, 0.2)
                end)
                if cfg.Callback then cfg.Callback() end
            end)
        end

        -- ── TOGGLE ─────────────────────────────────
        function TabObj:AddToggle(cfg)
            cfg = cfg or {}
            local item   = MakeItem(36)
            local toggled = cfg.Default or false

            Util.Make("TextLabel", {
                Size = UDim2.new(1, -60, 1, 0),
                BackgroundTransparency = 1,
                Text = cfg.Name or "Toggle",
                Font = Enum.Font.Gotham,
                TextSize = 13,
                TextColor3 = Theme.TextPrimary,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 5,
            }, item)
            Util.AddPadding(item, 0, 0, 12, 12)

            local track = Util.Make("Frame", {
                Size = UDim2.fromOffset(38, 20),
                Position = UDim2.new(1, -50, 0.5, -10),
                BackgroundColor3 = toggled and Theme.Accent or Theme.SurfaceAlt,
                ZIndex = 5,
            }, item)
            Util.RoundCorners(track, 10)

            local knob = Util.Make("Frame", {
                Size = UDim2.fromOffset(14, 14),
                Position = toggled and UDim2.fromOffset(21, 3) or UDim2.fromOffset(3, 3),
                BackgroundColor3 = Theme.TextPrimary,
                ZIndex = 6,
            }, track)
            Util.RoundCorners(knob, 7)

            local function updateToggle(val)
                toggled = val
                Util.Tween(track, { BackgroundColor3 = toggled and Theme.Accent or Theme.SurfaceAlt }, 0.2)
                Util.Tween(knob,  { Position = toggled and UDim2.fromOffset(21,3) or UDim2.fromOffset(3,3) }, 0.22, Enum.EasingStyle.Back)
            end

            local clickArea = Util.Make("TextButton", {
                Size = UDim2.fromScale(1,1),
                BackgroundTransparency = 1,
                Text = "",
                ZIndex = 7,
            }, item)
            clickArea.MouseButton1Click:Connect(function()
                updateToggle(not toggled)
                if cfg.Callback then cfg.Callback(toggled) end
            end)
        end

        -- ── SLIDER ─────────────────────────────────
        function TabObj:AddSlider(cfg)
            cfg = cfg or {}
            local item = MakeItem(48)
            local min, max = cfg.Min or 0, cfg.Max or 100
            local val = math.clamp(cfg.Default or min, min, max)

            Util.Make("TextLabel", {
                Size = UDim2.new(1, -60, 0, 18),
                Position = UDim2.fromOffset(0, 6),
                BackgroundTransparency = 1,
                Text = cfg.Name or "Slider",
                Font = Enum.Font.Gotham,
                TextSize = 12,
                TextColor3 = Theme.TextPrimary,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 5,
            }, item)
            Util.AddPadding(item, 0, 0, 12, 12)

            local valLabel = Util.Make("TextLabel", {
                Size = UDim2.fromOffset(48, 18),
                Position = UDim2.new(1, -60, 0, 6),
                BackgroundTransparency = 1,
                Text = tostring(val),
                Font = Enum.Font.GothamBold,
                TextSize = 12,
                TextColor3 = Theme.TextAccent,
                TextXAlignment = Enum.TextXAlignment.Right,
                ZIndex = 5,
            }, item)

            local track = Util.Make("Frame", {
                Size = UDim2.new(1, -24, 0, 4),
                Position = UDim2.new(0, 0, 0, 30),
                BackgroundColor3 = Theme.SurfaceAlt,
                ZIndex = 5,
            }, item)
            Util.RoundCorners(track, 3)

            local fill = Util.Make("Frame", {
                Size = UDim2.fromScale((val - min) / (max - min), 1),
                BackgroundColor3 = Theme.Accent,
                ZIndex = 6,
            }, track)
            Util.RoundCorners(fill, 3)
            Util.AddGradient(fill, 0, ColorSequence.new({
                ColorSequenceKeypoint.new(0, Theme.AccentDim),
                ColorSequenceKeypoint.new(1, Theme.AccentGlow),
            }))

            local thumb = Util.Make("Frame", {
                Size = UDim2.fromOffset(12, 12),
                Position = UDim2.new((val-min)/(max-min), -6, 0.5, -6),
                BackgroundColor3 = Theme.TextPrimary,
                ZIndex = 7,
            }, track)
            Util.RoundCorners(thumb, 6)

            local dragging = false
            local function updateSlider(x)
                local rel = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                val = math.floor(Util.Lerp(min, max, rel))
                valLabel.Text = tostring(val)
                Util.Tween(fill,  { Size = UDim2.fromScale(rel, 1) }, 0.08)
                Util.Tween(thumb, { Position = UDim2.new(rel, -6, 0.5, -6) }, 0.08)
                if cfg.Callback then cfg.Callback(val) end
            end

            track.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    updateSlider(inp.Position.X)
                end
            end)
            UserInputService.InputChanged:Connect(function(inp)
                if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
                    updateSlider(inp.Position.X)
                end
            end)
            UserInputService.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
        end

        -- ── DROPDOWN ───────────────────────────────
        function TabObj:AddDropdown(cfg)
            cfg = cfg or {}
            local item = MakeItem(36)
            local options = cfg.Options or {}
            local selected = cfg.Default or (options[1] or "Select...")
            local isOpen = false

            Util.Make("TextLabel", {
                Size = UDim2.new(0.5, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = cfg.Name or "Dropdown",
                Font = Enum.Font.Gotham,
                TextSize = 12,
                TextColor3 = Theme.TextPrimary,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 5,
            }, item)
            Util.AddPadding(item, 0, 0, 12, 8)

            local selLabel = Util.Make("TextButton", {
                Size = UDim2.new(0.5, -8, 0, 24),
                Position = UDim2.new(0.5, 4, 0.5, -12),
                BackgroundColor3 = Theme.SurfaceAlt,
                Text = selected .. "  ▾",
                Font = Enum.Font.Gotham,
                TextSize = 11,
                TextColor3 = Theme.TextSecondary,
                ZIndex = 5,
            }, item)
            Util.RoundCorners(selLabel, 5)

            local dropList = Util.Make("Frame", {
                Size = UDim2.new(0, selLabel.Size.X.Offset, 0, 0),
                Position = UDim2.new(0.5, 4, 1, 2),
                BackgroundColor3 = Theme.Surface,
                ClipsDescendants = true,
                ZIndex = 20,
            }, item)
            Util.RoundCorners(dropList, 6)
            Util.AddStroke(dropList, Theme.Border, 1, 0.3)

            local dropLayout = Util.Make("UIListLayout", { Padding = UDim.new(0,2), SortOrder = Enum.SortOrder.LayoutOrder }, dropList)

            local function closeDropdown()
                isOpen = false
                Util.Tween(dropList, { Size = UDim2.new(0, selLabel.AbsoluteSize.X, 0, 0) }, 0.2, Enum.EasingStyle.Quint)
            end

            selLabel.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                if isOpen then
                    local h = math.min(#options * 26 + 4, 120)
                    Util.Tween(dropList, { Size = UDim2.new(0, selLabel.AbsoluteSize.X, 0, h) }, 0.25, Enum.EasingStyle.Back)
                else closeDropdown() end
            end)

            for i, opt in ipairs(options) do
                local optBtn = Util.Make("TextButton", {
                    Size = UDim2.new(1, 0, 0, 26),
                    BackgroundColor3 = Theme.SurfaceAlt,
                    BackgroundTransparency = 0.5,
                    Text = opt,
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    TextColor3 = Theme.TextSecondary,
                    LayoutOrder = i,
                    ZIndex = 21,
                }, dropList)
                Util.AddPadding(optBtn, 0, 0, 8, 8)
                optBtn.MouseButton1Click:Connect(function()
                    selected = opt
                    selLabel.Text = opt .. "  ▾"
                    Util.Tween(selLabel, { TextColor3 = Theme.TextAccent }, 0.2)
                    closeDropdown()
                    if cfg.Callback then cfg.Callback(opt) end
                end)
                optBtn.MouseEnter:Connect(function()
                    Util.Tween(optBtn, { BackgroundTransparency = 0.1, TextColor3 = Theme.TextAccent }, 0.15)
                end)
                optBtn.MouseLeave:Connect(function()
                    Util.Tween(optBtn, { BackgroundTransparency = 0.5, TextColor3 = Theme.TextSecondary }, 0.15)
                end)
            end
        end

        -- ── TEXTBOX ────────────────────────────────
        function TabObj:AddTextBox(cfg)
            cfg = cfg or {}
            local item = MakeItem(36)

            Util.Make("TextLabel", {
                Size = UDim2.new(0.45, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = cfg.Name or "Input",
                Font = Enum.Font.Gotham,
                TextSize = 12,
                TextColor3 = Theme.TextPrimary,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 5,
            }, item)
            Util.AddPadding(item, 0, 0, 12, 8)

            local box = Util.Make("TextBox", {
                Size = UDim2.new(0.55, -8, 0, 24),
                Position = UDim2.new(0.45, 4, 0.5, -12),
                BackgroundColor3 = Theme.SurfaceAlt,
                BackgroundTransparency = 0.2,
                Text = cfg.Default or "",
                PlaceholderText = cfg.Default or "Type...",
                Font = Enum.Font.Gotham,
                TextSize = 11,
                TextColor3 = Theme.TextPrimary,
                PlaceholderColor3 = Theme.TextMuted,
                ClearTextOnFocus = false,
                ZIndex = 5,
            }, item)
            Util.RoundCorners(box, 5)
            Util.AddStroke(box, Theme.Border, 1, 0.4)

            box.Focused:Connect(function()
                Util.Tween(box, { BackgroundTransparency = 0.05 }, 0.2)
                Util.AddStroke(box, Theme.Accent, 1.5, 0)
            end)
            box.FocusLost:Connect(function(enter)
                Util.Tween(box, { BackgroundTransparency = 0.2 }, 0.2)
                Util.AddStroke(box, Theme.Border, 1, 0.4)
                if cfg.Callback then cfg.Callback(box.Text) end
            end)
        end

        -- ── CHECKBOX ───────────────────────────────
        function TabObj:AddCheckbox(cfg)
            cfg = cfg or {}
            local item   = MakeItem(36)
            local checked = cfg.Default or false

            Util.Make("TextLabel", {
                Size = UDim2.new(1, -44, 1, 0),
                BackgroundTransparency = 1,
                Text = cfg.Name or "Checkbox",
                Font = Enum.Font.Gotham,
                TextSize = 12,
                TextColor3 = Theme.TextPrimary,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 5,
            }, item)
            Util.AddPadding(item, 0, 0, 12, 8)

            local box = Util.Make("Frame", {
                Size = UDim2.fromOffset(18, 18),
                Position = UDim2.new(1, -32, 0.5, -9),
                BackgroundColor3 = checked and Theme.Accent or Theme.SurfaceAlt,
                ZIndex = 5,
            }, item)
            Util.RoundCorners(box, 4)
            Util.AddStroke(box, checked and Theme.Accent or Theme.Border, 1.5, 0)

            local tick = Util.Make("TextLabel", {
                Size = UDim2.fromScale(1,1),
                BackgroundTransparency = 1,
                Text = "✓",
                Font = Enum.Font.GothamBold,
                TextSize = 12,
                TextColor3 = Theme.Background,
                TextTransparency = checked and 0 or 1,
                ZIndex = 6,
            }, box)

            local clickArea = Util.Make("TextButton", {
                Size = UDim2.fromScale(1,1), BackgroundTransparency = 1, Text = "", ZIndex = 7
            }, item)
            clickArea.MouseButton1Click:Connect(function()
                checked = not checked
                Util.Tween(box,  { BackgroundColor3 = checked and Theme.Accent or Theme.SurfaceAlt }, 0.2)
                Util.Tween(tick, { TextTransparency = checked and 0 or 1 }, 0.15)
                if cfg.Callback then cfg.Callback(checked) end
            end)
        end

        -- ── COLOR PICKER ───────────────────────────
        function TabObj:AddColorPicker(cfg)
            cfg = cfg or {}
            local item = MakeItem(36)
            local color = cfg.Default or Color3.fromRGB(80, 220, 120)

            Util.Make("TextLabel", {
                Size = UDim2.new(1, -70, 1, 0),
                BackgroundTransparency = 1,
                Text = cfg.Name or "Color",
                Font = Enum.Font.Gotham, TextSize = 12,
                TextColor3 = Theme.TextPrimary,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 5,
            }, item)
            Util.AddPadding(item, 0, 0, 12, 8)

            local preview = Util.Make("Frame", {
                Size = UDim2.fromOffset(28, 20),
                Position = UDim2.new(1, -40, 0.5, -10),
                BackgroundColor3 = color,
                ZIndex = 5,
            }, item)
            Util.RoundCorners(preview, 5)
            Util.AddStroke(preview, Theme.Border, 1, 0.3)

            local hexLabel = Util.Make("TextBox", {
                Size = UDim2.fromOffset(52, 18),
                Position = UDim2.new(1, -98, 0.5, -9),
                BackgroundColor3 = Theme.SurfaceAlt,
                BackgroundTransparency = 0.3,
                Text = string.format("#%02X%02X%02X",
                    math.floor(color.R*255),
                    math.floor(color.G*255),
                    math.floor(color.B*255)),
                Font = Enum.Font.Code, TextSize = 10,
                TextColor3 = Theme.TextSecondary,
                ZIndex = 5,
            }, item)
            Util.RoundCorners(hexLabel, 4)

            hexLabel.FocusLost:Connect(function()
                local hex = hexLabel.Text:gsub("#","")
                if #hex == 6 then
                    local r = tonumber(hex:sub(1,2), 16)
                    local g = tonumber(hex:sub(3,4), 16)
                    local b = tonumber(hex:sub(5,6), 16)
                    if r and g and b then
                        color = Color3.fromRGB(r, g, b)
                        Util.Tween(preview, { BackgroundColor3 = color }, 0.2)
                        if cfg.Callback then cfg.Callback(color) end
                    end
                end
            end)
        end

        -- ── KEYBIND ────────────────────────────────
        function TabObj:AddKeybind(cfg)
            cfg = cfg or {}
            local item = MakeItem(36)
            local key  = cfg.Default or Enum.KeyCode.F
            local listening = false

            Util.Make("TextLabel", {
                Size = UDim2.new(1, -90, 1, 0),
                BackgroundTransparency = 1,
                Text = cfg.Name or "Keybind",
                Font = Enum.Font.Gotham, TextSize = 12,
                TextColor3 = Theme.TextPrimary,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 5,
            }, item)
            Util.AddPadding(item, 0, 0, 12, 8)

            local keyBtn = Util.Make("TextButton", {
                Size = UDim2.fromOffset(72, 22),
                Position = UDim2.new(1, -84, 0.5, -11),
                BackgroundColor3 = Theme.SurfaceAlt,
                Text = "[" .. key.Name .. "]",
                Font = Enum.Font.Code, TextSize = 11,
                TextColor3 = Theme.TextAccent,
                ZIndex = 5,
            }, item)
            Util.RoundCorners(keyBtn, 5)
            Util.AddStroke(keyBtn, Theme.Border, 1, 0.4)

            keyBtn.MouseButton1Click:Connect(function()
                listening = true
                keyBtn.Text = "[...]"
                Util.Tween(keyBtn, { BackgroundColor3 = Theme.AccentDark }, 0.15)
            end)

            UserInputService.InputBegan:Connect(function(inp)
                if listening and inp.UserInputType == Enum.UserInputType.Keyboard then
                    key = inp.KeyCode
                    keyBtn.Text = "[" .. key.Name .. "]"
                    Util.Tween(keyBtn, { BackgroundColor3 = Theme.SurfaceAlt }, 0.2)
                    listening = false
                end
                if not listening and inp.KeyCode == key then
                    if cfg.Callback then cfg.Callback() end
                end
            end)
        end

        -- ── LABEL ──────────────────────────────────
        function TabObj:AddLabel(cfg)
            cfg = cfg or {}
            local item = MakeItem(28)
            item.BackgroundTransparency = 1
            Util.Make("TextLabel", {
                Size = UDim2.fromScale(1, 1),
                BackgroundTransparency = 1,
                Text = cfg.Text or "Label",
                Font = Enum.Font.Gotham, TextSize = 12,
                TextColor3 = Theme.TextSecondary,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 5,
            }, item)
            Util.AddPadding(item, 0, 0, 12, 8)
        end

        -- ── PARAGRAPH ──────────────────────────────
        function TabObj:AddParagraph(cfg)
            cfg = cfg or {}
            local item = MakeItem(60)
            Util.Make("TextLabel", {
                Size = UDim2.new(1, 0, 0, 20),
                Position = UDim2.fromOffset(0, 4),
                BackgroundTransparency = 1,
                Text = cfg.Title or "",
                Font = Enum.Font.GothamBold, TextSize = 12,
                TextColor3 = Theme.TextPrimary,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 5,
            }, item)
            Util.Make("TextLabel", {
                Size = UDim2.new(1, 0, 0, 32),
                Position = UDim2.fromOffset(0, 24),
                BackgroundTransparency = 1,
                Text = cfg.Content or "",
                Font = Enum.Font.Gotham, TextSize = 11,
                TextColor3 = Theme.TextMuted,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 5,
            }, item)
            Util.AddPadding(item, 0, 0, 12, 8)
        end

        -- ── DIVIDER ────────────────────────────────
        function TabObj:AddDivider()
            local div = Util.Make("Frame", {
                Size = UDim2.new(1, -8, 0, 1),
                BackgroundColor3 = Theme.Border,
                BackgroundTransparency = 0.4,
                LayoutOrder = nextOrder(),
            }, ScrollFrame)
            Util.AddGradient(div, 0, ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(0,0,0)),
                ColorSequenceKeypoint.new(0.5, Theme.Border),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(0,0,0)),
            }))
        end

        return TabObj
    end -- AddTab

    return WindowObj
end -- CreateWindow

return SamsHub
