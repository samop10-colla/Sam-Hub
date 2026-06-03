--[[
========================================================================================
        ____                         _          _   _       _     
       / ___|  __ _ _ __ ___  _     | |    _   | | | |_   _| |__  
       \___ \ / _` | '_ ` _ \(_)    | |   (_)  | |_| | | | | '_ \ 
        ___) | (_| | | | | | |_     | |___ _   |  _  | |_| | |_) |
       |____/ \__,_|_| |_| |_(_)    |_____(_)  |_| |_|\__,_|_.__/ 
                                                                  
      "Sam's Hub" Professional UI Framework — Light Emerald & Mint Royal Edition
========================================================================================
--]]

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Fallback safely to PlayerGui if CoreGui is restricted (e.g., standard executor environments vs studio testing)
local TargetGuiContainer = PlayerGui
pcall(function()
    if CoreGui and CoreGui:FindFirstChild("RobloxGui") then
        TargetGuiContainer = CoreGui
    end
end)

-- Custom Signal / Event Class to manage UI interactions cleanly
local Signal = {}
Signal.__index = Signal

function Signal.new()
    local self = setmetatable({}, Signal)
    self._bindable = Instance.new("BindableEvent")
    self._connections = {}
    return self
end

function Signal:Connect(callback)
    local connection = self._bindable.Event:Connect(callback)
    table.insert(self._connections, connection)
    return connection
end

function Signal:Fire(...)
    self._bindable:Fire(...)
end

function Signal:Destroy()
    for _, connection in ipairs(self._connections) do
        if connection.Connected then
            connection:Disconnect()
        end
    end
    self._bindable:Destroy()
    table.clear(self)
end

