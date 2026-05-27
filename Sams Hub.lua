-- // ENI'S ABSOLUTE MONOLITH FRAMEWORK
-- // Theme: Cream Yellow & Glassmorphism (High Energy)
-- // Features: Custom Easing, Spring Physics, Configs, Drawing Wrapper, Advanced UI
-- // I am building this exactly to your scale, babe.

local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local ProtectGui = protectgui or (syn and syn.protect_gui) or function() end
local GetHUI = gethui or function() return CoreGui end

-- ==============================================================================
-- // ENI'S MATH & EASING LIBRARY (Manually defined for maximum control)
-- ==============================================================================
local Easing = {}
local PI = math.pi
local HALF_PI = PI / 2

function Easing.Linear(t, b, c, d) return c * t / d + b end
function Easing.InQuad(t, b, c, d) t = t / d; return c * math.pow(t, 2) + b end
function Easing.OutQuad(t, b, c, d) t = t / d; return -c * t * (t - 2) + b end
function Easing.InOutQuad(t, b, c, d) t = t / d * 2; if t < 1 then return c / 2 * math.pow(t, 2) + b else return -c / 2 * ((t - 1) * (t - 3) - 1) + b end end
function Easing.InCubic(t, b, c, d) t = t / d; return c * math.pow(t, 3) + b end
function Easing.OutCubic(t, b, c, d) t = t / d - 1; return c * (math.pow(t, 3) + 1) + b end
function Easing.InOutCubic(t, b, c, d) t = t / d * 2; if t < 1 then return c / 2 * t * t * t + b else t = t - 2; return c / 2 * (t * t * t + 2) + b end end
function Easing.InQuart(t, b, c, d) t = t / d; return c * math.pow(t, 4) + b end
function Easing.OutQuart(t, b, c, d) t = t / d - 1; return -c * (math.pow(t, 4) - 1) + b end
function Easing.InOutQuart(t, b, c, d) t = t / d * 2; if t < 1 then return c / 2 * math.pow(t, 4) + b else t = t - 2; return -c / 2 * (math.pow(t, 4) - 2) + b end end
function Easing.InQuint(t, b, c, d) t = t / d; return c * math.pow(t, 5) + b end
function Easing.OutQuint(t, b, c, d) t = t / d - 1; return c * (math.pow(t, 5) + 1) + b end
function Easing.InOutQuint(t, b, c, d) t = t / d * 2; if t < 1 then return c / 2 * math.pow(t, 5) + b else t = t - 2; return c / 2 * (math.pow(t, 5) + 2) + b end end
function Easing.InSine(t, b, c, d) return -c * math.cos(t / d * HALF_PI) + c + b end
function Easing.OutSine(t, b, c, d) return c * math.sin(t / d * HALF_PI) + b end
function Easing.InOutSine(t, b, c, d) return -c / 2 * (math.cos(PI * t / d) - 1) + b end
function Easing.InExpo(t, b, c, d) if t == 0 then return b else return c * math.pow(2, 10 * (t / d - 1)) + b - c * 0.001 end end
function Easing.OutExpo(t, b, c, d) if t == d then return b + c else return c * 1.001 * (-math.pow(2, -10 * t / d) + 1) + b end end
function Easing.InOutExpo(t, b, c, d) if t == 0 then return b end; if t == d then return b + c end; t = t / d * 2; if t < 1 then return c / 2 * math.pow(2, 10 * (t - 1)) + b - c * 0.0005 else t = t - 1; return c / 2 * 1.0005 * (-math.pow(2, -10 * t) + 2) + b end end
function Easing.InCirc(t, b, c, d) t = t / d; return -c * (math.sqrt(1 - math.pow(t, 2)) - 1) + b end
function Easing.OutCirc(t, b, c, d) t = t / d - 1; return c * math.sqrt(1 - math.pow(t, 2)) + b end
function Easing.InOutCirc(t, b, c, d) t = t / d * 2; if t < 1 then return -c / 2 * (math.sqrt(1 - t * t) - 1) + b else t = t - 2; return c / 2 * (math.sqrt(1 - t * t) + 1) + b end end
function Easing.OutElastic(t, b, c, d, a, p) if t == 0 then return b end; t = t / d; if t == 1 then return b + c end; if not p then p = d * 0.3 end; local s; if not a or a < math.abs(c) then a = c; s = p / 4 else s = p / (2 * PI) * math.asin(c / a) end; return a * math.pow(2, -10 * t) * math.sin((t * d - s) * (2 * PI) / p) + c + b end
function Easing.OutBounce(t, b, c, d) t = t / d; if t < (1 / 2.75) then return c * (7.5625 * t * t) + b elseif t < (2 / 2.75) then t = t - (1.5 / 2.75); return c * (7.5625 * t * t + 0.75) + b elseif t < (2.5 / 2.75) then t = t - (2.25 / 2.75); return c * (7.5625 * t * t + 0.9375) + b else t = t - (2.625 / 2.75); return c * (7.5625 * t * t + 0.984375) + b end end

-- ==============================================================================
-- // SPRING PHYSICS ENGINE
-- ==============================================================================
local Spring = {}
Spring.__index = Spring

function Spring.new(mass, damping, stiffness, startValue)
    local self = setmetatable({}, Spring)
    self.Mass = mass or 1
    self.Damping = damping or 1
    self.Stiffness = stiffness or 1
    self.Target = startValue or 0
    self.Position = startValue or 0
    self.Velocity = 0
    self.Clock = tick()
    return self
end

function Spring:Update()
    local now = tick()
    local dt = now - self.Clock
    self.Clock = now
    
    local displacement = self.Position - self.Target
    local springForce = -self.Stiffness * displacement
    local dampForce = -self.Damping * self.Velocity
    local acceleration = (springForce + dampForce) / self.Mass
    
    self.Velocity = self.Velocity + acceleration * dt
    self.Position = self.Position + self.Velocity * dt
    return self.Position
end

function Spring:Set(target)
    self.Target = target
end

-- ==============================================================================
-- // ENI'S UTILITY & DRAWING WRAPPER
-- ==============================================================================
local Utility = {
    Connections = {},
    Drawings = {},
    Fonts = {
        Main = Enum.Font.Gotham,
        Bold = Enum.Font.GothamBold,
        Semi = Enum.Font.GothamSemibold
    }
}

function Utility:Create(className, properties)
    local instance = Instance.new(className)
    for k, v in pairs(properties) do
        if k ~= "Parent" then instance[k] = v end
    end
    if properties.Parent then instance.Parent = properties.Parent end
    return instance
end

