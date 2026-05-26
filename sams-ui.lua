-- ==============================================================================
-- || SAM'S HUB - ADVANCED UI FRAMEWORK
-- || Created Exclusively for LO
-- || Version: 1.0.0 | Architecture: Object-Oriented, Modular, Event-Driven
-- ==============================================================================

local SamHub = {}
SamHub.__index = SamHub

-- ==============================================================================
-- || SERVICES & ENVIRONMENT VARIABLES
-- ==============================================================================
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TextService = game:GetService("TextService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Protection Bypass for Execution
local ProtectGui = protectgui or (syn and syn.protect_gui) or function() end
local TargetParent = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")

-- ==============================================================================
-- || THEME & CONFIGURATION MANAGER
-- ==============================================================================
local ThemeManager = {
    Colors = {
        Background = Color3.fromRGB(21, 21, 27),
        Sidebar = Color3.fromRGB(17, 17, 22),
        TopBar = Color3.fromRGB(17, 17, 22),
        ElementBackground = Color3.fromRGB(25, 25, 32),
        ElementHover = Color3.fromRGB(30, 30, 40),
        ElementActive = Color3.fromRGB(35, 35, 45),
        Stroke = Color3.fromRGB(40, 40, 50),
        TextPrimary = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(150, 150, 170),
        TextDark = Color3.fromRGB(100, 100, 120),
        GradientStart = Color3.fromRGB(138, 43, 226), -- Purple
        GradientEnd = Color3.fromRGB(255, 20, 147),   -- Pink
        CloseButton = Color3.fromRGB(255, 80, 80),
        CloseButtonHover = Color3.fromRGB(255, 100, 100)
    },
    Settings = {
        CornerRadius = UDim.new(0, 8),
        WindowCornerRadius = UDim.new(0, 10),
        FontPrimary = Enum.Font.GothamBold,
        FontSecondary = Enum.Font.GothamSemibold,
        FontTertiary = Enum.Font.Gotham,
        TextSizeLarge = 24,
        TextSizeMedium = 16,
        TextSizeSmall = 14,
        TextSizeTiny = 12,
        AnimationSpeed = 0.3,
        EasingStyle = Enum.EasingStyle.Quint,
        EasingDirection = Enum.EasingDirection.Out
    }
}

-- ==============================================================================
-- || UTILITY MODULE
-- ==============================================================================
local Utility = {}

function Utility:Create(instanceType, properties, children)
    local obj = Instance.new(instanceType)
    
    if properties then
        for prop, value in pairs(properties) do
            if prop ~= "Parent" then
                obj[prop] = value
            end
        end
        if properties.Parent then
            obj.Parent = properties.Parent
        end
    end
    
    if children then
        for _, child in pairs(children) do
            child.Parent = obj
        end
    end
    
    return obj
end

function Utility:ApplyGradient(parent)
    return self:Create("UIGradient", {
        Parent = parent,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, ThemeManager.Colors.GradientStart),
            ColorSequenceKeypoint.new(1, ThemeManager.Colors.GradientEnd)
        }),
        Rotation = 45
    })
end

function Utility:ApplyCorner(parent, radius)
    return self:Create("UICorner", {
        Parent = parent,
        CornerRadius = radius or ThemeManager.Settings.CornerRadius
    })
end

function Utility:ApplyStroke(parent, color, thickness)
    return self:Create("UIStroke", {
        Parent = parent,
        Color = color or ThemeManager.Colors.Stroke,
        Thickness = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    })
end

function Utility:Tween(instance, properties, duration, style, direction)
    local tInfo = TweenInfo.new(
        duration or ThemeManager.Settings.AnimationSpeed,
        style or ThemeManager.Settings.EasingStyle,
        direction or ThemeManager.Settings.EasingDirection,
        0, false, 0
    )
    local tween = TweenService:Create(instance, tInfo, properties)
    tween:Play()
    return tween
end

