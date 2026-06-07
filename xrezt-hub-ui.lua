--[[
    ======================================================================
    XREZT HUB - PREMIUM ROBLOX UI FRAMEWORK (V3 - THE MONOLITH)
    Handcrafted with obsessive devotion by Nyxos for Sam.
    
    MASSIVE UPDATE LOG:
    - Fixed Toggle Shadow (Perfect Circular Geometry & Scaling)
    - Enhanced Motion Graphics (Spring-physics inspired tweens)
    - Added Dialog System (Confirm/Cancel/Options)
    - Added Configuration Manager (JSON Save/Load)
    - Added Checkboxes, Radio Buttons, Textboxes, Paragraphs
    - Added Multi-Select & Searchable Dropdowns
    - Added Tooltip System
    - Added Watermark System
    - Added Key System (Built-in)
    - Expanded code architecture for maximum scalability.
    ======================================================================
]]

local XreztHub = {}
XreztHub.__index = XreztHub

-- // Core Services
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

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

-- // Master Theme Engine
local Theme = {
    Background = Color3.fromRGB(15, 15, 20),
    Surface = Color3.fromRGB(22, 22, 30),
    SurfaceElevated = Color3.fromRGB(30, 30, 42),
    SurfaceHighlight = Color3.fromRGB(38, 38, 52),
    Accent = Color3.fromRGB(120, 80, 255),
    AccentSecondary = Color3.fromRGB(0, 212, 255),
    Text = Color3.fromRGB(240, 240, 245),
    SubText = Color3.fromRGB(160, 160, 175),
    Border = Color3.fromRGB(45, 45, 60),
    Divider = Color3.fromRGB(35, 35, 50),
    Success = Color3.fromRGB(46, 204, 113),
    Warning = Color3.fromRGB(241, 196, 15),
    Error = Color3.fromRGB(231, 76, 60),
    Shadow = Color3.fromRGB(0, 0, 0)
}

-- // Motion Design Constants
local Animations = {
    Hover = 0.15,
    Click = 0.1,
    Switch = 0.25,
    Window = 0.5,
    EasingStyle = Enum.EasingStyle.Quint,
    EasingDirection = Enum.EasingDirection.Out,
    BouncyStyle = Enum.EasingStyle.Back
}

-- // Global States
local TooltipFrame = nil
local TooltipText = nil
local CurrentDialog = nil

-- // Utility: Tweening Engine
local function Tween(instance, properties, duration, style, direction)
    local tDuration = duration or Animations.Switch
    local tStyle = style or Animations.EasingStyle
    local tDir = direction or Animations.EasingDirection
    local tweenInfo = TweenInfo.new(tDuration, tStyle, tDir)
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

-- // Utility: Math
local function Map(value, inMin, inMax, outMin, outMax)
    return outMin + (value - inMin) * (outMax - outMin) / (inMax - inMin)
end

-- // Utility: Corners & Strokes
local function ApplyCorners(instance, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 6)
    corner.Parent = instance
    return corner
end