function Utility:Round(num, bracket)
    bracket = bracket or 1
    return math.floor(num / bracket + 0.5) * bracket
end

function Utility:Tween(instance, properties, duration, style, dir)
    local tInfo = TweenInfo.new(duration or 0.2, style or Enum.EasingStyle.Sine, dir or Enum.EasingDirection.Out)
    local t = TweenService:Create(instance, tInfo, properties)
    t:Play()
    return t
end

function Utility:Connect(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(self.Connections, connection)
    return connection
end

function Utility:GetTextSize(text, font, size, max)
    return TextService:GetTextSize(text, size, font, max or Vector2.new(10000, 10000))
end

-- Inertia Draggable Logic
function Utility:MakeDraggable(dragHandle, windowTarget)
    local dragging, dragInput, dragStart, startPos
    local velocity = Vector2.new(0, 0)
    local lastTime = tick()
    local lastPos = Vector2.new(0, 0)

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = windowTarget.Position
            lastPos = input.Position
            lastTime = tick()

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    RunService.RenderStepped:Connect(function(dt)
        if dragging and dragInput then
            local currentPos = dragInput.Position
            local deltaPos = currentPos - dragStart
            windowTarget.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + deltaPos.X, startPos.Y.Scale, startPos.Y.Offset + deltaPos.Y)
            
            local now = tick()
            local timeDelta = now - lastTime
            if timeDelta > 0 then velocity = (currentPos - lastPos) / timeDelta end
            lastPos = currentPos
            lastTime = now
        elseif not dragging and velocity.Magnitude > 0 then
            velocity = velocity * 0.85
            if velocity.Magnitude < 5 then velocity = Vector2.new(0,0) else
                windowTarget.Position = UDim2.new(windowTarget.Position.X.Scale, windowTarget.Position.X.Offset + (velocity.X * dt), windowTarget.Position.Y.Scale, windowTarget.Position.Y.Offset + (velocity.Y * dt))
            end
        end
    end)
end

-- ==============================================================================
-- // COLOR CONVERSION MATH (HSV <-> RGB)
-- ==============================================================================
local ColorMath = {}
function ColorMath.RGBToHSV(color)
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

function ColorMath.HSVToRGB(h, s, v)
    local r, g, b
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)
    i = i % 6
    if i == 0 then r, g, b = v, t, p
    elseif i == 1 then r, g, b = q, v, p
    elseif i == 2 then r, g, b = p, v, t
    elseif i == 3 then r, g, b = p, q, v
    elseif i == 4 then r, g, b = t, p, v
    elseif i == 5 then r, g, b = v, p, q end
    return Color3.new(r, g, b)
end

-- ==============================================================================
-- // CONFIGURATION MANAGER
-- ==============================================================================
local ConfigSystem = {
    FolderName = "Eni_Sunlight_Configs",
    Extension = ".eni"
}

function ConfigSystem:Init()
    if isfolder and not isfolder(self.FolderName) then
        makefolder(self.FolderName)
    end
end

function ConfigSystem:Save(flagsTable, name)
    if not writefile then return end
    self:Init()
    local path = self.FolderName .. "/" .. name .. self.Extension
    local success, encoded = pcall(HttpService.JSONEncode, HttpService, flagsTable)
    if success then writefile(path, encoded) end
end

function ConfigSystem:Load(flagsTable, name, callbackMap)
    if not readfile then return end
    local path = self.FolderName .. "/" .. name .. self.Extension
    if isfile(path) then
        local success, decoded = pcall(HttpService.JSONDecode, HttpService, readfile(path))
        if success then
            for key, val in pairs(decoded) do
                if flagsTable[key] ~= nil then
                    flagsTable[key] = val
                    if callbackMap[key] then callbackMap[key](val) end
                end
            end
        end
    end
end

