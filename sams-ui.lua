--[[
    Sam's Hub - Advanced UI Framework (Golden Edition)
    Architecture, Motion Graphics, and Design completely rewritten.
    Features: 
        - Custom Spring-based physics engine for motion graphics
        - True Golden UI Theme (Metallic Gradients, Ambient Glows)
        - Dynamic Geometric Loading Screen (Thread-Safe)
        - Interactive Particle/Ripple System
        - Comprehensive Elements (Pickers, Keybinds, Sliders, Dropdowns, etc.)
        - Notification & Tooltip Systems
]]

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local TextService = game:GetService("TextService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

--========================================================
-- 1. UTILITIES & ADVANCED MATH (SPRING PHYSICS)
--========================================================

local Utility = {}

function Utility:Create(className, properties, children)
    local inst = Instance.new(className)
    for i, v in pairs(properties or {}) do
        inst[i] = v
    end
    for _, child in pairs(children or {}) do
        child.Parent = inst
    end
    return inst
end

-- Custom Spring Module for buttery smooth motion graphics
local Spring = {}
Spring.__index = Spring

function Spring.new(target, tension, friction)
    local self = setmetatable({}, Spring)
    self.Target = target
    self.Position = target
    self.Velocity = 0
    self.Tension = tension or 40
    self.Friction = friction or 4
    return self
end

function Spring:Update(dt)
    local displacement = self.Target - self.Position
    local springForce = displacement * self.Tension
    local dampingForce = -self.Velocity * self.Friction
    local acceleration = springForce + dampingForce
    
    self.Velocity = self.Velocity + (acceleration * dt)
    self.Position = self.Position + (self.Velocity * dt)
    return self.Position
end

--========================================================
-- 2. THEME ENGINE & CONSTANTS
--========================================================

local Theme = {
    -- True Gold Palette
    GoldBase = Color3.fromRGB(212, 175, 55),
    GoldHighlight = Color3.fromRGB(255, 223, 0),
    GoldShadow = Color3.fromRGB(138, 115, 34),
    GoldDark = Color3.fromRGB(85, 70, 20),
    
    -- Background Palette (Obsidian/Carbon)
    BackgroundMain = Color3.fromRGB(12, 12, 12),
    BackgroundSecondary = Color3.fromRGB(18, 18, 18),
    BackgroundTertiary = Color3.fromRGB(24, 24, 24),
    BackgroundHover = Color3.fromRGB(30, 30, 30),
    
    -- Accents & Text
    TextMain = Color3.fromRGB(245, 245, 245),
    TextMuted = Color3.fromRGB(160, 160, 160),
    TextDark = Color3.fromRGB(100, 100, 100),
    
    -- UI Metrics
    CornerRadius = UDim.new(0, 6),
    WindowSize = UDim2.new(0, 650, 0, 420),
    SidebarWidth = 160
}

local Tweens = {
    Hover = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Press = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Slower = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    Bounce = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
}

--========================================================
-- 3. MOTION GRAPHICS: RIPPLE & GLOW SYSTEMS
--========================================================

local Effects = {}

function Effects:CreateRipple(parent, input)
    local absolutePos = parent.AbsolutePosition
    local absoluteSize = parent.AbsoluteSize
    
    local mouseX = input and input.Position.X or Mouse.X
    local mouseY = input and input.Position.Y or Mouse.Y
    
    local relX = mouseX - absolutePos.X
    local relY = mouseY - absolutePos.Y
    
    local ripple = Utility:Create("Frame", {
        Name = "Ripple",
        BackgroundColor3 = Theme.GoldHighlight,
        BackgroundTransparency = 0.6,
        BorderSizePixel = 0,
        Position = UDim2.new(0, relX, 0, relY),
        Size = UDim2.new(0, 0, 0, 0),
        ZIndex = parent.ZIndex + 1,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Parent = parent
    }, {
        Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0)})
    })
    
    local targetSize = math.max(absoluteSize.X, absoluteSize.Y) * 1.5
    
    local sizeTween = TweenService:Create(ripple, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, targetSize, 0, targetSize),
        BackgroundTransparency = 1
    })
    
    sizeTween:Play()
    task.delay(0.4, function()
        if ripple then ripple:Destroy() end
    end)
end

function Effects:ApplyGradient(parent, color1, color2, angle)
    return Utility:Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, color1),
            ColorSequenceKeypoint.new(1, color2)
        }),
        Rotation = angle or 45,
        Parent = parent
    })
end

function Effects:CreateGlow(parent, color, transparency, size)
    return Utility:Create("ImageLabel", {
        Name = "Glow",
        BackgroundTransparency = 1,
        Image = "rbxassetid://5028857472", -- Soft glow asset
        ImageColor3 = color,
        ImageTransparency = transparency or 0.5,
        Size = size or UDim2.new(1, 40, 1, 40),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex = parent.ZIndex - 1,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(24, 24, 276, 276),
        Parent = parent
    })
end

--========================================================
-- 4. FRAMEWORK CORE
--========================================================

local SamsHub = {
    Windows = {},
    Connections = {},
    Hovering = false,
    CurrentZIndex = 100
}

function SamsHub:ProtectGUI(gui)
    local success = pcall(function() gui.Parent = CoreGui end)
    if not success then
        gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
end

function SamsHub:MakeDraggable(topbar, object)
    local dragging, dragInput, dragStart, startPos
    
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = object.Position
            
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
            TweenService:Create(object, TweenInfo.new(0.08, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            }):Play()
        end
    end)
end

--========================================================
-- 5. LOADING SCREEN (GEOMETRIC & ANIMATED)
--========================================================

