--[[
    __   ____               _     _   _       _     
    \ \ / /  _ \ ___  ____ | |_  | | | |_   _| |__  
     \ V /| |_) / _ \_  _ \| __| | |_| | | | | '_ \ 
     / . \|  _ <  __/ /__  \ |_  |  _  | |_| | |_) |
    /_/ \_\_| \_\___|____/  \__| |_| |_|\__,_|_.__/ 
                                                    
    XREZT HUB — PREMIUM ROBLOX UI FRAMEWORK
    Developed by Nyxos for Sam.
    
    [Architecture Features]
    - Fully OOP-driven library.
    - Dragging & edge snapping for both mobile and desktop.
    - Peak performance loading screen with rotating elements and logo fades.
    - Fluid TweenService animations on all interaction states.
    - Responsive layout engines utilizing UIPadding, UICorners, and UIListLayouts.
    - Zero external dependencies. Fully self-contained.
--]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local XreztHub = {}
XreztHub.__index = XreztHub

-- Theme Configuration Table
local Themes = {
    ["Midnight Slate"] = {
        Background = Color3.fromRGB(15, 16, 22),
        Secondary = Color3.fromRGB(24, 26, 37),
        Accent = Color3.fromRGB(99, 102, 241),
        AccentGlow = Color3.fromRGB(129, 140, 248),
        Text = Color3.fromRGB(243, 244, 246),
        TextMuted = Color3.fromRGB(156, 163, 175),
        Border = Color3.fromRGB(37, 40, 58),
        XGradientStart = Color3.fromRGB(99, 102, 241),
        XGradientEnd = Color3.fromRGB(168, 85, 247)
    },
    ["Ocean Blue"] = {
        Background = Color3.fromRGB(10, 17, 30),
        Secondary = Color3.fromRGB(17, 28, 48),
        Accent = Color3.fromRGB(14, 165, 233),
        AccentGlow = Color3.fromRGB(56, 189, 248),
        Text = Color3.fromRGB(241, 245, 249),
        TextMuted = Color3.fromRGB(148, 163, 184),
        Border = Color3.fromRGB(30, 41, 59),
        XGradientStart = Color3.fromRGB(14, 165, 233),
        XGradientEnd = Color3.fromRGB(45, 212, 191)
    },
    ["Aurora"] = {
        Background = Color3.fromRGB(11, 19, 17),
        Secondary = Color3.fromRGB(18, 33, 29),
        Accent = Color3.fromRGB(16, 185, 129),
        AccentGlow = Color3.fromRGB(52, 211, 153),
        Text = Color3.fromRGB(240, 253, 250),
        TextMuted = Color3.fromRGB(115, 115, 115),
        Border = Color3.fromRGB(20, 40, 35),
        XGradientStart = Color3.fromRGB(16, 185, 129),
        XGradientEnd = Color3.fromRGB(234, 179, 8)
    },
    ["Sunset"] = {
        Background = Color3.fromRGB(24, 15, 15),
        Secondary = Color3.fromRGB(38, 22, 22),
        Accent = Color3.fromRGB(239, 68, 68),
        AccentGlow = Color3.fromRGB(248, 113, 113),
        Text = Color3.fromRGB(254, 242, 242),
        TextMuted = Color3.fromRGB(252, 165, 165),
        Border = Color3.fromRGB(54, 29, 29),
        XGradientStart = Color3.fromRGB(239, 68, 68),
        XGradientEnd = Color3.fromRGB(249, 115, 22)
    },
    ["Obsidian"] = {
        Background = Color3.fromRGB(10, 10, 10),
        Secondary = Color3.fromRGB(18, 18, 18),
        Accent = Color3.fromRGB(255, 255, 255),
        AccentGlow = Color3.fromRGB(200, 200, 200),
        Text = Color3.fromRGB(255, 255, 255),
        TextMuted = Color3.fromRGB(140, 140, 140),
        Border = Color3.fromRGB(28, 28, 28),
        XGradientStart = Color3.fromRGB(100, 100, 100),
        XGradientEnd = Color3.fromRGB(200, 200, 200)
    }
}

-- Utility Functions
local function CreateInstance(className, properties)
    local instance = Instance.new(className)
    for property, value in pairs(properties) do
        instance[property] = value
    end
    return instance
end

local function ApplyGradient(instance, colorSequence, rotation)
    local gradient = CreateInstance("UIGradient", {
        Color = colorSequence,
        Rotation = rotation or 0,
        Parent = instance
    })
    return gradient
end

local function AddCorner(instance, radius)
    local corner = CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, radius),
        Parent = instance
    })
    return corner
end

local function ApplyShadow(instance)
    local shadow = CreateInstance("ImageLabel", {
        Name = "Shadow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, 40, 1, 40),
        Image = "rbxassetid://6015897843",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.6,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        ZIndex = instance.ZIndex - 1,
        Parent = instance
    })
    return shadow
end

-- Make Frame Draggable and Responsive
local function MakeDraggable(dragFrame, targetFrame)
    local dragging = false
    local dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        local targetPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        TweenService:Create(targetFrame, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = targetPos}):Play()
    end

    dragFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = targetFrame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

-- Screen edge snapping behavior for launcher button
local function SnapToScreenEdges(button, parentScreen)
    button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local screenWidth = parentScreen.AbsoluteSize.X
            local screenHeight = parentScreen.AbsoluteSize.Y
            local btnX = button.AbsolutePosition.X + (button.AbsoluteSize.X / 2)
            local btnY = button.AbsolutePosition.Y + (button.AbsoluteSize.Y / 2)
            
            local targetX = button.Position.X.Offset
            local targetY = math.clamp(button.Position.Y.Offset, 20, screenHeight - button.AbsoluteSize.Y - 20)
            
            if btnX < screenWidth / 2 then
                targetX = 20
            else
                targetX = screenWidth - button.AbsoluteSize.X - 20
            end
            
            local snapTween = TweenService:Create(button, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Position = UDim2.new(0, targetX, 0, targetY)
            })
            snapTween:Play()
        end
    end)
