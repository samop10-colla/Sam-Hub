--[[
    XREZT HUB - PREMIUM ROBLOX UI LIBRARY FRAMEWORK
    Version: 1.0.0
    Description: A highly optimized, responsive, and animated glassmorphism UI framework.
    Architect: Senior UI/UX Engineer
    
    Features:
    - 10 Built-in Themes with Smooth Transitions
    - Advanced Motion Loading Screen
    - Floating Window Design with Custom Draggable Spawner
    - Full Component Suite (Sliders, Color Pickers, Dropdowns, etc.)
    - PC, Mobile, and Tablet friendly
]]

local XreztHub = {
    Version = "1.0.0",
    ThemeRegistry = {},
    CurrentTheme = "Midnight Slate",
    Connections = {},
    Flags = {},
    Windows = 0,
    HoverWait = 0.05
}

--=========================================--
-- SERVICES & CONSTANTS
--=========================================--

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Protection/Parenting Logic
local UIContainer = nil
if gethui then
    UIContainer = gethui()
else
    local success, _ = pcall(function() return CoreGui.Name end)
    if success then
        UIContainer = CoreGui
    else
        UIContainer = LocalPlayer:WaitForChild("PlayerGui")
    end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "XreztHub_Framework"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = UIContainer

--=========================================--
-- THEME ENGINE
--=========================================--

XreztHub.Themes = {
    ["Midnight Slate"] = {
        Background = Color3.fromRGB(15, 17, 23),
        Secondary = Color3.fromRGB(22, 25, 33),
        Tertiary = Color3.fromRGB(30, 34, 45),
        Accent = Color3.fromRGB(99, 102, 241),
        Text = Color3.fromRGB(240, 240, 245),
        SubText = Color3.fromRGB(150, 155, 170),
        Outline = Color3.fromRGB(45, 50, 65),
        Success = Color3.fromRGB(46, 204, 113),
        Warning = Color3.fromRGB(241, 196, 15),
        Error = Color3.fromRGB(231, 76, 60)
    },
    ["Ocean Blue"] = {
        Background = Color3.fromRGB(10, 20, 35),
        Secondary = Color3.fromRGB(15, 30, 50),
        Tertiary = Color3.fromRGB(25, 45, 70),
        Accent = Color3.fromRGB(0, 168, 255),
        Text = Color3.fromRGB(230, 240, 255),
        SubText = Color3.fromRGB(130, 160, 200),
        Outline = Color3.fromRGB(35, 60, 95),
        Success = Color3.fromRGB(46, 204, 113),
        Warning = Color3.fromRGB(241, 196, 15),
        Error = Color3.fromRGB(231, 76, 60)
    },
    ["Aurora"] = {
        Background = Color3.fromRGB(15, 25, 20),
        Secondary = Color3.fromRGB(20, 35, 30),
        Tertiary = Color3.fromRGB(30, 50, 45),
        Accent = Color3.fromRGB(0, 210, 150),
        Text = Color3.fromRGB(230, 255, 240),
        SubText = Color3.fromRGB(140, 180, 160),
        Outline = Color3.fromRGB(45, 75, 65),
        Success = Color3.fromRGB(46, 204, 113),
        Warning = Color3.fromRGB(241, 196, 15),
        Error = Color3.fromRGB(231, 76, 60)
    },
    ["Sunset"] = {
        Background = Color3.fromRGB(30, 15, 20),
        Secondary = Color3.fromRGB(45, 20, 25),
        Tertiary = Color3.fromRGB(60, 30, 35),
        Accent = Color3.fromRGB(255, 107, 107),
        Text = Color3.fromRGB(255, 235, 235),
        SubText = Color3.fromRGB(200, 140, 140),
        Outline = Color3.fromRGB(85, 45, 50),
        Success = Color3.fromRGB(46, 204, 113),
        Warning = Color3.fromRGB(241, 196, 15),
        Error = Color3.fromRGB(231, 76, 60)
    },
    ["Emerald"] = {
        Background = Color3.fromRGB(10, 25, 15),
        Secondary = Color3.fromRGB(15, 35, 20),
        Tertiary = Color3.fromRGB(25, 50, 35),
        Accent = Color3.fromRGB(46, 204, 113),
        Text = Color3.fromRGB(235, 255, 240),
        SubText = Color3.fromRGB(140, 190, 150),
        Outline = Color3.fromRGB(40, 75, 50),
        Success = Color3.fromRGB(46, 204, 113),
        Warning = Color3.fromRGB(241, 196, 15),
        Error = Color3.fromRGB(231, 76, 60)
    },
    ["Rose"] = {
        Background = Color3.fromRGB(30, 15, 25),
        Secondary = Color3.fromRGB(45, 20, 35),
        Tertiary = Color3.fromRGB(60, 30, 50),
        Accent = Color3.fromRGB(253, 121, 168),
        Text = Color3.fromRGB(255, 230, 245),
        SubText = Color3.fromRGB(200, 140, 175),
        Outline = Color3.fromRGB(85, 45, 70),
        Success = Color3.fromRGB(46, 204, 113),
        Warning = Color3.fromRGB(241, 196, 15),
        Error = Color3.fromRGB(231, 76, 60)
    },
    ["Graphite"] = {
        Background = Color3.fromRGB(25, 25, 25),
        Secondary = Color3.fromRGB(35, 35, 35),
        Tertiary = Color3.fromRGB(45, 45, 45),
        Accent = Color3.fromRGB(180, 180, 180),
        Text = Color3.fromRGB(245, 245, 245),
        SubText = Color3.fromRGB(160, 160, 160),
        Outline = Color3.fromRGB(65, 65, 65),
        Success = Color3.fromRGB(46, 204, 113),
        Warning = Color3.fromRGB(241, 196, 15),
        Error = Color3.fromRGB(231, 76, 60)
    },
    ["Obsidian"] = {
        Background = Color3.fromRGB(5, 5, 5),
        Secondary = Color3.fromRGB(12, 12, 12),
        Tertiary = Color3.fromRGB(20, 20, 20),
        Accent = Color3.fromRGB(255, 255, 255),
        Text = Color3.fromRGB(220, 220, 220),
        SubText = Color3.fromRGB(120, 120, 120),
        Outline = Color3.fromRGB(35, 35, 35),
        Success = Color3.fromRGB(46, 204, 113),
        Warning = Color3.fromRGB(241, 196, 15),
        Error = Color3.fromRGB(231, 76, 60)
    },
    ["Crystal"] = {
        Background = Color3.fromRGB(245, 245, 250),
        Secondary = Color3.fromRGB(255, 255, 255),
        Tertiary = Color3.fromRGB(230, 230, 240),
        Accent = Color3.fromRGB(108, 92, 231),
        Text = Color3.fromRGB(30, 30, 40),
        SubText = Color3.fromRGB(100, 100, 120),
        Outline = Color3.fromRGB(210, 210, 225),
        Success = Color3.fromRGB(39, 174, 96),
        Warning = Color3.fromRGB(243, 156, 18),
        Error = Color3.fromRGB(192, 57, 43)
    },
    ["Frost"] = {
        Background = Color3.fromRGB(235, 245, 255),
        Secondary = Color3.fromRGB(250, 252, 255),
        Tertiary = Color3.fromRGB(220, 235, 250),
        Accent = Color3.fromRGB(116, 185, 255),
        Text = Color3.fromRGB(25, 45, 65),
        SubText = Color3.fromRGB(90, 120, 150),
        Outline = Color3.fromRGB(190, 215, 240),
        Success = Color3.fromRGB(39, 174, 96),
        Warning = Color3.fromRGB(243, 156, 18),
        Error = Color3.fromRGB(192, 57, 43)
    }
}

--=========================================--
-- UTILITY FUNCTIONS
--=========================================--

local Utility = {}

function Utility:Create(className, properties, children)
    local inst = Instance.new(className)
    for i, v in pairs(properties or {}) do
        if type(i) == "string" then
            inst[i] = v
        end
    end
    for _, child in pairs(children or {}) do
        child.Parent = inst
    end
    return inst
end

function Utility:Tween(instance, properties, duration, style, direction)
    local tInfo = TweenService:Create(
        instance,
        TweenInfo.new(
            duration or 0.25,
            style or Enum.EasingStyle.Quint,
            direction or Enum.EasingDirection.Out
        ),
        properties
    )
    tInfo:Play()
    return tInfo
end