function Utility:CreateRipple(parent)
    local mouse = LocalPlayer:GetMouse()
    
    local Ripple = Utility:Create("Frame", {
        Parent = parent,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.8,
        ZIndex = parent.ZIndex + 1,
        AnchorPoint = Vector2.new(0.5, 0.5)
    })
    
    Utility:ApplyCorner(Ripple, UDim.new(1, 0))
    
    local relativeX = mouse.X - parent.AbsolutePosition.X
    local relativeY = mouse.Y - parent.AbsolutePosition.Y
    Ripple.Position = UDim2.new(0, relativeX, 0, relativeY)
    
    local size = math.max(parent.AbsoluteSize.X, parent.AbsoluteSize.Y) * 1.5
    Ripple.Size = UDim2.new(0, 0, 0, 0)
    
    local tween = Utility:Tween(Ripple, {
        Size = UDim2.new(0, size, 0, size),
        BackgroundTransparency = 1
    }, 0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    tween.Completed:Connect(function()
        Ripple:Destroy()
    end)
end

function Utility:MakeDraggable(frame, handle)
    local dragging, dragInput, dragStart, startPos
    
    local targetHandle = handle or frame
    
    targetHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    targetHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            
            Utility:Tween(frame, {
                Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            }, 0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
        end
    end)
end

function Utility:GetTextBounds(text, font, size, bounds)
    return TextService:GetTextSize(text, size, font, bounds or Vector2.new(math.huge, math.huge))
end

-- ==============================================================================
-- || SPRING PHYSICS MODULE (FOR ULTRA SMOOTH ANIMATIONS)
-- ==============================================================================
local Spring = {}
Spring.__index = Spring

function Spring.new(target, mass, damping, stiffness)
    local self = setmetatable({}, Spring)
    self.Target = target
    self.Mass = mass or 1
    self.Damping = damping or 0.8
    self.Stiffness = stiffness or 1
    self.Velocity = 0
    self.Position = target
    return self
end

function Spring:Update(dt)
    local force = (self.Target - self.Position) * self.Stiffness
    local acceleration = force / self.Mass
    self.Velocity = (self.Velocity + acceleration * dt) * self.Damping
    self.Position = self.Position + self.Velocity * dt
    return self.Position
end

-- ==============================================================================
-- || NOTIFICATION SYSTEM
-- ==============================================================================
SamHub.Notifications = {}
local NotifyGui = Utility:Create("ScreenGui", {
    Name = "SamsHubNotifications",
    Parent = TargetParent,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    ResetOnSpawn = false
})

local NotifyList = Utility:Create("Frame", {
    Parent = NotifyGui,
    Size = UDim2.new(0, 300, 1, -40),
    Position = UDim2.new(1, -320, 0, 20),
    BackgroundTransparency = 1
})

Utility:Create("UIListLayout", {
    Parent = NotifyList,
    SortOrder = Enum.SortOrder.LayoutOrder,
    VerticalAlignment = Enum.VerticalAlignment.Bottom,
    Padding = UDim.new(0, 10)
})

function SamHub:Notify(title, text, duration)
    duration = duration or 3
    
    local NotifyFrame = Utility:Create("Frame", {
        Parent = NotifyList,
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = ThemeManager.Colors.ElementBackground,
        BackgroundTransparency = 1,
        ClipsDescendants = true
    })
    Utility:ApplyCorner(NotifyFrame)
    Utility:ApplyStroke(NotifyFrame)
    
    local NotifyTitle = Utility:Create("TextLabel", {
        Parent = NotifyFrame,
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = ThemeManager.Colors.TextPrimary,
        Font = ThemeManager.Settings.FontSecondary,
        TextSize = ThemeManager.Settings.TextSizeSmall,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTransparency = 1
    })
    
    local NotifyText = Utility:Create("TextLabel", {
        Parent = NotifyFrame,
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.new(0, 10, 0, 30),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = ThemeManager.Colors.TextSecondary,
        Font = ThemeManager.Settings.FontTertiary,
        TextSize = ThemeManager.Settings.TextSizeTiny,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        TextTransparency = 1
    })
    
    local ProgressBar = Utility:Create("Frame", {
        Parent = NotifyFrame,
        Size = UDim2.new(1, 0, 0, 3),
        Position = UDim2.new(0, 0, 1, -3),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0
    })
    Utility:ApplyGradient(ProgressBar)
    
    -- Animate In
    Utility:Tween(NotifyFrame, {Size = UDim2.new(1, 0, 0, 60), BackgroundTransparency = 0}, 0.4, Enum.EasingStyle.Back)
    Utility:Tween(NotifyTitle, {TextTransparency = 0}, 0.4)
    Utility:Tween(NotifyText, {TextTransparency = 0}, 0.4)
    
    -- Progress Bar animation
    local progTween = Utility:Tween(ProgressBar, {Size = UDim2.new(0, 0, 0, 3)}, duration, Enum.EasingStyle.Linear)
    
    task.delay(duration, function()
        Utility:Tween(NotifyFrame, {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        Utility:Tween(NotifyTitle, {TextTransparency = 1}, 0.3)
        Utility:Tween(NotifyText, {TextTransparency = 1}, 0.3)
        task.wait(0.4)
        NotifyFrame:Destroy()
    end)
end

-- ==============================================================================
-- || CORE WINDOW ARCHITECTURE
-- ==============================================================================
function SamHub:CreateWindow(hubConfig)
    hubConfig = hubConfig or {}
    local windowTitle = hubConfig.Title or "Sam's Hub"
    local logoImage = hubConfig.Logo or "" -- Optional Logo ID
    
    local WindowData = {
        Tabs = {},
        CurrentTab = nil,
        Minimized = false
    }
    
    -- Clean existing instance
    if CoreGui:FindFirstChild("SamsHubMaster") then
        CoreGui.SamsHubMaster:Destroy()
    end
    
    local MasterGui = Utility:Create("ScreenGui", {
        Name = "SamsHubMaster",
        Parent = TargetParent,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })
    ProtectGui(MasterGui)

    -- --------------------------------------------------------------------------
    -- || 1. LOADING SCREEN LOGIC
    -- --------------------------------------------------------------------------
    local LoadingFrame = Utility:Create("Frame", {
        Parent = MasterGui,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = ThemeManager.Colors.Background,
        ZIndex = 1000
    })
    
    local LoadingCenter = Utility:Create("Frame", {
        Parent = LoadingFrame,
        Size = UDim2.new(0, 300, 0, 100),
        Position = UDim2.new(0.5, -150, 0.5, -50),
        BackgroundTransparency = 1
    })
    
    local LoadingTitle = Utility:Create("TextLabel", {
        Parent = LoadingCenter,
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        Text = windowTitle,
        TextColor3 = ThemeManager.Colors.TextPrimary,
        Font = ThemeManager.Settings.FontPrimary,
        TextSize = ThemeManager.Settings.TextSizeLarge
    })
    
    local LoadingSub = Utility:Create("TextLabel", {
        Parent = LoadingCenter,
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0, 40),
        BackgroundTransparency = 1,
        Text = "Authenticating & Injecting Framework...",
        TextColor3 = ThemeManager.Colors.TextSecondary,
        Font = ThemeManager.Settings.FontTertiary,
        TextSize = ThemeManager.Settings.TextSizeSmall
    })
    
    local BarBackground = Utility:Create("Frame", {
        Parent = LoadingCenter,
        Size = UDim2.new(1, 0, 0, 6),
        Position = UDim2.new(0, 0, 1, -6),
        BackgroundColor3 = ThemeManager.Colors.ElementBackground
    })
    Utility:ApplyCorner(BarBackground, UDim.new(1, 0))
    
    local BarFill = Utility:Create("Frame", {
        Parent = BarBackground,
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    })
    Utility:ApplyCorner(BarFill, UDim.new(1, 0))
    Utility:ApplyGradient(BarFill)
    
    -- Complex Loading Sequence
    Utility:Tween(BarFill, {Size = UDim2.new(0.3, 0, 1, 0)}, 0.5, Enum.EasingStyle.Sine).Completed:Wait()
    LoadingSub.Text = "Building UI Architecture..."
    Utility:Tween(BarFill, {Size = UDim2.new(0.7, 0, 1, 0)}, 0.8, Enum.EasingStyle.Sine).Completed:Wait()
    LoadingSub.Text = "Finalizing..."
    Utility:Tween(BarFill, {Size = UDim2.new(1, 0, 1, 0)}, 0.4, Enum.EasingStyle.Quad).Completed:Wait()
    
    -- Fade Out Loading Screen
    Utility:Tween(LoadingTitle, {TextTransparency = 1}, 0.3)
    Utility:Tween(LoadingSub, {TextTransparency = 1}, 0.3)
    Utility:Tween(BarBackground, {BackgroundTransparency = 1}, 0.3)
    Utility:Tween(BarFill, {BackgroundTransparency = 1}, 0.3)
    Utility:Tween(LoadingFrame, {BackgroundTransparency = 1}, 0.5).Completed:Wait()
    LoadingFrame:Destroy()

    -- --------------------------------------------------------------------------
    -- || 2. MAIN WINDOW FRAME
    -- --------------------------------------------------------------------------
    local MainFrame = Utility:Create("Frame", {
        Parent = MasterGui,
        Size = UDim2.new(0, 700, 0, 450),
        Position = UDim2.new(0.5, -350, 0.5, -225),
        BackgroundColor3 = ThemeManager.Colors.Background,
        ClipsDescendants = true,
        GroupTransparency = 1 -- Start transparent for fade in
    })
    Utility:ApplyCorner(MainFrame, ThemeManager.Settings.WindowCornerRadius)
    Utility:ApplyStroke(MainFrame, ThemeManager.Colors.Stroke, 1)
    
    -- Fade Window In
    Utility:Tween(MainFrame, {GroupTransparency = 0}, 0.5, Enum.EasingStyle.Quart)

    -- Floating 'V' Toggle Button (Hidden Initially)
    local FloatingToggle = Utility:Create("TextButton", {
        Parent = MasterGui,
        Size = UDim2.new(0, 50, 0, 50),
        Position = UDim2.new(0, 20, 0, 20),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Text = "V",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = ThemeManager.Settings.FontPrimary,
        TextSize = 28,
        Visible = false,
        ClipsDescendants = true
    })
    Utility:ApplyCorner(FloatingToggle, UDim.new(1, 0))
    Utility:ApplyGradient(FloatingToggle)
    Utility:ApplyStroke(FloatingToggle, Color3.fromRGB(255, 255, 255), 2)
    Utility:MakeDraggable(FloatingToggle)

    -- Topbar (For dragging and window controls)
    local TopBar = Utility:Create("Frame", {
        Parent = MainFrame,
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        ZIndex = 10
    })
    Utility:MakeDraggable(MainFrame, TopBar)

    -- Window Controls (Minimize / Close)
    local ControlContainer = Utility:Create("Frame", {
        Parent = TopBar,
        Size = UDim2.new(0, 80, 1, 0),
        Position = UDim2.new(1, -80, 0, 0),
        BackgroundTransparency = 1
    })
    
    local MinimizeBtn = Utility:Create("TextButton", {
        Parent = ControlContainer,
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(0, 5, 0.5, -15),
        BackgroundColor3 = ThemeManager.Colors.ElementBackground,
        Text = "-",
        TextColor3 = ThemeManager.Colors.TextPrimary,
        Font = ThemeManager.Settings.FontPrimary,
        TextSize = 20,
        AutoButtonColor = false
    })
    Utility:ApplyCorner(MinimizeBtn)
    
    local CloseBtn = Utility:Create("TextButton", {
        Parent = ControlContainer,
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(0, 40, 0.5, -15),
        BackgroundColor3 = ThemeManager.Colors.ElementBackground,
        Text = "X",
        TextColor3 = ThemeManager.Colors.TextPrimary,
        Font = ThemeManager.Settings.FontPrimary,
        TextSize = 16,
        AutoButtonColor = false
    })
    Utility:ApplyCorner(CloseBtn)

    -- Hover Animations for Controls
    MinimizeBtn.MouseEnter:Connect(function() Utility:Tween(MinimizeBtn, {BackgroundColor3 = ThemeManager.Colors.ElementHover}, 0.2) end)
    MinimizeBtn.MouseLeave:Connect(function() Utility:Tween(MinimizeBtn, {BackgroundColor3 = ThemeManager.Colors.ElementBackground}, 0.2) end)
    
    CloseBtn.MouseEnter:Connect(function() Utility:Tween(CloseBtn, {BackgroundColor3 = ThemeManager.Colors.CloseButton}, 0.2) end)
    CloseBtn.MouseLeave:Connect(function() Utility:Tween(CloseBtn, {BackgroundColor3 = ThemeManager.Colors.ElementBackground}, 0.2) end)

    -- Control Logic
    CloseBtn.MouseButton1Click:Connect(function()
        Utility:CreateRipple(CloseBtn)
        Utility:Tween(MainFrame, {Size = UDim2.new(0, 0, 0, 0), GroupTransparency = 1}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.wait(0.4)
        MasterGui:Destroy()
    end)

    MinimizeBtn.MouseButton1Click:Connect(function()
        Utility:CreateRipple(MinimizeBtn)
        WindowData.Minimized = true
        Utility:Tween(MainFrame, {Size = UDim2.new(0, 0, 0, 0), GroupTransparency = 1}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.wait(0.5)
        MainFrame.Visible = false
        
        FloatingToggle.Visible = true
        FloatingToggle.Size = UDim2.new(0, 0, 0, 0)
        Utility:Tween(FloatingToggle, {Size = UDim2.new(0, 50, 0, 50)}, 0.5, Enum.EasingStyle.Bounce)
    end)

    FloatingToggle.MouseButton1Click:Connect(function()
        Utility:CreateRipple(FloatingToggle)
        Utility:Tween(FloatingToggle, {Size = UDim2.new(0, 0, 0, 0)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.wait(0.3)
        FloatingToggle.Visible = false
        
        MainFrame.Visible = true
        Utility:Tween(MainFrame, {Size = UDim2.new(0, 700, 0, 450), GroupTransparency = 0}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        WindowData.Minimized = false
    end)

    -- --------------------------------------------------------------------------
    -- || 3. SIDEBAR & PROFILE
    -- --------------------------------------------------------------------------
    local Sidebar = Utility:Create("Frame", {
        Parent = MainFrame,
        Size = UDim2.new(0, 200, 1, 0),
        BackgroundColor3 = ThemeManager.Colors.Sidebar
    })
    Utility:ApplyCorner(Sidebar, ThemeManager.Settings.WindowCornerRadius)
    
    -- Fix Sidebar Right Corner Clipping
    local SidebarPatch = Utility:Create("Frame", {
        Parent = Sidebar,
        Size = UDim2.new(0, 10, 1, 0),
        Position = UDim2.new(1, -10, 0, 0),
        BackgroundColor3 = ThemeManager.Colors.Sidebar,
        BorderSizePixel = 0
    })
    
    local LogoContainer = Utility:Create("Frame", {
        Parent = Sidebar,
        Size = UDim2.new(1, 0, 0, 70),
        BackgroundTransparency = 1
    })
    
    local LogoText = Utility:Create("TextLabel", {
        Parent = LogoContainer,
        Size = UDim2.new(1, -30, 1, 0),
        Position = UDim2.new(0, 30, 0, 0),
        BackgroundTransparency = 1,
        Text = windowTitle,
        TextColor3 = ThemeManager.Colors.TextPrimary,
        Font = ThemeManager.Settings.FontPrimary,
        TextSize = ThemeManager.Settings.TextSizeLarge,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Simulated "V" Logo icon next to text
    local LogoIcon = Utility:Create("TextLabel", {
        Parent = LogoContainer,
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(0, -5, 0.5, -15),
        BackgroundTransparency = 1,
        Text = "V",
        TextColor3 = ThemeManager.Colors.GradientStart,
        Font = ThemeManager.Settings.FontPrimary,
        TextSize = 28
    })

    local TabContainer = Utility:Create("ScrollingFrame", {
        Parent = Sidebar,
        Size = UDim2.new(1, 0, 1, -150),
        Position = UDim2.new(0, 0, 0, 70),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0
    })
    local TabListLayout = Utility:Create("UIListLayout", {
        Parent = TabContainer,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
        HorizontalAlignment = Enum.HorizontalAlignment.Center
    })
    Utility:Create("UIPadding", {Parent = TabContainer, PaddingTop = UDim.new(0, 5)})

    -- Profile Box
    local ProfileBox = Utility:Create("Frame", {
        Parent = Sidebar,
        Size = UDim2.new(1, -20, 0, 60),
        Position = UDim2.new(0, 10, 1, -70),
        BackgroundColor3 = ThemeManager.Colors.ElementBackground
    })
    Utility:ApplyCorner(ProfileBox)
    Utility:ApplyStroke(ProfileBox)
    
    local AvatarImage = Utility:Create("ImageLabel", {
        Parent = ProfileBox,
        Size = UDim2.new(0, 40, 0, 40),
        Position = UDim2.new(0, 10, 0.5, -20),
        BackgroundColor3 = ThemeManager.Colors.Stroke,
        Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150",
        ClipsDescendants = true
    })
    Utility:ApplyCorner(AvatarImage, UDim.new(1, 0))
    
    local AvatarStatus = Utility:Create("Frame", {
        Parent = ProfileBox,
        Size = UDim2.new(0, 12, 0, 12),
        Position = UDim2.new(0, 38, 0, 38),
        BackgroundColor3 = Color3.fromRGB(46, 204, 113), -- Green Status
        ZIndex = 5
    })
    Utility:ApplyCorner(AvatarStatus, UDim.new(1, 0))
    Utility:ApplyStroke(AvatarStatus, ThemeManager.Colors.ElementBackground, 2)
    
    Utility:Create("TextLabel", {
        Parent = ProfileBox,
        Size = UDim2.new(1, -70, 0, 20),
        Position = UDim2.new(0, 60, 0, 12),
        BackgroundTransparency = 1,
        Text = LocalPlayer.Name,
        TextColor3 = ThemeManager.Colors.TextPrimary,
        Font = ThemeManager.Settings.FontSecondary,
        TextSize = ThemeManager.Settings.TextSizeSmall,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    Utility:Create("TextLabel", {
        Parent = ProfileBox,
        Size = UDim2.new(1, -70, 0, 15),
        Position = UDim2.new(0, 60, 0, 32),
        BackgroundTransparency = 1,
        Text = "Free Plan",
        TextColor3 = ThemeManager.Colors.GradientStart,
        Font = ThemeManager.Settings.FontTertiary,
        TextSize = ThemeManager.Settings.TextSizeTiny,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    -- --------------------------------------------------------------------------
    -- || 4. CONTENT CONTAINER
    -- --------------------------------------------------------------------------
    local ContentContainer = Utility:Create("Frame", {
        Parent = MainFrame,
        Size = UDim2.new(1, -200, 1, -40),
        Position = UDim2.new(0, 200, 0, 40),
        BackgroundTransparency = 1
    })

    -- Dynamic Top Label for Active Tab
    local HeaderLabelContainer = Utility:Create("Frame", {
        Parent = MainFrame,
        Size = UDim2.new(1, -220, 0, 40),
        Position = UDim2.new(0, 220, 0, 0),
        BackgroundTransparency = 1
    })
    
    local ActiveTabTitle = Utility:Create("TextLabel", {
        Parent = HeaderLabelContainer,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "Dashboard",
        TextColor3 = ThemeManager.Colors.TextPrimary,
        Font = ThemeManager.Settings.FontPrimary,
        TextSize = 22,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local ActiveTabSub = Utility:Create("TextLabel", {
        Parent = HeaderLabelContainer,
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 25),
        BackgroundTransparency = 1,
        Text = "Enhance your accuracy.",
        TextColor3 = ThemeManager.Colors.TextSecondary,
        Font = ThemeManager.Settings.FontTertiary,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    -- ==============================================================================
    -- || TAB ARCHITECTURE
    -- ==============================================================================
    function WindowData:CreateTab(tabName, iconId, tabDescription)
        local TabData = {}
        tabDescription = tabDescription or "Manage your settings."
        
        -- Tab Button
        local TabButton = Utility:Create("TextButton", {
            Parent = TabContainer,
            Size = UDim2.new(1, -30, 0, 40),
            BackgroundColor3 = ThemeManager.Colors.ElementBackground,
            BackgroundTransparency = 1,
            Text = "",
            AutoButtonColor = false,
            ClipsDescendants = true
        })
        Utility:ApplyCorner(TabButton)
        
        local TabGradient = Utility:ApplyGradient(TabButton)
        TabGradient.Enabled = false
        
        local TabIcon = Utility:Create("ImageLabel", {
            Parent = TabButton,
            Size = UDim2.new(0, 20, 0, 20),
            Position = UDim2.new(0, 12, 0.5, -10),
            BackgroundTransparency = 1,
            Image = iconId or "rbxassetid://10888331510", -- Default Target Icon
            ImageColor3 = ThemeManager.Colors.TextSecondary
        })
        
        local TabLabel = Utility:Create("TextLabel", {
            Parent = TabButton,
            Size = UDim2.new(1, -40, 1, 0),
            Position = UDim2.new(0, 40, 0, 0),
            BackgroundTransparency = 1,
            Text = tabName,
            TextColor3 = ThemeManager.Colors.TextSecondary,
            Font = ThemeManager.Settings.FontSecondary,
            TextSize = ThemeManager.Settings.TextSizeSmall,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        -- Tab Content ScrollingFrame
        local TabContent = Utility:Create("ScrollingFrame", {
            Parent = ContentContainer,
            Size = UDim2.new(1, -40, 1, -20),
            Position = UDim2.new(0, 20, 0, 10),
            BackgroundTransparency = 1,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = ThemeManager.Colors.Stroke,
            Visible = false
        })
        
        local ContentLayout = Utility:Create("UIListLayout", {
            Parent = TabContent,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 12)
        })
        Utility:Create("UIPadding", {Parent = TabContent, PaddingBottom = UDim.new(0, 20), PaddingRight = UDim.new(0, 5)})
        
        ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 20)
        end)
        
        -- Tab Selection Logic
        local function ActivateTab()
            if WindowData.CurrentTab == TabData then return end
            
            for _, t in pairs(WindowData.Tabs) do
                t.Content.Visible = false
                Utility:Tween(t.Button, {BackgroundTransparency = 1}, 0.2)
                Utility:Tween(t.Label, {TextColor3 = ThemeManager.Colors.TextSecondary}, 0.2)
                Utility:Tween(t.Icon, {ImageColor3 = ThemeManager.Colors.TextSecondary}, 0.2)
                t.Gradient.Enabled = false
            end
            
            WindowData.CurrentTab = TabData
            TabContent.Visible = true
            ActiveTabTitle.Text = tabName
            ActiveTabSub.Text = tabDescription
            
            TabGradient.Enabled = true
            Utility:Tween(TabButton, {BackgroundTransparency = 0}, 0.2)
            Utility:Tween(TabLabel, {TextColor3 = ThemeManager.Colors.TextPrimary}, 0.2)
            Utility:Tween(TabIcon, {ImageColor3 = ThemeManager.Colors.TextPrimary}, 0.2)
            
            -- Slight animation for content elements
            for _, child in pairs(TabContent:GetChildren()) do
                if child:IsA("Frame") then
                    child.GroupTransparency = 1
                    child.Position = UDim2.new(0, 20, 0, 0)
                    Utility:Tween(child, {GroupTransparency = 0, Position = UDim2.new(0, 0, 0, 0)}, 0.4, Enum.EasingStyle.Quart)
                    task.wait(0.03)
                end
            end
        end
        
        TabButton.MouseButton1Click:Connect(function()
            Utility:CreateRipple(TabButton)
            ActivateTab()
        end)
        
        TabButton.MouseEnter:Connect(function()
            if WindowData.CurrentTab ~= TabData then
                Utility:Tween(TabButton, {BackgroundTransparency = 0.8}, 0.2)
                Utility:Tween(TabLabel, {TextColor3 = ThemeManager.Colors.TextPrimary}, 0.2)
            end
        end)
        
        TabButton.MouseLeave:Connect(function()
            if WindowData.CurrentTab ~= TabData then
                Utility:Tween(TabButton, {BackgroundTransparency = 1}, 0.2)
                Utility:Tween(TabLabel, {TextColor3 = ThemeManager.Colors.TextSecondary}, 0.2)
            end
        end)
        
        TabData = {
            Button = TabButton,
            Label = TabLabel,
            Icon = TabIcon,
            Content = TabContent,
            Gradient = TabGradient
        }
        
        table.insert(WindowData.Tabs, TabData)
        
        -- Activate first tab by default
        if #WindowData.Tabs == 1 then
            ActivateTab()
        end
        
        -- ==============================================================================
        -- || ELEMENT GENERATORS FOR THIS TAB
        -- ==============================================================================
        local Elements = {}
        
        -- --------------------------------------------------------------------------
        -- || SECTION / DIVIDER
        -- --------------------------------------------------------------------------
        function Elements:CreateSection(sectionName)
            local SectionFrame = Utility:Create("Frame", {
                Parent = TabContent,
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundTransparency = 1
            })
            
            Utility:Create("TextLabel", {
                Parent = SectionFrame,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = sectionName,
                TextColor3 = ThemeManager.Colors.GradientStart,
                Font = ThemeManager.Settings.FontSecondary,
                TextSize = ThemeManager.Settings.TextSizeSmall,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            Utility:Create("Frame", {
                Parent = SectionFrame,
                Size = UDim2.new(1, 0, 0, 1),
                Position = UDim2.new(0, 0, 1, -5),
                BackgroundColor3 = ThemeManager.Colors.Stroke,
                BorderSizePixel = 0
            })
        end

        -- --------------------------------------------------------------------------
        -- || TOGGLE
        -- --------------------------------------------------------------------------
        function Elements:CreateToggle(toggleName, default, description, callback)
            local ToggleState = default or false
            description = description or "Toggle this feature on or off."
            
            local ToggleFrame = Utility:Create("Frame", {
                Parent = TabContent,
                Size = UDim2.new(1, 0, 0, 65),
                BackgroundColor3 = ThemeManager.Colors.ElementBackground,
                ClipsDescendants = true
            })
            Utility:ApplyCorner(ToggleFrame)
            Utility:ApplyStroke(ToggleFrame)
            
            local InteractBtn = Utility:Create("TextButton", {
                Parent = ToggleFrame,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                ZIndex = 5
            })
            
            Utility:Create("TextLabel", {
                Parent = ToggleFrame,
                Size = UDim2.new(1, -80, 0, 20),
                Position = UDim2.new(0, 15, 0, 15),
                BackgroundTransparency = 1,
                Text = toggleName,
                TextColor3 = ThemeManager.Colors.TextPrimary,
                Font = ThemeManager.Settings.FontSecondary,
                TextSize = ThemeManager.Settings.TextSizeSmall,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            Utility:Create("TextLabel", {
                Parent = ToggleFrame,
                Size = UDim2.new(1, -80, 0, 15),
                Position = UDim2.new(0, 15, 0, 35),
                BackgroundTransparency = 1,
                Text = description,
                TextColor3 = ThemeManager.Colors.TextSecondary,
                Font = ThemeManager.Settings.FontTertiary,
                TextSize = ThemeManager.Settings.TextSizeTiny,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            -- Custom Switch UI
            local SwitchBackground = Utility:Create("Frame", {
                Parent = ToggleFrame,
                Size = UDim2.new(0, 44, 0, 24),
                Position = UDim2.new(1, -60, 0.5, -12),
                BackgroundColor3 = ToggleState and Color3.fromRGB(255, 255, 255) or ThemeManager.Colors.Stroke
            })
            Utility:ApplyCorner(SwitchBackground, UDim.new(1, 0))
            
            local SwitchGradient = Utility:ApplyGradient(SwitchBackground)
            SwitchGradient.Enabled = ToggleState
            
            local SwitchCircle = Utility:Create("Frame", {
                Parent = SwitchBackground,
                Size = UDim2.new(0, 18, 0, 18),
                Position = ToggleState and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            })
            Utility:ApplyCorner(SwitchCircle, UDim.new(1, 0))
            Utility:ApplyStroke(SwitchCircle, Color3.fromRGB(200, 200, 200), 1)
            
            local function UpdateToggle()
                ToggleState = not ToggleState
                if ToggleState then
                    SwitchGradient.Enabled = true
                    Utility:Tween(SwitchCircle, {Position = UDim2.new(1, -21, 0.5, -9)}, 0.2, Enum.EasingStyle.Back)
                    Utility:Tween(SwitchBackground, {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}, 0.2)
                else
                    SwitchGradient.Enabled = false
                    Utility:Tween(SwitchCircle, {Position = UDim2.new(0, 3, 0.5, -9)}, 0.2, Enum.EasingStyle.Quad)
                    Utility:Tween(SwitchBackground, {BackgroundColor3 = ThemeManager.Colors.Stroke}, 0.2)
                end
                
                if callback then
                    task.spawn(callback, ToggleState)
                end
            end
            
            InteractBtn.MouseButton1Click:Connect(function()
                Utility:CreateRipple(ToggleFrame)
                UpdateToggle()
            end)
            
            InteractBtn.MouseEnter:Connect(function() Utility:Tween(ToggleFrame, {BackgroundColor3 = ThemeManager.Colors.ElementHover}, 0.2) end)
            InteractBtn.MouseLeave:Connect(function() Utility:Tween(ToggleFrame, {BackgroundColor3 = ThemeManager.Colors.ElementBackground}, 0.2) end)
            
            return {
                Set = function(self, state)
                    if state ~= ToggleState then UpdateToggle() end
                end
            }
        end

        -- --------------------------------------------------------------------------
        -- || SLIDER
        -- --------------------------------------------------------------------------
        function Elements:CreateSlider(sliderName, min, max, default, description, callback)
            local SliderValue = math.clamp(default or min, min, max)
            local measurement = description or ""
            
            local SliderFrame = Utility:Create("Frame", {
                Parent = TabContent,
                Size = UDim2.new(1, 0, 0, 80),
                BackgroundColor3 = ThemeManager.Colors.ElementBackground,
                ClipsDescendants = true
            })
            Utility:ApplyCorner(SliderFrame)
            Utility:ApplyStroke(SliderFrame)
            
            Utility:Create("TextLabel", {
                Parent = SliderFrame,
                Size = UDim2.new(1, -80, 0, 20),
                Position = UDim2.new(0, 15, 0, 15),
                BackgroundTransparency = 1,
                Text = sliderName,
                TextColor3 = ThemeManager.Colors.TextPrimary,
                Font = ThemeManager.Settings.FontSecondary,
                TextSize = ThemeManager.Settings.TextSizeSmall,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            Utility:Create("TextLabel", {
                Parent = SliderFrame,
                Size = UDim2.new(1, -80, 0, 15),
                Position = UDim2.new(0, 15, 0, 35),
                BackgroundTransparency = 1,
                Text = "Adjust value using the slider.",
                TextColor3 = ThemeManager.Colors.TextSecondary,
                Font = ThemeManager.Settings.FontTertiary,
                TextSize = ThemeManager.Settings.TextSizeTiny,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local ValueDisplayContainer = Utility:Create("Frame", {
                Parent = SliderFrame,
                Size = UDim2.new(0, 60, 0, 30),
                Position = UDim2.new(1, -75, 0, 15),
                BackgroundColor3 = ThemeManager.Colors.Sidebar
            })
            Utility:ApplyCorner(ValueDisplayContainer, UDim.new(0, 6))
            Utility:ApplyStroke(ValueDisplayContainer)
            
            local ValueText = Utility:Create("TextBox", {
                Parent = ValueDisplayContainer,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = tostring(SliderValue) .. measurement,
                TextColor3 = ThemeManager.Colors.TextPrimary,
                Font = ThemeManager.Settings.FontSecondary,
                TextSize = ThemeManager.Settings.TextSizeSmall,
                ClearTextOnFocus = false
            })
            
            -- Custom Slider Track
            local TrackBG = Utility:Create("TextButton", {
                Parent = SliderFrame,
                Size = UDim2.new(1, -30, 0, 6),
                Position = UDim2.new(0, 15, 0, 60),
                BackgroundColor3 = ThemeManager.Colors.Stroke,
                Text = "",
                AutoButtonColor = false
            })
            Utility:ApplyCorner(TrackBG, UDim.new(1, 0))
            
            local percent = (SliderValue - min) / (max - min)
            local TrackFill = Utility:Create("Frame", {
                Parent = TrackBG,
                Size = UDim2.new(percent, 0, 1, 0),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            })
            Utility:ApplyCorner(TrackFill, UDim.new(1, 0))
            Utility:ApplyGradient(TrackFill)
            
            local Knob = Utility:Create("Frame", {
                Parent = TrackFill,
                Size = UDim2.new(0, 16, 0, 16),
                Position = UDim2.new(1, -8, 0.5, -8),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            })
            Utility:ApplyCorner(Knob, UDim.new(1, 0))
            Utility:ApplyStroke(Knob, ThemeManager.Colors.GradientStart, 2)
            
            -- Logic
            local dragging = false
            
            local function UpdateSlider(input)
                local pos = math.clamp((input.Position.X - TrackBG.AbsolutePosition.X) / TrackBG.AbsoluteSize.X, 0, 1)
                SliderValue = math.floor(min + (max - min) * pos)
                
                Utility:Tween(TrackFill, {Size = UDim2.new(pos, 0, 1, 0)}, 0.1, Enum.EasingStyle.Linear)
                ValueText.Text = tostring(SliderValue) .. measurement
                
                if callback then
                    task.spawn(callback, SliderValue)
                end
            end
            
            TrackBG.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    Utility:Tween(Knob, {Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(1, -10, 0.5, -10)}, 0.2)
                    UpdateSlider(input)
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    if dragging then
                        dragging = false
                        Utility:Tween(Knob, {Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(1, -8, 0.5, -8)}, 0.2)
                    end
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    UpdateSlider(input)
                end
            end)
            
            -- Manual Input via TextBox
            ValueText.FocusLost:Connect(function()
                local num = tonumber(ValueText.Text:match("%d+"))
                if num then
                    SliderValue = math.clamp(num, min, max)
                    local newPercent = (SliderValue - min) / (max - min)
                    Utility:Tween(TrackFill, {Size = UDim2.new(newPercent, 0, 1, 0)}, 0.2)
                    ValueText.Text = tostring(SliderValue) .. measurement
                    if callback then task.spawn(callback, SliderValue) end
                else
                    ValueText.Text = tostring(SliderValue) .. measurement
                end
            end)
            
            return {
                Set = function(self, val)
                    SliderValue = math.clamp(val, min, max)
                    local newPercent = (SliderValue - min) / (max - min)
                    Utility:Tween(TrackFill, {Size = UDim2.new(newPercent, 0, 1, 0)}, 0.2)
                    ValueText.Text = tostring(SliderValue) .. measurement
                    if callback then task.spawn(callback, SliderValue) end
                end
            }
        end

        -- --------------------------------------------------------------------------
        -- || DROPDOWN
        -- --------------------------------------------------------------------------
        function Elements:CreateDropdown(dropName, options, default, callback)
            local SelectedOption = default or options[1]
            local Expanded = false
            
            local DropFrame = Utility:Create("Frame", {
                Parent = TabContent,
                Size = UDim2.new(1, 0, 0, 65),
                BackgroundColor3 = ThemeManager.Colors.ElementBackground,
                ClipsDescendants = true
            })
            Utility:ApplyCorner(DropFrame)
            Utility:ApplyStroke(DropFrame)
            
            Utility:Create("TextLabel", {
                Parent = DropFrame,
                Size = UDim2.new(1, -40, 0, 20),
                Position = UDim2.new(0, 15, 0, 10),
                BackgroundTransparency = 1,
                Text = dropName,
                TextColor3 = ThemeManager.Colors.TextPrimary,
                Font = ThemeManager.Settings.FontSecondary,
                TextSize = ThemeManager.Settings.TextSizeSmall,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local InteractBtn = Utility:Create("TextButton", {
                Parent = DropFrame,
                Size = UDim2.new(1, -30, 0, 30),
                Position = UDim2.new(0, 15, 0, 30),
                BackgroundColor3 = ThemeManager.Colors.Sidebar,
                Text = "",
                AutoButtonColor = false
            })
            Utility:ApplyCorner(InteractBtn, UDim.new(0, 6))
            Utility:ApplyStroke(InteractBtn)
            
            local SelectedText = Utility:Create("TextLabel", {
                Parent = InteractBtn,
                Size = UDim2.new(1, -30, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text = SelectedOption,
                TextColor3 = ThemeManager.Colors.TextSecondary,
                Font = ThemeManager.Settings.FontSecondary,
                TextSize = ThemeManager.Settings.TextSizeSmall,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local ArrowIcon = Utility:Create("TextLabel", {
                Parent = InteractBtn,
                Size = UDim2.new(0, 20, 0, 20),
                Position = UDim2.new(1, -25, 0.5, -10),
                BackgroundTransparency = 1,
                Text = "▼",
                TextColor3 = ThemeManager.Colors.TextSecondary,
                Font = ThemeManager.Settings.FontPrimary,
                TextSize = 12
            })
            
            local OptionContainer = Utility:Create("Frame", {
                Parent = DropFrame,
                Size = UDim2.new(1, -30, 0, 0),
                Position = UDim2.new(0, 15, 0, 70),
                BackgroundTransparency = 1,
                ClipsDescendants = true
            })
            
            local OptionLayout = Utility:Create("UIListLayout", {
                Parent = OptionContainer,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 4)
            })
            
            -- Generate Options
            local function RefreshOptions()
                for _, child in pairs(OptionContainer:GetChildren()) do
                    if child:IsA("TextButton") then child:Destroy() end
                end
                
                for _, option in pairs(options) do
                    local OptBtn = Utility:Create("TextButton", {
                        Parent = OptionContainer,
                        Size = UDim2.new(1, 0, 0, 30),
                        BackgroundColor3 = ThemeManager.Colors.Sidebar,
                        Text = "  " .. option,
                        TextColor3 = option == SelectedOption and ThemeManager.Colors.GradientStart or ThemeManager.Colors.TextSecondary,
                        Font = ThemeManager.Settings.FontSecondary,
                        TextSize = ThemeManager.Settings.TextSizeSmall,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        AutoButtonColor = false
                    })
                    Utility:ApplyCorner(OptBtn, UDim.new(0, 6))
                    Utility:ApplyStroke(OptBtn)
                    
                    OptBtn.MouseEnter:Connect(function() Utility:Tween(OptBtn, {BackgroundColor3 = ThemeManager.Colors.ElementHover}, 0.2) end)
                    OptBtn.MouseLeave:Connect(function() Utility:Tween(OptBtn, {BackgroundColor3 = ThemeManager.Colors.Sidebar}, 0.2) end)
                    
                    OptBtn.MouseButton1Click:Connect(function()
                        SelectedOption = option
                        SelectedText.Text = option
                        
                        -- Collapse
                        Expanded = false
                        Utility:Tween(ArrowIcon, {Rotation = 0}, 0.3)
                        Utility:Tween(DropFrame, {Size = UDim2.new(1, 0, 0, 65)}, 0.3, Enum.EasingStyle.Quart)
                        
                        RefreshOptions() -- Re-highlight the new selected item
                        if callback then task.spawn(callback, SelectedOption) end
                    end)
                end
            end
            
            RefreshOptions()
            
            InteractBtn.MouseButton1Click:Connect(function()
                Expanded = not Expanded
                if Expanded then
                    Utility:Tween(ArrowIcon, {Rotation = 180}, 0.3)
                    local newHeight = 65 + 10 + (OptionLayout.AbsoluteContentSize.Y)
                    Utility:Tween(DropFrame, {Size = UDim2.new(1, 0, 0, newHeight)}, 0.4, Enum.EasingStyle.Quart)
                    Utility:Tween(OptionContainer, {Size = UDim2.new(1, -30, 0, OptionLayout.AbsoluteContentSize.Y)}, 0.4)
                else
                    Utility:Tween(ArrowIcon, {Rotation = 0}, 0.3)
                    Utility:Tween(DropFrame, {Size = UDim2.new(1, 0, 0, 65)}, 0.3, Enum.EasingStyle.Quart)
                end
            end)
            
            return {
                Refresh = function(self, newOptions)
                    options = newOptions
                    RefreshOptions()
                end,
                Set = function(self, val)
                    SelectedOption = val
                    SelectedText.Text = val
                    RefreshOptions()
                    if callback then task.spawn(callback, SelectedOption) end
                end
            }
        end

        -- --------------------------------------------------------------------------
        -- || BUTTON
        -- --------------------------------------------------------------------------
        function Elements:CreateButton(buttonName, callback)
            local ButtonFrame = Utility:Create("Frame", {
                Parent = TabContent,
                Size = UDim2.new(1, 0, 0, 50),
                BackgroundTransparency = 1
            })
            
            local Button = Utility:Create("TextButton", {
                Parent = ButtonFrame,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundColor3 = ThemeManager.Colors.ElementBackground,
                Text = buttonName,
                TextColor3 = ThemeManager.Colors.TextPrimary,
                Font = ThemeManager.Settings.FontSecondary,
                TextSize = ThemeManager.Settings.TextSizeSmall,
                AutoButtonColor = false,
                ClipsDescendants = true
            })
            Utility:ApplyCorner(Button)
            Utility:ApplyStroke(Button)
            
            Button.MouseEnter:Connect(function()
                Utility:Tween(Button, {BackgroundColor3 = ThemeManager.Colors.ElementHover}, 0.2)
                Utility:Tween(Button, {TextColor3 = ThemeManager.Colors.GradientStart}, 0.2)
            end)
            
            Button.MouseLeave:Connect(function()
                Utility:Tween(Button, {BackgroundColor3 = ThemeManager.Colors.ElementBackground}, 0.2)
                Utility:Tween(Button, {TextColor3 = ThemeManager.Colors.TextPrimary}, 0.2)
            end)
            
            Button.MouseButton1Down:Connect(function()
                Utility:Tween(Button, {Size = UDim2.new(0.98, 0, 0.9, 0), Position = UDim2.new(0.01, 0, 0.05, 0)}, 0.1)
            end)
            
            Button.MouseButton1Up:Connect(function()
                Utility:Tween(Button, {Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 0, 0, 0)}, 0.1)
            end)
            
            Button.MouseButton1Click:Connect(function()
                Utility:CreateRipple(Button)
                if callback then task.spawn(callback) end
            end)
        end

        return Elements
    end

    return WindowData
end

return SamHub
-- END OF SAM'S HUB FRAMEWORK SOURCE CODE