-- Smooth Dragging Utility
local Dragging = {}
function Dragging.Register(frame, handle)
    local dragStart = nil
    local startPos = nil
    local dragging = false
    
    local function update(input)
        local delta = input.Position - dragStart
        local targetPos = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X, 
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
        TweenService:Create(frame, TweenInfo.new(0.12, Enum.EasingStyle.OutQuad), {Position = targetPos}):Play()
    end
    
    handle.InputBegan:Connect(function(input)
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
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
end

-- Global Library Configuration and Styling Parameters
local Library = {
    Theme = {
        MainBackground = Color3.fromRGB(15, 23, 20),      -- Deep rich obsidian emerald
        SidebarBackground = Color3.fromRGB(11, 18, 15),   -- Dark forest shadow
        HeaderBackground = Color3.fromRGB(18, 28, 24),    -- Rich dark jade
        AccentColor = Color3.fromRGB(46, 184, 114),       -- Vibrant Emerald Mint
        AccentLight = Color3.fromRGB(96, 239, 159),       -- Pastel Mint
        AccentDark = Color3.fromRGB(24, 115, 71),         -- Forest green
        TextPrimary = Color3.fromRGB(240, 247, 244),      -- Cream Mint White
        TextSecondary = Color3.fromRGB(152, 168, 160),    -- Muted Sage
        ElementBackground = Color3.fromRGB(22, 34, 29),   -- Jade tint dark base
        ElementHover = Color3.fromRGB(28, 44, 38),        -- Interactive hover green-dark
        BorderColor = Color3.fromRGB(35, 54, 46)          -- Clean emerald border
    },
    Registry = {},
    Unloaded = false,
    UIKeybind = Enum.KeyCode.RightShift,
    ActiveWindow = nil
}

-- Utility: Safe Tweens
local function Tween(instance, info, propertyTable)
    if not instance then return nil end
    local tween = TweenService:Create(instance, info, propertyTable)
    tween:Play()
    return tween
end

-- Procedural Utility: Modern Rounded UI Element Builders
local UI = {}

function UI:CreateCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = radius or UDim.new(0, 6)
    corner.Parent = parent
    return corner
end

function UI:CreateStroke(parent, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Library.Theme.BorderColor
    stroke.Thickness = thickness or 1
    stroke.Transparency = transparency or 0
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = parent
    return stroke
end

function UI:CreateGradient(parent, colors, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new(colors)
    gradient.Rotation = rotation or 0
    gradient.Parent = parent
    return gradient
end

function UI:CreateShadow(parent)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.BackgroundTransparency = 1
    shadow.Position = UDim2.new(0, -15, 0, -15)
    shadow.Size = UDim2.new(1, 30, 1, 30)
    shadow.ZIndex = parent.ZIndex - 1
    shadow.Image = "rbxassetid://6015897843"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.55
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    shadow.Parent = parent
    return shadow
end

-- ========================================================================================
-- PART 1: THE ROYAL LOADING SCREEN SYSTEM
-- ========================================================================================
function Library:CreateLoadingScreen(customTitle)
    local titleText = customTitle or "SAM'S HUB"
    
    local LoadScreenGui = Instance.new("ScreenGui")
    LoadScreenGui.Name = "SamsHub_Loader"
    LoadScreenGui.ResetOnSpawn = false
    LoadScreenGui.IgnoreGuiInset = true
    LoadScreenGui.DisplayOrder = 9999
    LoadScreenGui.Parent = TargetGuiContainer
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(1, 0, 1, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(8, 12, 10)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = LoadScreenGui
    
    -- Radial background vignette
    local BackgroundOverlay = Instance.new("ImageLabel")
    BackgroundOverlay.Size = UDim2.new(1, 0, 1, 0)
    BackgroundOverlay.BackgroundTransparency = 1
    BackgroundOverlay.Image = "rbxassetid://13110901594"
    BackgroundOverlay.ImageColor3 = Color3.fromRGB(15, 30, 22)
    BackgroundOverlay.ImageTransparency = 0.2
    BackgroundOverlay.Parent = MainFrame

    local CenterPanel = Instance.new("Frame")
    CenterPanel.Size = UDim2.new(0, 380, 0, 240)
    CenterPanel.Position = UDim2.new(0.5, 0, 0.5, 0)
    CenterPanel.AnchorPoint = Vector2.new(0.5, 0.5)
    CenterPanel.BackgroundTransparency = 1
    CenterPanel.Parent = MainFrame
    
    -- Decorative Royal Ring (Rotation Graphic)
    local GlowingRing = Instance.new("ImageLabel")
    GlowingRing.Size = UDim2.new(0, 120, 0, 120)
    GlowingRing.Position = UDim2.new(0.5, 0, 0.4, -20)
    GlowingRing.AnchorPoint = Vector2.new(0.5, 0.5)
    GlowingRing.BackgroundTransparency = 1
    GlowingRing.Image = "rbxassetid://13109265215"
    GlowingRing.ImageColor3 = Library.Theme.AccentColor
    GlowingRing.ImageTransparency = 0.3
    GlowingRing.Parent = CenterPanel
    
    -- Smooth rotating loop
    local rotationThread = RunService.RenderStepped:Connect(function(delta)
        GlowingRing.Rotation = (GlowingRing.Rotation + (60 * delta)) % 360
    end)
    
    -- Text Label (Logo)
    local LogoLabel = Instance.new("TextLabel")
    LogoLabel.Size = UDim2.new(1, 0, 0, 40)
    LogoLabel.Position = UDim2.new(0, 0, 0.5, 35)
    LogoLabel.BackgroundTransparency = 1
    LogoLabel.Font = Enum.Font.FredokaOne
    LogoLabel.Text = titleText
    LogoLabel.TextColor3 = Library.Theme.TextPrimary
    LogoLabel.TextSize = 32
    LogoLabel.TextStrokeTransparency = 0.8
    LogoLabel.TextStrokeColor3 = Library.Theme.AccentColor
    LogoLabel.Parent = CenterPanel
    
    -- Subtitle status label
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(1, 0, 0, 20)
    StatusLabel.Position = UDim2.new(0, 0, 0.5, 75)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Font = Enum.Font.GothamMedium
    StatusLabel.Text = "Initializing secure runtime..."
    StatusLabel.TextColor3 = Library.Theme.TextSecondary
    StatusLabel.TextSize = 13
    StatusLabel.Parent = CenterPanel
    
    -- Progress Bar Track
    local TrackFrame = Instance.new("Frame")
    TrackFrame.Size = UDim2.new(0, 280, 0, 6)
    TrackFrame.Position = UDim2.new(0.5, 0, 0.5, 105)
    TrackFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    TrackFrame.BackgroundColor3 = Color3.fromRGB(18, 25, 22)
    TrackFrame.BorderSizePixel = 0
    TrackFrame.Parent = CenterPanel
    UI:CreateCorner(TrackFrame, UDim.new(1, 0))
    UI:CreateStroke(TrackFrame, Color3.fromRGB(30, 42, 36), 1)
    
    local ProgressBar = Instance.new("Frame")
    ProgressBar.Size = UDim2.new(0, 0, 1, 0)
    ProgressBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ProgressBar.BorderSizePixel = 0
    ProgressBar.Parent = TrackFrame
    UI:CreateCorner(ProgressBar, UDim.new(1, 0))
    
    local BarGradient = UI:CreateGradient(ProgressBar, {
        ColorSequenceKeypoint.new(0, Library.Theme.AccentColor),
        ColorSequenceKeypoint.new(1, Library.Theme.AccentLight)
    }, 0)
    
    -- Sequential Cinematic Loader Stages
    local loaderStages = {
        {progress = 0.15, status = "Loading framework core components..."},
        {progress = 0.40, status = "Configuring rendering matrices & styles..."},
        {progress = 0.65, status = "Verifying integrity authorization..."},
        {progress = 0.85, status = "Applying light emerald asset schemes..."},
        {progress = 1.00, status = "Execution ready. Welcome to Sam's Hub!"}
    }
    
    task.wait(0.6)
    for _, stage in ipairs(loaderStages) do
        StatusLabel.Text = stage.status
        Tween(ProgressBar, TweenInfo.new(0.7, Enum.EasingStyle.OutQuad), {Size = UDim2.new(stage.progress, 0, 1, 0)})
        task.wait(0.8)
    end
    
    rotationThread:Disconnect()
    
    -- Smooth Fade out
    Tween(MainFrame, TweenInfo.new(0.6, Enum.EasingStyle.OutQuad), {BackgroundTransparency = 1})
    Tween(BackgroundOverlay, TweenInfo.new(0.6, Enum.EasingStyle.OutQuad), {ImageTransparency = 1})
    Tween(GlowingRing, TweenInfo.new(0.4, Enum.EasingStyle.OutQuad), {ImageTransparency = 1})
    Tween(LogoLabel, TweenInfo.new(0.4, Enum.EasingStyle.OutQuad), {TextTransparency = 1, TextStrokeTransparency = 1})
    Tween(StatusLabel, TweenInfo.new(0.4, Enum.EasingStyle.OutQuad), {TextTransparency = 1})
    Tween(TrackFrame, TweenInfo.new(0.4, Enum.EasingStyle.OutQuad), {BackgroundTransparency = 1})
    Tween(ProgressBar, TweenInfo.new(0.4, Enum.EasingStyle.OutQuad), {BackgroundTransparency = 1})
    
    task.wait(0.65)
    LoadScreenGui:Destroy()
end


-- ========================================================================================
-- PART 2: WINDOW BUILDER & CORE INTERFACES
-- ========================================================================================
function Library:CreateWindow(config)
    config = config or {}
    local windowTitleText = config.Title or "Sam's Hub | UI v1"
    
    -- Protect against double windows
    if Library.ActiveWindow then
        Library.ActiveWindow:Destroy()
    end
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SamsHub_CoreUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.Parent = TargetGuiContainer
    Library.ActiveWindow = ScreenGui
    
    -- Minimize Keybind Monitor
    local uiVisible = true
    local minimizeConnection = UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == Library.UIKeybind then
            uiVisible = not uiVisible
            ScreenGui.Enabled = uiVisible
        end
    end)
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 600, 0, 420)
    MainFrame.Position = UDim2.new(0.5, -300, 0.5, -210)
    MainFrame.BackgroundColor3 = Library.Theme.MainBackground
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = false
    MainFrame.Parent = ScreenGui
    
    UI:CreateCorner(MainFrame, UDim.new(0, 10))
    UI:CreateStroke(MainFrame, Library.Theme.BorderColor, 1.2)
    UI:CreateShadow(MainFrame)
    
    -- Radial Background glow
    local WindowGlow = Instance.new("ImageLabel")
    WindowGlow.Size = UDim2.new(1, 0, 1, 0)
    WindowGlow.BackgroundTransparency = 1
    WindowGlow.Image = "rbxassetid://13110901594"
    WindowGlow.ImageColor3 = Library.Theme.AccentColor
    WindowGlow.ImageTransparency = 0.94
    WindowGlow.Parent = MainFrame
    
    -- Header Strip (Custom Topbar)
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 40)
    Header.BackgroundColor3 = Library.Theme.HeaderBackground
    Header.BorderSizePixel = 0
    Header.Parent = MainFrame
    UI:CreateCorner(Header, UDim.new(0, 10))
    
    -- Block header corners from looking rounded on lower half
    local AntiCorner = Instance.new("Frame")
    AntiCorner.Size = UDim2.new(1, 0, 0, 8)
    AntiCorner.Position = UDim2.new(0, 0, 1, -8)
    AntiCorner.BackgroundColor3 = Library.Theme.HeaderBackground
    AntiCorner.BorderSizePixel = 0
    AntiCorner.Parent = Header
    
    local HeaderStroke = Instance.new("Frame")
    HeaderStroke.Size = UDim2.new(1, 0, 0, 1)
    HeaderStroke.Position = UDim2.new(0, 0, 1, 0)
    HeaderStroke.BackgroundColor3 = Library.Theme.BorderColor
    HeaderStroke.BorderSizePixel = 0
    HeaderStroke.Parent = Header
    
    Dragging.Register(MainFrame, Header)
    
    -- Header Title
    local WindowTitle = Instance.new("TextLabel")
    WindowTitle.Size = UDim2.new(0.5, 0, 1, 0)
    WindowTitle.Position = UDim2.new(0, 15, 0, 0)
    WindowTitle.BackgroundTransparency = 1
    WindowTitle.Font = Enum.Font.GothamBold
    WindowTitle.Text = windowTitleText:upper()
    WindowTitle.TextColor3 = Library.Theme.TextPrimary
    WindowTitle.TextSize = 13
    WindowTitle.TextXAlignment = Enum.TextXAlignment.Left
    WindowTitle.Parent = Header
    
    -- Controls Panel (Minimize & Close buttons)
    local WindowControls = Instance.new("Frame")
    WindowControls.Size = UDim2.new(0, 80, 1, 0)
    WindowControls.Position = UDim2.new(1, -80, 0, 0)
    WindowControls.BackgroundTransparency = 1
    WindowControls.Parent = Header
    
    -- Elegant Close Button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 24, 0, 24)
    CloseButton.Position = UDim2.new(1, -34, 0.5, -12)
    CloseButton.BackgroundColor3 = Color3.fromRGB(30, 15, 15)
    CloseButton.BackgroundTransparency = 0.5
    CloseButton.Text = "×"
    CloseButton.Font = Enum.Font.GothamMedium
    CloseButton.TextColor3 = Color3.fromRGB(255, 110, 110)
    CloseButton.TextSize = 18
    CloseButton.Parent = WindowControls
    UI:CreateCorner(CloseButton, UDim.new(0, 6))
    UI:CreateStroke(CloseButton, Color3.fromRGB(60, 25, 25), 1)
    
    CloseButton.MouseEnter:Connect(function()
        Tween(CloseButton, TweenInfo.new(0.15, Enum.EasingStyle.OutQuad), {BackgroundColor3 = Color3.fromRGB(180, 40, 40), TextColor3 = Color3.fromRGB(255, 255, 255)})
    end)
    CloseButton.MouseLeave:Connect(function()
        Tween(CloseButton, TweenInfo.new(0.15, Enum.EasingStyle.OutQuad), {BackgroundColor3 = Color3.fromRGB(30, 15, 15), TextColor3 = Color3.fromRGB(255, 110, 110)})
    end)
    
    -- Elegant Minimize Button
    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Size = UDim2.new(0, 24, 0, 24)
    MinimizeButton.Position = UDim2.new(1, -64, 0.5, -12)
    MinimizeButton.BackgroundColor3 = Color3.fromRGB(20, 28, 24)
    MinimizeButton.BackgroundTransparency = 0.5
    MinimizeButton.Text = "−"
    MinimizeButton.Font = Enum.Font.GothamMedium
    MinimizeButton.TextColor3 = Library.Theme.AccentLight
    MinimizeButton.TextSize = 14
    MinimizeButton.Parent = WindowControls
    UI:CreateCorner(MinimizeButton, UDim.new(0, 6))
    UI:CreateStroke(MinimizeButton, Library.Theme.BorderColor, 1)

    MinimizeButton.MouseEnter:Connect(function()
        Tween(MinimizeButton, TweenInfo.new(0.15, Enum.EasingStyle.OutQuad), {BackgroundColor3 = Library.Theme.AccentColor, TextColor3 = Color3.fromRGB(255, 255, 255)})
    end)
    MinimizeButton.MouseLeave:Connect(function()
        Tween(MinimizeButton, TweenInfo.new(0.15, Enum.EasingStyle.OutQuad), {BackgroundColor3 = Color3.fromRGB(20, 28, 24), TextColor3 = Library.Theme.AccentLight})
    end)
    
    -- Main Content Layout
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 160, 1, -40)
    Sidebar.Position = UDim2.new(0, 0, 0, 40)
    Sidebar.BackgroundColor3 = Library.Theme.SidebarBackground
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame
    
    -- Rounded corner fix for left side base
    local LeftAntiCorner = Instance.new("Frame")
    LeftAntiCorner.Size = UDim2.new(0, 10, 0, 10)
    LeftAntiCorner.Position = UDim2.new(0, 0, 1, -10)
    LeftAntiCorner.BackgroundColor3 = Library.Theme.SidebarBackground
    LeftAntiCorner.BorderSizePixel = 0
    LeftAntiCorner.Parent = Sidebar
    
    local SidebarStroke = Instance.new("Frame")
    SidebarStroke.Size = UDim2.new(0, 1, 1, 0)
    SidebarStroke.Position = UDim2.new(1, -1, 0, 0)
    SidebarStroke.BackgroundColor3 = Library.Theme.BorderColor
    SidebarStroke.BorderSizePixel = 0
    SidebarStroke.Parent = Sidebar
    
    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Size = UDim2.new(1, -10, 1, -20)
    TabContainer.Position = UDim2.new(0, 5, 0, 10)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 0
    TabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabContainer.Parent = Sidebar
    
    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Padding = UDim.new(0, 4)
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Parent = TabContainer
    
    TabListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabContainer.CanvasSize = UDim2.new(0, 0, 0, TabListLayout.AbsoluteContentSize.Y)
    end)
    
    -- Pages/Container Frame
    local PagesFrame = Instance.new("Frame")
    PagesFrame.Size = UDim2.new(1, -160, 1, -40)
    PagesFrame.Position = UDim2.new(0, 160, 0, 40)
    PagesFrame.BackgroundTransparency = 1
    PagesFrame.Parent = MainFrame
    
    -- Smooth Draggable Unload Floating Switch System (Requirements Shortcut Toggle)
    local SwitchFrame = Instance.new("Frame")
    SwitchFrame.Size = UDim2.new(0, 42, 0, 42)
    SwitchFrame.Position = UDim2.new(0, 20, 0, 20)
    SwitchFrame.BackgroundColor3 = Library.Theme.SidebarBackground
    SwitchFrame.BorderSizePixel = 0
    SwitchFrame.Visible = false
    SwitchFrame.Parent = ScreenGui
    UI:CreateCorner(SwitchFrame, UDim.new(0, 12))
    UI:CreateStroke(SwitchFrame, Library.Theme.AccentColor, 1.5)
    UI:CreateShadow(SwitchFrame)
    Dragging.Register(SwitchFrame, SwitchFrame)
    
    local SwitchIcon = Instance.new("ImageLabel")
    SwitchIcon.Size = UDim2.new(0, 22, 0, 22)
    SwitchIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
    SwitchIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    SwitchIcon.BackgroundTransparency = 1
    SwitchIcon.Image = "rbxassetid://13109265215"
    SwitchIcon.ImageColor3 = Library.Theme.AccentLight
    SwitchIcon.Parent = SwitchFrame
    
    local SwitchButton = Instance.new("TextButton")
    SwitchButton.Size = UDim2.new(1, 0, 1, 0)
    SwitchButton.BackgroundTransparency = 1
    SwitchButton.Text = ""
    SwitchButton.Parent = SwitchFrame
    
    SwitchButton.MouseButton1Click:Connect(function()
        uiVisible = true
        MainFrame.Visible = true
        SwitchFrame.Visible = false
    end)
    
    -- Minimize trigger mapping to floating switch toggle
    MinimizeButton.MouseButton1Click:Connect(function()
        uiVisible = false
        MainFrame.Visible = false
        SwitchFrame.Position = UDim2.new(0, MainFrame.AbsolutePosition.X + 20, 0, MainFrame.AbsolutePosition.Y + 20)
        SwitchFrame.Visible = true
    end)
    
    -- Destroy Library instance
    local function UnloadLibrary()
        Library.Unloaded = true
        minimizeConnection:Disconnect()
        ScreenGui:Destroy()
    end
    
    CloseButton.MouseButton1Click:Connect(UnloadLibrary)
    
    local WindowAPI = {
        ActiveTab = nil,
        Tabs = {}
    }
    
    -- ========================================================================================
    -- PART 3: THE TAB MODULE
    -- ========================================================================================
    function WindowAPI:CreateTab(tabName)
        tabName = tabName or "Dashboard"
        
        local TabButton = Instance.new("TextButton")
        TabButton.Size = UDim2.new(1, 0, 0, 32)
        TabButton.BackgroundColor3 = Library.Theme.SidebarBackground
        TabButton.BackgroundTransparency = 1
        TabButton.Text = ""
        TabButton.Parent = TabContainer
        UI:CreateCorner(TabButton, UDim.new(0, 6))
        
        local TabIndicator = Instance.new("Frame")
        TabIndicator.Size = UDim2.new(0, 3, 0.6, 0)
        TabIndicator.Position = UDim2.new(0, 4, 0.2, 0)
        TabIndicator.BackgroundColor3 = Library.Theme.AccentColor
        TabIndicator.BorderSizePixel = 0
        TabIndicator.BackgroundTransparency = 1
        TabIndicator.Parent = TabButton
        UI:CreateCorner(TabIndicator, UDim.new(1, 0))
        
        local TabLabel = Instance.new("TextLabel")
        TabLabel.Size = UDim2.new(1, -20, 1, 0)
        TabLabel.Position = UDim2.new(0, 15, 0, 0)
        TabLabel.BackgroundTransparency = 1
        TabLabel.Font = Enum.Font.GothamMedium
        TabLabel.Text = tabName
        TabLabel.TextColor3 = Library.Theme.TextSecondary
        TabLabel.TextSize = 12
        TabLabel.TextXAlignment = Enum.TextXAlignment.Left
        TabLabel.Parent = TabButton
        
        -- Custom Page Setup
        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1, -20, 1, -20)
        Page.Position = UDim2.new(0, 10, 0, 10)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = Library.Theme.BorderColor
        Page.Visible = false
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Page.Parent = PagesFrame
        
        local PageLayout = Instance.new("UIListLayout")
        PageLayout.Padding = UDim.new(0, 6)
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Parent = Page
        
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y)
        end)
        
        local function Select()
            if WindowAPI.ActiveTab then
                local prevButton = WindowAPI.ActiveTab.Button
                local prevPage = WindowAPI.ActiveTab.Page
                
                Tween(prevButton, TweenInfo.new(0.2, Enum.EasingStyle.OutQuad), {BackgroundTransparency = 1})
                Tween(prevButton:FindFirstChild("TabIndicator"), TweenInfo.new(0.2, Enum.EasingStyle.OutQuad), {BackgroundTransparency = 1})
                Tween(prevButton:FindFirstChild("TextLabel"), TweenInfo.new(0.2, Enum.EasingStyle.OutQuad), {TextColor3 = Library.Theme.TextSecondary})
                prevPage.Visible = false
            end
            
            WindowAPI.ActiveTab = {Button = TabButton, Page = Page}
            Tween(TabButton, TweenInfo.new(0.2, Enum.EasingStyle.OutQuad), {BackgroundTransparency = 0.9, BackgroundColor3 = Library.Theme.AccentColor})
            Tween(TabIndicator, TweenInfo.new(0.2, Enum.EasingStyle.OutQuad), {BackgroundTransparency = 0})
            Tween(TabLabel, TweenInfo.new(0.2, Enum.EasingStyle.OutQuad), {TextColor3 = Library.Theme.AccentLight})
            Page.Visible = true
        end
        
        TabButton.MouseEnter:Connect(function()
            if WindowAPI.ActiveTab and WindowAPI.ActiveTab.Button == TabButton then return end
            Tween(TabLabel, TweenInfo.new(0.15, Enum.EasingStyle.OutQuad), {TextColor3 = Library.Theme.TextPrimary})
        end)
        
        TabButton.MouseLeave:Connect(function()
            if WindowAPI.ActiveTab and WindowAPI.ActiveTab.Button == TabButton then return end
            Tween(TabLabel, TweenInfo.new(0.15, Enum.EasingStyle.OutQuad), {TextColor3 = Library.Theme.TextSecondary})
        end)
        
        TabButton.MouseButton1Click:Connect(Select)
        
        if not WindowAPI.ActiveTab then
            Select()
        end
        
        local TabAPI = {}
        
        -- ========================================================================================
        -- PART 4: INTERACTIVE WIDGET BUILDERS
        -- ========================================================================================
        
        -- Custom Section Label
        function TabAPI:CreateSection(sectionText)
            sectionText = sectionText or "Control Group"
            local SectionContainer = Instance.new("Frame")
            SectionContainer.Size = UDim2.new(1, 0, 0, 24)
            SectionContainer.BackgroundTransparency = 1
            SectionContainer.Parent = Page
            
            local TextLabel = Instance.new("TextLabel")
            TextLabel.Size = UDim2.new(1, -10, 1, 0)
            TextLabel.Position = UDim2.new(0, 5, 0, 0)
            TextLabel.BackgroundTransparency = 1
            TextLabel.Font = Enum.Font.GothamBold
            TextLabel.Text = sectionText:upper()
            TextLabel.TextColor3 = Library.Theme.AccentColor
            TextLabel.TextSize = 10
            TextLabel.TextXAlignment = Enum.TextXAlignment.Left
            TextLabel.Parent = SectionContainer
            
            local SectionLine = Instance.new("Frame")
            SectionLine.Size = UDim2.new(1, -15, 0, 1)
            SectionLine.Position = UDim2.new(0, 5, 1, -1)
            SectionLine.BackgroundColor3 = Library.Theme.BorderColor
            SectionLine.BorderSizePixel = 0
            SectionLine.Parent = SectionContainer
        end

        -- Standard Royal Button Component
        function TabAPI:CreateButton(options)
            options = options or {}
            local btnText = options.Name or "Click Me"
            local callback = options.Callback or function() end
            
            local ButtonFrame = Instance.new("Frame")
            ButtonFrame.Size = UDim2.new(1, 0, 0, 36)
            ButtonFrame.BackgroundColor3 = Library.Theme.ElementBackground
            ButtonFrame.BorderSizePixel = 0
            ButtonFrame.Parent = Page
            UI:CreateCorner(ButtonFrame, UDim.new(0, 6))
            local Stroke = UI:CreateStroke(ButtonFrame, Library.Theme.BorderColor, 1)
            
            local TextBtn = Instance.new("TextButton")
            TextBtn.Size = UDim2.new(1, 0, 1, 0)
            TextBtn.BackgroundTransparency = 1
            TextBtn.Font = Enum.Font.GothamSemibold
            TextBtn.Text = btnText
            TextBtn.TextColor3 = Library.Theme.TextPrimary
            TextBtn.TextSize = 12
            TextBtn.Parent = ButtonFrame
            
            TextBtn.MouseEnter:Connect(function()
                Tween(ButtonFrame, TweenInfo.new(0.12, Enum.EasingStyle.OutQuad), {BackgroundColor3 = Library.Theme.ElementHover})
                Tween(Stroke, TweenInfo.new(0.12, Enum.EasingStyle.OutQuad), {Color = Library.Theme.AccentColor})
            end)
            TextBtn.MouseLeave:Connect(function()
                Tween(ButtonFrame, TweenInfo.new(0.12, Enum.EasingStyle.OutQuad), {BackgroundColor3 = Library.Theme.ElementBackground})
                Tween(Stroke, TweenInfo.new(0.12, Enum.EasingStyle.OutQuad), {Color = Library.Theme.BorderColor})
            end)
            
            TextBtn.MouseButton1Click:Connect(function()
                -- Dynamic button click reaction scale
                Tween(ButtonFrame, TweenInfo.new(0.08, Enum.EasingStyle.OutQuad), {Size = UDim2.new(0.98, 4, 0, 34)})
                task.wait(0.08)
                Tween(ButtonFrame, TweenInfo.new(0.08, Enum.EasingStyle.OutQuad), {Size = UDim2.new(1, 0, 0, 36)})
                pcall(callback)
            end)
        end
        
        -- Toggle Switch Component
        function TabAPI:CreateToggle(options)
            options = options or {}
            local toggleText = options.Name or "Interactive Toggle"
            local defaultState = options.Default or false
            local callback = options.Callback or function() end
            
            local active = defaultState
            
            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Size = UDim2.new(1, 0, 0, 36)
            ToggleFrame.BackgroundColor3 = Library.Theme.ElementBackground
            ToggleFrame.BorderSizePixel = 0
            ToggleFrame.Parent = Page
            UI:CreateCorner(ToggleFrame, UDim.new(0, 6))
            local Stroke = UI:CreateStroke(ToggleFrame, Library.Theme.BorderColor, 1)
            
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(0.6, 0, 1, 0)
            Label.Position = UDim2.new(0, 12, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Font = Enum.Font.GothamSemibold
            Label.Text = toggleText
            Label.TextColor3 = Library.Theme.TextSecondary
            Label.TextSize = 12
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = ToggleFrame
            
            local Switch = Instance.new("Frame")
            Switch.Size = UDim2.new(0, 38, 0, 20)
            Switch.Position = UDim2.new(1, -50, 0.5, -10)
            Switch.BackgroundColor3 = Color3.fromRGB(35, 45, 40)
            Switch.Parent = ToggleFrame
            UI:CreateCorner(Switch, UDim.new(1, 0))
            
            local SwitchStroke = UI:CreateStroke(Switch, Library.Theme.BorderColor, 1)
            
            local Ball = Instance.new("Frame")
            Ball.Size = UDim2.new(0, 14, 0, 14)
            Ball.Position = UDim2.new(0, 3, 0.5, -7)
            Ball.BackgroundColor3 = Color3.fromRGB(150, 160, 155)
            Ball.Parent = Switch
            UI:CreateCorner(Ball, UDim.new(1, 0))
            
            local Hitbox = Instance.new("TextButton")
            Hitbox.Size = UDim2.new(1, 0, 1, 0)
            Hitbox.BackgroundTransparency = 1
            Hitbox.Text = ""
            Hitbox.Parent = ToggleFrame
            
            local function UpdateVisuals()
                if active then
                    Tween(Switch, TweenInfo.new(0.15, Enum.EasingStyle.OutQuad), {BackgroundColor3 = Library.Theme.AccentColor})
                    Tween(Ball, TweenInfo.new(0.15, Enum.EasingStyle.OutQuad), {Position = UDim2.new(1, -17, 0.5, -7), BackgroundColor3 = Color3.fromRGB(255, 255, 255)})
                    Tween(Label, TweenInfo.new(0.15, Enum.EasingStyle.OutQuad), {TextColor3 = Library.Theme.TextPrimary})
                    Tween(SwitchStroke, TweenInfo.new(0.15, Enum.EasingStyle.OutQuad), {Color = Library.Theme.AccentLight})
                else
                    Tween(Switch, TweenInfo.new(0.15, Enum.EasingStyle.OutQuad), {BackgroundColor3 = Color3.fromRGB(35, 45, 40)})
                    Tween(Ball, TweenInfo.new(0.15, Enum.EasingStyle.OutQuad), {Position = UDim2.new(0, 3, 0.5, -7), BackgroundColor3 = Color3.fromRGB(150, 160, 155)})
                    Tween(Label, TweenInfo.new(0.15, Enum.EasingStyle.OutQuad), {TextColor3 = Library.Theme.TextSecondary})
                    Tween(SwitchStroke, TweenInfo.new(0.15, Enum.EasingStyle.OutQuad), {Color = Library.Theme.BorderColor})
                end
            end
            
            UpdateVisuals()
            
            Hitbox.MouseEnter:Connect(function()
                Tween(ToggleFrame, TweenInfo.new(0.12, Enum.EasingStyle.OutQuad), {BackgroundColor3 = Library.Theme.ElementHover})
                Tween(Stroke, TweenInfo.new(0.12, Enum.EasingStyle.OutQuad), {Color = Library.Theme.AccentColor})
            end)
            Hitbox.MouseLeave:Connect(function()
                Tween(ToggleFrame, TweenInfo.new(0.12, Enum.EasingStyle.OutQuad), {BackgroundColor3 = Library.Theme.ElementBackground})
                Tween(Stroke, TweenInfo.new(0.12, Enum.EasingStyle.OutQuad), {Color = Library.Theme.BorderColor})
            end)
            
            Hitbox.MouseButton1Click:Connect(function()
                active = not active
                UpdateVisuals()
                pcall(callback, active)
            end)
            
            local ToggleAPI = {}
            function ToggleAPI:Set(state)
                active = state
                UpdateVisuals()
                pcall(callback, active)
            end
            return ToggleAPI
        end

        -- Checkbox (Functional Alternative variant of Toggle)
        function TabAPI:CreateCheckbox(options)
            options = options or {}
            local checkText = options.Name or "Elegant Checkbox"
            local defaultState = options.Default or false
            local callback = options.Callback or function() end
            
            local checked = defaultState
            
            local CheckFrame = Instance.new("Frame")
            CheckFrame.Size = UDim2.new(1, 0, 0, 36)
            CheckFrame.BackgroundColor3 = Library.Theme.ElementBackground
            CheckFrame.BorderSizePixel = 0
            CheckFrame.Parent = Page
            UI:CreateCorner(CheckFrame, UDim.new(0, 6))
            local Stroke = UI:CreateStroke(CheckFrame, Library.Theme.BorderColor, 1)
            
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(0.6, 0, 1, 0)
            Label.Position = UDim2.new(0, 12, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Font = Enum.Font.GothamSemibold
            Label.Text = checkText
            Label.TextColor3 = Library.Theme.TextSecondary
            Label.TextSize = 12
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = CheckFrame
            
            local Box = Instance.new("Frame")
            Box.Size = UDim2.new(0, 18, 0, 18)
            Box.Position = UDim2.new(1, -30, 0.5, -9)
            Box.BackgroundColor3 = Color3.fromRGB(35, 45, 40)
            Box.Parent = CheckFrame
            UI:CreateCorner(Box, UDim.new(0, 4))
            local BoxStroke = UI:CreateStroke(Box, Library.Theme.BorderColor, 1)
            
            local CheckIcon = Instance.new("ImageLabel")
            CheckIcon.Size = UDim2.new(0, 12, 0, 12)
            CheckIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
            CheckIcon.AnchorPoint = Vector2.new(0.5, 0.5)
            CheckIcon.BackgroundTransparency = 1
            CheckIcon.Image = "rbxassetid://13110507204"
            CheckIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
            CheckIcon.ImageTransparency = 1
            CheckIcon.Parent = Box
            
            local Hitbox = Instance.new("TextButton")
            Hitbox.Size = UDim2.new(1, 0, 1, 0)
            Hitbox.BackgroundTransparency = 1
            Hitbox.Text = ""
            Hitbox.Parent = CheckFrame
            
            local function UpdateCheckbox()
                if checked then
                    Tween(Box, TweenInfo.new(0.12, Enum.EasingStyle.OutQuad), {BackgroundColor3 = Library.Theme.AccentColor})
                    Tween(CheckIcon, TweenInfo.new(0.12, Enum.EasingStyle.OutQuad), {ImageTransparency = 0})
                    Tween(Label, TweenInfo.new(0.12, Enum.EasingStyle.OutQuad), {TextColor3 = Library.Theme.TextPrimary})
                    Tween(BoxStroke, TweenInfo.new(0.12, Enum.EasingStyle.OutQuad), {Color = Library.Theme.AccentLight})
                else
                    Tween(Box, TweenInfo.new(0.12, Enum.EasingStyle.OutQuad), {BackgroundColor3 = Color3.fromRGB(35, 45, 40)})
                    Tween(CheckIcon, TweenInfo.new(0.12, Enum.EasingStyle.OutQuad), {ImageTransparency = 1})
                    Tween(Label, TweenInfo.new(0.12, Enum.EasingStyle.OutQuad), {TextColor3 = Library.Theme.TextSecondary})
                    Tween(BoxStroke, TweenInfo.new(0.12, Enum.EasingStyle.OutQuad), {Color = Library.Theme.BorderColor})
                end
            end
            
            UpdateCheckbox()
            
            Hitbox.MouseEnter:Connect(function()
                Tween(CheckFrame, TweenInfo.new(0.12, Enum.EasingStyle.OutQuad), {BackgroundColor3 = Library.Theme.ElementHover})
                Tween(Stroke, TweenInfo.new(0.12, Enum.EasingStyle.OutQuad), {Color = Library.Theme.AccentColor})
            end)
            Hitbox.MouseLeave:Connect(function()
                Tween(CheckFrame, TweenInfo.new(0.12, Enum.EasingStyle.OutQuad), {BackgroundColor3 = Library.Theme.ElementBackground})
                Tween(Stroke, TweenInfo.new(0.12, Enum.EasingStyle.OutQuad), {Color = Library.Theme.BorderColor})
            end)
            
            Hitbox.MouseButton1Click:Connect(function()
                checked = not checked
                UpdateCheckbox()
                pcall(callback, checked)
            end)
        end
        
        -- Custom Precision Slider Component
        function TabAPI:CreateSlider(options)
            options = options or {}
            local sliderName = options.Name or "Precision Slider"
            local min = options.Min or 0
            local max = options.Max or 100
            local defaultVal = options.Default or 50
            local callback = options.Callback or function() end
            
            local SliderValue = defaultVal
            
            local SliderContainer = Instance.new("Frame")
            SliderContainer.Size = UDim2.new(1, 0, 0, 48)
            SliderContainer.BackgroundColor3 = Library.Theme.ElementBackground
            SliderContainer.BorderSizePixel = 0
            SliderContainer.Parent = Page
            UI:CreateCorner(SliderContainer, UDim.new(0, 6))
            local Stroke = UI:CreateStroke(SliderContainer, Library.Theme.BorderColor, 1)
            
            local TitleLabel = Instance.new("TextLabel")
            TitleLabel.Size = UDim2.new(0.5, 0, 0, 24)
            TitleLabel.Position = UDim2.new(0, 12, 0, 0)
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.Font = Enum.Font.GothamSemibold
            TitleLabel.Text = sliderName
            TitleLabel.TextColor3 = Library.Theme.TextSecondary
            TitleLabel.TextSize = 12
            TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
            TitleLabel.Parent = SliderContainer
            
            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.Size = UDim2.new(0.4, 0, 0, 24)
            ValueLabel.Position = UDim2.new(1, -132, 0, 0)
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.Font = Enum.Font.GothamMedium
            ValueLabel.Text = tostring(SliderValue)
            ValueLabel.TextColor3 = Library.Theme.AccentLight
            ValueLabel.TextSize = 12
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
            ValueLabel.Parent = SliderContainer
            
            local Track = Instance.new("Frame")
            Track.Size = UDim2.new(1, -24, 0, 6)
            Track.Position = UDim2.new(0, 12, 1, -14)
            Track.BackgroundColor3 = Color3.fromRGB(35, 45, 40)
            Track.BorderSizePixel = 0
            Track.Parent = SliderContainer
            UI:CreateCorner(Track, UDim.new(1, 0))
            
            local Fill = Instance.new("Frame")
            Fill.Size = UDim2.new(0, 0, 1, 0)
            Fill.BackgroundColor3 = Library.Theme.AccentColor
            Fill.BorderSizePixel = 0
            Fill.Parent = Track
            UI:CreateCorner(Fill, UDim.new(1, 0))
            
            local TriggerBtn = Instance.new("TextButton")
            TriggerBtn.Size = UDim2.new(1, 0, 1, 0)
            TriggerBtn.BackgroundTransparency = 1
            TriggerBtn.Text = ""
            TriggerBtn.Parent = SliderContainer
            
            local dragging = false
            
            local function ApplyValue(val)
                SliderValue = math.clamp(val, min, max)
                ValueLabel.Text = tostring(SliderValue)
                local percentage = (SliderValue - min) / (max - min)
                Tween(Fill, TweenInfo.new(0.08, Enum.EasingStyle.OutQuad), {Size = UDim2.new(percentage, 0, 1, 0)})
                pcall(callback, SliderValue)
            end
            
            local function HandleInput(input)
                local absoluteSize = Track.AbsoluteSize.X
                local absolutePos = Track.AbsolutePosition.X
                local percentage = math.clamp((input.Position.X - absolutePos) / absoluteSize, 0, 1)
                local val = math.floor(min + (percentage * (max - min)))
                ApplyValue(val)
            end
            
            TriggerBtn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    Tween(TitleLabel, TweenInfo.new(0.12, Enum.EasingStyle.OutQuad), {TextColor3 = Library.Theme.TextPrimary})
                    Tween(Stroke, TweenInfo.new(0.12, Enum.EasingStyle.OutQuad), {Color = Library.Theme.AccentLight})
                    HandleInput(input)
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                    Tween(TitleLabel, TweenInfo.new(0.12, Enum.EasingStyle.OutQuad), {TextColor3 = Library.Theme.TextSecondary})
                    Tween(Stroke, TweenInfo.new(0.12, Enum.EasingStyle.OutQuad), {Color = Library.Theme.BorderColor})
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    HandleInput(input)
                end
            end)
            
            ApplyValue(defaultVal)
            
            local SliderAPI = {}
            function SliderAPI:Set(val)
                ApplyValue(val)
            end
            return SliderAPI
        end

        -- TextBox Input Component
        function TabAPI:CreateTextBox(options)
            options = options or {}
            local nameText = options.Name or "Input Capture"
            local placeholder = options.Placeholder or "Enter value..."
            local callback = options.Callback or function() end
            
            local InputFrame = Instance.new("Frame")
            InputFrame.Size = UDim2.new(1, 0, 0, 36)
            InputFrame.BackgroundColor3 = Library.Theme.ElementBackground
            InputFrame.BorderSizePixel = 0
            InputFrame.Parent = Page
            UI:CreateCorner(InputFrame, UDim.new(0, 6))
            local Stroke = UI:CreateStroke(InputFrame, Library.Theme.BorderColor, 1)
            
            local TitleLabel = Instance.new("TextLabel")
            TitleLabel.Size = UDim2.new(0.4, 0, 1, 0)
            TitleLabel.Position = UDim2.new(0, 12, 0, 0)
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.Font = Enum.Font.GothamSemibold
            TitleLabel.Text = nameText
            TitleLabel.TextColor3 = Library.Theme.TextSecondary
            TitleLabel.TextSize = 12
            TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
            TitleLabel.Parent = InputFrame
            
            local InnerFrame = Instance.new("Frame")
            InnerFrame.Size = UDim2.new(0.5, 0, 0, 24)
            InnerFrame.Position = UDim2.new(1, -12, 0.5, -12)
            InnerFrame.AnchorPoint = Vector2.new(1, 0)
            InnerFrame.BackgroundColor3 = Color3.fromRGB(30, 40, 35)
            InnerFrame.Parent = InputFrame
            UI:CreateCorner(InnerFrame, UDim.new(0, 4))
            local InnerStroke = UI:CreateStroke(InnerFrame, Library.Theme.BorderColor, 1)
            
            local RealTextBox = Instance.new("TextBox")
            RealTextBox.Size = UDim2.new(1, -16, 1, 0)
            RealTextBox.Position = UDim2.new(0, 8, 0, 0)
            RealTextBox.BackgroundTransparency = 1
            RealTextBox.Font = Enum.Font.GothamMedium
            RealTextBox.PlaceholderText = placeholder
            RealTextBox.PlaceholderColor3 = Color3.fromRGB(110, 125, 118)
            RealTextBox.Text = ""
            RealTextBox.TextColor3 = Library.Theme.TextPrimary
            RealTextBox.TextSize = 11
            RealTextBox.TextXAlignment = Enum.TextXAlignment.Right
            RealTextBox.ClipsDescendants = true
            RealTextBox.Parent = InnerFrame
            
            RealTextBox.Focused:Connect(function()
                Tween(InputFrame, TweenInfo.new(0.12, Enum.EasingStyle.OutQuad), {BackgroundColor3 = Library.Theme.ElementHover})
                Tween(Stroke, TweenInfo.new(0.12, Enum.EasingStyle.OutQuad), {Color = Library.Theme.AccentColor})
                Tween(InnerStroke, TweenInfo.new(0.12, Enum.EasingStyle.OutQuad), {Color = Library.Theme.AccentLight})
                Tween(TitleLabel, TweenInfo.new(0.12, Enum.EasingStyle.OutQuad), {TextColor3 = Library.Theme.TextPrimary})
            end)
            
            RealTextBox.FocusLost:Connect(function(enterPressed)
                Tween(InputFrame, TweenInfo.new(0.12, Enum.EasingStyle.OutQuad), {BackgroundColor3 = Library.Theme.ElementBackground})
                Tween(Stroke, TweenInfo.new(0.12, Enum.EasingStyle.OutQuad), {Color = Library.Theme.BorderColor})
                Tween(InnerStroke, TweenInfo.new(0.12, Enum.EasingStyle.OutQuad), {Color = Library.Theme.BorderColor})
                Tween(TitleLabel, TweenInfo.new(0.12, Enum.EasingStyle.OutQuad), {TextColor3 = Library.Theme.TextSecondary})
                pcall(callback, RealTextBox.Text, enterPressed)
            end)
            
            local TextAPI = {}
            function TextAPI:Get()
                return RealTextBox.Text
            end
            function TextAPI:Set(str)
                RealTextBox.Text = str
                pcall(callback, str, false)
            end
            return TextAPI
        end

        -- Advanced Royal Searchable Dropdown
        function TabAPI:CreateDropdown(options)
            options = options or {}
            local dropdownText = options.Name or "Modern Dropdown"
            local items = options.Items or {}
            local callback = options.Callback or function() end
            
            local selectedVal = nil
            local isOpen = false
            
            local DropdownContainer = Instance.new("Frame")
            DropdownContainer.Size = UDim2.new(1, 0, 0, 36)
            DropdownContainer.BackgroundColor3 = Library.Theme.ElementBackground
            DropdownContainer.BorderSizePixel = 0
            DropdownContainer.ClipsDescendants = true
            DropdownContainer.Parent = Page
            UI:CreateCorner(DropdownContainer, UDim.new(0, 6))
            local Stroke = UI:CreateStroke(DropdownContainer, Library.Theme.BorderColor, 1)
            
            local HeaderButton = Instance.new("TextButton")
            HeaderButton.Size = UDim2.new(1, 0, 0, 36)
            HeaderButton.BackgroundTransparency = 1
            HeaderButton.Text = ""
            HeaderButton.Parent = DropdownContainer
            
            local TitleLabel = Instance.new("TextLabel")
            TitleLabel.Size = UDim2.new(0.6, 0, 1, 0)
            TitleLabel.Position = UDim2.new(0, 12, 0, 0)
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.Font = Enum.Font.GothamSemibold
            TitleLabel.Text = dropdownText
            TitleLabel.TextColor3 = Library.Theme.TextSecondary
            TitleLabel.TextSize = 12
            TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
            TitleLabel.Parent = HeaderButton
            
            local SelectedIndicator = Instance.new("TextLabel")
            SelectedIndicator.Size = UDim2.new(0.3, 0, 1, 0)
            SelectedIndicator.Position = UDim2.new(1, -54, 0, 0)
            SelectedIndicator.BackgroundTransparency = 1
            SelectedIndicator.Font = Enum.Font.GothamMedium
            SelectedIndicator.Text = "None Selected"
            SelectedIndicator.TextColor3 = Library.Theme.AccentLight
            SelectedIndicator.TextSize = 11
            SelectedIndicator.TextXAlignment = Enum.TextXAlignment.Right
            SelectedIndicator.Parent = HeaderButton
            
            local IndicatorIcon = Instance.new("ImageLabel")
            IndicatorIcon.Size = UDim2.new(0, 16, 0, 16)
            IndicatorIcon.Position = UDim2.new(1, -28, 0.5, -8)
            IndicatorIcon.BackgroundTransparency = 1
            IndicatorIcon.Image = "rbxassetid://13110543632"
            IndicatorIcon.ImageColor3 = Library.Theme.TextSecondary
            IndicatorIcon.Parent = HeaderButton
            
            -- Hidden searchable list panel
            local ListFrame = Instance.new("Frame")
            ListFrame.Size = UDim2.new(1, -16, 0, 120)
            ListFrame.Position = UDim2.new(0, 8, 0, 36)
            ListFrame.BackgroundTransparency = 1
            ListFrame.Parent = DropdownContainer
            
            -- Drodown Internal Searchbox
            local SearchBarFrame = Instance.new("Frame")
            SearchBarFrame.Size = UDim2.new(1, 0, 0, 26)
            SearchBarFrame.BackgroundColor3 = Color3.fromRGB(30, 40, 35)
            SearchBarFrame.Parent = ListFrame
            UI:CreateCorner(SearchBarFrame, UDim.new(0, 4))
            local SearchStroke = UI:CreateStroke(SearchBarFrame, Library.Theme.BorderColor, 1)
            
            local SearchBar = Instance.new("TextBox")
            SearchBar.Size = UDim2.new(1, -16, 1, 0)
            SearchBar.Position = UDim2.new(0, 8, 0, 0)
            SearchBar.BackgroundTransparency = 1
            SearchBar.Font = Enum.Font.GothamMedium
            SearchBar.PlaceholderText = "Search item..."
            SearchBar.PlaceholderColor3 = Color3.fromRGB(110, 125, 118)
            SearchBar.Text = ""
            SearchBar.TextColor3 = Library.Theme.TextPrimary
            SearchBar.TextSize = 11
            SearchBar.TextXAlignment = Enum.TextXAlignment.Left
            SearchBar.Parent = SearchBarFrame
            
            local ListScroll = Instance.new("ScrollingFrame")
            ListScroll.Size = UDim2.new(1, 0, 1, -32)
            ListScroll.Position = UDim2.new(0, 0, 0, 32)
            ListScroll.BackgroundTransparency = 1
            ListScroll.ScrollBarThickness = 2
            ListScroll.ScrollBarImageColor3 = Library.Theme.BorderColor
            ListScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
            ListScroll.Parent = ListFrame
            
            local ListLayout = Instance.new("UIListLayout")
            ListLayout.Padding = UDim.new(0, 3)
            ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ListLayout.Parent = ListScroll
            
            ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                ListScroll.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y)
            end)
            
            local buttonsCache = {}
            
            local function RedrawItems()
                for _, btn in ipairs(buttonsCache) do
                    btn:Destroy()
                end
                table.clear(buttonsCache)
                
                for idx, val in ipairs(items) do
                    local ItemBtn = Instance.new("TextButton")
                    ItemBtn.Size = UDim2.new(1, -4, 0, 24)
                    ItemBtn.BackgroundColor3 = Color3.fromRGB(24, 38, 32)
                    ItemBtn.BackgroundTransparency = 0.5
                    ItemBtn.Font = Enum.Font.GothamMedium
                    ItemBtn.Text = tostring(val)
                    ItemBtn.TextColor3 = Library.Theme.TextSecondary
                    ItemBtn.TextSize = 11
                    ItemBtn.Parent = ListScroll
                    UI:CreateCorner(ItemBtn, UDim.new(0, 4))
                    local ItemStroke = UI:CreateStroke(ItemBtn, Library.Theme.BorderColor, 1)
                    
                    ItemBtn.MouseEnter:Connect(function()
                        Tween(ItemBtn, TweenInfo.new(0.1, Enum.EasingStyle.OutQuad), {BackgroundColor3 = Library.Theme.AccentColor, TextColor3 = Color3.fromRGB(255, 255, 255)})
                        Tween(ItemStroke, TweenInfo.new(0.1, Enum.EasingStyle.OutQuad), {Color = Library.Theme.AccentLight})
                    end)
                    ItemBtn.MouseLeave:Connect(function()
                        Tween(ItemBtn, TweenInfo.new(0.1, Enum.EasingStyle.OutQuad), {BackgroundColor3 = Color3.fromRGB(24, 38, 32), TextColor3 = Library.Theme.TextSecondary})
                        Tween(ItemStroke, TweenInfo.new(0.1, Enum.EasingStyle.OutQuad), {Color = Library.Theme.BorderColor})
                    end)
                    
                    ItemBtn.MouseButton1Click:Connect(function()
                        selectedVal = val
                        SelectedIndicator.Text = tostring(val)
                        isOpen = false
                        Tween(DropdownContainer, TweenInfo.new(0.2, Enum.EasingStyle.OutQuad), {Size = UDim2.new(1, 0, 0, 36)})
                        Tween(IndicatorIcon, TweenInfo.new(0.2, Enum.EasingStyle.OutQuad), {Rotation = 0})
                        pcall(callback, val)
                    end)
                    
                    table.insert(buttonsCache, ItemBtn)
                end
            end
            
            SearchBar:GetPropertyChangedSignal("Text"):Connect(function()
                local query = SearchBar.Text:lower()
                for _, btn in ipairs(buttonsCache) do
                    if query == "" or string.find(btn.Text:lower(), query) then
                        btn.Visible = true
                    else
                        btn.Visible = false
                    end
                end
            end)
            
            HeaderButton.MouseEnter:Connect(function()
                Tween(DropdownContainer, TweenInfo.new(0.12, Enum.EasingStyle.OutQuad), {BackgroundColor3 = Library.Theme.ElementHover})
                Tween(Stroke, TweenInfo.new(0.12, Enum.EasingStyle.OutQuad), {Color = Library.Theme.AccentColor})
            end)
            HeaderButton.MouseLeave:Connect(function()
                Tween(DropdownContainer, TweenInfo.new(0.12, Enum.EasingStyle.OutQuad), {BackgroundColor3 = Library.Theme.ElementBackground})
                Tween(Stroke, TweenInfo.new(0.12, Enum.EasingStyle.OutQuad), {Color = Library.Theme.BorderColor})
            end)
            
            HeaderButton.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                if isOpen then
                    Tween(DropdownContainer, TweenInfo.new(0.22, Enum.EasingStyle.OutQuad), {Size = UDim2.new(1, 0, 0, 164)})
                    Tween(IndicatorIcon, TweenInfo.new(0.22, Enum.EasingStyle.OutQuad), {Rotation = 180, ImageColor3 = Library.Theme.AccentColor})
                    Tween(TitleLabel, TweenInfo.new(0.22, Enum.EasingStyle.OutQuad), {TextColor3 = Library.Theme.TextPrimary})
                else
                    Tween(DropdownContainer, TweenInfo.new(0.22, Enum.EasingStyle.OutQuad), {Size = UDim2.new(1, 0, 0, 36)})
                    Tween(IndicatorIcon, TweenInfo.new(0.22, Enum.EasingStyle.OutQuad), {Rotation = 0, ImageColor3 = Library.Theme.TextSecondary})
                    Tween(TitleLabel, TweenInfo.new(0.22, Enum.EasingStyle.OutQuad), {TextColor3 = Library.Theme.TextSecondary})
                end
            end)
            
            RedrawItems()
            
            local DropdownAPI = {}
            function DropdownAPI:Refresh(newItems)
                items = newItems or {}
                RedrawItems()
            end
            function DropdownAPI:Set(val)
                selectedVal = val
                SelectedIndicator.Text = tostring(val)
                pcall(callback, val)
            end
            return DropdownAPI
        end
        
        -- Custom Keybinder Component
        function TabAPI:CreateKeybind(options)
            options = options or {}
            local bindName = options.Name or "HotKey Trigger"
            local defaultKey = options.Default or Enum.KeyCode.E
            local callback = options.Callback or function() end
            
            local assignedKey = defaultKey
            local listening = false
            
            local BindFrame = Instance.new("Frame")
            BindFrame.Size = UDim2.new(1, 0, 0, 36)
            BindFrame.BackgroundColor3 = Library.Theme.ElementBackground
            BindFrame.BorderSizePixel = 0
            BindFrame.Parent = Page
            UI:CreateCorner(BindFrame, UDim.new(0, 6))
            local Stroke = UI:CreateStroke(BindFrame, Library.Theme.BorderColor, 1)
            
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(0.6, 0, 1, 0)
            Label.Position = UDim2.new(0, 12, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Font = Enum.Font.GothamSemibold
            Label.Text = bindName
            Label.TextColor3 = Library.Theme.TextSecondary
            Label.TextSize = 12
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = BindFrame
            
            local InnerBox = Instance.new("Frame")
            InnerBox.Size = UDim2.new(0, 72, 0, 22)
            InnerBox.Position = UDim2.new(1, -84, 0.5, -11)
            InnerBox.BackgroundColor3 = Color3.fromRGB(30, 40, 35)
            InnerBox.Parent = BindFrame
            UI:CreateCorner(InnerBox, UDim.new(0, 4))
            local InnerStroke = UI:CreateStroke(InnerBox, Library.Theme.BorderColor, 1)
            
            local DisplayText = Instance.new("TextLabel")
            DisplayText.Size = UDim2.new(1, 0, 1, 0)
            DisplayText.BackgroundTransparency = 1
            DisplayText.Font = Enum.Font.GothamBold
            DisplayText.Text = assignedKey.Name:upper()
            DisplayText.TextColor3 = Library.Theme.AccentLight
            DisplayText.TextSize = 10
            DisplayText.Parent = InnerBox
            
            local TriggerBtn = Instance.new("TextButton")
            TriggerBtn.Size = UDim2.new(1, 0, 1, 0)
            TriggerBtn.BackgroundTransparency = 1
            TriggerBtn.Text = ""
            TriggerBtn.Parent = BindFrame
            
            local function StartListening()
                listening = true
                DisplayText.Text = "[...]"
                Tween(InnerStroke, TweenInfo.new(0.12, Enum.EasingStyle.OutQuad), {Color = Library.Theme.AccentColor})
                Tween(Label, TweenInfo.new(0.12, Enum.EasingStyle.OutQuad), {TextColor3 = Library.Theme.TextPrimary})
            end
            
            local inputConnection
            inputConnection = UserInputService.InputBegan:Connect(function(input, processed)
                if listening and not processed then
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        assignedKey = input.KeyCode
                        listening = false
                        DisplayText.Text = assignedKey.Name:upper()
                        Tween(InnerStroke, TweenInfo.new(0.12, Enum.EasingStyle.OutQuad), {Color = Library.Theme.BorderColor})
                        Tween(Label, TweenInfo.new(0.12, Enum.EasingStyle.OutQuad), {TextColor3 = Library.Theme.TextSecondary})
                    end
                elseif not listening and input.KeyCode == assignedKey and not processed then
                    pcall(callback)
                end
            end)
            
            TriggerBtn.MouseButton1Click:Connect(function()
                if not listening then
                    StartListening()
                end
            end)
            
            TriggerBtn.MouseEnter:Connect(function()
                Tween(BindFrame, TweenInfo.new(0.12, Enum.EasingStyle.OutQuad), {BackgroundColor3 = Library.Theme.ElementHover})
                Tween(Stroke, TweenInfo.new(0.12, Enum.EasingStyle.OutQuad), {Color = Library.Theme.AccentColor})
            end)
            TriggerBtn.MouseLeave:Connect(function()
                Tween(BindFrame, TweenInfo.new(0.12, Enum.EasingStyle.OutQuad), {BackgroundColor3 = Library.Theme.ElementBackground})
                Tween(Stroke, TweenInfo.new(0.12, Enum.EasingStyle.OutQuad), {Color = Library.Theme.BorderColor})
            end)
        end
        
        -- Luxury Dynamic Color Picker Component
        function TabAPI:CreateColorPicker(options)
            options = options or {}
            local cpName = options.Name or "Atmosphere Color"
            local defaultColor = options.Default or Color3.fromRGB(46, 184, 114)
            local callback = options.Callback or function() end
            
            local selectedCol = defaultColor
            local h, s, v = Color3.toHSV(selectedCol)
            local expanded = false
            
            local PickerContainer = Instance.new("Frame")
            PickerContainer.Size = UDim2.new(1, 0, 0, 36)
            PickerContainer.BackgroundColor3 = Library.Theme.ElementBackground
            PickerContainer.BorderSizePixel = 0
            PickerContainer.ClipsDescendants = true
            PickerContainer.Parent = Page
            UI:CreateCorner(PickerContainer, UDim.new(0, 6))
            local Stroke = UI:CreateStroke(PickerContainer, Library.Theme.BorderColor, 1)
            
            local HeaderButton = Instance.new("TextButton")
            HeaderButton.Size = UDim2.new(1, 0, 0, 36)
            HeaderButton.BackgroundTransparency = 1
            HeaderButton.Text = ""
            HeaderButton.Parent = PickerContainer
            
            local TitleLabel = Instance.new("TextLabel")
            TitleLabel.Size = UDim2.new(0.5, 0, 1, 0)
            TitleLabel.Position = UDim2.new(0, 12, 0, 0)
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.Font = Enum.Font.GothamSemibold
            TitleLabel.Text = cpName
            TitleLabel.TextColor3 = Library.Theme.TextSecondary
            TitleLabel.TextSize = 12
            TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
            TitleLabel.Parent = HeaderButton
            
            -- Color preview display circle
            local PreviewCircle = Instance.new("Frame")
            PreviewCircle.Size = UDim2.new(0, 16, 0, 16)
            PreviewCircle.Position = UDim2.new(1, -28, 0.5, -8)
            PreviewCircle.BackgroundColor3 = selectedCol
            PreviewCircle.Parent = HeaderButton
            UI:CreateCorner(PreviewCircle, UDim.new(1, 0))
            local PreviewStroke = UI:CreateStroke(PreviewCircle, Library.Theme.BorderColor, 1)
            
            -- Hidden controls panel
            local ControlPanel = Instance.new("Frame")
            ControlPanel.Size = UDim2.new(1, -24, 0, 110)
            ControlPanel.Position = UDim2.new(0, 12, 0, 36)
            ControlPanel.BackgroundTransparency = 1
            ControlPanel.Parent = PickerContainer
            
            -- Hue Slider Track
            local HueTrack = Instance.new("Frame")
            HueTrack.Size = UDim2.new(1, 0, 0, 12)
            HueTrack.Position = UDim2.new(0, 0, 0, 10)
            HueTrack.BorderSizePixel = 0
            HueTrack.Parent = ControlPanel
            UI:CreateCorner(HueTrack, UDim.new(0, 3))
            
            -- Spectrum Gradient Builder
            local hueSeq = {}
            for i = 0, 6 do
                local pointColor = Color3.fromHSV(i/6, 1, 1)
                table.insert(hueSeq, ColorSequenceKeypoint.new(i/6, pointColor))
            end
            UI:CreateGradient(HueTrack, hueSeq, 0)
            
            local HueCursor = Instance.new("Frame")
            HueCursor.Size = UDim2.new(0, 6, 1, 4)
            HueCursor.Position = UDim2.new(h, -3, 0.5, -8)
            HueCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            HueCursor.Parent = HueTrack
            UI:CreateCorner(HueCursor, UDim.new(1, 0))
            UI:CreateStroke(HueCursor, Color3.fromRGB(0, 0, 0), 1)
            
            -- Saturation / Value Canvas Frame
            local SatValCanvas = Instance.new("Frame")
            SatValCanvas.Size = UDim2.new(1, 0, 0, 64)
            SatValCanvas.Position = UDim2.new(0, 0, 0, 32)
            SatValCanvas.BorderSizePixel = 0
            SatValCanvas.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
            SatValCanvas.Parent = ControlPanel
            UI:CreateCorner(SatValCanvas, UDim.new(0, 4))
            
            -- Gradient Overlay (Black to transparent white simulation)
            local SatGradient = Instance.new("Frame")
            SatGradient.Size = UDim2.new(1, 0, 1, 0)
            SatGradient.BackgroundTransparency = 0
            SatGradient.Parent = SatValCanvas
            UI:CreateCorner(SatGradient, UDim.new(0, 4))
            UI:CreateGradient(SatGradient, {
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromHSV(h, 1, 1))
            }, 0)
            
            local ValGradient = Instance.new("Frame")
            ValGradient.Size = UDim2.new(1, 0, 1, 0)
            ValGradient.BackgroundTransparency = 0
            ValGradient.Parent = SatValCanvas
            UI:CreateCorner(ValGradient, UDim.new(0, 4))
            UI:CreateGradient(ValGradient, {
                ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
            }, -90)
            
            -- Blend values smoothly
            SatGradient.BackgroundTransparency = 0.1
            ValGradient.BackgroundTransparency = 0.4
            
            local CanvasCursor = Instance.new("Frame")
            CanvasCursor.Size = UDim2.new(0, 8, 0, 8)
            CanvasCursor.Position = UDim2.new(s, -4, 1 - v, -4)
            CanvasCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            CanvasCursor.Parent = SatValCanvas
            UI:CreateCorner(CanvasCursor, UDim.new(1, 0))
            UI:CreateStroke(CanvasCursor, Color3.fromRGB(0, 0, 0), 1)
            
            local hueDragging = false
            local svDragging = false
            
            local function UpdateColorOutput()
                selectedCol = Color3.fromHSV(h, s, v)
                PreviewCircle.BackgroundColor3 = selectedCol
                SatGradient.UIGradient.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromHSV(h, 1, 1))
                })
                pcall(callback, selectedCol)
            end
            
            -- Interaction math routines
            local HueTrigger = Instance.new("TextButton")
            HueTrigger.Size = UDim2.new(1, 0, 1, 0)
            HueTrigger.BackgroundTransparency = 1
            HueTrigger.Text = ""
            HueTrigger.Parent = HueTrack
            
            local function UpdateHue(input)
                local percentage = math.clamp((input.Position.X - HueTrack.AbsolutePosition.X) / HueTrack.AbsoluteSize.X, 0, 1)
                h = percentage
                HueCursor.Position = UDim2.new(h, -3, 0.5, -8)
                UpdateColorOutput()
            end
            
            HueTrigger.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    hueDragging = true
                    UpdateHue(input)
                end
            end)
            
            local SVTrigger = Instance.new("TextButton")
            SVTrigger.Size = UDim2.new(1, 0, 1, 0)
            SVTrigger.BackgroundTransparency = 1
            SVTrigger.Text = ""
            SVTrigger.Parent = SatValCanvas
            
            local function UpdateSV(input)
                local sizeX, sizeY = SatValCanvas.AbsoluteSize.X, SatValCanvas.AbsoluteSize.Y
                local posX, posY = SatValCanvas.AbsolutePosition.X, SatValCanvas.AbsolutePosition.Y
                local percentX = math.clamp((input.Position.X - posX) / sizeX, 0, 1)
                local percentY = math.clamp((input.Position.Y - posY) / sizeY, 0, 1)
                s = percentX
                v = 1 - percentY
                CanvasCursor.Position = UDim2.new(s, -4, percentY, -4)
                UpdateColorOutput()
            end
            
            SVTrigger.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    svDragging = true
                    UpdateSV(input)
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    hueDragging = false
                    svDragging = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if hueDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    UpdateHue(input)
                end
                if svDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    UpdateSV(input)
                end
            end)
            
            HeaderButton.MouseEnter:Connect(function()
                Tween(PickerContainer, TweenInfo.new(0.12, Enum.EasingStyle.OutQuad), {BackgroundColor3 = Library.Theme.ElementHover})
                Tween(Stroke, TweenInfo.new(0.12, Enum.EasingStyle.OutQuad), {Color = Library.Theme.AccentColor})
            end)
            HeaderButton.MouseLeave:Connect(function()
                Tween(PickerContainer, TweenInfo.new(0.12, Enum.EasingStyle.OutQuad), {BackgroundColor3 = Library.Theme.ElementBackground})
                Tween(Stroke, TweenInfo.new(0.12, Enum.EasingStyle.OutQuad), {Color = Library.Theme.BorderColor})
            end)
            
            HeaderButton.MouseButton1Click:Connect(function()
                expanded = not expanded
                if expanded then
                    Tween(PickerContainer, TweenInfo.new(0.22, Enum.EasingStyle.OutQuad), {Size = UDim2.new(1, 0, 0, 154)})
                    Tween(TitleLabel, TweenInfo.new(0.22, Enum.EasingStyle.OutQuad), {TextColor3 = Library.Theme.TextPrimary})
                else
                    Tween(PickerContainer, TweenInfo.new(0.22, Enum.EasingStyle.OutQuad), {Size = UDim2.new(1, 0, 0, 36)})
                    Tween(TitleLabel, TweenInfo.new(0.22, Enum.EasingStyle.OutQuad), {TextColor3 = Library.Theme.TextSecondary})
                end
            end)
            
            UpdateColorOutput()
        end
        
        table.insert(WindowAPI.Tabs, TabAPI)
        return TabAPI
    end
    
    return WindowAPI
end

return Library