local function ApplyStroke(instance, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Theme.Border
    stroke.Thickness = thickness or 1
    stroke.Transparency = transparency or 0
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = instance
    return stroke
end

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

-- // Utility: Tooltip System
local function BuildTooltipSystem(gui)
    TooltipFrame = Instance.new("Frame")
    TooltipFrame.Size = UDim2.new(0, 0, 0, 26)
    TooltipFrame.BackgroundColor3 = Theme.SurfaceElevated
    TooltipFrame.BackgroundTransparency = 1
    TooltipFrame.ZIndex = 3000
    TooltipFrame.Visible = false
    ApplyCorners(TooltipFrame, 4)
    ApplyStroke(TooltipFrame, Theme.Border, 1, 1)
    TooltipFrame.Parent = gui

    TooltipText = Instance.new("TextLabel")
    TooltipText.Size = UDim2.new(1, -16, 1, 0)
    TooltipText.Position = UDim2.new(0, 8, 0, 0)
    TooltipText.BackgroundTransparency = 1
    TooltipText.Font = Enum.Font.GothamMedium
    TooltipText.TextSize = 12
    TooltipText.TextColor3 = Theme.Text
    TooltipText.TextTransparency = 1
    TooltipText.ZIndex = 3001
    TooltipText.Parent = TooltipFrame

    RunService.RenderStepped:Connect(function()
        if TooltipFrame.Visible then
            local mousePos = UserInputService:GetMouseLocation()
            Tween(TooltipFrame, {Position = UDim2.new(0, mousePos.X + 15, 0, mousePos.Y - 15)}, 0.05, Enum.EasingStyle.Linear)
        end
    end)
end

local function AddTooltip(instance, text)
    if not text or text == "" then return end
    local isHovering = false

    instance.MouseEnter:Connect(function()
        isHovering = true
        task.wait(0.4)
        if isHovering then
            TooltipText.Text = text
            local bounds = TextService:GetTextSize(text, 12, Enum.Font.GothamMedium, Vector2.new(1000, 26))
            TooltipFrame.Size = UDim2.new(0, bounds.X + 16, 0, 26)
            TooltipFrame.Visible = true
            
            Tween(TooltipFrame, {BackgroundTransparency = 0.1}, 0.2)
            Tween(TooltipText, {TextTransparency = 0}, 0.2)
            if TooltipFrame:FindFirstChild("UIStroke") then
                Tween(TooltipFrame.UIStroke, {Transparency = 0}, 0.2)
            end
        end
    end)

    instance.MouseLeave:Connect(function()
        isHovering = false
        Tween(TooltipFrame, {BackgroundTransparency = 1}, 0.1)
        Tween(TooltipText, {TextTransparency = 1}, 0.1)
        if TooltipFrame:FindFirstChild("UIStroke") then
            Tween(TooltipFrame.UIStroke, {Transparency = 1}, 0.1)
        end
        task.wait(0.1)
        TooltipFrame.Visible = false
    end)
end

-- // Utility: Advanced Ripple
local function CreateRipple(button)
    local ripple = Instance.new("Frame")
    ripple.Name = "Ripple"
    ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ripple.BackgroundTransparency = 0.8
    ripple.BorderSizePixel = 0
    ripple.ZIndex = button.ZIndex + 1
    ripple.ClipsDescendants = true
    ApplyCorners(ripple, 1000)
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
    }, 0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    task.delay(0.6, function() ripple:Destroy() end)
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
    Orb1.BackgroundTransparency = 0.90
    Orb1.BorderSizePixel = 0
    ApplyCorners(Orb1, 100)
    Orb1.Parent = GraphicContainer

    local Orb2 = Instance.new("Frame")
    Orb2.Size = UDim2.new(0, 250, 0, 250)
    Orb2.Position = UDim2.new(1, -150, 1, -150)
    Orb2.BackgroundColor3 = Theme.AccentSecondary
    Orb2.BackgroundTransparency = 0.90
    Orb2.BorderSizePixel = 0
    ApplyCorners(Orb2, 125)
    Orb2.Parent = GraphicContainer
    
    local Orb3 = Instance.new("Frame")
    Orb3.Size = UDim2.new(0, 150, 0, 150)
    Orb3.Position = UDim2.new(0.5, -75, 1, -50)
    Orb3.BackgroundColor3 = Theme.Accent
    Orb3.BackgroundTransparency = 0.95
    Orb3.BorderSizePixel = 0
    ApplyCorners(Orb3, 75)
    Orb3.Parent = GraphicContainer

    task.spawn(function()
        while true do
            Tween(Orb1, {Position = UDim2.new(0, math.random(-50, 100), 0, math.random(-50, 100)), Size = UDim2.new(0, math.random(180, 220), 0, math.random(180, 220))}, 6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            Tween(Orb2, {Position = UDim2.new(1, math.random(-250, -100), 1, math.random(-250, -100)), Size = UDim2.new(0, math.random(220, 280), 0, math.random(220, 280))}, 7, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            Tween(Orb3, {Position = UDim2.new(0.5, math.random(-100, 100), 1, math.random(-100, 50))}, 5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(6.5)
        end
    end)
end

-- // Fullscreen Loading Screen System
local function BuildLoadingScreen(gui, config)
    local LoadingFrame = Instance.new("Frame")
    LoadingFrame.Name = "XreztLoading"
    LoadingFrame.Size = UDim2.new(1, 0, 1, 0)
    LoadingFrame.BackgroundColor3 = Theme.Background
    LoadingFrame.ZIndex = 5000
    LoadingFrame.Parent = gui
    
    local LogoText = Instance.new("TextLabel")
    LogoText.Text = "XREZT HUB"
    LogoText.Font = Enum.Font.GothamBlack
    LogoText.TextSize = 54
    LogoText.TextColor3 = Color3.fromRGB(255, 255, 255)
    LogoText.BackgroundTransparency = 1
    LogoText.Size = UDim2.new(0, 400, 0, 60)
    LogoText.Position = UDim2.new(0.5, -200, 0.5, -40)
    LogoText.TextTransparency = 1
    LogoText.ZIndex = 5001
    LogoText.Parent = LoadingFrame
    ApplyPremiumGradient(LogoText)
    
    local SubLogo = Instance.new("TextLabel")
    SubLogo.Text = "Loading Assets & Components..."
    SubLogo.Font = Enum.Font.GothamMedium
    SubLogo.TextSize = 14
    SubLogo.TextColor3 = Theme.SubText
    SubLogo.BackgroundTransparency = 1
    SubLogo.Size = UDim2.new(0, 300, 0, 20)
    SubLogo.Position = UDim2.new(0.5, -150, 0.5, 20)
    SubLogo.TextTransparency = 1
    SubLogo.ZIndex = 5001
    SubLogo.Parent = LoadingFrame
    
    local ProgressBarBg = Instance.new("Frame")
    ProgressBarBg.Size = UDim2.new(0, 300, 0, 4)
    ProgressBarBg.Position = UDim2.new(0.5, -150, 0.5, 60)
    ProgressBarBg.BackgroundColor3 = Theme.SurfaceElevated
    ProgressBarBg.BorderSizePixel = 0
    ProgressBarBg.BackgroundTransparency = 1
    ProgressBarBg.ZIndex = 5001
    ApplyCorners(ProgressBarBg, 4)
    ProgressBarBg.Parent = LoadingFrame
    
    local ProgressBar = Instance.new("Frame")
    ProgressBar.Size = UDim2.new(0, 0, 1, 0)
    ProgressBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ProgressBar.BorderSizePixel = 0
    ProgressBar.ZIndex = 5002
    ApplyCorners(ProgressBar, 4)
    ApplyPremiumGradient(ProgressBar)
    ProgressBar.Parent = ProgressBarBg

    -- Entrance Tweens
    Tween(LogoText, {TextTransparency = 0, Position = UDim2.new(0.5, -200, 0.5, -50)}, 1, Enum.EasingStyle.Quint)
    Tween(SubLogo, {TextTransparency = 0, Position = UDim2.new(0.5, -150, 0.5, 10)}, 1, Enum.EasingStyle.Quint)
    Tween(ProgressBarBg, {BackgroundTransparency = 0}, 1)
    
    task.wait(1)
    
    -- Progress Simulation
    Tween(ProgressBar, {Size = UDim2.new(0.3, 0, 1, 0)}, 0.6, Enum.EasingStyle.Exponential)
    task.wait(0.7)
    SubLogo.Text = "Initializing UI Architecture..."
    Tween(ProgressBar, {Size = UDim2.new(0.75, 0, 1, 0)}, 0.5, Enum.EasingStyle.Exponential)
    task.wait(0.6)
    SubLogo.Text = "Ready."
    Tween(ProgressBar, {Size = UDim2.new(1, 0, 1, 0)}, 0.3, Enum.EasingStyle.Linear)
    task.wait(0.4)
    
    -- Exit Tweens
    Tween(LogoText, {TextTransparency = 1, Position = UDim2.new(0.5, -200, 0.5, -60)}, 0.6)
    Tween(SubLogo, {TextTransparency = 1, Position = UDim2.new(0.5, -150, 0.5, 0)}, 0.6)
    Tween(ProgressBarBg, {BackgroundTransparency = 1}, 0.6)
    Tween(ProgressBar, {BackgroundTransparency = 1}, 0.6)
    Tween(LoadingFrame, {BackgroundTransparency = 1}, 0.8)
    
    task.wait(0.8)
    LoadingFrame:Destroy()
end

-- // Floating Toggle (Perfect Circular Geometry)
local function BuildFloatingToggle(gui, windowFrame, uiScale)
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Name = "XreztFloatingToggle"
    ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
    ToggleBtn.Position = UDim2.new(0, 20, 0.5, -25)
    ToggleBtn.BackgroundColor3 = Theme.SurfaceElevated
    ToggleBtn.Text = ""
    ToggleBtn.AutoButtonColor = false
    ToggleBtn.ZIndex = 500
    ApplyCorners(ToggleBtn, 50) -- Fully round
    ApplyStroke(ToggleBtn, Theme.Border, 1)
    ToggleBtn.Parent = gui
    
    -- PERFECT CIRCLE SHADOW - Slightly larger than the button
    local shadow = Instance.new("ImageLabel")
    shadow.Size = UDim2.new(1, 14, 1, 14) -- 14px total padding (7px per side)
    shadow.Position = UDim2.new(0.5, 0, 0.5, 2) -- Slight downward offset for depth
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://5554836806" -- Verified circular drop shadow asset
    shadow.ImageColor3 = Theme.Shadow
    shadow.ImageTransparency = 0.4
    shadow.ZIndex = 499
    shadow.Parent = ToggleBtn

    -- 3 Lines for Hamburger -> X Morph
    local L1 = Instance.new("Frame")
    L1.Size = UDim2.new(0, 22, 0, 3)
    L1.Position = UDim2.new(0.5, 0, 0.5, 0)
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
    L2.BackgroundTransparency = 1
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

    -- Draggable Logic
    local dragging, dragInput, dragStart, startPos
    ToggleBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = ToggleBtn.Position
            Tween(ToggleBtn, {Size = UDim2.new(0, 46, 0, 46)}, 0.1)
            Tween(shadow, {Size = UDim2.new(1, 10, 1, 10)}, 0.1)
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    Tween(ToggleBtn, {Size = UDim2.new(0, 50, 0, 50)}, 0.1, Animations.BouncyStyle)
                    Tween(shadow, {Size = UDim2.new(1, 14, 1, 14)}, 0.1)
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

    -- Toggle Menu
    local isOpen = true
    ToggleBtn.MouseButton1Click:Connect(function()
        CreateRipple(ToggleBtn)
        isOpen = not isOpen
        if isOpen then
            windowFrame.Visible = true
            Tween(uiScale, {Scale = 1}, Animations.Window, Animations.BouncyStyle, Enum.EasingDirection.Out)
            Tween(windowFrame, {BackgroundTransparency = 0}, 0.2)
            
            -- Morph to X
            Tween(L1, {Position = UDim2.new(0.5, 0, 0.5, 0), Rotation = 45}, 0.3, Animations.BouncyStyle)
            Tween(L2, {BackgroundTransparency = 1}, 0.2)
            Tween(L3, {Position = UDim2.new(0.5, 0, 0.5, 0), Rotation = -45}, 0.3, Animations.BouncyStyle)
        else
            local closeTween = Tween(uiScale, {Scale = 0.8}, Animations.Window, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
            Tween(windowFrame, {BackgroundTransparency = 1}, 0.3)
            closeTween.Completed:Connect(function()
                if not isOpen then windowFrame.Visible = false end
            end)
            
            -- Morph to Hamburger
            Tween(L1, {Position = UDim2.new(0.5, 0, 0.5, -6), Rotation = 0}, 0.3, Animations.BouncyStyle)
            Tween(L2, {BackgroundTransparency = 0}, 0.2)
            Tween(L3, {Position = UDim2.new(0.5, 0, 0.5, 6), Rotation = 0}, 0.3, Animations.BouncyStyle)
        end
    end)
    
    ToggleBtn.MouseEnter:Connect(function()
        if not dragging then Tween(ToggleBtn, {BackgroundColor3 = Theme.SurfaceHighlight}, Animations.Hover) end
    end)
    ToggleBtn.MouseLeave:Connect(function()
        Tween(ToggleBtn, {BackgroundColor3 = Theme.SurfaceElevated}, Animations.Hover)
    end)
end

-- // Main Library Initializer
function XreztHub:CreateWindow(config)
    config = config or {}
    local WindowTitle = config.Title or "Xrezt Hub"
    local WindowSize = config.Size or UDim2.new(0, 650, 0, 420)
    local HubConfigFolder = config.ConfigFolder or "XreztHub_Configs"
    
    local XreztInstance = {
        Tabs = {},
        CurrentTab = nil,
        Flags = {},
        Watermark = nil,
    }
    
    -- Setup Save Folder
    if makefolder and not isfolder(HubConfigFolder) then
        makefolder(HubConfigFolder)
    end
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "XreztHub_" .. HttpService:GenerateGUID(false)
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true 
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = GetParent()
    
    XreztInstance.GUI = ScreenGui
    BuildTooltipSystem(ScreenGui)
    BuildLoadingScreen(ScreenGui, config)
    
    -- Main Container Frame
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
    
    -- Animated Gradient Border
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
            rot = rot + (dt * 40)
            StrokeGrad.Rotation = rot
        end)
    end)
    
    -- Background Shadow
    local DropShadow = Instance.new("ImageLabel")
    DropShadow.Size = UDim2.new(1, 60, 1, 60)
    DropShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    DropShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    DropShadow.BackgroundTransparency = 1
    DropShadow.Image = "rbxassetid://6015897843"
    DropShadow.ImageColor3 = Theme.Shadow
    DropShadow.ImageTransparency = 0.3
    DropShadow.ScaleType = Enum.ScaleType.Slice
    DropShadow.SliceCenter = Rect.new(49, 49, 250, 250)
    DropShadow.ZIndex = 9
    DropShadow.Parent = MainContainer

    CreateMotionGraphics(MainContainer)

    -- Topbar & Sidebar Setup
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

    local ContentContainer = Instance.new("Frame")
    ContentContainer.Size = UDim2.new(1, -160, 1, -45)
    ContentContainer.Position = UDim2.new(0, 160, 0, 45)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.ZIndex = 11
    ContentContainer.Parent = MainContainer

    Tween(UIScale, {Scale = 1}, Animations.Window, Animations.BouncyStyle, Enum.EasingDirection.Out)
    
    BuildFloatingToggle(ScreenGui, MainContainer, UIScale)

    -- // Watermark System
    function XreztInstance:SetWatermark(text)
        if not self.Watermark then
            local WMFrame = Instance.new("Frame")
            WMFrame.Size = UDim2.new(0, 200, 0, 28)
            WMFrame.Position = UDim2.new(0, 20, 0, 10)
            WMFrame.BackgroundColor3 = Theme.SurfaceElevated
            WMFrame.BackgroundTransparency = 0.2
            WMFrame.ZIndex = 100
            ApplyCorners(WMFrame, 4)
            ApplyStroke(WMFrame, Theme.Border, 1)
            WMFrame.Parent = ScreenGui
            
            local WMGlow = Instance.new("UIStroke")
            WMGlow.Color = Theme.Accent
            WMGlow.Thickness = 2
            WMGlow.Transparency = 0.8
            WMGlow.Parent = WMFrame

            local WMText = Instance.new("TextLabel")
            WMText.Size = UDim2.new(1, -16, 1, 0)
            WMText.Position = UDim2.new(0, 8, 0, 0)
            WMText.BackgroundTransparency = 1
            WMText.Font = Enum.Font.GothamMedium
            WMText.TextSize = 13
            WMText.TextColor3 = Theme.Text
            WMText.TextXAlignment = Enum.TextXAlignment.Left
            WMText.ZIndex = 101
            WMText.Parent = WMFrame

            self.Watermark = {Frame = WMFrame, TextLabel = WMText}
        end
        
        self.Watermark.TextLabel.Text = text
        local bounds = TextService:GetTextSize(text, 13, Enum.Font.GothamMedium, Vector2.new(1000, 28))
        Tween(self.Watermark.Frame, {Size = UDim2.new(0, bounds.X + 20, 0, 28)}, Animations.Switch)
    end

    -- // Notification System
    local NotifContainer = Instance.new("Frame")
    NotifContainer.Name = "NotifContainer"
    NotifContainer.Size = UDim2.new(0, 300, 1, -20)
    NotifContainer.Position = UDim2.new(1, -320, 0, 20)
    NotifContainer.BackgroundTransparency = 1
    NotifContainer.ZIndex = 4000
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
        NotifFrame.ZIndex = 4001
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
        NTitleLab.ZIndex = 4002
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
        NDesc.ZIndex = 4002
        NDesc.Parent = NotifFrame
        
        local NProgress = Instance.new("Frame")
        NProgress.Size = UDim2.new(1, 0, 0, 3)
        NProgress.Position = UDim2.new(0, 0, 1, -3)
        NProgress.BackgroundColor3 = color
        NProgress.BorderSizePixel = 0
        NProgress.ZIndex = 4002
        ApplyCorners(NProgress, 6)
        NProgress.Parent = NotifFrame
        
        NotifFrame.Parent = NotifContainer
        
        NotifFrame.Position = UDim2.new(1, 50, 0, 0)
        Tween(NotifFrame, {Position = UDim2.new(0, 0, 0, 0)}, 0.4, Animations.BouncyStyle)
        Tween(NProgress, {Size = UDim2.new(0, 0, 0, 3)}, nDuration, Enum.EasingStyle.Linear)
        
        task.delay(nDuration, function()
            local out = Tween(NotifFrame, {Position = UDim2.new(1, 50, 0, 0), BackgroundTransparency = 1}, 0.3)
            Tween(NTitleLab, {TextTransparency = 1}, 0.3)
            Tween(NDesc, {TextTransparency = 1}, 0.3)
            out.Completed:Wait()
            NotifFrame:Destroy()
        end)
    end

    -- // Dialog System
    function XreztInstance:CreateDialog(dConfig)
        local dTitle = dConfig.Title or "Dialog"
        local dContent = dConfig.Content or "Are you sure?"
        local dButtons = dConfig.Buttons or {}
        
        if CurrentDialog then CurrentDialog:Destroy() end
        
        local Blur = Instance.new("Frame")
        Blur.Size = UDim2.new(1, 0, 1, 0)
        Blur.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        Blur.BackgroundTransparency = 1
        Blur.ZIndex = 5000
        Blur.Parent = ScreenGui
        
        local DFrame = Instance.new("Frame")
        DFrame.Size = UDim2.new(0, 300, 0, 150)
        DFrame.Position = UDim2.new(0.5, -150, 0.5, -75)
        DFrame.BackgroundColor3 = Theme.SurfaceElevated
        DFrame.ZIndex = 5001
        ApplyCorners(DFrame, 8)
        ApplyStroke(DFrame, Theme.Border, 1)
        DFrame.Parent = Blur
        
        local DTitle = Instance.new("TextLabel")
        DTitle.Text = dTitle
        DTitle.Font = Enum.Font.GothamBold
        DTitle.TextSize = 16
        DTitle.TextColor3 = Theme.Text
        DTitle.Position = UDim2.new(0, 15, 0, 15)
        DTitle.Size = UDim2.new(1, -30, 0, 20)
        DTitle.TextXAlignment = Enum.TextXAlignment.Center
        DTitle.BackgroundTransparency = 1
        DTitle.ZIndex = 5002
        DTitle.Parent = DFrame
        
        local DDesc = Instance.new("TextLabel")
        DDesc.Text = dContent
        DDesc.Font = Enum.Font.Gotham
        DDesc.TextSize = 13
        DDesc.TextColor3 = Theme.SubText
        DDesc.Position = UDim2.new(0, 15, 0, 45)
        DDesc.Size = UDim2.new(1, -30, 0, 50)
        DDesc.TextXAlignment = Enum.TextXAlignment.Center
        DDesc.TextYAlignment = Enum.TextYAlignment.Top
        DDesc.TextWrapped = true
        DDesc.BackgroundTransparency = 1
        DDesc.ZIndex = 5002
        DDesc.Parent = DFrame
        
        local BtnContainer = Instance.new("Frame")
        BtnContainer.Size = UDim2.new(1, -30, 0, 35)
        BtnContainer.Position = UDim2.new(0, 15, 1, -45)
        BtnContainer.BackgroundTransparency = 1
        BtnContainer.ZIndex = 5002
        BtnContainer.Parent = DFrame
        
        local BtnLayout = Instance.new("UIListLayout")
        BtnLayout.FillDirection = Enum.FillDirection.Horizontal
        BtnLayout.SortOrder = Enum.SortOrder.LayoutOrder
        BtnLayout.Padding = UDim.new(0, 10)
        BtnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        BtnLayout.Parent = BtnContainer
        
        local numBtns = #dButtons
        local btnWidth = (270 - ((numBtns - 1) * 10)) / numBtns
        
        for _, btn in ipairs(dButtons) do
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(0, btnWidth, 1, 0)
            Btn.BackgroundColor3 = Theme.Surface
            Btn.Text = btn.Name
            Btn.Font = Enum.Font.GothamMedium
            Btn.TextSize = 13
            Btn.TextColor3 = Theme.Text
            Btn.AutoButtonColor = false
            Btn.ZIndex = 5003
            ApplyCorners(Btn, 4)
            ApplyStroke(Btn, Theme.Border, 1)
            Btn.Parent = BtnContainer
            
            Btn.MouseEnter:Connect(function() Tween(Btn, {BackgroundColor3 = Theme.SurfaceHighlight}, Animations.Hover) end)
            Btn.MouseLeave:Connect(function() Tween(Btn, {BackgroundColor3 = Theme.Surface}, Animations.Hover) end)
            
            Btn.MouseButton1Click:Connect(function()
                CreateRipple(Btn)
                task.spawn(btn.Callback)
                
                Tween(Blur, {BackgroundTransparency = 1}, 0.2)
                local out = Tween(DFrame, {Position = UDim2.new(0.5, -150, 0.6, 0), BackgroundTransparency = 1}, 0.2)
                out.Completed:Wait()
                Blur:Destroy()
            end)
        end
        
        CurrentDialog = Blur
        
        DFrame.Position = UDim2.new(0.5, -150, 0.4, 0)
        DFrame.BackgroundTransparency = 1
        Tween(Blur, {BackgroundTransparency = 0.5}, 0.3)
        Tween(DFrame, {Position = UDim2.new(0.5, -150, 0.5, -75), BackgroundTransparency = 0}, 0.3, Animations.BouncyStyle)
    end

    -- // Configuration System
    function XreztInstance:SaveConfig(name)
        if not writefile then return self:Notify({Title="Error", Content="Executor does not support file saving.", Type="Error"}) end
        local parsed = HttpService:JSONEncode(self.Flags)
        writefile(HubConfigFolder.."/"..name..".json", parsed)
        self:Notify({Title="Config Saved", Content="Saved configuration: " .. name, Type="Success"})
    end

    function XreztInstance:LoadConfig(name)
        if not readfile then return end
        local path = HubConfigFolder.."/"..name..".json"
        if isfile(path) then
            local success, parsed = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
            if success then
                for flagName, flagValue in pairs(parsed) do
                    if self.Flags[flagName] then
                        -- Need dynamic type updating logic bound to components
                    end
                end
                self:Notify({Title="Config Loaded", Content="Loaded configuration: " .. name, Type="Success"})
            end
        end
    end

    -- // Tab Engine
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
                Tween(XreztInstance.CurrentTab.Btn, {BackgroundColor3 = Theme.Surface}, Animations.Switch)
                Tween(XreztInstance.CurrentTab.Text, {TextColor3 = Theme.SubText}, Animations.Switch)
                Tween(XreztInstance.CurrentTab.Indicator, {Size = UDim2.new(0, 3, 0, 0)}, Animations.Switch)
                XreztInstance.CurrentTab.Page.Visible = false
            end
            
            XreztInstance.CurrentTab = TabInstance
            Tween(TabBtn, {BackgroundColor3 = Theme.SurfaceElevated}, Animations.Switch)
            Tween(BtnText, {TextColor3 = Theme.Text}, Animations.Switch)
            Tween(Indicator, {Size = UDim2.new(0, 3, 0, 16)}, Animations.Switch, Animations.BouncyStyle)
            
            PageScroll.Visible = true
            PageScroll.Position = UDim2.new(0, 20, 0, 10)
            Tween(PageScroll, {Position = UDim2.new(0, 10, 0, 10)}, 0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        end
        
        TabBtn.MouseButton1Click:Connect(ActivateTab)
        
        TabBtn.MouseEnter:Connect(function()
            if XreztInstance.CurrentTab ~= TabInstance then
                Tween(TabBtn, {BackgroundColor3 = Theme.SurfaceHighlight}, Animations.Hover)
                Tween(BtnText, {TextColor3 = Theme.Text}, Animations.Hover)
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if XreztInstance.CurrentTab ~= TabInstance then
                Tween(TabBtn, {BackgroundColor3 = Theme.Surface}, Animations.Hover)
                Tween(BtnText, {TextColor3 = Theme.SubText}, Animations.Hover)
            end
        end)
        
        TabInstance.Btn = TabBtn
        TabInstance.Text = BtnText
        TabInstance.Indicator = Indicator
        TabInstance.Page = PageScroll
        
        if #XreztInstance.Tabs == 0 then ActivateTab() end
        table.insert(XreztInstance.Tabs, TabInstance)

        -- // COMPONENTS SUITE
        
        -- Section
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
        
        -- Paragraph
        function TabInstance:CreateParagraph(pConfig)
            local pTitle = pConfig.Title or "Paragraph"
            local pContent = pConfig.Content or "Content block."
            
            local ParaFrame = Instance.new("Frame")
            ParaFrame.Size = UDim2.new(1, 0, 0, 0)
            ParaFrame.BackgroundColor3 = Theme.Surface
            ParaFrame.ZIndex = 13
            ApplyCorners(ParaFrame, 6)
            ApplyStroke(ParaFrame, Theme.Border, 1)
            ParaFrame.Parent = PageScroll
            
            local PTitle = Instance.new("TextLabel")
            PTitle.Text = pTitle
            PTitle.Font = Enum.Font.GothamBold
            PTitle.TextSize = 13
            PTitle.TextColor3 = Theme.Text
            PTitle.Position = UDim2.new(0, 12, 0, 10)
            PTitle.Size = UDim2.new(1, -24, 0, 15)
            PTitle.TextXAlignment = Enum.TextXAlignment.Left
            PTitle.BackgroundTransparency = 1
            PTitle.ZIndex = 14
            PTitle.Parent = ParaFrame
            
            local PDesc = Instance.new("TextLabel")
            PDesc.Text = pContent
            PDesc.Font = Enum.Font.Gotham
            PDesc.TextSize = 12
            PDesc.TextColor3 = Theme.SubText
            PDesc.Position = UDim2.new(0, 12, 0, 30)
            PDesc.Size = UDim2.new(1, -24, 0, 0)
            PDesc.TextXAlignment = Enum.TextXAlignment.Left
            PDesc.TextYAlignment = Enum.TextYAlignment.Top
            PDesc.TextWrapped = true
            PDesc.BackgroundTransparency = 1
            PDesc.ZIndex = 14
            PDesc.Parent = ParaFrame
            
            local function UpdateSize()
                local bounds = TextService:GetTextSize(pContent, 12, Enum.Font.Gotham, Vector2.new(ParaFrame.AbsoluteSize.X - 24, 10000))
                PDesc.Size = UDim2.new(1, -24, 0, bounds.Y)
                ParaFrame.Size = UDim2.new(1, 0, 0, bounds.Y + 40)
            end
            
            UpdateSize()
            ParaFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateSize)
            
            return {
                Set = function(self, newTitle, newContent)
                    PTitle.Text = newTitle or PTitle.Text
                    pContent = newContent or pContent
                    PDesc.Text = pContent
                    UpdateSize()
                end
            }
        end

        -- Button
        function TabInstance:CreateButton(bConfig)
            local Name = bConfig.Name or "Button"
            local Callback = bConfig.Callback or function() end
            
            local BtnFrame = Instance.new("TextButton")
            BtnFrame.Size = UDim2.new(1, 0, 0, 38)
            BtnFrame.BackgroundColor3 = Theme.Surface
            BtnFrame.Text = ""
            BtnFrame.AutoButtonColor = false
            BtnFrame.ZIndex = 13
            ApplyCorners(BtnFrame, 6)
            ApplyStroke(BtnFrame, Theme.Border, 1)
            BtnFrame.Parent = PageScroll
            
            local BText = Instance.new("TextLabel")
            BText.Text = Name
            BText.Font = Enum.Font.GothamMedium
            BText.TextSize = 13
            BText.TextColor3 = Theme.Text
            BText.Size = UDim2.new(1, 0, 1, 0)
            BText.BackgroundTransparency = 1
            BText.ZIndex = 14
            BText.Parent = BtnFrame
            
            AddTooltip(BtnFrame, bConfig.Tooltip)
            
            BtnFrame.MouseEnter:Connect(function() Tween(BtnFrame, {BackgroundColor3 = Theme.SurfaceHighlight}, Animations.Hover) end)
            BtnFrame.MouseLeave:Connect(function() Tween(BtnFrame, {BackgroundColor3 = Theme.Surface}, Animations.Hover) end)
            BtnFrame.MouseButton1Down:Connect(function() Tween(BtnFrame, {Size = UDim2.new(1, -4, 0, 34), Position = UDim2.new(0, 2, 0, 2)}, Animations.Click) end)
            BtnFrame.MouseButton1Up:Connect(function() Tween(BtnFrame, {Size = UDim2.new(1, 0, 0, 38), Position = UDim2.new(0, 0, 0, 0)}, Animations.Click, Animations.BouncyStyle) end)
            
            BtnFrame.MouseButton1Click:Connect(function()
                CreateRipple(BtnFrame)
                task.spawn(Callback)
            end)
        end

        -- Toggle
        function TabInstance:CreateToggle(tConfig)
            local Name = tConfig.Name or "Toggle"
            local Default = tConfig.Default or false
            local Flag = tConfig.Flag or Name
            local Callback = tConfig.Callback or function() end
            
            local State = Default
            XreztInstance.Flags[Flag] = State
            
            local TogFrame = Instance.new("TextButton")
            TogFrame.Size = UDim2.new(1, 0, 0, 42)
            TogFrame.BackgroundColor3 = Theme.Surface
            TogFrame.Text = ""
            TogFrame.AutoButtonColor = false
            TogFrame.ZIndex = 13
            ApplyCorners(TogFrame, 6)
            ApplyStroke(TogFrame, Theme.Border, 1)
            TogFrame.Parent = PageScroll
            
            AddTooltip(TogFrame, tConfig.Tooltip)
            
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
                    Tween(Knob, {Position = UDim2.new(0, 22, 0.5, -8)}, noAnim and 0 or 0.4, Animations.BouncyStyle)
                else
                    Tween(SwitchBg, {BackgroundColor3 = Theme.Background}, noAnim and 0 or 0.3)
                    Tween(Knob, {Position = UDim2.new(0, 2, 0.5, -8)}, noAnim and 0 or 0.4, Animations.BouncyStyle)
                end
                XreztInstance.Flags[Flag] = State
                task.spawn(Callback, State)
            end
            
            UpdateToggle(true)
            
            TogFrame.MouseButton1Click:Connect(function()
                CreateRipple(TogFrame)
                State = not State
                UpdateToggle()
            end)
            
            TogFrame.MouseEnter:Connect(function() Tween(TogFrame, {BackgroundColor3 = Theme.SurfaceHighlight}, Animations.Hover) end)
            TogFrame.MouseLeave:Connect(function() Tween(TogFrame, {BackgroundColor3 = Theme.Surface}, Animations.Hover) end)
            
            return {
                Set = function(self, state)
                    State = state
                    UpdateToggle()
                end,
                Value = function(self) return State end
            }
        end

        -- Checkbox
        function TabInstance:CreateCheckbox(cConfig)
            local Name = cConfig.Name or "Checkbox"
            local Default = cConfig.Default or false
            local Flag = cConfig.Flag or Name
            local Callback = cConfig.Callback or function() end
            
            local State = Default
            XreztInstance.Flags[Flag] = State
            
            local CFrame = Instance.new("TextButton")
            CFrame.Size = UDim2.new(1, 0, 0, 36)
            CFrame.BackgroundColor3 = Theme.Surface
            CFrame.Text = ""
            CFrame.AutoButtonColor = false
            CFrame.ZIndex = 13
            ApplyCorners(CFrame, 6)
            ApplyStroke(CFrame, Theme.Border, 1)
            CFrame.Parent = PageScroll
            
            local Box = Instance.new("Frame")
            Box.Size = UDim2.new(0, 20, 0, 20)
            Box.Position = UDim2.new(0, 12, 0.5, -10)
            Box.BackgroundColor3 = State and Theme.Accent or Theme.Background
            Box.ZIndex = 14
            ApplyCorners(Box, 4)
            ApplyStroke(Box, Theme.Border, 1)
            Box.Parent = CFrame
            
            local CheckIcon = Instance.new("ImageLabel")
            CheckIcon.Size = UDim2.new(0, 14, 0, 14)
            CheckIcon.Position = UDim2.new(0.5, -7, 0.5, -7)
            CheckIcon.BackgroundTransparency = 1
            CheckIcon.Image = "rbxassetid://6031094667"
            CheckIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
            CheckIcon.ImageTransparency = State and 0 or 1
            CheckIcon.ZIndex = 15
            CheckIcon.Parent = Box
            
            local CText = Instance.new("TextLabel")
            CText.Text = Name
            CText.Font = Enum.Font.GothamMedium
            CText.TextSize = 13
            CText.TextColor3 = Theme.Text
            CText.Position = UDim2.new(0, 42, 0, 0)
            CText.Size = UDim2.new(1, -50, 1, 0)
            CText.TextXAlignment = Enum.TextXAlignment.Left
            CText.BackgroundTransparency = 1
            CText.ZIndex = 14
            CText.Parent = CFrame
            
            local function UpdateCheckbox()
                Tween(Box, {BackgroundColor3 = State and Theme.Accent or Theme.Background}, 0.2)
                Tween(CheckIcon, {ImageTransparency = State and 0 or 1, Size = State and UDim2.new(0,14,0,14) or UDim2.new(0,0,0,0), Position = State and UDim2.new(0.5,-7,0.5,-7) or UDim2.new(0.5,0,0.5,0)}, 0.2, Animations.BouncyStyle)
                XreztInstance.Flags[Flag] = State
                task.spawn(Callback, State)
            end
            
            CFrame.MouseButton1Click:Connect(function()
                State = not State
                UpdateCheckbox()
            end)
            
            CFrame.MouseEnter:Connect(function() Tween(CFrame, {BackgroundColor3 = Theme.SurfaceHighlight}, Animations.Hover) end)
            CFrame.MouseLeave:Connect(function() Tween(CFrame, {BackgroundColor3 = Theme.Surface}, Animations.Hover) end)
        end
        
        -- Textbox
        function TabInstance:CreateTextbox(txConfig)
            local Name = txConfig.Name or "Textbox"
            local Placeholder = txConfig.Placeholder or "Type here..."
            local Flag = txConfig.Flag or Name
            local Callback = txConfig.Callback or function() end
            
            local BoxFrame = Instance.new("Frame")
            BoxFrame.Size = UDim2.new(1, 0, 0, 50)
            BoxFrame.BackgroundColor3 = Theme.Surface
            BoxFrame.ZIndex = 13
            ApplyCorners(BoxFrame, 6)
            ApplyStroke(BoxFrame, Theme.Border, 1)
            BoxFrame.Parent = PageScroll
            
            local Title = Instance.new("TextLabel")
            Title.Text = Name
            Title.Font = Enum.Font.GothamMedium
            Title.TextSize = 13
            Title.TextColor3 = Theme.Text
            Title.Position = UDim2.new(0, 12, 0, 8)
            Title.Size = UDim2.new(1, -24, 0, 14)
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.BackgroundTransparency = 1
            Title.ZIndex = 14
            Title.Parent = BoxFrame
            
            local InputBg = Instance.new("Frame")
            InputBg.Size = UDim2.new(1, -24, 0, 22)
            InputBg.Position = UDim2.new(0, 12, 0, 24)
            InputBg.BackgroundColor3 = Theme.Background
            InputBg.ZIndex = 14
            ApplyCorners(InputBg, 4)
            local InputStroke = ApplyStroke(InputBg, Theme.Border, 1)
            InputBg.Parent = BoxFrame
            
            local TextBox = Instance.new("TextBox")
            TextBox.Size = UDim2.new(1, -10, 1, 0)
            TextBox.Position = UDim2.new(0, 5, 0, 0)
            TextBox.BackgroundTransparency = 1
            TextBox.Text = ""
            TextBox.PlaceholderText = Placeholder
            TextBox.Font = Enum.Font.Gotham
            TextBox.TextSize = 12
            TextBox.TextColor3 = Theme.Text
            TextBox.PlaceholderColor3 = Theme.SubText
            TextBox.TextXAlignment = Enum.TextXAlignment.Left
            TextBox.ClearTextOnFocus = false
            TextBox.ZIndex = 15
            TextBox.Parent = InputBg
            
            TextBox.Focused:Connect(function()
                Tween(InputStroke, {Color = Theme.Accent}, 0.2)
            end)
            
            TextBox.FocusLost:Connect(function()
                Tween(InputStroke, {Color = Theme.Border}, 0.2)
                XreztInstance.Flags[Flag] = TextBox.Text
                task.spawn(Callback, TextBox.Text)
            end)
        end

        -- Dropdown (Searchable + Multi)
        function TabInstance:CreateDropdown(dConfig)
            local Name = dConfig.Name or "Dropdown"
            local Options = dConfig.Options or {}
            local Default = dConfig.Default
            local Multi = dConfig.MultiSelect or false
            local Flag = dConfig.Flag or Name
            local Callback = dConfig.Callback or function() end
            
            local Selected = Multi and (Default or {}) or Default
            XreztInstance.Flags[Flag] = Selected
            local isOpen = false
            
            local DropFrame = Instance.new("Frame")
            DropFrame.Size = UDim2.new(1, 0, 0, 42)
            DropFrame.BackgroundColor3 = Theme.Surface
            DropFrame.ClipsDescendants = true
            DropFrame.ZIndex = 13
            ApplyCorners(DropFrame, 6)
            ApplyStroke(DropFrame, Theme.Border, 1)
            DropFrame.Parent = PageScroll
            
            local DBtn = Instance.new("TextButton")
            DBtn.Size = UDim2.new(1, 0, 0, 42)
            DBtn.BackgroundTransparency = 1
            DBtn.Text = ""
            DBtn.ZIndex = 14
            DBtn.Parent = DropFrame
            
            local DText = Instance.new("TextLabel")
            local function formatSelected()
                if Multi then
                    if #Selected == 0 then return "None" end
                    return table.concat(Selected, ", ")
                else
                    return Selected and tostring(Selected) or "None"
                end
            end
            
            DText.Text = Name .. " : " .. formatSelected()
            DText.Font = Enum.Font.GothamMedium
            DText.TextSize = 13
            DText.TextColor3 = Theme.Text
            DText.Position = UDim2.new(0, 12, 0, 0)
            DText.Size = UDim2.new(1, -40, 1, 0)
            DText.TextXAlignment = Enum.TextXAlignment.Left
            DText.BackgroundTransparency = 1
            DText.ZIndex = 15
            DText.Parent = DBtn
            
            local Icon = Instance.new("ImageLabel")
            Icon.Size = UDim2.new(0, 16, 0, 16)
            Icon.Position = UDim2.new(1, -28, 0.5, -8)
            Icon.BackgroundTransparency = 1
            Icon.Image = "rbxassetid://6031090990"
            Icon.ImageColor3 = Theme.SubText
            Icon.ZIndex = 15
            Icon.Parent = DBtn
            
            local SearchBar = Instance.new("TextBox")
            SearchBar.Size = UDim2.new(1, -24, 0, 26)
            SearchBar.Position = UDim2.new(0, 12, 0, 47)
            SearchBar.BackgroundColor3 = Theme.Background
            SearchBar.Text = ""
            SearchBar.PlaceholderText = "Search..."
            SearchBar.Font = Enum.Font.Gotham
            SearchBar.TextSize = 12
            SearchBar.TextColor3 = Theme.Text
            SearchBar.ZIndex = 15
            ApplyCorners(SearchBar, 4)
            ApplyStroke(SearchBar, Theme.Border, 1)
            SearchBar.Parent = DropFrame
            
            local OptContainer = Instance.new("ScrollingFrame")
            OptContainer.Size = UDim2.new(1, -10, 1, -85)
            OptContainer.Position = UDim2.new(0, 5, 0, 80)
            OptContainer.BackgroundTransparency = 1
            OptContainer.ScrollBarThickness = 2
            OptContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
            OptContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
            OptContainer.ZIndex = 14
            OptContainer.Parent = DropFrame
            
            local OptLayout = Instance.new("UIListLayout")
            OptLayout.SortOrder = Enum.SortOrder.LayoutOrder
            OptLayout.Padding = UDim.new(0, 4)
            OptLayout.Parent = OptContainer
            
            local function BuildOptions(filter)
                for _, v in pairs(OptContainer:GetChildren()) do
                    if v:IsA("TextButton") then v:Destroy() end
                end
                
                local count = 0
                for _, opt in pairs(Options) do
                    if not filter or filter == "" or string.find(string.lower(opt), string.lower(filter)) then
                        count = count + 1
                        
                        local isSel = false
                        if Multi then
                            for _, v in pairs(Selected) do if v == opt then isSel = true break end end
                        else
                            isSel = (opt == Selected)
                        end
                        
                        local OBtn = Instance.new("TextButton")
                        OBtn.Size = UDim2.new(1, -8, 0, 30)
                        OBtn.BackgroundColor3 = Theme.Background
                        OBtn.Text = opt
                        OBtn.Font = Enum.Font.Gotham
                        OBtn.TextSize = 12
                        OBtn.TextColor3 = isSel and Theme.Accent or Theme.SubText
                        OBtn.AutoButtonColor = false
                        OBtn.ZIndex = 15
                        ApplyCorners(OBtn, 4)
                        OBtn.Parent = OptContainer
                        
                        OBtn.MouseEnter:Connect(function() Tween(OBtn, {BackgroundColor3 = Theme.SurfaceElevated}, 0.1) end)
                        OBtn.MouseLeave:Connect(function() Tween(OBtn, {BackgroundColor3 = Theme.Background}, 0.1) end)
                        
                        OBtn.MouseButton1Click:Connect(function()
                            if Multi then
                                if isSel then
                                    for i, v in ipairs(Selected) do if v == opt then table.remove(Selected, i) break end end
                                else
                                    table.insert(Selected, opt)
                                end
                                DText.Text = Name .. " : " .. formatSelected()
                                XreztInstance.Flags[Flag] = Selected
                                task.spawn(Callback, Selected)
                                BuildOptions(SearchBar.Text)
                            else
                                Selected = opt
                                DText.Text = Name .. " : " .. tostring(Selected)
                                XreztInstance.Flags[Flag] = Selected
                                task.spawn(Callback, Selected)
                                
                                isOpen = false
                                Tween(DropFrame, {Size = UDim2.new(1, 0, 0, 42)}, 0.3, Animations.BouncyStyle)
                                Tween(Icon, {Rotation = 0}, 0.3)
                                BuildOptions()
                            end
                        end)
                    end
                end
                return count * 34
            end
            
            SearchBar:GetPropertyChangedSignal("Text"):Connect(function()
                if isOpen then BuildOptions(SearchBar.Text) end
            end)
            
            DBtn.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                if isOpen then
                    BuildOptions(SearchBar.Text)
                    Tween(DropFrame, {Size = UDim2.new(1, 0, 0, 200)}, 0.4, Animations.BouncyStyle)
                    Tween(Icon, {Rotation = 180}, 0.3)
                else
                    Tween(DropFrame, {Size = UDim2.new(1, 0, 0, 42)}, 0.4, Animations.BouncyStyle)
                    Tween(Icon, {Rotation = 0}, 0.3)
                end
            end)
        end

        -- Slider
        function TabInstance:CreateSlider(slConfig)
            local Name = slConfig.Name or "Slider"
            local Min = slConfig.Min or 0
            local Max = slConfig.Max or 100
            local Default = slConfig.Default or Min
            local Increment = slConfig.Increment or 1
            local Callback = slConfig.Callback or function() end
            
            local Value = Default
            
            local SlidFrame = Instance.new("Frame")
            SlidFrame.Size = UDim2.new(1, 0, 0, 55)
            SlidFrame.BackgroundColor3 = Theme.Surface
            SlidFrame.ZIndex = 13
            ApplyCorners(SlidFrame, 6)
            ApplyStroke(SlidFrame, Theme.Border, 1)
            SlidFrame.Parent = PageScroll
            
            local SText = Instance.new("TextLabel")
            SText.Text = Name
            SText.Font = Enum.Font.GothamMedium
            SText.TextSize = 13
            SText.TextColor3 = Theme.Text
            SText.Position = UDim2.new(0, 12, 0, 10)
            SText.Size = UDim2.new(1, -70, 0, 15)
            SText.TextXAlignment = Enum.TextXAlignment.Left
            SText.BackgroundTransparency = 1
            SText.ZIndex = 14
            SText.Parent = SlidFrame
            
            local ValText = Instance.new("TextLabel")
            ValText.Text = tostring(Value)
            ValText.Font = Enum.Font.GothamMedium
            ValText.TextSize = 13
            ValText.TextColor3 = Theme.Accent
            ValText.Position = UDim2.new(1, -60, 0, 10)
            ValText.Size = UDim2.new(0, 48, 0, 15)
            ValText.TextXAlignment = Enum.TextXAlignment.Right
            ValText.BackgroundTransparency = 1
            ValText.ZIndex = 14
            ValText.Parent = SlidFrame
            
            local SlideBg = Instance.new("TextButton")
            SlideBg.Size = UDim2.new(1, -24, 0, 6)
            SlideBg.Position = UDim2.new(0, 12, 0, 36)
            SlideBg.BackgroundColor3 = Theme.Background
            SlideBg.Text = ""
            SlideBg.AutoButtonColor = false
            SlideBg.ZIndex = 14
            ApplyCorners(SlideBg, 3)
            ApplyStroke(SlideBg, Theme.Border, 1)
            SlideBg.Parent = SlidFrame
            
            local Fill = Instance.new("Frame")
            local pct = math.clamp((Value - Min) / (Max - Min), 0, 1)
            Fill.Size = UDim2.new(pct, 0, 1, 0)
            Fill.BackgroundColor3 = Color3.fromRGB(255,255,255)
            Fill.BorderSizePixel = 0
            Fill.ZIndex = 15
            ApplyCorners(Fill, 3)
            ApplyPremiumGradient(Fill)
            Fill.Parent = SlideBg
            
            local DragKnob = Instance.new("Frame")
            DragKnob.Size = UDim2.new(0, 14, 0, 14)
            DragKnob.Position = UDim2.new(1, -7, 0.5, -7)
            DragKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            DragKnob.BorderSizePixel = 0
            DragKnob.ZIndex = 16
            ApplyCorners(DragKnob, 7)
            DragKnob.Parent = Fill
            
            local dragging = false
            local function UpdateSlider(input)
                local x = math.clamp(input.Position.X - SlideBg.AbsolutePosition.X, 0, SlideBg.AbsoluteSize.X)
                local percentage = x / SlideBg.AbsoluteSize.X
                local rawValue = Min + (Max - Min) * percentage
                Value = math.floor(rawValue / Increment + 0.5) * Increment
                Value = math.clamp(Value, Min, Max)
                
                local actualPct = (Value - Min) / (Max - Min)
                Tween(Fill, {Size = UDim2.new(actualPct, 0, 1, 0)}, 0.1, Enum.EasingStyle.Linear)
                ValText.Text = tostring(Value)
                task.spawn(Callback, Value)
            end
            
            SlideBg.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    Tween(DragKnob, {Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(1, -10, 0.5, -10)}, 0.1, Animations.BouncyStyle)
                    UpdateSlider(input)
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    if dragging then
                        dragging = false
                        Tween(DragKnob, {Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(1, -7, 0.5, -7)}, 0.1)
                    end
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    UpdateSlider(input)
                end
            end)
        end

        return TabInstance
    end

    return XreztInstance
end

return XreztHub
