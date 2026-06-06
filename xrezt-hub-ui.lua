-- ============================================================================== --
-- XREZT HUB - THE PREMIUM ROBLOX UI ARCHITECTURE (PATCH V5)
-- Architected exclusively for LO.
-- Fixes: Removed CanvasGroup (Blank Screen Bug Fixed). 
-- Added UIScale for flawless minimizing. Added Progress Bar to Loading Screen.
-- ============================================================================== --

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

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
    }
}

local CurrentThemeName = "Midnight Slate"
local CurrentTheme = Themes[CurrentThemeName]
local ActiveThemeInstances = {}

-- ============================================================================== --
-- UTILITY FUNCTIONS
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

function Utility:RGBToHSV(color)
    local r, g, b = color.R, color.G, color.B
    local max, min = math.max(r, g, b), math.min(r, g, b)
    local h, s, v
    v = max
    local d = max - min
    if max == 0 then s = 0 else s = d / max end
    if max == min then h = 0 else
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
local NotificationsContainer

-- ============================================================================== --
-- LOADING SEQUENCE WITH PROGRESS BAR
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

    local OuterRing = Utility:Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Parent = CenterAnim
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = OuterRing})
    local OuterStroke = Utility:Create("UIStroke", {Color = Color3.fromRGB(255, 255, 255), Thickness = 2, Transparency = 1, Parent = OuterRing})
    local UIGradientOuter = Utility:Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, CurrentTheme.Accent),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(150, 80, 255)),
            ColorSequenceKeypoint.new(1, CurrentTheme.Accent)
        }),
        Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0), NumberSequenceKeypoint.new(1, 1)}),
        Rotation = 0, Parent = OuterRing
    })

    local InnerRing = Utility:Create("Frame", {
        Size = UDim2.new(0.7, 0, 0.7, 0),
        Position = UDim2.new(0.15, 0, 0.15, 0),
        BackgroundTransparency = 1,
        Parent = CenterAnim
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = InnerRing})
    local InnerStroke = Utility:Create("UIStroke", {Color = CurrentTheme.Accent, Thickness = 4, Transparency = 1, Parent = InnerRing})
    local UIGradientInner = Utility:Create("UIGradient", {
        Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.5, 1), NumberSequenceKeypoint.new(1, 0)}),
        Rotation = 0, Parent = InnerRing
    })

    local LoadingText = Utility:Create("TextLabel", {
        Size = UDim2.new(0, 300, 0, 40),
        Position = UDim2.new(0.5, -150, 0.55, 30),
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
        Position = UDim2.new(0.5, -150, 0.55, 70),
        BackgroundTransparency = 1,
        Text = "Architecting User Interface...",
        Font = Enum.Font.GothamMedium,
        TextSize = 14,
        TextColor3 = CurrentTheme.SubText,
        TextTransparency = 1,
        Parent = Background
    })

    -- PROGRESS BAR ADDITION
    local ProgressBg = Utility:Create("Frame", {
        Size = UDim2.new(0, 300, 0, 6),
        Position = UDim2.new(0.5, -150, 0.55, 110),
        BackgroundColor3 = CurrentTheme.Container,
        BackgroundTransparency = 1,
        Parent = Background
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = ProgressBg})
    
    local ProgressFill = Utility:Create("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = CurrentTheme.Accent,
        BackgroundTransparency = 1,
        Parent = ProgressBg
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = ProgressFill})

    -- Start Animations
    Utility:Tween(OuterStroke, {Transparency = 0}, 1)
    Utility:Tween(InnerStroke, {Transparency = 0}, 1)
    Utility:Tween(LoadingText, {TextTransparency = 0, Position = UDim2.new(0.5, -150, 0.55, 20)}, 1, Enum.EasingStyle.Exponential)
    Utility:Tween(SubtitleText, {TextTransparency = 0, Position = UDim2.new(0.5, -150, 0.55, 60)}, 1, Enum.EasingStyle.Exponential)
    Utility:Tween(ProgressBg, {BackgroundTransparency = 0}, 1)
    Utility:Tween(ProgressFill, {BackgroundTransparency = 0}, 1)

    local rot = 0
    local conn = RunService.RenderStepped:Connect(function(dt)
        rot = rot + (dt * 120)
        UIGradientOuter.Rotation = rot
        UIGradientInner.Rotation = -rot * 1.5
    end)

    -- Bar filling logic
    Utility:Tween(ProgressFill, {Size = UDim2.new(0.3, 0, 1, 0)}, 0.5)
    task.wait(0.8)
    SubtitleText.Text = "Compiling Tween Engine..."
    Utility:Tween(ProgressFill, {Size = UDim2.new(0.6, 0, 1, 0)}, 0.5)
    task.wait(0.8)
    SubtitleText.Text = "Applying Aesthetics..."
    Utility:Tween(ProgressFill, {Size = UDim2.new(1, 0, 1, 0)}, 0.5)
    task.wait(0.8)

    -- Fade out
    Utility:Tween(OuterStroke, {Transparency = 1}, 0.5)
    Utility:Tween(InnerStroke, {Transparency = 1}, 0.5)
    Utility:Tween(LoadingText, {TextTransparency = 1}, 0.5)
    Utility:Tween(SubtitleText, {TextTransparency = 1}, 0.5)
    Utility:Tween(ProgressBg, {BackgroundTransparency = 1}, 0.5)
    Utility:Tween(ProgressFill, {BackgroundTransparency = 1}, 0.5)
    
    task.wait(0.5)
    conn:Disconnect()
    Utility:Tween(Background, {BackgroundTransparency = 1}, 0.5).Completed:Wait()
    ScreenGui:Destroy()
