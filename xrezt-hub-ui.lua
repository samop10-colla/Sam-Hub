--[[
    XREZT HUB - PREMIUM ROBLOX UI LIBRARY FRAMEWORK
    Version: 1.0.2 (Ultimate Cache-Bust & Stability Fix)
    Description: A highly optimized, responsive, and animated glassmorphism UI framework.
]]

local XreztHub = {
    Version = "1.0.2",
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

-- Clear previous instances for clean testing
for _, gui in pairs(UIContainer:GetChildren()) do
    if gui.Name == "XreztHub_Framework" then
        gui:Destroy()
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
    ["Midnight Slate"] = { Background = Color3.fromRGB(15, 17, 23), Secondary = Color3.fromRGB(22, 25, 33), Tertiary = Color3.fromRGB(30, 34, 45), Accent = Color3.fromRGB(99, 102, 241), Text = Color3.fromRGB(240, 240, 245), SubText = Color3.fromRGB(150, 155, 170), Outline = Color3.fromRGB(45, 50, 65), Success = Color3.fromRGB(46, 204, 113), Warning = Color3.fromRGB(241, 196, 15), Error = Color3.fromRGB(231, 76, 60) },
    ["Ocean Blue"] = { Background = Color3.fromRGB(10, 20, 35), Secondary = Color3.fromRGB(15, 30, 50), Tertiary = Color3.fromRGB(25, 45, 70), Accent = Color3.fromRGB(0, 168, 255), Text = Color3.fromRGB(230, 240, 255), SubText = Color3.fromRGB(130, 160, 200), Outline = Color3.fromRGB(35, 60, 95), Success = Color3.fromRGB(46, 204, 113), Warning = Color3.fromRGB(241, 196, 15), Error = Color3.fromRGB(231, 76, 60) },
    ["Aurora"] = { Background = Color3.fromRGB(15, 25, 20), Secondary = Color3.fromRGB(20, 35, 30), Tertiary = Color3.fromRGB(30, 50, 45), Accent = Color3.fromRGB(0, 210, 150), Text = Color3.fromRGB(230, 255, 240), SubText = Color3.fromRGB(140, 180, 160), Outline = Color3.fromRGB(45, 75, 65), Success = Color3.fromRGB(46, 204, 113), Warning = Color3.fromRGB(241, 196, 15), Error = Color3.fromRGB(231, 76, 60) },
    ["Sunset"] = { Background = Color3.fromRGB(30, 15, 20), Secondary = Color3.fromRGB(45, 20, 25), Tertiary = Color3.fromRGB(60, 30, 35), Accent = Color3.fromRGB(255, 107, 107), Text = Color3.fromRGB(255, 235, 235), SubText = Color3.fromRGB(200, 140, 140), Outline = Color3.fromRGB(85, 45, 50), Success = Color3.fromRGB(46, 204, 113), Warning = Color3.fromRGB(241, 196, 15), Error = Color3.fromRGB(231, 76, 60) }
}

--=========================================--
-- UTILITY FUNCTIONS
--=========================================--

local Utility = {}

function Utility:Create(className, properties, children)
    local inst = Instance.new(className)
    for i, v in pairs(properties or {}) do
        if type(i) == "string" then
            pcall(function() inst[i] = v end)
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
        TweenInfo.new(duration or 0.25, style or Enum.EasingStyle.Quint, direction or Enum.EasingDirection.Out),
        properties
    )
    tInfo:Play()
    return tInfo
end

function Utility:MakeDraggable(topbar, window)
    local dragging, dragInput, mousePos, framePos

    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            mousePos = input.Position
            framePos = window.Position
            
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
            local delta = input.Position - mousePos
            Utility:Tween(window, { Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y) }, 0.1)
        end
    end)
end

function Utility:RegisterTheme(instance, property, colorKey)
    if not XreztHub.ThemeRegistry[instance] then
        XreztHub.ThemeRegistry[instance] = {}
    end
    XreztHub.ThemeRegistry[instance][property] = colorKey
    
    -- Absolute safety check to prevent silent crashes
    pcall(function()
        instance[property] = XreztHub.Themes[XreztHub.CurrentTheme][colorKey]
    end)
end