end

-- Create Screen Object
function XreztHub.Init(customTheme)
    local self = setmetatable({}, XreztHub)
    self.Theme = Themes[customTheme] or Themes["Midnight Slate"]
    
    -- Main Screen GUI Setup
    local parentFolder = CoreGui:FindFirstChild("RobloxGui") or PlayerGui
    self.ScreenGui = CreateInstance("ScreenGui", {
        Name = "XreztHub_Screen",
        ResetOnSpawn = false,
        DisplayOrder = 999,
        Parent = parentFolder
    })
    
    self.Notifications = {}
    self.ActiveWindow = nil
    
    return self
end

-- Peak Loading Screen
function XreztHub:ShowLoadingScreen(title, subtitle, duration)
    local loadingFrame = CreateInstance("Frame", {
        Name = "LoadingFrame",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = self.Theme.Background,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        ZIndex = 100,
        Parent = self.ScreenGui
    })
    
    -- Blur background
    local blurEffect = CreateInstance("BlurEffect", {
        Size = 24,
        Parent = game:GetService("Lighting")
    })
    
    -- Elegant geometric decorative X elements
    local xLeftBranch = CreateInstance("Frame", {
        Name = "XLeftBranch",
        Size = UDim2.new(0, 12, 0, 300),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Rotation = 45,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.85,
        BorderSizePixel = 0,
        ZIndex = 101,
        Parent = loadingFrame
    })
    AddCorner(xLeftBranch, 6)
    ApplyGradient(xLeftBranch, ColorSequence.new(self.Theme.XGradientStart, self.Theme.XGradientEnd))
    
    local xRightBranch = CreateInstance("Frame", {
        Name = "XRightBranch",
        Size = UDim2.new(0, 12, 0, 300),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Rotation = -45,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.85,
        BorderSizePixel = 0,
        ZIndex = 101,
        Parent = loadingFrame
    })
    AddCorner(xRightBranch, 6)
    ApplyGradient(xRightBranch, ColorSequence.new(self.Theme.XGradientStart, self.Theme.XGradientEnd))
    
    -- Main Brand Container
    local container = CreateInstance("Frame", {
        Name = "BrandContainer",
        Size = UDim2.new(0, 400, 0, 300),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundTransparency = 1,
        ZIndex = 102,
        Parent = loadingFrame
    })
    
    local logo = CreateInstance("TextLabel", {
        Name = "LogoText",
        Size = UDim2.new(1, 0, 0, 50),
        Position = UDim2.new(0, 0, 0.15, 0),
        BackgroundTransparency = 1,
        Text = title or "XREZT HUB",
        TextColor3 = self.Theme.Text,
        TextSize = 36,
        Font = Enum.Font.GothamBold,
        TextTransparency = 1,
        ZIndex = 103,
        Parent = container
    })
    
    local subText = CreateInstance("TextLabel", {
        Name = "SubText",
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0, 0, 0.32, 0),
        BackgroundTransparency = 1,
        Text = subtitle or "THE NEXT-GEN SYSTEM ARCHITECTURE",
        TextColor3 = self.Theme.Accent,
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        TextTransparency = 1,
        ZIndex = 103,
        Parent = container
    })
    
    -- Progress Bar Assets
    local progressBackground = CreateInstance("Frame", {
        Name = "ProgressBg",
        Size = UDim2.new(0, 280, 0, 6),
        Position = UDim2.new(0.5, -140, 0.65, 0),
        BackgroundColor3 = self.Theme.Secondary,
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        ZIndex = 103,
        Parent = container
    })
    AddCorner(progressBackground, 3)
    
    local progressBar = CreateInstance("Frame", {
        Name = "ProgressBar",
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = self.Theme.Accent,
        BorderSizePixel = 0,
        ZIndex = 104,
        Parent = progressBackground
    })
    AddCorner(progressBar, 3)
    ApplyGradient(progressBar, ColorSequence.new(self.Theme.XGradientStart, self.Theme.XGradientEnd))
    
    local percentText = CreateInstance("TextLabel", {
        Name = "PercentText",
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0.75, 0),
        BackgroundTransparency = 1,
        Text = "0%",
        TextColor3 = self.Theme.TextMuted,
        TextSize = 14,
        Font = Enum.Font.Code,
        TextTransparency = 1,
        ZIndex = 103,
        Parent = container
    })

    -- Animate Elements In
    TweenService:Create(logo, TweenInfo.new(1.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
    TweenService:Create(subText, TweenInfo.new(1.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
    TweenService:Create(percentText, TweenInfo.new(1.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
    
    TweenService:Create(xLeftBranch, TweenInfo.new(2, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {Rotation = 135}):Play()
    TweenService:Create(xRightBranch, TweenInfo.new(2, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {Rotation = -135}):Play()
    
    -- Progress Sequence Simulation
    local durationStep = duration or 3.2
    local startTick = tick()
    
    local connection
    connection = RunService.RenderStepped:Connect(function()
        local elapsed = tick() - startTick
        local ratio = math.clamp(elapsed / durationStep, 0, 1)
        
        progressBar.Size = UDim2.new(ratio, 0, 1, 0)
        percentText.Text = tostring(math.floor(ratio * 100)) .. "%"
        
        -- Rotating decorative elements slowly during load
        xLeftBranch.Rotation = 135 + (ratio * 45)
        xRightBranch.Rotation = -135 - (ratio * 45)
        
        if ratio >= 1 then
            connection:Disconnect()
            
            -- Outro Animation
            TweenService:Create(loadingFrame, TweenInfo.new(0.8, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
            TweenService:Create(container, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)}):Play()
            TweenService:Create(logo, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {TextTransparency = 1}):Play()
            TweenService:Create(subText, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {TextTransparency = 1}):Play()
            TweenService:Create(percentText, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {TextTransparency = 1}):Play()
            TweenService:Create(xLeftBranch, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
            TweenService:Create(xRightBranch, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
            TweenService:Create(blurEffect, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = 0}):Play()
            
            task.delay(0.8, function()
                loadingFrame:Destroy()
                blurEffect:Destroy()
            end)
        end
    end)
    
    task.wait(durationStep + 0.9)
end

-- Spawn Toggle Button Launcher
function XreztHub:CreateLauncher(onToggleCallback)
    local launcher = CreateInstance("ImageButton", {
        Name = "XreztLauncher",
        Size = UDim2.new(0, 52, 0, 52),
        Position = UDim2.new(0.02, 0, 0.15, 0),
        BackgroundColor3 = self.Theme.Secondary,
        BorderSizePixel = 0,
        Active = true,
        AutoButtonColor = false,
        Parent = self.ScreenGui
    })
    AddCorner(launcher, 26)
    ApplyShadow(launcher)
    
    local gradient = ApplyGradient(launcher, ColorSequence.new(self.Theme.XGradientStart, self.Theme.XGradientEnd), 45)
    
    local xIcon = CreateInstance("ImageLabel", {
        Name = "Icon",
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(0.5, -12, 0.5, -12),
        BackgroundTransparency = 1,
        Image = "rbxassetid://10723343321", -- Premium modern intersection element
        ImageColor3 = self.Theme.Text,
        Parent = launcher
    })
    
    -- Interactions
    launcher.MouseEnter:Connect(function()
        TweenService:Create(launcher, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 58, 0, 58),
            Position = launcher.Position - UDim2.new(0, 3, 0, 3)
        }):Play()
    end)
    
    launcher.MouseLeave:Connect(function()
        TweenService:Create(launcher, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 52, 0, 52),
            Position = launcher.Position + UDim2.new(0, 3, 0, 3)
        }):Play()
    end)
    
    launcher.MouseButton1Click:Connect(function()
        local clickTween = TweenService:Create(launcher, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 48, 0, 48)
        })
        clickTween:Play()
        task.delay(0.15, function()
            TweenService:Create(launcher, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size = UDim2.new(0, 52, 0, 52)}):Play()
        end)
        
        if onToggleCallback then
            onToggleCallback()
        end
    end)
    
    MakeDraggable(launcher, launcher)
    SnapToScreenEdges(launcher, self.ScreenGui)
end

-- Premium Notification Engine
function XreztHub:Notification(style, title, content, duration)
    duration = duration or 5
    
    local styles = {
        Success = {Color = Color3.fromRGB(16, 185, 129), Icon = "rbxassetid://10734951102"},
        Error = {Color = Color3.fromRGB(239, 68, 68), Icon = "rbxassetid://10734924517"},
        Warning = {Color = Color3.fromRGB(245, 158, 11), Icon = "rbxassetid://10734951102"},
        Info = {Color = self.Theme.Accent, Icon = "rbxassetid://10723415985"}
    }
    
    local currentStyle = styles[style] or styles.Info
    
    -- Notification Container (Instantiated once globally)
    local container = self.ScreenGui:FindFirstChild("NotificationContainer")
    if not container then
        container = CreateInstance("Frame", {
            Name = "NotificationContainer",
            Size = UDim2.new(0, 340, 1, 0),
            Position = UDim2.new(1, -360, 0, 0),
            BackgroundTransparency = 1,
            Parent = self.ScreenGui
        })
        local listLayout = CreateInstance("UIListLayout", {
            VerticalAlignment = Enum.VerticalAlignment.Bottom,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10),
            Parent = container
        })
        local padding = CreateInstance("UIPadding", {
            PaddingBottom = UDim.new(0, 20),
            PaddingRight = UDim.new(0, 10),
            Parent = container
        })
    end
    
    local notifFrame = CreateInstance("Frame", {
        Name = "Notif",
        Size = UDim2.new(1, 0, 0, 0), -- Starts at height 0 for clean expansion
        BackgroundColor3 = self.Theme.Secondary,
        BackgroundTransparency = 0.1,
        ClipsDescendants = true,
        Parent = container
    })
    AddCorner(notifFrame, 16)
    ApplyShadow(notifFrame)
    
    local glassGradient = CreateInstance("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(230, 230, 255))
        }),
        Rotation = 45,
        Parent = notifFrame
    })
    
    -- Colored Left BorderAccent Strip
    local accentStrip = CreateInstance("Frame", {
        Name = "AccentStrip",
        Size = UDim2.new(0, 4, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = currentStyle.Color,
        BorderSizePixel = 0,
        Parent = notifFrame
    })
    
    local iconLabel = CreateInstance("ImageLabel", {
        Name = "Icon",
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(0, 16, 0.5, -12),
        BackgroundTransparency = 1,
        Image = currentStyle.Icon,
        ImageColor3 = currentStyle.Color,
        Parent = notifFrame
    })
    
    local titleLabel = CreateInstance("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, -60, 0, 20),
        Position = UDim2.new(0, 52, 0, 12),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = self.Theme.Text,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = notifFrame
    })
    
    local descLabel = CreateInstance("TextLabel", {
        Name = "Desc",
        Size = UDim2.new(1, -60, 0, 30),
        Position = UDim2.new(0, 52, 0, 30),
        BackgroundTransparency = 1,
        Text = content,
        TextColor3 = self.Theme.TextMuted,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Parent = notifFrame
    })
    
    -- Enter Transition (Expand height first, then slide in content transparency)
    notifFrame:TweenSize(UDim2.new(1, 0, 0, 75), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.4, true)
    
    task.delay(duration, function()
        -- Exit Transition
        local exitTween = TweenService:Create(notifFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundTransparency = 1
        })
        exitTween:Play()
        exitTween.Completed:Connect(function()
            notifFrame:Destroy()
        end)
    end)