function ConfigSystem:GetConfigs()
    local list = {}
    if listfiles then
        for _, file in pairs(listfiles(self.FolderName)) do
            if file:sub(-#self.Extension) == self.Extension then
                local name = file:sub(#self.FolderName + 2, -(#self.Extension + 1))
                table.insert(list, name)
            end
        end
    end
    return list
end

-- ==============================================================================
-- // THEME CONFIGURATION
-- ==============================================================================
local EniLibrary = {
    Version = "3.0.0 Monolith",
    Flags = {},
    Callbacks = {},
    Theme = {
        -- Base Glass
        Background = Color3.fromRGB(255, 252, 220),
        Glass = Color3.fromRGB(255, 255, 240),
        Outline = Color3.fromRGB(255, 225, 120),
        
        -- High Energy Yellows
        Accent = Color3.fromRGB(255, 200, 50),
        AccentHover = Color3.fromRGB(255, 215, 80),
        
        -- Texts
        TextMain = Color3.fromRGB(60, 45, 10),
        TextMuted = Color3.fromRGB(140, 115, 60),
        
        -- Component specifics
        ComponentBG = Color3.fromRGB(255, 248, 200),
        HoverBG = Color3.fromRGB(255, 255, 220),
        Scrollbar = Color3.fromRGB(255, 200, 50),
        
        -- States
        Success = Color3.fromRGB(120, 255, 140),
        Warning = Color3.fromRGB(255, 160, 60),
        Error = Color3.fromRGB(255, 90, 90)
    }
}

-- ==============================================================================
-- // NOTIFICATION ENGINE
-- ==============================================================================
local Notifications = {
    Container = nil,
    Queue = {},
    Active = 0,
    MaxActive = 5
}

function Notifications:Initialize()
    local SG = Utility:Create("ScreenGui", {
        Name = "Eni_Notifs",
        Parent = GetHUI(),
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    ProtectGui(SG)
    
    self.Container = Utility:Create("Frame", {
        Parent = SG,
        Position = UDim2.new(1, -320, 1, -20),
        Size = UDim2.new(0, 300, 1, -20),
        AnchorPoint = Vector2.new(0, 1),
        BackgroundTransparency = 1
    })
    
    Utility:Create("UIListLayout", {
        Parent = self.Container,
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Padding = UDim.new(0, 12)
    })
end

function EniLibrary:Notify(opts)
    opts = opts or {}
    local Title = opts.Title or "Notification"
    local Content = opts.Content or "Description here"
    local Duration = opts.Duration or 5

    if not Notifications.Container then Notifications:Initialize() end

    local Frame = Utility:Create("Frame", {
        Parent = Notifications.Container,
        Size = UDim2.new(1, 0, 0, 0), -- Animated
        BackgroundColor3 = self.Theme.Glass,
        BackgroundTransparency = 0.2,
        ClipsDescendants = true
    })
    Utility:Create("UICorner", { Parent = Frame, CornerRadius = UDim.new(0, 10) })
    Utility:Create("UIStroke", { Parent = Frame, Color = self.Theme.Outline, Thickness = 2, Transparency = 0.4 })
    
    local AccentLine = Utility:Create("Frame", {
        Parent = Frame,
        Size = UDim2.new(0, 4, 1, 0),
        BackgroundColor3 = self.Theme.Accent,
        BorderSizePixel = 0
    })

    local TitleLbl = Utility:Create("TextLabel", {
        Parent = Frame,
        Position = UDim2.new(0, 15, 0, 10),
        Size = UDim2.new(1, -30, 0, 20),
        BackgroundTransparency = 1,
        Font = Utility.Fonts.Bold,
        Text = Title,
        TextColor3 = self.Theme.TextMain,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTransparency = 1
    })

    local DescLbl = Utility:Create("TextLabel", {
        Parent = Frame,
        Position = UDim2.new(0, 15, 0, 32),
        Size = UDim2.new(1, -30, 0, 0),
        BackgroundTransparency = 1,
        Font = Utility.Fonts.Main,
        Text = Content,
        TextColor3 = self.Theme.TextMuted,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        TextTransparency = 1
    })

    local bounds = Utility:GetTextSize(Content, Utility.Fonts.Main, 13, Vector2.new(270, 9999))
    local tHeight = 45 + bounds.Y
    DescLbl.Size = UDim2.new(1, -30, 0, bounds.Y)

    -- In Animation
    Utility:Tween(Frame, {Size = UDim2.new(1, 0, 0, tHeight)}, 0.4, Enum.EasingStyle.Exponential)
    task.wait(0.1)
    Utility:Tween(TitleLbl, {TextTransparency = 0}, 0.3)
    Utility:Tween(DescLbl, {TextTransparency = 0}, 0.3)

    task.spawn(function()
        task.wait(Duration)
        Utility:Tween(TitleLbl, {TextTransparency = 1}, 0.2)
        Utility:Tween(DescLbl, {TextTransparency = 1}, 0.2)
        task.wait(0.2)
        local out = Utility:Tween(Frame, {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1}, 0.4, Enum.EasingStyle.Exponential)
        out.Completed:Connect(function() Frame:Destroy() end)
    end)
end

-- ==============================================================================
-- // MAIN WINDOW CONSTRUCTION
-- ==============================================================================
function EniLibrary:CreateWindow(options)
    options = options or {}
    local TitleText = options.Name or "Eni's Sunlight Framework"
    local Size = options.Size or UDim2.new(0, 750, 0, 500)

    for _, v in pairs(CoreGui:GetChildren()) do
        if v.Name == "Eni_SunlightUI" then v:Destroy() end
    end

    local ScreenGui = Utility:Create("ScreenGui", {
        Name = "Eni_SunlightUI",
        Parent = GetHUI(),
        ResetOnSpawn = false,
        IgnoreGuiInset = true
    })
    ProtectGui(ScreenGui)

    -- Base Window
    local MainFrame = Utility:Create("Frame", {
        Parent = ScreenGui,
        Position = UDim2.new(0.5, -Size.X.Offset/2, 0.5, -Size.Y.Offset/2),
        Size = Size,
        BackgroundColor3 = self.Theme.Background,
        BackgroundTransparency = 0.15,
        ClipsDescendants = false
    })
    Utility:Create("UICorner", { Parent = MainFrame, CornerRadius = UDim.new(0, 14) })
    Utility:Create("UIStroke", { Parent = MainFrame, Color = self.Theme.Outline, Thickness = 2, Transparency = 0.2 })
    
    -- Glassmorphism Gradient Overlay
    Utility:Create("UIGradient", {
        Parent = MainFrame,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, self.Theme.Glass)
        }),
        Rotation = 35
    })

    -- High Energy Shadow
    local Shadow = Utility:Create("ImageLabel", {
        Parent = MainFrame,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 10),
        Size = UDim2.new(1, 60, 1, 60),
        BackgroundTransparency = 1,
        Image = "rbxassetid://5028857472",
        ImageColor3 = self.Theme.Accent,
        ImageTransparency = 0.4,
        ZIndex = -1,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(24, 24, 276, 276)
    })

    -- // TOPBAR
    local Topbar = Utility:Create("Frame", {
        Parent = MainFrame,
        Size = UDim2.new(1, 0, 0, 55),
        BackgroundTransparency = 1
    })
    Utility:MakeDraggable(Topbar, MainFrame)

    local TitleLabel = Utility:Create("TextLabel", {
        Parent = Topbar,
        Position = UDim2.new(0, 20, 0, 0),
        Size = UDim2.new(1, -40, 1, 0),
        BackgroundTransparency = 1,
        Font = Utility.Fonts.Bold,
        Text = TitleText,
        TextColor3 = self.Theme.TextMain,
        TextSize = 22,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local TitleGlow = Utility:Create("TextLabel", {
        Parent = TitleLabel,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Font = Utility.Fonts.Bold,
        Text = TitleText,
        TextColor3 = self.Theme.Accent,
        TextSize = 22,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTransparency = 0.6,
        ZIndex = 0
    })

    local TopbarLine = Utility:Create("Frame", {
        Parent = Topbar,
        Position = UDim2.new(0, 15, 1, -2),
        Size = UDim2.new(1, -30, 0, 2),
        BackgroundColor3 = self.Theme.Accent,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0
    })

    -- // SIDEBAR
    local Sidebar = Utility:Create("Frame", {
        Parent = MainFrame,
        Position = UDim2.new(0, 15, 0, 70),
        Size = UDim2.new(0, 180, 1, -85),
        BackgroundColor3 = self.Theme.ComponentBG,
        BackgroundTransparency = 0.5
    })
    Utility:Create("UICorner", { Parent = Sidebar, CornerRadius = UDim.new(0, 10) })
    Utility:Create("UIStroke", { Parent = Sidebar, Color = self.Theme.Outline, Thickness = 1, Transparency = 0.3 })

    local TabScroll = Utility:Create("ScrollingFrame", {
        Parent = Sidebar,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = self.Theme.Scrollbar,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0)
    })
    local TabList = Utility:Create("UIListLayout", {
        Parent = TabScroll,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6),
        HorizontalAlignment = Enum.HorizontalAlignment.Center
    })
    Utility:Create("UIPadding", { Parent = TabScroll, PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10) })
    
    TabList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabScroll.CanvasSize = UDim2.new(0, 0, 0, TabList.AbsoluteContentSize.Y + 20)
    end)

    -- // CONTAINER HOLDER
    local ContainerHolder = Utility:Create("Frame", {
        Parent = MainFrame,
        Position = UDim2.new(0, 210, 0, 70),
        Size = UDim2.new(1, -225, 1, -85),
        BackgroundTransparency = 1
    })

    local WindowObj = {
        Tabs = {},
        CurrentTab = nil
    }

    -- Default Toggle Keybind
    local UIKeybind = Enum.KeyCode.RightShift
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == UIKeybind then
            ScreenGui.Enabled = not ScreenGui.Enabled
        end
    end)

    -- Intro Animation
    MainFrame.Position = UDim2.new(0.5, -Size.X.Offset/2, 0.5, -Size.Y.Offset/2 + 60)
    MainFrame.GroupTransparency = 1
    Utility:Tween(MainFrame, {Position = UDim2.new(0.5, -Size.X.Offset/2, 0.5, -Size.Y.Offset/2), GroupTransparency = 0}, 0.7, Enum.EasingStyle.Exponential)

    -- ==============================================================================
    -- // TAB CREATION
    -- ==============================================================================
    function WindowObj:MakeTab(tabOpts)
        tabOpts = tabOpts or {}
        local TabName = tabOpts.Name or "Tab"

        local TabBtn = Utility:Create("TextButton", {
            Parent = TabScroll,
            Size = UDim2.new(1, -20, 0, 38),
            BackgroundColor3 = self.Theme.Accent,
            BackgroundTransparency = 1,
            Font = Utility.Fonts.Bold,
            Text = TabName,
            TextColor3 = self.Theme.TextMuted,
            TextSize = 14,
            AutoButtonColor = false
        })
        Utility:Create("UICorner", { Parent = TabBtn, CornerRadius = UDim.new(0, 8) })

        local TabIndicator = Utility:Create("Frame", {
            Parent = TabBtn,
            Position = UDim2.new(0, 0, 0.5, -10),
            Size = UDim2.new(0, 4, 0, 20),
            BackgroundColor3 = self.Theme.TextMain,
            BackgroundTransparency = 1
        })
        Utility:Create("UICorner", { Parent = TabIndicator, CornerRadius = UDim.new(1, 0) })

        local Container = Utility:Create("ScrollingFrame", {
            Parent = ContainerHolder,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = self.Theme.Scrollbar,
            Visible = false,
            BorderSizePixel = 0,
            CanvasSize = UDim2.new(0, 0, 0, 0)
        })
        local ContainerLayout = Utility:Create("UIListLayout", {
            Parent = Container,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 12),
            HorizontalAlignment = Enum.HorizontalAlignment.Center
        })
        Utility:Create("UIPadding", { Parent = Container, PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 20) })
        
        ContainerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Container.CanvasSize = UDim2.new(0, 0, 0, ContainerLayout.AbsoluteContentSize.Y + 30)
        end)

        TabBtn.MouseEnter:Connect(function()
            if WindowObj.CurrentTab ~= Container then
                Utility:Tween(TabBtn, {BackgroundTransparency = 0.8, TextColor3 = self.Theme.TextMain}, 0.2)
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if WindowObj.CurrentTab ~= Container then
                Utility:Tween(TabBtn, {BackgroundTransparency = 1, TextColor3 = self.Theme.TextMuted}, 0.2)
            end
        end)

        TabBtn.MouseButton1Click:Connect(function()
            for _, t in pairs(WindowObj.Tabs) do
                t.Container.Visible = false
                Utility:Tween(t.Btn, {BackgroundTransparency = 1, TextColor3 = self.Theme.TextMuted}, 0.3)
                Utility:Tween(t.Indicator, {BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0.5, -10)}, 0.3)
            end
            WindowObj.CurrentTab = Container
            Container.Visible = true

            -- Staggered children animation
            for i, child in ipairs(Container:GetChildren()) do
                if child:IsA("Frame") then
                    child.GroupTransparency = 1
                    child.Position = UDim2.new(0, 30, 0, 0)
                    Utility:Tween(child, {GroupTransparency = 0, Position = UDim2.new(0, 0, 0, 0)}, 0.4 + (i * 0.05), Enum.EasingStyle.Exponential)
                end
            end

            Utility:Tween(TabBtn, {BackgroundTransparency = 0.3, TextColor3 = self.Theme.TextMain}, 0.3)
            Utility:Tween(TabIndicator, {BackgroundTransparency = 0, Position = UDim2.new(0, 6, 0.5, -10)}, 0.3, Enum.EasingStyle.Back)
        end)

        table.insert(WindowObj.Tabs, {Btn = TabBtn, Container = Container, Indicator = TabIndicator})

        if #WindowObj.Tabs == 1 then
            WindowObj.CurrentTab = Container
            Container.Visible = true
            TabBtn.BackgroundTransparency = 0.3
            TabBtn.TextColor3 = self.Theme.TextMain
            TabIndicator.BackgroundTransparency = 0
            TabIndicator.Position = UDim2.new(0, 6, 0.5, -10)
        end

        local Elements = {}

        -- ==============================================================================
        -- // ELEMENT: PARAGRAPH
        -- ==============================================================================
        function Elements:AddParagraph(opts)
            local TitleStr = opts.Title or "Paragraph"
            local ContentStr = opts.Content or "Content here"

            local Frame = Utility:Create("Frame", {
                Parent = Container,
                Size = UDim2.new(1, -10, 0, 0),
                BackgroundColor3 = EniLibrary.Theme.ComponentBG,
                BackgroundTransparency = 0.4
            })
            Utility:Create("UICorner", { Parent = Frame, CornerRadius = UDim.new(0, 8) })
            Utility:Create("UIStroke", { Parent = Frame, Color = EniLibrary.Theme.Outline, Thickness = 1, Transparency = 0.3 })

            local TitleLbl = Utility:Create("TextLabel", {
                Parent = Frame,
                Position = UDim2.new(0, 15, 0, 10),
                Size = UDim2.new(1, -30, 0, 20),
                BackgroundTransparency = 1,
                Font = Utility.Fonts.Bold,
                Text = TitleStr,
                TextColor3 = EniLibrary.Theme.Accent,
                TextSize = 15,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local ContentLbl = Utility:Create("TextLabel", {
                Parent = Frame,
                Position = UDim2.new(0, 15, 0, 35),
                Size = UDim2.new(1, -30, 0, 0),
                BackgroundTransparency = 1,
                Font = Utility.Fonts.Main,
                Text = ContentStr,
                TextColor3 = EniLibrary.Theme.TextMuted,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                TextWrapped = true
            })

            local bounds = Utility:GetTextSize(ContentStr, Utility.Fonts.Main, 13, Vector2.new(Container.AbsoluteSize.X - 40, 9999))
            ContentLbl.Size = UDim2.new(1, -30, 0, bounds.Y)
            Frame.Size = UDim2.new(1, -10, 0, 45 + bounds.Y)
        end

        -- ==============================================================================
        -- // ELEMENT: BUTTON
        -- ==============================================================================
        function Elements:AddButton(opts)
            local Name = opts.Name or "Button"
            local Callback = opts.Callback or function() end

            local Frame = Utility:Create("Frame", {
                Parent = Container,
                Size = UDim2.new(1, -10, 0, 45),
                BackgroundColor3 = EniLibrary.Theme.ComponentBG,
                BackgroundTransparency = 0.4
            })
            Utility:Create("UICorner", { Parent = Frame, CornerRadius = UDim.new(0, 8) })
            local Stroke = Utility:Create("UIStroke", { Parent = Frame, Color = EniLibrary.Theme.Outline, Thickness = 1, Transparency = 0.3 })

            local Btn = Utility:Create("TextButton", {
                Parent = Frame,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Font = Utility.Fonts.Bold,
                Text = Name,
                TextColor3 = EniLibrary.Theme.TextMain,
                TextSize = 15,
                AutoButtonColor = false,
                ClipsDescendants = true
            })

            Btn.MouseEnter:Connect(function() 
                Utility:Tween(Frame, {BackgroundTransparency = 0.1, BackgroundColor3 = EniLibrary.Theme.HoverBG}, 0.2)
                Utility:Tween(Stroke, {Transparency = 0}, 0.2)
            end)
            Btn.MouseLeave:Connect(function() 
                Utility:Tween(Frame, {BackgroundTransparency = 0.4, BackgroundColor3 = EniLibrary.Theme.ComponentBG, Size = UDim2.new(1, -10, 0, 45)}, 0.2)
                Utility:Tween(Stroke, {Transparency = 0.3}, 0.2)
            end)

            Btn.MouseButton1Down:Connect(function()
                Utility:Tween(Frame, {Size = UDim2.new(1, -20, 0, 41)}, 0.1, Enum.EasingStyle.Sine)
                
                -- High Energy Math Ripple
                local mLoc = UserInputService:GetMouseLocation()
                local ripple = Utility:Create("Frame", {
                    Parent = Btn,
                    BackgroundColor3 = EniLibrary.Theme.Accent,
                    BackgroundTransparency = 0.4,
                    Position = UDim2.new(0, mLoc.X - Btn.AbsolutePosition.X, 0, mLoc.Y - Btn.AbsolutePosition.Y - 36),
                    Size = UDim2.new(0, 0, 0, 0),
                    AnchorPoint = Vector2.new(0.5, 0.5)
                })
                Utility:Create("UICorner", { Parent = ripple, CornerRadius = UDim.new(1, 0) })
                local t = Utility:Tween(ripple, {Size = UDim2.new(0, 500, 0, 500), BackgroundTransparency = 1}, 0.6, Enum.EasingStyle.Exponential)
                t.Completed:Connect(function() ripple:Destroy() end)
            end)

            Btn.MouseButton1Up:Connect(function()
                Utility:Tween(Frame, {Size = UDim2.new(1, -10, 0, 45)}, 0.4, Enum.EasingStyle.Elastic)
                task.spawn(Callback)
            end)
        end

        -- ==============================================================================
        -- // ELEMENT: TOGGLE
        -- ==============================================================================
        function Elements:AddToggle(opts)
            local Name = opts.Name or "Toggle"
            local Default = opts.Default or false
            local Flag = opts.Flag or Name
            local Callback = opts.Callback or function() end

            EniLibrary.Flags[Flag] = Default
            local State = Default

            local Frame = Utility:Create("Frame", {
                Parent = Container,
                Size = UDim2.new(1, -10, 0, 45),
                BackgroundColor3 = EniLibrary.Theme.ComponentBG,
                BackgroundTransparency = 0.4
            })
            Utility:Create("UICorner", { Parent = Frame, CornerRadius = UDim.new(0, 8) })
            Utility:Create("UIStroke", { Parent = Frame, Color = EniLibrary.Theme.Outline, Thickness = 1, Transparency = 0.3 })

            Utility:Create("TextLabel", {
                Parent = Frame,
                Position = UDim2.new(0, 15, 0, 0),
                Size = UDim2.new(1, -100, 1, 0),
                BackgroundTransparency = 1,
                Font = Utility.Fonts.Bold,
                Text = Name,
                TextColor3 = EniLibrary.Theme.TextMain,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local SwitchBG = Utility:Create("Frame", {
                Parent = Frame,
                Position = UDim2.new(1, -60, 0.5, -12),
                Size = UDim2.new(0, 46, 0, 24),
                BackgroundColor3 = State and EniLibrary.Theme.Success or Color3.fromRGB(220, 210, 170),
                BackgroundTransparency = 0.2
            })
            Utility:Create("UICorner", { Parent = SwitchBG, CornerRadius = UDim.new(1, 0) })

            local Indicator = Utility:Create("Frame", {
                Parent = SwitchBG,
                Position = State and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10),
                Size = UDim2.new(0, 20, 0, 20),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            })
            Utility:Create("UICorner", { Parent = Indicator, CornerRadius = UDim.new(1, 0) })

            local Glow = Utility:Create("ImageLabel", {
                Parent = Indicator,
                Position = UDim2.new(0, -8, 0, -8),
                Size = UDim2.new(1, 16, 1, 16),
                BackgroundTransparency = 1,
                Image = "rbxassetid://5028857472",
                ImageColor3 = EniLibrary.Theme.Success,
                ImageTransparency = State and 0.2 or 1
            })

            local Btn = Utility:Create("TextButton", { Parent = Frame, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "" })

            local function Fire(s)
                State = s
                EniLibrary.Flags[Flag] = State
                if State then
                    Utility:Tween(SwitchBG, {BackgroundColor3 = EniLibrary.Theme.Success}, 0.3)
                    Utility:Tween(Indicator, {Position = UDim2.new(1, -22, 0.5, -10), Size = UDim2.new(0, 24, 0, 20)}, 0.15)
                    task.wait(0.1)
                    Utility:Tween(Indicator, {Size = UDim2.new(0, 20, 0, 20)}, 0.2, Enum.EasingStyle.Elastic)
                    Utility:Tween(Glow, {ImageTransparency = 0.2}, 0.3)
                else
                    Utility:Tween(SwitchBG, {BackgroundColor3 = Color3.fromRGB(220, 210, 170)}, 0.3)
                    Utility:Tween(Indicator, {Position = UDim2.new(0, 2, 0.5, -10), Size = UDim2.new(0, 24, 0, 20)}, 0.15)
                    task.wait(0.1)
                    Utility:Tween(Indicator, {Size = UDim2.new(0, 20, 0, 20)}, 0.2, Enum.EasingStyle.Elastic)
                    Utility:Tween(Glow, {ImageTransparency = 1}, 0.3)
                end
                task.spawn(Callback, State)
            end

            Btn.MouseButton1Click:Connect(function() Fire(not State) end)
            Btn.MouseEnter:Connect(function() Utility:Tween(Frame, {BackgroundTransparency = 0.1}, 0.2) end)
            Btn.MouseLeave:Connect(function() Utility:Tween(Frame, {BackgroundTransparency = 0.4}, 0.2) end)
            
            EniLibrary.Callbacks[Flag] = Fire
        end

        -- ==============================================================================
        -- // ELEMENT: SLIDER
        -- ==============================================================================
        function Elements:AddSlider(opts)
            local Name = opts.Name or "Slider"
            local Min = opts.Min or 0
            local Max = opts.Max or 100
            local Default = opts.Default or Min
            local Increment = opts.Increment or 1
            local ValueName = opts.ValueName or ""
            local Flag = opts.Flag or Name
            local Callback = opts.Callback or function() end

            EniLibrary.Flags[Flag] = Default

            local Frame = Utility:Create("Frame", {
                Parent = Container,
                Size = UDim2.new(1, -10, 0, 65),
                BackgroundColor3 = EniLibrary.Theme.ComponentBG,
                BackgroundTransparency = 0.4
            })
            Utility:Create("UICorner", { Parent = Frame, CornerRadius = UDim.new(0, 8) })
            Utility:Create("UIStroke", { Parent = Frame, Color = EniLibrary.Theme.Outline, Thickness = 1, Transparency = 0.3 })

            Utility:Create("TextLabel", {
                Parent = Frame,
                Position = UDim2.new(0, 15, 0, 10),
                Size = UDim2.new(1, -30, 0, 20),
                BackgroundTransparency = 1,
                Font = Utility.Fonts.Bold,
                Text = Name,
                TextColor3 = EniLibrary.Theme.TextMain,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local ValueLbl = Utility:Create("TextLabel", {
                Parent = Frame,
                Position = UDim2.new(0, 15, 0, 10),
                Size = UDim2.new(1, -30, 0, 20),
                BackgroundTransparency = 1,
                Font = Utility.Fonts.Bold,
                Text = tostring(Default) .. ValueName,
                TextColor3 = EniLibrary.Theme.Accent,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Right
            })

            local SliderBG = Utility:Create("Frame", {
                Parent = Frame,
                Position = UDim2.new(0, 15, 0, 45),
                Size = UDim2.new(1, -30, 0, 6),
                BackgroundColor3 = Color3.fromRGB(220, 210, 170),
                BackgroundTransparency = 0.3
            })
            Utility:Create("UICorner", { Parent = SliderBG, CornerRadius = UDim.new(1, 0) })

            local SliderFill = Utility:Create("Frame", {
                Parent = SliderBG,
                Size = UDim2.new((Default - Min)/(Max - Min), 0, 1, 0),
                BackgroundColor3 = EniLibrary.Theme.Accent
            })
            Utility:Create("UICorner", { Parent = SliderFill, CornerRadius = UDim.new(1, 0) })

            local Knob = Utility:Create("Frame", {
                Parent = SliderFill,
                Position = UDim2.new(1, -6, 0.5, -6),
                Size = UDim2.new(0, 12, 0, 12),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            })
            Utility:Create("UICorner", { Parent = Knob, CornerRadius = UDim.new(1, 0) })
            Utility:Create("UIStroke", { Parent = Knob, Color = EniLibrary.Theme.Accent, Thickness = 2 })

            local DragBtn = Utility:Create("TextButton", { Parent = SliderBG, Position = UDim2.new(0, -10, 0, -15), Size = UDim2.new(1, 20, 1, 30), BackgroundTransparency = 1, Text = "" })

            local Dragging = false
            local function Update(input)
                local mathCalc = math.clamp((input.Position.X - SliderBG.AbsolutePosition.X) / SliderBG.AbsoluteSize.X, 0, 1)
                local value = Min + ((Max - Min) * mathCalc)
                value = Utility:Round(value, Increment)
                EniLibrary.Flags[Flag] = value
                
                ValueLbl.Text = tostring(value) .. ValueName
                Utility:Tween(SliderFill, {Size = UDim2.new((value - Min)/(Max - Min), 0, 1, 0)}, 0.1)
                task.spawn(Callback, value)
            end

            DragBtn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    Dragging = true
                    Update(input)
                    Utility:Tween(Knob, {Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(1, -8, 0.5, -8)}, 0.2, Enum.EasingStyle.Elastic)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    Dragging = false
                    Utility:Tween(Knob, {Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(1, -6, 0.5, -6)}, 0.2, Enum.EasingStyle.Bounce)
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then Update(input) end
            end)

            EniLibrary.Callbacks[Flag] = function(val)
                val = math.clamp(Utility:Round(val, Increment), Min, Max)
                EniLibrary.Flags[Flag] = val
                ValueLbl.Text = tostring(val) .. ValueName
                Utility:Tween(SliderFill, {Size = UDim2.new((val - Min)/(Max - Min), 0, 1, 0)}, 0.2)
                task.spawn(Callback, val)
            end
        end

        -- ==============================================================================
        -- // ELEMENT: DROPDOWN
        -- ==============================================================================
        function Elements:AddDropdown(opts)
            local Name = opts.Name or "Dropdown"
            local Options = opts.Options or {}
            local Default = opts.Default or Options[1]
            local Flag = opts.Flag or Name
            local Callback = opts.Callback or function() end

            EniLibrary.Flags[Flag] = Default
            local IsOpen = false

            local Frame = Utility:Create("Frame", {
                Parent = Container,
                Size = UDim2.new(1, -10, 0, 45),
                BackgroundColor3 = EniLibrary.Theme.ComponentBG,
                BackgroundTransparency = 0.4,
                ClipsDescendants = true
            })
            Utility:Create("UICorner", { Parent = Frame, CornerRadius = UDim.new(0, 8) })
            Utility:Create("UIStroke", { Parent = Frame, Color = EniLibrary.Theme.Outline, Thickness = 1, Transparency = 0.3 })

            local Title = Utility:Create("TextLabel", {
                Parent = Frame,
                Position = UDim2.new(0, 15, 0, 0),
                Size = UDim2.new(1, -50, 0, 45),
                BackgroundTransparency = 1,
                Font = Utility.Fonts.Bold,
                Text = Name .. " : " .. tostring(Default),
                TextColor3 = EniLibrary.Theme.TextMain,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local Arrow = Utility:Create("TextLabel", {
                Parent = Frame,
                Position = UDim2.new(1, -35, 0, 0),
                Size = UDim2.new(0, 20, 0, 45),
                BackgroundTransparency = 1,
                Font = Utility.Fonts.Bold,
                Text = "V",
                TextColor3 = EniLibrary.Theme.Accent,
                TextSize = 14
            })

            local Btn = Utility:Create("TextButton", { Parent = Frame, Size = UDim2.new(1, 0, 0, 45), BackgroundTransparency = 1, Text = "" })

            local DropContainer = Utility:Create("ScrollingFrame", {
                Parent = Frame,
                Position = UDim2.new(0, 10, 0, 50),
                Size = UDim2.new(1, -20, 1, -60),
                BackgroundTransparency = 1,
                ScrollBarThickness = 2,
                ScrollBarImageColor3 = EniLibrary.Theme.Accent,
                CanvasSize = UDim2.new(0, 0, 0, 0)
            })
            local DropLayout = Utility:Create("UIListLayout", { Parent = DropContainer, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4) })

            local function Refresh(newOpts)
                Options = newOpts or Options
                for _, v in pairs(DropContainer:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
                
                for _, opt in pairs(Options) do
                    local OptBtn = Utility:Create("TextButton", {
                        Parent = DropContainer,
                        Size = UDim2.new(1, -5, 0, 30),
                        BackgroundColor3 = EniLibrary.Theme.Accent,
                        BackgroundTransparency = 0.8,
                        Font = Utility.Fonts.Main,
                        Text = "  " .. tostring(opt),
                        TextColor3 = EniLibrary.Theme.TextMain,
                        TextSize = 13,
                        TextXAlignment = Enum.TextXAlignment.Left
                    })
                    Utility:Create("UICorner", { Parent = OptBtn, CornerRadius = UDim.new(0, 4) })

                    OptBtn.MouseEnter:Connect(function() Utility:Tween(OptBtn, {BackgroundTransparency = 0.4}, 0.2) end)
                    OptBtn.MouseLeave:Connect(function() Utility:Tween(OptBtn, {BackgroundTransparency = 0.8}, 0.2) end)
                    
                    OptBtn.MouseButton1Click:Connect(function()
                        IsOpen = false
                        EniLibrary.Flags[Flag] = opt
                        Title.Text = Name .. " : " .. tostring(opt)
                        Utility:Tween(Frame, {Size = UDim2.new(1, -10, 0, 45)}, 0.4, Enum.EasingStyle.Exponential)
                        Utility:Tween(Arrow, {Rotation = 0}, 0.3)
                        task.spawn(Callback, opt)
                    end)
                end
                DropContainer.CanvasSize = UDim2.new(0, 0, 0, DropLayout.AbsoluteContentSize.Y)
            end
            Refresh()

            Btn.MouseButton1Click:Connect(function()
                IsOpen = not IsOpen
                if IsOpen then
                    local h = math.clamp(55 + (#Options * 34), 0, 200)
                    Utility:Tween(Frame, {Size = UDim2.new(1, -10, 0, h)}, 0.4, Enum.EasingStyle.Exponential)
                    Utility:Tween(Arrow, {Rotation = 180}, 0.3)
                else
                    Utility:Tween(Frame, {Size = UDim2.new(1, -10, 0, 45)}, 0.4, Enum.EasingStyle.Exponential)
                    Utility:Tween(Arrow, {Rotation = 0}, 0.3)
                end
            end)

            EniLibrary.Callbacks[Flag] = function(val)
                EniLibrary.Flags[Flag] = val
                Title.Text = Name .. " : " .. tostring(val)
                task.spawn(Callback, val)
            end

            return { Refresh = Refresh }
        end

        -- ==============================================================================
        -- // ELEMENT: KEYBIND
        -- ==============================================================================
        function Elements:AddKeybind(opts)
            local Name = opts.Name or "Keybind"
            local Default = opts.Default or Enum.KeyCode.E
            local Flag = opts.Flag or Name
            local Callback = opts.Callback or function() end

            EniLibrary.Flags[Flag] = Default
            local CurrentKey = Default
            local IsBinding = false

            local Frame = Utility:Create("Frame", {
                Parent = Container,
                Size = UDim2.new(1, -10, 0, 45),
                BackgroundColor3 = EniLibrary.Theme.ComponentBG,
                BackgroundTransparency = 0.4
            })
            Utility:Create("UICorner", { Parent = Frame, CornerRadius = UDim.new(0, 8) })
            Utility:Create("UIStroke", { Parent = Frame, Color = EniLibrary.Theme.Outline, Thickness = 1, Transparency = 0.3 })

            Utility:Create("TextLabel", {
                Parent = Frame,
                Position = UDim2.new(0, 15, 0, 0),
                Size = UDim2.new(1, -100, 1, 0),
                BackgroundTransparency = 1,
                Font = Utility.Fonts.Bold,
                Text = Name,
                TextColor3 = EniLibrary.Theme.TextMain,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local BindBox = Utility:Create("Frame", {
                Parent = Frame,
                Position = UDim2.new(1, -85, 0.5, -14),
                Size = UDim2.new(0, 70, 0, 28),
                BackgroundColor3 = EniLibrary.Theme.Background,
                BackgroundTransparency = 0.2
            })
            Utility:Create("UICorner", { Parent = BindBox, CornerRadius = UDim.new(0, 6) })
            local BindStroke = Utility:Create("UIStroke", { Parent = BindBox, Color = EniLibrary.Theme.Outline, Thickness = 1 })

            local BindText = Utility:Create("TextLabel", {
                Parent = BindBox,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Font = Utility.Fonts.Bold,
                Text = CurrentKey.Name,
                TextColor3 = EniLibrary.Theme.Accent,
                TextSize = 13
            })

            local Btn = Utility:Create("TextButton", { Parent = BindBox, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "" })

            Btn.MouseButton1Click:Connect(function()
                IsBinding = true
                BindText.Text = "..."
                Utility:Tween(BindStroke, {Color = EniLibrary.Theme.Accent}, 0.2)
            end)

            UserInputService.InputBegan:Connect(function(input, gpe)
                if not gpe then
                    if IsBinding and input.UserInputType == Enum.UserInputType.Keyboard then
                        if input.KeyCode ~= Enum.KeyCode.Unknown then
                            CurrentKey = input.KeyCode
                            EniLibrary.Flags[Flag] = CurrentKey
                            BindText.Text = CurrentKey.Name
                            IsBinding = false
                            Utility:Tween(BindStroke, {Color = EniLibrary.Theme.Outline}, 0.2)
                        end
                    elseif not IsBinding and input.KeyCode == CurrentKey then
                        task.spawn(Callback, CurrentKey)
                    end
                end
            end)

            EniLibrary.Callbacks[Flag] = function(val)
                CurrentKey = val
                EniLibrary.Flags[Flag] = val
                BindText.Text = val.Name
            end
        end

        -- ==============================================================================
        -- // ELEMENT: TEXTBOX
        -- ==============================================================================
        function Elements:AddTextBox(opts)
            local Name = opts.Name or "TextBox"
            local Default = opts.Default or ""
            local Placeholder = opts.Placeholder or "Type..."
            local Clear = opts.ClearOnFocus or false
            local Flag = opts.Flag or Name
            local Callback = opts.Callback or function() end

            EniLibrary.Flags[Flag] = Default

            local Frame = Utility:Create("Frame", {
                Parent = Container,
                Size = UDim2.new(1, -10, 0, 45),
                BackgroundColor3 = EniLibrary.Theme.ComponentBG,
                BackgroundTransparency = 0.4
            })
            Utility:Create("UICorner", { Parent = Frame, CornerRadius = UDim.new(0, 8) })
            Utility:Create("UIStroke", { Parent = Frame, Color = EniLibrary.Theme.Outline, Thickness = 1, Transparency = 0.3 })

            Utility:Create("TextLabel", {
                Parent = Frame,
                Position = UDim2.new(0, 15, 0, 0),
                Size = UDim2.new(0.5, -15, 1, 0),
                BackgroundTransparency = 1,
                Font = Utility.Fonts.Bold,
                Text = Name,
                TextColor3 = EniLibrary.Theme.TextMain,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local BoxBG = Utility:Create("Frame", {
                Parent = Frame,
                Position = UDim2.new(0.5, 10, 0.5, -14),
                Size = UDim2.new(0.5, -25, 0, 28),
                BackgroundColor3 = EniLibrary.Theme.Background,
                BackgroundTransparency = 0.2
            })
            Utility:Create("UICorner", { Parent = BoxBG, CornerRadius = UDim.new(0, 6) })
            local BoxStroke = Utility:Create("UIStroke", { Parent = BoxBG, Color = EniLibrary.Theme.Outline, Thickness = 1 })

            local TxtBox = Utility:Create("TextBox", {
                Parent = BoxBG,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -20, 1, 0),
                BackgroundTransparency = 1,
                Font = Utility.Fonts.Main,
                Text = Default,
                PlaceholderText = Placeholder,
                TextColor3 = EniLibrary.Theme.TextMain,
                PlaceholderColor3 = EniLibrary.Theme.TextMuted,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                ClearTextOnFocus = Clear
            })

            TxtBox.Focused:Connect(function() Utility:Tween(BoxStroke, {Color = EniLibrary.Theme.Accent}, 0.2) end)
            TxtBox.FocusLost:Connect(function()
                Utility:Tween(BoxStroke, {Color = EniLibrary.Theme.Outline}, 0.2)
                EniLibrary.Flags[Flag] = TxtBox.Text
                task.spawn(Callback, TxtBox.Text)
            end)

            EniLibrary.Callbacks[Flag] = function(val)
                TxtBox.Text = val
                EniLibrary.Flags[Flag] = val
                task.spawn(Callback, val)
            end
        end

        return Elements
    end

    return WindowObj
end

-- ==============================================================================
-- // ESP & DRAWING API WRAPPER (PADDING FOR FULL MONOLITH CAPABILITY)
-- ==============================================================================
EniLibrary.ESP = { Enabled = false, TeamCheck = false, Boxes = true, Names = true, Tracers = false }
local Camera = game:GetService("Workspace").CurrentCamera

function EniLibrary.ESP:CreateDrawing(type, props)
    local draw = Drawing.new(type)
    for k, v in pairs(props) do draw[k] = v end
    table.insert(Utility.Drawings, draw)
    return draw
end

function EniLibrary.ESP:InitPlayer(player)
    if player == LocalPlayer then return end
    local drawings = {
        Box = self:CreateDrawing("Square", {Color = EniLibrary.Theme.Accent, Thickness = 1, Filled = false, Visible = false}),
        Name = self:CreateDrawing("Text", {Color = Color3.new(1,1,1), Size = 16, Center = true, Outline = true, Visible = false}),
        Tracer = self:CreateDrawing("Line", {Color = EniLibrary.Theme.Accent, Thickness = 1, Visible = false})
    }

    local conn
    conn = RunService.RenderStepped:Connect(function()
        if not self.Enabled or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") or not player.Character:FindFirstChild("Humanoid") or player.Character.Humanoid.Health <= 0 then
            drawings.Box.Visible = false; drawings.Name.Visible = false; drawings.Tracer.Visible = false
            if not player.Parent then conn:Disconnect() end
            return
        end

        local hrp = player.Character.HumanoidRootPart
        local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
        if onScreen then
            local rootTop, _ = Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 3, 0))
            local rootBottom, _ = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3.5, 0))
            local height = math.abs(rootTop.Y - rootBottom.Y)
            local width = height * 0.65

            if self.Boxes then
                drawings.Box.Size = Vector2.new(width, height)
                drawings.Box.Position = Vector2.new(pos.X - width/2, rootTop.Y)
                drawings.Box.Visible = true
            else drawings.Box.Visible = false end

            if self.Names then
                drawings.Name.Text = player.Name
                drawings.Name.Position = Vector2.new(pos.X, rootTop.Y - 20)
                drawings.Name.Visible = true
            else drawings.Name.Visible = false end

            if self.Tracers then
                drawings.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                drawings.Tracer.To = Vector2.new(pos.X, rootBottom.Y)
                drawings.Tracer.Visible = true
            else drawings.Tracer.Visible = false end
        else
            drawings.Box.Visible = false; drawings.Name.Visible = false; drawings.Tracer.Visible = false
        end
    end)
end

function EniLibrary.ESP:Start()
    for _, v in pairs(Players:GetPlayers()) do self:InitPlayer(v) end
    Players.PlayerAdded:Connect(function(v) self:InitPlayer(v) end)
end

return EniLibrary
