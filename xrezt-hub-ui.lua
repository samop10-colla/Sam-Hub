--[[
    ======================================================================
    XREZT HUB - PREMIUM ROBLOX UI FRAMEWORK (V2)
    Designed & Engineered for absolute perfection by Nyxos.
    
    Fixes applied for Sam:
    - Replaced CanvasGroup with standard Frame (Fixes invisible elements/black screen bug)
    - Animated Gradient X toggle button (Shape morphing)
    - Fullscreen Loading Screen (Ignores Gui Insets)
    - Motion Graphics (Rotating gradient strokes, floating background orbs)
    - Fixed DropShadow (SliceCenter geometry)
    - AutomaticCanvasSize for buttery smooth scrolling
    ======================================================================
]]

local XreztHub = {}
XreztHub.__index = XreztHub

-- // Services
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

-- // Utility: Parent Resolver
local function GetParent()
    local success, parent = pcall(function()
        return (gethui and gethui()) or CoreGui
    end)
    if not success then
        parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    return parent
end

-- // Master Theme Definition (Colorful, Premium, High-End)
local Theme = {
    Background = Color3.fromRGB(15, 15, 20),
    Surface = Color3.fromRGB(22, 22, 30),
    SurfaceElevated = Color3.fromRGB(30, 30, 42),
    Accent = Color3.fromRGB(120, 80, 255), -- Vibrant Purple
    AccentSecondary = Color3.fromRGB(0, 212, 255), -- Cyan gradient pair
    Text = Color3.fromRGB(240, 240, 245),
    SubText = Color3.fromRGB(160, 160, 175),
    Border = Color3.fromRGB(45, 45, 60),
    Divider = Color3.fromRGB(35, 35, 50),
    Success = Color3.fromRGB(46, 204, 113),
    Warning = Color3.fromRGB(241, 196, 15),
    Error = Color3.fromRGB(231, 76, 60),
}

-- // Motion Design Constants
local Animations = {
    Duration = 0.4,
    EasingStyle = Enum.EasingStyle.Quint,
    EasingDirection = Enum.EasingDirection.Out
}

-- // Utility: Tweening Engine
local function Tween(instance, properties, duration, style, direction)
    local tDuration = duration or Animations.Duration
    local tStyle = style or Animations.EasingStyle
    local tDir = direction or Animations.EasingDirection
    local tweenInfo = TweenInfo.new(tDuration, tStyle, tDir)
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

-- // Utility: Corner Radius
local function ApplyCorners(instance, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 6)
    corner.Parent = instance
    return corner
end

-- // Utility: UIStroke
local function ApplyStroke(instance, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Theme.Border
    stroke.Thickness = thickness or 1
    stroke.Transparency = transparency or 0
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = instance
    return stroke
end

-- // Utility: Premium Gradient
local function ApplyPremiumGradient(instance)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.AccentSecondary),
        ColorSequenceKeypoint.new(1, Theme.Accent)
    })
    gradient.Rotation = 45
    gradient.Parent = instance
    return gradient
end

-- // Utility: Ripple Effect
local function CreateRipple(button)
    local ripple = Instance.new("Frame")
    ripple.Name = "Ripple"
    ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ripple.BackgroundTransparency = 0.8
    ripple.BorderSizePixel = 0
    ripple.ZIndex = button.ZIndex + 1
    ripple.ClipsDescendants = true
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = ripple
    
    ripple.Parent = button
    
    local mouseLocation = UserInputService:GetMouseLocation()
    local buttonPosition = button.AbsolutePosition
    local buttonSize = button.AbsoluteSize
    
    local x = mouseLocation.X - buttonPosition.X
    local y = (mouseLocation.Y - 36) - buttonPosition.Y 
    
    ripple.Position = UDim2.new(0, x, 0, y)
    ripple.Size = UDim2.new(0, 0, 0, 0)
    
    local targetSize = math.max(buttonSize.X, buttonSize.Y) * 2.5
    
    Tween(ripple, {
        Size = UDim2.new(0, targetSize, 0, targetSize),
        Position = UDim2.new(0, x - (targetSize / 2), 0, y - (targetSize / 2)),
        BackgroundTransparency = 1
    }, 0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    task.delay(0.5, function()
        ripple:Destroy()
    end)
end

-- // Utility: Dragging Logic
local function MakeDraggable(topbar, window)
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
            Tween(window, {
                Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            }, 0.08, Enum.EasingStyle.Linear)
        end
    end)
end

