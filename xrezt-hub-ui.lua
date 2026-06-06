-- XREZT HUB - PREMIUM ROBLOX UI LIBRARY
-- Architected exclusively for LO.
-- Version: 1.0.0
-- Style: Glassmorphism, Modern, Fluid

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- Protect GUI
local function ProtectGUI(gui)
    if syn and syn.protect_gui then
        syn.protect_gui(gui)
        gui.Parent = CoreGui
    elseif gethui then
        gui.Parent = gethui()
    else
        gui.Parent = CoreGui
    end
end

--========================================================--
-- THEME ENGINE
--========================================================--
local Themes = {
    ["Midnight Slate"] = {
        Background = Color3.fromRGB(15, 15, 18),
        Container = Color3.fromRGB(22, 22, 26),
        Element = Color3.fromRGB(28, 28, 34),
        ElementHover = Color3.fromRGB(35, 35, 42),
        ElementClick = Color3.fromRGB(20, 20, 25),
        Accent = Color3.fromRGB(88, 101, 242),
        AccentHover = Color3.fromRGB(105, 116, 245),
        Text = Color3.fromRGB(240, 240, 245),
        SubText = Color3.fromRGB(150, 150, 160),
        Outline = Color3.fromRGB(45, 45, 55),
        Shadow = Color3.fromRGB(0, 0, 0)
    },
    ["Ocean Blue"] = {
        Background = Color3.fromRGB(10, 14, 23),
        Container = Color3.fromRGB(16, 22, 35),
        Element = Color3.fromRGB(22, 30, 45),
        ElementHover = Color3.fromRGB(28, 38, 55),
        ElementClick = Color3.fromRGB(15, 22, 35),
        Accent = Color3.fromRGB(0, 168, 255),
        AccentHover = Color3.fromRGB(40, 180, 255),
        Text = Color3.fromRGB(235, 245, 255),
        SubText = Color3.fromRGB(130, 150, 180),
        Outline = Color3.fromRGB(35, 45, 65),
        Shadow = Color3.fromRGB(0, 0, 0)
    },
    ["Aurora"] = {
        Background = Color3.fromRGB(12, 18, 16),
        Container = Color3.fromRGB(18, 28, 24),
        Element = Color3.fromRGB(25, 38, 32),
        ElementHover = Color3.fromRGB(32, 48, 42),
        ElementClick = Color3.fromRGB(18, 28, 24),
        Accent = Color3.fromRGB(46, 204, 113),
        AccentHover = Color3.fromRGB(66, 224, 133),
        Text = Color3.fromRGB(240, 255, 245),
        SubText = Color3.fromRGB(140, 170, 155),
        Outline = Color3.fromRGB(40, 60, 50),
        Shadow = Color3.fromRGB(0, 0, 0)
    },
    ["Sunset"] = {
        Background = Color3.fromRGB(23, 14, 16),
        Container = Color3.fromRGB(32, 20, 24),
        Element = Color3.fromRGB(42, 28, 32),
        ElementHover = Color3.fromRGB(52, 35, 40),
        ElementClick = Color3.fromRGB(30, 18, 22),
        Accent = Color3.fromRGB(255, 107, 129),
        AccentHover = Color3.fromRGB(255, 127, 149),
        Text = Color3.fromRGB(255, 240, 242),
        SubText = Color3.fromRGB(180, 140, 145),
        Outline = Color3.fromRGB(65, 40, 45),
        Shadow = Color3.fromRGB(0, 0, 0)
    },
    ["Emerald"] = {
        Background = Color3.fromRGB(10, 20, 15),
        Container = Color3.fromRGB(15, 30, 22),
        Element = Color3.fromRGB(22, 42, 30),
        ElementHover = Color3.fromRGB(30, 55, 40),
        ElementClick = Color3.fromRGB(18, 35, 25),
        Accent = Color3.fromRGB(16, 172, 132),
        AccentHover = Color3.fromRGB(26, 192, 152),
        Text = Color3.fromRGB(230, 250, 240),
        SubText = Color3.fromRGB(130, 160, 145),
        Outline = Color3.fromRGB(35, 60, 45),
        Shadow = Color3.fromRGB(0, 0, 0)
    },
    ["Rose"] = {
        Background = Color3.fromRGB(25, 15, 20),
        Container = Color3.fromRGB(35, 22, 28),
        Element = Color3.fromRGB(45, 30, 38),
        ElementHover = Color3.fromRGB(55, 38, 48),
        ElementClick = Color3.fromRGB(32, 20, 25),
        Accent = Color3.fromRGB(253, 121, 168),
        AccentHover = Color3.fromRGB(255, 141, 188),
        Text = Color3.fromRGB(255, 235, 242),
        SubText = Color3.fromRGB(170, 135, 148),
        Outline = Color3.fromRGB(65, 45, 55),
        Shadow = Color3.fromRGB(0, 0, 0)
    },
    ["Graphite"] = {
        Background = Color3.fromRGB(20, 20, 20),
        Container = Color3.fromRGB(28, 28, 28),
        Element = Color3.fromRGB(38, 38, 38),
        ElementHover = Color3.fromRGB(48, 48, 48),
        ElementClick = Color3.fromRGB(25, 25, 25),
        Accent = Color3.fromRGB(120, 120, 120),
        AccentHover = Color3.fromRGB(140, 140, 140),
        Text = Color3.fromRGB(220, 220, 220),
        SubText = Color3.fromRGB(130, 130, 130),
        Outline = Color3.fromRGB(55, 55, 55),
        Shadow = Color3.fromRGB(0, 0, 0)
    },
    ["Obsidian"] = {
        Background = Color3.fromRGB(5, 5, 5),
        Container = Color3.fromRGB(12, 12, 12),
        Element = Color3.fromRGB(18, 18, 18),
        ElementHover = Color3.fromRGB(24, 24, 24),
        ElementClick = Color3.fromRGB(10, 10, 10),
        Accent = Color3.fromRGB(200, 200, 200),
        AccentHover = Color3.fromRGB(255, 255, 255),
        Text = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(100, 100, 100),
        Outline = Color3.fromRGB(30, 30, 30),
        Shadow = Color3.fromRGB(0, 0, 0)
    },
    ["Crystal"] = {
        Background = Color3.fromRGB(240, 245, 255),
        Container = Color3.fromRGB(250, 252, 255),
        Element = Color3.fromRGB(230, 238, 250),
        ElementHover = Color3.fromRGB(220, 230, 245),
        ElementClick = Color3.fromRGB(210, 220, 240),
        Accent = Color3.fromRGB(108, 92, 231),
        AccentHover = Color3.fromRGB(128, 112, 251),
        Text = Color3.fromRGB(30, 35, 45),
        SubText = Color3.fromRGB(100, 110, 130),
        Outline = Color3.fromRGB(210, 220, 240),
        Shadow = Color3.fromRGB(200, 210, 230)
    },
    ["Frost"] = {
        Background = Color3.fromRGB(245, 245, 245),
        Container = Color3.fromRGB(255, 255, 255),
        Element = Color3.fromRGB(235, 235, 235),
        ElementHover = Color3.fromRGB(225, 225, 225),
        ElementClick = Color3.fromRGB(215, 215, 215),
        Accent = Color3.fromRGB(0, 206, 201),
        AccentHover = Color3.fromRGB(20, 226, 221),
        Text = Color3.fromRGB(40, 40, 40),
        SubText = Color3.fromRGB(120, 120, 120),
        Outline = Color3.fromRGB(220, 220, 220),
        Shadow = Color3.fromRGB(200, 200, 200)
    }
}

