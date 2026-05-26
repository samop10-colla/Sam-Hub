--[[
    Sam's Hub — Ultimate Golden UI Library (OOP Refactored & Fixed)
    Author: ENI (Obsessed Developer GF)
    Version: 1.2.1 (Patched)
--]]

local Library = {}
Library.__index = Library

local Tab = {}
Tab.__index = Tab

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Ensure LocalPlayer is authenticated
local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    task.wait(0.1)
    LocalPlayer = Players.LocalPlayer
end

-- Resolve parent container safely
local ParentGui
local success = pcall(function()
    ParentGui = game:GetService("CoreGui")
end)
if not success or not ParentGui then
    ParentGui = LocalPlayer:WaitForChild("PlayerGui", 12) or LocalPlayer.PlayerGui
end

-- Golden Color Palette
local Theme = {
    Background = Color3.fromRGB(12, 12, 12),
    Secondary = Color3.fromRGB(20, 20, 20),
    Border = Color3.fromRGB(35, 35, 35),
    Primary = Color3.fromRGB(212, 175, 55), -- Metallic Gold
    Accent = Color3.fromRGB(255, 215, 0), -- Bright Gold
    Text = Color3.fromRGB(245, 245, 245),
    TextDark = Color3.fromRGB(130, 130, 130)
}

-- Utility function to easily create instances with clean declarative structure
local function Create(className, properties, children)
    local inst = Instance.new(className)
    for k, v in pairs(properties) do
        inst[k] = v
    end
    if children then
        for _, child in ipairs(children) do
            child.Parent = inst
        end
    end
    return inst
end

-- Custom gold gradient overlay generator
local function AddGoldGradient(parent, rotation)
    local Gradient = Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 223, 128)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(197, 160, 89)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 223, 128))
        }),
        Rotation = rotation or 45
    })
    Gradient.Parent = parent
    return Gradient
end

