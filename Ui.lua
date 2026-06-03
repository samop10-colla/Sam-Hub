-- ==============================================================================
-- Sam's Hub UI Framework - PRO VERSION (UPDATED)
-- Coded exclusively for LO by ENI.
-- + Compact Size
-- + Motion Graphic Loader
-- + Floating Toggle Circle
-- + Minimize Glitch Fixed
-- ==============================================================================

local Library = {
    Version = "2.1.0",
    Author = "ENI for LO",
    Theme = {
        Background = Color3.fromRGB(18, 24, 20),
        Sidebar = Color3.fromRGB(13, 18, 15),
        Topbar = Color3.fromRGB(10, 15, 12),
        Accent = Color3.fromRGB(75, 220, 120),
        AccentDark = Color3.fromRGB(45, 160, 80),
        Text = Color3.fromRGB(240, 245, 240),
        TextDark = Color3.fromRGB(140, 150, 145),
        Element = Color3.fromRGB(24, 30, 26),
        ElementHover = Color3.fromRGB(32, 40, 34),
        Border = Color3.fromRGB(38, 48, 42),
        Shadow = Color3.fromRGB(0, 0, 0),
        Success = Color3.fromRGB(80, 200, 120),
        Warning = Color3.fromRGB(220, 180, 70),
        Error = Color3.fromRGB(220, 70, 70)
    },
    Registry = {},
    Flags = {}
}

-- ==============================================================================
-- Core Services & Variables
-- ==============================================================================
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local ParentUI = nil
if gethui then ParentUI = gethui() 
elseif not pcall(function() ParentUI = CoreGui end) then ParentUI = LocalPlayer:WaitForChild("PlayerGui") end

-- ==============================================================================
-- Utility Functions
-- ==============================================================================
local function Create(className, properties)
    local instance = Instance.new(className)
    for k, v in pairs(properties) do
        if k ~= "Parent" then instance[k] = v end
    end
    if properties.Parent then instance.Parent = properties.Parent end
    return instance
end

local function Tween(instance, properties, duration, style, direction)
    style = style or Enum.EasingStyle.Quart
    direction = direction or Enum.EasingDirection.Out
    duration = duration or 0.4
    local tweenInfo = TweenInfo.new(duration, style, direction)
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

local function GetTextBounds(text, font, size, bounds)
    return TextService:GetTextSize(text, size, font, bounds or Vector2.new(10000, 10000))
end

local function MakeDraggable(dragArea, moveTarget)
    local dragging, dragInput, dragStart, startPos
    dragArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = moveTarget.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    dragArea.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Tween(moveTarget, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}, 0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
        end
    end)
end

local function AdvancedRipple(button)
    task.spawn(function()
        local ripple = Create("Frame", {
            Name = "Ripple",
            Parent = button,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 0.8,
            ZIndex = button.ZIndex + 2,
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0, Mouse.X - button.AbsolutePosition.X, 0, Mouse.Y - button.AbsolutePosition.Y),
            AnchorPoint = Vector2.new(0.5, 0.5),
            ClipsDescendants = true
        })
        Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = ripple})
        local targetSize = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 1.5
        local t1 = Tween(ripple, {Size = UDim2.new(0, targetSize, 0, targetSize), BackgroundTransparency = 1}, 0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        t1.Completed:Wait()
        ripple:Destroy()
    end)
end

local function ApplyHover(element, targetColor, originalColor)
    element.MouseEnter:Connect(function() Tween(element, {BackgroundColor3 = targetColor}, 0.25) end)
    element.MouseLeave:Connect(function() Tween(element, {BackgroundColor3 = originalColor}, 0.25) end)
end

local function CreateShadow(parent, radius, intensity, offset)
    return Create("ImageLabel", {
        Name = "Shadow",
        Parent = parent,
        BackgroundTransparency = 1,
        Image = "rbxassetid://5028857084",
        ImageColor3 = Library.Theme.Shadow,
        ImageTransparency = intensity or 0.5,
        Size = UDim2.new(1, radius * 2, 1, radius * 2),
        Position = UDim2.new(0, -radius + (offset and offset.X or 0), 0, -radius + (offset and offset.Y or 0)),
        ZIndex = parent.ZIndex - 1,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(24, 24, 276, 276)
    })
end

