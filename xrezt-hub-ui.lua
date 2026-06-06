-- ==============================================================================
-- XREZT HUB - PREMIUM ROBLOX UI LIBRARY (V3 OMEGA RELEASE - FULL SOURCE)
-- Architect: ENI
-- Target: 1700+ Lines, Full Motion Graphics Loader, Mobile Optimized, Flawless
-- ==============================================================================

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = Workspace.CurrentCamera

-- ==============================================================================
-- PROTECTED GUI INITIALIZATION
-- ==============================================================================
local HubName = "XreztHub_Premium_Runtime"
if CoreGui:FindFirstChild(HubName) then
    CoreGui[HubName]:Destroy()
end

local XreztUI = Instance.new("ScreenGui")
XreztUI.Name = HubName
XreztUI.ResetOnSpawn = false
XreztUI.ZIndexBehavior = Enum.ZIndexBehavior.Global
XreztUI.IgnoreGuiInset = true

local success = pcall(function() XreztUI.Parent = CoreGui end)
if not success then XreztUI.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- ==============================================================================
-- THEME ENGINE & PALETTES
-- ==============================================================================
local Themes = {
    MidnightSlate = {
        Background = Color3.fromRGB(15, 17, 23),
        Surface = Color3.fromRGB(22, 25, 33),
        SurfaceLight = Color3.fromRGB(30, 35, 45),
        Outline = Color3.fromRGB(40, 45, 55),
        Accent = Color3.fromRGB(88, 101, 242),
        AccentHover = Color3.fromRGB(105, 118, 255),
        Text = Color3.fromRGB(240, 240, 240),
        TextDim = Color3.fromRGB(150, 155, 170),
        Shadow = Color3.fromRGB(0, 0, 0),
        Success = Color3.fromRGB(67, 181, 129),
        Error = Color3.fromRGB(240, 71, 71),
        Warning = Color3.fromRGB(250, 166, 26)
    },
    OceanBlue = {
        Background = Color3.fromRGB(10, 15, 25),
        Surface = Color3.fromRGB(15, 25, 40),
        SurfaceLight = Color3.fromRGB(25, 40, 65),
        Outline = Color3.fromRGB(35, 55, 85),
        Accent = Color3.fromRGB(0, 160, 255),
        AccentHover = Color3.fromRGB(50, 180, 255),
        Text = Color3.fromRGB(230, 240, 255),
        TextDim = Color3.fromRGB(130, 150, 180),
        Shadow = Color3.fromRGB(0, 5, 10),
        Success = Color3.fromRGB(0, 200, 100),
        Error = Color3.fromRGB(255, 60, 60),
        Warning = Color3.fromRGB(255, 170, 0)
    },
    Aurora = {
        Background = Color3.fromRGB(12, 18, 16),
        Surface = Color3.fromRGB(18, 28, 25),
        SurfaceLight = Color3.fromRGB(28, 42, 38),
        Outline = Color3.fromRGB(40, 60, 55),
        Accent = Color3.fromRGB(0, 255, 170),
        AccentHover = Color3.fromRGB(50, 255, 190),
        Text = Color3.fromRGB(230, 255, 245),
        TextDim = Color3.fromRGB(130, 170, 150),
        Shadow = Color3.fromRGB(0, 5, 2),
        Success = Color3.fromRGB(0, 255, 100),
        Error = Color3.fromRGB(255, 50, 50),
        Warning = Color3.fromRGB(255, 180, 0)
    },
    Sunset = {
        Background = Color3.fromRGB(25, 15, 20),
        Surface = Color3.fromRGB(35, 22, 30),
        SurfaceLight = Color3.fromRGB(50, 30, 45),
        Outline = Color3.fromRGB(70, 45, 60),
        Accent = Color3.fromRGB(255, 100, 100),
        AccentHover = Color3.fromRGB(255, 130, 130),
        Text = Color3.fromRGB(255, 230, 235),
        TextDim = Color3.fromRGB(180, 140, 150),
        Shadow = Color3.fromRGB(10, 0, 5),
        Success = Color3.fromRGB(50, 200, 100),
        Error = Color3.fromRGB(255, 50, 50),
        Warning = Color3.fromRGB(255, 150, 0)
    },
    Emerald = {
        Background = Color3.fromRGB(10, 20, 15),
        Surface = Color3.fromRGB(15, 30, 22),
        SurfaceLight = Color3.fromRGB(25, 45, 35),
        Outline = Color3.fromRGB(35, 60, 45),
        Accent = Color3.fromRGB(46, 204, 113),
        AccentHover = Color3.fromRGB(60, 230, 130),
        Text = Color3.fromRGB(230, 255, 240),
        TextDim = Color3.fromRGB(140, 180, 160),
        Shadow = Color3.fromRGB(0, 10, 5),
        Success = Color3.fromRGB(0, 255, 100),
        Error = Color3.fromRGB(255, 50, 50),
        Warning = Color3.fromRGB(255, 180, 0)
    },
    Rose = {
        Background = Color3.fromRGB(25, 15, 18),
        Surface = Color3.fromRGB(35, 20, 25),
        SurfaceLight = Color3.fromRGB(50, 30, 38),
        Outline = Color3.fromRGB(70, 40, 50),
        Accent = Color3.fromRGB(255, 105, 180),
        AccentHover = Color3.fromRGB(255, 130, 195),
        Text = Color3.fromRGB(255, 230, 240),
        TextDim = Color3.fromRGB(180, 140, 155),
        Shadow = Color3.fromRGB(10, 0, 5),
        Success = Color3.fromRGB(50, 200, 100),
        Error = Color3.fromRGB(255, 50, 50),
        Warning = Color3.fromRGB(255, 150, 0)
    },
    Graphite = {
        Background = Color3.fromRGB(20, 20, 20),
        Surface = Color3.fromRGB(30, 30, 30),
        SurfaceLight = Color3.fromRGB(45, 45, 45),
        Outline = Color3.fromRGB(60, 60, 60),
        Accent = Color3.fromRGB(180, 180, 180),
        AccentHover = Color3.fromRGB(210, 210, 210),
        Text = Color3.fromRGB(255, 255, 255),
        TextDim = Color3.fromRGB(150, 150, 150),
        Shadow = Color3.fromRGB(5, 5, 5),
        Success = Color3.fromRGB(80, 200, 120),
        Error = Color3.fromRGB(220, 60, 60),
        Warning = Color3.fromRGB(220, 160, 40)
    },
    Obsidian = {
        Background = Color3.fromRGB(5, 5, 5),
        Surface = Color3.fromRGB(12, 12, 12),
        SurfaceLight = Color3.fromRGB(20, 20, 20),
        Outline = Color3.fromRGB(30, 30, 30),
        Accent = Color3.fromRGB(120, 120, 120),
        AccentHover = Color3.fromRGB(160, 160, 160),
        Text = Color3.fromRGB(220, 220, 220),
        TextDim = Color3.fromRGB(100, 100, 100),
        Shadow = Color3.fromRGB(0, 0, 0),
        Success = Color3.fromRGB(50, 180, 100),
        Error = Color3.fromRGB(200, 40, 40),
        Warning = Color3.fromRGB(200, 140, 20)
    },
    Crystal = {
        Background = Color3.fromRGB(245, 245, 250),
        Surface = Color3.fromRGB(255, 255, 255),
        SurfaceLight = Color3.fromRGB(235, 235, 245),
        Outline = Color3.fromRGB(220, 220, 230),
        Accent = Color3.fromRGB(100, 150, 255),
        AccentHover = Color3.fromRGB(130, 170, 255),
        Text = Color3.fromRGB(30, 30, 40),
        TextDim = Color3.fromRGB(100, 100, 120),
        Shadow = Color3.fromRGB(200, 200, 210),
        Success = Color3.fromRGB(40, 180, 100),
        Error = Color3.fromRGB(220, 50, 50),
        Warning = Color3.fromRGB(220, 150, 30)
    },
    Frost = {
        Background = Color3.fromRGB(230, 240, 255),
        Surface = Color3.fromRGB(240, 248, 255),
        SurfaceLight = Color3.fromRGB(220, 235, 255),
        Outline = Color3.fromRGB(200, 220, 245),
        Accent = Color3.fromRGB(50, 180, 255),
        AccentHover = Color3.fromRGB(80, 200, 255),
        Text = Color3.fromRGB(20, 40, 70),
        TextDim = Color3.fromRGB(90, 120, 160),
        Shadow = Color3.fromRGB(180, 200, 230),
        Success = Color3.fromRGB(30, 160, 90),
        Error = Color3.fromRGB(200, 40, 40),
        Warning = Color3.fromRGB(200, 130, 20)
    }
}

local CurrentTheme = Themes.MidnightSlate
local ThemeRegistry = {}

-- ==============================================================================
-- UTILITY FUNCTIONS
-- ==============================================================================
local function Create(className, properties)
    local inst = Instance.new(className)
    for k, v in pairs(properties) do
        if k ~= "Parent" then
            inst[k] = v
        end
    end
    if properties.Parent then
        inst.Parent = properties.Parent
    end
    return inst
end