function SamsHub:PlayLoadingSequence(gui, windowName, callback)
    local LoadFrame = Utility:Create("Frame", {
        Name = "LoadingScreen",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Theme.BackgroundMain,
        ZIndex = 1000,
        Parent = gui
    })
    
    Effects:CreateGlow(LoadFrame, Theme.GoldShadow, 0.8, UDim2.new(1, 0, 1, 0))
    
    local CenterContainer = Utility:Create("Frame", {
        Name = "Center",
        Size = UDim2.new(0, 200, 0, 200),
        Position = UDim2.new(0.5, 0, 0.45, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Parent = LoadFrame
    })

    -- Geometric Logo Generation
    local shapes = {}
    for i = 1, 3 do
        local shape = Utility:Create("Frame", {
            Name = "Shape" .. i,
            Size = UDim2.new(0, 0, 0, 0), -- Start size 0
            Position = UDim2.new(0.5, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Rotation = (i - 1) * 30,
            ZIndex = 1001 + i,
            Parent = CenterContainer
        }, {
            Utility:Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
            Utility:Create("UIStroke", {
                Color = Theme.GoldBase,
                Thickness = 2,
                Transparency = 1
            })
        })
        Effects:ApplyGradient(shape, Theme.GoldHighlight, Theme.GoldShadow, 45)
        table.insert(shapes, shape)
    end

    local Title = Utility:Create("TextLabel", {
        Name = "Title",
        Text = windowName,
        Font = Enum.Font.GothamBlack,
        TextSize = 34,
        TextColor3 = Theme.TextMain,
        Size = UDim2.new(1, 0, 0, 50),
        Position = UDim2.new(0.5, 0, 0.55, 30),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        TextTransparency = 1,
        ZIndex = 1005,
        Parent = LoadFrame
    })
    
    Effects:ApplyGradient(Title, Theme.GoldHighlight, Theme.GoldBase, 0)

    local SubTitle = Utility:Create("TextLabel", {
        Name = "SubTitle",
        Text = "Initializing Framework...",
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextColor3 = Theme.TextMuted,
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0.5, 0, 0.55, 60),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        TextTransparency = 1,
        ZIndex = 1005,
        Parent = LoadFrame
    })

    local BarBg = Utility:Create("Frame", {
        Name = "BarBg",
        Size = UDim2.new(0, 250, 0, 4),
        Position = UDim2.new(0.5, 0, 0.55, 90),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.BackgroundTertiary,
        BackgroundTransparency = 1,
        ZIndex = 1005,
        Parent = LoadFrame
    }, {
        Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0)})
    })

    local BarFill = Utility:Create("Frame", {
        Name = "BarFill",
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        ZIndex = 1006,
        Parent = BarBg
    }, {
        Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0)})
    })
    Effects:ApplyGradient(BarFill, Theme.GoldHighlight, Theme.GoldDark, 90)

    -- Thread-safe Animation Timeline (No Yielding Issues)
    task.spawn(function()
        -- 1. Pop in shapes
        for i, shape in ipairs(shapes) do
            TweenService:Create(shape, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 80, 0, 80)
            }):Play()
            TweenService:Create(shape.UIStroke, TweenInfo.new(0.6), {Transparency = 0}):Play()
            task.wait(0.15)
        end
        
        -- 2. Spin shapes
        local spinConn = RunService.RenderStepped:Connect(function()
            for i, shape in ipairs(shapes) do
                shape.Rotation = shape.Rotation + (0.5 * i)
            end
        end)
        
        -- 3. Fade in text and bar
        TweenService:Create(Title, Tweens.Slower, {TextTransparency = 0, Position = UDim2.new(0.5, 0, 0.55, 20)}):Play()
        task.wait(0.2)
        TweenService:Create(SubTitle, Tweens.Slower, {TextTransparency = 0}):Play()
        TweenService:Create(BarBg, Tweens.Slower, {BackgroundTransparency = 0}):Play()
        
        -- 4. Fill Bar safely
        TweenService:Create(BarFill, TweenInfo.new(1.8, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Size = UDim2.new(1, 0, 1, 0)}):Play()
        
        -- Update subtitle randomly
        local phrases = {"Injecting CSS...", "Bending Physics...", "Forging Gold...", "Loading Modules...", "Preparing Canvas..."}
        for _ = 1, 5 do
            task.wait(1.8 / 5)
            SubTitle.Text = phrases[math.random(1, #phrases)]
        end
        
        SubTitle.Text = "Complete."
        task.wait(0.3)
        
        -- 5. Shatter / Fade Out Sequence
        if spinConn then spinConn:Disconnect() end
        
        for i, shape in ipairs(shapes) do
            TweenService:Create(shape, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 0, 0, 0),
                Rotation = shape.Rotation + 90
            }):Play()
        end
        
        TweenService:Create(Title, TweenInfo.new(0.3), {TextTransparency = 1, Position = UDim2.new(0.5, 0, 0.55, 10)}):Play()
        TweenService:Create(SubTitle, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        TweenService:Create(BarBg, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        TweenService:Create(BarFill, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        
        task.wait(0.4)
        
        TweenService:Create(LoadFrame, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
        for _, child in pairs(LoadFrame:GetChildren()) do
            if child:IsA("GuiObject") and child.Name == "Glow" then
                TweenService:Create(child, TweenInfo.new(0.5), {ImageTransparency = 1}):Play()
            end
        end
        
        task.wait(0.55) -- Hard yield to ensure tweens finish
        
        LoadFrame:Destroy()
        if callback then callback() end
    end)
end

--========================================================
-- 6. MAIN WINDOW CREATION
--========================================================

function SamsHub:CreateWindow(config)
    config = config or {}
    local WindowName = config.Name or "Sam's Hub - Golden"
    local UseLoading = config.LoadingScreen == nil and true or config.LoadingScreen
    local Keybind = config.Keybind or Enum.KeyCode.RightShift
    
    local CoreUI = Utility:Create("ScreenGui", {
        Name = "SamsHub_V2",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Global
    })
    
    SamsHub:ProtectGUI(CoreUI)
    
    local MainContainer = Utility:Create("Frame", {
        Name = "MainContainer",
        Size = Theme.WindowSize,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.BackgroundMain,
        BorderSizePixel = 0,
        ClipsDescendants = false,
        Visible = not UseLoading,
        ZIndex = 10
    }, {
        Utility:Create("UICorner", {CornerRadius = Theme.CornerRadius}),
        Utility:Create("UIStroke", {
            Color = Theme.GoldDark,
            Thickness = 1,
            Transparency = 0.5
        })
    })
    
    -- Drop shadow
    Effects:CreateGlow(MainContainer, Color3.new(0,0,0), 0.4, UDim2.new(1, 80, 1, 80))
    MainContainer.Parent = CoreUI
    
    -- Topbar setup
    local Topbar = Utility:Create("Frame", {
        Name = "Topbar",
        Size = UDim2.new(1, 0, 0, 45),
        BackgroundColor3 = Theme.BackgroundSecondary,
        BorderSizePixel = 0,
        ZIndex = 11,
        Parent = MainContainer
    }, {
        Utility:Create("UICorner", {CornerRadius = Theme.CornerRadius}),
        Utility:Create("Frame", { -- Square off bottom corners
            Name = "BottomBlock",
            Size = UDim2.new(1, 0, 0, 10),
            Position = UDim2.new(0, 0, 1, -10),
            BackgroundColor3 = Theme.BackgroundSecondary,
            BorderSizePixel = 0
        })
    })
    
    -- Gold Accent Line
    local AccentLine = Utility:Create("Frame", {
        Name = "AccentLine",
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        ZIndex = 12,
        Parent = Topbar
    })
    Effects:ApplyGradient(AccentLine, Theme.GoldBase, Theme.GoldHighlight, 0)
    
    local TitleLabel = Utility:Create("TextLabel", {
        Name = "TitleLabel",
        Text = "  " .. WindowName,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextColor3 = Theme.TextMain,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1, -100, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        BackgroundTransparency = 1,
        ZIndex = 12,
        Parent = Topbar
    })
    -- Gradient Text
    Effects:ApplyGradient(TitleLabel, Theme.GoldHighlight, Theme.GoldBase, 0)
    
    SamsHub:MakeDraggable(Topbar, MainContainer)
    
    -- Sidebar Setup
    local Sidebar = Utility:Create("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, Theme.SidebarWidth, 1, -45),
        Position = UDim2.new(0, 0, 0, 45),
        BackgroundColor3 = Theme.BackgroundSecondary,
        BorderSizePixel = 0,
        ZIndex = 11,
        Parent = MainContainer
    }, {
        Utility:Create("UICorner", {CornerRadius = Theme.CornerRadius}),
        Utility:Create("Frame", { -- Square off right and top corners
            Name = "Filler",
            Size = UDim2.new(0, 10, 1, 0),
            Position = UDim2.new(1, -10, 0, 0),
            BackgroundColor3 = Theme.BackgroundSecondary,
            BorderSizePixel = 0
        }),
        Utility:Create("Frame", { 
            Name = "Filler2",
            Size = UDim2.new(1, 0, 0, 10),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundColor3 = Theme.BackgroundSecondary,
            BorderSizePixel = 0
        })
    })

    local SidebarList = Utility:Create("ScrollingFrame", {
        Name = "List",
        Size = UDim2.new(1, 0, 1, -10),
        Position = UDim2.new(0, 0, 0, 5),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 0,
        ZIndex = 12,
        Parent = Sidebar
    }, {
        Utility:Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 4),
            HorizontalAlignment = Enum.HorizontalAlignment.Center
        }),
        Utility:Create("UIPadding", {
            PaddingTop = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 10)
        })
    })

    -- Content Container Setup
    local ContentContainer = Utility:Create("Frame", {
        Name = "Content",
        Size = UDim2.new(1, -Theme.SidebarWidth, 1, -45),
        Position = UDim2.new(0, Theme.SidebarWidth, 0, 45),
        BackgroundTransparency = 1,
        ZIndex = 11,
        Parent = MainContainer
    })
    
    -- Notification Container
    local NotifContainer = Utility:Create("Frame", {
        Name = "Notifications",
        Size = UDim2.new(0, 300, 1, 0),
        Position = UDim2.new(1, -320, 0, 20),
        BackgroundTransparency = 1,
        ZIndex = 2000,
        Parent = CoreUI
    }, {
        Utility:Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10),
            VerticalAlignment = Enum.VerticalAlignment.Bottom
        })
    })

    -- Safe Toggling Mechanism
    local isUIOpen = true
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if input.KeyCode == Keybind and not gameProcessed then
            isUIOpen = not isUIOpen
            if isUIOpen then
                MainContainer.Visible = true
                TweenService:Create(MainContainer, Tweens.Bounce, {
                    Size = Theme.WindowSize
                }):Play()
            else
                TweenService:Create(MainContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                    Size = UDim2.new(0, Theme.WindowSize.X.Offset, 0, 0)
                }):Play()
                
                task.delay(0.3, function()
                    if not isUIOpen then MainContainer.Visible = false end
                end)
            end
        end
    end)

    if UseLoading then
        SamsHub:PlayLoadingSequence(CoreUI, WindowName, function()
            MainContainer.Visible = true
            MainContainer.Size = UDim2.new(0, Theme.WindowSize.X.Offset, 0, 0)
            TweenService:Create(MainContainer, Tweens.Bounce, {Size = Theme.WindowSize}):Play()
        end)
    end

    --========================================================
    -- 7. TAB SYSTEM API
    --========================================================
    
    local WindowAPI = {}
    local Tabs = {}
    local FirstTab = true

    function WindowAPI:CreateTab(tabName, iconAssetId)
        local TabAPI = {}
        
        local TabButton = Utility:Create("TextButton", {
            Name = "Tab_" .. tabName,
            Size = UDim2.new(1, -20, 0, 34),
            BackgroundColor3 = Theme.BackgroundTertiary,
            BackgroundTransparency = 1,
            Text = "",
            AutoButtonColor = false,
            ZIndex = 13,
            Parent = SidebarList
        }, {
            Utility:Create("UICorner", {CornerRadius = Theme.CornerRadius})
        })

        -- Visuals for Tab
        local Indicator = Utility:Create("Frame", {
            Name = "Indicator",
            Size = UDim2.new(0, 3, 0, 0),
            Position = UDim2.new(0, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundColor3 = Theme.GoldBase,
            BorderSizePixel = 0,
            ZIndex = 14,
            Parent = TabButton
        }, { Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0)}) })
        
        Effects:ApplyGradient(Indicator, Theme.GoldHighlight, Theme.GoldBase, 180)

        local TabIcon = Utility:Create("ImageLabel", {
            Name = "Icon",
            Size = UDim2.new(0, 18, 0, 18),
            Position = UDim2.new(0, 15, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundTransparency = 1,
            Image = iconAssetId or "rbxassetid://11283626154",
            ImageColor3 = Theme.TextMuted,
            ZIndex = 14,
            Parent = TabButton
        })

        local TabText = Utility:Create("TextLabel", {
            Name = "Text",
            Text = tabName,
            Font = Enum.Font.GothamSemibold,
            TextSize = 13,
            TextColor3 = Theme.TextMuted,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(1, -45, 1, 0),
            Position = UDim2.new(0, 40, 0, 0),
            BackgroundTransparency = 1,
            ZIndex = 14,
            Parent = TabButton
        })

        local TabScroll = Utility:Create("ScrollingFrame", {
            Name = "Scroll_" .. tabName,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Theme.GoldDark,
            Visible = false,
            ZIndex = 12,
            Parent = ContentContainer
        }, {
            Utility:Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 8),
                HorizontalAlignment = Enum.HorizontalAlignment.Center
            }),
            Utility:Create("UIPadding", {
                PaddingTop = UDim.new(0, 15),
                PaddingBottom = UDim.new(0, 15),
                PaddingLeft = UDim.new(0, 15),
                PaddingRight = UDim.new(0, 15)
            })
        })

        Tabs[tabName] = {Button = TabButton, Scroll = TabScroll, Text = TabText, Icon = TabIcon, Indicator = Indicator}

        local function ActivateTab()
            for name, tab in pairs(Tabs) do
                tab.Scroll.Visible = (name == tabName)
                if name == tabName then
                    TweenService:Create(tab.Button, Tweens.Hover, {BackgroundTransparency = 0}):Play()
                    TweenService:Create(tab.Text, Tweens.Hover, {TextColor3 = Theme.GoldHighlight}):Play()
                    TweenService:Create(tab.Icon, Tweens.Hover, {ImageColor3 = Theme.GoldHighlight}):Play()
                    TweenService:Create(tab.Indicator, Tweens.Bounce, {Size = UDim2.new(0, 3, 0, 18)}):Play()
                else
                    TweenService:Create(tab.Button, Tweens.Hover, {BackgroundTransparency = 1}):Play()
                    TweenService:Create(tab.Text, Tweens.Hover, {TextColor3 = Theme.TextMuted}):Play()
                    TweenService:Create(tab.Icon, Tweens.Hover, {ImageColor3 = Theme.TextMuted}):Play()
                    TweenService:Create(tab.Indicator, Tweens.Hover, {Size = UDim2.new(0, 3, 0, 0)}):Play()
                end
            end
        end

        TabButton.MouseButton1Click:Connect(function()
            Effects:CreateRipple(TabButton)
            ActivateTab()
        end)
        
        TabButton.MouseEnter:Connect(function()
            if not TabScroll.Visible then
                TweenService:Create(TabText, Tweens.Hover, {TextColor3 = Theme.TextMain}):Play()
            end
        end)
        
        TabButton.MouseLeave:Connect(function()
            if not TabScroll.Visible then
                TweenService:Create(TabText, Tweens.Hover, {TextColor3 = Theme.TextMuted}):Play()
            end
        end)

        TabScroll.ChildAdded:Connect(function()
            local layout = TabScroll:FindFirstChildOfClass("UIListLayout")
            TabScroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 30)
        end)

        if FirstTab then ActivateTab(); FirstTab = false end

        --========================================================
        -- 8. ELEMENTS API (Inside Tab)
        --========================================================

        function TabAPI:CreateSection(sectionName)
            local sec = Utility:Create("Frame", {
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundTransparency = 1,
                Parent = TabScroll
            })
            
            Utility:Create("TextLabel", {
                Text = string.upper(sectionName),
                Font = Enum.Font.GothamBold,
                TextSize = 12,
                TextColor3 = Theme.GoldBase,
                TextXAlignment = Enum.TextXAlignment.Left,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Parent = sec
            })
            
            Utility:Create("Frame", {
                Size = UDim2.new(1, 0, 0, 1),
                Position = UDim2.new(0, 0, 1, -5),
                BackgroundColor3 = Theme.GoldDark,
                BorderSizePixel = 0,
                Parent = sec
            })
        end

        function TabAPI:CreateButton(params)
            local Name = params.Name or "Button"
            local Callback = params.Callback or function() end

            local BtnFrame = Utility:Create("TextButton", {
                Name = "Btn_" .. Name,
                Size = UDim2.new(1, 0, 0, 38),
                BackgroundColor3 = Theme.BackgroundTertiary,
                Text = "",
                AutoButtonColor = false,
                ClipsDescendants = true,
                Parent = TabScroll
            }, {
                Utility:Create("UICorner", {CornerRadius = Theme.CornerRadius}),
                Utility:Create("UIStroke", {Color = Theme.GoldDark, Thickness = 1, Transparency = 0.8})
            })

            local BtnText = Utility:Create("TextLabel", {
                Text = Name,
                Font = Enum.Font.GothamSemibold,
                TextSize = 14,
                TextColor3 = Theme.TextMain,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                ZIndex = 2,
                Parent = BtnFrame
            })

            BtnFrame.MouseEnter:Connect(function()
                TweenService:Create(BtnFrame, Tweens.Hover, {BackgroundColor3 = Theme.BackgroundHover}):Play()
                TweenService:Create(BtnText, Tweens.Hover, {TextColor3 = Theme.GoldHighlight}):Play()
            end)

            BtnFrame.MouseLeave:Connect(function()
                TweenService:Create(BtnFrame, Tweens.Hover, {BackgroundColor3 = Theme.BackgroundTertiary}):Play()
                TweenService:Create(BtnText, Tweens.Hover, {TextColor3 = Theme.TextMain}):Play()
            end)

            BtnFrame.MouseButton1Down:Connect(function()
                TweenService:Create(BtnFrame, Tweens.Press, {Size = UDim2.new(1, -4, 0, 34)}):Play()
            end)

            BtnFrame.MouseButton1Up:Connect(function()
                Effects:CreateRipple(BtnFrame)
                TweenService:Create(BtnFrame, Tweens.Bounce, {Size = UDim2.new(1, 0, 0, 38)}):Play()
                Callback()
            end)
        end

        function TabAPI:CreateToggle(params)
            local Name = params.Name or "Toggle"
            local Default = params.Default or false
            local Callback = params.Callback or function() end
            local State = Default

            local ToggleFrame = Utility:Create("TextButton", {
                Size = UDim2.new(1, 0, 0, 42),
                BackgroundColor3 = Theme.BackgroundTertiary,
                Text = "",
                AutoButtonColor = false,
                Parent = TabScroll
            }, {
                Utility:Create("UICorner", {CornerRadius = Theme.CornerRadius}),
                Utility:Create("UIStroke", {Color = Theme.GoldDark, Thickness = 1, Transparency = 0.8})
            })

            local Title = Utility:Create("TextLabel", {
                Text = Name,
                Font = Enum.Font.GothamSemibold,
                TextSize = 14,
                TextColor3 = Theme.TextMain,
                TextXAlignment = Enum.TextXAlignment.Left,
                Size = UDim2.new(1, -60, 1, 0),
                Position = UDim2.new(0, 15, 0, 0),
                BackgroundTransparency = 1,
                Parent = ToggleFrame
            })

            local SwitchBg = Utility:Create("Frame", {
                Size = UDim2.new(0, 40, 0, 20),
                Position = UDim2.new(1, -55, 0.5, -10),
                BackgroundColor3 = State and Theme.GoldBase or Theme.BackgroundMain,
                Parent = ToggleFrame
            }, {
                Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
                Utility:Create("UIStroke", {Color = Theme.GoldDark, Thickness = 1, Transparency = 0.5})
            })

            local SwitchKnob = Utility:Create("Frame", {
                Size = UDim2.new(0, 16, 0, 16),
                Position = UDim2.new(0, State and 22 or 2, 0.5, -8),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Parent = SwitchBg
            }, { Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0)}) })

            local knobSpring = Spring.new(State and 22 or 2, 50, 4)
            local conn

            local function Fire()
                State = not State
                knobSpring.Target = State and 22 or 2
                
                TweenService:Create(SwitchBg, Tweens.Hover, {
                    BackgroundColor3 = State and Theme.GoldBase or Theme.BackgroundMain
                }):Play()
                
                if conn then conn:Disconnect() end
                conn = RunService.RenderStepped:Connect(function(dt)
                    local pos = knobSpring:Update(dt)
                    SwitchKnob.Position = UDim2.new(0, pos, 0.5, -8)
                    if math.abs(knobSpring.Velocity) < 0.01 and math.abs(knobSpring.Target - knobSpring.Position) < 0.01 then
                        conn:Disconnect()
                    end
                end)
                
                Callback(State)
            end

            ToggleFrame.MouseButton1Click:Connect(Fire)
            
            local TglAPI = {}
            function TglAPI:Set(val)
                if val ~= State then Fire() end
            end
            return TglAPI
        end

        function TabAPI:CreateSlider(params)
            local Name = params.Name or "Slider"
            local Min = params.Min or 0
            local Max = params.Max or 100
            local Default = params.Default or Min
            local Callback = params.Callback or function() end
            local Decimals = params.Decimals or 0
            
            local Value = math.clamp(Default, Min, Max)

            local SliderFrame = Utility:Create("Frame", {
                Size = UDim2.new(1, 0, 0, 55),
                BackgroundColor3 = Theme.BackgroundTertiary,
                Parent = TabScroll
            }, {
                Utility:Create("UICorner", {CornerRadius = Theme.CornerRadius}),
                Utility:Create("UIStroke", {Color = Theme.GoldDark, Thickness = 1, Transparency = 0.8})
            })

            local Title = Utility:Create("TextLabel", {
                Text = Name,
                Font = Enum.Font.GothamSemibold,
                TextSize = 14,
                TextColor3 = Theme.TextMain,
                TextXAlignment = Enum.TextXAlignment.Left,
                Size = UDim2.new(1, -60, 0, 25),
                Position = UDim2.new(0, 15, 0, 5),
                BackgroundTransparency = 1,
                Parent = SliderFrame
            })

            local ValueBox = Utility:Create("TextBox", {
                Text = string.format("%." .. Decimals .. "f", Value),
                Font = Enum.Font.GothamBold,
                TextSize = 13,
                TextColor3 = Theme.GoldHighlight,
                TextXAlignment = Enum.TextXAlignment.Right,
                Size = UDim2.new(0, 50, 0, 25),
                Position = UDim2.new(1, -65, 0, 5),
                BackgroundTransparency = 1,
                Parent = SliderFrame
            })

            local BarBg = Utility:Create("TextButton", {
                Text = "",
                Size = UDim2.new(1, -30, 0, 6),
                Position = UDim2.new(0, 15, 0, 35),
                BackgroundColor3 = Theme.BackgroundMain,
                AutoButtonColor = false,
                Parent = SliderFrame
            }, { Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0)}) })

            local BarFill = Utility:Create("Frame", {
                Size = UDim2.new((Value - Min) / (Max - Min), 0, 1, 0),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Parent = BarBg
            }, { Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0)}) })
            Effects:ApplyGradient(BarFill, Theme.GoldBase, Theme.GoldHighlight, 0)

            local DragDot = Utility:Create("Frame", {
                Size = UDim2.new(0, 14, 0, 14),
                Position = UDim2.new(1, -7, 0.5, -7),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Parent = BarFill
            }, {
                Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
                Utility:Create("UIStroke", {Color = Theme.GoldShadow, Thickness = 2})
            })

            local dragging = false
            
            local function Update(input)
                local percent = math.clamp((input.Position.X - BarBg.AbsolutePosition.X) / BarBg.AbsoluteSize.X, 0, 1)
                local val = Min + ((Max - Min) * percent)
                
                if Decimals == 0 then
                    val = math.floor(val)
                else
                    val = tonumber(string.format("%." .. Decimals .. "f", val))
                end
                
                Value = val
                ValueBox.Text = tostring(val)
                
                TweenService:Create(BarFill, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Size = UDim2.new(percent, 0, 1, 0)
                }):Play()
                
                Callback(Value)
            end

            BarBg.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    Update(input)
                    TweenService:Create(DragDot, Tweens.Hover, {Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(1, -9, 0.5, -9)}):Play()
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    if dragging then
                        dragging = false
                        TweenService:Create(DragDot, Tweens.Hover, {Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(1, -7, 0.5, -7)}):Play()
                    end
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    Update(input)
                end
            end)
            
            ValueBox.FocusLost:Connect(function()
                local num = tonumber(ValueBox.Text)
                if num then
                    num = math.clamp(num, Min, Max)
                    Value = num
                    ValueBox.Text = tostring(num)
                    local percent = (Value - Min) / (Max - Min)
                    TweenService:Create(BarFill, Tweens.Hover, {Size = UDim2.new(percent, 0, 1, 0)}):Play()
                    Callback(Value)
                else
                    ValueBox.Text = tostring(Value)
                end
            end)
        end

        function TabAPI:CreateDropdown(params)
            local Name = params.Name or "Dropdown"
            local Options = params.Options or {}
            local Default = params.Default
            local Callback = params.Callback or function() end
            
            local IsOpen = false
            local Selected = Default
            local ItemHeight = 30
            
            local DropdownFrame = Utility:Create("Frame", {
                Size = UDim2.new(1, 0, 0, 42),
                BackgroundColor3 = Theme.BackgroundTertiary,
                ClipsDescendants = true,
                Parent = TabScroll
            }, {
                Utility:Create("UICorner", {CornerRadius = Theme.CornerRadius}),
                Utility:Create("UIStroke", {Color = Theme.GoldDark, Thickness = 1, Transparency = 0.8})
            })

            local DropButton = Utility:Create("TextButton", {
                Size = UDim2.new(1, 0, 0, 42),
                BackgroundTransparency = 1,
                Text = "",
                ZIndex = 2,
                Parent = DropdownFrame
            })

            local Title = Utility:Create("TextLabel", {
                Text = Name,
                Font = Enum.Font.GothamSemibold,
                TextSize = 14,
                TextColor3 = Theme.TextMain,
                TextXAlignment = Enum.TextXAlignment.Left,
                Size = UDim2.new(1, -60, 1, 0),
                Position = UDim2.new(0, 15, 0, 0),
                BackgroundTransparency = 1,
                Parent = DropButton
            })

            local SelectedLabel = Utility:Create("TextLabel", {
                Text = Selected or "None",
                Font = Enum.Font.Gotham,
                TextSize = 13,
                TextColor3 = Theme.GoldBase,
                TextXAlignment = Enum.TextXAlignment.Right,
                Size = UDim2.new(0, 100, 1, 0),
                Position = UDim2.new(1, -135, 0, 0),
                BackgroundTransparency = 1,
                Parent = DropButton
            })

            local Icon = Utility:Create("ImageLabel", {
                Image = "rbxassetid://6031090990", 
                Size = UDim2.new(0, 20, 0, 20),
                Position = UDim2.new(1, -30, 0.5, -10),
                BackgroundTransparency = 1,
                ImageColor3 = Theme.TextMuted,
                Parent = DropButton
            })

            local ListContainer = Utility:Create("ScrollingFrame", {
                Size = UDim2.new(1, -20, 0, 0),
                Position = UDim2.new(0, 10, 0, 42),
                BackgroundTransparency = 1,
                ScrollBarThickness = 2,
                ScrollBarImageColor3 = Theme.GoldDark,
                BorderSizePixel = 0,
                Parent = DropdownFrame
            }, {
                Utility:Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2)})
            })

            local function Refresh()
                for _, child in pairs(ListContainer:GetChildren()) do
                    if child:IsA("TextButton") then child:Destroy() end
                end
                
                local count = 0
                for _, opt in pairs(Options) do
                    count = count + 1
                    local optBtn = Utility:Create("TextButton", {
                        Size = UDim2.new(1, -10, 0, ItemHeight),
                        BackgroundColor3 = Theme.BackgroundMain,
                        Text = "  " .. opt,
                        Font = Enum.Font.Gotham,
                        TextSize = 13,
                        TextColor3 = Theme.TextMuted,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        AutoButtonColor = false,
                        Parent = ListContainer
                    }, { Utility:Create("UICorner", {CornerRadius = UDim.new(0, 4)}) })
                    
                    if Selected == opt then
                        optBtn.TextColor3 = Theme.GoldHighlight
                        optBtn.BackgroundColor3 = Theme.BackgroundHover
                    end

                    optBtn.MouseEnter:Connect(function()
                        if Selected ~= opt then
                            TweenService:Create(optBtn, Tweens.Hover, {BackgroundColor3 = Theme.BackgroundHover, TextColor3 = Theme.TextMain}):Play()
                        end
                    end)
                    optBtn.MouseLeave:Connect(function()
                        if Selected ~= opt then
                            TweenService:Create(optBtn, Tweens.Hover, {BackgroundColor3 = Theme.BackgroundMain, TextColor3 = Theme.TextMuted}):Play()
                        end
                    end)

                    optBtn.MouseButton1Click:Connect(function()
                        Selected = opt
                        SelectedLabel.Text = opt
                        IsOpen = false
                        TweenService:Create(DropdownFrame, Tweens.Bounce, {Size = UDim2.new(1, 0, 0, 42)}):Play()
                        TweenService:Create(Icon, Tweens.Hover, {Rotation = 0}):Play()
                        Refresh()
                        Callback(opt)
                    end)
                end
                
                ListContainer.CanvasSize = UDim2.new(0, 0, 0, count * (ItemHeight + 2))
                return count
            end
            
            Refresh()

            DropButton.MouseButton1Click:Connect(function()
                IsOpen = not IsOpen
                if IsOpen then
                    local count = #Options
                    local expandHeight = math.clamp(count * (ItemHeight + 2), 0, 150)
                    TweenService:Create(DropdownFrame, Tweens.Bounce, {Size = UDim2.new(1, 0, 0, 42 + expandHeight + 10)}):Play()
                    TweenService:Create(ListContainer, Tweens.Bounce, {Size = UDim2.new(1, -20, 0, expandHeight)}):Play()
                    TweenService:Create(Icon, Tweens.Hover, {Rotation = 180}):Play()
                else
                    TweenService:Create(DropdownFrame, Tweens.Bounce, {Size = UDim2.new(1, 0, 0, 42)}):Play()
                    TweenService:Create(Icon, Tweens.Hover, {Rotation = 0}):Play()
                end
            end)
            
            local DropAPI = {}
            function DropAPI:Refresh(newOpts)
                Options = newOpts
                Refresh()
            end
            return DropAPI
        end
        
        function TabAPI:CreateColorPicker(params)
            local Name = params.Name or "Color Picker"
            local Default = params.Default or Color3.fromRGB(255, 255, 255)
            local Callback = params.Callback or function() end
            
            local ColorH, ColorS, ColorV = Default:ToHSV()
            local IsOpen = false
            
            local CPFrame = Utility:Create("Frame", {
                Size = UDim2.new(1, 0, 0, 42),
                BackgroundColor3 = Theme.BackgroundTertiary,
                ClipsDescendants = true,
                Parent = TabScroll
            }, {
                Utility:Create("UICorner", {CornerRadius = Theme.CornerRadius}),
                Utility:Create("UIStroke", {Color = Theme.GoldDark, Thickness = 1, Transparency = 0.8})
            })

            local ToggleBtn = Utility:Create("TextButton", {
                Size = UDim2.new(1, 0, 0, 42),
                BackgroundTransparency = 1,
                Text = "",
                Parent = CPFrame
            })
            
            local Title = Utility:Create("TextLabel", {
                Text = Name,
                Font = Enum.Font.GothamSemibold,
                TextSize = 14,
                TextColor3 = Theme.TextMain,
                TextXAlignment = Enum.TextXAlignment.Left,
                Size = UDim2.new(1, -60, 1, 0),
                Position = UDim2.new(0, 15, 0, 0),
                BackgroundTransparency = 1,
                Parent = ToggleBtn
            })

            local DisplayColor = Utility:Create("Frame", {
                Size = UDim2.new(0, 30, 0, 20),
                Position = UDim2.new(1, -45, 0.5, -10),
                BackgroundColor3 = Default,
                Parent = ToggleBtn
            }, {
                Utility:Create("UICorner", {CornerRadius = UDim.new(0, 4)}),
                Utility:Create("UIStroke", {Color = Theme.GoldDark, Thickness = 1})
            })
            
            local PickerArea = Utility:Create("Frame", {
                Size = UDim2.new(1, -20, 0, 150),
                Position = UDim2.new(0, 10, 0, 50),
                BackgroundTransparency = 1,
                Parent = CPFrame
            })
            
            local SatValMap = Utility:Create("TextButton", {
                Size = UDim2.new(1, -30, 1, 0),
                BackgroundColor3 = Color3.fromHSV(ColorH, 1, 1),
                Text = "",
                AutoButtonColor = false,
                Parent = PickerArea
            }, { Utility:Create("UICorner", {CornerRadius = UDim.new(0, 4)}) })
            
            Utility:Create("UIGradient", {
                Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.new(1,1,1)), ColorSequenceKeypoint.new(1, Color3.new(1,1,1))}),
                Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)}),
                Parent = SatValMap
            })
            Utility:Create("Frame", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundColor3 = Color3.new(0,0,0),
                ZIndex = 2,
                Parent = SatValMap
            }, {
                Utility:Create("UIGradient", {
                    Rotation = 90,
                    Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0)})
                }),
                Utility:Create("UICorner", {CornerRadius = UDim.new(0, 4)})
            })
            
            local SV_Ring = Utility:Create("Frame", {
                Size = UDim2.new(0, 12, 0, 12),
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(ColorS, 0, 1 - ColorV, 0),
                BackgroundColor3 = Color3.new(1,1,1),
                ZIndex = 3,
                Parent = SatValMap
            }, {
                Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
                Utility:Create("UIStroke", {Color = Color3.new(0,0,0), Thickness = 1})
            })
            
            local HueBar = Utility:Create("TextButton", {
                Size = UDim2.new(0, 20, 1, 0),
                Position = UDim2.new(1, -20, 0, 0),
                BackgroundColor3 = Color3.new(1,1,1),
                Text = "",
                AutoButtonColor = false,
                Parent = PickerArea
            }, {
                Utility:Create("UICorner", {CornerRadius = UDim.new(0, 4)}),
                Utility:Create("UIGradient", {
                    Rotation = 90,
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)),
                        ColorSequenceKeypoint.new(0.16, Color3.fromRGB(255,255,0)),
                        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0,255,0)),
                        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,255,255)),
                        ColorSequenceKeypoint.new(0.66, Color3.fromRGB(0,0,255)),
                        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255,0,255)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,0))
                    })
                })
            })
            
            local Hue_Slide = Utility:Create("Frame", {
                Size = UDim2.new(1, 4, 0, 6),
                Position = UDim2.new(0.5, 0, ColorH, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Color3.new(1,1,1),
                Parent = HueBar
            }, {
                Utility:Create("UICorner", {CornerRadius = UDim.new(0, 2)}),
                Utility:Create("UIStroke", {Color = Color3.new(0,0,0), Thickness = 1})
            })
            
            local function UpdateColor()
                local realColor = Color3.fromHSV(ColorH, ColorS, ColorV)
                DisplayColor.BackgroundColor3 = realColor
                SatValMap.BackgroundColor3 = Color3.fromHSV(ColorH, 1, 1)
                Callback(realColor)
            end
            
            local SVDrugging, HDrugging = false, false
            
            SatValMap.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    SVDrugging = true
                    ColorS = math.clamp(inp.Position.X - SatValMap.AbsolutePosition.X, 0, SatValMap.AbsoluteSize.X) / SatValMap.AbsoluteSize.X
                    ColorV = 1 - (math.clamp(inp.Position.Y - SatValMap.AbsolutePosition.Y, 0, SatValMap.AbsoluteSize.Y) / SatValMap.AbsoluteSize.Y)
                    SV_Ring.Position = UDim2.new(ColorS, 0, 1 - ColorV, 0)
                    UpdateColor()
                end
            end)
            
            HueBar.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    HDrugging = true
                    ColorH = 1 - (math.clamp(inp.Position.Y - HueBar.AbsolutePosition.Y, 0, HueBar.AbsoluteSize.Y) / HueBar.AbsoluteSize.Y)
                    Hue_Slide.Position = UDim2.new(0.5, 0, 1 - ColorH, 0)
                    UpdateColor()
                end
            end)
            
            UserInputService.InputChanged:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseMovement then
                    if SVDrugging then
                        ColorS = math.clamp(inp.Position.X - SatValMap.AbsolutePosition.X, 0, SatValMap.AbsoluteSize.X) / SatValMap.AbsoluteSize.X
                        ColorV = 1 - (math.clamp(inp.Position.Y - SatValMap.AbsolutePosition.Y, 0, SatValMap.AbsoluteSize.Y) / SatValMap.AbsoluteSize.Y)
                        SV_Ring.Position = UDim2.new(ColorS, 0, 1 - ColorV, 0)
                        UpdateColor()
                    end
                    if HDrugging then
                        ColorH = 1 - (math.clamp(inp.Position.Y - HueBar.AbsolutePosition.Y, 0, HueBar.AbsoluteSize.Y) / HueBar.AbsoluteSize.Y)
                        Hue_Slide.Position = UDim2.new(0.5, 0, 1 - ColorH, 0)
                        UpdateColor()
                    end
                end
            end)
            
            UserInputService.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    SVDrugging, HDrugging = false, false
                end
            end)
            
            ToggleBtn.MouseButton1Click:Connect(function()
                IsOpen = not IsOpen
                TweenService:Create(CPFrame, Tweens.Bounce, {
                    Size = IsOpen and UDim2.new(1, 0, 0, 210) or UDim2.new(1, 0, 0, 42)
                }):Play()
            end)
        end

        return TabAPI
    end

    --========================================================
    -- 9. NOTIFICATION SYSTEM
    --========================================================

    function WindowAPI:Notify(params)
        local Title = params.Title or "Notification"
        local Content = params.Content or ""
        local Duration = params.Duration or 3

        local NotifFrame = Utility:Create("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundColor3 = Theme.BackgroundSecondary,
            BackgroundTransparency = 1,
            ClipsDescendants = true,
            Parent = NotifContainer
        }, {
            Utility:Create("UICorner", {CornerRadius = Theme.CornerRadius}),
            Utility:Create("UIStroke", {Color = Theme.GoldBase, Thickness = 1, Transparency = 1})
        })

        local Glow = Effects:CreateGlow(NotifFrame, Theme.GoldShadow, 1, UDim2.new(1, 30, 1, 30))

        local TitleLbl = Utility:Create("TextLabel", {
            Text = Title,
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            TextColor3 = Theme.GoldHighlight,
            TextXAlignment = Enum.TextXAlignment.Left,
            Size = UDim2.new(1, -20, 0, 25),
            Position = UDim2.new(0, 10, 0, 5),
            BackgroundTransparency = 1,
            TextTransparency = 1,
            Parent = NotifFrame
        })

        local DescLbl = Utility:Create("TextLabel", {
            Text = Content,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextColor3 = Theme.TextMain,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            Size = UDim2.new(1, -20, 0, 40),
            Position = UDim2.new(0, 10, 0, 30),
            BackgroundTransparency = 1,
            TextTransparency = 1,
            Parent = NotifFrame
        })
        
        local Line = Utility:Create("Frame", {
            Size = UDim2.new(0, 0, 0, 2),
            Position = UDim2.new(0, 0, 1, -2),
            BackgroundColor3 = Theme.GoldBase,
            BorderSizePixel = 0,
            Parent = NotifFrame
        })
        Effects:ApplyGradient(Line, Theme.GoldHighlight, Theme.GoldDark, 0)

        local textHeight = TextService:GetTextSize(Content, 12, Enum.Font.Gotham, Vector2.new(280, math.huge)).Y
        local targetHeight = math.max(70, textHeight + 40)

        TweenService:Create(NotifFrame, Tweens.Bounce, {Size = UDim2.new(1, 0, 0, targetHeight), BackgroundTransparency = 0.05}):Play()
        TweenService:Create(NotifFrame.UIStroke, Tweens.Slower, {Transparency = 0.3}):Play()
        TweenService:Create(Glow, Tweens.Slower, {ImageTransparency = 0.5}):Play()
        task.wait(0.2)
        TweenService:Create(TitleLbl, Tweens.Hover, {TextTransparency = 0}):Play()
        TweenService:Create(DescLbl, Tweens.Hover, {TextTransparency = 0}):Play()
        
        TweenService:Create(Line, TweenInfo.new(Duration, Enum.EasingStyle.Linear), {Size = UDim2.new(1, 0, 0, 2)}):Play()

        task.delay(Duration, function()
            TweenService:Create(TitleLbl, Tweens.Hover, {TextTransparency = 1}):Play()
            TweenService:Create(DescLbl, Tweens.Hover, {TextTransparency = 1}):Play()
            TweenService:Create(NotifFrame.UIStroke, Tweens.Hover, {Transparency = 1}):Play()
            TweenService:Create(Glow, Tweens.Hover, {ImageTransparency = 1}):Play()
            TweenService:Create(Line, Tweens.Hover, {BackgroundTransparency = 1}):Play()
            task.wait(0.2)
            local exitTween = TweenService:Create(NotifFrame, Tweens.Slower, {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1})
            exitTween:Play()
            task.delay(0.4, function()
                if NotifFrame then NotifFrame:Destroy() end
            end)
        end)
    end

    return WindowAPI
end

return SamsHub