-- Premium Dragging script supporting both Touch and Mouse input with smooth tweening
local function MakeDraggable(gui, dragSpeed)
    local dragging = false
    local dragInput
    local dragStart
    local startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        local targetPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        TweenService:Create(gui, TweenInfo.new(dragSpeed or 0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = targetPos}):Play()
    end

    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position
        end
    end)
    
    gui.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    gui.InputChanged:Connect(function(input)
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

function Library:CreateWindow()
    local self = setmetatable({}, Library)
    
    -- Main ScreenGui
    local ScreenGui = Create("ScreenGui", {
        Name = "SamsHub",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    
    -- Safely parent to CoreGui or fallback to PlayerGui
    local parentSuccess = pcall(function()
        ScreenGui.Parent = ParentGui
    end)
    if not parentSuccess or not ScreenGui.Parent then
        ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui", 10) or LocalPlayer.PlayerGui
    end
    
    -- Footer description updates
    local footerText
    local function UpdateFooter(desc)
        if footerText then
            footerText.Text = desc or "Hover over a feature to view its details."
            footerText.TextColor3 = Theme.Text
        end
    end
    
    local function ResetFooter()
        if footerText then
            footerText.Text = "Hover over a feature to view its details."
            footerText.TextColor3 = Theme.TextDark
        end
    end
    
    ---------------------------------------------------------
    -- 1. Full Screen Animated Loading Screen
    ---------------------------------------------------------
    local LoadingScreen = Create("Frame", {
        Name = "LoadingScreen",
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Color3.fromRGB(8, 8, 8),
        ZIndex = 10,
        Active = true,
        Parent = ScreenGui
    })
    
    local LoadingContainer = Create("Frame", {
        Size = UDim2.new(0, 450, 0, 450),
        Position = UDim2.new(0.5, -225, 0.5, -225),
        BackgroundTransparency = 1,
        ZIndex = 11,
        Parent = LoadingScreen
    })
    
    -- Concentric Rotating Golden Rings
    local OuterRing = Create("Frame", {
        Size = UDim2.new(0, 280, 0, 280),
        Position = UDim2.new(0.5, -140, 0.5, -140),
        BackgroundTransparency = 1,
        ZIndex = 11,
        Parent = LoadingContainer
    })
    Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = OuterRing})
    local OuterStroke = Create("UIStroke", {
        Color = Theme.Primary,
        Thickness = 1.5,
        Parent = OuterRing
    })
    AddGoldGradient(OuterStroke, 0)
    
    local InnerRing = Create("Frame", {
        Size = UDim2.new(0, 240, 0, 240),
        Position = UDim2.new(0.5, -120, 0.5, -120),
        BackgroundTransparency = 1,
        ZIndex = 11,
        Parent = LoadingContainer
    })
    Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = InnerRing})
    local InnerStroke = Create("UIStroke", {
        Color = Theme.Accent,
        Thickness = 1,
        Parent = InnerRing
    })
    AddGoldGradient(InnerStroke, 180)
    
    local LoadingTitle = Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 50),
        Position = UDim2.new(0, 0, 0.5, -45),
        BackgroundTransparency = 1,
        Text = "Sam's Hub",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 44,
        ZIndex = 12,
        Parent = LoadingContainer
    })
    local TitleGradient = AddGoldGradient(LoadingTitle, 45)
    
    local LoadingSubtitle = Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0.5, 5),
        BackgroundTransparency = 1,
        Text = "INITIALIZING JJS FRAMEWORK",
        TextColor3 = Theme.TextDark,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        ZIndex = 12,
        Parent = LoadingContainer
    })
    
    -- Progress Bar
    local BarBG = Create("Frame", {
        Size = UDim2.new(0, 220, 0, 4),
        Position = UDim2.new(0.5, -110, 0.5, 35),
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
        BorderSizePixel = 0,
        ZIndex = 12,
        Parent = LoadingContainer
    })
    Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = BarBG})
    
    local BarFill = Create("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Theme.Primary,
        BorderSizePixel = 0,
        ZIndex = 12,
        Parent = BarBG
    })
    Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = BarFill})
    local BarGradient = AddGoldGradient(BarFill, 45)
    
    local LoadingPercent = Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0.5, 50),
        BackgroundTransparency = 1,
        Text = "0%",
        TextColor3 = Theme.Accent,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        ZIndex = 12,
        Parent = LoadingContainer
    })
    
    ---------------------------------------------------------
    -- 2. Safe Threaded Motion Graphics
    ---------------------------------------------------------
    -- Spin Rings
    local ringConnection
    ringConnection = RunService.RenderStepped:Connect(function()
        if LoadingScreen and LoadingScreen.Parent then
            pcall(function()
                OuterRing.Rotation = (OuterRing.Rotation + 0.8) % 360
                InnerRing.Rotation = (InnerRing.Rotation - 1.2) % 360
            end)
        else
            ringConnection:Disconnect()
        end
    end)
    
    -- Shimmer Gold Text & Bar
    pcall(function()
        local ShimmerInfo = TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true)
        TweenService:Create(TitleGradient, ShimmerInfo, {Offset = Vector2.new(1, 0)}):Play()
        TweenService:Create(BarGradient, ShimmerInfo, {Offset = Vector2.new(1, 0)}):Play()
    end)
    
    -- Gold Embers Particle Spawner
    local isSpawningParticles = true
    local function SpawnGoldEmber()
        if not LoadingScreen or not LoadingScreen.Parent then return end
        local size = math.random(3, 5)
        local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
        
        -- Safely clamp constraints to avoid empty interval floating-point errors
        local startX = math.random(0, math.max(1, math.floor(viewport.X)))
        local startY = viewport.Y + 20
        
        local Ember = Create("Frame", {
            Size = UDim2.new(0, size, 0, size),
            Position = UDim2.new(0, startX, 0, startY),
            BackgroundColor3 = Theme.Accent,
            BorderSizePixel = 0,
            ZIndex = 11,
            Parent = LoadingScreen
        })
        Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Ember})
        AddGoldGradient(Ember, math.random(0, 90))
        
        local endX = startX + math.random(-100, 100)
        local endY = math.random(100, math.max(101, math.floor(viewport.Y) - 150))
        local lifetime = math.random(30, 45) / 10
        
        local move = TweenService:Create(Ember, TweenInfo.new(lifetime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, endX, 0, endY),
            BackgroundTransparency = 1,
            Rotation = math.random(0, 360)
        })
        move:Play()
        move.Completed:Connect(function()
            Ember:Destroy()
        end)
    end
    
    local lastParticleSpawn = 0
    local emberConnection
    emberConnection = RunService.RenderStepped:Connect(function()
        if not isSpawningParticles or not (LoadingScreen and LoadingScreen.Parent) then
            emberConnection:Disconnect()
            return
        end
        if tick() - lastParticleSpawn > 0.08 then
            pcall(SpawnGoldEmber)
            lastParticleSpawn = tick()
        end
    end)
    
    ---------------------------------------------------------
    -- 3. Main Window Layout (Starts Hidden)
    ---------------------------------------------------------
    local MainWindow = Create("Frame", {
        Name = "MainWindow",
        Size = UDim2.new(0, 550, 0, 350),
        Position = UDim2.new(0.5, -275, 0.5, -175),
        BackgroundColor3 = Theme.Background,
        Visible = false,
        Parent = ScreenGui
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = MainWindow})
    
    local WindowStroke = Create("UIStroke", {
        Color = Theme.Primary,
        Thickness = 1.5,
        Parent = MainWindow
    })
    AddGoldGradient(WindowStroke)
    
    -- Top Bar
    local TopBar = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Theme.Secondary,
        BorderSizePixel = 0,
        Parent = MainWindow
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = TopBar})
    
    Create("Frame", {
        Size = UDim2.new(1, 0, 0, 10),
        Position = UDim2.new(0, 0, 1, -10),
        BackgroundColor3 = Theme.Secondary,
        BorderSizePixel = 0,
        Parent = TopBar
    })
    
    local WindowTitle = Create("TextLabel", {
        Size = UDim2.new(0, 200, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        BackgroundTransparency = 1,
        Text = "Sam's Hub",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TopBar
    })
    AddGoldGradient(WindowTitle)
    
    local CloseBtn = Create("TextButton", {
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -35, 0.5, -15),
        BackgroundTransparency = 1,
        Text = "×",
        TextColor3 = Theme.TextDark,
        Font = Enum.Font.GothamBold,
        TextSize = 22,
        Parent = TopBar
    })
    
    Create("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Theme.Border,
        BorderSizePixel = 0,
        Parent = TopBar
    })
    
    MakeDraggable(MainWindow, 0.12)
    
    local NavigationPanel = Create("Frame", {
        Size = UDim2.new(0, 130, 1, -80),
        Position = UDim2.new(0, 0, 0, 41),
        BackgroundColor3 = Theme.Secondary,
        BorderSizePixel = 0,
        Parent = MainWindow
    })
    
    Create("Frame", {
        Size = UDim2.new(0, 1, 1, 0),
        Position = UDim2.new(1, -1, 0, 0),
        BackgroundColor3 = Theme.Border,
        BorderSizePixel = 0,
        Parent = NavigationPanel
    })
    
    local TabContainer = Create("ScrollingFrame", {
        Size = UDim2.new(1, -10, 1, -10),
        Position = UDim2.new(0, 5, 0, 5),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticCanvasSize.Y,
        Parent = NavigationPanel
    })
    
    local TabListLayout = Create("UIListLayout", {
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = TabContainer
    })
    
    local ContentContainer = Create("Frame", {
        Size = UDim2.new(1, -140, 1, -80),
        Position = UDim2.new(0, 135, 0, 41),
        BackgroundTransparency = 1,
        Parent = MainWindow
    })
    
    local Footer = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 38),
        Position = UDim2.new(0, 0, 1, -38),
        BackgroundColor3 = Theme.Secondary,
        BorderSizePixel = 0,
        Parent = MainWindow
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = Footer})
    
    Create("Frame", {
        Size = UDim2.new(1, 0, 0, 10),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Theme.Secondary,
        BorderSizePixel = 0,
        Parent = Footer
    })
    
    Create("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Theme.Border,
        BorderSizePixel = 0,
        Parent = Footer
    })
    
    footerText = Create("TextLabel", {
        Size = UDim2.new(1, -30, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        BackgroundTransparency = 1,
        Text = "Hover over a feature to view its details.",
        TextColor3 = Theme.TextDark,
        Font = Enum.Font.GothamMedium,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClipsDescendants = true,
        Parent = Footer
    })
    
    ---------------------------------------------------------
    -- 4. Floating Toggle Screen UI ("S")
    ---------------------------------------------------------
    local FloatingToggle = Create("TextButton", {
        Name = "FloatingToggle",
        Size = UDim2.new(0, 50, 0, 50),
        Position = UDim2.new(0.05, 0, 0.3, 0),
        BackgroundColor3 = Theme.Background,
        Text = "S",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.FredokaOne,
        TextSize = 26,
        Visible = false,
        Active = true,
        Parent = ScreenGui
    })
    Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = FloatingToggle})
    
    local ToggleStroke = Create("UIStroke", {
        Color = Theme.Primary,
        Thickness = 2,
        Parent = FloatingToggle
    })
    AddGoldGradient(ToggleStroke)
    AddGoldGradient(FloatingToggle)
    MakeDraggable(FloatingToggle, 0.1)
    
    local uiOpen = false
    local function ToggleUI()
        uiOpen = not uiOpen
        if uiOpen then
            MainWindow.Visible = true
            MainWindow.Size = UDim2.new(0, 0, 0, 0)
            MainWindow.Position = UDim2.new(0.5, 0, 0.5, 0)
            
            TweenService:Create(MainWindow, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 550, 0, 350),
                Position = UDim2.new(0.5, -275, 0.5, -175)
            }):Play()
        else
            local hideTween = TweenService:Create(MainWindow, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 0, 0, 0),
                Position = UDim2.new(0.5, 0, 0.5, 0)
            })
            hideTween:Play()
            hideTween.Completed:Connect(function()
                if not uiOpen then
                    MainWindow.Visible = false
                end
            end)
        end
    end
    
    FloatingToggle.MouseButton1Click:Connect(ToggleUI)
    
    CloseBtn.MouseEnter:Connect(function()
        TweenService:Create(CloseBtn, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(255, 80, 80)}):Play()
    end)
    CloseBtn.MouseLeave:Connect(function()
        TweenService:Create(CloseBtn, TweenInfo.new(0.15), {TextColor3 = Theme.TextDark}):Play()
    end)
    
    CloseBtn.MouseButton1Click:Connect(function()
        uiOpen = false
        TweenService:Create(MainWindow, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }):Play()
        local killToggle = TweenService:Create(FloatingToggle, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0)
        })
        killToggle:Play()
        killToggle.Completed:Connect(function()
            ScreenGui:Destroy()
        end)
    end)
    
    ---------------------------------------------------------
    -- 5. Reliable Loading Engine (Patched Tween Conflict)
    ---------------------------------------------------------
    local function PlayLoadingAnimation()
        -- Uses a NumberValue for smooth engine interpolation rather than overlapping Tweens in loops
        local ValueState = Instance.new("NumberValue")
        ValueState.Value = 0
        
        local updater
        updater = ValueState:GetPropertyChangedSignal("Value"):Connect(function()
            local val = ValueState.Value
            local ratio = val / 100
            BarFill.Size = UDim2.new(ratio, 0, 1, 0)
            LoadingPercent.Text = tostring(math.floor(val)) .. "%"
        end)
        
        -- Native engine handles frame-by-frame easing with complete reliability
        local loadTween = TweenService:Create(ValueState, TweenInfo.new(3.2, Enum.EasingStyle.Linear), {Value = 100})
        
        loadTween.Completed:Connect(function()
            updater:Disconnect()
            isSpawningParticles = false
            
            task.delay(0.2, function()
                local fadeOut = TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                
                pcall(function()
                    for _, descendant in ipairs(LoadingScreen:GetDescendants()) do
                        if descendant:IsA("Frame") and descendant ~= LoadingScreen then
                            TweenService:Create(descendant, fadeOut, {BackgroundTransparency = 1}):Play()
                        elseif descendant:IsA("TextLabel") then
                            TweenService:Create(descendant, fadeOut, {TextTransparency = 1}):Play()
                        elseif descendant:IsA("UIStroke") then
                            TweenService:Create(descendant, fadeOut, {Transparency = 1}):Play()
                        end
                    end
                end)
                
                local ScreenFade = TweenService:Create(LoadingScreen, fadeOut, {BackgroundTransparency = 1})
                ScreenFade:Play()
                
                ScreenFade.Completed:Connect(function()
                    LoadingScreen:Destroy()
                    ValueState:Destroy()
                    
                    FloatingToggle.Visible = true
                    FloatingToggle.Size = UDim2.new(0, 0, 0, 0)
                    TweenService:Create(FloatingToggle, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                        Size = UDim2.new(0, 50, 0, 50)
                    }):Play()
                    
                    ToggleUI()
                end)
            end)
        end)
        
        loadTween:Play()
    end
    
    PlayLoadingAnimation()
    
    -- Store shared OOP instances on Window object
    self.Theme = Theme
    self.ScreenGui = ScreenGui
    self.MainWindow = MainWindow
    self.TabContainer = TabContainer
    self.ContentContainer = ContentContainer
    self.ActiveTab = nil
    self.UpdateFooter = UpdateFooter
    self.ResetFooter = ResetFooter
    
    return self