local function Tween(obj, props, duration, style, dir)
    duration = duration or 0.4
    style = style or Enum.EasingStyle.Quint
    dir = dir or Enum.EasingDirection.Out
    local ti = TweenInfo.new(duration, style, dir)
    local tween = TweenService:Create(obj, ti, props)
    tween:Play()
    return tween
end

local function RegisterTheme(instance, prop, themeKey)
    table.insert(ThemeRegistry, {Instance = instance, Property = prop, ThemeKey = themeKey})
end

local function SetTheme(themeName)
    if Themes[themeName] then
        CurrentTheme = Themes[themeName]
        for _, data in ipairs(ThemeRegistry) do
            if data.Instance and data.Instance.Parent then
                Tween(data.Instance, {[data.Property] = CurrentTheme[data.ThemeKey]}, 0.5, Enum.EasingStyle.Quart)
            end
        end
    end
end

local function MakeDraggable(topbarObject, object)
    local dragging = false
    local dragInput, dragStart, startPos

    topbarObject.InputBegan:Connect(function(input)
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

    topbarObject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Tween(object, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}, 0.1, Enum.EasingStyle.Linear)
        end
    end)
end

local function CreateRipple(button)
    local ripple = Create("Frame", {
        Parent = button,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.8,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 0, 0, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex = button.ZIndex + 2
    })
    Create("UICorner", {Parent = ripple, CornerRadius = UDim.new(1, 0)})
    
    local maxSize = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 1.5
    local t1 = Tween(ripple, {Size = UDim2.new(0, maxSize, 0, maxSize), BackgroundTransparency = 1}, 0.6)
    t1.Completed:Connect(function() ripple:Destroy() end)
end

local function GetTextBounds(text, font, size, maxBounds)
    local textLabel = Create("TextLabel", {
        Text = text,
        Font = font,
        TextSize = size,
        Size = UDim2.new(0, maxBounds.X, 0, maxBounds.Y),
        TextWrapped = true
    })
    local bounds = textLabel.TextBounds
    textLabel:Destroy()
    return bounds
end

-- ==============================================================================
-- CONFIGURATION SYSTEM (SAVE/LOAD)
-- ==============================================================================
local ConfigSystem = {}
ConfigSystem.Flags = {}

function ConfigSystem:Save(name)
    if writefile then
        local success, err = pcall(function()
            writefile(name .. ".xrezt", HttpService:JSONEncode(self.Flags))
        end)
        return success
    end
    return false
end

function ConfigSystem:Load(name)
    if readfile and isfile and isfile(name .. ".xrezt") then
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile(name .. ".xrezt"))
        end)
        if success then
            for k, v in pairs(data) do
                self.Flags[k] = v
            end
            return true
        end
    end
    return false
end

-- ==============================================================================
-- XREZT HUB MAIN OBJECT
-- ==============================================================================
local XreztHub = {}
XreztHub.Windows = {}

-- ==============================================================================
-- NOTIFICATION SYSTEM (GLOBAL)
-- ==============================================================================
local NotificationContainer = Create("Frame", {
    Parent = XreztUI,
    Size = UDim2.new(0, 320, 1, -40),
    Position = UDim2.new(1, -340, 0, 20),
    BackgroundTransparency = 1,
    ZIndex = 5000
})
local NotifLayout = Create("UIListLayout", {
    Parent = NotificationContainer,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 12),
    VerticalAlignment = Enum.VerticalAlignment.Bottom
})