-- ==============================================================================
-- Main GUI Builder
-- ==============================================================================
function Library:Init(options)
    options = options or {}
    local Title = options.Title or "Sam's Hub"
    local Description = options.Description or "Premium Framework"
    local LogoId = options.Logo or "rbxassetid://4483345998"

    local SamHubGui = Create("ScreenGui", {
        Name = "SamsHub_V2_Updated",
        Parent = ParentUI,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        DisplayOrder = 100
    })
    Library.ScreenGui = SamHubGui

    -- ==============================================================================
    -- Notification Engine & Dialogs
    -- ==============================================================================
    local NotifContainer = Create("Frame", {
        Name = "NotificationContainer",
        Parent = SamHubGui,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -320, 1, -20),
        Size = UDim2.new(0, 300, 1, 0),
        AnchorPoint = Vector2.new(0, 1),
        ZIndex = 1000
    })
    local NotifLayout = Create("UIListLayout", {
        Parent = NotifContainer,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10),
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        HorizontalAlignment = Enum.HorizontalAlignment.Right
    })

    function Library:Notify(nOpts)
        nOpts = nOpts or {}
        local nTitle = nOpts.Title or "Notification"
        local nText = nOpts.Text or "This is a notification."
        local nDuration = nOpts.Duration or 5
        local nType = nOpts.Type or "Info"
        
        local AccentCol = Library.Theme.Accent
        if nType == "Success" then AccentCol = Library.Theme.Success
        elseif nType == "Warning" then AccentCol = Library.Theme.Warning
        elseif nType == "Error" then AccentCol = Library.Theme.Error end

        local textBounds = GetTextBounds(nText, Enum.Font.GothamMedium, 13, Vector2.new(260, 9999))
        local frameHeight = math.max(65, textBounds.Y + 40)

        local NotifFrame = Create("Frame", {
            Parent = NotifContainer,
            BackgroundColor3 = Library.Theme.Background,
            Size = UDim2.new(0, 300, 0, frameHeight),
            BackgroundTransparency = 1,
            Position = UDim2.new(1, 50, 0, 0)
        })
        Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = NotifFrame})
        Create("UIStroke", {Parent = NotifFrame, Color = AccentCol, Thickness = 1, Transparency = 1})
        CreateShadow(NotifFrame, 15, 0.6)

        local Bar = Create("Frame", {
            Parent = NotifFrame,
            BackgroundColor3 = AccentCol,
            Size = UDim2.new(0, 4, 1, -20),
            Position = UDim2.new(0, 10, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundTransparency = 1
        })
        Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Bar})

        local NTitle = Create("TextLabel", { Parent = NotifFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 25, 0, 10), Size = UDim2.new(1, -35, 0, 16), Font = Enum.Font.GothamBold, Text = nTitle, TextColor3 = Library.Theme.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, TextTransparency = 1 })
        local NText = Create("TextLabel", { Parent = NotifFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 25, 0, 30), Size = UDim2.new(1, -35, 0, textBounds.Y), Font = Enum.Font.GothamMedium, Text = nText, TextColor3 = Library.Theme.TextDark, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, TextWrapped = true, TextTransparency = 1 })

        Tween(NotifFrame, {BackgroundTransparency = 0}, 0.4)
        Tween(NotifFrame:FindFirstChild("UIStroke"), {Transparency = 0}, 0.4)
        Tween(Bar, {BackgroundTransparency = 0}, 0.4)
        Tween(NTitle, {TextTransparency = 0}, 0.4)
        Tween(NText, {TextTransparency = 0}, 0.4)

        task.spawn(function()
            task.wait(nDuration)
            local fade = Tween(NotifFrame, {BackgroundTransparency = 1}, 0.5)
            Tween(NotifFrame:FindFirstChild("UIStroke"), {Transparency = 1}, 0.5)
            Tween(Bar, {BackgroundTransparency = 1}, 0.5)
            Tween(NTitle, {TextTransparency = 1}, 0.5)
            Tween(NText, {TextTransparency = 1}, 0.5)
            fade.Completed:Wait()
            NotifFrame:Destroy()
        end)
    end

    function Library:Prompt(pOpts)
        pOpts = pOpts or {}
        local pTitle = pOpts.Title or "Confirmation"
        local pText = pOpts.Text or "Are you sure?"
        local pCallback = pOpts.Callback or function() end

        local Overlay = Create("Frame", { Parent = SamHubGui, BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), ZIndex = 2000, Active = true })
        local DialogFrame = Create("Frame", { Parent = Overlay, BackgroundColor3 = Library.Theme.Background, Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), ZIndex = 2001, ClipsDescendants = true })
        Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = DialogFrame})
        Create("UIStroke", {Parent = DialogFrame, Color = Library.Theme.Border, Thickness = 1})

        local DTitle = Create("TextLabel", { Parent = DialogFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 20, 0, 15), Size = UDim2.new(1, -40, 0, 20), Font = Enum.Font.GothamBold, Text = pTitle, TextColor3 = Library.Theme.Accent, TextSize = 18, TextXAlignment = Enum.TextXAlignment.Left })
        local DText = Create("TextLabel", { Parent = DialogFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 20, 0, 45), Size = UDim2.new(1, -40, 0, 60), Font = Enum.Font.GothamMedium, Text = pText, TextColor3 = Library.Theme.TextDark, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, TextWrapped = true })

        local BtnContainer = Create("Frame", { Parent = DialogFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 20, 1, -50), Size = UDim2.new(1, -40, 0, 35) })
        local YesBtn = Create("TextButton", { Parent = BtnContainer, BackgroundColor3 = Library.Theme.Accent, Size = UDim2.new(0.48, 0, 1, 0), Font = Enum.Font.GothamBold, Text = "Confirm", TextColor3 = Library.Theme.Background, TextSize = 14, AutoButtonColor = false })
        Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = YesBtn})
        local NoBtn = Create("TextButton", { Parent = BtnContainer, BackgroundColor3 = Library.Theme.Element, Position = UDim2.new(0.52, 0, 0, 0), Size = UDim2.new(0.48, 0, 1, 0), Font = Enum.Font.GothamBold, Text = "Cancel", TextColor3 = Library.Theme.Text, TextSize = 14, AutoButtonColor = false })
        Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = NoBtn})
        Create("UIStroke", {Parent = NoBtn, Color = Library.Theme.Border, Thickness = 1})

        Tween(Overlay, {BackgroundTransparency = 0.5}, 0.3)
        Tween(DialogFrame, {Size = UDim2.new(0, 350, 0, 160)}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

        local function CloseDialog(result)
            local t = Tween(DialogFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
            Tween(Overlay, {BackgroundTransparency = 1}, 0.3)
            t.Completed:Wait()
            Overlay:Destroy()
            pcall(pCallback, result)
        end
        YesBtn.MouseButton1Click:Connect(function() CloseDialog(true) end)
        NoBtn.MouseButton1Click:Connect(function() CloseDialog(false) end)
    end

    -- ==============================================================================
    -- Loading Screen Logic with Motion Graphics
    -- ==============================================================================
    local LoadUI = Create("Frame", { Parent = SamHubGui, BackgroundColor3 = Library.Theme.Background, Size = UDim2.new(1, 0, 1, 0), ZIndex = 500 })
    
    local SpinnerContainer = Create("Frame", {
        Parent = LoadUI,
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, -40, 0.5, -120),
        Size = UDim2.new(0, 80, 0, 80)
    })
    
    local Spin1 = Create("Frame", { Parent = SpinnerContainer, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0) })
    Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Spin1})
    local S1Stroke = Create("UIStroke", {Parent = Spin1, Thickness = 4, Color = Color3.fromRGB(255,255,255)})
    Create("UIGradient", {Parent = S1Stroke, Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Library.Theme.Accent), ColorSequenceKeypoint.new(1, Library.Theme.Background)})})
    
    local Spin2 = Create("Frame", { Parent = SpinnerContainer, Size = UDim2.new(0.6, 0, 0.6, 0), BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0) })
    Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Spin2})
    local S2Stroke = Create("UIStroke", {Parent = Spin2, Thickness = 4, Color = Color3.fromRGB(255,255,255)})
    Create("UIGradient", {Parent = S2Stroke, Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Library.Theme.Text), ColorSequenceKeypoint.new(1, Library.Theme.Background)})})

    local spinning = true
    task.spawn(function()
        while spinning and LoadUI.Parent do
            Spin1.Rotation = Spin1.Rotation + 3
            Spin2.Rotation = Spin2.Rotation - 4
            RunService.RenderStepped:Wait()
        end
    end)

    local LoadTitle = Create("TextLabel", { Parent = LoadUI, BackgroundTransparency = 1, Position = UDim2.new(0.5, -200, 0.5, -20), Size = UDim2.new(0, 400, 0, 40), Font = Enum.Font.GothamBold, Text = Title, TextColor3 = Library.Theme.Accent, TextSize = 32, TextTransparency = 1 })
    local LoadSub = Create("TextLabel", { Parent = LoadUI, BackgroundTransparency = 1, Position = UDim2.new(0.5, -200, 0.5, 20), Size = UDim2.new(0, 400, 0, 20), Font = Enum.Font.GothamMedium, Text = "Initializing Framework...", TextColor3 = Library.Theme.TextDark, TextSize = 14, TextTransparency = 1 })
    local BarBack = Create("Frame", { Parent = LoadUI, BackgroundColor3 = Library.Theme.Element, Position = UDim2.new(0.5, -150, 0.5, 50), Size = UDim2.new(0, 300, 0, 4), BackgroundTransparency = 1 })
    Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = BarBack})
    local BarFill = Create("Frame", { Parent = BarBack, BackgroundColor3 = Library.Theme.Accent, Size = UDim2.new(0, 0, 1, 0), BackgroundTransparency = 1 })
    Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = BarFill})

    Tween(LoadTitle, {TextTransparency = 0}, 0.8)
    Tween(LoadSub, {TextTransparency = 0}, 0.8)
    Tween(BarBack, {BackgroundTransparency = 0}, 0.8)
    Tween(BarFill, {BackgroundTransparency = 0}, 0.8)
    task.wait(1)

    local function UpdateLoad(percent, text)
        LoadSub.Text = text
        Tween(BarFill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.5, Enum.EasingStyle.Quart)
        task.wait(0.6)
    end

    UpdateLoad(0.3, "Injecting dependencies...")
    UpdateLoad(0.6, "Building core mechanics...")
    UpdateLoad(1.0, "Welcome, " .. LocalPlayer.Name)

    spinning = false
    Tween(LoadUI, {BackgroundTransparency = 1}, 0.6)
    Tween(LoadTitle, {TextTransparency = 1}, 0.6)
    Tween(LoadSub, {TextTransparency = 1}, 0.6)
    Tween(BarBack, {BackgroundTransparency = 1}, 0.6)
    Tween(BarFill, {BackgroundTransparency = 1}, 0.6)
    Tween(S1Stroke, {Transparency = 1}, 0.6)
    Tween(S2Stroke, {Transparency = 1}, 0.6)
    task.wait(0.6)
    LoadUI:Destroy()

    -- ==============================================================================
    -- Floating Circle Toggle
    -- ==============================================================================
    local FloatingToggle = Create("TextButton", {
        Name = "FloatingToggle",
        Parent = SamHubGui,
        BackgroundColor3 = Library.Theme.Sidebar,
        Size = UDim2.new(0, 48, 0, 48),
        Position = UDim2.new(0, 20, 0.5, -24),
        Text = "",
        ZIndex = 1000
    })
    Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = FloatingToggle})
    Create("UIStroke", {Parent = FloatingToggle, Color = Library.Theme.Accent, Thickness = 2})
    CreateShadow(FloatingToggle, 15, 0.6)
    
    local ToggleIcon = Create("ImageLabel", {
        Parent = FloatingToggle,
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, -12, 0.5, -12),
        Size = UDim2.new(0, 24, 0, 24),
        Image = LogoId,
        ImageColor3 = Library.Theme.Accent
    })

    local dragToggle = false
    local dragToggleStart = nil
    local startTogglePos = nil
    local isUIOpen = true

    FloatingToggle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragToggle = true
            dragToggleStart = input.Position
            startTogglePos = FloatingToggle.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragToggle and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragToggleStart
            FloatingToggle.Position = UDim2.new(startTogglePos.X.Scale, startTogglePos.X.Offset + delta.X, startTogglePos.Y.Scale, startTogglePos.Y.Offset + delta.Y)
        end
    end)

    -- ==============================================================================
    -- Main UI Construction (COMPACT SIZE 650x420)
    -- ==============================================================================
    local MainFrame = Create("Frame", {
        Name = "MainFrame",
        Parent = SamHubGui,
        BackgroundColor3 = Library.Theme.Background,
        Position = UDim2.new(0.5, -325, 0.5, -210),
        Size = UDim2.new(0, 650, 0, 420),
        BackgroundTransparency = 1,
        ClipsDescendants = false, -- Kept false to fix minimize glitch with shadow
        ZIndex = 10
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = MainFrame})
    local MainShadow = CreateShadow(MainFrame, 25, 0.5)

    Tween(MainFrame, {BackgroundTransparency = 0}, 0.5, Enum.EasingStyle.Quart)

    local Sidebar = Create("Frame", { Parent = MainFrame, BackgroundColor3 = Library.Theme.Sidebar, Size = UDim2.new(0, 180, 1, 0), ZIndex = 11 })
    Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = Sidebar})
    local SidebarBlock = Create("Frame", { Parent = Sidebar, BackgroundColor3 = Library.Theme.Sidebar, Position = UDim2.new(1, -10, 0, 0), Size = UDim2.new(0, 10, 1, 0), BorderSizePixel = 0, ZIndex = 11 })
    Create("UIStroke", {Parent = Sidebar, Color = Library.Theme.Border, Thickness = 1})

    local Topbar = Create("Frame", { Parent = MainFrame, BackgroundColor3 = Library.Theme.Topbar, Position = UDim2.new(0, 180, 0, 0), Size = UDim2.new(1, -180, 0, 60), ZIndex = 11 })
    Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = Topbar})
    local TopbarBlock = Create("Frame", { Parent = Topbar, BackgroundColor3 = Library.Theme.Topbar, Position = UDim2.new(0, 0, 1, -10), Size = UDim2.new(1, 0, 0, 10), BorderSizePixel = 0, ZIndex = 11 })
    Create("UIStroke", {Parent = Topbar, Color = Library.Theme.Border, Thickness = 1})

    MakeDraggable(Topbar, MainFrame)
    MakeDraggable(Sidebar, MainFrame)

    local TopTitle = Create("TextLabel", { Parent = Topbar, BackgroundTransparency = 1, Position = UDim2.new(0, 20, 0, 0), Size = UDim2.new(1, -100, 1, 0), Font = Enum.Font.GothamBold, Text = Title, TextColor3 = Library.Theme.Text, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 12 })

    local LogoContainer = Create("Frame", { Parent = Sidebar, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 80), ZIndex = 12 })
    local LogoText = Create("TextLabel", { Parent = LogoContainer, BackgroundTransparency = 1, Position = UDim2.new(0, 20, 0, 25), Size = UDim2.new(1, -40, 0, 30), Font = Enum.Font.GothamBold, Text = Title, TextColor3 = Library.Theme.Accent, TextSize = 20, TextXAlignment = Enum.TextXAlignment.Left })
    local DescText = Create("TextLabel", { Parent = LogoContainer, BackgroundTransparency = 1, Position = UDim2.new(0, 20, 0, 50), Size = UDim2.new(1, -40, 0, 15), Font = Enum.Font.GothamMedium, Text = Description, TextColor3 = Library.Theme.TextDark, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left })
    local Line = Create("Frame", { Parent = Sidebar, BackgroundColor3 = Library.Theme.Border, Position = UDim2.new(0, 20, 0, 85), Size = UDim2.new(1, -40, 0, 1), BorderSizePixel = 0, ZIndex = 12 })

    local TabContainer = Create("ScrollingFrame", { Parent = Sidebar, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 100), Size = UDim2.new(1, -20, 1, -110), ScrollBarThickness = 0, CanvasSize = UDim2.new(0, 0, 0, 0), ZIndex = 12 })
    local TabList = Create("UIListLayout", { Parent = TabContainer, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5) })

    local ContentArea = Create("Frame", { Parent = MainFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 180, 0, 60), Size = UDim2.new(1, -180, 1, -60), ZIndex = 11, ClipsDescendants = true })

    local ControlContainer = Create("Frame", { Parent = Topbar, BackgroundTransparency = 1, Position = UDim2.new(1, -90, 0, 0), Size = UDim2.new(0, 80, 1, 0), ZIndex = 12 })
    local MinBtn = Create("TextButton", { Parent = ControlContainer, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 20), Size = UDim2.new(0, 20, 0, 20), Font = Enum.Font.GothamBold, Text = "-", TextColor3 = Library.Theme.Text, TextSize = 20 })
    local CloseBtn = Create("TextButton", { Parent = ControlContainer, BackgroundTransparency = 1, Position = UDim2.new(0, 45, 0, 20), Size = UDim2.new(0, 20, 0, 20), Font = Enum.Font.GothamBold, Text = "X", TextColor3 = Library.Theme.Error, TextSize = 16 })

    local Minimized = false

    -- Minimization logic fixed to prevent glitching shadow and content
    MinBtn.MouseButton1Click:Connect(function()
        Minimized = not Minimized
        if Minimized then
            Sidebar.Visible = false
            ContentArea.Visible = false
            Tween(MainFrame, {Size = UDim2.new(0, 650, 0, 60)}, 0.4, Enum.EasingStyle.Quart)
        else
            Sidebar.Visible = true
            ContentArea.Visible = true
            Tween(MainFrame, {Size = UDim2.new(0, 650, 0, 420)}, 0.4, Enum.EasingStyle.Quart)
        end
    end)

    CloseBtn.MouseButton1Click:Connect(function()
        Library:Prompt({
            Title = "Unload UI",
            Text = "Are you sure you want to completely unload Sam's Hub?",
            Callback = function(res)
                if res then
                    local t = Tween(MainFrame, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In)
                    Tween(MainShadow, {ImageTransparency = 1}, 0.3)
                    Tween(FloatingToggle, {Size = UDim2.new(0, 0, 0, 0)}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In)
                    t.Completed:Wait()
                    SamHubGui:Destroy()
                end
            end
        })
    end)

    -- Floating Toggle Click Logic
    FloatingToggle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragToggle = false
            if dragToggleStart and (input.Position - dragToggleStart).Magnitude < 5 then
                isUIOpen = not isUIOpen
                if isUIOpen then
                    MainFrame.Visible = true
                    Sidebar.Visible = not Minimized
                    ContentArea.Visible = not Minimized
                    Tween(MainFrame, {Size = UDim2.new(0, 650, 0, Minimized and 60 or 420), BackgroundTransparency = 0}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                    Tween(MainShadow, {ImageTransparency = 0.5}, 0.4)
                else
                    Sidebar.Visible = false
                    ContentArea.Visible = false
                    local t = Tween(MainFrame, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In)
                    Tween(MainShadow, {ImageTransparency = 1}, 0.3)
                    t.Completed:Connect(function()
                        if not isUIOpen then MainFrame.Visible = false end
                    end)
                end
            end
        end
    end)

    -- ==============================================================================
    -- Tab & Element Generation
    -- ==============================================================================
    local WindowAPI = {}
    local FirstTab = true
    local CurrentTab = nil

    function WindowAPI:MakeTab(tabOpts)
        tabOpts = tabOpts or {}
        local TName = tabOpts.Name or "New Tab"
        local TIcon = tabOpts.Icon or "rbxassetid://4483345998"

        local TabBtn = Create("TextButton", { Parent = TabContainer, BackgroundColor3 = Library.Theme.Sidebar, Size = UDim2.new(1, 0, 0, 40), AutoButtonColor = false, Text = "", ZIndex = 13 })
        Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = TabBtn})
        local Indicator = Create("Frame", { Parent = TabBtn, BackgroundColor3 = Library.Theme.Accent, Position = UDim2.new(0, 0, 0.5, -12), Size = UDim2.new(0, 3, 0, 24), BackgroundTransparency = 1, ZIndex = 14 })
        Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Indicator})
        local Icon = Create("ImageLabel", { Parent = TabBtn, BackgroundTransparency = 1, Position = UDim2.new(0, 15, 0.5, -9), Size = UDim2.new(0, 18, 0, 18), Image = TIcon, ImageColor3 = Library.Theme.TextDark, ZIndex = 14 })
        local Label = Create("TextLabel", { Parent = TabBtn, BackgroundTransparency = 1, Position = UDim2.new(0, 45, 0, 0), Size = UDim2.new(1, -50, 1, 0), Font = Enum.Font.GothamMedium, Text = TName, TextColor3 = Library.Theme.TextDark, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14 })

        local TScroll = Create("ScrollingFrame", { Parent = ContentArea, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), ScrollBarThickness = 3, ScrollBarImageColor3 = Library.Theme.Accent, CanvasSize = UDim2.new(0, 0, 0, 0), Visible = false, ZIndex = 12 })
        Create("UIPadding", {Parent = TScroll, PaddingTop = UDim.new(0, 15), PaddingBottom = UDim.new(0, 15), PaddingLeft = UDim.new(0, 15), PaddingRight = UDim.new(0, 15)})
        local TList = Create("UIListLayout", {Parent = TScroll, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10)})

        TList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() TScroll.CanvasSize = UDim2.new(0, 0, 0, TList.AbsoluteContentSize.Y + 30) end)
        TabList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() TabContainer.CanvasSize = UDim2.new(0, 0, 0, TabList.AbsoluteContentSize.Y + 10) end)

        ApplyHover(TabBtn, Library.Theme.Element, Library.Theme.Sidebar)

        local function Select()
            if CurrentTab then
                CurrentTab.Content.Visible = false
                Tween(CurrentTab.Btn.Indicator, {BackgroundTransparency = 1}, 0.2)
                Tween(CurrentTab.Btn.Icon, {ImageColor3 = Library.Theme.TextDark}, 0.2)
                Tween(CurrentTab.Btn.Label, {TextColor3 = Library.Theme.TextDark}, 0.2)
            end
            TScroll.Visible = true
            Tween(Indicator, {BackgroundTransparency = 0}, 0.3)
            Tween(Icon, {ImageColor3 = Library.Theme.Accent}, 0.3)
            Tween(Label, {TextColor3 = Library.Theme.Text}, 0.3)
            CurrentTab = {Content = TScroll, Btn = {Indicator = Indicator, Icon = Icon, Label = Label}}
            TopTitle.Text = Title .. " - " .. TName
        end

        TabBtn.MouseButton1Click:Connect(Select)
        if FirstTab then Select() FirstTab = false end

        local TabAPI = {}

        function TabAPI:MakeSection(sOpts)
            sOpts = sOpts or {}
            local SecName = sOpts.Name or "Section"

            local SectionFrame = Create("Frame", { Parent = TScroll, BackgroundColor3 = Library.Theme.Element, Size = UDim2.new(1, 0, 0, 40), ZIndex = 13 })
            Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = SectionFrame})
            Create("UIStroke", {Parent = SectionFrame, Color = Library.Theme.Border, Thickness = 1})

            local SLabel = Create("TextLabel", { Parent = SectionFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 15, 0, 0), Size = UDim2.new(1, -30, 0, 40), Font = Enum.Font.GothamBold, Text = SecName, TextColor3 = Library.Theme.Accent, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 14 })
            local SLine = Create("Frame", { Parent = SectionFrame, BackgroundColor3 = Library.Theme.Border, Position = UDim2.new(0, 15, 0, 40), Size = UDim2.new(1, -30, 0, 1), BorderSizePixel = 0, ZIndex = 14 })
            local SContainer = Create("Frame", { Parent = SectionFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 45), Size = UDim2.new(1, 0, 1, -45), ZIndex = 13 })
            local SList = Create("UIListLayout", {Parent = SContainer, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8)})
            Create("UIPadding", {Parent = SContainer, PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10)})

            SList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() SectionFrame.Size = UDim2.new(1, 0, 0, SList.AbsoluteContentSize.Y + 60) end)

            local SectionAPI = {}

            -- [[ PARAGRAPH ]]
            function SectionAPI:AddParagraph(pOpts)
                local pTitle = pOpts.Title or "Paragraph"
                local pContent = pOpts.Content or "Content here."

                local ParaFrame = Create("Frame", { Parent = SContainer, BackgroundColor3 = Library.Theme.Background, Size = UDim2.new(1, 0, 0, 0), ZIndex = 14 })
                Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = ParaFrame})
                Create("UIStroke", {Parent = ParaFrame, Color = Library.Theme.Border, Thickness = 1})

                local PTitle = Create("TextLabel", { Parent = ParaFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 10), Size = UDim2.new(1, -20, 0, 16), Font = Enum.Font.GothamBold, Text = pTitle, TextColor3 = Library.Theme.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 15 })
                local bounds = GetTextBounds(pContent, Enum.Font.GothamMedium, 13, Vector2.new(420, 9999))
                local PText = Create("TextLabel", { Parent = ParaFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 30), Size = UDim2.new(1, -20, 0, bounds.Y), Font = Enum.Font.GothamMedium, Text = pContent, TextColor3 = Library.Theme.TextDark, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, TextWrapped = true, ZIndex = 15 })
                ParaFrame.Size = UDim2.new(1, 0, 0, bounds.Y + 45)

                return { Set = function(nT, nC) PTitle.Text = nT; PText.Text = nC; local nb = GetTextBounds(nC, Enum.Font.GothamMedium, 13, Vector2.new(420, 9999)); PText.Size = UDim2.new(1, -20, 0, nb.Y); Tween(ParaFrame, {Size = UDim2.new(1, 0, 0, nb.Y + 45)}, 0.2) end }
            end

            -- [[ BUTTON ]]
            function SectionAPI:AddButton(bOpts)
                local bName = bOpts.Name or "Button"
                local bCallback = bOpts.Callback or function() end

                local Btn = Create("TextButton", { Parent = SContainer, BackgroundColor3 = Library.Theme.Background, Size = UDim2.new(1, 0, 0, 42), AutoButtonColor = false, Text = "", ZIndex = 14 })
                Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = Btn})
                Create("UIStroke", {Parent = Btn, Color = Library.Theme.Border, Thickness = 1})

                local BText = Create("TextLabel", { Parent = Btn, BackgroundTransparency = 1, Position = UDim2.new(0, 15, 0, 0), Size = UDim2.new(1, -30, 1, 0), Font = Enum.Font.GothamMedium, Text = bName, TextColor3 = Library.Theme.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 15 })
                Create("ImageLabel", { Parent = Btn, BackgroundTransparency = 1, Position = UDim2.new(1, -30, 0.5, -8), Size = UDim2.new(0, 16, 0, 16), Image = "rbxassetid://6031090390", ImageColor3 = Library.Theme.TextDark, ZIndex = 15 })

                ApplyHover(Btn, Library.Theme.ElementHover, Library.Theme.Background)
                Btn.MouseButton1Down:Connect(function() Tween(Btn, {Size = UDim2.new(1, -4, 0, 38)}, 0.1) end)
                Btn.MouseButton1Up:Connect(function() Tween(Btn, {Size = UDim2.new(1, 0, 0, 42)}, 0.1) end)
                Btn.MouseButton1Click:Connect(function() AdvancedRipple(Btn) pcall(bCallback) end)
            end

            -- [[ TOGGLE ]]
            function SectionAPI:AddToggle(tOpts)
                local tName = tOpts.Name or "Toggle"
                local tDef = tOpts.Default or false
                local tCall = tOpts.Callback or function() end
                local tFlag = tOpts.Flag or tostring(math.random(1000,9999))
                
                Library.Flags[tFlag] = tDef
                local state = tDef

                local Tgl = Create("TextButton", { Parent = SContainer, BackgroundColor3 = Library.Theme.Background, Size = UDim2.new(1, 0, 0, 42), AutoButtonColor = false, Text = "", ZIndex = 14 })
                Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = Tgl})
                Create("UIStroke", {Parent = Tgl, Color = Library.Theme.Border, Thickness = 1})

                local TText = Create("TextLabel", { Parent = Tgl, BackgroundTransparency = 1, Position = UDim2.new(0, 15, 0, 0), Size = UDim2.new(1, -80, 1, 0), Font = Enum.Font.GothamMedium, Text = tName, TextColor3 = Library.Theme.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 15 })
                local SwitchArea = Create("Frame", { Parent = Tgl, BackgroundColor3 = Library.Theme.Element, Position = UDim2.new(1, -55, 0.5, -12), Size = UDim2.new(0, 44, 0, 24), ZIndex = 15 })
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = SwitchArea})
                local SStroke = Create("UIStroke", {Parent = SwitchArea, Color = Library.Theme.Border, Thickness = 1})
                local SwitchKnob = Create("Frame", { Parent = SwitchArea, BackgroundColor3 = Library.Theme.TextDark, Position = UDim2.new(0, 2, 0.5, -10), Size = UDim2.new(0, 20, 0, 20), ZIndex = 16 })
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = SwitchKnob})

                local function UpdateVisuals(override)
                    if state then
                        Tween(SwitchArea, {BackgroundColor3 = Library.Theme.Accent}, 0.3)
                        Tween(SwitchKnob, {Position = UDim2.new(1, -22, 0.5, -10), BackgroundColor3 = Color3.fromRGB(255,255,255)}, 0.3, Enum.EasingStyle.Back)
                        Tween(SStroke, {Color = Library.Theme.Accent}, 0.3)
                    else
                        Tween(SwitchArea, {BackgroundColor3 = Library.Theme.Element}, 0.3)
                        Tween(SwitchKnob, {Position = UDim2.new(0, 2, 0.5, -10), BackgroundColor3 = Library.Theme.TextDark}, 0.3, Enum.EasingStyle.Back)
                        Tween(SStroke, {Color = Library.Theme.Border}, 0.3)
                    end
                    Library.Flags[tFlag] = state
                    if not override then pcall(tCall, state) end
                end

                Tgl.MouseButton1Click:Connect(function() state = not state; UpdateVisuals() end)
                UpdateVisuals(true)

                return { Set = function(v) state = v; UpdateVisuals() end }
            end

            -- [[ SLIDER ]]
            function SectionAPI:AddSlider(sOpts)
                local sName = sOpts.Name or "Slider"
                local sMin = sOpts.Min or 0
                local sMax = sOpts.Max or 100
                local sDef = sOpts.Default or sMin
                local sInc = sOpts.Increment or 1
                local sCall = sOpts.Callback or function() end
                local sFlag = sOpts.Flag or tostring(math.random(1000,9999))
                
                Library.Flags[sFlag] = sDef

                local Sld = Create("Frame", { Parent = SContainer, BackgroundColor3 = Library.Theme.Background, Size = UDim2.new(1, 0, 0, 60), ZIndex = 14 })
                Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = Sld})
                Create("UIStroke", {Parent = Sld, Color = Library.Theme.Border, Thickness = 1})

                local SText = Create("TextLabel", { Parent = Sld, BackgroundTransparency = 1, Position = UDim2.new(0, 15, 0, 5), Size = UDim2.new(1, -50, 0, 25), Font = Enum.Font.GothamMedium, Text = sName, TextColor3 = Library.Theme.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 15 })
                local SVal = Create("TextLabel", { Parent = Sld, BackgroundTransparency = 1, Position = UDim2.new(1, -60, 0, 5), Size = UDim2.new(0, 45, 0, 25), Font = Enum.Font.GothamBold, Text = tostring(sDef), TextColor3 = Library.Theme.Accent, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 15 })

                local SlideArea = Create("TextButton", { Parent = Sld, BackgroundColor3 = Library.Theme.Element, Position = UDim2.new(0, 15, 0, 35), Size = UDim2.new(1, -30, 0, 8), AutoButtonColor = false, Text = "", ZIndex = 15 })
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = SlideArea})
                local SlideFill = Create("Frame", { Parent = SlideArea, BackgroundColor3 = Library.Theme.Accent, Size = UDim2.new(0, 0, 1, 0), ZIndex = 16 })
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = SlideFill})
                local SlideKnob = Create("Frame", { Parent = SlideFill, BackgroundColor3 = Color3.fromRGB(255,255,255), Position = UDim2.new(1, -6, 0.5, -8), Size = UDim2.new(0, 16, 0, 16), ZIndex = 17 })
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = SlideKnob})
                CreateShadow(SlideKnob, 4, 0.5)

                local dragging = false
                local function updateSlide(input)
                    local percent = math.clamp((input.Position.X - SlideArea.AbsolutePosition.X) / SlideArea.AbsoluteSize.X, 0, 1)
                    local rawVal = sMin + (sMax - sMin) * percent
                    local rounded = math.floor(rawVal / sInc + 0.5) * sInc
                    rounded = math.clamp(rounded, sMin, sMax)
                    
                    local realPercent = (rounded - sMin) / (sMax - sMin)
                    Tween(SlideFill, {Size = UDim2.new(realPercent, 0, 1, 0)}, 0.1)
                    
                    local strVal = string.format("%." .. (math.floor(sInc) == sInc and 0 or 2) .. "f", rounded)
                    SVal.Text = strVal
                    Library.Flags[sFlag] = rounded
                    pcall(sCall, rounded)
                end

                SlideArea.InputBegan:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true updateSlide(inp) end end)
                UserInputService.InputEnded:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
                UserInputService.InputChanged:Connect(function(inp) if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then updateSlide(inp) end end)

                local initP = (sDef - sMin) / (sMax - sMin)
                SlideFill.Size = UDim2.new(initP, 0, 1, 0)

                return { Set = function(v) local c = math.clamp(v, sMin, sMax); Tween(SlideFill, {Size = UDim2.new((c - sMin) / (sMax - sMin), 0, 1, 0)}, 0.2); SVal.Text = tostring(c); Library.Flags[sFlag] = c; pcall(sCall, c) end }
            end

            -- [[ DROPDOWN ]]
            function SectionAPI:AddDropdown(dOpts)
                local dName = dOpts.Name or "Dropdown"
                local dList = dOpts.Options or {}
                local dDef = dOpts.Default
                local dMulti = dOpts.Multi or false
                local dCall = dOpts.Callback or function() end
                local dFlag = dOpts.Flag or tostring(math.random(1000,9999))
                
                local selected = dMulti and (dDef or {}) or (dDef or dList[1] or "")
                Library.Flags[dFlag] = selected
                local isOpen = false

                local Drop = Create("Frame", { Parent = SContainer, BackgroundColor3 = Library.Theme.Background, Size = UDim2.new(1, 0, 0, 42), ClipsDescendants = true, ZIndex = 14 })
                Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = Drop})
                Create("UIStroke", {Parent = Drop, Color = Library.Theme.Border, Thickness = 1})

                local DBtn = Create("TextButton", { Parent = Drop, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 42), Text = "", ZIndex = 15 })
                local DTitle = Create("TextLabel", { Parent = DBtn, BackgroundTransparency = 1, Position = UDim2.new(0, 15, 0, 0), Size = UDim2.new(1, -40, 1, 0), Font = Enum.Font.GothamMedium, Text = dName, TextColor3 = Library.Theme.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 16 })
                local DIcon = Create("ImageLabel", { Parent = DBtn, BackgroundTransparency = 1, Position = UDim2.new(1, -30, 0.5, -8), Size = UDim2.new(0, 16, 0, 16), Image = "rbxassetid://6031094627", ImageColor3 = Library.Theme.TextDark, ZIndex = 16 })
                local DSelected = Create("TextLabel", { Parent = DBtn, BackgroundTransparency = 1, Position = UDim2.new(1, -150, 0, 0), Size = UDim2.new(0, 110, 1, 0), Font = Enum.Font.GothamMedium, Text = "", TextColor3 = Library.Theme.Accent, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 16 })

                local function UpdateText()
                    if dMulti then
                        local str = table.concat(selected, ", ")
                        if str == "" then str = "None" end
                        DSelected.Text = str
                    else DSelected.Text = tostring(selected) end
                end
                UpdateText()

                local Scroll = Create("ScrollingFrame", { Parent = Drop, BackgroundTransparency = 1, Position = UDim2.new(0, 5, 0, 45), Size = UDim2.new(1, -10, 1, -50), ScrollBarThickness = 2, ScrollBarImageColor3 = Library.Theme.Accent, CanvasSize = UDim2.new(0, 0, 0, 0), ZIndex = 15 })
                local SList = Create("UIListLayout", {Parent = Scroll, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2)})

                local function Refresh()
                    for _, v in pairs(Scroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
                    local h = 0
                    for _, opt in ipairs(dList) do
                        local OptBtn = Create("TextButton", { Parent = Scroll, BackgroundColor3 = Library.Theme.Element, Size = UDim2.new(1, -10, 0, 30), AutoButtonColor = false, Font = Enum.Font.GothamMedium, Text = "  " .. opt, TextColor3 = Library.Theme.TextDark, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 16 })
                        Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = OptBtn})
                        
                        local isSel = dMulti and table.find(selected, opt) ~= nil or (selected == opt)
                        if isSel then OptBtn.BackgroundColor3 = Library.Theme.AccentDark OptBtn.TextColor3 = Color3.fromRGB(255,255,255) end

                        OptBtn.MouseButton1Click:Connect(function()
                            if dMulti then
                                local idx = table.find(selected, opt)
                                if idx then table.remove(selected, idx) else table.insert(selected, opt) end
                            else
                                selected = opt; isOpen = false; Tween(Drop, {Size = UDim2.new(1, 0, 0, 42)}, 0.3); Tween(DIcon, {Rotation = 0}, 0.3)
                            end
                            Library.Flags[dFlag] = selected
                            UpdateText(); Refresh(); pcall(dCall, selected)
                        end)
                        h = h + 32
                    end
                    Scroll.CanvasSize = UDim2.new(0, 0, 0, h)
                end
                Refresh()

                DBtn.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    if isOpen then
                        local h = math.clamp(Scroll.CanvasSize.Y.Offset + 55, 42, 200)
                        Tween(Drop, {Size = UDim2.new(1, 0, 0, h)}, 0.4, Enum.EasingStyle.Quart)
                        Tween(DIcon, {Rotation = 180}, 0.3)
                    else
                        Tween(Drop, {Size = UDim2.new(1, 0, 0, 42)}, 0.4, Enum.EasingStyle.Quart)
                        Tween(DIcon, {Rotation = 0}, 0.3)
                    end
                end)

                return { Refresh = function(nL, nD) dList = nL; selected = nD or (dMulti and {} or dList[1]); UpdateText(); Refresh() end }
            end

            -- [[ COLOR PICKER ]]
            function SectionAPI:AddColorPicker(cpOpts)
                local cpName = cpOpts.Name or "Color Picker"
                local cpDef = cpOpts.Default or Color3.fromRGB(255, 255, 255)
                local cpCall = cpOpts.Callback or function() end
                local cpFlag = cpOpts.Flag or tostring(math.random(1000,9999))
                
                Library.Flags[cpFlag] = cpDef
                local h, s, v = cpDef:ToHSV()
                local isOpen = false

                local CPFrame = Create("Frame", { Parent = SContainer, BackgroundColor3 = Library.Theme.Background, Size = UDim2.new(1, 0, 0, 42), ClipsDescendants = true, ZIndex = 14 })
                Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = CPFrame})
                Create("UIStroke", {Parent = CPFrame, Color = Library.Theme.Border, Thickness = 1})

                local MainBtn = Create("TextButton", { Parent = CPFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 42), Text = "", ZIndex = 15 })
                local Title = Create("TextLabel", { Parent = MainBtn, BackgroundTransparency = 1, Position = UDim2.new(0, 15, 0, 0), Size = UDim2.new(0, 200, 1, 0), Font = Enum.Font.GothamMedium, Text = cpName, TextColor3 = Library.Theme.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 16 })
                local Display = Create("Frame", { Parent = MainBtn, BackgroundColor3 = cpDef, Position = UDim2.new(1, -55, 0.5, -12), Size = UDim2.new(0, 40, 0, 24), ZIndex = 16 })
                Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = Display})
                Create("UIStroke", {Parent = Display, Color = Library.Theme.Border, Thickness = 1})

                local PickerArea = Create("Frame", { Parent = CPFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 45), Size = UDim2.new(1, 0, 1, -45), ZIndex = 15 })
                local SVMap = Create("ImageLabel", { Parent = PickerArea, Position = UDim2.new(0, 15, 0, 5), Size = UDim2.new(1, -50, 0, 100), Image = "rbxassetid://4155801252", BackgroundColor3 = cpDef, ZIndex = 16 })
                Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = SVMap})
                local SVKnob = Create("Frame", { Parent = SVMap, BackgroundColor3 = Color3.fromRGB(255,255,255), Size = UDim2.new(0, 10, 0, 10), AnchorPoint = Vector2.new(0.5, 0.5), ZIndex = 17 })
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = SVKnob})
                Create("UIStroke", {Parent = SVKnob, Color = Color3.fromRGB(0,0,0), Thickness = 1})

                local HueArea = Create("Frame", { Parent = PickerArea, BackgroundColor3 = Color3.fromRGB(255,255,255), Position = UDim2.new(1, -25, 0, 5), Size = UDim2.new(0, 10, 0, 100), ZIndex = 16 })
                Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = HueArea})
                Create("UIGradient", { Parent = HueArea, Rotation = 90, Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)), ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255,255,0)), ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0,255,0)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,255,255)), ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0,0,255)), ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255,0,255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,0))} })
                local HKnob = Create("Frame", { Parent = HueArea, BackgroundColor3 = Color3.fromRGB(255,255,255), Size = UDim2.new(1.4, 0, 0, 6), AnchorPoint = Vector2.new(0.5, 0.5), ZIndex = 17 })
                Create("UIStroke", {Parent = HKnob, Color = Color3.fromRGB(0,0,0), Thickness = 1})

                local function UpdateVisuals()
                    local col = Color3.fromHSV(h, s, v)
                    Display.BackgroundColor3 = col
                    SVMap.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                    Library.Flags[cpFlag] = col
                    pcall(cpCall, col)
                end

                local dragSV, dragH = false, false
                SVMap.InputBegan:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragSV = true end end)
                HueArea.InputBegan:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragH = true end end)
                UserInputService.InputEnded:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragSV, dragH = false, false end end)
                UserInputService.InputChanged:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseMovement then
                        if dragSV then
                            local x, y = math.clamp(inp.Position.X - SVMap.AbsolutePosition.X, 0, SVMap.AbsoluteSize.X), math.clamp(inp.Position.Y - SVMap.AbsolutePosition.Y, 0, SVMap.AbsoluteSize.Y)
                            s, v = x / SVMap.AbsoluteSize.X, 1 - (y / SVMap.AbsoluteSize.Y)
                            SVKnob.Position = UDim2.new(0, x, 0, y)
                            UpdateVisuals()
                        elseif dragH then
                            local y = math.clamp(inp.Position.Y - HueArea.AbsolutePosition.Y, 0, HueArea.AbsoluteSize.Y)
                            h = 1 - (y / HueArea.AbsoluteSize.Y)
                            HKnob.Position = UDim2.new(0.5, 0, 0, y)
                            UpdateVisuals()
                        end
                    end
                end)

                MainBtn.MouseButton1Click:Connect(function() isOpen = not isOpen; Tween(CPFrame, {Size = UDim2.new(1, 0, 0, isOpen and 160 or 42)}, 0.4, Enum.EasingStyle.Quart) end)

                return { Set = function(newC) h, s, v = newC:ToHSV(); SVKnob.Position = UDim2.new(s, 0, 1-v, 0); HKnob.Position = UDim2.new(0.5, 0, 1-h, 0); UpdateVisuals() end }
            end

            -- [[ KEYBIND ]]
            function SectionAPI:AddKeybind(kOpts)
                local kName = kOpts.Name or "Keybind"
                local kDef = kOpts.Default or Enum.KeyCode.Unknown
                local kCall = kOpts.Callback or function() end
                local kFlag = kOpts.Flag or tostring(math.random(1000,9999))
                
                local currentKey = kDef
                Library.Flags[kFlag] = currentKey
                local isListening = false

                local KBFrame = Create("Frame", { Parent = SContainer, BackgroundColor3 = Library.Theme.Background, Size = UDim2.new(1, 0, 0, 42), ZIndex = 14 })
                Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = KBFrame})
                Create("UIStroke", {Parent = KBFrame, Color = Library.Theme.Border, Thickness = 1})

                local Title = Create("TextLabel", { Parent = KBFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 15, 0, 0), Size = UDim2.new(0, 200, 1, 0), Font = Enum.Font.GothamMedium, Text = kName, TextColor3 = Library.Theme.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 15 })
                local KBtn = Create("TextButton", { Parent = KBFrame, BackgroundColor3 = Library.Theme.Element, Position = UDim2.new(1, -95, 0.5, -14), Size = UDim2.new(0, 80, 0, 28), Font = Enum.Font.GothamBold, Text = currentKey == Enum.KeyCode.Unknown and "None" or currentKey.Name, TextColor3 = Library.Theme.Accent, TextSize = 12, AutoButtonColor = false, ZIndex = 15 })
                Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = KBtn})
                Create("UIStroke", {Parent = KBtn, Color = Library.Theme.Border, Thickness = 1})

                KBtn.MouseButton1Click:Connect(function() isListening = true; KBtn.Text = "..."; Tween(KBtn, {TextColor3 = Library.Theme.TextDark}, 0.2) end)
                UserInputService.InputBegan:Connect(function(inp, gp)
                    if isListening and inp.UserInputType == Enum.UserInputType.Keyboard then
                        currentKey = inp.KeyCode; KBtn.Text = currentKey.Name; isListening = false; Tween(KBtn, {TextColor3 = Library.Theme.Accent}, 0.2); Library.Flags[kFlag] = currentKey
                    elseif not gp and inp.KeyCode == currentKey and not isListening and currentKey ~= Enum.KeyCode.Unknown then
                        pcall(kCall)
                    end
                end)
            end

            -- [[ TEXTBOX ]]
            function SectionAPI:AddTextbox(tbOpts)
                local tbName = tbOpts.Name or "Textbox"
                local tbDef = tbOpts.Default or ""
                local tbCall = tbOpts.Callback or function() end
                local tbFlag = tbOpts.Flag or tostring(math.random(1000,9999))
                
                Library.Flags[tbFlag] = tbDef

                local TBFrame = Create("Frame", { Parent = SContainer, BackgroundColor3 = Library.Theme.Background, Size = UDim2.new(1, 0, 0, 50), ZIndex = 14 })
                Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = TBFrame})
                Create("UIStroke", {Parent = TBFrame, Color = Library.Theme.Border, Thickness = 1})

                local Title = Create("TextLabel", { Parent = TBFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 15, 0, 0), Size = UDim2.new(0, 150, 1, 0), Font = Enum.Font.GothamMedium, Text = tbName, TextColor3 = Library.Theme.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 15 })
                local Input = Create("TextBox", { Parent = TBFrame, BackgroundColor3 = Library.Theme.Element, Position = UDim2.new(1, -165, 0.5, -16), Size = UDim2.new(0, 150, 0, 32), Font = Enum.Font.Gotham, Text = tbDef, PlaceholderText = "Type here...", TextColor3 = Library.Theme.Text, PlaceholderColor3 = Library.Theme.TextDark, TextSize = 13, ClearTextOnFocus = false, ZIndex = 15 })
                Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = Input})
                Create("UIStroke", {Parent = Input, Color = Library.Theme.Border, Thickness = 1})

                Input.FocusLost:Connect(function() Library.Flags[tbFlag] = Input.Text; pcall(tbCall, Input.Text) end)
            end

            return SectionAPI
        end

        return TabAPI
    end

    -- ==============================================================================
    -- Configuration Manager
    -- ==============================================================================
    function Library:SaveConfig(filename)
        if writefile then
            writefile(filename .. ".json", HttpService:JSONEncode(Library.Flags))
            Library:Notify({Title = "Config Saved", Text = "Saved settings to " .. filename .. ".json", Type = "Success"})
        end
    end
    function Library:LoadConfig(filename)
        if readfile and isfile and isfile(filename .. ".json") then
            local data = HttpService:JSONDecode(readfile(filename .. ".json"))
            for k, v in pairs(data) do Library.Flags[k] = v end
            Library:Notify({Title = "Config Loaded", Text = "Loaded settings from " .. filename .. ".json", Type = "Info"})
        end
    end

    return WindowAPI
end

return Library