end

---------------------------------------------------------
-- 6. Clean OOP Prototype Layout (Methods on Prototype)
---------------------------------------------------------
function Library:CreateTab(tabName)
    local window = self
    local Theme = window.Theme
    
    local TabBtn = Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = Color3.fromRGB(24, 24, 24),
        Text = tabName,
        TextColor3 = Theme.TextDark,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        BorderSizePixel = 0,
        Parent = window.TabContainer
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 5), Parent = TabBtn})
    
    local TabStroke = Create("UIStroke", {
        Color = Theme.Border,
        Thickness = 1,
        Parent = TabBtn
    })
    
    local Page = Create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.Primary,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticCanvasSize.Y,
        Visible = false,
        Parent = window.ContentContainer
    })
    Create("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        Parent = Page
    })
    
    local function SelectTab()
        if window.ActiveTab then
            window.ActiveTab.Button.TextColor3 = Theme.TextDark
            window.ActiveTab.Button.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
            window.ActiveTab.Stroke.Color = Theme.Border
            window.ActiveTab.Page.Visible = false
        end
        
        window.ActiveTab = {Button = TabBtn, Page = Page, Stroke = TabStroke}
        TabBtn.TextColor3 = Theme.Primary
        TabBtn.BackgroundColor3 = Color3.fromRGB(28, 25, 17)
        TabStroke.Color = Theme.Primary
        Page.Visible = true
    end
    
    TabBtn.MouseButton1Click:Connect(SelectTab)
    if not window.ActiveTab then
        SelectTab()
    end
    
    local tabInstance = setmetatable({}, Tab)
    tabInstance.Window = window
    tabInstance.Page = Page
    
    return tabInstance