-- // Motion Graphics: Background Orbs
local function CreateMotionGraphics(parent)
    local GraphicContainer = Instance.new("Frame")
    GraphicContainer.Size = UDim2.new(1, 0, 1, 0)
    GraphicContainer.BackgroundTransparency = 1
    GraphicContainer.ClipsDescendants = true
    GraphicContainer.ZIndex = parent.ZIndex - 1
    GraphicContainer.Parent = parent

    local Orb1 = Instance.new("Frame")
    Orb1.Size = UDim2.new(0, 200, 0, 200)
    Orb1.Position = UDim2.new(0, -50, 0, -50)
    Orb1.BackgroundColor3 = Theme.Accent
    Orb1.BackgroundTransparency = 0.92
    Orb1.BorderSizePixel = 0
    ApplyCorners(Orb1, 100)
    Orb1.Parent = GraphicContainer

    local Orb2 = Instance.new("Frame")
    Orb2.Size = UDim2.new(0, 250, 0, 250)
    Orb2.Position = UDim2.new(1, -150, 1, -150)
    Orb2.BackgroundColor3 = Theme.AccentSecondary
    Orb2.BackgroundTransparency = 0.92
    Orb2.BorderSizePixel = 0
    ApplyCorners(Orb2, 125)
    Orb2.Parent = GraphicContainer

    task.spawn(function()
        while true do
            Tween(Orb1, {Position = UDim2.new(0, math.random(-50, 100), 0, math.random(-50, 100))}, 6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            Tween(Orb2, {Position = UDim2.new(1, math.random(-250, -100), 1, math.random(-250, -100))}, 7, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(6.5)
        end
    end)
end

-- // Loading Screen System
local function BuildLoadingScreen(gui, config)
    local LoadingFrame = Instance.new("Frame")
    LoadingFrame.Name = "XreztLoading"
    LoadingFrame.Size = UDim2.new(1, 0, 1, 0)
    LoadingFrame.BackgroundColor3 = Theme.Background
    LoadingFrame.ZIndex = 2000
    LoadingFrame.Parent = gui
    
    local LogoText = Instance.new("TextLabel")
    LogoText.Text = "XREZT HUB"
    LogoText.Font = Enum.Font.GothamBlack
    LogoText.TextSize = 48
    LogoText.TextColor3 = Color3.fromRGB(255, 255, 255)
    LogoText.BackgroundTransparency = 1
    LogoText.Size = UDim2.new(0, 400, 0, 60)
    LogoText.Position = UDim2.new(0.5, -200, 0.5, -40)
    LogoText.TextTransparency = 1
    LogoText.ZIndex = 2001
    LogoText.Parent = LoadingFrame
    ApplyPremiumGradient(LogoText)
    
    local SubLogo = Instance.new("TextLabel")
    SubLogo.Text = "Premium Framework Initialization"
    SubLogo.Font = Enum.Font.GothamMedium
    SubLogo.TextSize = 14
    SubLogo.TextColor3 = Theme.SubText
    SubLogo.BackgroundTransparency = 1
    SubLogo.Size = UDim2.new(0, 300, 0, 20)
    SubLogo.Position = UDim2.new(0.5, -150, 0.5, 20)
    SubLogo.TextTransparency = 1
    SubLogo.ZIndex = 2001
    SubLogo.Parent = LoadingFrame
    
    local ProgressBarBg = Instance.new("Frame")
    ProgressBarBg.Size = UDim2.new(0, 300, 0, 4)
    ProgressBarBg.Position = UDim2.new(0.5, -150, 0.5, 60)
    ProgressBarBg.BackgroundColor3 = Theme.SurfaceElevated
    ProgressBarBg.BorderSizePixel = 0
    ProgressBarBg.BackgroundTransparency = 1
    ProgressBarBg.ZIndex = 2001
    ApplyCorners(ProgressBarBg, 4)
    ProgressBarBg.Parent = LoadingFrame
    
    local ProgressBar = Instance.new("Frame")
    ProgressBar.Size = UDim2.new(0, 0, 1, 0)
    ProgressBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ProgressBar.BorderSizePixel = 0
    ProgressBar.ZIndex = 2002
    ApplyCorners(ProgressBar, 4)
    ApplyPremiumGradient(ProgressBar)
    ProgressBar.Parent = ProgressBarBg

    Tween(LogoText, {TextTransparency = 0, Position = UDim2.new(0.5, -200, 0.5, -50)}, 1)
    Tween(SubLogo, {TextTransparency = 0, Position = UDim2.new(0.5, -150, 0.5, 10)}, 1)
    Tween(ProgressBarBg, {BackgroundTransparency = 0}, 1)
    
    task.wait(1.2)
    
    Tween(ProgressBar, {Size = UDim2.new(0.4, 0, 1, 0)}, 0.8, Enum.EasingStyle.Exponential)
    task.wait(0.9)
    Tween(ProgressBar, {Size = UDim2.new(0.8, 0, 1, 0)}, 0.5, Enum.EasingStyle.Exponential)
    task.wait(0.6)
    Tween(ProgressBar, {Size = UDim2.new(1, 0, 1, 0)}, 0.3, Enum.EasingStyle.Linear)
    task.wait(0.4)
    
    Tween(LogoText, {TextTransparency = 1, Position = UDim2.new(0.5, -200, 0.5, -60)}, 0.5)
    Tween(SubLogo, {TextTransparency = 1, Position = UDim2.new(0.5, -150, 0.5, 0)}, 0.5)
    Tween(ProgressBarBg, {BackgroundTransparency = 1}, 0.5)
    Tween(ProgressBar, {BackgroundTransparency = 1}, 0.5)
    Tween(LoadingFrame, {BackgroundTransparency = 1}, 0.8)
    
    task.wait(0.8)
    LoadingFrame:Destroy()
end

-- // Floating Toggle (Shape-based Morphing X)
local function BuildFloatingToggle(gui, windowFrame, uiScale)
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Name = "XreztFloatingToggle"
    ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
    ToggleBtn.Position = UDim2.new(0, 20, 0.5, -25)
    ToggleBtn.BackgroundColor3 = Theme.SurfaceElevated
    ToggleBtn.Text = ""
    ToggleBtn.AutoButtonColor = false
    ToggleBtn.ZIndex = 500
    ApplyCorners(ToggleBtn, 25)
    ApplyStroke(ToggleBtn, Theme.Border, 1)
    ToggleBtn.Parent = gui
    
    local shadow = Instance.new("ImageLabel")
    shadow.Size = UDim2.new(1, 40, 1, 40)
    shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://6015897843"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.4
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 250, 250)
    shadow.ZIndex = 499
    shadow.Parent = ToggleBtn

    -- 3 Lines for Hamburger -> X Morph
    local L1 = Instance.new("Frame")
    L1.Size = UDim2.new(0, 22, 0, 3)
    L1.Position = UDim2.new(0.5, 0, 0.5, 0) -- Starts morphed as X (since UI starts open)
    L1.Rotation = 45
    L1.AnchorPoint = Vector2.new(0.5, 0.5)
    L1.BorderSizePixel = 0
    L1.ZIndex = 501
    ApplyCorners(L1, 2)
    ApplyPremiumGradient(L1)
    L1.Parent = ToggleBtn
    
    local L2 = Instance.new("Frame")
    L2.Size = UDim2.new(0, 22, 0, 3)
    L2.Position = UDim2.new(0.5, 0, 0.5, 0)
    L2.BackgroundTransparency = 1 -- Hidden when X
    L2.AnchorPoint = Vector2.new(0.5, 0.5)
    L2.BorderSizePixel = 0
    L2.ZIndex = 501
    ApplyCorners(L2, 2)
    ApplyPremiumGradient(L2)
    L2.Parent = ToggleBtn
    
    local L3 = Instance.new("Frame")
    L3.Size = UDim2.new(0, 22, 0, 3)
    L3.Position = UDim2.new(0.5, 0, 0.5, 0)
    L3.Rotation = -45
    L3.AnchorPoint = Vector2.new(0.5, 0.5)
    L3.BorderSizePixel = 0
    L3.ZIndex = 501
    ApplyCorners(L3, 2)
    ApplyPremiumGradient(L3)
    L3.Parent = ToggleBtn

    -- Draggable Toggle
    local dragging, dragInput, dragStart, startPos
    ToggleBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = ToggleBtn.Position
            Tween(ToggleBtn, {Size = UDim2.new(0, 44, 0, 44)}, 0.1)
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    Tween(ToggleBtn, {Size = UDim2.new(0, 50, 0, 50)}, 0.1)
                end
            end)
        end
    end)
    ToggleBtn.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Tween(ToggleBtn, {
                Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            }, 0.08, Enum.EasingStyle.Linear)
        end
    end)

    -- Toggle Logic
    local isOpen = true
    ToggleBtn.MouseButton1Click:Connect(function()
        CreateRipple(ToggleBtn)
        isOpen = not isOpen
        if isOpen then
            -- Open Menu
            windowFrame.Visible = true
            Tween(uiScale, {Scale = 1}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            
            -- Morph to X
            Tween(L1, {Position = UDim2.new(0.5, 0, 0.5, 0), Rotation = 45}, 0.3, Enum.EasingStyle.Back)
            Tween(L2, {BackgroundTransparency = 1}, 0.2)
            Tween(L3, {Position = UDim2.new(0.5, 0, 0.5, 0), Rotation = -45}, 0.3, Enum.EasingStyle.Back)
        else
            -- Close Menu
            local closeTween = Tween(uiScale, {Scale = 0}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In)
            closeTween.Completed:Connect(function()
                if not isOpen then windowFrame.Visible = false end
            end)
            
            -- Morph to Hamburger
            Tween(L1, {Position = UDim2.new(0.5, 0, 0.5, -7), Rotation = 0}, 0.3, Enum.EasingStyle.Back)
            Tween(L2, {BackgroundTransparency = 0}, 0.2)
            Tween(L3, {Position = UDim2.new(0.5, 0, 0.5, 7), Rotation = 0}, 0.3, Enum.EasingStyle.Back)
        end
    end)
    
    ToggleBtn.MouseEnter:Connect(function()
        if not dragging then Tween(ToggleBtn, {BackgroundColor3 = Theme.SurfaceElevated}, 0.2) end
    end)
    ToggleBtn.MouseLeave:Connect(function()
        Tween(ToggleBtn, {BackgroundColor3 = Theme.Surface}, 0.2)
    end)
end

-- // Library Init
function XreztHub:CreateWindow(config)
    config = config or {}
    local WindowTitle = config.Title or "Xrezt Hub"
    local WindowSize = config.Size or UDim2.new(0, 650, 0, 420)
    
    local XreztInstance = {
        Tabs = {},
        CurrentTab = nil,
        ConfigSystem = { Settings = {} }
    }
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "XreztHub_" .. HttpService:GenerateGUID(false)
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true -- Critical for fullscreen loading screen
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = GetParent()
    
    XreztInstance.GUI = ScreenGui
    
    BuildLoadingScreen(ScreenGui, config)
    
    -- Main Container (Replaced CanvasGroup for reliability)
    local MainContainer = Instance.new("Frame")
    MainContainer.Name = "Main"
    MainContainer.Size = WindowSize
    MainContainer.Position = UDim2.new(0.5, -(WindowSize.X.Offset/2), 0.5, -(WindowSize.Y.Offset/2))
    MainContainer.BackgroundColor3 = Theme.Background
    MainContainer.BorderSizePixel = 0
    MainContainer.ZIndex = 10
    ApplyCorners(MainContainer, 8)
    MainContainer.Parent = ScreenGui
    
    local UIScale = Instance.new("UIScale")
    UIScale.Scale = 0
    UIScale.Parent = MainContainer
    
    -- Animated Gradient Stroke
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Color3.fromRGB(255, 255, 255)
    MainStroke.Thickness = 1.5
    MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    MainStroke.Parent = MainContainer
    
    local StrokeGrad = Instance.new("UIGradient")
    StrokeGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.Accent),
        ColorSequenceKeypoint.new(0.5, Theme.AccentSecondary),
        ColorSequenceKeypoint.new(1, Theme.Accent)
    })
    StrokeGrad.Parent = MainStroke
    
    task.spawn(function()
        local rot = 0
        RunService.RenderStepped:Connect(function(dt)
            rot = rot + (dt * 45)
            StrokeGrad.Rotation = rot
        end)
    end)
    
    -- Fixed Drop Shadow
    local DropShadow = Instance.new("ImageLabel")
    DropShadow.Size = UDim2.new(1, 60, 1, 60)
    DropShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    DropShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    DropShadow.BackgroundTransparency = 1
    DropShadow.Image = "rbxassetid://6015897843"
    DropShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    DropShadow.ImageTransparency = 0.3
    DropShadow.ScaleType = Enum.ScaleType.Slice
    DropShadow.SliceCenter = Rect.new(49, 49, 250, 250)
    DropShadow.ZIndex = 9
    DropShadow.Parent = MainContainer

    -- Background Motion Graphics
    CreateMotionGraphics(MainContainer)

    -- Topbar
    local Topbar = Instance.new("Frame")
    Topbar.Size = UDim2.new(1, 0, 0, 45)
    Topbar.BackgroundColor3 = Theme.Surface
    Topbar.BorderSizePixel = 0
    Topbar.ZIndex = 12
    ApplyCorners(Topbar, 8)
    Topbar.Parent = MainContainer
    
    local TopbarCornerFix = Instance.new("Frame")
    TopbarCornerFix.Size = UDim2.new(1, 0, 0, 8)
    TopbarCornerFix.Position = UDim2.new(0, 0, 1, -8)
    TopbarCornerFix.BackgroundColor3 = Theme.Surface
    TopbarCornerFix.BorderSizePixel = 0
    TopbarCornerFix.ZIndex = 12
    TopbarCornerFix.Parent = Topbar
    
    MakeDraggable(Topbar, MainContainer)
    
    local Title = Instance.new("TextLabel")
    Title.Text = WindowTitle
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.TextColor3 = Theme.Text
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.Size = UDim2.new(0, 200, 1, 0)
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.ZIndex = 13
    Title.Parent = Topbar

    local Divider = Instance.new("Frame")
    Divider.Size = UDim2.new(1, 0, 0, 1)
    Divider.Position = UDim2.new(0, 0, 1, -1)
    Divider.BackgroundColor3 = Theme.Divider
    Divider.BorderSizePixel = 0
    Divider.ZIndex = 13
    Divider.Parent = Topbar

    -- Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 160, 1, -45)
    Sidebar.Position = UDim2.new(0, 0, 0, 45)
    Sidebar.BackgroundColor3 = Theme.SurfaceElevated
    Sidebar.BorderSizePixel = 0
    Sidebar.ZIndex = 11
    Sidebar.Parent = MainContainer
    
    local SidebarCornerFix = Instance.new("Frame")
    SidebarCornerFix.Size = UDim2.new(0, 8, 1, 0)
    SidebarCornerFix.Position = UDim2.new(1, -8, 0, 0)
    SidebarCornerFix.BackgroundColor3 = Theme.SurfaceElevated
    SidebarCornerFix.BorderSizePixel = 0
    SidebarCornerFix.ZIndex = 11
    SidebarCornerFix.Parent = Sidebar
    
    local SidebarLine = Instance.new("Frame")
    SidebarLine.Size = UDim2.new(0, 1, 1, 0)
    SidebarLine.Position = UDim2.new(1, -1, 0, 0)
    SidebarLine.BackgroundColor3 = Theme.Divider
    SidebarLine.BorderSizePixel = 0
    SidebarLine.ZIndex = 12
    SidebarLine.Parent = Sidebar
    
    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Size = UDim2.new(1, -16, 1, -20)
    TabContainer.Position = UDim2.new(0, 8, 0, 10)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 2
    TabContainer.ScrollBarImageColor3 = Theme.Border
    TabContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
    TabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabContainer.ZIndex = 13
    TabContainer.Parent = Sidebar
    
    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Padding = UDim.new(0, 6)
    TabListLayout.Parent = TabContainer

    -- Content Area
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Size = UDim2.new(1, -160, 1, -45)
    ContentContainer.Position = UDim2.new(0, 160, 0, 45)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.ZIndex = 11
    ContentContainer.Parent = MainContainer

    Tween(UIScale, {Scale = 1}, 0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    
    BuildFloatingToggle(ScreenGui, MainContainer, UIScale)

    -- // Notification System
    local NotifContainer = Instance.new("Frame")
    NotifContainer.Name = "NotifContainer"
    NotifContainer.Size = UDim2.new(0, 300, 1, -20)
    NotifContainer.Position = UDim2.new(1, -320, 0, 20)
    NotifContainer.BackgroundTransparency = 1
    NotifContainer.ZIndex = 2500
    NotifContainer.Parent = ScreenGui
    
    local NotifLayout = Instance.new("UIListLayout")
    NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
    NotifLayout.Padding = UDim.new(0, 10)
    NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    NotifLayout.Parent = NotifContainer

    function XreztInstance:Notify(notifConfig)
        local nTitle = notifConfig.Title or "Notification"
        local nContent = notifConfig.Content or "Content here"
        local nType = notifConfig.Type or "Info"
        local nDuration = notifConfig.Duration or 3
        
        local color = Theme.Accent
        if nType == "Success" then color = Theme.Success
        elseif nType == "Error" then color = Theme.Error
        elseif nType == "Warning" then color = Theme.Warning end
        
        local NotifFrame = Instance.new("Frame")
        NotifFrame.Size = UDim2.new(1, 0, 0, 80)
        NotifFrame.BackgroundColor3 = Theme.SurfaceElevated
        NotifFrame.ZIndex = 2501
        ApplyCorners(NotifFrame, 6)
        ApplyStroke(NotifFrame, Theme.Border, 1)
        
        local NTitleLab = Instance.new("TextLabel")
        NTitleLab.Text = nTitle
        NTitleLab.Font = Enum.Font.GothamBold
        NTitleLab.TextSize = 14
        NTitleLab.TextColor3 = color
        NTitleLab.Position = UDim2.new(0, 15, 0, 12)
        NTitleLab.Size = UDim2.new(1, -30, 0, 20)
        NTitleLab.TextXAlignment = Enum.TextXAlignment.Left
        NTitleLab.BackgroundTransparency = 1
        NTitleLab.ZIndex = 2502
        NTitleLab.Parent = NotifFrame
        
        local NDesc = Instance.new("TextLabel")
        NDesc.Text = nContent
        NDesc.Font = Enum.Font.Gotham
        NDesc.TextSize = 13
        NDesc.TextColor3 = Theme.SubText
        NDesc.Position = UDim2.new(0, 15, 0, 35)
        NDesc.Size = UDim2.new(1, -30, 0, 35)
        NDesc.TextXAlignment = Enum.TextXAlignment.Left
        NDesc.TextYAlignment = Enum.TextYAlignment.Top
        NDesc.TextWrapped = true
        NDesc.BackgroundTransparency = 1
        NDesc.ZIndex = 2502
        NDesc.Parent = NotifFrame
        
        local NProgress = Instance.new("Frame")
        NProgress.Size = UDim2.new(1, 0, 0, 3)
        NProgress.Position = UDim2.new(0, 0, 1, -3)
        NProgress.BackgroundColor3 = color
        NProgress.BorderSizePixel = 0
        NProgress.ZIndex = 2502
        ApplyCorners(NProgress, 6)
        NProgress.Parent = NotifFrame
        
        NotifFrame.Parent = NotifContainer
        
        NotifFrame.Position = UDim2.new(1, 50, 0, 0)
        TweenService:Create(NotifFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()
        Tween(NProgress, {Size = UDim2.new(0, 0, 0, 3)}, nDuration, Enum.EasingStyle.Linear)
        
        task.delay(nDuration, function()
            Tween(NotifFrame, {Position = UDim2.new(1, 50, 0, 0), BackgroundTransparency = 1}, 0.3)
            task.wait(0.3)
            NotifFrame:Destroy()
        end)
    end

    -- // Tab Creation
    function XreztInstance:CreateTab(tabConfig)
        local TabName = tabConfig.Name or "Tab"
        
        local TabInstance = {}
        
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, 0, 0, 34)
        TabBtn.BackgroundColor3 = Theme.Surface
        TabBtn.Text = ""
        TabBtn.AutoButtonColor = false
        TabBtn.ZIndex = 14
        ApplyCorners(TabBtn, 6)
        TabBtn.Parent = TabContainer
        
        local BtnText = Instance.new("TextLabel")
        BtnText.Text = TabName
        BtnText.Font = Enum.Font.GothamMedium
        BtnText.TextSize = 13
        BtnText.TextColor3 = Theme.SubText
        BtnText.Position = UDim2.new(0, 12, 0, 0)
        BtnText.Size = UDim2.new(1, -12, 1, 0)
        BtnText.TextXAlignment = Enum.TextXAlignment.Left
        BtnText.BackgroundTransparency = 1
        BtnText.ZIndex = 15
        BtnText.Parent = TabBtn
        
        local Indicator = Instance.new("Frame")
        Indicator.Size = UDim2.new(0, 3, 0, 0)
        Indicator.Position = UDim2.new(0, 4, 0.5, 0)
        Indicator.AnchorPoint = Vector2.new(0, 0.5)
        Indicator.BackgroundColor3 = Theme.Accent
        Indicator.BorderSizePixel = 0
        Indicator.ZIndex = 15
        ApplyCorners(Indicator, 2)
        Indicator.Parent = TabBtn

        local PageScroll = Instance.new("ScrollingFrame")
        PageScroll.Size = UDim2.new(1, -20, 1, -20)
        PageScroll.Position = UDim2.new(0, 10, 0, 10)
        PageScroll.BackgroundTransparency = 1
        PageScroll.ScrollBarThickness = 2
        PageScroll.ScrollBarImageColor3 = Theme.Border
        PageScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        PageScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        PageScroll.Visible = false
        PageScroll.ZIndex = 12
        PageScroll.Parent = ContentContainer
        
        local PageLayout = Instance.new("UIListLayout")
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Padding = UDim.new(0, 8)
        PageLayout.Parent = PageScroll
        
        local PagePadding = Instance.new("UIPadding")
        PagePadding.PaddingTop = UDim.new(0, 2)
        PagePadding.PaddingBottom = UDim.new(0, 10)
        PagePadding.PaddingLeft = UDim.new(0, 2)
        PagePadding.PaddingRight = UDim.new(0, 10)
        PagePadding.Parent = PageScroll
        
        local function ActivateTab()
            if XreztInstance.CurrentTab == TabInstance then return end
            
            if XreztInstance.CurrentTab then
                Tween(XreztInstance.CurrentTab.Btn, {BackgroundColor3 = Theme.Surface}, 0.2)
                Tween(XreztInstance.CurrentTab.Text, {TextColor3 = Theme.SubText}, 0.2)
                Tween(XreztInstance.CurrentTab.Indicator, {Size = UDim2.new(0, 3, 0, 0)}, 0.2)
                XreztInstance.CurrentTab.Page.Visible = false
            end
            
            XreztInstance.CurrentTab = TabInstance
            Tween(TabBtn, {BackgroundColor3 = Theme.SurfaceElevated}, 0.2)
            Tween(BtnText, {TextColor3 = Theme.Text}, 0.2)
            Tween(Indicator, {Size = UDim2.new(0, 3, 0, 16)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            
            PageScroll.Visible = true
            PageScroll.Position = UDim2.new(0, 20, 0, 10)
            Tween(PageScroll, {Position = UDim2.new(0, 10, 0, 10)}, 0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        end
        
        TabBtn.MouseButton1Click:Connect(ActivateTab)
        
        TabBtn.MouseEnter:Connect(function()
            if XreztInstance.CurrentTab ~= TabInstance then
                Tween(TabBtn, {BackgroundColor3 = Theme.SurfaceElevated}, 0.15)
                Tween(BtnText, {TextColor3 = Theme.Text}, 0.15)
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if XreztInstance.CurrentTab ~= TabInstance then
                Tween(TabBtn, {BackgroundColor3 = Theme.Surface}, 0.15)
                Tween(BtnText, {TextColor3 = Theme.SubText}, 0.15)
            end
        end)
        
        TabInstance.Btn = TabBtn
        TabInstance.Text = BtnText
        TabInstance.Indicator = Indicator
        TabInstance.Page = PageScroll
        
        if #XreztInstance.Tabs == 0 then
            ActivateTab()
        end
        table.insert(XreztInstance.Tabs, TabInstance)

        -- // Section
        function TabInstance:CreateSection(sName)
            local sName = sName or "Section"
            local SecFrame = Instance.new("Frame")
            SecFrame.Size = UDim2.new(1, 0, 0, 25)
            SecFrame.BackgroundTransparency = 1
            SecFrame.ZIndex = 13
            SecFrame.Parent = PageScroll
            
            local SText = Instance.new("TextLabel")
            SText.Text = string.upper(sName)
            SText.Font = Enum.Font.GothamBold
            SText.TextSize = 11
            SText.TextColor3 = Theme.SubText
            SText.Position = UDim2.new(0, 5, 0, 5)
            SText.Size = UDim2.new(1, -10, 1, -5)
            SText.TextXAlignment = Enum.TextXAlignment.Left
            SText.TextYAlignment = Enum.TextYAlignment.Bottom
            SText.BackgroundTransparency = 1
            SText.ZIndex = 14
            SText.Parent = SecFrame
        end

        -- // Toggle Component
        function TabInstance:CreateToggle(tConfig)
            local Name = tConfig.Name or "Toggle"
            local Default = tConfig.Default or false
            local Callback = tConfig.Callback or function() end
            
            local State = Default
            
            local TogFrame = Instance.new("TextButton")
            TogFrame.Size = UDim2.new(1, 0, 0, 42)
            TogFrame.BackgroundColor3 = Theme.Surface
            TogFrame.Text = ""
            TogFrame.AutoButtonColor = false
            TogFrame.ZIndex = 13
            ApplyCorners(TogFrame, 6)
            ApplyStroke(TogFrame, Theme.Border, 1)
            TogFrame.Parent = PageScroll
            
            local TText = Instance.new("TextLabel")
            TText.Text = Name
            TText.Font = Enum.Font.GothamMedium
            TText.TextSize = 13
            TText.TextColor3 = Theme.Text
            TText.Position = UDim2.new(0, 12, 0, 0)
            TText.Size = UDim2.new(1, -70, 1, 0)
            TText.TextXAlignment = Enum.TextXAlignment.Left
            TText.BackgroundTransparency = 1
            TText.ZIndex = 14
            TText.Parent = TogFrame
            
            local SwitchBg = Instance.new("Frame")
            SwitchBg.Size = UDim2.new(0, 40, 0, 20)
            SwitchBg.Position = UDim2.new(1, -52, 0.5, -10)
            SwitchBg.BackgroundColor3 = State and Theme.Accent or Theme.Background
            SwitchBg.BorderSizePixel = 0
            SwitchBg.ZIndex = 14
            ApplyCorners(SwitchBg, 10)
            SwitchBg.Parent = TogFrame
            
            local Knob = Instance.new("Frame")
            Knob.Size = UDim2.new(0, 16, 0, 16)
            Knob.Position = State and UDim2.new(0, 22, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Knob.BorderSizePixel = 0
            Knob.ZIndex = 15
            ApplyCorners(Knob, 8)
            Knob.Parent = SwitchBg
            
            local function UpdateToggle(noAnim)
                if State then
                    Tween(SwitchBg, {BackgroundColor3 = Theme.Accent}, noAnim and 0 or 0.3)
                    Tween(Knob, {Position = UDim2.new(0, 22, 0.5, -8)}, noAnim and 0 or 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                else
                    Tween(SwitchBg, {BackgroundColor3 = Theme.Background}, noAnim and 0 or 0.3)
                    Tween(Knob, {Position = UDim2.new(0, 2, 0.5, -8)}, noAnim and 0 or 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                end
                task.spawn(Callback, State)
            end
            
            UpdateToggle(true)
            
            TogFrame.MouseButton1Click:Connect(function()
                CreateRipple(TogFrame)
                State = not State
                UpdateToggle()
            end)
            
            TogFrame.MouseEnter:Connect(function() Tween(TogFrame, {BackgroundColor3 = Theme.SurfaceElevated}, 0.2) end)
            TogFrame.MouseLeave:Connect(function() Tween(TogFrame, {BackgroundColor3 = Theme.Surface}, 0.2) end)
        end

        -- // Color Picker
        function TabInstance:CreateColorPicker(cpConfig)
            local Name = cpConfig.Name or "Color Picker"
            local Default = cpConfig.Default or Color3.fromRGB(255, 255, 255)
            local Callback = cpConfig.Callback or function() end
            
            local CurrentColor = Default
            local h, s, v = Color3.toHSV(CurrentColor)
            local isOpen = false
            
            local CPFrame = Instance.new("Frame")
            CPFrame.Size = UDim2.new(1, 0, 0, 42)
            CPFrame.BackgroundColor3 = Theme.Surface
            CPFrame.ClipsDescendants = true
            CPFrame.ZIndex = 13
            ApplyCorners(CPFrame, 6)
            ApplyStroke(CPFrame, Theme.Border, 1)
            CPFrame.Parent = PageScroll
            
            local CPToggle = Instance.new("TextButton")
            CPToggle.Size = UDim2.new(1, 0, 0, 42)
            CPToggle.BackgroundTransparency = 1
            CPToggle.Text = ""
            CPToggle.ZIndex = 14
            CPToggle.Parent = CPFrame
            
            local CText = Instance.new("TextLabel")
            CText.Text = Name
            CText.Font = Enum.Font.GothamMedium
            CText.TextSize = 13
            CText.TextColor3 = Theme.Text
            CText.Position = UDim2.new(0, 12, 0, 0)
            CText.Size = UDim2.new(1, -50, 0, 42)
            CText.TextXAlignment = Enum.TextXAlignment.Left
            CText.BackgroundTransparency = 1
            CText.ZIndex = 15
            CText.Parent = CPToggle
            
            local Preview = Instance.new("Frame")
            Preview.Size = UDim2.new(0, 36, 0, 20)
            Preview.Position = UDim2.new(1, -48, 0.5, -10)
            Preview.BackgroundColor3 = CurrentColor
            Preview.ZIndex = 15
            ApplyCorners(Preview, 4)
            ApplyStroke(Preview, Theme.Border, 1)
            Preview.Parent = CPToggle
            
            local PickerArea = Instance.new("Frame")
            PickerArea.Size = UDim2.new(1, -24, 0, 120)
            PickerArea.Position = UDim2.new(0, 12, 0, 42)
            PickerArea.BackgroundTransparency = 1
            PickerArea.ZIndex = 14
            PickerArea.Parent = CPFrame
            
            local SatValMap = Instance.new("TextButton")
            SatValMap.Size = UDim2.new(1, -30, 1, -10)
            SatValMap.Position = UDim2.new(0, 0, 0, 5)
            SatValMap.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
            SatValMap.Text = ""
            SatValMap.AutoButtonColor = false
            SatValMap.ZIndex = 15
            ApplyCorners(SatValMap, 4)
            SatValMap.Parent = PickerArea
            
            local SVGradientWhite = Instance.new("UIGradient")
            SVGradientWhite.Color = ColorSequence.new(Color3.new(1,1,1), Color3.new(1,1,1))
            SVGradientWhite.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)})
            SVGradientWhite.Parent = SatValMap
            
            local SVBlack = Instance.new("Frame")
            SVBlack.Size = UDim2.new(1, 0, 1, 0)
            SVBlack.BackgroundColor3 = Color3.new(1,1,1)
            SVBlack.ZIndex = 15
            ApplyCorners(SVBlack, 4)
            local SVGradientBlack = Instance.new("UIGradient")
            SVGradientBlack.Color = ColorSequence.new(Color3.new(0,0,0), Color3.new(0,0,0))
            SVGradientBlack.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)})
            SVGradientBlack.Rotation = 90
            SVGradientBlack.Parent = SVBlack
            SVBlack.Parent = SatValMap
            
            local Ring = Instance.new("ImageLabel")
            Ring.Size = UDim2.new(0, 12, 0, 12)
            Ring.AnchorPoint = Vector2.new(0.5, 0.5)
            Ring.Position = UDim2.new(s, 0, 1 - v, 0)
            Ring.BackgroundTransparency = 1
            Ring.Image = "rbxassetid://3926309567"
            Ring.ImageRectOffset = Vector2.new(44, 44)
            Ring.ImageRectSize = Vector2.new(36, 36)
            Ring.ZIndex = 16
            Ring.Parent = SatValMap
            
            local HueSlide = Instance.new("TextButton")
            HueSlide.Size = UDim2.new(0, 20, 1, -10)
            HueSlide.Position = UDim2.new(1, -20, 0, 5)
            HueSlide.BackgroundColor3 = Color3.new(1,1,1)
            HueSlide.Text = ""
            HueSlide.AutoButtonColor = false
            HueSlide.ZIndex = 15
            ApplyCorners(HueSlide, 4)
            HueSlide.Parent = PickerArea
            
            local HueGradient = Instance.new("UIGradient")
            HueGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),
                ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)),
                ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
            })
            HueGradient.Rotation = 90
            HueGradient.Parent = HueSlide
            
            local HueRing = Instance.new("Frame")
            HueRing.Size = UDim2.new(1, 4, 0, 4)
            HueRing.Position = UDim2.new(0, -2, h, 0)
            HueRing.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            HueRing.BorderSizePixel = 0
            HueRing.ZIndex = 16
            ApplyCorners(HueRing, 2)
            HueRing.Parent = HueSlide

            local function UpdateColor()
                CurrentColor = Color3.fromHSV(h, s, v)
                Tween(Preview, {BackgroundColor3 = CurrentColor}, 0.1)
                SatValMap.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                task.spawn(Callback, CurrentColor)
            end

            local draggingSV = false
            local draggingH = false

            SatValMap.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingSV = true end
            end)
            HueSlide.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingH = true end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    draggingSV = false
                    draggingH = false
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                    if draggingSV then
                        local x = math.clamp(input.Position.X - SatValMap.AbsolutePosition.X, 0, SatValMap.AbsoluteSize.X)
                        local y = math.clamp(input.Position.Y - SatValMap.AbsolutePosition.Y, 0, SatValMap.AbsoluteSize.Y)
                        s = x / SatValMap.AbsoluteSize.X
                        v = 1 - (y / SatValMap.AbsoluteSize.Y)
                        Tween(Ring, {Position = UDim2.new(s, 0, 1 - v, 0)}, 0.05, Enum.EasingStyle.Linear)
                        UpdateColor()
                    elseif draggingH then
                        local y = math.clamp(input.Position.Y - HueSlide.AbsolutePosition.Y, 0, HueSlide.AbsoluteSize.Y)
                        h = y / HueSlide.AbsoluteSize.Y
                        Tween(HueRing, {Position = UDim2.new(0, -2, h, 0)}, 0.05, Enum.EasingStyle.Linear)
                        UpdateColor()
                    end
                end
            end)

            CPToggle.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                if isOpen then
                    Tween(CPFrame, {Size = UDim2.new(1, 0, 0, 170)}, 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
                else
                    Tween(CPFrame, {Size = UDim2.new(1, 0, 0, 42)}, 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
                end
            end)
        end

        return TabInstance
    end

    return XreztInstance
end

return XreztHub