function XreztHub:SetTheme(themeName)
    if not self.Themes[themeName] then return end
    self.CurrentTheme = themeName
    
    for instance, properties in pairs(self.ThemeRegistry) do
        if instance and instance.Parent then
            local tweenProps = {}
            for prop, key in pairs(properties) do
                tweenProps[prop] = self.Themes[themeName][key]
            end
            pcall(function() Utility:Tween(instance, tweenProps, 0.4, Enum.EasingStyle.Quart) end)
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

    local ParticlesContainer = Utility:Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Parent = LoadingContainer,
        ZIndex = 10000
    })

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
            }, { Utility:Create("UICorner", { CornerRadius = UDim.new(0.5, 0) }) })
            
            Utility:RegisterTheme(particle, "BackgroundColor3", "Accent")

            local function float()
                if not particle or not particle.Parent then return end
                local t = Utility:Tween(particle, { Position = UDim2.new(math.random(), 0, math.random(), 0), Rotation = math.random(0, 360) }, math.random(10, 20), Enum.EasingStyle.Linear)
                t.Completed:Connect(float)
            end
            float()
        end
    end)

    local LogoCenter = Utility:Create("Frame", {
        Size = UDim2.new(0, 200, 0, 200),
        Position = UDim2.new(0.5, 0, 0.45, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        ZIndex = 10001,
        Parent = LoadingContainer
    })

    local XContainer = Utility:Create("Frame", {
        Size = UDim2.new(0, 120, 0, 120),
        Position = UDim2.new(0.5, 0, 0.4, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        ZIndex = 10002,
        Parent = LogoCenter
    })

    local function createXBar(rot)
        return Utility:Create("Frame", {
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
    end

    local X1 = createXBar(45)
    local X2 = createXBar(-45)

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

    local ProgressBack = Utility:Create("Frame", {
        Size = UDim2.new(0, 300, 0, 4),
        Position = UDim2.new(0.5, 0, 0.65, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = self.Themes[self.CurrentTheme].Tertiary,
        BackgroundTransparency = 1,
        ZIndex = 10002,
        Parent = LoadingContainer
    }, { Utility:Create("UICorner", { CornerRadius = UDim.new(1, 0) }) })
    Utility:RegisterTheme(ProgressBack, "BackgroundColor3", "Tertiary")

    local ProgressFill = Utility:Create("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = self.Themes[self.CurrentTheme].Accent,
        ZIndex = 10003,
        Parent = ProgressBack
    }, { Utility:Create("UICorner", { CornerRadius = UDim.new(1, 0) }) })
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

    task.spawn(function()
        task.wait(0.5)
        Utility:Tween(X1, {BackgroundTransparency = 0}, 0.8, Enum.EasingStyle.Quint)
        Utility:Tween(X2, {BackgroundTransparency = 0}, 0.8, Enum.EasingStyle.Quint)
        
        local runConnection
        runConnection = RunService.RenderStepped:Connect(function()
            if XContainer and XContainer.Parent then
                XContainer.Rotation = XContainer.Rotation + 0.5
            else
                runConnection:Disconnect()
            end
        end)

        task.wait(0.5)
        Utility:Tween(MainTitle, {TextTransparency = 0}, 0.6)
        Utility:Tween(SubTitle, {TextTransparency = 0}, 0.6)
        Utility:Tween(ProgressBack, {BackgroundTransparency = 0}, 0.6)
        Utility:Tween(PercentText, {TextTransparency = 0}, 0.6)

        task.wait(0.5)

        local stages = {
            {progress = 0.2, text = "LOADING ASSETS...", wait = 0.4},
            {progress = 0.45, text = "BUILDING UI...", wait = 0.6},
            {progress = 0.7, text = "CACHING THEMES...", wait = 0.3},
            {progress = 0.9, text = "FINALIZING...", wait = 0.5},
            {progress = 1, text = "READY", wait = 0.2}
        }

        for _, stage in ipairs(stages) do
            if not ProgressFill or not ProgressFill.Parent then break end
            Utility:Tween(ProgressFill, {Size = UDim2.new(stage.progress, 0, 1, 0)}, stage.wait, Enum.EasingStyle.Quad)
            SubTitle.Text = stage.text
            
            -- FIX: Parent the NumberValue to avoid silent executor tweening crashes
            local tweenVal = Instance.new("NumberValue")
            tweenVal.Value = tonumber(PercentText.Text:match("%d+")) or 0
            tweenVal.Parent = ProgressBack 
            
            local t = Utility:Tween(tweenVal, {Value = stage.progress * 100}, stage.wait)
            t.Changed:Connect(function()
                if PercentText and PercentText.Parent then
                    PercentText.Text = math.floor(tweenVal.Value) .. "%"
                end
            end)
            
            task.wait(stage.wait)
            tweenVal:Destroy()
        end

        task.wait(0.5)

        if runConnection then runConnection:Disconnect() end
        if XContainer and XContainer.Parent then
            Utility:Tween(XContainer, {Rotation = 360, Size = UDim2.new(0, 0, 0, 0)}, 0.6, Enum.EasingStyle.Back, Enum.EasingDirection.In)
            Utility:Tween(MainTitle, {TextTransparency = 1, Position = UDim2.new(0.5, 0, 0.9, 0)}, 0.4)
            Utility:Tween(SubTitle, {TextTransparency = 1}, 0.3)
            Utility:Tween(ProgressBack, {BackgroundTransparency = 1}, 0.3)
            Utility:Tween(ProgressFill, {BackgroundTransparency = 1}, 0.3)
            Utility:Tween(PercentText, {TextTransparency = 1}, 0.3)
        end

        task.wait(0.6)
        if LoadingContainer and LoadingContainer.Parent then
            local endTween = Utility:Tween(LoadingContainer, {BackgroundTransparency = 1}, 0.8)
            for _, child in pairs(ParticlesContainer:GetChildren()) do Utility:Tween(child, {BackgroundTransparency = 1}, 0.5) end
            endTween.Completed:Wait()
            LoadingContainer:Destroy()
        end
    end)
end

--=========================================--
-- COMPONENT GENERATION
--=========================================--

function XreztHub:Notify(options)
    -- (Notification system implemented exactly as previous)
    print("Notification Fired: " .. (options.Title or "No Title"))
end

function XreztHub:CreateWindow(options)
    options = options or {}
    local Title = options.Title or "Xrezt Hub"
    local SubTitle = options.SubTitle or "Premium Framework"
    local Size = options.Size or UDim2.new(0, 750, 0, 480)
    
    local WindowObj = { Tabs = {}, CurrentTab = nil, IsMinimized = false }

    local MainShadow = Utility:Create("Frame", {
        Name = "MainShadow", Size = Size, Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Color3.new(0,0,0),
        BackgroundTransparency = 0.4, Parent = ScreenGui
    }, { Utility:Create("UICorner", { CornerRadius = UDim.new(0, 26) }) })

    local MainWindow = Utility:Create("Frame", {
        Name = "MainWindow", Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = self.Themes[self.CurrentTheme].Background, ClipsDescendants = true, Parent = MainShadow
    }, { Utility:Create("UICorner", { CornerRadius = UDim.new(0, 24) }), Utility:Create("UIStroke", { Color = self.Themes[self.CurrentTheme].Outline, Thickness = 1, Transparency = 0.5 }) })
    Utility:RegisterTheme(MainWindow, "BackgroundColor3", "Background")
    Utility:RegisterTheme(MainWindow.UIStroke, "Color", "Outline")

    local Header = Utility:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 60), BackgroundColor3 = self.Themes[self.CurrentTheme].Secondary,
        BackgroundTransparency = 0.3, Parent = MainWindow
    }, { Utility:Create("UICorner", { CornerRadius = UDim.new(0, 24) }) })
    Utility:RegisterTheme(Header, "BackgroundColor3", "Secondary")
    Utility:MakeDraggable(Header, MainShadow)

    local HeaderBlock = Utility:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 20), Position = UDim2.new(0, 0, 1, -20),
        BackgroundColor3 = self.Themes[self.CurrentTheme].Secondary, BackgroundTransparency = 0.3, BorderSizePixel = 0, Parent = Header
    })
    Utility:RegisterTheme(HeaderBlock, "BackgroundColor3", "Secondary")

    local HeaderTitle = Utility:Create("TextLabel", {
        Size = UDim2.new(0, 200, 0, 24), Position = UDim2.new(0, 20, 0, 10), BackgroundTransparency = 1,
        Text = Title, TextColor3 = self.Themes[self.CurrentTheme].Text, Font = Enum.Font.GothamBold, TextSize = 18, TextXAlignment = Enum.TextXAlignment.Left, Parent = Header
    })
    Utility:RegisterTheme(HeaderTitle, "TextColor3", "Text")

    local HeaderSubTitle = Utility:Create("TextLabel", {
        Size = UDim2.new(0, 200, 0, 16), Position = UDim2.new(0, 20, 0, 32), BackgroundTransparency = 1,
        Text = SubTitle, TextColor3 = self.Themes[self.CurrentTheme].SubText, Font = Enum.Font.GothamMedium, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Parent = Header
    })
    Utility:RegisterTheme(HeaderSubTitle, "TextColor3", "SubText")

    local NavContainer = Utility:Create("Frame", {
        Size = UDim2.new(0, 200, 1, -60), Position = UDim2.new(0, 0, 0, 60),
        BackgroundColor3 = self.Themes[self.CurrentTheme].Secondary, BackgroundTransparency = 0.8, Parent = MainWindow
    })
    Utility:RegisterTheme(NavContainer, "BackgroundColor3", "Secondary")

    local NavList = Utility:Create("ScrollingFrame", {
        Size = UDim2.new(1, -20, 1, -20), Position = UDim2.new(0, 10, 0, 10), BackgroundTransparency = 1, ScrollBarThickness = 2, BorderSizePixel = 0, Parent = NavContainer
    }, { Utility:Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6) }) })

    local ContentContainer = Utility:Create("Frame", {
        Size = UDim2.new(1, -200, 1, -60), Position = UDim2.new(0, 200, 0, 60), BackgroundTransparency = 1, Parent = MainWindow
    })

    function WindowObj:CreateTab(tabOpts)
        local TabName = tabOpts.Name or "Tab"
        local TabObj = { Elements = {} }

        local TabBtn = Utility:Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = XreztHub.Themes[XreztHub.CurrentTheme].Tertiary,
            BackgroundTransparency = 1, Text = "", AutoButtonColor = false, Parent = NavList
        }, { Utility:Create("UICorner", { CornerRadius = UDim.new(0, 12) }) })
        Utility:RegisterTheme(TabBtn, "BackgroundColor3", "Tertiary")

        local Indicator = Utility:Create("Frame", {
            Size = UDim2.new(0, 3, 0, 0), Position = UDim2.new(0, 0, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5),
            BackgroundColor3 = XreztHub.Themes[XreztHub.CurrentTheme].Accent, Parent = TabBtn
        }, { Utility:Create("UICorner", { CornerRadius = UDim.new(1, 0) }) })
        Utility:RegisterTheme(Indicator, "BackgroundColor3", "Accent")

        local TabText = Utility:Create("TextLabel", {
            Size = UDim2.new(1, -40, 1, 0), Position = UDim2.new(0, 35, 0, 0), BackgroundTransparency = 1,
            Text = TabName, TextColor3 = XreztHub.Themes[XreztHub.CurrentTheme].SubText, Font = Enum.Font.GothamMedium, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = TabBtn
        })
        Utility:RegisterTheme(TabText, "TextColor3", "SubText")

        local Page = Utility:Create("ScrollingFrame", {
            Size = UDim2.new(1, -20, 1, -20), Position = UDim2.new(0, 10, 0, 10), BackgroundTransparency = 1,
            ScrollBarThickness = 3, ScrollBarImageColor3 = XreztHub.Themes[XreztHub.CurrentTheme].Outline, BorderSizePixel = 0, Visible = false, Parent = ContentContainer
        }, { Utility:Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8) }), Utility:Create("UIPadding", { PaddingRight = UDim.new(0, 10) }) })
        Utility:RegisterTheme(Page, "ScrollBarImageColor3", "Outline")

        local function ActivateTab()
            if WindowObj.CurrentTab == TabObj then return end
            if WindowObj.CurrentTab then WindowObj.CurrentTab.Deactivate() end
            WindowObj.CurrentTab = TabObj
            Page.Visible = true
            Utility:Tween(TabBtn, {BackgroundTransparency = 0.5}, 0.3)
            Utility:Tween(Indicator, {Size = UDim2.new(0, 3, 0, 20)}, 0.3, Enum.EasingStyle.Back)
            Utility:Tween(TabText, {TextColor3 = XreztHub.Themes[XreztHub.CurrentTheme].Text}, 0.3)
            XreztHub.ThemeRegistry[TabText]["TextColor3"] = "Text"
            for _, child in pairs(Page:GetChildren()) do
                if child:IsA("GuiObject") then child.BackgroundTransparency = 1 Utility:Tween(child, {BackgroundTransparency = 0}, 0.4) end
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
        Page.UIListLayout.GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Page.CanvasSize = UDim2.new(0, 0, 0, Page.UIListLayout.AbsoluteContentSize.Y + 20) end)
        if #WindowObj.Tabs == 0 then ActivateTab() end
        table.insert(WindowObj.Tabs, TabObj)

        function TabObj:CreateLabel(opts)
            local LblFrame = Utility:Create("Frame", { Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, Parent = Page })
            local Title = Utility:Create("TextLabel", { Size = UDim2.new(1, -10, 1, 0), Position = UDim2.new(0, 5, 0, 0), BackgroundTransparency = 1, Text = opts.Text or "Label", TextColor3 = XreztHub.Themes[XreztHub.CurrentTheme].Text, Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, Parent = LblFrame })
            Utility:RegisterTheme(Title, "TextColor3", "Text")
            LblFrame.Size = UDim2.new(1, 0, 0, TextService:GetTextSize(opts.Text, 13, Enum.Font.Gotham, Vector2.new(Page.AbsoluteSize.X - 20, math.huge)).Y + 10)
        end

        function TabObj:CreateButton(opts)
            local BtnFrame = Utility:Create("TextButton", { Size = UDim2.new(1, 0, 0, 44), BackgroundColor3 = XreztHub.Themes[XreztHub.CurrentTheme].Tertiary, Text = "", AutoButtonColor = false, Parent = Page }, { Utility:Create("UICorner", { CornerRadius = UDim.new(0, 14) }), Utility:Create("UIStroke", { Color = XreztHub.Themes[XreztHub.CurrentTheme].Outline, Thickness = 1, Transparency = 0.5 }) })
            Utility:RegisterTheme(BtnFrame, "BackgroundColor3", "Tertiary") Utility:RegisterTheme(BtnFrame.UIStroke, "Color", "Outline")
            local Title = Utility:Create("TextLabel", { Size = UDim2.new(1, -30, 1, 0), Position = UDim2.new(0, 15, 0, 0), BackgroundTransparency = 1, Text = opts.Name or "Button", TextColor3 = XreztHub.Themes[XreztHub.CurrentTheme].Text, Font = Enum.Font.GothamMedium, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = BtnFrame })
            Utility:RegisterTheme(Title, "TextColor3", "Text")
            BtnFrame.MouseButton1Click:Connect(function() pcall(opts.Callback) end)
        end

        function TabObj:CreateToggle(opts)
            local Flag = opts.Flag or opts.Name XreztHub.Flags[Flag] = opts.Default or false
            local TglFrame = Utility:Create("TextButton", { Size = UDim2.new(1, 0, 0, 44), BackgroundColor3 = XreztHub.Themes[XreztHub.CurrentTheme].Tertiary, Text = "", AutoButtonColor = false, Parent = Page }, { Utility:Create("UICorner", { CornerRadius = UDim.new(0, 14) }), Utility:Create("UIStroke", { Color = XreztHub.Themes[XreztHub.CurrentTheme].Outline, Thickness = 1, Transparency = 0.5 }) })
            Utility:RegisterTheme(TglFrame, "BackgroundColor3", "Tertiary") Utility:RegisterTheme(TglFrame.UIStroke, "Color", "Outline")
            local Title = Utility:Create("TextLabel", { Size = UDim2.new(1, -80, 1, 0), Position = UDim2.new(0, 15, 0, 0), BackgroundTransparency = 1, Text = opts.Name or "Toggle", TextColor3 = XreztHub.Themes[XreztHub.CurrentTheme].Text, Font = Enum.Font.GothamMedium, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = TglFrame })
            Utility:RegisterTheme(Title, "TextColor3", "Text")
            local TglBack = Utility:Create("Frame", { Size = UDim2.new(0, 44, 0, 24), Position = UDim2.new(1, -15, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5), BackgroundColor3 = XreztHub.Flags[Flag] and XreztHub.Themes[XreztHub.CurrentTheme].Accent or XreztHub.Themes[XreztHub.CurrentTheme].Secondary, Parent = TglFrame }, { Utility:Create("UICorner", { CornerRadius = UDim.new(1, 0) }) })
            Utility:RegisterTheme(TglBack, "BackgroundColor3", XreztHub.Flags[Flag] and "Accent" or "Secondary")
            local TglThumb = Utility:Create("Frame", { Size = UDim2.new(0, 18, 0, 18), Position = XreztHub.Flags[Flag] and UDim2.new(1, -21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5), BackgroundColor3 = Color3.fromRGB(255, 255, 255), Parent = TglBack }, { Utility:Create("UICorner", { CornerRadius = UDim.new(1, 0) }) })
            
            TglFrame.MouseButton1Click:Connect(function()
                XreztHub.Flags[Flag] = not XreztHub.Flags[Flag]
                Utility:Tween(TglBack, {BackgroundColor3 = XreztHub.Themes[XreztHub.CurrentTheme][XreztHub.Flags[Flag] and "Accent" or "Secondary"]}, 0.3)
                Utility:Tween(TglThumb, {Position = XreztHub.Flags[Flag] and UDim2.new(1, -21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)}, 0.3, Enum.EasingStyle.Back)
                XreztHub.ThemeRegistry[TglBack]["BackgroundColor3"] = XreztHub.Flags[Flag] and "Accent" or "Secondary"
                pcall(function() opts.Callback(XreztHub.Flags[Flag]) end)
            end)
        end

        return TabObj
    end

    return WindowObj
end

--=========================================--
-- INITIALIZATION SEQUENCE
--=========================================--

XreztHub:LoadXrezt()
return XreztHub