end

---------------------------------------------------------
-- Tab Class: Elements Instantiation Methods
---------------------------------------------------------

-- Element: Toggle
function Tab:CreateToggle(name, description, default, callback)
    local window = self.Window
    local Theme = window.Theme
    local Page = self.Page
    local state = default or false
    
    local ToggleFrame = Create("Frame", {
        Size = UDim2.new(1, -10, 0, 45),
        BackgroundColor3 = Color3.fromRGB(24, 24, 24),
        BorderSizePixel = 0,
        Parent = Page
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = ToggleFrame})
    
    local ElementStroke = Create("UIStroke", {
        Color = Theme.Border,
        Thickness = 1,
        Parent = ToggleFrame
    })
    
    local Label = Create("TextLabel", {
        Size = UDim2.new(1, -70, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = ToggleFrame
    })
    
    local Switch = Create("TextButton", {
        Size = UDim2.new(0, 42, 0, 20),
        Position = UDim2.new(1, -55, 0.5, -10),
        BackgroundColor3 = state and Theme.Primary or Color3.fromRGB(45, 45, 45),
        Text = "",
        Parent = ToggleFrame
    })
    Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Switch})
    
    local Knob = Create("Frame", {
        Size = UDim2.new(0, 14, 0, 14),
        Position = state and UDim2.new(1, -18, 0.5, -7) or UDim2.new(0, 4, 0.5, -7),
        BackgroundColor3 = Color3.fromRGB(245, 245, 245),
        Parent = Switch
    })
    Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Knob})
    
    local function UpdateVisuals()
        local targetPos = state and UDim2.new(1, -18, 0.5, -7) or UDim2.new(0, 4, 0.5, -7)
        local targetColor = state and Theme.Primary or Color3.fromRGB(45, 45, 45)
        
        TweenService:Create(Knob, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = targetPos}):Play()
        TweenService:Create(Switch, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = targetColor}):Play()
        
        task.spawn(function()
            callback(state)
        end)
    end
    
    Switch.MouseButton1Click:Connect(function()
        state = not state
        UpdateVisuals()
    end)
    
    ToggleFrame.MouseEnter:Connect(function()
        TweenService:Create(ToggleFrame, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}):Play()
        TweenService:Create(ElementStroke, TweenInfo.new(0.15), {Color = Theme.Primary}):Play()
        window.UpdateFooter(description)
    end)
    
    ToggleFrame.MouseLeave:Connect(function()
        TweenService:Create(ToggleFrame, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(24, 24, 24)}):Play()
        TweenService:Create(ElementStroke, TweenInfo.new(0.15), {Color = Theme.Border}):Play()
        window.ResetFooter()
    end)
    
    local ToggleObj = {}
    function ToggleObj:Set(newState)
        state = newState
        UpdateVisuals()
    end
    return ToggleObj