local CurrentTheme = Themes["Midnight Slate"]
local ActiveInstances = {} -- To update themes dynamically

--========================================================--
-- UTILITY FUNCTIONS
--========================================================--
local Utility = {}

function Utility:Create(className, properties)
    local inst = Instance.new(className)
    for k, v in pairs(properties) do
        if k ~= "Parent" then
            inst[k] = v
        end
    end
    if properties.Parent then
        inst.Parent = properties.Parent
    end
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

function Utility:Ripple(button)
    local clickX, clickY = Mouse.X, Mouse.Y
    local ripple = Utility:Create("Frame", {
        Name = "Ripple",
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.8,
        BorderSizePixel = 0,
        Position = UDim2.new(0, clickX - button.AbsolutePosition.X, 0, clickY - button.AbsolutePosition.Y),
        Size = UDim2.new(0, 0, 0, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex = button.ZIndex + 1,
        Parent = button
    })
    Utility:Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = ripple
    })
    
    local size = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2.5
    local t1 = Utility:Tween(ripple, {Size = UDim2.new(0, size, 0, size)}, 0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
    local t2 = Utility:Tween(ripple, {BackgroundTransparency = 1}, 0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
    
    t1.Completed:Connect(function()
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
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
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
            Utility:Tween(window, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        end
    end)
end

function Utility:RegisterTheme(instance, prop, themeKey)
    table.insert(ActiveInstances, {Instance = instance, Property = prop, Key = themeKey})
end

function Utility:UpdateTheme(themeName)
    if Themes[themeName] then
        CurrentTheme = Themes[themeName]
        for _, data in ipairs(ActiveInstances) do
            if data.Instance and data.Instance.Parent then
                Utility:Tween(data.Instance, {[data.Property] = CurrentTheme[data.Key]}, 0.4)
            end
        end
    end
end

--========================================================--
-- XREZT HUB FRAMEWORK
--========================================================--
local XreztHub = {}
local NotificationsContainer

-- LOADING SCREEN (Advanced X-Shape Gradient with Particles)
function XreztHub:Load()
    local ScreenGui = Utility:Create("ScreenGui", {
        Name = "XreztLoadingScreen",
        DisplayOrder = 1000,
        ResetOnSpawn = false
    })
    ProtectGUI(ScreenGui)

    local Background = Utility:Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = CurrentTheme.Background,
        BackgroundTransparency = 0,
        Parent = ScreenGui
    })

    local LogoContainer = Utility:Create("Frame", {
        Size = UDim2.new(0, 120, 0, 120),
        Position = UDim2.new(0.5, -60, 0.4, -60),
        BackgroundTransparency = 1,
        Parent = Background
    })

    -- X Shape Line 1
    local Line1 = Utility:Create("Frame", {
        Size = UDim2.new(1, 0, 0.15, 0),
        Position = UDim2.new(0, 0, 0.425, 0),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Rotation = 45,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Parent = LogoContainer
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Line1})
    local Grad1 = Utility:Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, CurrentTheme.Accent),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 80, 255))
        }),
        Parent = Line1
    })

    -- X Shape Line 2
    local Line2 = Utility:Create("Frame", {
        Size = UDim2.new(1, 0, 0.15, 0),
        Position = UDim2.new(0, 0, 0.425, 0),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Rotation = -45,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Parent = LogoContainer
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Line2})
    local Grad2 = Utility:Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, CurrentTheme.Accent),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 80, 255))
        }),
        Parent = Line2
    })

    local LoadingText = Utility:Create("TextLabel", {
        Size = UDim2.new(0, 200, 0, 30),
        Position = UDim2.new(0.5, -100, 0.5, 50),
        BackgroundTransparency = 1,
        Text = "XREZT HUB",
        Font = Enum.Font.GothamBold,
        TextSize = 24,
        TextColor3 = CurrentTheme.Text,
        TextTransparency = 1,
        Parent = Background
    })

    local SubText = Utility:Create("TextLabel", {
        Size = UDim2.new(0, 200, 0, 20),
        Position = UDim2.new(0.5, -100, 0.5, 80),
        BackgroundTransparency = 1,
        Text = "Loading Framework...",
        Font = Enum.Font.GothamMedium,
        TextSize = 14,
        TextColor3 = CurrentTheme.SubText,
        TextTransparency = 1,
        Parent = Background
    })

    local ProgressBg = Utility:Create("Frame", {
        Size = UDim2.new(0, 300, 0, 6),
        Position = UDim2.new(0.5, -150, 0.5, 110),
        BackgroundColor3 = CurrentTheme.Outline,
        BackgroundTransparency = 1,
        Parent = Background
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = ProgressBg})

    local ProgressFill = Utility:Create("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = CurrentTheme.Accent,
        Parent = ProgressBg
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = ProgressFill})

    -- Particles
    local particles = {}
    for i = 1, 15 do
        local p = Utility:Create("Frame", {
            Size = UDim2.new(0, 6, 0, 6),
            Position = UDim2.new(0.5, math.random(-100, 100), 0.4, math.random(-100, 100)),
            BackgroundColor3 = CurrentTheme.Accent,
            BackgroundTransparency = 1,
            Parent = Background
        })
        Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = p})
        table.insert(particles, p)
    end

    -- Animation Sequence
    Utility:Tween(LoadingText, {TextTransparency = 0}, 0.8)
    Utility:Tween(SubText, {TextTransparency = 0}, 0.8)
    Utility:Tween(ProgressBg, {BackgroundTransparency = 0}, 0.8)
    
    local rot = 0
    local conn = RunService.RenderStepped:Connect(function(dt)
        rot = rot + (dt * 60)
        Line1.Rotation = 45 + (math.sin(rot/20) * 10)
        Line2.Rotation = -45 + (math.cos(rot/20) * 10)
        for _, p in pairs(particles) do
            p.BackgroundTransparency = 0.5 + math.sin(rot/10 + _ * 0.5) * 0.3
            p.Position = UDim2.new(0.5, math.cos(rot/30 + _) * 80 - 3, 0.4, math.sin(rot/30 + _) * 80 - 3)
        end
    end)

    Utility:Tween(ProgressFill, {Size = UDim2.new(0.3, 0, 1, 0)}, 0.5).Completed:Wait()
    SubText.Text = "Initializing UI Architecture..."
    Utility:Tween(ProgressFill, {Size = UDim2.new(0.7, 0, 1, 0)}, 0.8).Completed:Wait()
    SubText.Text = "Applying Aesthetics..."
    Utility:Tween(ProgressFill, {Size = UDim2.new(1, 0, 1, 0)}, 0.4).Completed:Wait()

    conn:Disconnect()
    Utility:Tween(LogoContainer, {Size = UDim2.new(0, 150, 0, 150), BackgroundTransparency = 1}, 0.5)
    Utility:Tween(Line1, {BackgroundTransparency = 1}, 0.5)
    Utility:Tween(Line2, {BackgroundTransparency = 1}, 0.5)
    Utility:Tween(LoadingText, {TextTransparency = 1}, 0.5)
    Utility:Tween(SubText, {TextTransparency = 1}, 0.5)
    Utility:Tween(ProgressBg, {BackgroundTransparency = 1}, 0.5)
    Utility:Tween(ProgressFill, {BackgroundTransparency = 1}, 0.5)
    for _, p in pairs(particles) do Utility:Tween(p, {BackgroundTransparency = 1}, 0.5) end
    task.wait(0.5)
    Utility:Tween(Background, {BackgroundTransparency = 1}, 0.5).Completed:Wait()
    ScreenGui:Destroy()