function Utility:MakeDraggable(topbar, window)
    local dragging = false
    local dragInput, mousePos, framePos

    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            mousePos = input.Position
            framePos = window.Position
            
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
            local delta = input.Position - mousePos
            Utility:Tween(window, {
                Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
            }, 0.1)
        end
    end)
end

function Utility:RegisterTheme(instance, property, colorKey)
    if not XreztHub.ThemeRegistry[instance] then
        XreztHub.ThemeRegistry[instance] = {}
    end
    XreztHub.ThemeRegistry[instance][property] = colorKey
    
    -- Apply immediately
    instance[property] = XreztHub.Themes[XreztHub.CurrentTheme][colorKey]
end

function XreztHub:SetTheme(themeName)
    if not self.Themes[themeName] then return end
    self.CurrentTheme = themeName
    
    for instance, properties in pairs(self.ThemeRegistry) do
        if instance.Parent then
            local tweenProps = {}
            for prop, key in pairs(properties) do
                tweenProps[prop] = self.Themes[themeName][key]
            end
            Utility:Tween(instance, tweenProps, 0.4, Enum.EasingStyle.Quart)
        else
            self.ThemeRegistry[instance] = nil
        end
    end
end

--=========================================--
-- ADVANCED LOADING SCREEN
--=========================================--

function XreztHub:LoadXrezt(config)
    config = config or {}
    local TitleText = config.Title or "XREZT HUB"
    local SubText = config.SubText or "PREMIUM UI FRAMEWORK"
    
    local LoadingContainer = Utility:Create("Frame", {
        Name = "LoadingScreen",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = self.Themes[self.CurrentTheme].Background,
        ZIndex = 9999,
        Parent = ScreenGui,
        BackgroundTransparency = 0
    })

    Utility:RegisterTheme(LoadingContainer, "BackgroundColor3", "Background")

    -- Background Particle System (Motion Graphics)
    local ParticlesContainer = Utility:Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Parent = LoadingContainer,
        ZIndex = 10000
    })

    -- Spawn floating soft shapes
    task.spawn(function()
        for i = 1, 15 do
            local particle = Utility:Create("Frame", {
                Size = UDim2.new(0, math.random(20, 100), 0, math.random(20, 100)),
                Position = UDim2.new(math.random(), 0, math.random(), 0),
                BackgroundColor3 = self.Themes[self.CurrentTheme].Accent,
                BackgroundTransparency = math.random(7, 9) / 10,
                Rotation = math.random(0, 360),
                ZIndex = 10000,
                Parent = ParticlesContainer
            }, {
                Utility:Create("UICorner", { CornerRadius = UDim.new(0.5, 0) })
            })
            
            Utility:RegisterTheme(particle, "BackgroundColor3", "Accent")

            local function float()
                local t = Utility:Tween(particle, {
                    Position = UDim2.new(math.random(), 0, math.random(), 0),
                    Rotation = math.random(0, 360)
                }, math.random(10, 20), Enum.EasingStyle.Linear)
                t.Completed:Connect(float)
            end
            float()
        end
    end)

    -- Center Logo Container
    local LogoCenter = Utility:Create("Frame", {
        Size = UDim2.new(0, 200, 0, 200),
        Position = UDim2.new(0.5, 0, 0.45, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        ZIndex = 10001,
        Parent = LoadingContainer
    })

    -- The "X" Shape (Premium Gradient)
    local XContainer = Utility:Create("Frame", {
        Size = UDim2.new(0, 120, 0, 120),
        Position = UDim2.new(0.5, 0, 0.4, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        ZIndex = 10002,
        Parent = LogoCenter
    })

    local function createXBar(rot)
        local bar = Utility:Create("Frame", {
            Size = UDim2.new(0, 15, 1, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Color3.new(1, 1, 1),
            Rotation = rot,
            BackgroundTransparency = 1,
            Parent = XContainer
        }, {
            Utility:Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
            Utility:Create("UIGradient", {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, self.Themes[self.CurrentTheme].Accent),
                    ColorSequenceKeypoint.new(1, self.Themes[self.CurrentTheme].Secondary)
                }),
                Rotation = 90
            })
        })
        Utility:RegisterTheme(bar.UIGradient, "Color", "Accent") -- Simplified theme registering for gradient
        return bar
    end

    local X1 = createXBar(45)
    local X2 = createXBar(-45)

    -- Titles
    local MainTitle = Utility:Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 40),
        Position = UDim2.new(0.5, 0, 0.85, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Text = TitleText,
        TextColor3 = self.Themes[self.CurrentTheme].Text,
        Font = Enum.Font.GothamBold,
        TextSize = 28,
        TextTransparency = 1,
        ZIndex = 10002,
        Parent = LogoCenter
    })
    Utility:RegisterTheme(MainTitle, "TextColor3", "Text")

    local SubTitle = Utility:Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0.5, 0, 1, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Text = "INITIALIZING FRAMEWORK...",
        TextColor3 = self.Themes[self.CurrentTheme].SubText,
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        TextTransparency = 1,
        ZIndex = 10002,
        Parent = LogoCenter
    })
    Utility:RegisterTheme(SubTitle, "TextColor3", "SubText")

    -- Progress Bar
    local ProgressBack = Utility:Create("Frame", {
        Size = UDim2.new(0, 300, 0, 4),
        Position = UDim2.new(0.5, 0, 0.65, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = self.Themes[self.CurrentTheme].Tertiary,
        BackgroundTransparency = 1,
        ZIndex = 10002,
        Parent = LoadingContainer
    }, {
        Utility:Create("UICorner", { CornerRadius = UDim.new(1, 0) })
    })
    Utility:RegisterTheme(ProgressBack, "BackgroundColor3", "Tertiary")

    local ProgressFill = Utility:Create("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = self.Themes[self.CurrentTheme].Accent,
        ZIndex = 10003,
        Parent = ProgressBack
    }, {
        Utility:Create("UICorner", { CornerRadius = UDim.new(1, 0) })
    })
    Utility:RegisterTheme(ProgressFill, "BackgroundColor3", "Accent")
    
    local PercentText = Utility:Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0.5, 0, 1.5, 0),
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundTransparency = 1,
        Text = "0%",
        TextColor3 = self.Themes[self.CurrentTheme].Accent,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextTransparency = 1,
        ZIndex = 10003,
        Parent = ProgressBack
    })
    Utility:RegisterTheme(PercentText, "TextColor3", "Accent")

    -- Sequence Animations
    task.wait(0.5)
    
    -- 1. Logo Appear
    Utility:Tween(X1, {BackgroundTransparency = 0}, 0.8, Enum.EasingStyle.Quint)
    Utility:Tween(X2, {BackgroundTransparency = 0}, 0.8, Enum.EasingStyle.Quint)
    
    -- X Animation Loop
    local runConnection
    runConnection = RunService.RenderStepped:Connect(function()
        XContainer.Rotation = XContainer.Rotation + 0.5
    end)

    task.wait(0.5)
    
    -- 2. Text Appear
    Utility:Tween(MainTitle, {TextTransparency = 0}, 0.6)
    Utility:Tween(SubTitle, {TextTransparency = 0}, 0.6)
    Utility:Tween(ProgressBack, {BackgroundTransparency = 0}, 0.6)
    Utility:Tween(PercentText, {TextTransparency = 0}, 0.6)

    task.wait(0.5)

    -- 3. Progress Simulation
    local stages = {
        {progress = 0.2, text = "LOADING ASSETS...", wait = 0.4},
        {progress = 0.45, text = "BUILDING UI...", wait = 0.6},
        {progress = 0.7, text = "CACHING THEMES...", wait = 0.3},
        {progress = 0.9, text = "FINALIZING...", wait = 0.5},
        {progress = 1, text = "READY", wait = 0.2}
    }

    for _, stage in ipairs(stages) do
        Utility:Tween(ProgressFill, {Size = UDim2.new(stage.progress, 0, 1, 0)}, stage.wait, Enum.EasingStyle.Quad)
        SubTitle.Text = stage.text
        
        local tweenVal = Instance.new("NumberValue")
        tweenVal.Value = tonumber(PercentText.Text:match("%d+"))
        local t = Utility:Tween(tweenVal, {Value = stage.progress * 100}, stage.wait)
        
        t.Changed:Connect(function()
            PercentText.Text = math.floor(tweenVal.Value) .. "%"
        end)
        
        task.wait(stage.wait)
    end

    task.wait(0.5)

    -- 4. Completion & Fade Out
    runConnection:Disconnect()
    Utility:Tween(XContainer, {Rotation = 360, Size = UDim2.new(0, 0, 0, 0)}, 0.6, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    Utility:Tween(MainTitle, {TextTransparency = 1, Position = UDim2.new(0.5, 0, 0.9, 0)}, 0.4)
    Utility:Tween(SubTitle, {TextTransparency = 1}, 0.3)
    Utility:Tween(ProgressBack, {BackgroundTransparency = 1}, 0.3)
    Utility:Tween(ProgressFill, {BackgroundTransparency = 1}, 0.3)
    Utility:Tween(PercentText, {TextTransparency = 1}, 0.3)

    task.wait(0.6)
    
    local endTween = Utility:Tween(LoadingContainer, {BackgroundTransparency = 1}, 0.8)
    for _, child in pairs(ParticlesContainer:GetChildren()) do
        Utility:Tween(child, {BackgroundTransparency = 1}, 0.5)
    end

    endTween.Completed:Wait()
    LoadingContainer:Destroy()
end

--=========================================--
-- NOTIFICATION SYSTEM
--=========================================--

local NotificationContainer = Utility:Create("Frame", {
    Name = "NotificationLayer",
    Size = UDim2.new(0, 320, 1, -40),
    Position = UDim2.new(1, -20, 0, 20),
    AnchorPoint = Vector2.new(1, 0),
    BackgroundTransparency = 1,
    ZIndex = 99999,
    Parent = ScreenGui
}, {
    Utility:Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10),
        VerticalAlignment = Enum.VerticalAlignment.Bottom
    })
})