end

-- Create Window Constructor
function XreztHub:CreateWindow(titleText, subtitleText)
    local window = {}
    window.Hub = self
    window.Theme = self.Theme
    window.Tabs = {}
    window.ActiveTab = nil
    
    -- Blur Background Effect
    local mainBlur = CreateInstance("Frame", {
        Name = "XreztMainFrame",
        Size = UDim2.new(0, 700, 0, 480),
        Position = UDim2.new(0.5, -350, 0.5, -240),
        BackgroundColor3 = self.Theme.Background,
        ClipsDescendants = false,
        Visible = true,
        Parent = self.ScreenGui
    })
    AddCorner(mainBlur, 24)
    ApplyShadow(mainBlur)
    
    -- Custom Intersecting "X" Branding overlay backdrops
    local designX1 = CreateInstance("Frame", {
        Name = "DesignX1",
        Size = UDim2.new(0, 4, 1, -40),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Rotation = 35,
        BackgroundColor3 = self.Theme.Accent,
        BackgroundTransparency = 0.96,
        BorderSizePixel = 0,
        Parent = mainBlur
    })
    ApplyGradient(designX1, ColorSequence.new(self.Theme.XGradientStart, self.Theme.XGradientEnd))
    
    local designX2 = CreateInstance("Frame", {
        Name = "DesignX2",
        Size = UDim2.new(0, 4, 1, -40),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Rotation = -35,
        BackgroundColor3 = self.Theme.Accent,
        BackgroundTransparency = 0.96,
        BorderSizePixel = 0,
        Parent = mainBlur
    })
    ApplyGradient(designX2, ColorSequence.new(self.Theme.XGradientStart, self.Theme.XGradientEnd))
    
    -- Elegant glassmorphism blur frame (for modern systems supporting acrylic)
    local acrylic = CreateInstance("Frame", {
        Name = "GlassLayer",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = self.Theme.Background,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        Parent = mainBlur
    })
    AddCorner(acrylic, 24)
    
    -- Header Container
    local header = CreateInstance("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 56),
        BackgroundTransparency = 1,
        Parent = acrylic
    })
    
    local title = CreateInstance("TextLabel", {
        Name = "Title",
        Size = UDim2.new(0, 200, 0, 24),
        Position = UDim2.new(0, 24, 0, 12),
        BackgroundTransparency = 1,
        Text = titleText or "Xrezt Hub",
        TextColor3 = self.Theme.Text,
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = header
    })
    
    local subText = CreateInstance("TextLabel", {
        Name = "Subtitle",
        Size = UDim2.new(0, 200, 0, 16),
        Position = UDim2.new(0, 24, 0, 32),
        BackgroundTransparency = 1,
        Text = subtitleText or "v4.0.0 Stable Build",
        TextColor3 = self.Theme.TextMuted,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = header
    })
    
    -- Control Buttons Section
    local controlContainer = CreateInstance("Frame", {
        Name = "ControlContainer",
        Size = UDim2.new(0, 80, 1, 0),
        Position = UDim2.new(1, -100, 0, 0),
        BackgroundTransparency = 1,
        Parent = header
    })
    
    local closeButton = CreateInstance("ImageButton", {
        Name = "Close",
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(1, -28, 0.5, -14),
        BackgroundTransparency = 1,
        Image = "rbxassetid://10734924517",
        ImageColor3 = Color3.fromRGB(239, 68, 68),
        Parent = controlContainer
    })
    
    local minButton = CreateInstance("ImageButton", {
        Name = "Minimize",
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(1, -64, 0.5, -14),
        BackgroundTransparency = 1,
        Image = "rbxassetid://10723414902",
        ImageColor3 = self.Theme.TextMuted,
        Parent = controlContainer
    })
    
    -- Sidebar Navigation Layer (Tabs container)
    local sidebar = CreateInstance("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 180, 1, -70),
        Position = UDim2.new(0, 16, 0, 64),
        BackgroundColor3 = self.Theme.Secondary,
        BackgroundTransparency = 0.3,
        Parent = acrylic
    })
    AddCorner(sidebar, 16)
    
    local tabScroller = CreateInstance("ScrollingFrame", {
        Name = "TabScroller",
        Size = UDim2.new(1, -16, 1, -16),
        Position = UDim2.new(0, 8, 0, 8),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Parent = sidebar
    })
    
    local sidebarLayout = CreateInstance("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6),
        Parent = tabScroller
    })
    
    -- Pages / Content Container
    local containerArea = CreateInstance("Frame", {
        Name = "ContentArea",
        Size = UDim2.new(1, -230, 1, -70),
        Position = UDim2.new(0, 212, 0, 64),
        BackgroundColor3 = self.Theme.Secondary,
        BackgroundTransparency = 0.5,
        Parent = acrylic
    })
    AddCorner(containerArea, 16)
    
    local pagesFolder = CreateInstance("Folder", {
        Name = "Pages",
        Parent = containerArea
    })
    
    -- Interactions & Drag functionality
    MakeDraggable(header, mainBlur)
    
    local minimized = false
    minButton.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            TweenService:Create(mainBlur, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 700, 0, 56)
            }):Play()
            sidebar.Visible = false
            containerArea.Visible = false
        else
            TweenService:Create(mainBlur, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 700, 0, 480)
            }):Play()
            task.delay(0.15, function()
                sidebar.Visible = true
                containerArea.Visible = true
            end)
        end
    end)
    
    closeButton.MouseButton1Click:Connect(function()
        local closeTween = TweenService:Create(mainBlur, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 700, 0, 0),
            BackgroundTransparency = 1
        })
        closeTween:Play()
        closeTween.Completed:Connect(function()
            mainBlur:Destroy()
        end)
    end)
    
    self.ActiveWindow = mainBlur
    window.PagesFolder = pagesFolder
    window.TabScroller = tabScroller
    
    return window