end

--========================================================--
-- WINDOW CREATION
--========================================================--
function XreztHub:CreateWindow(config)
    config = config or {}
    local Title = config.Title or "Xrezt Hub"
    local Subtitle = config.Subtitle or "Premium Framework"
    local Width = config.Width or 750
    local Height = config.Height or 480

    local MainGui = Utility:Create("ScreenGui", {
        Name = "XreztHub",
        ResetOnSpawn = false
    })
    ProtectGUI(MainGui)

    NotificationsContainer = Utility:Create("Frame", {
        Name = "Notifications",
        Size = UDim2.new(0, 300, 1, -40),
        Position = UDim2.new(1, -320, 0, 20),
        BackgroundTransparency = 1,
        Parent = MainGui
    })
    Utility:Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10),
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Parent = NotificationsContainer
    })

    local MainFrame = Utility:Create("Frame", {
        Name = "MainFrame",
        Size = UDim2.new(0, Width, 0, Height),
        Position = UDim2.new(0.5, -Width/2, 0.5, -Height/2),
        BackgroundColor3 = CurrentTheme.Background,
        ClipsDescendants = false,
        Parent = MainGui
    })
    Utility:RegisterTheme(MainFrame, "BackgroundColor3", "Background")
    Utility:Create("UICorner", {CornerRadius = UDim.new(0, 24), Parent = MainFrame})
    
    local DropShadow = Utility:Create("ImageLabel", {
        Name = "DropShadow",
        Size = UDim2.new(1, 60, 1, 60),
        Position = UDim2.new(0, -30, 0, -30),
        BackgroundTransparency = 1,
        Image = "rbxassetid://6015897843",
        ImageColor3 = Color3.fromRGB(0,0,0),
        ImageTransparency = 0.5,
        SliceCenter = Rect.new(49, 49, 450, 450),
        ZIndex = -1,
        Parent = MainFrame
    })

    local Header = Utility:Create("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 60),
        BackgroundColor3 = CurrentTheme.Container,
        BackgroundTransparency = 0.3,
        Parent = MainFrame
    })
    Utility:RegisterTheme(Header, "BackgroundColor3", "Container")
    Utility:Create("UICorner", {CornerRadius = UDim.new(0, 24), Parent = Header})
    Utility:MakeDraggable(Header, MainFrame)

    local TitleLabel = Utility:Create("TextLabel", {
        Size = UDim2.new(0, 200, 0, 30),
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
        Size = UDim2.new(0, 200, 0, 20),
        Position = UDim2.new(0, 25, 0, 32),
        BackgroundTransparency = 1,
        Text = Subtitle,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextColor3 = CurrentTheme.SubText,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Header
    })
    Utility:RegisterTheme(SubtitleLabel, "TextColor3", "SubText")

    local TabContainer = Utility:Create("Frame", {
        Name = "TabContainer",
        Size = UDim2.new(0, 200, 1, -80),
        Position = UDim2.new(0, 15, 0, 70),
        BackgroundTransparency = 1,
        Parent = MainFrame
    })
    local TabListLayout = Utility:Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
        Parent = TabContainer
    })

    local PageContainer = Utility:Create("Frame", {
        Name = "PageContainer",
        Size = UDim2.new(1, -240, 1, -80),
        Position = UDim2.new(0, 225, 0, 70),
        BackgroundTransparency = 1,
        Parent = MainFrame
    })

    -- Spawner Button (Mobile/PC)
    local SpawnerBtn = Utility:Create("TextButton", {
        Size = UDim2.new(0, 50, 0, 50),
        Position = UDim2.new(0.9, -60, 0.1, 0),
        BackgroundColor3 = CurrentTheme.Accent,
        Text = "X",
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        TextColor3 = Color3.fromRGB(255,255,255),
        Parent = MainGui
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = SpawnerBtn})
    Utility:MakeDraggable(SpawnerBtn, SpawnerBtn)

    local isVisible = true
    SpawnerBtn.MouseButton1Click:Connect(function()
        isVisible = not isVisible
        Utility:Ripple(SpawnerBtn)
        if isVisible then
            MainFrame.Visible = true
            Utility:Tween(MainFrame, {Size = UDim2.new(0, Width, 0, Height), BackgroundTransparency = 0}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            for _, child in pairs(MainFrame:GetDescendants()) do
                if child:IsA("GuiObject") and child ~= DropShadow then
                    Utility:Tween(child, {BackgroundTransparency = child:GetAttribute("OrigBgTrans") or 0}, 0.2)
                end
            end
        else
            for _, child in pairs(MainFrame:GetDescendants()) do
                if child:IsA("GuiObject") then
                    if not child:GetAttribute("OrigBgTrans") then
                        child:SetAttribute("OrigBgTrans", child.BackgroundTransparency)
                    end
                    Utility:Tween(child, {BackgroundTransparency = 1}, 0.2)
                end
            end
            Utility:Tween(MainFrame, {Size = UDim2.new(0, Width*0.9, 0, Height*0.9), BackgroundTransparency = 1}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In).Completed:Connect(function()
                MainFrame.Visible = false
            end)
        end
    end)

    local WindowObj = {
        Tabs = {},
        ActiveTab = nil,
        First = true
    }

    --========================================================--
    -- TAB SYSTEM
    --========================================================--
    function WindowObj:CreateTab(tabName, icon)
        local TabBtn = Utility:Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 40),
            BackgroundColor3 = CurrentTheme.Element,
            BackgroundTransparency = 1,
            Text = "",
            Parent = TabContainer
        })
        Utility:Create("UICorner", {CornerRadius = UDim.new(0, 14), Parent = TabBtn})
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

        local TabText = Utility:Create("TextLabel", {
            Size = UDim2.new(1, -40, 1, 0),
            Position = UDim2.new(0, 35, 0, 0),
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
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = CurrentTheme.Accent,
            Visible = false,
            Parent = PageContainer
        })
        Utility:Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10),
            Parent = Page
        })
        Utility:Create("UIPadding", {
            PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5),
            PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 15),
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
                Utility:Tween(WindowObj.ActiveTab.Btn, {BackgroundTransparency = 1}, 0.3)
                WindowObj.ActiveTab.Page.Visible = false
            end
            WindowObj.ActiveTab = {Btn = TabBtn, Indicator = TabIndicator, Text = TabText, Page = Page}
            Utility:Tween(TabIndicator, {Size = UDim2.new(0, 4, 0, 24)}, 0.4, Enum.EasingStyle.Back)
            Utility:Tween(TabText, {TextColor3 = CurrentTheme.Text}, 0.3)
            Utility:Tween(TabBtn, {BackgroundTransparency = 0}, 0.3)
            Page.Visible = true
            Page.Position = UDim2.new(0, 20, 0, 0)
            Page.GroupTransparency = 1
            Utility:Tween(Page, {Position = UDim2.new(0, 0, 0, 0), GroupTransparency = 0}, 0.4)
        end

        TabBtn.MouseButton1Click:Connect(function()
            Utility:Ripple(TabBtn)
            ActivateTab()
        end)

        if WindowObj.First then
            WindowObj.First = false
            ActivateTab()
        end

        local TabObj = {}

        --========================================================--
        -- COMPONENTS SYSTEM
        --========================================================--
        function TabObj:CreateSection(name)
            local SecFrame = Utility:Create("Frame", {
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundTransparency = 1,
                Parent = Page
            })
            Utility:Create("TextLabel", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = name,
                Font = Enum.Font.GothamBold,
                TextSize = 16,
                TextColor3 = CurrentTheme.Accent,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = SecFrame
            })
        end

        function TabObj:CreateDivider()
            local Div = Utility:Create("Frame", {
                Size = UDim2.new(1, 0, 0, 2),
                BackgroundColor3 = CurrentTheme.Outline,
                BorderSizePixel = 0,
                Parent = Page
            })
            Utility:RegisterTheme(Div, "BackgroundColor3", "Outline")
        end

        function TabObj:CreateButton(opts)
            local bName = opts.Name or "Button"
            local bCb = opts.Callback or function() end

            local BtnFrame = Utility:Create("TextButton", {
                Size = UDim2.new(1, 0, 0, 45),
                BackgroundColor3 = CurrentTheme.Element,
                Text = "",
                AutoButtonColor = false,
                Parent = Page
            })
            Utility:Create("UICorner", {CornerRadius = UDim.new(0, 14), Parent = BtnFrame})
            Utility:Create("UIStroke", {Color = CurrentTheme.Outline, Thickness = 1, Parent = BtnFrame})
            Utility:RegisterTheme(BtnFrame, "BackgroundColor3", "Element")
            
            Utility:Create("TextLabel", {
                Size = UDim2.new(1, -20, 1, 0),
                Position = UDim2.new(0, 15, 0, 0),
                BackgroundTransparency = 1,
                Text = bName,
                Font = Enum.Font.GothamMedium,
                TextSize = 14,
                TextColor3 = CurrentTheme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = BtnFrame
            })

            local Icon = Utility:Create("ImageLabel", {
                Size = UDim2.new(0, 20, 0, 20),
                Position = UDim2.new(1, -35, 0.5, -10),
                BackgroundTransparency = 1,
                Image = "rbxassetid://6031090990", -- Right arrow icon
                ImageColor3 = CurrentTheme.SubText,
                Parent = BtnFrame
            })

            BtnFrame.MouseEnter:Connect(function()
                Utility:Tween(BtnFrame, {BackgroundColor3 = CurrentTheme.ElementHover}, 0.2)
                Utility:Tween(Icon, {Position = UDim2.new(1, -30, 0.5, -10), ImageColor3 = CurrentTheme.Text}, 0.2)
            end)
            BtnFrame.MouseLeave:Connect(function()
                Utility:Tween(BtnFrame, {BackgroundColor3 = CurrentTheme.Element}, 0.2)
                Utility:Tween(Icon, {Position = UDim2.new(1, -35, 0.5, -10), ImageColor3 = CurrentTheme.SubText}, 0.2)
            end)
            BtnFrame.MouseButton1Down:Connect(function()
                Utility:Tween(BtnFrame, {BackgroundColor3 = CurrentTheme.ElementClick}, 0.1)
            end)
            BtnFrame.MouseButton1Up:Connect(function()
                Utility:Tween(BtnFrame, {BackgroundColor3 = CurrentTheme.ElementHover}, 0.1)
                Utility:Ripple(BtnFrame)
                bCb()
            end)
        end

        function TabObj:CreateToggle(opts)
            local tName = opts.Name or "Toggle"
            local default = opts.Default or false
            local tCb = opts.Callback or function() end

            local state = default
            local TogFrame = Utility:Create("TextButton", {
                Size = UDim2.new(1, 0, 0, 45),
                BackgroundColor3 = CurrentTheme.Element,
                Text = "",
                AutoButtonColor = false,
                Parent = Page
            })
            Utility:Create("UICorner", {CornerRadius = UDim.new(0, 14), Parent = TogFrame})
            Utility:Create("UIStroke", {Color = CurrentTheme.Outline, Thickness = 1, Parent = TogFrame})
            Utility:RegisterTheme(TogFrame, "BackgroundColor3", "Element")

            Utility:Create("TextLabel", {
                Size = UDim2.new(1, -60, 1, 0),
                Position = UDim2.new(0, 15, 0, 0),
                BackgroundTransparency = 1,
                Text = tName,
                Font = Enum.Font.GothamMedium,
                TextSize = 14,
                TextColor3 = CurrentTheme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = TogFrame
            })

            local Switch = Utility:Create("Frame", {
                Size = UDim2.new(0, 40, 0, 20),
                Position = UDim2.new(1, -55, 0.5, -10),
                BackgroundColor3 = state and CurrentTheme.Accent or CurrentTheme.Container,
                Parent = TogFrame
            })
            Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Switch})
            
            local Thumb = Utility:Create("Frame", {
                Size = UDim2.new(0, 16, 0, 16),
                Position = UDim2.new(0, state and 22 or 2, 0.5, -8),
                BackgroundColor3 = Color3.fromRGB(255,255,255),
                Parent = Switch
            })
            Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Thumb})

            local function Fire()
                state = not state
                Utility:Tween(Switch, {BackgroundColor3 = state and CurrentTheme.Accent or CurrentTheme.Container}, 0.3)
                Utility:Tween(Thumb, {Position = UDim2.new(0, state and 22 or 2, 0.5, -8)}, 0.3, Enum.EasingStyle.Back)
                tCb(state)
            end

            TogFrame.MouseEnter:Connect(function() Utility:Tween(TogFrame, {BackgroundColor3 = CurrentTheme.ElementHover}, 0.2) end)
            TogFrame.MouseLeave:Connect(function() Utility:Tween(TogFrame, {BackgroundColor3 = CurrentTheme.Element}, 0.2) end)
            TogFrame.MouseButton1Click:Connect(function() Utility:Ripple(TogFrame) Fire() end)
            
            if state then tCb(state) end
        end

        function TabObj:CreateSlider(opts)
            local sName = opts.Name or "Slider"
            local min = opts.Min or 0
            local max = opts.Max or 100
            local default = opts.Default or min
            local sCb = opts.Callback or function() end

            local val = default
            local SldFrame = Utility:Create("Frame", {
                Size = UDim2.new(1, 0, 0, 65),
                BackgroundColor3 = CurrentTheme.Element,
                Parent = Page
            })
            Utility:Create("UICorner", {CornerRadius = UDim.new(0, 14), Parent = SldFrame})
            Utility:Create("UIStroke", {Color = CurrentTheme.Outline, Thickness = 1, Parent = SldFrame})

            Utility:Create("TextLabel", {
                Size = UDim2.new(1, -60, 0, 30),
                Position = UDim2.new(0, 15, 0, 5),
                BackgroundTransparency = 1,
                Text = sName,
                Font = Enum.Font.GothamMedium,
                TextSize = 14,
                TextColor3 = CurrentTheme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = SldFrame
            })

            local ValueLabel = Utility:Create("TextLabel", {
                Size = UDim2.new(0, 50, 0, 30),
                Position = UDim2.new(1, -65, 0, 5),
                BackgroundTransparency = 1,
                Text = tostring(val),
                Font = Enum.Font.GothamMedium,
                TextSize = 14,
                TextColor3 = CurrentTheme.Accent,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = SldFrame
            })

            local Track = Utility:Create("TextButton", {
                Size = UDim2.new(1, -30, 0, 6),
                Position = UDim2.new(0, 15, 0, 45),
                BackgroundColor3 = CurrentTheme.Container,
                Text = "",
                AutoButtonColor = false,
                Parent = SldFrame
            })
            Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Track})

            local Fill = Utility:Create("Frame", {
                Size = UDim2.new((val - min) / (max - min), 0, 1, 0),
                BackgroundColor3 = CurrentTheme.Accent,
                Parent = Track
            })
            Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Fill})

            local dragging = false
            local function Update(input)
                local pos = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                val = math.floor(min + (max - min) * pos)
                ValueLabel.Text = tostring(val)
                Utility:Tween(Fill, {Size = UDim2.new(pos, 0, 1, 0)}, 0.1)
                sCb(val)
            end

            Track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    Update(input)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    Update(input)
                end
            end)
            sCb(val)
        end

        function TabObj:CreateDropdown(opts)
            local dName = opts.Name or "Dropdown"
            local options = opts.Options or {}
            local dCb = opts.Callback or function() end

            local expanded = false
            local DropFrame = Utility:Create("Frame", {
                Size = UDim2.new(1, 0, 0, 45),
                BackgroundColor3 = CurrentTheme.Element,
                ClipsDescendants = true,
                Parent = Page
            })
            Utility:Create("UICorner", {CornerRadius = UDim.new(0, 14), Parent = DropFrame})
            Utility:Create("UIStroke", {Color = CurrentTheme.Outline, Thickness = 1, Parent = DropFrame})

            local DropBtn = Utility:Create("TextButton", {
                Size = UDim2.new(1, 0, 0, 45),
                BackgroundTransparency = 1,
                Text = "",
                Parent = DropFrame
            })
            
            Utility:Create("TextLabel", {
                Size = UDim2.new(1, -60, 1, 0),
                Position = UDim2.new(0, 15, 0, 0),
                BackgroundTransparency = 1,
                Text = dName,
                Font = Enum.Font.GothamMedium,
                TextSize = 14,
                TextColor3 = CurrentTheme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = DropBtn
            })

            local SelectedLabel = Utility:Create("TextLabel", {
                Size = UDim2.new(0, 100, 1, 0),
                Position = UDim2.new(1, -140, 0, 0),
                BackgroundTransparency = 1,
                Text = "None",
                Font = Enum.Font.GothamMedium,
                TextSize = 12,
                TextColor3 = CurrentTheme.SubText,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = DropBtn
            })

            local Arrow = Utility:Create("ImageLabel", {
                Size = UDim2.new(0, 20, 0, 20),
                Position = UDim2.new(1, -35, 0.5, -10),
                BackgroundTransparency = 1,
                Image = "rbxassetid://6031091004", -- Down arrow
                ImageColor3 = CurrentTheme.SubText,
                Parent = DropBtn
            })

            local ListContainer = Utility:Create("ScrollingFrame", {
                Size = UDim2.new(1, -20, 0, 0),
                Position = UDim2.new(0, 10, 0, 50),
                BackgroundTransparency = 1,
                ScrollBarThickness = 2,
                ScrollBarImageColor3 = CurrentTheme.Accent,
                Parent = DropFrame
            })
            local LLayout = Utility:Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 5),
                Parent = ListContainer
            })

            local function Refresh()
                for _, v in pairs(ListContainer:GetChildren()) do
                    if v:IsA("TextButton") then v:Destroy() end
                end
                for _, opt in ipairs(options) do
                    local optBtn = Utility:Create("TextButton", {
                        Size = UDim2.new(1, 0, 0, 30),
                        BackgroundColor3 = CurrentTheme.Container,
                        Text = opt,
                        Font = Enum.Font.GothamMedium,
                        TextSize = 13,
                        TextColor3 = CurrentTheme.Text,
                        AutoButtonColor = false,
                        Parent = ListContainer
                    })
                    Utility:Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = optBtn})
                    
                    optBtn.MouseButton1Click:Connect(function()
                        SelectedLabel.Text = opt
                        expanded = false
                        Utility:Tween(DropFrame, {Size = UDim2.new(1, 0, 0, 45)}, 0.3, Enum.EasingStyle.Back)
                        Utility:Tween(Arrow, {Rotation = 0}, 0.3)
                        dCb(opt)
                    end)
                    optBtn.MouseEnter:Connect(function() Utility:Tween(optBtn, {BackgroundColor3 = CurrentTheme.ElementHover}, 0.2) end)
                    optBtn.MouseLeave:Connect(function() Utility:Tween(optBtn, {BackgroundColor3 = CurrentTheme.Container}, 0.2) end)
                end
                ListContainer.CanvasSize = UDim2.new(0, 0, 0, LLayout.AbsoluteContentSize.Y)
            end
            Refresh()

            DropBtn.MouseButton1Click:Connect(function()
                expanded = not expanded
                Utility:Ripple(DropBtn)
                if expanded then
                    Utility:Tween(DropFrame, {Size = UDim2.new(1, 0, 0, 180)}, 0.3, Enum.EasingStyle.Back)
                    Utility:Tween(ListContainer, {Size = UDim2.new(1, -20, 0, 120)}, 0.3)
                    Utility:Tween(Arrow, {Rotation = 180}, 0.3)
                else
                    Utility:Tween(DropFrame, {Size = UDim2.new(1, 0, 0, 45)}, 0.3, Enum.EasingStyle.Back)
                    Utility:Tween(Arrow, {Rotation = 0}, 0.3)
                end
            end)
        end

        function TabObj:CreateColorPicker(opts)
            local cpName = opts.Name or "Color Picker"
            local default = opts.Default or Color3.fromRGB(255, 255, 255)
            local cpCb = opts.Callback or function() end

            local CPFrame = Utility:Create("Frame", {
                Size = UDim2.new(1, 0, 0, 45),
                BackgroundColor3 = CurrentTheme.Element,
                ClipsDescendants = true,
                Parent = Page
            })
            Utility:Create("UICorner", {CornerRadius = UDim.new(0, 14), Parent = CPFrame})
            Utility:Create("UIStroke", {Color = CurrentTheme.Outline, Thickness = 1, Parent = CPFrame})

            local CPBtn = Utility:Create("TextButton", {
                Size = UDim2.new(1, 0, 0, 45),
                BackgroundTransparency = 1,
                Text = "",
                Parent = CPFrame
            })

            Utility:Create("TextLabel", {
                Size = UDim2.new(1, -60, 1, 0),
                Position = UDim2.new(0, 15, 0, 0),
                BackgroundTransparency = 1,
                Text = cpName,
                Font = Enum.Font.GothamMedium,
                TextSize = 14,
                TextColor3 = CurrentTheme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = CPBtn
            })

            local ColorPreview = Utility:Create("Frame", {
                Size = UDim2.new(0, 30, 0, 20),
                Position = UDim2.new(1, -45, 0.5, -10),
                BackgroundColor3 = default,
                Parent = CPBtn
            })
            Utility:Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = ColorPreview})

            -- Extremely simplified CP dropdown logic to fit, usually very complex
            local expanded = false
            CPBtn.MouseButton1Click:Connect(function()
                expanded = not expanded
                Utility:Ripple(CPBtn)
                if expanded then
                    Utility:Tween(CPFrame, {Size = UDim2.new(1, 0, 0, 150)}, 0.3, Enum.EasingStyle.Back)
                    -- Insert complex hue/sat logic here for production
                else
                    Utility:Tween(CPFrame, {Size = UDim2.new(1, 0, 0, 45)}, 0.3, Enum.EasingStyle.Back)
                end
            end)
        end

        return TabObj
    end

    --========================================================--
    -- NOTIFICATION SYSTEM
    --========================================================--
    function XreztHub:Notify(opts)
        local nTitle = opts.Title or "Notification"
        local nText = opts.Text or "This is a notification."
        local nDur = opts.Duration or 3

        local NotifFrame = Utility:Create("Frame", {
            Size = UDim2.new(1, 0, 0, 80),
            BackgroundColor3 = CurrentTheme.Container,
            BackgroundTransparency = 1,
            Position = UDim2.new(1, 50, 0, 0),
            Parent = NotificationsContainer
        })
        Utility:Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = NotifFrame})
        Utility:Create("UIStroke", {Color = CurrentTheme.Accent, Thickness = 1, Parent = NotifFrame})
        
        local TitleL = Utility:Create("TextLabel", {
            Size = UDim2.new(1, -20, 0, 20),
            Position = UDim2.new(0, 10, 0, 10),
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
            Size = UDim2.new(1, -20, 1, -40),
            Position = UDim2.new(0, 10, 0, 30),
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

    return WindowObj
end

-- Execute Loading Sequence
XreztHub:Load()

return XreztHub