end

-- ============================================================================== --
-- WINDOW CREATION (FIXED CANVASGROUP BUG USING UISCALE)
-- ============================================================================== --

function XreztHub:CreateWindow(config)
    config = config or {}
    local Title = config.Title or "Xrezt Hub"
    local Subtitle = config.Subtitle or "Premium Framework"
    local Width = config.Width or 600
    local Height = config.Height or 350

    local MainGui = Utility:Create("ScreenGui", {
        Name = "XreztHub_Workspace",
        ResetOnSpawn = false,
        IgnoreGuiInset = true
    })
    ProtectGUI(MainGui)

    NotificationsContainer = Utility:Create("Frame", {
        Name = "Notifications",
        Size = UDim2.new(0, 320, 1, -40),
        Position = UDim2.new(1, -340, 0, 20),
        BackgroundTransparency = 1,
        ZIndex = 100,
        Parent = MainGui
    })
    Utility:Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 12), VerticalAlignment = Enum.VerticalAlignment.Bottom, Parent = NotificationsContainer})

    -- REPLACED CANVASGROUP WITH STANDARD FRAME
    local MainFrame = Utility:Create("Frame", {
        Name = "MainFrame",
        Size = UDim2.new(0, Width, 0, Height),
        Position = UDim2.new(0.5, -Width/2, 0.5, -Height/2),
        BackgroundColor3 = CurrentTheme.Background,
        ZIndex = 10,
        Parent = MainGui
    })
    Utility:RegisterTheme(MainFrame, "BackgroundColor3", "Background")
    Utility:Create("UICorner", {CornerRadius = UDim.new(0, 16), Parent = MainFrame})
    Utility:Create("UIStroke", {Color = CurrentTheme.Outline, Thickness = 1, Parent = MainFrame})
    Utility:RegisterTheme(MainFrame.UIStroke, "Color", "Outline")
    
    -- THE MAGIC MINIMIZE FIX: UISCALE
    local WindowScale = Utility:Create("UIScale", {
        Scale = 0,
        Parent = MainFrame
    })
    
    -- Animate Window In via Scale
    Utility:Tween(WindowScale, {Scale = 1}, 0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

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

    Utility:Create("TextLabel", {
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

    -- Search Bar
    local SearchFrame = Utility:Create("Frame", {
        Size = UDim2.new(0, 180, 0, 36),
        Position = UDim2.new(1, -200, 0.5, -18),
        BackgroundColor3 = CurrentTheme.Element,
        Parent = Header
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = SearchFrame})
    Utility:RegisterTheme(SearchFrame, "BackgroundColor3", "Element")
    
    local SearchBox = Utility:Create("TextBox", {
        Size = UDim2.new(1, -40, 1, 0),
        Position = UDim2.new(0, 35, 0, 0),
        BackgroundTransparency = 1,
        Text = "",
        PlaceholderText = "Search...",
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextColor3 = CurrentTheme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = SearchFrame
    })

    local TabContainer = Utility:Create("ScrollingFrame", {
        Name = "TabContainer",
        Size = UDim2.new(0, 180, 1, -80),
        Position = UDim2.new(0, 15, 0, 75),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        Parent = MainFrame
    })
    Utility:Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8), Parent = TabContainer})

    local PageContainer = Utility:Create("Frame", {
        Name = "PageContainer",
        Size = UDim2.new(1, -215, 1, -80),
        Position = UDim2.new(0, 205, 0, 75),
        BackgroundTransparency = 1,
        Parent = MainFrame
    })

    -- Launcher Button
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
    Utility:RegisterTheme(SpawnerBtn, "BackgroundColor3", "Container")
    Utility:RegisterTheme(SpawnerBtn, "TextColor3", "Accent")
    Utility:MakeDraggable(SpawnerBtn, SpawnerBtn)

    -- PERFECT MINIMIZE USING UISCALE
    local isVisible = true
    SpawnerBtn.MouseButton1Click:Connect(function()
        isVisible = not isVisible
        Utility:Ripple(SpawnerBtn)
        if isVisible then
            MainFrame.Visible = true
            Utility:Tween(WindowScale, {Scale = 1}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        else
            Utility:Tween(WindowScale, {Scale = 0}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In).Completed:Connect(function()
                MainFrame.Visible = false
            end)
        end
    end)

    local WindowObj = {
        ActiveTab = nil,
        First = true,
        Tabs = {}
    }

    -- TAB SYSTEM
    function WindowObj:CreateTab(tabName)
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

        local TabText = Utility:Create("TextLabel", {
            Size = UDim2.new(1, -30, 1, 0),
            Position = UDim2.new(0, 20, 0, 0),
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
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = CurrentTheme.Outline,
            Visible = false,
            Parent = PageContainer
        })
        Utility:RegisterTheme(Page, "ScrollBarImageColor3", "Outline")
        Utility:Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10), Parent = Page})
        Utility:Create("UIPadding", {PaddingTop = UDim.new(0, 2), PaddingBottom = UDim.new(0, 15), PaddingRight = UDim.new(0, 10), Parent = Page})

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

        local TabObj = {}

        -- BUTTON COMPONENT
        function TabObj:CreateButton(opts)
            local BtnFrame = Utility:Create("TextButton", {
                Size = UDim2.new(1, 0, 0, 45),
                BackgroundColor3 = CurrentTheme.Element,
                Text = "",
                AutoButtonColor = false,
                Parent = Page
            })
            Utility:Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = BtnFrame})
            Utility:Create("UIStroke", {Color = CurrentTheme.Outline, Thickness = 1, Parent = BtnFrame})
            Utility:RegisterTheme(BtnFrame, "BackgroundColor3", "Element")
            
            Utility:Create("TextLabel", {
                Size = UDim2.new(1, -40, 1, 0),
                Position = UDim2.new(0, 15, 0, 0),
                BackgroundTransparency = 1,
                Text = opts.Name or "Button",
                Font = Enum.Font.GothamMedium,
                TextSize = 14,
                TextColor3 = CurrentTheme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = BtnFrame
            })

            BtnFrame.MouseButton1Up:Connect(function()
                Utility:Ripple(BtnFrame)
                if opts.Callback then opts.Callback() end
            end)
        end

        -- TOGGLE COMPONENT
        function TabObj:CreateToggle(opts)
            local state = opts.Default or false
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

            Utility:Create("TextLabel", {
                Size = UDim2.new(1, -70, 1, 0),
                Position = UDim2.new(0, 15, 0, 0),
                BackgroundTransparency = 1,
                Text = opts.Name or "Toggle",
                Font = Enum.Font.GothamMedium,
                TextSize = 14,
                TextColor3 = CurrentTheme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = TogFrame
            })

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

            TogFrame.MouseButton1Click:Connect(function()
                state = not state
                Utility:Ripple(TogFrame)
                Utility:Tween(Switch, {BackgroundColor3 = state and CurrentTheme.Accent or CurrentTheme.Container}, 0.3)
                Utility:Tween(Thumb, {Position = UDim2.new(0, state and 23 or 3, 0.5, -8)}, 0.3, Enum.EasingStyle.Back)
                if opts.Callback then opts.Callback(state) end
            end)
        end

        -- SLIDER COMPONENT
        function TabObj:CreateSlider(opts)
            local min, max, val = opts.Min or 0, opts.Max or 100, opts.Default or opts.Min or 0
            local SldFrame = Utility:Create("Frame", {
                Size = UDim2.new(1, 0, 0, 65),
                BackgroundColor3 = CurrentTheme.Element,
                Parent = Page
            })
            Utility:Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = SldFrame})
            Utility:RegisterTheme(SldFrame, "BackgroundColor3", "Element")

            Utility:Create("TextLabel", {
                Size = UDim2.new(1, -100, 0, 25),
                Position = UDim2.new(0, 15, 0, 10),
                BackgroundTransparency = 1,
                Text = opts.Name or "Slider",
                Font = Enum.Font.GothamMedium,
                TextSize = 14,
                TextColor3 = CurrentTheme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = SldFrame
            })

            local ValueLabel = Utility:Create("TextLabel", {
                Size = UDim2.new(0, 50, 0, 25),
                Position = UDim2.new(1, -65, 0, 10),
                BackgroundTransparency = 1,
                Text = tostring(val),
                Font = Enum.Font.GothamMedium,
                TextSize = 13,
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
                if opts.Callback then opts.Callback(val) end
            end

            Track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    Update(input)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then Update(input) end
            end)
        end

        return TabObj
    end

    return WindowObj
end

XreztHub:Load()
return XreztHub