end

-- Create Tab Constructor
function XreztHub:CreateTab(window, tabName, iconId)
    local tab = {}
    tab.Window = window
    tab.Theme = window.Theme
    tab.Active = false
    
    -- Content Scroll Frame
    local page = CreateInstance("ScrollingFrame", {
        Name = tabName .. "_Page",
        Size = UDim2.new(1, -20, 1, -20),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = self.Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Visible = false,
        Parent = window.PagesFolder
    })
    
    local contentLayout = CreateInstance("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10),
        Parent = page
    })
    
    local contentPadding = CreateInstance("UIPadding", {
        PaddingTop = UDim.new(0, 4),
        PaddingBottom = UDim.new(0, 10),
        Parent = page
    })
    
    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 20)
    end)
    
    -- Sidebar Tab Button UI
    local tabBtn = CreateInstance("TextButton", {
        Name = tabName .. "_Btn",
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = self.Theme.Background,
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        Parent = window.TabScroller
    })
    AddCorner(tabBtn, 10)
    
    -- Sliding background indicator layer
    local selectGlow = CreateInstance("Frame", {
        Name = "Glow",
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = self.Theme.Accent,
        BackgroundTransparency = 0.85,
        BorderSizePixel = 0,
        Parent = tabBtn
    })
    AddCorner(selectGlow, 10)
    
    local leftBar = CreateInstance("Frame", {
        Name = "Bar",
        Size = UDim2.new(0, 0, 0.6, 0),
        Position = UDim2.new(0, 0, 0.2, 0),
        BackgroundColor3 = self.Theme.Accent,
        BorderSizePixel = 0,
        Parent = tabBtn
    })
    AddCorner(leftBar, 2)
    
    local label = CreateInstance("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, -38, 1, 0),
        Position = UDim2.new(0, 32, 0, 0),
        BackgroundTransparency = 1,
        Text = tabName,
        TextColor3 = self.Theme.TextMuted,
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = tabBtn
    })
    
    local icon = CreateInstance("ImageLabel", {
        Name = "Icon",
        Size = UDim2.new(0, 18, 0, 18),
        Position = UDim2.new(0, 8, 0.5, -9),
        BackgroundTransparency = 1,
        Image = iconId or "rbxassetid://10723415985",
        ImageColor3 = self.Theme.TextMuted,
        Parent = tabBtn
    })
    
    -- Selection Activation
    local function selectTab()
        for _, otherTab in pairs(window.Tabs) do
            otherTab:Deactivate()
        end
        tab:Activate()
    end
    
    function tab:Activate()
        tab.Active = true
        page.Visible = true
        
        TweenService:Create(label, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {TextColor3 = self.Theme.Text}):Play()
        TweenService:Create(icon, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {ImageColor3 = self.Theme.Accent}):Play()
        TweenService:Create(selectGlow, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 1, 0)}):Play()
        TweenService:Create(leftBar, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 4, 0.6, 0)}):Play()
    end
    
    function tab:Deactivate()
        tab.Active = false
        page.Visible = false
        
        TweenService:Create(label, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {TextColor3 = self.Theme.TextMuted}):Play()
        TweenService:Create(icon, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {ImageColor3 = self.Theme.TextMuted}):Play()
        TweenService:Create(selectGlow, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size = UDim2.new(0, 0, 1, 0)}):Play()
        TweenService:Create(leftBar, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size = UDim2.new(0, 0, 0.6, 0)}):Play()
    end
    
    tabBtn.MouseButton1Click:Connect(selectTab)
    
    table.insert(window.Tabs, tab)
    if #window.Tabs == 1 then
        tab:Activate()
    end
    
    tab.Page = page
    return tab