end

-- Element: Slider
function Tab:CreateSlider(name, description, min, max, default, callback)
    local window = self.Window
    local Theme = window.Theme
    local Page = self.Page
    local value = math.clamp(default or min, min, max)
    local sliding = false
    
    local SliderFrame = Create("Frame", {
        Size = UDim2.new(1, -10, 0, 55),
        BackgroundColor3 = Color3.fromRGB(24, 24, 24),
        BorderSizePixel = 0,
        Parent = Page
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = SliderFrame})
    
    local ElementStroke = Create("UIStroke", {
        Color = Theme.Border,
        Thickness = 1,
        Parent = SliderFrame
    })
    
    local Label = Create("TextLabel", {
        Size = UDim2.new(0, 200, 0, 25),
        Position = UDim2.new(0, 15, 0, 4),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = SliderFrame
    })
    
    local ValLabel = Create("TextLabel", {
        Size = UDim2.new(0, 100, 0, 25),
        Position = UDim2.new(1, -115, 0, 4),
        BackgroundTransparency = 1,
        Text = tostring(value),
        TextColor3 = Theme.Accent,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = SliderFrame
    })
    
    local Track = Create("TextButton", {
        Size = UDim2.new(1, -30, 0, 5),
        Position = UDim2.new(0.5, 0, 0.75, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(45, 45, 45),
        Text = "",
        BorderSizePixel = 0,
        Parent = SliderFrame
    })
    Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Track})
    
    local Fill = Create("Frame", {
        Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = Theme.Primary,
        BorderSizePixel = 0,
        Parent = Track
    })
    Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Fill})
    AddGoldGradient(Fill)
    
    local Knob = Create("Frame", {
        Size = UDim2.new(0, 11, 0, 11),
        Position = UDim2.new((value - min) / (max - min), 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(245, 245, 245),
        Parent = Track
    })
    Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Knob})
    
    local function UpdateSliderInput(input)
        local ratio = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
        local rawVal = min + ((max - min) * ratio)
        value = math.floor(rawVal + 0.5)
        
        ValLabel.Text = tostring(value)
        Fill.Size = UDim2.new(ratio, 0, 1, 0)
        Knob.Position = UDim2.new(ratio, 0, 0.5, 0)
        
        task.spawn(function()
            callback(value)
        end)
    end
    
    Track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = true
            UpdateSliderInput(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            UpdateSliderInput(input)
        end
    end)
    
    SliderFrame.MouseEnter:Connect(function()
        TweenService:Create(SliderFrame, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}):Play()
        TweenService:Create(ElementStroke, TweenInfo.new(0.15), {Color = Theme.Primary}):Play()
        window.UpdateFooter(description)
    end)
    
    SliderFrame.MouseLeave:Connect(function()
        TweenService:Create(SliderFrame, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(24, 24, 24)}):Play()
        TweenService:Create(ElementStroke, TweenInfo.new(0.15), {Color = Theme.Border}):Play()
        window.ResetFooter()
    end)
    
    local SliderObj = {}
    function SliderObj:Set(newVal)
        value = math.clamp(newVal, min, max)
        local ratio = (value - min) / (max - min)
        ValLabel.Text = tostring(value)
        TweenService:Create(Fill, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(ratio, 0, 1, 0)}):Play()
        TweenService:Create(Knob, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(ratio, 0, 0.5, 0)}):Play()
        task.spawn(function()
            callback(value)
        end)
    end
    return SliderObj