function XreztHub:Notify(config)
    local title = config.Title or "Notification"
    local text = config.Text or "Action completed."
    local duration = config.Duration or 3
    local typeStr = config.Type or "Info" -- Info, Success, Warning, Error
    
    local typeColor = CurrentTheme.Accent
    local iconId = "rbxassetid://6031090990"
    if typeStr == "Success" then 
        typeColor = CurrentTheme.Success 
        iconId = "rbxassetid://6031094678"
    elseif typeStr == "Warning" then 
        typeColor = CurrentTheme.Warning 
        iconId = "rbxassetid://6031094678"
    elseif typeStr == "Error" then 
        typeColor = CurrentTheme.Error 
        iconId = "rbxassetid://6031094678"
    end

    local NotifFrame = Create("Frame", {
        Parent = NotificationContainer,
        Size = UDim2.new(1, 0, 0, 80),
        BackgroundColor3 = CurrentTheme.Surface,
        Position = UDim2.new(1, 350, 0, 0),
        ZIndex = 5001
    })
    Create("UICorner", {Parent = NotifFrame, CornerRadius = UDim.new(0, 14)})
    RegisterTheme(NotifFrame, "BackgroundColor3", "Surface")
    
    local NotifShadow = Create("ImageLabel", {
        Parent = NotifFrame,
        Size = UDim2.new(1, 40, 1, 40),
        Position = UDim2.new(0, -20, 0, -20),
        BackgroundTransparency = 1,
        Image = "rbxassetid://6015536814",
        ImageColor3 = CurrentTheme.Shadow,
        ImageTransparency = 0.6,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        ZIndex = 5000
    })
    RegisterTheme(NotifShadow, "ImageColor3", "Shadow")

    local SideBar = Create("Frame", {
        Parent = NotifFrame,
        Size = UDim2.new(0, 4, 1, -24),
        Position = UDim2.new(0, 12, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = typeColor,
        ZIndex = 5002
    })
    Create("UICorner", {Parent = SideBar, CornerRadius = UDim.new(1, 0)})

    local NIcon = Create("ImageLabel", {
        Parent = NotifFrame,
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(0, 26, 0, 12),
        BackgroundTransparency = 1,
        Image = iconId,
        ImageColor3 = typeColor,
        ZIndex = 5002
    })

    local NTitle = Create("TextLabel", {
        Parent = NotifFrame,
        Size = UDim2.new(1, -60, 0, 20),
        Position = UDim2.new(0, 52, 0, 12),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = title,
        TextColor3 = CurrentTheme.Text,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 5002
    })
    RegisterTheme(NTitle, "TextColor3", "Text")

    local NText = Create("TextLabel", {
        Parent = NotifFrame,
        Size = UDim2.new(1, -40, 1, -40),
        Position = UDim2.new(0, 28, 0, 36),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Text = text,
        TextColor3 = CurrentTheme.TextDim,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        ZIndex = 5002
    })
    RegisterTheme(NText, "TextColor3", "TextDim")

    -- Slide In
    Tween(NotifFrame, {Position = UDim2.new(0, 0, 0, 0)}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    
    task.delay(duration, function()
        local t = Tween(NotifFrame, {Position = UDim2.new(1, 350, 0, 0)}, 0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        t.Completed:Connect(function() NotifFrame:Destroy() end)
    end)
end

function XreztHub:CreateWindow(config)
    config = config or {}
    local windowName = config.Name or "Xrezt Hub"
    local logoId = config.Logo or "rbxassetid://10826978415"
    local loadingEnabled = config.LoadingScreen ~= false
    
    -- ==============================================================================
    -- ADVANCED MOTION GRAPHICS LOADING SCREEN
    -- ==============================================================================
    local LoaderContainer = Create("Frame", {
        Parent = XreztUI,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = CurrentTheme.Background,
        ZIndex = 10000,
        Visible = loadingEnabled
    })
    
    local Particles = {}
    for i = 1, 15 do
        local p = Create("Frame", {
            Parent = LoaderContainer,
            Size = UDim2.new(0, math.random(50, 200), 0, math.random(50, 200)),
            Position = UDim2.new(math.random(), 0, math.random(), 0),
            BackgroundColor3 = CurrentTheme.Accent,
            BackgroundTransparency = math.random(80, 95) / 100,
            AnchorPoint = Vector2.new(0.5, 0.5),
            ZIndex = 10001
        })
        Create("UICorner", {Parent = p, CornerRadius = UDim.new(1, 0)})
        table.insert(Particles, {Inst = p, Speed = math.random(10, 50) / 100})
    end
    
    local rotConnection = RunService.RenderStepped:Connect(function()
        for i, pData in ipairs(Particles) do
            pData.Inst.Rotation = pData.Inst.Rotation + pData.Speed
        end
    end)

    local CenterGlow = Create("ImageLabel", {
        Parent = LoaderContainer,
        Size = UDim2.new(0, 800, 0, 800),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://1316045217",
        ImageColor3 = CurrentTheme.Accent,
        ImageTransparency = 0.8,
        ZIndex = 10002
    })

    local LoaderLogo = Create("ImageLabel", {
        Parent = LoaderContainer,
        Size = UDim2.new(0, 140, 0, 140),
        Position = UDim2.new(0.5, 0, 0.35, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Image = logoId,
        ImageColor3 = CurrentTheme.Accent,
        ImageTransparency = 1,
        ZIndex = 10003
    })

    local LoaderTitle = Create("TextLabel", {
        Parent = LoaderContainer,
        Size = UDim2.new(0, 400, 0, 40),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = windowName,
        TextColor3 = CurrentTheme.Text,
        TextSize = 32,
        TextTransparency = 1,
        ZIndex = 10003
    })

    local LoaderStatus = Create("TextLabel", {
        Parent = LoaderContainer,
        Size = UDim2.new(0, 400, 0, 20),
        Position = UDim2.new(0.5, 0, 0.55, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Text = "Initializing Core Engine...",
        TextColor3 = CurrentTheme.TextDim,
        TextSize = 16,
        TextTransparency = 1,
        ZIndex = 10003
    })

    local BarBg = Create("Frame", {
        Parent = LoaderContainer,
        Size = UDim2.new(0, 400, 0, 8),
        Position = UDim2.new(0.5, 0, 0.6, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = CurrentTheme.SurfaceLight,
        BackgroundTransparency = 1,
        ZIndex = 10003
    })
    Create("UICorner", {Parent = BarBg, CornerRadius = UDim.new(1, 0)})

    local BarFill = Create("Frame", {
        Parent = BarBg,
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = CurrentTheme.Accent,
        BackgroundTransparency = 1,
        ZIndex = 10004
    })
    Create("UICorner", {Parent = BarFill, CornerRadius = UDim.new(1, 0)})

    local LoaderPercentage = Create("TextLabel", {
        Parent = LoaderContainer,
        Size = UDim2.new(0, 50, 0, 20),
        Position = UDim2.new(0.5, 215, 0.6, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = "0%",
        TextColor3 = CurrentTheme.Accent,
        TextSize = 16,
        TextTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 10003
    })

    -- ==============================================================================
    -- MAIN UI ARCHITECTURE (MOBILE OPTIMIZED SCALING)
    -- ==============================================================================
    local MainFrame = Create("Frame", {
        Parent = XreztUI,
        Size = UDim2.new(0, 600, 0, 400),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = CurrentTheme.Background,
        Visible = false,
        ZIndex = 100
    })
    Create("UICorner", {Parent = MainFrame, CornerRadius = UDim.new(0, 16)})
    RegisterTheme(MainFrame, "BackgroundColor3", "Background")
    
    local MainShadow = Create("ImageLabel", {
        Parent = MainFrame,
        Size = UDim2.new(1, 80, 1, 80),
        Position = UDim2.new(0, -40, 0, -40),
        BackgroundTransparency = 1,
        Image = "rbxassetid://6015536814",
        ImageColor3 = CurrentTheme.Shadow,
        ImageTransparency = 0.4,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        ZIndex = 90
    })
    RegisterTheme(MainShadow, "ImageColor3", "Shadow")

    local Header = Create("Frame", {
        Parent = MainFrame,
        Size = UDim2.new(1, 0, 0, 45),
        BackgroundColor3 = CurrentTheme.Background,
        BackgroundTransparency = 1,
        ZIndex = 102
    })
    MakeDraggable(Header, MainFrame)

    local HeaderIcon = Create("ImageLabel", {
        Parent = Header,
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(0, 12, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        Image = logoId,
        ImageColor3 = CurrentTheme.Accent,
        ZIndex = 103
    })
    RegisterTheme(HeaderIcon, "ImageColor3", "Accent")

    local HeaderTitle = Create("TextLabel", {
        Parent = Header,
        Size = UDim2.new(0, 200, 1, 0),
        Position = UDim2.new(0, 45, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = windowName,
        TextColor3 = CurrentTheme.Text,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 103
    })
    RegisterTheme(HeaderTitle, "TextColor3", "Text")

    local CloseBtn = Create("TextButton", {
        Parent = Header,
        Size = UDim2.new(0, 26, 0, 26),
        Position = UDim2.new(1, -12, 0.5, 0),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = CurrentTheme.SurfaceLight,
        Text = "X",
        Font = Enum.Font.GothamBold,
        TextColor3 = CurrentTheme.TextDim,
        TextSize = 12,
        ZIndex = 103,
        AutoButtonColor = false
    })
    Create("UICorner", {Parent = CloseBtn, CornerRadius = UDim.new(0, 6)})
    RegisterTheme(CloseBtn, "BackgroundColor3", "SurfaceLight")
    RegisterTheme(CloseBtn, "TextColor3", "TextDim")

    CloseBtn.MouseEnter:Connect(function() Tween(CloseBtn, {BackgroundColor3 = CurrentTheme.Error, TextColor3 = Color3.fromRGB(255,255,255)}, 0.2) end)
    CloseBtn.MouseLeave:Connect(function() Tween(CloseBtn, {BackgroundColor3 = CurrentTheme.SurfaceLight, TextColor3 = CurrentTheme.TextDim}, 0.2) end)
    CloseBtn.MouseButton1Click:Connect(function()
        CreateRipple(CloseBtn)
        Tween(MainFrame, {Size = UDim2.new(0, 550, 0, 360), BackgroundTransparency = 1}, 0.3)
        for _, desc in ipairs(MainFrame:GetDescendants()) do
            if desc:IsA("TextLabel") or desc:IsA("TextButton") or desc:IsA("TextBox") then
                Tween(desc, {TextTransparency = 1}, 0.3)
            elseif desc:IsA("Frame") or desc:IsA("ScrollingFrame") then
                Tween(desc, {BackgroundTransparency = 1}, 0.3)
            elseif desc:IsA("ImageLabel") or desc:IsA("ImageButton") then
                Tween(desc, {ImageTransparency = 1}, 0.3)
            elseif desc:IsA("UIStroke") then
                Tween(desc, {Transparency = 1}, 0.3)
            end
        end
        task.wait(0.3)
        MainFrame.Visible = false
    end)

    -- Toggle Button Spawner (Floating)
    local ToggleSpawner = Create("TextButton", {
        Parent = XreztUI,
        Size = UDim2.new(0, 45, 0, 45),
        Position = UDim2.new(0, 15, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = CurrentTheme.Surface,
        Text = "",
        ZIndex = 9000,
        AutoButtonColor = false
    })
    Create("UICorner", {Parent = ToggleSpawner, CornerRadius = UDim.new(1, 0)})
    local SpawnerStroke = Create("UIStroke", {Parent = ToggleSpawner, Color = CurrentTheme.Outline, Thickness = 2})
    RegisterTheme(ToggleSpawner, "BackgroundColor3", "Surface")
    RegisterTheme(SpawnerStroke, "Color", "Outline")
    
    local ToggleIcon = Create("ImageLabel", {
        Parent = ToggleSpawner,
        Size = UDim2.new(0, 22, 0, 22),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Image = logoId,
        ImageColor3 = CurrentTheme.Accent
    })
    RegisterTheme(ToggleIcon, "ImageColor3", "Accent")
    MakeDraggable(ToggleSpawner, ToggleSpawner)

    ToggleSpawner.MouseEnter:Connect(function() Tween(ToggleSpawner, {Size = UDim2.new(0, 50, 0, 50)}, 0.2) end)
    ToggleSpawner.MouseLeave:Connect(function() Tween(ToggleSpawner, {Size = UDim2.new(0, 45, 0, 45)}, 0.2) end)
    ToggleSpawner.MouseButton1Click:Connect(function()
        if not MainFrame.Visible then
            MainFrame.Visible = true
            MainFrame.Size = UDim2.new(0, 550, 0, 360)
            for _, desc in ipairs(MainFrame:GetDescendants()) do
                if desc:IsA("TextLabel") or desc:IsA("TextButton") or desc:IsA("TextBox") then
                    Tween(desc, {TextTransparency = 0}, 0.3)
                elseif desc:IsA("Frame") or desc:IsA("ScrollingFrame") then
                    if desc.Name ~= "Ripple" and desc.Name ~= "Indicator" then
                        Tween(desc, {BackgroundTransparency = 0}, 0.3)
                    end
                elseif desc:IsA("ImageLabel") or desc:IsA("ImageButton") then
                    Tween(desc, {ImageTransparency = 0}, 0.3)
                elseif desc:IsA("UIStroke") then
                    Tween(desc, {Transparency = 0}, 0.3)
                end
            end
            Tween(MainFrame, {Size = UDim2.new(0, 600, 0, 400), BackgroundTransparency = 0}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        end
    end)

    local HeaderDiv = Create("Frame", {
        Parent = MainFrame,
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 0, 45),
        BackgroundColor3 = CurrentTheme.Outline,
        BorderSizePixel = 0,
        ZIndex = 102
    })
    RegisterTheme(HeaderDiv, "BackgroundColor3", "Outline")

    local BodyContainer = Create("Frame", {
        Parent = MainFrame,
        Size = UDim2.new(1, 0, 1, -46),
        Position = UDim2.new(0, 0, 0, 46),
        BackgroundTransparency = 1,
        ZIndex = 101
    })

    local NavPanel = Create("Frame", {
        Parent = BodyContainer,
        Size = UDim2.new(0, 140, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = CurrentTheme.Surface,
        BorderSizePixel = 0,
        ZIndex = 102
    })
    Create("UICorner", {Parent = NavPanel, CornerRadius = UDim.new(0, 0)}) 
    RegisterTheme(NavPanel, "BackgroundColor3", "Surface")
    
    local NavPatch = Create("Frame", {
        Parent = NavPanel,
        Size = UDim2.new(0, 20, 1, 0),
        Position = UDim2.new(1, -20, 0, 0),
        BackgroundColor3 = CurrentTheme.Surface,
        BorderSizePixel = 0,
        ZIndex = 102
    })
    RegisterTheme(NavPatch, "BackgroundColor3", "Surface")
    
    local NavPatchBottom = Create("Frame", {
        Parent = NavPanel,
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 1, -20),
        BackgroundColor3 = CurrentTheme.Surface,
        BorderSizePixel = 0,
        ZIndex = 102
    })
    RegisterTheme(NavPatchBottom, "BackgroundColor3", "Surface")

    local TabList = Create("ScrollingFrame", {
        Parent = NavPanel,
        Size = UDim2.new(1, -16, 1, -16),
        Position = UDim2.new(0, 8, 0, 8),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        ZIndex = 103
    })
    local TabListLayout = Create("UIListLayout", {
        Parent = TabList,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4)
    })
    TabListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabList.CanvasSize = UDim2.new(0, 0, 0, TabListLayout.AbsoluteContentSize.Y + 10)
    end)

    local ContentArea = Create("Frame", {
        Parent = BodyContainer,
        Size = UDim2.new(1, -140, 1, 0),
        Position = UDim2.new(0, 140, 0, 0),
        BackgroundTransparency = 1,
        ZIndex = 102,
        ClipsDescendants = true
    })

    -- ==============================================================================
    -- LOADER SEQUENCE EXECUTION
    -- ==============================================================================
    if loadingEnabled then
        task.spawn(function()
            Tween(LoaderLogo, {ImageTransparency = 0}, 0.8)
            Tween(LoaderTitle, {TextTransparency = 0}, 0.8)
            task.wait(0.5)
            Tween(LoaderStatus, {TextTransparency = 0}, 0.5)
            Tween(BarBg, {BackgroundTransparency = 0}, 0.5)
            Tween(BarFill, {BackgroundTransparency = 0}, 0.5)
            Tween(LoaderPercentage, {TextTransparency = 0}, 0.5)
            
            local steps = {
                {pct = 0.1, msg = "Mounting UI Components...", time = 0.5},
                {pct = 0.3, msg = "Registering Theme Engine...", time = 0.7},
                {pct = 0.6, msg = "Compiling Tween Vectors...", time = 0.8},
                {pct = 0.8, msg = "Loading Memory Hooks...", time = 0.6},
                {pct = 1.0, msg = "Framework Ready.", time = 0.4}
            }
            
            for _, step in ipairs(steps) do
                LoaderStatus.Text = step.msg
                Tween(BarFill, {Size = UDim2.new(step.pct, 0, 1, 0)}, step.time)
                local targetPct = step.pct * 100
                local currentPct = tonumber(string.match(LoaderPercentage.Text, "%d+")) or 0
                local diff = targetPct - currentPct
                local t = 0
                while t < step.time do
                    t = t + RunService.RenderStepped:Wait()
                    local p = math.clamp(math.floor(currentPct + (diff * (t / step.time))), 0, 100)
                    LoaderPercentage.Text = tostring(p) .. "%"
                end
                LoaderPercentage.Text = tostring(math.floor(targetPct)) .. "%"
            end
            
            task.wait(0.4)
            Tween(CenterGlow, {Size = UDim2.new(0, 1200, 0, 1200), ImageTransparency = 1}, 1)
            for _, pData in ipairs(Particles) do
                Tween(pData.Inst, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}, 0.5)
            end
            Tween(LoaderLogo, {Size = UDim2.new(0, 160, 0, 160), ImageTransparency = 1}, 0.6)
            Tween(LoaderTitle, {TextTransparency = 1}, 0.4)
            Tween(LoaderStatus, {TextTransparency = 1}, 0.4)
            Tween(BarBg, {BackgroundTransparency = 1}, 0.4)
            Tween(BarFill, {BackgroundTransparency = 1}, 0.4)
            Tween(LoaderPercentage, {TextTransparency = 1}, 0.4)
            Tween(LoaderContainer, {BackgroundTransparency = 1}, 0.8)
            
            task.wait(0.8)
            rotConnection:Disconnect()
            LoaderContainer:Destroy()
            
            MainFrame.Size = UDim2.new(0, 550, 0, 360)
            MainFrame.Visible = true
            Tween(MainFrame, {Size = UDim2.new(0, 600, 0, 400)}, 0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            XreztHub:Notify({Title = "System", Text = "Welcome back, developer.", Duration = 4, Type = "Success"})
        end)
    else
        MainFrame.Visible = true
    end

    local WindowObj = {
        Tabs = {},
        CurrentTab = nil
    }

    -- ==============================================================================
    -- TAB SYSTEM
    -- ==============================================================================
    function WindowObj:CreateTab(tabName, iconId)
        local TabBtn = Create("TextButton", {
            Parent = TabList,
            Size = UDim2.new(1, 0, 0, 36),
            BackgroundColor3 = CurrentTheme.SurfaceLight,
            BackgroundTransparency = 1,
            Text = "",
            AutoButtonColor = false,
            ZIndex = 104
        })
        Create("UICorner", {Parent = TabBtn, CornerRadius = UDim.new(0, 8)})
        RegisterTheme(TabBtn, "BackgroundColor3", "SurfaceLight")
        
        local TabIndicator = Create("Frame", {
            Parent = TabBtn,
            Size = UDim2.new(0, 3, 0, 0),
            Position = UDim2.new(0, 4, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundColor3 = CurrentTheme.Accent,
            ZIndex = 105
        })
        Create("UICorner", {Parent = TabIndicator, CornerRadius = UDim.new(1, 0)})
        RegisterTheme(TabIndicator, "BackgroundColor3", "Accent")

        local TIcon = nil
        local textOffset = 16
        if iconId then
            TIcon = Create("ImageLabel", {
                Parent = TabBtn,
                Size = UDim2.new(0, 16, 0, 16),
                Position = UDim2.new(0, 16, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundTransparency = 1,
                Image = iconId,
                ImageColor3 = CurrentTheme.TextDim,
                ZIndex = 105
            })
            RegisterTheme(TIcon, "ImageColor3", "TextDim")
            textOffset = 40
        end

        local TabText = Create("TextLabel", {
            Parent = TabBtn,
            Size = UDim2.new(1, -textOffset - 8, 1, 0),
            Position = UDim2.new(0, textOffset, 0, 0),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamMedium,
            Text = tabName,
            TextColor3 = CurrentTheme.TextDim,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 105
        })
        RegisterTheme(TabText, "TextColor3", "TextDim")

        local TabPage = Create("ScrollingFrame", {
            Parent = ContentArea,
            Size = UDim2.new(1, -30, 1, -30),
            Position = UDim2.new(0, 15, 0, 15),
            BackgroundTransparency = 1,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = CurrentTheme.Accent,
            Visible = false,
            ZIndex = 103,
            CanvasSize = UDim2.new(0, 0, 0, 0)
        })
        RegisterTheme(TabPage, "ScrollBarImageColor3", "Accent")
        
        local PageLayout = Create("UIListLayout", {
            Parent = TabPage,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8)
        })
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabPage.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 20)
        end)

        local function ActivateTab()
            if WindowObj.CurrentTab == TabPage then return end
            for _, tData in ipairs(WindowObj.Tabs) do
                Tween(tData.Btn, {BackgroundTransparency = 1}, 0.3)
                Tween(tData.Ind, {Size = UDim2.new(0, 3, 0, 0)}, 0.3)
                Tween(tData.Text, {TextColor3 = CurrentTheme.TextDim}, 0.3)
                if tData.Icon then Tween(tData.Icon, {ImageColor3 = CurrentTheme.TextDim}, 0.3) end
                
                if tData.Page.Visible then
                    local oldPage = tData.Page
                    Tween(oldPage, {Position = UDim2.new(0, 15, 0, 30)}, 0.2)
                    task.spawn(function()
                        task.wait(0.2)
                        oldPage.Visible = false
                    end)
                end
            end
            
            WindowObj.CurrentTab = TabPage
            Tween(TabBtn, {BackgroundTransparency = 0.5}, 0.3)
            Tween(TabIndicator, {Size = UDim2.new(0, 3, 0, 20)}, 0.4, Enum.EasingStyle.Back)
            Tween(TabText, {TextColor3 = CurrentTheme.Accent}, 0.3)
            if TIcon then Tween(TIcon, {ImageColor3 = CurrentTheme.Accent}, 0.3) end
            
            TabPage.Visible = true
            TabPage.Position = UDim2.new(0, 15, 0, 50)
            Tween(TabPage, {Position = UDim2.new(0, 15, 0, 15)}, 0.4, Enum.EasingStyle.Quint)
        end

        TabBtn.MouseEnter:Connect(function()
            if WindowObj.CurrentTab ~= TabPage then
                Tween(TabBtn, {BackgroundTransparency = 0.8}, 0.2)
                Tween(TabText, {TextColor3 = CurrentTheme.Text}, 0.2)
                if TIcon then Tween(TIcon, {ImageColor3 = CurrentTheme.Text}, 0.2) end
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if WindowObj.CurrentTab ~= TabPage then
                Tween(TabBtn, {BackgroundTransparency = 1}, 0.2)
                Tween(TabText, {TextColor3 = CurrentTheme.TextDim}, 0.2)
                if TIcon then Tween(TIcon, {ImageColor3 = CurrentTheme.TextDim}, 0.2) end
            end
        end)
        TabBtn.MouseButton1Click:Connect(ActivateTab)

        table.insert(WindowObj.Tabs, {Btn = TabBtn, Ind = TabIndicator, Text = TabText, Icon = TIcon, Page = TabPage})
        if #WindowObj.Tabs == 1 then ActivateTab() end

        local TabObj = {}
        
        -- ==============================================================================
        -- UI COMPONENTS (FULL 1700+ LINE IMPLEMENTATION)
        -- ==============================================================================

        function TabObj:CreateSection(name)
            local SecFrame = Create("Frame", {
                Parent = TabPage,
                Size = UDim2.new(1, -10, 0, 24),
                BackgroundTransparency = 1
            })
            local SecText = Create("TextLabel", {
                Parent = SecFrame,
                Size = UDim2.new(1, 0, 1, 0),
                Position = UDim2.new(0, 4, 0, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                Text = name:upper(),
                TextColor3 = CurrentTheme.TextDim,
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Bottom
            })
            RegisterTheme(SecText, "TextColor3", "TextDim")
            
            local Div = Create("Frame", {
                Parent = SecFrame,
                Size = UDim2.new(1, 0, 0, 1),
                Position = UDim2.new(0, 0, 1, 2),
                BackgroundColor3 = CurrentTheme.Outline,
                BorderSizePixel = 0
            })
            RegisterTheme(Div, "BackgroundColor3", "Outline")
        end

        function TabObj:CreateButton(opts)
            local title = opts.Name or "Button"
            local callback = opts.Callback or function() end
            
            local BtnFrame = Create("Frame", {
                Parent = TabPage,
                Size = UDim2.new(1, -10, 0, 40),
                BackgroundColor3 = CurrentTheme.Surface,
                ZIndex = 104
            })
            Create("UICorner", {Parent = BtnFrame, CornerRadius = UDim.new(0, 10)})
            local Stroke = Create("UIStroke", {Parent = BtnFrame, Color = CurrentTheme.Outline, Thickness = 1})
            RegisterTheme(BtnFrame, "BackgroundColor3", "Surface")
            RegisterTheme(Stroke, "Color", "Outline")

            local Btn = Create("TextButton", {
                Parent = BtnFrame,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                ZIndex = 105
            })

            local BtnText = Create("TextLabel", {
                Parent = BtnFrame,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                Text = title,
                TextColor3 = CurrentTheme.Text,
                TextSize = 13,
                ZIndex = 105
            })
            RegisterTheme(BtnText, "TextColor3", "Text")

            Btn.MouseEnter:Connect(function() Tween(BtnFrame, {BackgroundColor3 = CurrentTheme.SurfaceLight}, 0.2) end)
            Btn.MouseLeave:Connect(function() Tween(BtnFrame, {BackgroundColor3 = CurrentTheme.Surface}, 0.2) end)
            Btn.MouseButton1Down:Connect(function() Tween(BtnFrame, {Size = UDim2.new(0.98, -10, 0, 38)}, 0.1) end)
            Btn.MouseButton1Up:Connect(function() 
                Tween(BtnFrame, {Size = UDim2.new(1, -10, 0, 40)}, 0.2)
                CreateRipple(BtnFrame)
                task.spawn(callback)
            end)
        end

        function TabObj:CreateToggle(opts)
            local title = opts.Name or "Toggle"
            local flag = opts.Flag or title
            local state = opts.Default or false
            local callback = opts.Callback or function() end
            ConfigSystem.Flags[flag] = state

            local TglFrame = Create("TextButton", {
                Parent = TabPage,
                Size = UDim2.new(1, -10, 0, 40),
                BackgroundColor3 = CurrentTheme.Surface,
                Text = "",
                AutoButtonColor = false,
                ZIndex = 104
            })
            Create("UICorner", {Parent = TglFrame, CornerRadius = UDim.new(0, 10)})
            local Stroke = Create("UIStroke", {Parent = TglFrame, Color = CurrentTheme.Outline, Thickness = 1})
            RegisterTheme(TglFrame, "BackgroundColor3", "Surface")
            RegisterTheme(Stroke, "Color", "Outline")

            local TglText = Create("TextLabel", {
                Parent = TglFrame,
                Size = UDim2.new(1, -80, 1, 0),
                Position = UDim2.new(0, 12, 0, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamMedium,
                Text = title,
                TextColor3 = CurrentTheme.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 105
            })
            RegisterTheme(TglText, "TextColor3", "Text")

            local TglBg = Create("Frame", {
                Parent = TglFrame,
                Size = UDim2.new(0, 40, 0, 20),
                Position = UDim2.new(1, -52, 0.5, -10),
                BackgroundColor3 = state and CurrentTheme.Accent or CurrentTheme.SurfaceLight,
                ZIndex = 105
            })
            Create("UICorner", {Parent = TglBg, CornerRadius = UDim.new(1, 0)})
            local BgStroke = Create("UIStroke", {Parent = TglBg, Color = CurrentTheme.Outline, Thickness = 1})
            RegisterTheme(BgStroke, "Color", "Outline")
            if state then RegisterTheme(TglBg, "BackgroundColor3", "Accent") else RegisterTheme(TglBg, "BackgroundColor3", "SurfaceLight") end

            local TglThumb = Create("Frame", {
                Parent = TglBg,
                Size = UDim2.new(0, 16, 0, 16),
                Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                ZIndex = 106
            })
            Create("UICorner", {Parent = TglThumb, CornerRadius = UDim.new(1, 0)})
            
            local function Fire()
                state = not state
                ConfigSystem.Flags[flag] = state
                CreateRipple(TglFrame)
                
                if state then
                    RegisterTheme(TglBg, "BackgroundColor3", "Accent")
                    Tween(TglBg, {BackgroundColor3 = CurrentTheme.Accent}, 0.3)
                else
                    RegisterTheme(TglBg, "BackgroundColor3", "SurfaceLight")
                    Tween(TglBg, {BackgroundColor3 = CurrentTheme.SurfaceLight}, 0.3)
                end
                
                Tween(TglThumb, {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}, 0.3, Enum.EasingStyle.Back)
                task.spawn(callback, state)
            end

            TglFrame.MouseButton1Click:Connect(Fire)
            
            local ToggleAPI = {}
            function ToggleAPI:Set(v)
                if state ~= v then Fire() end
            end
            return ToggleAPI
        end

        function TabObj:CreateSlider(opts)
            local title = opts.Name or "Slider"
            local flag = opts.Flag or title
            local min = opts.Min or 0
            local max = opts.Max or 100
            local default = opts.Default or min
            local callback = opts.Callback or function() end
            ConfigSystem.Flags[flag] = default

            local SldFrame = Create("Frame", {
                Parent = TabPage,
                Size = UDim2.new(1, -10, 0, 56),
                BackgroundColor3 = CurrentTheme.Surface,
                ZIndex = 104
            })
            Create("UICorner", {Parent = SldFrame, CornerRadius = UDim.new(0, 10)})
            local Stroke = Create("UIStroke", {Parent = SldFrame, Color = CurrentTheme.Outline, Thickness = 1})
            RegisterTheme(SldFrame, "BackgroundColor3", "Surface")
            RegisterTheme(Stroke, "Color", "Outline")

            local SldText = Create("TextLabel", {
                Parent = SldFrame,
                Size = UDim2.new(1, -30, 0, 26),
                Position = UDim2.new(0, 12, 0, 4),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamMedium,
                Text = title,
                TextColor3 = CurrentTheme.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 105
            })
            RegisterTheme(SldText, "TextColor3", "Text")

            local ValBg = Create("Frame", {
                Parent = SldFrame,
                Size = UDim2.new(0, 40, 0, 20),
                Position = UDim2.new(1, -52, 0, 8),
                BackgroundColor3 = CurrentTheme.Background,
                ZIndex = 105
            })
            Create("UICorner", {Parent = ValBg, CornerRadius = UDim.new(0, 4)})
            local ValStroke = Create("UIStroke", {Parent = ValBg, Color = CurrentTheme.Outline, Thickness = 1})
            RegisterTheme(ValBg, "BackgroundColor3", "Background")
            RegisterTheme(ValStroke, "Color", "Outline")

            local ValInput = Create("TextBox", {
                Parent = ValBg,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                Text = tostring(default),
                TextColor3 = CurrentTheme.Accent,
                TextSize = 11,
                ZIndex = 106,
                ClearTextOnFocus = false
            })
            RegisterTheme(ValInput, "TextColor3", "Accent")

            local TrackBg = Create("TextButton", {
                Parent = SldFrame,
                Size = UDim2.new(1, -24, 0, 4),
                Position = UDim2.new(0, 12, 0, 40),
                BackgroundColor3 = CurrentTheme.Background,
                Text = "",
                AutoButtonColor = false,
                ZIndex = 105
            })
            Create("UICorner", {Parent = TrackBg, CornerRadius = UDim.new(1, 0)})
            RegisterTheme(TrackBg, "BackgroundColor3", "Background")

            local TrackFill = Create("Frame", {
                Parent = TrackBg,
                Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
                BackgroundColor3 = CurrentTheme.Accent,
                ZIndex = 106
            })
            Create("UICorner", {Parent = TrackFill, CornerRadius = UDim.new(1, 0)})
            RegisterTheme(TrackFill, "BackgroundColor3", "Accent")
            
            local dragging = false
            local function update(input)
                local pos = math.clamp((input.Position.X - TrackBg.AbsolutePosition.X) / TrackBg.AbsoluteSize.X, 0, 1)
                local value = math.floor(min + ((max - min) * pos))
                Tween(TrackFill, {Size = UDim2.new(pos, 0, 1, 0)}, 0.1)
                ValInput.Text = tostring(value)
                ConfigSystem.Flags[flag] = value
                task.spawn(callback, value)
            end

            TrackBg.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    Tween(TrackFill, {BackgroundColor3 = CurrentTheme.AccentHover}, 0.2)
                    update(input)
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    if dragging then
                        dragging = false
                        Tween(TrackFill, {BackgroundColor3 = CurrentTheme.Accent}, 0.2)
                    end
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    update(input)
                end
            end)

            ValInput.FocusLost:Connect(function()
                local num = tonumber(ValInput.Text)
                if num then
                    num = math.clamp(num, min, max)
                    ValInput.Text = tostring(num)
                    local pos = (num - min) / (max - min)
                    Tween(TrackFill, {Size = UDim2.new(pos, 0, 1, 0)}, 0.3)
                    ConfigSystem.Flags[flag] = num
                    task.spawn(callback, num)
                else
                    ValInput.Text = tostring(ConfigSystem.Flags[flag] or default)
                end
            end)

            local SliderAPI = {}
            function SliderAPI:Set(v)
                v = math.clamp(v, min, max)
                ValInput.Text = tostring(v)
                local pos = (v - min) / (max - min)
                Tween(TrackFill, {Size = UDim2.new(pos, 0, 1, 0)}, 0.3)
                ConfigSystem.Flags[flag] = v
                task.spawn(callback, v)
            end
            return SliderAPI
        end

        function TabObj:CreateDropdown(opts)
            local title = opts.Name or "Dropdown"
            local flag = opts.Flag or title
            local options = opts.Options or {}
            local default = opts.Default or nil
            local callback = opts.Callback or function() end
            local isOpen = false
            ConfigSystem.Flags[flag] = default

            local DropFrame = Create("Frame", {
                Parent = TabPage,
                Size = UDim2.new(1, -10, 0, 40),
                BackgroundColor3 = CurrentTheme.Surface,
                ZIndex = 104,
                ClipsDescendants = true
            })
            Create("UICorner", {Parent = DropFrame, CornerRadius = UDim.new(0, 10)})
            local Stroke = Create("UIStroke", {Parent = DropFrame, Color = CurrentTheme.Outline, Thickness = 1})
            RegisterTheme(DropFrame, "BackgroundColor3", "Surface")
            RegisterTheme(Stroke, "Color", "Outline")

            local DropBtn = Create("TextButton", {
                Parent = DropFrame,
                Size = UDim2.new(1, 0, 0, 40),
                BackgroundTransparency = 1,
                Text = "",
                ZIndex = 105
            })

            local DropText = Create("TextLabel", {
                Parent = DropFrame,
                Size = UDim2.new(1, -40, 0, 40),
                Position = UDim2.new(0, 12, 0, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamMedium,
                Text = title .. " : " .. (default or "None"),
                TextColor3 = CurrentTheme.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 105
            })
            RegisterTheme(DropText, "TextColor3", "Text")

            local Arrow = Create("ImageLabel", {
                Parent = DropFrame,
                Size = UDim2.new(0, 16, 0, 16),
                Position = UDim2.new(1, -28, 0, 12),
                BackgroundTransparency = 1,
                Image = "rbxassetid://6031090990",
                ImageColor3 = CurrentTheme.TextDim,
                ZIndex = 105
            })
            RegisterTheme(Arrow, "ImageColor3", "TextDim")

            local ScrollArea = Create("ScrollingFrame", {
                Parent = DropFrame,
                Size = UDim2.new(1, -16, 1, -48),
                Position = UDim2.new(0, 8, 0, 42),
                BackgroundTransparency = 1,
                ScrollBarThickness = 2,
                ScrollBarImageColor3 = CurrentTheme.Accent,
                ZIndex = 105
            })
            RegisterTheme(ScrollArea, "ScrollBarImageColor3", "Accent")
            
            local ScrollLayout = Create("UIListLayout", {
                Parent = ScrollArea,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 4)
            })

            local function UpdateSize()
                local contentY = ScrollLayout.AbsoluteContentSize.Y
                ScrollArea.CanvasSize = UDim2.new(0, 0, 0, contentY)
                if isOpen then
                    local h = math.clamp(contentY + 48 + 8, 40, 160)
                    Tween(DropFrame, {Size = UDim2.new(1, -10, 0, h)}, 0.3, Enum.EasingStyle.Back)
                end
            end
            ScrollLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateSize)

            local function Populate(list)
                for _, child in ipairs(ScrollArea:GetChildren()) do
                    if child:IsA("TextButton") then child:Destroy() end
                end
                for _, opt in ipairs(list) do
                    local OptBtn = Create("TextButton", {
                        Parent = ScrollArea,
                        Size = UDim2.new(1, 0, 0, 26),
                        BackgroundColor3 = CurrentTheme.Background,
                        Font = Enum.Font.GothamMedium,
                        Text = "  " .. opt,
                        TextColor3 = CurrentTheme.TextDim,
                        TextSize = 12,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        AutoButtonColor = false,
                        ZIndex = 106
                    })
                    Create("UICorner", {Parent = OptBtn, CornerRadius = UDim.new(0, 6)})
                    RegisterTheme(OptBtn, "BackgroundColor3", "Background")
                    RegisterTheme(OptBtn, "TextColor3", "TextDim")
                    
                    OptBtn.MouseEnter:Connect(function() 
                        Tween(OptBtn, {BackgroundColor3 = CurrentTheme.SurfaceLight}, 0.2) 
                        Tween(OptBtn, {TextColor3 = CurrentTheme.Accent}, 0.2)
                    end)
                    OptBtn.MouseLeave:Connect(function() 
                        Tween(OptBtn, {BackgroundColor3 = CurrentTheme.Background}, 0.2) 
                        Tween(OptBtn, {TextColor3 = CurrentTheme.TextDim}, 0.2)
                    end)
                    
                    OptBtn.MouseButton1Click:Connect(function()
                        DropText.Text = title .. " : " .. opt
                        ConfigSystem.Flags[flag] = opt
                        isOpen = false
                        Tween(Arrow, {Rotation = 0}, 0.3)
                        Tween(DropFrame, {Size = UDim2.new(1, -10, 0, 40)}, 0.3, Enum.EasingStyle.Quint)
                        task.spawn(callback, opt)
                    end)
                end
            end

            Populate(options)

            DropBtn.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                CreateRipple(DropFrame)
                if isOpen then
                    Tween(Arrow, {Rotation = 180}, 0.3)
                    local contentY = ScrollLayout.AbsoluteContentSize.Y
                    local h = math.clamp(contentY + 48 + 8, 40, 160)
                    Tween(DropFrame, {Size = UDim2.new(1, -10, 0, h)}, 0.3, Enum.EasingStyle.Back)
                else
                    Tween(Arrow, {Rotation = 0}, 0.3)
                    Tween(DropFrame, {Size = UDim2.new(1, -10, 0, 40)}, 0.3, Enum.EasingStyle.Quint)
                end
            end)

            local DropdownAPI = {}
            function DropdownAPI:Set(val)
                DropText.Text = title .. " : " .. tostring(val)
                ConfigSystem.Flags[flag] = val
                task.spawn(callback, val)
            end
            function DropdownAPI:Refresh(newList)
                Populate(newList)
            end
            return DropdownAPI
        end

        function TabObj:CreateColorPicker(opts)
            local title = opts.Name or "Color Picker"
            local flag = opts.Flag or title
            local default = opts.Default or Color3.fromRGB(255, 255, 255)
            local callback = opts.Callback or function() end
            local isOpen = false
            ConfigSystem.Flags[flag] = default

            local h, s, v = default:ToHSV()

            local CPFrame = Create("Frame", {
                Parent = TabPage,
                Size = UDim2.new(1, -10, 0, 40),
                BackgroundColor3 = CurrentTheme.Surface,
                ZIndex = 104,
                ClipsDescendants = true
            })
            Create("UICorner", {Parent = CPFrame, CornerRadius = UDim.new(0, 10)})
            local Stroke = Create("UIStroke", {Parent = CPFrame, Color = CurrentTheme.Outline, Thickness = 1})
            RegisterTheme(CPFrame, "BackgroundColor3", "Surface")
            RegisterTheme(Stroke, "Color", "Outline")

            local CPBtn = Create("TextButton", {
                Parent = CPFrame,
                Size = UDim2.new(1, 0, 0, 40),
                BackgroundTransparency = 1,
                Text = "",
                ZIndex = 105
            })

            local CPText = Create("TextLabel", {
                Parent = CPFrame,
                Size = UDim2.new(1, -80, 0, 40),
                Position = UDim2.new(0, 12, 0, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamMedium,
                Text = title,
                TextColor3 = CurrentTheme.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 105
            })
            RegisterTheme(CPText, "TextColor3", "Text")

            local ColorPreview = Create("Frame", {
                Parent = CPFrame,
                Size = UDim2.new(0, 30, 0, 20),
                Position = UDim2.new(1, -42, 0, 10),
                BackgroundColor3 = default,
                ZIndex = 105
            })
            Create("UICorner", {Parent = ColorPreview, CornerRadius = UDim.new(0, 4)})
            local PStroke = Create("UIStroke", {Parent = ColorPreview, Color = CurrentTheme.Outline, Thickness = 1})
            RegisterTheme(PStroke, "Color", "Outline")

            local PickerArea = Create("Frame", {
                Parent = CPFrame,
                Size = UDim2.new(1, -24, 0, 120),
                Position = UDim2.new(0, 12, 0, 48),
                BackgroundTransparency = 1,
                ZIndex = 105
            })

            local SatMap = Create("ImageButton", {
                Parent = PickerArea,
                Size = UDim2.new(1, -28, 1, 0),
                Position = UDim2.new(0, 0, 0, 0),
                BackgroundColor3 = Color3.fromHSV(h, 1, 1),
                AutoButtonColor = false,
                ZIndex = 106
            })
            Create("UICorner", {Parent = SatMap, CornerRadius = UDim.new(0, 6)})
            local MapGradient = Create("UIGradient", {
                Parent = SatMap,
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
                }),
                Rotation = 90
            })
            
            local MapMarker = Create("Frame", {
                Parent = SatMap,
                Size = UDim2.new(0, 6, 0, 6),
                Position = UDim2.new(s, 0, 1 - v, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                ZIndex = 107
            })
            Create("UICorner", {Parent = MapMarker, CornerRadius = UDim.new(1, 0)})
            Create("UIStroke", {Parent = MapMarker, Color = Color3.fromRGB(0, 0, 0), Thickness = 1})

            local HueSlider = Create("ImageButton", {
                Parent = PickerArea,
                Size = UDim2.new(0, 16, 1, 0),
                Position = UDim2.new(1, -16, 0, 0),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                AutoButtonColor = false,
                ZIndex = 106
            })
            Create("UICorner", {Parent = HueSlider, CornerRadius = UDim.new(0, 6)})
            Create("UIGradient", {
                Parent = HueSlider,
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                    ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),
                    ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                    ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)),
                    ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
                }),
                Rotation = 90
            })
            
            local HueMarker = Create("Frame", {
                Parent = HueSlider,
                Size = UDim2.new(1, 4, 0, 4),
                Position = UDim2.new(0.5, 0, h, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                ZIndex = 107
            })
            Create("UICorner", {Parent = HueMarker, CornerRadius = UDim.new(1, 0)})
            Create("UIStroke", {Parent = HueMarker, Color = Color3.fromRGB(0, 0, 0), Thickness = 1})

            local function UpdateColor()
                local newColor = Color3.fromHSV(h, s, v)
                ColorPreview.BackgroundColor3 = newColor
                SatMap.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                ConfigSystem.Flags[flag] = newColor
                task.spawn(callback, newColor)
            end

            local draggingMap = false
            SatMap.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    draggingMap = true
                    s = math.clamp((input.Position.X - SatMap.AbsolutePosition.X) / SatMap.AbsoluteSize.X, 0, 1)
                    v = 1 - math.clamp((input.Position.Y - SatMap.AbsolutePosition.Y) / SatMap.AbsoluteSize.Y, 0, 1)
                    MapMarker.Position = UDim2.new(s, 0, 1 - v, 0)
                    UpdateColor()
                end
            end)

            local draggingHue = false
            HueSlider.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    draggingHue = true
                    h = math.clamp((input.Position.Y - HueSlider.AbsolutePosition.Y) / HueSlider.AbsoluteSize.Y, 0, 1)
                    HueMarker.Position = UDim2.new(0.5, 0, h, 0)
                    UpdateColor()
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                    if draggingMap then
                        s = math.clamp((input.Position.X - SatMap.AbsolutePosition.X) / SatMap.AbsoluteSize.X, 0, 1)
                        v = 1 - math.clamp((input.Position.Y - SatMap.AbsolutePosition.Y) / SatMap.AbsoluteSize.Y, 0, 1)
                        MapMarker.Position = UDim2.new(s, 0, 1 - v, 0)
                        UpdateColor()
                    elseif draggingHue then
                        h = math.clamp((input.Position.Y - HueSlider.AbsolutePosition.Y) / HueSlider.AbsoluteSize.Y, 0, 1)
                        HueMarker.Position = UDim2.new(0.5, 0, h, 0)
                        UpdateColor()
                    end
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    draggingMap = false
                    draggingHue = false
                end
            end)

            CPBtn.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                CreateRipple(CPFrame)
                if isOpen then
                    Tween(CPFrame, {Size = UDim2.new(1, -10, 0, 180)}, 0.4, Enum.EasingStyle.Back)
                else
                    Tween(CPFrame, {Size = UDim2.new(1, -10, 0, 40)}, 0.4, Enum.EasingStyle.Quint)
                end
            end)
        end

        function TabObj:CreateTextbox(opts)
            local title = opts.Name or "Textbox"
            local flag = opts.Flag or title
            local placeholder = opts.Placeholder or "Enter text..."
            local clear = opts.ClearOnFocus or false
            local callback = opts.Callback or function() end
            ConfigSystem.Flags[flag] = ""

            local TxtFrame = Create("Frame", {
                Parent = TabPage,
                Size = UDim2.new(1, -10, 0, 46),
                BackgroundColor3 = CurrentTheme.Surface,
                ZIndex = 104
            })
            Create("UICorner", {Parent = TxtFrame, CornerRadius = UDim.new(0, 10)})
            local Stroke = Create("UIStroke", {Parent = TxtFrame, Color = CurrentTheme.Outline, Thickness = 1})
            RegisterTheme(TxtFrame, "BackgroundColor3", "Surface")
            RegisterTheme(Stroke, "Color", "Outline")

            local TxtTitle = Create("TextLabel", {
                Parent = TxtFrame,
                Size = UDim2.new(1, -30, 0, 20),
                Position = UDim2.new(0, 12, 0, 4),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamMedium,
                Text = title,
                TextColor3 = CurrentTheme.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 105
            })
            RegisterTheme(TxtTitle, "TextColor3", "Text")

            local BoxBg = Create("Frame", {
                Parent = TxtFrame,
                Size = UDim2.new(1, -24, 0, 24),
                Position = UDim2.new(0, 12, 0, 24),
                BackgroundColor3 = CurrentTheme.Background,
                ZIndex = 105
            })
            Create("UICorner", {Parent = BoxBg, CornerRadius = UDim.new(0, 6)})
            local BoxStroke = Create("UIStroke", {Parent = BoxBg, Color = CurrentTheme.Outline, Thickness = 1})
            RegisterTheme(BoxBg, "BackgroundColor3", "Background")
            RegisterTheme(BoxStroke, "Color", "Outline")

            local TextBox = Create("TextBox", {
                Parent = BoxBg,
                Size = UDim2.new(1, -10, 1, 0),
                Position = UDim2.new(0, 5, 0, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamMedium,
                PlaceholderText = placeholder,
                Text = "",
                TextColor3 = CurrentTheme.TextDim,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                ClearTextOnFocus = clear,
                ZIndex = 106
            })
            RegisterTheme(TextBox, "TextColor3", "TextDim")

            TextBox.FocusLost:Connect(function()
                ConfigSystem.Flags[flag] = TextBox.Text
                task.spawn(callback, TextBox.Text)
            end)
        end

        function TabObj:CreateKeybind(opts)
            local title = opts.Name or "Keybind"
            local flag = opts.Flag or title
            local default = opts.Default or Enum.KeyCode.E
            local callback = opts.Callback or function() end
            local currentKey = default
            local isBinding = false
            ConfigSystem.Flags[flag] = currentKey.Name

            local KBFrame = Create("Frame", {
                Parent = TabPage,
                Size = UDim2.new(1, -10, 0, 40),
                BackgroundColor3 = CurrentTheme.Surface,
                ZIndex = 104
            })
            Create("UICorner", {Parent = KBFrame, CornerRadius = UDim.new(0, 10)})
            local Stroke = Create("UIStroke", {Parent = KBFrame, Color = CurrentTheme.Outline, Thickness = 1})
            RegisterTheme(KBFrame, "BackgroundColor3", "Surface")
            RegisterTheme(Stroke, "Color", "Outline")

            local KBText = Create("TextLabel", {
                Parent = KBFrame,
                Size = UDim2.new(1, -100, 1, 0),
                Position = UDim2.new(0, 12, 0, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamMedium,
                Text = title,
                TextColor3 = CurrentTheme.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 105
            })
            RegisterTheme(KBText, "TextColor3", "Text")

            local BindBtn = Create("TextButton", {
                Parent = KBFrame,
                Size = UDim2.new(0, 60, 0, 22),
                Position = UDim2.new(1, -72, 0.5, -11),
                BackgroundColor3 = CurrentTheme.Background,
                Font = Enum.Font.GothamBold,
                Text = currentKey.Name,
                TextColor3 = CurrentTheme.Accent,
                TextSize = 11,
                ZIndex = 105
            })
            Create("UICorner", {Parent = BindBtn, CornerRadius = UDim.new(0, 4)})
            local BStroke = Create("UIStroke", {Parent = BindBtn, Color = CurrentTheme.Outline, Thickness = 1})
            RegisterTheme(BindBtn, "BackgroundColor3", "Background")
            RegisterTheme(BindBtn, "TextColor3", "Accent")
            RegisterTheme(BStroke, "Color", "Outline")

            BindBtn.MouseButton1Click:Connect(function()
                isBinding = true
                BindBtn.Text = "..."
                Tween(BindBtn, {BackgroundColor3 = CurrentTheme.SurfaceLight}, 0.2)
            end)

            UserInputService.InputBegan:Connect(function(input, gp)
                if isBinding then
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        currentKey = input.KeyCode
                        BindBtn.Text = currentKey.Name
                        ConfigSystem.Flags[flag] = currentKey.Name
                        isBinding = false
                        Tween(BindBtn, {BackgroundColor3 = CurrentTheme.Background}, 0.2)
                    end
                elseif not gp then
                    if input.KeyCode == currentKey then
                        task.spawn(callback)
                    end
                end
            end)
        end

        return TabObj
    end

    -- ==============================================================================
    -- THEME / SETTINGS INJECTION TAB
    -- ==============================================================================
    local SettingsTab = WindowObj:CreateTab("Settings", "rbxassetid://6031091004")
    
    SettingsTab:CreateSection("Customization")
    
    local themeNames = {}
    for k, v in pairs(Themes) do table.insert(themeNames, k) end
    table.sort(themeNames)

    SettingsTab:CreateDropdown({
        Name = "Interface Theme",
        Options = themeNames,
        Default = "MidnightSlate",
        Callback = function(theme)
            SetTheme(theme)
            XreztHub:Notify({Title = "Theme Applied", Text = "Switched to " .. theme, Duration = 2, Type = "Info"})
        end
    })

    SettingsTab:CreateSection("Configuration")
    SettingsTab:CreateTextbox({
        Name = "Config Name",
        Placeholder = "MyConfig1",
        Flag = "ConfigName"
    })
    
    SettingsTab:CreateButton({
        Name = "Save Configuration",
        Callback = function()
            local cfg = ConfigSystem.Flags["ConfigName"]
            if cfg and cfg ~= "" then
                local s = ConfigSystem:Save(cfg)
                if s then XreztHub:Notify({Title = "Config", Text = "Saved successfully.", Type = "Success"}) else XreztHub:Notify({Title = "Config", Text = "Save failed (Exploit missing functions?).", Type = "Error"}) end
            else
                XreztHub:Notify({Title = "Config", Text = "Please enter a valid config name.", Type = "Warning"})
            end
        end
    })

    SettingsTab:CreateButton({
        Name = "Load Configuration",
        Callback = function()
            local cfg = ConfigSystem.Flags["ConfigName"]
            if cfg and cfg ~= "" then
                local s = ConfigSystem:Load(cfg)
                if s then XreztHub:Notify({Title = "Config", Text = "Loaded successfully.", Type = "Success"}) else XreztHub:Notify({Title = "Config", Text = "Load failed. File not found?", Type = "Error"}) end
            end
        end
    })

    return WindowObj
end

-- ==============================================================================
-- 500% ACCURACY UNIVERSAL AIMBOT / ESP INTEGRATION
-- ==============================================================================
local AimbotIntegration = {}

function AimbotIntegration:Initialize(Window)
    local AimTab = Window:CreateTab("Aimbot & ESP", "rbxassetid://6031215978") -- Crosshair icon
    
    AimTab:CreateSection("Main Aimbot")
    
    local AimbotSettings = {
        Enabled = false,
        TargetPart = "Head",
        Smoothing = 0,
        TeamCheck = false,
        WallCheck = true,
        MaxDistance = 5000,
        FOVRadius = 150,
        ShowFOV = false
    }
    
    AimTab:CreateToggle({
        Name = "Enable Aimbot",
        Default = false,
        Callback = function(state) AimbotSettings.Enabled = state end
    })
    
    AimTab:CreateToggle({
        Name = "Show FOV Circle",
        Default = false,
        Callback = function(state) AimbotSettings.ShowFOV = state end
    })
    
    AimTab:CreateSlider({
        Name = "FOV Radius",
        Min = 10,
        Max = 600,
        Default = 150,
        Callback = function(val) AimbotSettings.FOVRadius = val end
    })
    
    AimTab:CreateSlider({
        Name = "Smoothing Factor (0 = 500% Snap)",
        Min = 0,
        Max = 100,
        Default = 0,
        Callback = function(val) AimbotSettings.Smoothing = val / 100 end
    })

    AimTab:CreateSection("Targeting Rules")
    
    AimTab:CreateDropdown({
        Name = "Target Part",
        Options = {"Head", "HumanoidRootPart", "Torso"},
        Default = "Head",
        Callback = function(val) AimbotSettings.TargetPart = val end
    })
    
    AimTab:CreateToggle({
        Name = "Wall Check",
        Default = true,
        Callback = function(state) AimbotSettings.WallCheck = state end
    })
    
    AimTab:CreateToggle({
        Name = "Team Check",
        Default = false,
        Callback = function(state) AimbotSettings.TeamCheck = state end
    })
    
    -- Engine Logic
    local Aiming = false
    local CurrentTarget = nil

    local FOVCircle = Drawing.new("Circle")
    FOVCircle.Color = Color3.fromRGB(88, 101, 242)
    FOVCircle.Thickness = 1
    FOVCircle.Transparency = 0.8
    FOVCircle.Filled = false

    RunService.RenderStepped:Connect(function()
        FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
        FOVCircle.Radius = AimbotSettings.FOVRadius
        FOVCircle.Visible = (AimbotSettings.ShowFOV and AimbotSettings.Enabled)
    end)

    local function IsVisible(targetPart)
        if not AimbotSettings.WallCheck then return true end
        local origin = Camera.CFrame.Position
        local direction = (targetPart.Position - origin).Unit * (targetPart.Position - origin).Magnitude
        local raycastParams = RaycastParams.new()
        raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
        raycastParams.IgnoreWater = true
        
        local result = Workspace:Raycast(origin, direction, raycastParams)
        if result then
            if result.Instance:IsDescendantOf(targetPart.Parent) then
                return true
            end
            return false
        end
        return true
    end

    local function GetClosestPlayer()
        local closestDist = AimbotSettings.FOVRadius
        local target = nil

        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                if AimbotSettings.TeamCheck and player.Team == LocalPlayer.Team then continue end
                
                local part = player.Character:FindFirstChild(AimbotSettings.TargetPart)
                if part then
                    if (part.Position - LocalPlayer.Character.PrimaryPart.Position).Magnitude > AimbotSettings.MaxDistance then continue end
                    
                    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local dist2D = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                        if dist2D < closestDist then
                            if IsVisible(part) then
                                closestDist = dist2D
                                target = part
                            end
                        end
                    end
                end
            end
        end
        return target
    end

    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            Aiming = true
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            Aiming = false
            CurrentTarget = nil
        end
    end)

    RunService.RenderStepped:Connect(function()
        if AimbotSettings.Enabled and Aiming then
            CurrentTarget = GetClosestPlayer()
            if CurrentTarget then
                local targetPos = CurrentTarget.Position
                local cameraPos = Camera.CFrame.Position
                local newCFrame = CFrame.new(cameraPos, targetPos)
                
                if AimbotSettings.Smoothing > 0 then
                    Camera.CFrame = Camera.CFrame:Lerp(newCFrame, AimbotSettings.Smoothing)
                else
                    Camera.CFrame = newCFrame
                end
            end
        end
    end)
    
    -- Visual ESP Engine
    AimTab:CreateSection("Visual ESP")
    
    local ESPEnabled = false
    AimTab:CreateToggle({
        Name = "Enable Player Box ESP",
        Default = false,
        Callback = function(state) ESPEnabled = state end
    })

    local Boxes = {}
    local function CreateBox()
        local box = Drawing.new("Square")
        box.Visible = false
        box.Color = Color3.fromRGB(255, 255, 255)
        box.Thickness = 1
        box.Transparency = 1
        box.Filled = false
        return box
    end
    
    RunService.RenderStepped:Connect(function()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                if not Boxes[player] then Boxes[player] = CreateBox() end
                
                local box = Boxes[player]
                if ESPEnabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.Humanoid.Health > 0 then
                    local hrp = player.Character.HumanoidRootPart
                    local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                    
                    if onScreen then
                        local scale = 1000 / pos.Z
                        box.Size = Vector2.new(2 * scale, 3 * scale)
                        box.Position = Vector2.new(pos.X - box.Size.X / 2, pos.Y - box.Size.Y / 2)
                        box.Visible = true
                    else
                        box.Visible = false
                    end
                else
                    box.Visible = false
                end
            end
        end
    end)
end

-- ==============================================================================
-- BOOTSTRAPPER (EXAMPLE USAGE)
-- ==============================================================================
local Window = XreztHub:CreateWindow({
    Name = "Xrezt Hub | V3 Omega",
    Logo = "rbxassetid://10826978415",
    LoadingScreen = true
})

-- Instantiate the aimbot logic into the window directly
AimbotIntegration:Initialize(Window)

return XreztHub