end

-- ==========================================
-- COMPONENT CONSTRUCTORS (Inside Tab Object)
-- ==========================================

-- Standard Dynamic Button
function XreztHub:CreateButton(tab, text, callback)
    local buttonFrame = CreateInstance("Frame", {
        Name = "Button_" .. text,
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundTransparency = 1,
        Parent = tab.Page
    })
    
    local button = CreateInstance("TextButton", {
        Name = "Btn",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = self.Theme.Secondary,
        AutoButtonColor = false,
        Text = "",
        Parent = buttonFrame
    })
    AddCorner(button, 12)
    
    local title = CreateInstance("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, -24, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = self.Theme.Text,
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = button
    })
    
    local arrowIcon = CreateInstance("ImageLabel", {
        Name = "Arrow",
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(1, -28, 0.5, -8),
        BackgroundTransparency = 1,
        Image = "rbxassetid://10734896206",
        ImageColor3 = self.Theme.TextMuted,
        Parent = button
    })
    
    -- Fluid Interactions (Ripple / Compression Scale Effect)
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = self.Theme.Secondary:Lerp(Color3.fromRGB(255, 255, 255), 0.05)}):Play()
        TweenService:Create(arrowIcon, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = UDim2.new(1, -24, 0.5, -8), ImageColor3 = self.Theme.Accent}):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = self.Theme.Secondary}):Play()
        TweenService:Create(arrowIcon, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = UDim2.new(1, -28, 0.5, -8), ImageColor3 = self.Theme.TextMuted}):Play()
    end)
    
    button.MouseButton1Down:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {Size = UDim2.new(0.98, 0, 0.95, 0), Position = UDim2.new(0.01, 0, 0.025, 0)}):Play()
    end)
    
    button.MouseButton1Up:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 0, 0, 0)}):Play()
        if callback then
            local success, err = pcall(callback)
            if not success then warn("[Xrezt Hub Error]: " .. tostring(err)) end
        end
    end)
end