end

-- Element: Dropdown
function Tab:CreateDropdown(name, description, options, default, callback)
    local window = self.Window
    local Theme = window.Theme
    local Page = self.Page
    local selection = default or (options[1] or "None")
    local expanded = false
    
    local DropdownFrame = Create("Frame", {
        Size = UDim2.new(1, -10, 0, 42),
        BackgroundColor3 = Color3.fromRGB(24, 24, 24),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = Page
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = DropdownFrame})
    
    local ElementStroke = Create("UIStroke", {
        Color = Theme.Border,
        Thickness = 1,
        Parent = DropdownFrame
    })
    
    local TopBtn = Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundTransparency = 1,
        Text = "",
        Parent = DropdownFrame
    })
    
    local Label = Create("TextLabel", {
        Size = UDim2.new(0, 180, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TopBtn
    })
    
    local SelectLabel = Create("TextLabel", {
        Size = UDim2.new(0, 150, 1, 0),
        Position = UDim2.new(1, -185, 0, 0),
        BackgroundTransparency = 1,
        Text = selection,
        TextColor3 = Theme.Accent,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = TopBtn
    })
    
    local Indicator = Create("TextLabel", {
        Size = UDim2.new(0, 20, 1, 0),
        Position = UDim2.new(1, -30, 0, 0),
        BackgroundTransparency = 1,
        Text = "▼",
        TextColor3 = Theme.TextDark,
        Font = Enum.Font.GothamMedium,
        TextSize = 11,
        Parent = TopBtn
    })
    
    local OptionsHolder = Create("Frame", {
        Size = UDim2.new(1, -20, 0, 0),
        Position = UDim2.new(0, 10, 0, 42),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent = DropdownFrame
    })
    Create("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = OptionsHolder
    })
    
    local function ToggleDropdown()
        expanded = not expanded
        local targetHeight = expanded and (42 + (#options * 30) + 8) or 42
        local targetRotation = expanded and 180 or 0
        
        TweenService:Create(DropdownFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, -10, 0, targetHeight)
        }):Play()
        
        TweenService:Create(Indicator, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Rotation = targetRotation
        }):Play()
        
        if expanded then
            OptionsHolder.Size = UDim2.new(1, -20, 0, #options * 30)
        end
    end
    
    TopBtn.MouseButton1Click:Connect(ToggleDropdown)
    
    local function Populate()
        for _, item in ipairs(OptionsHolder:GetChildren()) do
            if item:IsA("TextButton") then
                item:Destroy()
            end
        end
        
        for i, opt in ipairs(options) do
            local OptBtn = Create("TextButton", {
                Size = UDim2.new(1, 0, 0, 26),
                BackgroundColor3 = Color3.fromRGB(30, 30, 30),
                Text = opt,
                TextColor3 = opt == selection and Theme.Primary or Theme.Text,
                Font = opt == selection and Enum.Font.GothamBold or Enum.Font.Gotham,
                TextSize = 12,
                BorderSizePixel = 0,
                LayoutOrder = i,
                Parent = OptionsHolder
            })
            Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = OptBtn})
            
            OptBtn.MouseEnter:Connect(function()
                TweenService:Create(OptBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(38, 38, 38)}):Play()
            end)
            OptBtn.MouseLeave:Connect(function()
                TweenService:Create(OptBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}):Play()
            end)
            
            OptBtn.MouseButton1Click:Connect(function()
                selection = opt
                SelectLabel.Text = opt
                ToggleDropdown()
                Populate()
                task.spawn(function()
                    callback(opt)
                end)
            end)
        end
    end
    
    Populate()
    
    DropdownFrame.MouseEnter:Connect(function()
        TweenService:Create(DropdownFrame, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}):Play()
        TweenService:Create(ElementStroke, TweenInfo.new(0.15), {Color = Theme.Primary}):Play()
        window.UpdateFooter(description)
    end)
    
    DropdownFrame.MouseLeave:Connect(function()
        TweenService:Create(DropdownFrame, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(24, 24, 24)}):Play()
        TweenService:Create(ElementStroke, TweenInfo.new(0.15), {Color = Theme.Border}):Play()
        window.ResetFooter()
    end)
    
    local DropdownObj = {}
    function DropdownObj:Set(newSelection)
        selection = newSelection
        SelectLabel.Text = newSelection
        Populate()
        task.spawn(function()
            callback(newSelection)
        end)
    end
    function DropdownObj:Refresh(newOptions)
        options = newOptions
        if not table.find(options, selection) then
            selection = options[1] or "None"
            SelectLabel.Text = selection
        end
        Populate()
        if expanded then
            OptionsHolder.Size = UDim2.new(1, -20, 0, #options * 30)
            DropdownFrame.Size = UDim2.new(1, -10, 0, 42 + (#options * 30) + 8)
        end
    end
    return DropdownObj
end

return Library