function XreztHub:Notify(options)
    options = options or {}
    local title = options.Title or "Notification"
    local content = options.Content or "This is a notification."
    local duration = options.Duration or 5
    local typeStr = options.Type or "Info" -- Success, Error, Warning, Info

    local typeColor = self.Themes[self.CurrentTheme].Accent
    local typeKey = "Accent"
    
    if typeStr == "Success" then typeKey = "Success"
    elseif typeStr == "Error" then typeKey = "Error"
    elseif typeStr == "Warning" then typeKey = "Warning"
    end
    typeColor = self.Themes[self.CurrentTheme][typeKey]

    local NotifFrame = Utility:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 0), -- Starts collapsed
        BackgroundColor3 = self.Themes[self.CurrentTheme].Secondary,
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent = NotificationContainer
    }, {
        Utility:Create("UICorner", { CornerRadius = UDim.new(0, 14) }),
        Utility:Create("UIStroke", {
            Color = self.Themes[self.CurrentTheme].Outline,
            Thickness = 1,
            Transparency = 1
        })
    })

    Utility:RegisterTheme(NotifFrame, "BackgroundColor3", "Secondary")
    Utility:RegisterTheme(NotifFrame.UIStroke, "Color", "Outline")

    local ContentFrame = Utility:Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Parent = NotifFrame
    })

    local Indicator = Utility:Create("Frame", {
        Size = UDim2.new(0, 4, 1, -24),
        Position = UDim2.new(0, 12, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = typeColor,
        Parent = ContentFrame
    }, {
        Utility:Create("UICorner", { CornerRadius = UDim.new(1, 0) })
    })
    Utility:RegisterTheme(Indicator, "BackgroundColor3", typeKey)

    local TitleLabel = Utility:Create("TextLabel", {
        Size = UDim2.new(1, -40, 0, 20),
        Position = UDim2.new(0, 28, 0, 12),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = self.Themes[self.CurrentTheme].Text,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = ContentFrame
    })
    Utility:RegisterTheme(TitleLabel, "TextColor3", "Text")

    local DescLabel = Utility:Create("TextLabel", {
        Size = UDim2.new(1, -40, 0, 0),
        Position = UDim2.new(0, 28, 0, 32),
        BackgroundTransparency = 1,
        Text = content,
        TextColor3 = self.Themes[self.CurrentTheme].SubText,
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Parent = ContentFrame
    })
    Utility:RegisterTheme(DescLabel, "TextColor3", "SubText")

    -- Calculate Height
    local textBounds = TextService:GetTextSize(content, 12, Enum.Font.GothamMedium, Vector2.new(280, math.huge))
    local targetHeight = 44 + textBounds.Y
    DescLabel.Size = UDim2.new(1, -40, 0, textBounds.Y)

    -- Animations
    Utility:Tween(NotifFrame, {Size = UDim2.new(1, 0, 0, targetHeight), BackgroundTransparency = 0.1}, 0.4, Enum.EasingStyle.Back)
    Utility:Tween(NotifFrame.UIStroke, {Transparency = 0}, 0.4)

    task.delay(duration, function()
        if NotifFrame then
            local t = Utility:Tween(NotifFrame, {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In)
            Utility:Tween(NotifFrame.UIStroke, {Transparency = 1}, 0.4)
            Utility:Tween(TitleLabel, {TextTransparency = 1}, 0.3)
            Utility:Tween(DescLabel, {TextTransparency = 1}, 0.3)
            Utility:Tween(Indicator, {BackgroundTransparency = 1}, 0.3)
            
            t.Completed:Connect(function()
                NotifFrame:Destroy()
            end)
        end
    end)
end

--=========================================--
-- MAIN WINDOW SYSTEM
--=========================================--

function XreztHub:CreateWindow(options)
    options = options or {}
    local Title = options.Title or "Xrezt Hub"
    local SubTitle = options.SubTitle or "Premium Framework"
    local Size = options.Size or UDim2.new(0, 750, 0, 480)
    
    self.Windows = self.Windows + 1

    local WindowObj = {
        Tabs = {},
        CurrentTab = nil,
        IsMinimized = false
    }

    -- Main GUI Structures
    local MainShadow = Utility:Create("Frame", {
        Name = "MainShadow",
        Size = Size,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.new(0,0,0),
        BackgroundTransparency = 0.4,
        Parent = ScreenGui
    }, {
        Utility:Create("UICorner", { CornerRadius = UDim.new(0, 26) }) -- Matches window shadow
    })

    local MainWindow = Utility:Create("Frame", {
        Name = "MainWindow",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = self.Themes[self.CurrentTheme].Background,
        ClipsDescendants = true,
        Parent = MainShadow
    }, {
        Utility:Create("UICorner", { CornerRadius = UDim.new(0, 24) }),
        Utility:Create("UIStroke", {
            Color = self.Themes[self.CurrentTheme].Outline,
            Thickness = 1,
            Transparency = 0.5
        })
    })

    Utility:RegisterTheme(MainWindow, "BackgroundColor3", "Background")
    Utility:RegisterTheme(MainWindow.UIStroke, "Color", "Outline")

    -- Header
    local Header = Utility:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 60),
        BackgroundColor3 = self.Themes[self.CurrentTheme].Secondary,
        BackgroundTransparency = 0.3,
        Parent = MainWindow
    }, {
        Utility:Create("UICorner", { CornerRadius = UDim.new(0, 24) })
    })
    Utility:RegisterTheme(Header, "BackgroundColor3", "Secondary")
    Utility:MakeDraggable(Header, MainShadow)

    -- Fix header bottom corner rounding by adding a covering frame
    local HeaderBlock = Utility:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 1, -20),
        BackgroundColor3 = self.Themes[self.CurrentTheme].Secondary,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Parent = Header
    })
    Utility:RegisterTheme(HeaderBlock, "BackgroundColor3", "Secondary")

    local HeaderTitle = Utility:Create("TextLabel", {
        Size = UDim2.new(0, 200, 0, 24),
        Position = UDim2.new(0, 20, 0, 10),
        BackgroundTransparency = 1,
        Text = Title,
        TextColor3 = self.Themes[self.CurrentTheme].Text,
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Header
    })
    Utility:RegisterTheme(HeaderTitle, "TextColor3", "Text")

    local HeaderSubTitle = Utility:Create("TextLabel", {
        Size = UDim2.new(0, 200, 0, 16),
        Position = UDim2.new(0, 20, 0, 32),
        BackgroundTransparency = 1,
        Text = SubTitle,
        TextColor3 = self.Themes[self.CurrentTheme].SubText,
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Header
    })
    Utility:RegisterTheme(HeaderSubTitle, "TextColor3", "SubText")

    -- Navigation Container (Left Tabs)
    local NavContainer = Utility:Create("Frame", {
        Size = UDim2.new(0, 200, 1, -60),
        Position = UDim2.new(0, 0, 0, 60),
        BackgroundColor3 = self.Themes[self.CurrentTheme].Secondary,
        BackgroundTransparency = 0.8,
        Parent = MainWindow
    })
    Utility:RegisterTheme(NavContainer, "BackgroundColor3", "Secondary")

    local NavList = Utility:Create("ScrollingFrame", {
        Size = UDim2.new(1, -20, 1, -20),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundTransparency = 1,
        ScrollBarThickness = 2,
        BorderSizePixel = 0,
        Parent = NavContainer
    }, {
        Utility:Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 6)
        })
    })

    -- Content Container
    local ContentContainer = Utility:Create("Frame", {
        Size = UDim2.new(1, -200, 1, -60),
        Position = UDim2.new(0, 200, 0, 60),
        BackgroundTransparency = 1,
        Parent = MainWindow
    })

    -- Tab System
    function WindowObj:CreateTab(tabOptions)
        tabOptions = tabOptions or {}
        local TabName = tabOptions.Name or "Tab"
        local TabIcon = tabOptions.Icon or ""

        local TabObj = {
            Elements = {}
        }

        -- Tab Button
        local TabBtn = Utility:Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 40),
            BackgroundColor3 = XreztHub.Themes[XreztHub.CurrentTheme].Tertiary,
            BackgroundTransparency = 1,
            Text = "",
            AutoButtonColor = false,
            Parent = NavList
        }, {
            Utility:Create("UICorner", { CornerRadius = UDim.new(0, 12) })
        })
        Utility:RegisterTheme(TabBtn, "BackgroundColor3", "Tertiary")

        local Indicator = Utility:Create("Frame", {
            Size = UDim2.new(0, 3, 0, 0),
            Position = UDim2.new(0, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundColor3 = XreztHub.Themes[XreztHub.CurrentTheme].Accent,
            Parent = TabBtn
        }, {
            Utility:Create("UICorner", { CornerRadius = UDim.new(1, 0) })
        })
        Utility:RegisterTheme(Indicator, "BackgroundColor3", "Accent")

        local TabText = Utility:Create("TextLabel", {
            Size = UDim2.new(1, -40, 1, 0),
            Position = UDim2.new(0, 35, 0, 0),
            BackgroundTransparency = 1,
            Text = TabName,
            TextColor3 = XreztHub.Themes[XreztHub.CurrentTheme].SubText,
            Font = Enum.Font.GothamMedium,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = TabBtn
        })
        Utility:RegisterTheme(TabText, "TextColor3", "SubText")

        -- Content Page
        local Page = Utility:Create("ScrollingFrame", {
            Size = UDim2.new(1, -20, 1, -20),
            Position = UDim2.new(0, 10, 0, 10),
            BackgroundTransparency = 1,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = XreztHub.Themes[XreztHub.CurrentTheme].Outline,
            BorderSizePixel = 0,
            Visible = false,
            Parent = ContentContainer
        }, {
            Utility:Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 8)
            }),
            Utility:Create("UIPadding", {
                PaddingRight = UDim.new(0, 10)
            })
        })
        Utility:RegisterTheme(Page, "ScrollBarImageColor3", "Outline")

        -- Logic
        local function ActivateTab()
            if WindowObj.CurrentTab == TabObj then return end

            if WindowObj.CurrentTab then
                WindowObj.CurrentTab.Deactivate()
            end

            WindowObj.CurrentTab = TabObj
            Page.Visible = true
            
            Utility:Tween(TabBtn, {BackgroundTransparency = 0.5}, 0.3)
            Utility:Tween(Indicator, {Size = UDim2.new(0, 3, 0, 20)}, 0.3, Enum.EasingStyle.Back)
            Utility:Tween(TabText, {TextColor3 = XreztHub.Themes[XreztHub.CurrentTheme].Text}, 0.3)
            XreztHub.ThemeRegistry[TabText]["TextColor3"] = "Text"
            
            -- Page Entrance Animation
            for _, child in pairs(Page:GetChildren()) do
                if child:IsA("GuiObject") then
                    child.BackgroundTransparency = 1
                    Utility:Tween(child, {BackgroundTransparency = 0}, 0.4)
                end
            end
        end

        function TabObj.Deactivate()
            Page.Visible = false
            Utility:Tween(TabBtn, {BackgroundTransparency = 1}, 0.3)
            Utility:Tween(Indicator, {Size = UDim2.new(0, 3, 0, 0)}, 0.3)
            Utility:Tween(TabText, {TextColor3 = XreztHub.Themes[XreztHub.CurrentTheme].SubText}, 0.3)
            XreztHub.ThemeRegistry[TabText]["TextColor3"] = "SubText"
        end

        TabBtn.MouseButton1Click:Connect(ActivateTab)
        
        -- Hover
        TabBtn.MouseEnter:Connect(function()
            if WindowObj.CurrentTab ~= TabObj then
                Utility:Tween(TabBtn, {BackgroundTransparency = 0.8}, 0.2)
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if WindowObj.CurrentTab ~= TabObj then
                Utility:Tween(TabBtn, {BackgroundTransparency = 1}, 0.2)
            end
        end)

        -- Auto layout update
        Page.UIListLayout.GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, Page.UIListLayout.AbsoluteContentSize.Y + 20)
        end)

        -- Initial Tab Select
        if #WindowObj.Tabs == 0 then
            ActivateTab()
        end
        table.insert(WindowObj.Tabs, TabObj)

        --=========================================--
        -- COMPONENTS WITHIN TAB
        --=========================================--

        function TabObj:CreateButton(btnOpts)
            btnOpts = btnOpts or {}
            local BtnName = btnOpts.Name or "Button"
            local Callback = btnOpts.Callback or function() end

            local BtnFrame = Utility:Create("TextButton", {
                Size = UDim2.new(1, 0, 0, 44),
                BackgroundColor3 = XreztHub.Themes[XreztHub.CurrentTheme].Tertiary,
                Text = "",
                AutoButtonColor = false,
                Parent = Page
            }, {
                Utility:Create("UICorner", { CornerRadius = UDim.new(0, 14) }),
                Utility:Create("UIStroke", {
                    Color = XreztHub.Themes[XreztHub.CurrentTheme].Outline,
                    Thickness = 1,
                    Transparency = 0.5
                })
            })
            Utility:RegisterTheme(BtnFrame, "BackgroundColor3", "Tertiary")
            Utility:RegisterTheme(BtnFrame.UIStroke, "Color", "Outline")

            local Title = Utility:Create("TextLabel", {
                Size = UDim2.new(1, -30, 1, 0),
                Position = UDim2.new(0, 15, 0, 0),
                BackgroundTransparency = 1,
                Text = BtnName,
                TextColor3 = XreztHub.Themes[XreztHub.CurrentTheme].Text,
                Font = Enum.Font.GothamMedium,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = BtnFrame
            })
            Utility:RegisterTheme(Title, "TextColor3", "Text")

            local InteractIcon = Utility:Create("ImageLabel", {
                Size = UDim2.new(0, 20, 0, 20),
                Position = UDim2.new(1, -30, 0.5, -10),
                BackgroundTransparency = 1,
                Image = "rbxassetid://6026663699", -- Tap icon
                ImageColor3 = XreztHub.Themes[XreztHub.CurrentTheme].SubText,
                Parent = BtnFrame
            })
            Utility:RegisterTheme(InteractIcon, "ImageColor3", "SubText")

            -- Animations
            BtnFrame.MouseEnter:Connect(function()
                Utility:Tween(BtnFrame, {BackgroundColor3 = XreztHub.Themes[XreztHub.CurrentTheme].Secondary}, 0.2)
                Utility:Tween(InteractIcon, {Position = UDim2.new(1, -25, 0.5, -10)}, 0.2)
            end)
            
            BtnFrame.MouseLeave:Connect(function()
                Utility:Tween(BtnFrame, {BackgroundColor3 = XreztHub.Themes[XreztHub.CurrentTheme].Tertiary}, 0.2)
                Utility:Tween(InteractIcon, {Position = UDim2.new(1, -30, 0.5, -10)}, 0.2)
            end)

            BtnFrame.MouseButton1Down:Connect(function()
                Utility:Tween(BtnFrame, {Size = UDim2.new(1, -4, 0, 40), Position = UDim2.new(0, 2, 0, 2)}, 0.1)
            end)

            BtnFrame.MouseButton1Up:Connect(function()
                Utility:Tween(BtnFrame, {Size = UDim2.new(1, 0, 0, 44), Position = UDim2.new(0, 0, 0, 0)}, 0.1)
                Callback()
                
                -- Ripple effect simulation
                local ripple = Utility:Create("Frame", {
                    Size = UDim2.new(0, 0, 0, 0),
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    BackgroundColor3 = XreztHub.Themes[XreztHub.CurrentTheme].Accent,
                    BackgroundTransparency = 0.5,
                    Parent = BtnFrame
                }, {Utility:Create("UICorner", {CornerRadius = UDim.new(1,0)})})
                
                local t = Utility:Tween(ripple, {Size = UDim2.new(2, 0, 2, 0), BackgroundTransparency = 1}, 0.5)
                t.Completed:Connect(function() ripple:Destroy() end)
            end)
        end

        function TabObj:CreateToggle(tglOpts)
            tglOpts = tglOpts or {}
            local TglName = tglOpts.Name or "Toggle"
            local Default = tglOpts.Default or false
            local Callback = tglOpts.Callback or function() end
            local Flag = tglOpts.Flag or TglName

            XreztHub.Flags[Flag] = Default

            local TglFrame = Utility:Create("TextButton", {
                Size = UDim2.new(1, 0, 0, 44),
                BackgroundColor3 = XreztHub.Themes[XreztHub.CurrentTheme].Tertiary,
                Text = "",
                AutoButtonColor = false,
                Parent = Page
            }, {
                Utility:Create("UICorner", { CornerRadius = UDim.new(0, 14) }),
                Utility:Create("UIStroke", {
                    Color = XreztHub.Themes[XreztHub.CurrentTheme].Outline,
                    Thickness = 1,
                    Transparency = 0.5
                })
            })
            Utility:RegisterTheme(TglFrame, "BackgroundColor3", "Tertiary")
            Utility:RegisterTheme(TglFrame.UIStroke, "Color", "Outline")

            local Title = Utility:Create("TextLabel", {
                Size = UDim2.new(1, -80, 1, 0),
                Position = UDim2.new(0, 15, 0, 0),
                BackgroundTransparency = 1,
                Text = TglName,
                TextColor3 = XreztHub.Themes[XreztHub.CurrentTheme].Text,
                Font = Enum.Font.GothamMedium,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = TglFrame
            })
            Utility:RegisterTheme(Title, "TextColor3", "Text")

            local TglBack = Utility:Create("Frame", {
                Size = UDim2.new(0, 44, 0, 24),
                Position = UDim2.new(1, -15, 0.5, 0),
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundColor3 = Default and XreztHub.Themes[XreztHub.CurrentTheme].Accent or XreztHub.Themes[XreztHub.CurrentTheme].Secondary,
                Parent = TglFrame
            }, {
                Utility:Create("UICorner", { CornerRadius = UDim.new(1, 0) })
            })
            Utility:RegisterTheme(TglBack, "BackgroundColor3", Default and "Accent" or "Secondary")

            local TglThumb = Utility:Create("Frame", {
                Size = UDim2.new(0, 18, 0, 18),
                Position = Default and UDim2.new(1, -21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Parent = TglBack
            }, {
                Utility:Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
                Utility:Create("UIStroke", {Color = Color3.new(0,0,0), Transparency = 0.8, Thickness = 1})
            })

            local function Update(state)
                XreztHub.Flags[Flag] = state
                
                if state then
                    Utility:Tween(TglBack, {BackgroundColor3 = XreztHub.Themes[XreztHub.CurrentTheme].Accent}, 0.3)
                    Utility:Tween(TglThumb, {Position = UDim2.new(1, -21, 0.5, 0)}, 0.3, Enum.EasingStyle.Back)
                    XreztHub.ThemeRegistry[TglBack]["BackgroundColor3"] = "Accent"
                else
                    Utility:Tween(TglBack, {BackgroundColor3 = XreztHub.Themes[XreztHub.CurrentTheme].Secondary}, 0.3)
                    Utility:Tween(TglThumb, {Position = UDim2.new(0, 3, 0.5, 0)}, 0.3, Enum.EasingStyle.Back)
                    XreztHub.ThemeRegistry[TglBack]["BackgroundColor3"] = "Secondary"
                end
                
                Callback(state)
            end

            TglFrame.MouseButton1Click:Connect(function()
                Update(not XreztHub.Flags[Flag])
            end)
        end

        function TabObj:CreateSlider(sldOpts)
            sldOpts = sldOpts or {}
            local SldName = sldOpts.Name or "Slider"
            local Min = sldOpts.Min or 0
            local Max = sldOpts.Max or 100
            local Default = sldOpts.Default or Min
            local Callback = sldOpts.Callback or function() end
            local Flag = sldOpts.Flag or SldName

            XreztHub.Flags[Flag] = Default

            local SldFrame = Utility:Create("Frame", {
                Size = UDim2.new(1, 0, 0, 64),
                BackgroundColor3 = XreztHub.Themes[XreztHub.CurrentTheme].Tertiary,
                Parent = Page
            }, {
                Utility:Create("UICorner", { CornerRadius = UDim.new(0, 14) }),
                Utility:Create("UIStroke", {
                    Color = XreztHub.Themes[XreztHub.CurrentTheme].Outline,
                    Thickness = 1,
                    Transparency = 0.5
                })
            })
            Utility:RegisterTheme(SldFrame, "BackgroundColor3", "Tertiary")
            Utility:RegisterTheme(SldFrame.UIStroke, "Color", "Outline")

            local Title = Utility:Create("TextLabel", {
                Size = UDim2.new(1, -30, 0, 20),
                Position = UDim2.new(0, 15, 0, 10),
                BackgroundTransparency = 1,
                Text = SldName,
                TextColor3 = XreztHub.Themes[XreztHub.CurrentTheme].Text,
                Font = Enum.Font.GothamMedium,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = SldFrame
            })
            Utility:RegisterTheme(Title, "TextColor3", "Text")

            local ValueLabel = Utility:Create("TextLabel", {
                Size = UDim2.new(0, 50, 0, 20),
                Position = UDim2.new(1, -65, 0, 10),
                BackgroundTransparency = 1,
                Text = tostring(Default),
                TextColor3 = XreztHub.Themes[XreztHub.CurrentTheme].SubText,
                Font = Enum.Font.GothamMedium,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = SldFrame
            })
            Utility:RegisterTheme(ValueLabel, "TextColor3", "SubText")

            local SliderBack = Utility:Create("TextButton", {
                Size = UDim2.new(1, -30, 0, 8),
                Position = UDim2.new(0, 15, 0, 42),
                BackgroundColor3 = XreztHub.Themes[XreztHub.CurrentTheme].Secondary,
                Text = "",
                AutoButtonColor = false,
                Parent = SldFrame
            }, {
                Utility:Create("UICorner", { CornerRadius = UDim.new(1, 0) })
            })
            Utility:RegisterTheme(SliderBack, "BackgroundColor3", "Secondary")

            local FillRatio = math.clamp((Default - Min) / (Max - Min), 0, 1)
            
            local SliderFill = Utility:Create("Frame", {
                Size = UDim2.new(FillRatio, 0, 1, 0),
                BackgroundColor3 = XreztHub.Themes[XreztHub.CurrentTheme].Accent,
                Parent = SliderBack
            }, {
                Utility:Create("UICorner", { CornerRadius = UDim.new(1, 0) })
            })
            Utility:RegisterTheme(SliderFill, "BackgroundColor3", "Accent")

            local SliderThumb = Utility:Create("Frame", {
                Size = UDim2.new(0, 16, 0, 16),
                Position = UDim2.new(1, -8, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Parent = SliderFill
            }, {
                Utility:Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
                Utility:Create("UIStroke", {Color = Color3.new(0,0,0), Transparency = 0.8, Thickness = 1})
            })

            local Dragging = false
            local function UpdateSlider(input)
                local pos = math.clamp((input.Position.X - SliderBack.AbsolutePosition.X) / SliderBack.AbsoluteSize.X, 0, 1)
                local val = math.floor(Min + ((Max - Min) * pos))
                
                XreztHub.Flags[Flag] = val
                ValueLabel.Text = tostring(val)
                Utility:Tween(SliderFill, {Size = UDim2.new(pos, 0, 1, 0)}, 0.1)
                Callback(val)
            end

            SliderBack.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    Dragging = true
                    UpdateSlider(input)
                    Utility:Tween(SliderThumb, {Size = UDim2.new(0, 20, 0, 20)}, 0.2)
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    Dragging = false
                    Utility:Tween(SliderThumb, {Size = UDim2.new(0, 16, 0, 16)}, 0.2)
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    UpdateSlider(input)
                end
            end)
        end

        function TabObj:CreateDropdown(dropOpts)
            dropOpts = dropOpts or {}
            local DropName = dropOpts.Name or "Dropdown"
            local Options = dropOpts.Options or {}
            local Default = dropOpts.Default or Options[1]
            local Callback = dropOpts.Callback or function() end
            local Flag = dropOpts.Flag or DropName

            XreztHub.Flags[Flag] = Default

            local DropFrame = Utility:Create("Frame", {
                Size = UDim2.new(1, 0, 0, 44),
                BackgroundColor3 = XreztHub.Themes[XreztHub.CurrentTheme].Tertiary,
                ClipsDescendants = true,
                Parent = Page
            }, {
                Utility:Create("UICorner", { CornerRadius = UDim.new(0, 14) }),
                Utility:Create("UIStroke", {
                    Color = XreztHub.Themes[XreztHub.CurrentTheme].Outline,
                    Thickness = 1,
                    Transparency = 0.5
                })
            })
            Utility:RegisterTheme(DropFrame, "BackgroundColor3", "Tertiary")
            Utility:RegisterTheme(DropFrame.UIStroke, "Color", "Outline")

            local DropBtn = Utility:Create("TextButton", {
                Size = UDim2.new(1, 0, 0, 44),
                BackgroundTransparency = 1,
                Text = "",
                Parent = DropFrame
            })

            local Title = Utility:Create("TextLabel", {
                Size = UDim2.new(1, -30, 1, 0),
                Position = UDim2.new(0, 15, 0, 0),
                BackgroundTransparency = 1,
                Text = DropName .. " : " .. tostring(Default),
                TextColor3 = XreztHub.Themes[XreztHub.CurrentTheme].Text,
                Font = Enum.Font.GothamMedium,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = DropBtn
            })
            Utility:RegisterTheme(Title, "TextColor3", "Text")

            local Icon = Utility:Create("ImageLabel", {
                Size = UDim2.new(0, 20, 0, 20),
                Position = UDim2.new(1, -30, 0.5, -10),
                BackgroundTransparency = 1,
                Image = "rbxassetid://6026668589", -- chevron down
                ImageColor3 = XreztHub.Themes[XreztHub.CurrentTheme].SubText,
                Parent = DropBtn
            })
            Utility:RegisterTheme(Icon, "ImageColor3", "SubText")

            local ListContainer = Utility:Create("ScrollingFrame", {
                Size = UDim2.new(1, -20, 1, -50),
                Position = UDim2.new(0, 10, 0, 44),
                BackgroundTransparency = 1,
                ScrollBarThickness = 2,
                BorderSizePixel = 0,
                Parent = DropFrame
            }, {
                Utility:Create("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 4)
                })
            })

            local IsOpen = false

            local function RebuildList()
                for _, child in ipairs(ListContainer:GetChildren()) do
                    if child:IsA("TextButton") then child:Destroy() end
                end

                local itemHeight = 32
                for i, opt in ipairs(Options) do
                    local ItemBtn = Utility:Create("TextButton", {
                        Size = UDim2.new(1, 0, 0, itemHeight),
                        BackgroundColor3 = XreztHub.Themes[XreztHub.CurrentTheme].Secondary,
                        Text = "  " .. tostring(opt),
                        TextColor3 = XreztHub.Themes[XreztHub.CurrentTheme].SubText,
                        Font = Enum.Font.GothamMedium,
                        TextSize = 13,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        AutoButtonColor = false,
                        Parent = ListContainer
                    }, {
                        Utility:Create("UICorner", { CornerRadius = UDim.new(0, 8) })
                    })
                    Utility:RegisterTheme(ItemBtn, "BackgroundColor3", "Secondary")
                    Utility:RegisterTheme(ItemBtn, "TextColor3", "SubText")

                    ItemBtn.MouseEnter:Connect(function()
                        Utility:Tween(ItemBtn, {BackgroundColor3 = XreztHub.Themes[XreztHub.CurrentTheme].Accent, TextColor3 = Color3.new(1,1,1)}, 0.2)
                    end)
                    ItemBtn.MouseLeave:Connect(function()
                        Utility:Tween(ItemBtn, {BackgroundColor3 = XreztHub.Themes[XreztHub.CurrentTheme].Secondary, TextColor3 = XreztHub.Themes[XreztHub.CurrentTheme].SubText}, 0.2)
                        -- Re-register theme specific properties since hover interrupts
                        XreztHub.ThemeRegistry[ItemBtn]["BackgroundColor3"] = "Secondary"
                        XreztHub.ThemeRegistry[ItemBtn]["TextColor3"] = "SubText"
                    end)

                    ItemBtn.MouseButton1Click:Connect(function()
                        XreztHub.Flags[Flag] = opt
                        Title.Text = DropName .. " : " .. tostring(opt)
                        Callback(opt)
                        
                        -- Close dropdown
                        IsOpen = false
                        Utility:Tween(DropFrame, {Size = UDim2.new(1, 0, 0, 44)}, 0.4, Enum.EasingStyle.Quint)
                        Utility:Tween(Icon, {Rotation = 0}, 0.3)
                    end)
                end
                
                local totalHeight = 44 + (#Options * (itemHeight + 4)) + 10
                ListContainer.CanvasSize = UDim2.new(0, 0, 0, #Options * (itemHeight + 4))
                return math.clamp(totalHeight, 44, 200)
            end

            DropBtn.MouseButton1Click:Connect(function()
                IsOpen = not IsOpen
                if IsOpen then
                    local h = RebuildList()
                    Utility:Tween(DropFrame, {Size = UDim2.new(1, 0, 0, h)}, 0.4, Enum.EasingStyle.Quint)
                    Utility:Tween(Icon, {Rotation = 180}, 0.3)
                else
                    Utility:Tween(DropFrame, {Size = UDim2.new(1, 0, 0, 44)}, 0.4, Enum.EasingStyle.Quint)
                    Utility:Tween(Icon, {Rotation = 0}, 0.3)
                end
            end)
        end
        
        function TabObj:CreateColorPicker(colorOpts)
            colorOpts = colorOpts or {}
            local CpName = colorOpts.Name or "Color Picker"
            local Default = colorOpts.Default or Color3.fromRGB(255, 255, 255)
            local Callback = colorOpts.Callback or function() end
            local Flag = colorOpts.Flag or CpName
            
            XreztHub.Flags[Flag] = Default
            
            local ColorFrame = Utility:Create("Frame", {
                Size = UDim2.new(1, 0, 0, 44),
                BackgroundColor3 = XreztHub.Themes[XreztHub.CurrentTheme].Tertiary,
                ClipsDescendants = true,
                Parent = Page
            }, {
                Utility:Create("UICorner", { CornerRadius = UDim.new(0, 14) }),
                Utility:Create("UIStroke", {
                    Color = XreztHub.Themes[XreztHub.CurrentTheme].Outline,
                    Thickness = 1,
                    Transparency = 0.5
                })
            })
            Utility:RegisterTheme(ColorFrame, "BackgroundColor3", "Tertiary")
            Utility:RegisterTheme(ColorFrame.UIStroke, "Color", "Outline")
            
            local TopBtn = Utility:Create("TextButton", {
                Size = UDim2.new(1, 0, 0, 44),
                BackgroundTransparency = 1,
                Text = "",
                Parent = ColorFrame
            })
            
            local Title = Utility:Create("TextLabel", {
                Size = UDim2.new(1, -80, 1, 0),
                Position = UDim2.new(0, 15, 0, 0),
                BackgroundTransparency = 1,
                Text = CpName,
                TextColor3 = XreztHub.Themes[XreztHub.CurrentTheme].Text,
                Font = Enum.Font.GothamMedium,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = TopBtn
            })
            Utility:RegisterTheme(Title, "TextColor3", "Text")
            
            local DisplayColor = Utility:Create("Frame", {
                Size = UDim2.new(0, 30, 0, 20),
                Position = UDim2.new(1, -45, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = Default,
                Parent = TopBtn
            }, {
                Utility:Create("UICorner", { CornerRadius = UDim.new(0, 6) })
            })
            
            local DropIcon = Utility:Create("ImageLabel", {
                Size = UDim2.new(0, 16, 0, 16),
                Position = UDim2.new(1, -15, 0.5, 0),
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundTransparency = 1,
                Image = "rbxassetid://6026668589",
                ImageColor3 = XreztHub.Themes[XreztHub.CurrentTheme].SubText,
                Parent = TopBtn
            })
            Utility:RegisterTheme(DropIcon, "ImageColor3", "SubText")
            
            -- Picker Layout
            local PickerArea = Utility:Create("Frame", {
                Size = UDim2.new(1, -30, 0, 120),
                Position = UDim2.new(0, 15, 0, 50),
                BackgroundTransparency = 1,
                Parent = ColorFrame
            })
            
            local SatValueBox = Utility:Create("TextButton", {
                Size = UDim2.new(1, -25, 1, 0),
                BackgroundColor3 = Default,
                Text = "",
                AutoButtonColor = false,
                Parent = PickerArea
            }, {
                Utility:Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
                Utility:Create("UIGradient", {
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
                        ColorSequenceKeypoint.new(1, Color3.new(1,1,1))
                    })
                })
            })
            -- Simulate Saturation & Value gradients via Image overlay (standard trick)
            local Overlay = Utility:Create("ImageLabel", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Image = "rbxassetid://4155337372", -- S/V map
                Parent = SatValueBox
            }, { Utility:Create("UICorner", { CornerRadius = UDim.new(0, 8) }) })
            
            local HueBox = Utility:Create("TextButton", {
                Size = UDim2.new(0, 15, 1, 0),
                Position = UDim2.new(1, 0, 0, 0),
                AnchorPoint = Vector2.new(1, 0),
                Text = "",
                AutoButtonColor = false,
                Parent = PickerArea
            }, {
                Utility:Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
                Utility:Create("UIGradient", {
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.new(1,0,0)),
                        ColorSequenceKeypoint.new(0.167, Color3.new(1,1,0)),
                        ColorSequenceKeypoint.new(0.333, Color3.new(0,1,0)),
                        ColorSequenceKeypoint.new(0.5, Color3.new(0,1,1)),
                        ColorSequenceKeypoint.new(0.667, Color3.new(0,0,1)),
                        ColorSequenceKeypoint.new(0.833, Color3.new(1,0,1)),
                        ColorSequenceKeypoint.new(1, Color3.new(1,0,0))
                    }),
                    Rotation = 90
                })
            })
            
            local TrackerSV = Utility:Create("Frame", {
                Size = UDim2.new(0, 10, 0, 10),
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Color3.new(1,1,1),
                Parent = SatValueBox
            }, {
                Utility:Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
                Utility:Create("UIStroke", {Color = Color3.new(0,0,0), Thickness = 1})
            })
            
            local TrackerH = Utility:Create("Frame", {
                Size = UDim2.new(1, 4, 0, 4),
                Position = UDim2.new(0.5, 0, 0, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Color3.new(1,1,1),
                Parent = HueBox
            }, {
                Utility:Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
                Utility:Create("UIStroke", {Color = Color3.new(0,0,0), Thickness = 1})
            })

            local H, S, V = Default:ToHSV()
            TrackerH.Position = UDim2.new(0.5, 0, 1 - H, 0)
            TrackerSV.Position = UDim2.new(S, 0, 1 - V, 0)
            SatValueBox.BackgroundColor3 = Color3.fromHSV(H, 1, 1)

            local function UpdateColor()
                local c = Color3.fromHSV(H, S, V)
                DisplayColor.BackgroundColor3 = c
                XreztHub.Flags[Flag] = c
                Callback(c)
            end

            local DraggingSV = false
            local DraggingH = false

            SatValueBox.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then DraggingSV = true end
            end)
            HueBox.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then DraggingH = true end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    DraggingSV = false
                    DraggingH = false
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                    if DraggingSV then
                        local x = math.clamp((input.Position.X - SatValueBox.AbsolutePosition.X) / SatValueBox.AbsoluteSize.X, 0, 1)
                        local y = math.clamp((input.Position.Y - SatValueBox.AbsolutePosition.Y) / SatValueBox.AbsoluteSize.Y, 0, 1)
                        S = x
                        V = 1 - y
                        TrackerSV.Position = UDim2.new(S, 0, 1 - V, 0)
                        UpdateColor()
                    elseif DraggingH then
                        local y = math.clamp((input.Position.Y - HueBox.AbsolutePosition.Y) / HueBox.AbsoluteSize.Y, 0, 1)
                        H = 1 - y
                        TrackerH.Position = UDim2.new(0.5, 0, y, 0)
                        SatValueBox.BackgroundColor3 = Color3.fromHSV(H, 1, 1)
                        UpdateColor()
                    end
                end
            end)

            local IsOpen = false
            TopBtn.MouseButton1Click:Connect(function()
                IsOpen = not IsOpen
                if IsOpen then
                    Utility:Tween(ColorFrame, {Size = UDim2.new(1, 0, 0, 180)}, 0.4, Enum.EasingStyle.Quint)
                    Utility:Tween(DropIcon, {Rotation = 180}, 0.3)
                else
                    Utility:Tween(ColorFrame, {Size = UDim2.new(1, 0, 0, 44)}, 0.4, Enum.EasingStyle.Quint)
                    Utility:Tween(DropIcon, {Rotation = 0}, 0.3)
                end
            end)
        end

        function TabObj:CreateTextbox(boxOpts)
            boxOpts = boxOpts or {}
            local BoxName = boxOpts.Name or "Textbox"
            local Placeholder = boxOpts.Placeholder or "Type here..."
            local Callback = boxOpts.Callback or function() end
            local Flag = boxOpts.Flag or BoxName

            XreztHub.Flags[Flag] = ""

            local BoxFrame = Utility:Create("Frame", {
                Size = UDim2.new(1, 0, 0, 44),
                BackgroundColor3 = XreztHub.Themes[XreztHub.CurrentTheme].Tertiary,
                Parent = Page
            }, {
                Utility:Create("UICorner", { CornerRadius = UDim.new(0, 14) }),
                Utility:Create("UIStroke", {
                    Color = XreztHub.Themes[XreztHub.CurrentTheme].Outline,
                    Thickness = 1,
                    Transparency = 0.5
                })
            })
            Utility:RegisterTheme(BoxFrame, "BackgroundColor3", "Tertiary")
            Utility:RegisterTheme(BoxFrame.UIStroke, "Color", "Outline")

            local Title = Utility:Create("TextLabel", {
                Size = UDim2.new(0, 150, 1, 0),
                Position = UDim2.new(0, 15, 0, 0),
                BackgroundTransparency = 1,
                Text = BoxName,
                TextColor3 = XreztHub.Themes[XreztHub.CurrentTheme].Text,
                Font = Enum.Font.GothamMedium,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = BoxFrame
            })
            Utility:RegisterTheme(Title, "TextColor3", "Text")

            local InputContainer = Utility:Create("Frame", {
                Size = UDim2.new(0, 150, 0, 30),
                Position = UDim2.new(1, -15, 0.5, 0),
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundColor3 = XreztHub.Themes[XreztHub.CurrentTheme].Secondary,
                Parent = BoxFrame
            }, {
                Utility:Create("UICorner", { CornerRadius = UDim.new(0, 8) })
            })
            Utility:RegisterTheme(InputContainer, "BackgroundColor3", "Secondary")

            local TextBox = Utility:Create("TextBox", {
                Size = UDim2.new(1, -10, 1, 0),
                Position = UDim2.new(0, 5, 0, 0),
                BackgroundTransparency = 1,
                Text = "",
                PlaceholderText = Placeholder,
                TextColor3 = XreztHub.Themes[XreztHub.CurrentTheme].Text,
                PlaceholderColor3 = XreztHub.Themes[XreztHub.CurrentTheme].SubText,
                Font = Enum.Font.GothamMedium,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                ClearTextOnFocus = false,
                Parent = InputContainer
            })
            Utility:RegisterTheme(TextBox, "TextColor3", "Text")
            Utility:RegisterTheme(TextBox, "PlaceholderColor3", "SubText")

            TextBox.FocusLost:Connect(function()
                XreztHub.Flags[Flag] = TextBox.Text
                Callback(TextBox.Text)
            end)
        end

        function TabObj:CreateKeybind(keyOpts)
            keyOpts = keyOpts or {}
            local KeyName = keyOpts.Name or "Keybind"
            local Default = keyOpts.Default or Enum.KeyCode.E
            local Callback = keyOpts.Callback or function() end
            local Flag = keyOpts.Flag or KeyName

            XreztHub.Flags[Flag] = Default

            local KeyFrame = Utility:Create("Frame", {
                Size = UDim2.new(1, 0, 0, 44),
                BackgroundColor3 = XreztHub.Themes[XreztHub.CurrentTheme].Tertiary,
                Parent = Page
            }, {
                Utility:Create("UICorner", { CornerRadius = UDim.new(0, 14) }),
                Utility:Create("UIStroke", {
                    Color = XreztHub.Themes[XreztHub.CurrentTheme].Outline,
                    Thickness = 1,
                    Transparency = 0.5
                })
            })
            Utility:RegisterTheme(KeyFrame, "BackgroundColor3", "Tertiary")
            Utility:RegisterTheme(KeyFrame.UIStroke, "Color", "Outline")

            local Title = Utility:Create("TextLabel", {
                Size = UDim2.new(0, 150, 1, 0),
                Position = UDim2.new(0, 15, 0, 0),
                BackgroundTransparency = 1,
                Text = KeyName,
                TextColor3 = XreztHub.Themes[XreztHub.CurrentTheme].Text,
                Font = Enum.Font.GothamMedium,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = KeyFrame
            })
            Utility:RegisterTheme(Title, "TextColor3", "Text")

            local BindBtn = Utility:Create("TextButton", {
                Size = UDim2.new(0, 80, 0, 26),
                Position = UDim2.new(1, -15, 0.5, 0),
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundColor3 = XreztHub.Themes[XreztHub.CurrentTheme].Secondary,
                Text = Default.Name,
                TextColor3 = XreztHub.Themes[XreztHub.CurrentTheme].Text,
                Font = Enum.Font.GothamBold,
                TextSize = 12,
                AutoButtonColor = false,
                Parent = KeyFrame
            }, {
                Utility:Create("UICorner", { CornerRadius = UDim.new(0, 8) })
            })
            Utility:RegisterTheme(BindBtn, "BackgroundColor3", "Secondary")
            Utility:RegisterTheme(BindBtn, "TextColor3", "Text")

            local Binding = false
            BindBtn.MouseButton1Click:Connect(function()
                Binding = true
                BindBtn.Text = "..."
                Utility:Tween(BindBtn, {BackgroundColor3 = XreztHub.Themes[XreztHub.CurrentTheme].Accent}, 0.2)
            end)

            UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if not Binding then
                    if not gameProcessed and input.KeyCode == XreztHub.Flags[Flag] and input.KeyCode ~= Enum.KeyCode.Unknown then
                        Callback()
                    end
                    return
                end

                if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode ~= Enum.KeyCode.Unknown then
                    XreztHub.Flags[Flag] = input.KeyCode
                    BindBtn.Text = input.KeyCode.Name
                    Binding = false
                    Utility:Tween(BindBtn, {BackgroundColor3 = XreztHub.Themes[XreztHub.CurrentTheme].Secondary}, 0.2)
                end
            end)
        end

        function TabObj:CreateLabel(lblOpts)
            lblOpts = lblOpts or {}
            local Text = lblOpts.Text or "Label"
            
            local LblFrame = Utility:Create("Frame", {
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundTransparency = 1,
                Parent = Page
            })
            
            local Title = Utility:Create("TextLabel", {
                Size = UDim2.new(1, -10, 1, 0),
                Position = UDim2.new(0, 5, 0, 0),
                BackgroundTransparency = 1,
                Text = Text,
                TextColor3 = XreztHub.Themes[XreztHub.CurrentTheme].Text,
                Font = Enum.Font.Gotham,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextWrapped = true,
                Parent = LblFrame
            })
            Utility:RegisterTheme(Title, "TextColor3", "Text")
            
            -- Auto scale label
            local bounds = TextService:GetTextSize(Text, 13, Enum.Font.Gotham, Vector2.new(Page.AbsoluteSize.X - 20, math.huge))
            LblFrame.Size = UDim2.new(1, 0, 0, bounds.Y + 10)
        end
        
        function TabObj:CreateSection(secOpts)
            secOpts = secOpts or {}
            local SecName = secOpts.Name or "Section"
            
            local SecFrame = Utility:Create("Frame", {
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundTransparency = 1,
                Parent = Page
            })
            
            local Title = Utility:Create("TextLabel", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = SecName,
                TextColor3 = XreztHub.Themes[XreztHub.CurrentTheme].Accent,
                Font = Enum.Font.GothamBold,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = SecFrame
            })
            Utility:RegisterTheme(Title, "TextColor3", "Accent")
            
            local Div = Utility:Create("Frame", {
                Size = UDim2.new(1, 0, 0, 1),
                Position = UDim2.new(0, 0, 1, -2),
                BackgroundColor3 = XreztHub.Themes[XreztHub.CurrentTheme].Outline,
                Parent = SecFrame
            })
            Utility:RegisterTheme(Div, "BackgroundColor3", "Outline")
        end

        return TabObj
    end

    -- Setup Theme Tab automatically for demonstration
    local SettingsTab = WindowObj:CreateTab({Name = "Settings", Icon = ""})
    SettingsTab:CreateSection({Name = "Theme Engine"})
    
    local themeNames = {}
    for tName, _ in pairs(XreztHub.Themes) do
        table.insert(themeNames, tName)
    end
    
    SettingsTab:CreateDropdown({
        Name = "Select Theme",
        Options = themeNames,
        Default = XreztHub.CurrentTheme,
        Callback = function(val)
            XreztHub:SetTheme(val)
        end
    })

    SettingsTab:CreateButton({
        Name = "Test Notification",
        Callback = function()
            XreztHub:Notify({
                Title = "Xrezt Hub",
                Content = "This is a premium floating notification.",
                Duration = 3,
                Type = "Success"
            })
        end
    })

    -- Toggle Hotkey
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.RightShift then
            WindowObj.IsMinimized = not WindowObj.IsMinimized
            if WindowObj.IsMinimized then
                Utility:Tween(MainShadow, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In)
            else
                Utility:Tween(MainShadow, {Size = Size, BackgroundTransparency = 0.4}, 0.5, Enum.EasingStyle.Back)
            end
        end
    end)

    return WindowObj