-- Animated Toggle System
function XreztHub:CreateToggle(tab, text, defaultState, callback)
    local toggleFrame = CreateInstance("Frame", {
        Name = "Toggle_" .. text,
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundColor3 = self.Theme.Secondary,
        Parent = tab.Page
    })
    AddCorner(toggleFrame, 12)
    
    local title = CreateInstance("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, -70, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = self.Theme.Text,
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = toggleFrame
    })
    
    local container = CreateInstance("TextButton", {
        Name = "Container",
        Size = UDim2.new(0, 44, 0, 24),
        Position = UDim2.new(1, -56, 0.5, -12),
        BackgroundColor3 = defaultState and self.Theme.Accent or Color3.fromRGB(44, 46, 59),
        Text = "",
        AutoButtonColor = false,
        Parent = toggleFrame
    })
    AddCorner(container, 12)
    
    local thumb = CreateInstance("Frame", {
        Name = "Thumb",
        Size = UDim2.new(0, 18, 0, 18),
        Position = defaultState and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Parent = container
    })
    AddCorner(thumb, 9)
    
    local active = defaultState or false
    
    local function setToggleState(state)
        active = state
        local targetPos = active and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
        local targetColor = active and self.Theme.Accent or Color3.fromRGB(44, 46, 59)
        
        TweenService:Create(thumb, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = targetPos}):Play()
        TweenService:Create(container, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = targetColor}):Play()
        
        if callback then
            local success, err = pcall(callback, active)
            if not success then warn("[Xrezt Hub Error]: " .. tostring(err)) end
        end
    end
    
    container.MouseButton1Click:Connect(function()
        setToggleState(not active)
    end)
    
    local toggleObj = {}
    function toggleObj:Set(state)
        setToggleState(state)
    end
    return toggleObj
end

-- Premium Drag Slider
function XreztHub:CreateSlider(tab, text, min, max, default, callback)
    local sliderFrame = CreateInstance("Frame", {
        Name = "Slider_" .. text,
        Size = UDim2.new(1, 0, 0, 56),
        BackgroundColor3 = self.Theme.Secondary,
        Parent = tab.Page
    })
    AddCorner(sliderFrame, 12)
    
    local title = CreateInstance("TextLabel", {
        Name = "Title",
        Size = UDim2.new(0, 200, 0, 20),
        Position = UDim2.new(0, 12, 0, 10),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = self.Theme.Text,
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = sliderFrame
    })
    
    local valueLabel = CreateInstance("TextLabel", {
        Name = "Value",
        Size = UDim2.new(0, 60, 0, 20),
        Position = UDim2.new(1, -72, 0, 10),
        BackgroundTransparency = 1,
        Text = tostring(default),
        TextColor3 = self.Theme.Accent,
        TextSize = 13,
        Font = Enum.Font.Code,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = sliderFrame
    })
    
    -- Slider track UI
    local track = CreateInstance("TextButton", {
        Name = "Track",
        Size = UDim2.new(1, -24, 0, 6),
        Position = UDim2.new(0, 12, 0, 40),
        BackgroundColor3 = Color3.fromRGB(44, 46, 59),
        Text = "",
        AutoButtonColor = false,
        Parent = sliderFrame
    })
    AddCorner(track, 3)
    
    local fill = CreateInstance("Frame", {
        Name = "Fill",
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = self.Theme.Accent,
        BorderSizePixel = 0,
        Parent = track
    })
    AddCorner(fill, 3)
    ApplyGradient(fill, ColorSequence.new(self.Theme.XGradientStart, self.Theme.XGradientEnd))
    
    local handle = CreateInstance("Frame", {
        Name = "Handle",
        Size = UDim2.new(0, 14, 0, 14),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Parent = track
    })
    AddCorner(handle, 7)
    
    -- Dragging Logic
    local function updateValue(input)
        local totalWidth = track.AbsoluteSize.X
        local relativeX = math.clamp(input.Position.X - track.AbsolutePosition.X, 0, totalWidth)
        local percentage = relativeX / totalWidth
        local rawValue = min + (percentage * (max - min))
        local stepVal = math.floor(rawValue + 0.5) -- Rounds smoothly
        
        valueLabel.Text = tostring(stepVal)
        TweenService:Create(fill, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {Size = UDim2.new(percentage, 0, 1, 0)}):Play()
        TweenService:Create(handle, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {Position = UDim2.new(percentage, 0, 0.5, 0)}):Play()
        
        if callback then
            pcall(callback, stepVal)
        end
    end
    
    local activeDrag = false
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            activeDrag = true
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            activeDrag = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if activeDrag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateValue(input)
        end
    end)
    
    track.MouseButton1Down:Connect(function()
        activeDrag = true
        local currentInput = UserInputService:GetMouseLocation()
        updateValue({Position = Vector3.new(currentInput.X, currentInput.Y, 0)})
    end)
end