end

--=========================================--
-- TOGGLE SPAWNER (FLOATING BUTTON)
--=========================================--

function XreztHub:CreateSpawner()
    local SpawnerBtn = Utility:Create("TextButton", {
        Name = "XreztSpawner",
        Size = UDim2.new(0, 50, 0, 50),
        Position = UDim2.new(0, 20, 0.5, 0),
        BackgroundColor3 = self.Themes[self.CurrentTheme].Secondary,
        Text = "",
        ZIndex = 9999,
        Parent = ScreenGui,
        ClipsDescendants = true
    }, {
        Utility:Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
        Utility:Create("UIStroke", {
            Color = self.Themes[self.CurrentTheme].Accent,
            Thickness = 2,
            Transparency = 0.2
        })
    })
    
    Utility:RegisterTheme(SpawnerBtn, "BackgroundColor3", "Secondary")
    Utility:RegisterTheme(SpawnerBtn.UIStroke, "Color", "Accent")

    local Logo = Utility:Create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "X",
        TextColor3 = self.Themes[self.CurrentTheme].Accent,
        Font = Enum.Font.GothamBold,
        TextSize = 24,
        Parent = SpawnerBtn
    })
    Utility:RegisterTheme(Logo, "TextColor3", "Accent")

    -- Draggable
    Utility:MakeDraggable(SpawnerBtn, SpawnerBtn)

    -- Hover Animation
    SpawnerBtn.MouseEnter:Connect(function()
        Utility:Tween(SpawnerBtn, {Size = UDim2.new(0, 55, 0, 55)}, 0.2)
    end)
    SpawnerBtn.MouseLeave:Connect(function()
        Utility:Tween(SpawnerBtn, {Size = UDim2.new(0, 50, 0, 50)}, 0.2)
    end)

    -- Press Action (Simulate opening the main window if minimized)
    SpawnerBtn.MouseButton1Click:Connect(function()
        local mainShadow = ScreenGui:FindFirstChild("MainShadow")
        if mainShadow then
            if mainShadow.Size.X.Offset < 100 then -- assume minimized
                Utility:Tween(mainShadow, {Size = UDim2.new(0, 750, 0, 480), BackgroundTransparency = 0.4}, 0.5, Enum.EasingStyle.Back)
            else
                Utility:Tween(mainShadow, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In)
            end
        end
    end)
end

--=========================================--
-- INITIALIZATION SEQUENCE
--=========================================--

-- 1. Show Advanced Loading Screen
XreztHub:LoadXrezt()

-- 2. Create Floating Spawner
XreztHub:CreateSpawner()

return XreztHub