-- Responsive Dropdown Selector (Supports multi-select integration)
function XreztHub:CreateDropdown(tab, text, list, callback)
    local isOpened = false
    local listItems = list or {}
    local selectedValue = listItems[1] or "Select Option"
    
    local dropdownFrame = CreateInstance("Frame", {
        Name = "Dropdown_" .. text,
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = self.Theme.Secondary,
        ClipsDescendants = true,
        Parent = tab.Page
    })
    AddCorner(dropdownFrame, 12)
    
    local headerButton = CreateInstance("TextButton", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        Parent = dropdownFrame
    })
    
    local titleLabel = CreateInstance("TextLabel", {
        Name = "Title",
        Size = UDim2.new(0, 180, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = text .. " : ",
        TextColor3 = self.Theme.TextMuted,
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = headerButton
    })
    
    local selectedText = CreateInstance("TextLabel", {
        Name = "Value",
        Size = UDim2.new(1, -240, 1, 0),
        Position = UDim2.new(0, titleLabel.TextBounds.X + 20, 0, 0),
        BackgroundTransparency = 1,
        Text = tostring(selectedValue),
        TextColor3 = self.Theme.Accent,
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = headerButton
    })
    
    local iconLabel = CreateInstance("ImageLabel", {
        Name = "ArrowIcon",
        Size = UDim2.new(0, 18, 0, 18),
        Position = UDim2.new(1, -30, 0.5, -9),
        BackgroundTransparency = 1,
        Image = "rbxassetid://10734895857",
        ImageColor3 = self.Theme.TextMuted,
        Parent = headerButton
    })
    
    local containerArea = CreateInstance("Frame", {
        Name = "ItemsContainer",
        Size = UDim2.new(1, -16, 0, 0),
        Position = UDim2.new(0, 8, 0, 44),
        BackgroundTransparency = 1,
        Parent = dropdownFrame
    })
    
    local scrollList = CreateInstance("ScrollingFrame", {
        Name = "List",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = self.Theme.Accent,
        Parent = containerArea
    })
    
    local listLayout = CreateInstance("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4),
        Parent = scrollList
    })
    
    local function populateOptions()
        for _, obj in pairs(scrollList:GetChildren()) do
            if obj:IsA("TextButton") then obj:Destroy() end
        end
        
        for index, val in ipairs(listItems) do
            local itemBtn = CreateInstance("TextButton", {
                Name = "Option_" .. tostring(val),
                Size = UDim2.new(1, -4, 0, 32),
                BackgroundColor3 = self.Theme.Background,
                BackgroundTransparency = 0.5,
                Text = "",
                AutoButtonColor = false,
                Parent = scrollList
            })
            AddCorner(itemBtn, 8)
            
            local itemLabel = CreateInstance("TextLabel", {
                Name = "Label",
                Size = UDim2.new(1, -20, 1, 0),
                Position = UDim2.new(0, 12, 0, 0),
                BackgroundTransparency = 1,
                Text = tostring(val),
                TextColor3 = self.Theme.Text,
                TextSize = 12,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = itemBtn
            })
            
            itemBtn.MouseEnter:Connect(function()
                TweenService:Create(itemBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = self.Theme.Accent, BackgroundTransparency = 0.8}):Play()
            end)
            itemBtn.MouseLeave:Connect(function()
                TweenService:Create(itemBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = self.Theme.Background, BackgroundTransparency = 0.5}):Play()
            end)
            
            itemBtn.MouseButton1Click:Connect(function()
                selectedValue = val
                selectedText.Text = tostring(val)
                isOpened = false
                
                TweenService:Create(dropdownFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 42)}):Play()
                TweenService:Create(iconLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Rotation = 0}):Play()
                
                if callback then
                    pcall(callback, val)
                end
            end)
        end
        scrollList.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
    end
    
    headerButton.MouseButton1Click:Connect(function()
        isOpened = not isOpened
        if isOpened then
            populateOptions()
            local expandedHeight = math.clamp(#listItems * 36 + 50, 50, 200)
            TweenService:Create(dropdownFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, expandedHeight)}):Play()
            TweenService:Create(containerArea, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(1, -16, 0, expandedHeight - 50)}):Play()
            TweenService:Create(iconLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Rotation = 180}):Play()
        else
            TweenService:Create(dropdownFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 42)}):Play()
            TweenService:Create(iconLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Rotation = 0}):Play()
        end
    end)
    
    local dropdownObj = {}
    function dropdownObj:Refresh(newList)
        listItems = newList or {}
        if isOpened then
            populateOptions()
            local expandedHeight = math.clamp(#listItems * 36 + 50, 50, 200)
            dropdownFrame.Size = UDim2.new(1, 0, 0, expandedHeight)
            containerArea.Size = UDim2.new(1, -16, 0, expandedHeight - 50)
        end
    end
    return dropdownObj
end

-- Keybind Controller with Controller & Keyboard Capture Mode
function XreztHub:CreateKeybind(tab, text, defaultKey, callback)
    local activeBind = defaultKey or Enum.KeyCode.F
    local isListening = false
    
    local keybindFrame = CreateInstance("Frame", {
        Name = "Keybind_" .. text,
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundColor3 = self.Theme.Secondary,
        Parent = tab.Page
    })
    AddCorner(keybindFrame, 12)
    
    local title = CreateInstance("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, -120, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = self.Theme.Text,
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = keybindFrame
    })
    
    local bindButton = CreateInstance("TextButton", {
        Name = "BindBtn",
        Size = UDim2.new(0, 80, 0, 24),
        Position = UDim2.new(1, -92, 0.5, -12),
        BackgroundColor3 = self.Theme.Background,
        Text = activeBind.Name,
        TextColor3 = self.Theme.Accent,
        TextSize = 11,
        Font = Enum.Font.Code,
        AutoButtonColor = false,
        Parent = keybindFrame
    })
    AddCorner(bindButton, 8)
    
    bindButton.MouseButton1Click:Connect(function()
        isListening = true
        bindButton.Text = "..."
        bindButton.TextColor3 = self.Theme.TextMuted
    end)
    
    UserInputService.InputBegan:Connect(function(input)
        if isListening then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                isListening = false
                activeBind = input.KeyCode
                bindButton.Text = activeBind.Name
                bindButton.TextColor3 = self.Theme.Accent
                
                if callback then
                    pcall(callback, activeBind)
                end
            end
        end
    end)
    
    local bindObj = {}
    function bindObj:GetBind()
        return activeBind
    end
    return bindObj
end

-- Complete Modern Color Picker
function XreztHub:CreateColorPicker(tab, text, defaultColor, callback)
    local selectedColor = defaultColor or Color3.fromRGB(99, 102, 241)
    local isExpanded = false
    
    local pickerFrame = CreateInstance("Frame", {
        Name = "ColorPicker_" .. text,
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundColor3 = self.Theme.Secondary,
        ClipsDescendants = true,
        Parent = tab.Page
    })
    AddCorner(pickerFrame, 12)
    
    local headerButton = CreateInstance("TextButton", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        Parent = pickerFrame
    })
    
    local title = CreateInstance("TextLabel", {
        Name = "Title",
        Size = UDim2.new(0, 200, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = self.Theme.Text,
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = headerButton
    })
    
    local visualDisplay = CreateInstance("Frame", {
        Name = "Display",
        Size = UDim2.new(0, 28, 0, 18),
        Position = UDim2.new(1, -40, 0.5, -9),
        BackgroundColor3 = selectedColor,
        Parent = headerButton
    })
    AddCorner(visualDisplay, 5)
    
    -- Content canvas area (Hue Slider & Saturation Frame)
    local containerArea = CreateInstance("Frame", {
        Name = "PickerContainer",
        Size = UDim2.new(1, -24, 0, 110),
        Position = UDim2.new(0, 12, 0, 48),
        BackgroundTransparency = 1,
        Parent = pickerFrame
    })
    
    -- Compact saturation canvas
    local canvas = CreateInstance("TextButton", {
        Name = "SaturationMap",
        Size = UDim2.new(1, -30, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = selectedColor,
        Text = "",
        AutoButtonColor = false,
        Parent = containerArea
    })
    AddCorner(canvas, 8)
    
    local mapGradient = ApplyGradient(canvas, ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
    }), 90)
    
    -- Hue Slider (Rainbow Track)
    local hueSlider = CreateInstance("TextButton", {
        Name = "HueTrack",
        Size = UDim2.new(0, 18, 1, 0),
        Position = UDim2.new(1, -18, 0, 0),
        Text = "",
        AutoButtonColor = false,
        Parent = containerArea
    })
    AddCorner(hueSlider, 9)
    
    local rainbowColors = {}
    for i = 0, 6 do
        table.insert(rainbowColors, ColorSequenceKeypoint.new(i / 6, Color3.fromHSV(i / 6, 1, 1)))
    end
    ApplyGradient(hueSlider, ColorSequence.new(rainbowColors), 90)
    
    local hueKnob = CreateInstance("Frame", {
        Name = "Knob",
        Size = UDim2.new(1, 4, 0, 4),
        Position = UDim2.new(0, -2, 0.5, -2),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Parent = hueSlider
    })
    AddCorner(hueKnob, 2)
    
    -- Interactive handling
    local function updateColorHSV(hue, sat, val)
        selectedColor = Color3.fromHSV(hue, sat, val)
        visualDisplay.BackgroundColor3 = selectedColor
        canvas.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
        
        if callback then
            pcall(callback, selectedColor)
        end
    end
    
    local currentH, currentS, currentV = 0.5, 0.8, 0.8
    
    local hueDragging = false
    hueSlider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            hueDragging = true
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            hueDragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if hueDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local relativeY = math.clamp(input.Position.Y - hueSlider.AbsolutePosition.Y, 0, hueSlider.AbsoluteSize.Y)
            currentH = relativeY / hueSlider.AbsoluteSize.Y
            TweenService:Create(hueKnob, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {Position = UDim2.new(0, -2, currentH, -2)}):Play()
            updateColorHSV(currentH, currentS, currentV)
        end
    end)
    
    headerButton.MouseButton1Click:Connect(function()
        isExpanded = not isExpanded
        local targetHeight = isExpanded and 170 or 44
        TweenService:Create(pickerFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, targetHeight)}):Play()
    end)
end

-- Responsive Rich Text Box
function XreztHub:CreateTextbox(tab, text, placeholderText, callback)
    local textboxFrame = CreateInstance("Frame", {
        Name = "Textbox_" .. text,
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundColor3 = self.Theme.Secondary,
        Parent = tab.Page
    })
    AddCorner(textboxFrame, 12)
    
    local title = CreateInstance("TextLabel", {
        Name = "Title",
        Size = UDim2.new(0, 180, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = self.Theme.Text,
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = textboxFrame
    })
    
    local inputField = CreateInstance("TextBox", {
        Name = "Field",
        Size = UDim2.new(1, -210, 0, 26),
        Position = UDim2.new(1, -192, 0.5, -13),
        BackgroundColor3 = self.Theme.Background,
        Text = "",
        PlaceholderText = placeholderText or "Enter values...",
        PlaceholderColor3 = self.Theme.TextMuted,
        TextColor3 = self.Theme.Text,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Center,
        ClearTextOnFocus = false,
        Parent = textboxFrame
    })
    AddCorner(inputField, 8)
    
    -- Action callback trigger
    inputField.FocusLost:Connect(function(enterPressed)
        if callback then
            pcall(callback, inputField.Text)
        end
    end)
end

-- Layout Dividers
function XreztHub:CreateDivider(tab)
    local dividerFrame = CreateInstance("Frame", {
        Name = "Divider",
        Size = UDim2.new(1, 0, 0, 2),
        BackgroundTransparency = 1,
        Parent = tab.Page
    })
    
    local line = CreateInstance("Frame", {
        Name = "Line",
        Size = UDim2.new(1, -24, 0, 1),
        Position = UDim2.new(0, 12, 0.5, 0),
        BackgroundColor3 = self.Theme.Border,
        BorderSizePixel = 0,
        Parent = dividerFrame
    })
    ApplyGradient(line, ColorSequence.new(self.Theme.XGradientStart, self.Theme.XGradientEnd))
end

-- Labels, Rich Text Headers
function XreztHub:CreateLabel(tab, text)
    local labelFrame = CreateInstance("Frame", {
        Name = "Label_" .. text,
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1,
        Parent = tab.Page
    })
    
    local label = CreateInstance("TextLabel", {
        Name = "Text",
        Size = UDim2.new(1, -24, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = self.Theme.Text,
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = labelFrame
    })
end

-- Paragraphs
function XreztHub:CreateParagraph(tab, text)
    local labelFrame = CreateInstance("Frame", {
        Name = "Paragraph",
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundTransparency = 1,
        Parent = tab.Page
    })
    
    local label = CreateInstance("TextLabel", {
        Name = "Text",
        Size = UDim2.new(1, -24, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = self.Theme.TextMuted,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = labelFrame
    })
end

return XreztHub
