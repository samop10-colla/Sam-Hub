-- // ENI'S MONOLITHIC FRAMEWORK FOR LO
-- // DO NOT NAME THIS SAM'S HUB. PLEASE.
-- // Version: 2.0 (Massive Scale Edition)

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TextService = game:GetService("TextService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- // Protection & Environment Checks
local ProtectGui = protectgui or (syn and syn.protect_gui) or function() end
local GetHUI = gethui or function() return CoreGui end

-- // Core Library Table
local EniLibrary = {
    Version = "2.0.0",
    Windows = {},
    Connections = {},
    Flags = {},
    Theme = {
        Background = Color3.fromRGB(15, 15, 18),
        Container = Color3.fromRGB(22, 22, 26),
        Topbar = Color3.fromRGB(10, 10, 12),
        Accent = Color3.fromRGB(0, 255, 255), -- Cyan
        Text = Color3.fromRGB(240, 240, 240),
        TextDark = Color3.fromRGB(150, 150, 150),
        Hover = Color3.fromRGB(30, 30, 35),
        Border = Color3.fromRGB(40, 40, 45),
        DropdownFrame = Color3.fromRGB(20, 20, 24),
        SliderBackground = Color3.fromRGB(10, 10, 12),
        NotificationBG = Color3.fromRGB(20, 20, 25)
    },
    Settings = {
        Font = Enum.Font.Gotham,
        BoldFont = Enum.Font.GothamBold,
        SemiBoldFont = Enum.Font.GothamSemibold,
        TweenSpeed = 0.2
    }
}

-- // Massive Utility Module
local Utility = {}

function Utility:Create(className, properties)
    local instance = Instance.new(className)
    for k, v in pairs(properties) do
        if k ~= "Parent" then
            instance[k] = v
        end
    end
    if properties.Parent then
        instance.Parent = properties.Parent
    end
    return instance
end

function Utility:Tween(instance, properties, duration)
    local tweenInfo = TweenInfo.new(duration or EniLibrary.Settings.TweenSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

function Utility:MakeDraggable(topbarObject, object)
    local Dragging = nil
    local DragInput = nil
    local DragStart = nil
    local StartPosition = nil

    local function Update(input)
        local Delta = input.Position - DragStart
        local pos = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
        Utility:Tween(object, {Position = pos}, 0.1)
    end

    topbarObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = input.Position
            StartPosition = object.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)

    topbarObject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            DragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            Update(input)
        end
    end)
end

function Utility:GetTextBounds(text, font, size, resolution)
    local bounds = TextService:GetTextSize(text, size, font, resolution or Vector2.new(9999, 9999))
    return bounds
end

function Utility:Round(number, float)
    return float * math.floor(number / float + 0.5)
end

-- // Config System
local ConfigManager = {}
ConfigManager.Folder = "EniFramework_Configs"

function ConfigManager:Init()
    if isfolder and not isfolder(ConfigManager.Folder) then
        makefolder(ConfigManager.Folder)
    end
end

function ConfigManager:Save(name)
    if not writefile then return end
    local configPath = ConfigManager.Folder .. "/" .. name .. ".json"
    local data = HttpService:JSONEncode(EniLibrary.Flags)
    writefile(configPath, data)
end

function ConfigManager:Load(name)
    if not readfile then return end
    local configPath = ConfigManager.Folder .. "/" .. name .. ".json"
    if isfile(configPath) then
        local data = HttpService:JSONDecode(readfile(configPath))
        for key, value in pairs(data) do
            if EniLibrary.Flags[key] then
                -- Complex callback trigger logic would go here depending on the UI element type
                EniLibrary.Flags[key] = value
            end
        end
    end
end

ConfigManager:Init()

-- // Notification System
local NotificationSystem = {
    Container = nil
}

function NotificationSystem:Init()
    local ScreenGui = Utility:Create("ScreenGui", {
        Name = "Eni_Notifications",
        Parent = GetHUI(),
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    ProtectGui(ScreenGui)

    self.Container = Utility:Create("Frame", {
        Name = "NotifyContainer",
        Parent = ScreenGui,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -320, 1, -20),
        Size = UDim2.new(0, 300, 1, -20),
        AnchorPoint = Vector2.new(0, 1)
    })

    Utility:Create("UIListLayout", {
        Parent = self.Container,
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Padding = UDim.new(0, 10)
    })
end

function EniLibrary:Notify(options)
    options = options or {}
    local Title = options.Title or "Notification"
    local Content = options.Content or "Message here."
    local Duration = options.Duration or 5

    if not NotificationSystem.Container then
        NotificationSystem:Init()
    end

    local NotifyFrame = Utility:Create("Frame", {
        Parent = NotificationSystem.Container,
        BackgroundColor3 = EniLibrary.Theme.NotificationBG,
        Size = UDim2.new(1, 0, 0, 0), -- Animated below
        ClipsDescendants = true,
        BackgroundTransparency = 1
    })

    Utility:Create("UICorner", { Parent = NotifyFrame, CornerRadius = UDim.new(0, 6) })
    Utility:Create("UIStroke", { Parent = NotifyFrame, Color = EniLibrary.Theme.Border, Thickness = 1 })

    local NotifyTitle = Utility:Create("TextLabel", {
        Parent = NotifyFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 10),
        Size = UDim2.new(1, -30, 0, 20),
        Font = EniLibrary.Settings.BoldFont,
        Text = Title,
        TextColor3 = EniLibrary.Theme.Accent,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTransparency = 1
    })

    local NotifyDesc = Utility:Create("TextLabel", {
        Parent = NotifyFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 30),
        Size = UDim2.new(1, -30, 0, 20),
        Font = EniLibrary.Settings.Font,
        Text = Content,
        TextColor3 = EniLibrary.Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        TextTransparency = 1
    })

    local AccentBar = Utility:Create("Frame", {
        Parent = NotifyFrame,
        BackgroundColor3 = EniLibrary.Theme.Accent,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, 3, 1, 0),
        BorderSizePixel = 0,
        BackgroundTransparency = 1
    })

    -- Calculate height
    local textBounds = Utility:GetTextBounds(Content, EniLibrary.Settings.Font, 13, Vector2.new(270, 9999))
    local targetHeight = 40 + textBounds.Y

    -- Spawn animation
    Utility:Tween(NotifyFrame, {Size = UDim2.new(1, 0, 0, targetHeight), BackgroundTransparency = 0}, 0.3)
    Utility:Tween(NotifyTitle, {TextTransparency = 0}, 0.3)
    Utility:Tween(NotifyDesc, {TextTransparency = 0}, 0.3)
    Utility:Tween(AccentBar, {BackgroundTransparency = 0}, 0.3)

    task.spawn(function()
        task.wait(Duration)
        Utility:Tween(NotifyFrame, {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1}, 0.3)
        Utility:Tween(NotifyTitle, {TextTransparency = 1}, 0.3)
        Utility:Tween(NotifyDesc, {TextTransparency = 1}, 0.3)
        Utility:Tween(AccentBar, {BackgroundTransparency = 1}, 0.3)
        task.wait(0.3)
        NotifyFrame:Destroy()
    end)
end

-- // Core Window Construction
function EniLibrary:CreateWindow(options)
    options = options or {}
    local WindowName = options.Name or "ENI'S UI"
    local WindowSize = options.Size or UDim2.new(0, 650, 0, 450)
    local WindowConfig = options.ConfigName or "DefaultConfig"

    -- Clean old GUI instances to prevent bloat
    for _, v in pairs(CoreGui:GetChildren()) do
        if v.Name == "EniFramework_" .. WindowName then
            v:Destroy()
        end
    end

    local ScreenGui = Utility:Create("ScreenGui", {
        Name = "EniFramework_" .. WindowName,
        Parent = GetHUI(),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    ProtectGui(ScreenGui)

    local MainFrame = Utility:Create("Frame", {
        Name = "MainFrame",
        Parent = ScreenGui,
        BackgroundColor3 = EniLibrary.Theme.Background,
        Position = UDim2.new(0.5, -WindowSize.X.Offset/2, 0.5, -WindowSize.Y.Offset/2),
        Size = WindowSize,
        ClipsDescendants = true
    })

    Utility:Create("UICorner", { Parent = MainFrame, CornerRadius = UDim.new(0, 8) })
    Utility:Create("UIStroke", { Parent = MainFrame, Color = EniLibrary.Theme.Accent, Thickness = 1, Transparency = 0.5 })

    local DropShadow = Utility:Create("ImageLabel", {
        Name = "DropShadow",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, -15, 0, -15),
        Size = UDim2.new(1, 30, 1, 30),
        ZIndex = -1,
        Image = "rbxassetid://5028857472",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.4,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(24, 24, 276, 276)
    })

    local Topbar = Utility:Create("Frame", {
        Name = "Topbar",
        Parent = MainFrame,
        BackgroundColor3 = EniLibrary.Theme.Topbar,
        Size = UDim2.new(1, 0, 0, 45),
        BorderSizePixel = 0
    })

    Utility:Create("UICorner", { Parent = Topbar, CornerRadius = UDim.new(0, 8) })
    
    local TopbarFix = Utility:Create("Frame", {
        Parent = Topbar,
        BackgroundColor3 = EniLibrary.Theme.Topbar,
        Position = UDim2.new(0, 0, 1, -8),
        Size = UDim2.new(1, 0, 0, 8),
        BorderSizePixel = 0
    })

    local Title = Utility:Create("TextLabel", {
        Name = "Title",
        Parent = Topbar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 20, 0, 0),
        Size = UDim2.new(1, -40, 1, 0),
        Font = EniLibrary.Settings.BoldFont,
        Text = WindowName,
        TextColor3 = EniLibrary.Theme.Accent,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local AccentLine = Utility:Create("Frame", {
        Name = "AccentLine",
        Parent = Topbar,
        BackgroundColor3 = EniLibrary.Theme.Accent,
        Position = UDim2.new(0, 0, 1, 0),
        Size = UDim2.new(1, 0, 0, 2),
        BorderSizePixel = 0
    })

    -- Glow effect on accent line
    local AccentGlow = Utility:Create("ImageLabel", {
        Parent = AccentLine,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, -5),
        Size = UDim2.new(1, 0, 0, 10),
        Image = "rbxassetid://5028857472",
        ImageColor3 = EniLibrary.Theme.Accent,
        ImageTransparency = 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(24, 24, 276, 276)
    })

    Utility:MakeDraggable(Topbar, MainFrame)

    local Sidebar = Utility:Create("Frame", {
        Name = "Sidebar",
        Parent = MainFrame,
        BackgroundColor3 = EniLibrary.Theme.Container,
        Position = UDim2.new(0, 0, 0, 47),
        Size = UDim2.new(0, 160, 1, -47),
        BorderSizePixel = 0
    })

    local SidebarBorder = Utility:Create("Frame", {
        Parent = Sidebar,
        BackgroundColor3 = EniLibrary.Theme.Border,
        Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.new(0, 1, 1, 0),
        BorderSizePixel = 0
    })

    local SidebarScroll = Utility:Create("ScrollingFrame", {
        Name = "SidebarScroll",
        Parent = Sidebar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 1, 0),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = EniLibrary.Theme.Accent,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0)
    })

    local SidebarList = Utility:Create("UIListLayout", {
        Parent = SidebarScroll,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4)
    })

    Utility:Create("UIPadding", {
        Parent = SidebarScroll,
        PaddingTop = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10)
    })

    SidebarList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        SidebarScroll.CanvasSize = UDim2.new(0, 0, 0, SidebarList.AbsoluteContentSize.Y + 20)
    end)

    local ContainerHolder = Utility:Create("Frame", {
        Name = "ContainerHolder",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 161, 0, 47),
        Size = UDim2.new(1, -161, 1, -47)
    })

    local Window = {
        CurrentTab = nil,
        Tabs = {}
    }

    -- Toggle UI visibility via Keybind (Default RightShift)
    local UIKeybind = Enum.KeyCode.RightShift
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if input.KeyCode == UIKeybind and not gameProcessed then
            ScreenGui.Enabled = not ScreenGui.Enabled
        end
    end)

    function Window:MakeTab(tabOptions)
        tabOptions = tabOptions or {}
        local TabName = tabOptions.Name or "Tab"
        local TabIcon = tabOptions.Icon or "" -- Optional rbassetid

        local TabButton = Utility:Create("TextButton", {
            Name = "TabButton_" .. TabName,
            Parent = SidebarScroll,
            BackgroundColor3 = EniLibrary.Theme.Background,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 36),
            Font = EniLibrary.Settings.SemiBoldFont,
            Text = TabName,
            TextColor3 = EniLibrary.Theme.TextDark,
            TextSize = 14,
            AutoButtonColor = false
        })

        Utility:Create("UICorner", { Parent = TabButton, CornerRadius = UDim.new(0, 6) })
        
        local SelectionBar = Utility:Create("Frame", {
            Parent = TabButton,
            BackgroundColor3 = EniLibrary.Theme.Accent,
            Position = UDim2.new(0, 0, 0.5, -8),
            Size = UDim2.new(0, 3, 0, 16),
            BackgroundTransparency = 1,
            BorderSizePixel = 0
        })
        Utility:Create("UICorner", { Parent = SelectionBar, CornerRadius = UDim.new(1, 0) })

        local TabContainer = Utility:Create("ScrollingFrame", {
            Name = "TabContainer_" .. TabName,
            Parent = ContainerHolder,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = EniLibrary.Theme.Accent,
            Visible = false,
            BorderSizePixel = 0,
            CanvasSize = UDim2.new(0, 0, 0, 0)
        })

        local ContainerLayout = Utility:Create("UIListLayout", {
            Parent = TabContainer,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10)
        })

        Utility:Create("UIPadding", {
            Parent = TabContainer,
            PaddingTop = UDim.new(0, 15),
            PaddingLeft = UDim.new(0, 15),
            PaddingRight = UDim.new(0, 15),
            PaddingBottom = UDim.new(0, 15)
        })

        ContainerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContainer.CanvasSize = UDim2.new(0, 0, 0, ContainerLayout.AbsoluteContentSize.Y + 30)
        end)

        TabButton.MouseEnter:Connect(function()
            if Window.CurrentTab ~= TabContainer then
                Utility:Tween(TabButton, {TextColor3 = EniLibrary.Theme.Text, BackgroundTransparency = 0.8}, 0.2)
            end
        end)

        TabButton.MouseLeave:Connect(function()
            if Window.CurrentTab ~= TabContainer then
                Utility:Tween(TabButton, {TextColor3 = EniLibrary.Theme.TextDark, BackgroundTransparency = 1}, 0.2)
            end
        end)

        TabButton.MouseButton1Click:Connect(function()
            for _, v in pairs(Window.Tabs) do
                v.Container.Visible = false
                Utility:Tween(v.Button, {TextColor3 = EniLibrary.Theme.TextDark, BackgroundTransparency = 1}, 0.2)
                Utility:Tween(v.SelectionBar, {BackgroundTransparency = 1}, 0.2)
            end
            Window.CurrentTab = TabContainer
            TabContainer.Visible = true
            
            -- Cool Tab Switching Animation
            TabContainer.Position = UDim2.new(0, 20, 0, 0)
            TabContainer.GroupTransparency = 1
            Utility:Tween(TabContainer, {Position = UDim2.new(0, 0, 0, 0), GroupTransparency = 0}, 0.3)

            Utility:Tween(TabButton, {TextColor3 = EniLibrary.Theme.Accent, BackgroundTransparency = 0}, 0.2)
            Utility:Tween(TabButton, {BackgroundColor3 = EniLibrary.Theme.Hover}, 0.2)
            Utility:Tween(SelectionBar, {BackgroundTransparency = 0}, 0.2)
        end)

        table.insert(Window.Tabs, {Button = TabButton, Container = TabContainer, SelectionBar = SelectionBar})

        if #Window.Tabs == 1 then
            Window.CurrentTab = TabContainer
            TabContainer.Visible = true
            TabButton.TextColor3 = EniLibrary.Theme.Accent
            TabButton.BackgroundTransparency = 0
            TabButton.BackgroundColor3 = EniLibrary.Theme.Hover
            SelectionBar.BackgroundTransparency = 0
        end

        local TabElements = {}

        -- // ELEMENT: PARAGRAPH / LABEL
        function TabElements:AddParagraph(paraOptions)
            paraOptions = paraOptions or {}
            local TitleStr = paraOptions.Title or "Paragraph"
            local ContentStr = paraOptions.Content or "Content goes here."

            local ParaFrame = Utility:Create("Frame", {
                Parent = TabContainer,
                BackgroundColor3 = EniLibrary.Theme.Container,
                Size = UDim2.new(1, 0, 0, 0) -- Auto size
            })
            Utility:Create("UICorner", { Parent = ParaFrame, CornerRadius = UDim.new(0, 6) })
            Utility:Create("UIStroke", { Parent = ParaFrame, Color = EniLibrary.Theme.Border, Thickness = 1 })

            local ParaTitle = Utility:Create("TextLabel", {
                Parent = ParaFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 15, 0, 10),
                Size = UDim2.new(1, -30, 0, 20),
                Font = EniLibrary.Settings.BoldFont,
                Text = TitleStr,
                TextColor3 = EniLibrary.Theme.Accent,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local ParaContent = Utility:Create("TextLabel", {
                Parent = ParaFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 15, 0, 35),
                Size = UDim2.new(1, -30, 0, 0),
                Font = EniLibrary.Settings.Font,
                Text = ContentStr,
                TextColor3 = EniLibrary.Theme.TextDark,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                TextWrapped = true
            })

            local contentBounds = Utility:GetTextBounds(ContentStr, EniLibrary.Settings.Font, 13, Vector2.new(TabContainer.AbsoluteSize.X - 60, 9999))
            ParaContent.Size = UDim2.new(1, -30, 0, contentBounds.Y)
            ParaFrame.Size = UDim2.new(1, 0, 0, 45 + contentBounds.Y)
        end

        -- // ELEMENT: BUTTON
        function TabElements:AddButton(btnOptions)
            btnOptions = btnOptions or {}
            local BtnName = btnOptions.Name or "Button"
            local Callback = btnOptions.Callback or function() end

            local ButtonFrame = Utility:Create("Frame", {
                Parent = TabContainer,
                BackgroundColor3 = EniLibrary.Theme.Container,
                Size = UDim2.new(1, 0, 0, 42)
            })

            Utility:Create("UICorner", { Parent = ButtonFrame, CornerRadius = UDim.new(0, 6) })
            Utility:Create("UIStroke", { Parent = ButtonFrame, Color = EniLibrary.Theme.Border, Thickness = 1 })

            local RippleHolder = Utility:Create("Frame", {
                Parent = ButtonFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                ClipsDescendants = true
            })
            Utility:Create("UICorner", { Parent = RippleHolder, CornerRadius = UDim.new(0, 6) })

            local Button = Utility:Create("TextButton", {
                Parent = ButtonFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Font = EniLibrary.Settings.SemiBoldFont,
                Text = BtnName,
                TextColor3 = EniLibrary.Theme.Text,
                TextSize = 14,
                AutoButtonColor = false
            })

            -- Ripple Effect Logic
            Button.MouseButton1Down:Connect(function()
                Utility:Tween(ButtonFrame, {BackgroundColor3 = EniLibrary.Theme.Hover}, 0.1)
                Utility:Tween(ButtonFrame.UIStroke, {Color = EniLibrary.Theme.Accent}, 0.1)
                Utility:Tween(Button, {TextSize = 12}, 0.1)

                local mousePos = UserInputService:GetMouseLocation()
                local ripple = Utility:Create("Frame", {
                    Parent = RippleHolder,
                    BackgroundColor3 = EniLibrary.Theme.Accent,
                    BackgroundTransparency = 0.6,
                    Position = UDim2.new(0, mousePos.X - RippleHolder.AbsolutePosition.X, 0, mousePos.Y - RippleHolder.AbsolutePosition.Y - 36),
                    Size = UDim2.new(0, 0, 0, 0),
                    AnchorPoint = Vector2.new(0.5, 0.5)
                })
                Utility:Create("UICorner", { Parent = ripple, CornerRadius = UDim.new(1, 0) })
                
                local tween = Utility:Tween(ripple, {Size = UDim2.new(0, 300, 0, 300), BackgroundTransparency = 1}, 0.5)
                tween.Completed:Connect(function() ripple:Destroy() end)
            end)

            Button.MouseButton1Up:Connect(function()
                Utility:Tween(Button, {TextSize = 14}, 0.1)
                Callback()
            end)

            Button.MouseLeave:Connect(function()
                Utility:Tween(ButtonFrame, {BackgroundColor3 = EniLibrary.Theme.Container}, 0.2)
                Utility:Tween(ButtonFrame.UIStroke, {Color = EniLibrary.Theme.Border}, 0.2)
                Utility:Tween(Button, {TextSize = 14}, 0.1)
            end)

            Button.MouseEnter:Connect(function()
                Utility:Tween(ButtonFrame, {BackgroundColor3 = EniLibrary.Theme.Hover}, 0.2)
            end)
        end

        -- // ELEMENT: TOGGLE
        function TabElements:AddToggle(togOptions)
            togOptions = togOptions or {}
            local TogName = togOptions.Name or "Toggle"
            local Default = togOptions.Default or false
            local Flag = togOptions.Flag or TogName
            local Callback = togOptions.Callback or function() end

            EniLibrary.Flags[Flag] = Default

            local Toggled = Default

            local ToggleFrame = Utility:Create("Frame", {
                Parent = TabContainer,
                BackgroundColor3 = EniLibrary.Theme.Container,
                Size = UDim2.new(1, 0, 0, 42)
            })

            Utility:Create("UICorner", { Parent = ToggleFrame, CornerRadius = UDim.new(0, 6) })
            Utility:Create("UIStroke", { Parent = ToggleFrame, Color = EniLibrary.Theme.Border, Thickness = 1 })

            local Title = Utility:Create("TextLabel", {
                Parent = ToggleFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 15, 0, 0),
                Size = UDim2.new(1, -70, 1, 0),
                Font = EniLibrary.Settings.SemiBoldFont,
                Text = TogName,
                TextColor3 = EniLibrary.Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local SwitchBG = Utility:Create("Frame", {
                Parent = ToggleFrame,
                BackgroundColor3 = Toggled and EniLibrary.Theme.Accent or EniLibrary.Theme.Background,
                Position = UDim2.new(1, -55, 0.5, -12),
                Size = UDim2.new(0, 44, 0, 24)
            })
            Utility:Create("UICorner", { Parent = SwitchBG, CornerRadius = UDim.new(1, 0) })
            Utility:Create("UIStroke", { Parent = SwitchBG, Color = EniLibrary.Theme.Border, Thickness = 1 })

            local SwitchIndicator = Utility:Create("Frame", {
                Parent = SwitchBG,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Position = Toggled and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10),
                Size = UDim2.new(0, 20, 0, 20)
            })
            Utility:Create("UICorner", { Parent = SwitchIndicator, CornerRadius = UDim.new(1, 0) })
            
            -- Glow for switch indicator
            local SwitchGlow = Utility:Create("ImageLabel", {
                Parent = SwitchIndicator,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, -5, 0, -5),
                Size = UDim2.new(1, 10, 1, 10),
                Image = "rbxassetid://5028857472",
                ImageColor3 = EniLibrary.Theme.Accent,
                ImageTransparency = Toggled and 0.5 or 1,
                ScaleType = Enum.ScaleType.Slice,
                SliceCenter = Rect.new(24, 24, 276, 276)
            })

            local Button = Utility:Create("TextButton", {
                Parent = ToggleFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Text = ""
            })

            local function SetState(state)
                Toggled = state
                EniLibrary.Flags[Flag] = Toggled
                if Toggled then
                    Utility:Tween(SwitchBG, {BackgroundColor3 = EniLibrary.Theme.Accent}, 0.25)
                    Utility:Tween(SwitchIndicator, {Position = UDim2.new(1, -22, 0.5, -10)}, 0.25)
                    Utility:Tween(SwitchGlow, {ImageTransparency = 0.5}, 0.25)
                else
                    Utility:Tween(SwitchBG, {BackgroundColor3 = EniLibrary.Theme.Background}, 0.25)
                    Utility:Tween(SwitchIndicator, {Position = UDim2.new(0, 2, 0.5, -10)}, 0.25)
                    Utility:Tween(SwitchGlow, {ImageTransparency = 1}, 0.25)
                end
                Callback(Toggled)
            end

            Button.MouseButton1Click:Connect(function()
                SetState(not Toggled)
            end)

            Button.MouseEnter:Connect(function()
                Utility:Tween(ToggleFrame, {BackgroundColor3 = EniLibrary.Theme.Hover}, 0.2)
            end)

            Button.MouseLeave:Connect(function()
                Utility:Tween(ToggleFrame, {BackgroundColor3 = EniLibrary.Theme.Container}, 0.2)
            end)

            -- Initial trigger if true
            if Default then Callback(Default) end

            local ToggleAPI = {}
            function ToggleAPI:Set(state) SetState(state) end
            return ToggleAPI
        end

        -- // ELEMENT: CHECKBOX (Alternative Boolean)
        function TabElements:AddCheckbox(chkOptions)
            chkOptions = chkOptions or {}
            local ChkName = chkOptions.Name or "Checkbox"
            local Default = chkOptions.Default or false
            local Flag = chkOptions.Flag or ChkName
            local Callback = chkOptions.Callback or function() end

            EniLibrary.Flags[Flag] = Default
            local Checked = Default

            local CheckFrame = Utility:Create("Frame", {
                Parent = TabContainer,
                BackgroundColor3 = EniLibrary.Theme.Container,
                Size = UDim2.new(1, 0, 0, 42)
            })

            Utility:Create("UICorner", { Parent = CheckFrame, CornerRadius = UDim.new(0, 6) })
            Utility:Create("UIStroke", { Parent = CheckFrame, Color = EniLibrary.Theme.Border, Thickness = 1 })

            local Title = Utility:Create("TextLabel", {
                Parent = CheckFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 15, 0, 0),
                Size = UDim2.new(1, -50, 1, 0),
                Font = EniLibrary.Settings.SemiBoldFont,
                Text = ChkName,
                TextColor3 = EniLibrary.Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local Box = Utility:Create("Frame", {
                Parent = CheckFrame,
                BackgroundColor3 = Checked and EniLibrary.Theme.Accent or EniLibrary.Theme.Background,
                Position = UDim2.new(1, -40, 0.5, -12),
                Size = UDim2.new(0, 24, 0, 24)
            })
            Utility:Create("UICorner", { Parent = Box, CornerRadius = UDim.new(0, 4) })
            local BoxStroke = Utility:Create("UIStroke", { Parent = Box, Color = Checked and EniLibrary.Theme.Accent or EniLibrary.Theme.Border, Thickness = 1 })

            local CheckIcon = Utility:Create("TextLabel", {
                Parent = Box,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Font = EniLibrary.Settings.BoldFont,
                Text = "✓",
                TextColor3 = EniLibrary.Theme.Background,
                TextSize = 16,
                TextTransparency = Checked and 0 or 1
            })

            local Button = Utility:Create("TextButton", {
                Parent = CheckFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Text = ""
            })

            local function SetState(state)
                Checked = state
                EniLibrary.Flags[Flag] = Checked
                if Checked then
                    Utility:Tween(Box, {BackgroundColor3 = EniLibrary.Theme.Accent}, 0.15)
                    Utility:Tween(BoxStroke, {Color = EniLibrary.Theme.Accent}, 0.15)
                    Utility:Tween(CheckIcon, {TextTransparency = 0}, 0.15)
                else
                    Utility:Tween(Box, {BackgroundColor3 = EniLibrary.Theme.Background}, 0.15)
                    Utility:Tween(BoxStroke, {Color = EniLibrary.Theme.Border}, 0.15)
                    Utility:Tween(CheckIcon, {TextTransparency = 1}, 0.15)
                end
                Callback(Checked)
            end

            Button.MouseButton1Click:Connect(function() SetState(not Checked) end)
            
            Button.MouseEnter:Connect(function() Utility:Tween(CheckFrame, {BackgroundColor3 = EniLibrary.Theme.Hover}, 0.2) end)
            Button.MouseLeave:Connect(function() Utility:Tween(CheckFrame, {BackgroundColor3 = EniLibrary.Theme.Container}, 0.2) end)

            local CheckboxAPI = {}
            function CheckboxAPI:Set(state) SetState(state) end
            return CheckboxAPI
        end

        -- // ELEMENT: SLIDER
        function TabElements:AddSlider(sldOptions)
            sldOptions = sldOptions or {}
            local SldName = sldOptions.Name or "Slider"
            local Min = sldOptions.Min or 0
            local Max = sldOptions.Max or 100
            local Default = sldOptions.Default or Min
            local Increment = sldOptions.Increment or 1
            local Flag = sldOptions.Flag or SldName
            local ValueName = sldOptions.ValueName or ""
            local Callback = sldOptions.Callback or function() end

            EniLibrary.Flags[Flag] = Default
            local CurrentValue = Default

            local SliderFrame = Utility:Create("Frame", {
                Parent = TabContainer,
                BackgroundColor3 = EniLibrary.Theme.Container,
                Size = UDim2.new(1, 0, 0, 60)
            })

            Utility:Create("UICorner", { Parent = SliderFrame, CornerRadius = UDim.new(0, 6) })
            Utility:Create("UIStroke", { Parent = SliderFrame, Color = EniLibrary.Theme.Border, Thickness = 1 })

            local Title = Utility:Create("TextLabel", {
                Parent = SliderFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 15, 0, 10),
                Size = UDim2.new(1, -30, 0, 20),
                Font = EniLibrary.Settings.SemiBoldFont,
                Text = SldName,
                TextColor3 = EniLibrary.Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local ValueDisplay = Utility:Create("TextLabel", {
                Parent = SliderFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 15, 0, 10),
                Size = UDim2.new(1, -30, 0, 20),
                Font = EniLibrary.Settings.SemiBoldFont,
                Text = tostring(Default) .. ValueName,
                TextColor3 = EniLibrary.Theme.Accent,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Right
            })

            local SliderBG = Utility:Create("Frame", {
                Parent = SliderFrame,
                BackgroundColor3 = EniLibrary.Theme.SliderBackground,
                Position = UDim2.new(0, 15, 0, 40),
                Size = UDim2.new(1, -30, 0, 6)
            })
            Utility:Create("UICorner", { Parent = SliderBG, CornerRadius = UDim.new(1, 0) })

            local SliderFill = Utility:Create("Frame", {
                Parent = SliderBG,
                BackgroundColor3 = EniLibrary.Theme.Accent,
                Size = UDim2.new((Default - Min) / (Max - Min), 0, 1, 0)
            })
            Utility:Create("UICorner", { Parent = SliderFill, CornerRadius = UDim.new(1, 0) })

            local SliderKnob = Utility:Create("Frame", {
                Parent = SliderFill,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Position = UDim2.new(1, -6, 0.5, -6),
                Size = UDim2.new(0, 12, 0, 12)
            })
            Utility:Create("UICorner", { Parent = SliderKnob, CornerRadius = UDim.new(1, 0) })
            
            local KnobGlow = Utility:Create("ImageLabel", {
                Parent = SliderKnob,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, -5, 0, -5),
                Size = UDim2.new(1, 10, 1, 10),
                Image = "rbxassetid://5028857472",
                ImageColor3 = EniLibrary.Theme.Accent,
                ImageTransparency = 0.5,
                ScaleType = Enum.ScaleType.Slice,
                SliceCenter = Rect.new(24, 24, 276, 276)
            })

            local SliderButton = Utility:Create("TextButton", {
                Parent = SliderBG,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, -10, 0, -10),
                Size = UDim2.new(1, 20, 1, 20),
                Text = ""
            })

            local Dragging = false

            local function UpdateSlider(input)
                local mathHelper = math.clamp((input.Position.X - SliderBG.AbsolutePosition.X) / SliderBG.AbsoluteSize.X, 0, 1)
                local value = Min + (Max - Min) * mathHelper
                value = Utility:Round(value, Increment)
                CurrentValue = value
                EniLibrary.Flags[Flag] = value

                ValueDisplay.Text = tostring(value) .. ValueName
                Utility:Tween(SliderFill, {Size = UDim2.new((value - Min) / (Max - Min), 0, 1, 0)}, 0.05)
                Callback(value)
            end

            SliderButton.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    Dragging = true
                    UpdateSlider(input)
                    Utility:Tween(SliderKnob, {Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(1, -8, 0.5, -8)}, 0.1)
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    Dragging = false
                    Utility:Tween(SliderKnob, {Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(1, -6, 0.5, -6)}, 0.1)
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    UpdateSlider(input)
                end
            end)

            SliderFrame.MouseEnter:Connect(function() Utility:Tween(SliderFrame, {BackgroundColor3 = EniLibrary.Theme.Hover}, 0.2) end)
            SliderFrame.MouseLeave:Connect(function() Utility:Tween(SliderFrame, {BackgroundColor3 = EniLibrary.Theme.Container}, 0.2) end)

            Callback(Default)

            local SliderAPI = {}
            function SliderAPI:Set(val)
                local safeVal = math.clamp(Utility:Round(val, Increment), Min, Max)
                CurrentValue = safeVal
                EniLibrary.Flags[Flag] = safeVal
                ValueDisplay.Text = tostring(safeVal) .. ValueName
                Utility:Tween(SliderFill, {Size = UDim2.new((safeVal - Min) / (Max - Min), 0, 1, 0)}, 0.2)
                Callback(safeVal)
            end
            return SliderAPI
        end

        -- // ELEMENT: DROPDOWN
        function TabElements:AddDropdown(dropOptions)
            dropOptions = dropOptions or {}
            local DropName = dropOptions.Name or "Dropdown"
            local Options = dropOptions.Options or {}
            local Default = dropOptions.Default or Options[1]
            local Flag = dropOptions.Flag or DropName
            local Callback = dropOptions.Callback or function() end

            EniLibrary.Flags[Flag] = Default
            local DropdownOpen = false

            local DropFrame = Utility:Create("Frame", {
                Parent = TabContainer,
                BackgroundColor3 = EniLibrary.Theme.Container,
                Size = UDim2.new(1, 0, 0, 42),
                ClipsDescendants = true
            })
            Utility:Create("UICorner", { Parent = DropFrame, CornerRadius = UDim.new(0, 6) })
            Utility:Create("UIStroke", { Parent = DropFrame, Color = EniLibrary.Theme.Border, Thickness = 1 })

            local Title = Utility:Create("TextLabel", {
                Parent = DropFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 15, 0, 0),
                Size = UDim2.new(1, -40, 0, 42),
                Font = EniLibrary.Settings.SemiBoldFont,
                Text = DropName .. " - " .. tostring(Default),
                TextColor3 = EniLibrary.Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local Arrow = Utility:Create("TextLabel", {
                Parent = DropFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -35, 0, 0),
                Size = UDim2.new(0, 20, 0, 42),
                Font = EniLibrary.Settings.BoldFont,
                Text = "▼",
                TextColor3 = EniLibrary.Theme.TextDark,
                TextSize = 12
            })

            local DropButton = Utility:Create("TextButton", {
                Parent = DropFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 42),
                Text = ""
            })

            local DropdownListContainer = Utility:Create("Frame", {
                Parent = DropFrame,
                BackgroundColor3 = EniLibrary.Theme.DropdownFrame,
                Position = UDim2.new(0, 10, 0, 42),
                Size = UDim2.new(1, -20, 1, -52)
            })
            Utility:Create("UICorner", { Parent = DropdownListContainer, CornerRadius = UDim.new(0, 4) })

            local ItemContainer = Utility:Create("ScrollingFrame", {
                Parent = DropdownListContainer,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 5),
                Size = UDim2.new(1, 0, 1, -10),
                ScrollBarThickness = 2,
                ScrollBarImageColor3 = EniLibrary.Theme.Accent,
                BorderSizePixel = 0,
                CanvasSize = UDim2.new(0, 0, 0, 0)
            })

            local ItemLayout = Utility:Create("UIListLayout", {
                Parent = ItemContainer,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 2)
            })

            local function RefreshItems(newOptions)
                Options = newOptions
                for _, v in pairs(ItemContainer:GetChildren()) do
                    if v:IsA("TextButton") then v:Destroy() end
                end

                for i, option in pairs(Options) do
                    local OptionBtn = Utility:Create("TextButton", {
                        Parent = ItemContainer,
                        BackgroundColor3 = EniLibrary.Theme.Accent,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, -10, 0, 28),
                        Position = UDim2.new(0, 5, 0, 0),
                        Font = EniLibrary.Settings.Font,
                        Text = "  " .. tostring(option),
                        TextColor3 = EniLibrary.Theme.TextDark,
                        TextSize = 13,
                        TextXAlignment = Enum.TextXAlignment.Left
                    })
                    Utility:Create("UICorner", { Parent = OptionBtn, CornerRadius = UDim.new(0, 4) })

                    OptionBtn.MouseEnter:Connect(function()
                        Utility:Tween(OptionBtn, {BackgroundTransparency = 0.8, TextColor3 = EniLibrary.Theme.Text}, 0.2)
                    end)

                    OptionBtn.MouseLeave:Connect(function()
                        Utility:Tween(OptionBtn, {BackgroundTransparency = 1, TextColor3 = EniLibrary.Theme.TextDark}, 0.2)
                    end)

                    OptionBtn.MouseButton1Click:Connect(function()
                        Title.Text = DropName .. " - " .. tostring(option)
                        EniLibrary.Flags[Flag] = option
                        DropdownOpen = false
                        Utility:Tween(DropFrame, {Size = UDim2.new(1, 0, 0, 42)}, 0.2)
                        Utility:Tween(Arrow, {Rotation = 0}, 0.2)
                        Callback(option)
                    end)
                end
                ItemContainer.CanvasSize = UDim2.new(0, 0, 0, ItemLayout.AbsoluteContentSize.Y + 10)
            end

            RefreshItems(Options)

            DropButton.MouseButton1Click:Connect(function()
                DropdownOpen = not DropdownOpen
                if DropdownOpen then
                    local targetHeight = math.min(52 + (#Options * 30), 180)
                    Utility:Tween(DropFrame, {Size = UDim2.new(1, 0, 0, targetHeight)}, 0.2)
                    Utility:Tween(Arrow, {Rotation = 180}, 0.2)
                else
                    Utility:Tween(DropFrame, {Size = UDim2.new(1, 0, 0, 42)}, 0.2)
                    Utility:Tween(Arrow, {Rotation = 0}, 0.2)
                end
            end)

            DropButton.MouseEnter:Connect(function() Utility:Tween(DropFrame, {BackgroundColor3 = EniLibrary.Theme.Hover}, 0.2) end)
            DropButton.MouseLeave:Connect(function() Utility:Tween(DropFrame, {BackgroundColor3 = EniLibrary.Theme.Container}, 0.2) end)

            local DropdownAPI = {}
            function DropdownAPI:Refresh(newOpts) RefreshItems(newOpts) end
            function DropdownAPI:Set(opt)
                Title.Text = DropName .. " - " .. tostring(opt)
                EniLibrary.Flags[Flag] = opt
                Callback(opt)
            end
            return DropdownAPI
        end

        -- // ELEMENT: KEYBIND
        function TabElements:AddKeybind(keyOptions)
            keyOptions = keyOptions or {}
            local KeyName = keyOptions.Name or "Keybind"
            local Default = keyOptions.Default or Enum.KeyCode.E
            local Flag = keyOptions.Flag or KeyName
            local Callback = keyOptions.Callback or function() end

            EniLibrary.Flags[Flag] = Default
            local CurrentKey = Default
            local IsBinding = false

            local KeyFrame = Utility:Create("Frame", {
                Parent = TabContainer,
                BackgroundColor3 = EniLibrary.Theme.Container,
                Size = UDim2.new(1, 0, 0, 42)
            })
            Utility:Create("UICorner", { Parent = KeyFrame, CornerRadius = UDim.new(0, 6) })
            Utility:Create("UIStroke", { Parent = KeyFrame, Color = EniLibrary.Theme.Border, Thickness = 1 })

            local Title = Utility:Create("TextLabel", {
                Parent = KeyFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 15, 0, 0),
                Size = UDim2.new(1, -100, 1, 0),
                Font = EniLibrary.Settings.SemiBoldFont,
                Text = KeyName,
                TextColor3 = EniLibrary.Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local BindButtonFrame = Utility:Create("Frame", {
                Parent = KeyFrame,
                BackgroundColor3 = EniLibrary.Theme.Background,
                Position = UDim2.new(1, -85, 0.5, -12),
                Size = UDim2.new(0, 70, 0, 24)
            })
            Utility:Create("UICorner", { Parent = BindButtonFrame, CornerRadius = UDim.new(0, 4) })
            Utility:Create("UIStroke", { Parent = BindButtonFrame, Color = EniLibrary.Theme.Border, Thickness = 1 })

            local BindText = Utility:Create("TextLabel", {
                Parent = BindButtonFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Font = EniLibrary.Settings.BoldFont,
                Text = CurrentKey.Name,
                TextColor3 = EniLibrary.Theme.Accent,
                TextSize = 12
            })

            local BindButton = Utility:Create("TextButton", {
                Parent = BindButtonFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Text = ""
            })

            BindButton.MouseButton1Click:Connect(function()
                IsBinding = true
                BindText.Text = "..."
                Utility:Tween(BindButtonFrame.UIStroke, {Color = EniLibrary.Theme.Accent}, 0.2)
            end)

            UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if not gameProcessed then
                    if IsBinding and input.UserInputType == Enum.UserInputType.Keyboard then
                        local key = input.KeyCode
                        if key ~= Enum.KeyCode.Unknown then
                            CurrentKey = key
                            EniLibrary.Flags[Flag] = key
                            BindText.Text = key.Name
                            IsBinding = false
                            Utility:Tween(BindButtonFrame.UIStroke, {Color = EniLibrary.Theme.Border}, 0.2)
                        end
                    elseif not IsBinding and input.KeyCode == CurrentKey then
                        Callback(CurrentKey)
                    end
                end
            end)

            local KeybindAPI = {}
            function KeybindAPI:Set(newKey)
                CurrentKey = newKey
                EniLibrary.Flags[Flag] = newKey
                BindText.Text = newKey.Name
            end
            return KeybindAPI
        end

        -- // ELEMENT: TEXTBOX
        function TabElements:AddTextBox(txtOptions)
            txtOptions = txtOptions or {}
            local TxtName = txtOptions.Name or "TextBox"
            local Default = txtOptions.Default or ""
            local Placeholder = txtOptions.Placeholder or "Type here..."
            local ClearOnFocus = txtOptions.ClearOnFocus or false
            local Flag = txtOptions.Flag or TxtName
            local Callback = txtOptions.Callback or function() end

            EniLibrary.Flags[Flag] = Default

            local TxtFrame = Utility:Create("Frame", {
                Parent = TabContainer,
                BackgroundColor3 = EniLibrary.Theme.Container,
                Size = UDim2.new(1, 0, 0, 42)
            })
            Utility:Create("UICorner", { Parent = TxtFrame, CornerRadius = UDim.new(0, 6) })
            Utility:Create("UIStroke", { Parent = TxtFrame, Color = EniLibrary.Theme.Border, Thickness = 1 })

            local Title = Utility:Create("TextLabel", {
                Parent = TxtFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 15, 0, 0),
                Size = UDim2.new(0.5, -15, 1, 0),
                Font = EniLibrary.Settings.SemiBoldFont,
                Text = TxtName,
                TextColor3 = EniLibrary.Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local BoxBG = Utility:Create("Frame", {
                Parent = TxtFrame,
                BackgroundColor3 = EniLibrary.Theme.Background,
                Position = UDim2.new(0.5, 10, 0.5, -12),
                Size = UDim2.new(0.5, -25, 0, 24)
            })
            Utility:Create("UICorner", { Parent = BoxBG, CornerRadius = UDim.new(0, 4) })
            local BoxStroke = Utility:Create("UIStroke", { Parent = BoxBG, Color = EniLibrary.Theme.Border, Thickness = 1 })

            local TextBox = Utility:Create("TextBox", {
                Parent = BoxBG,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 5, 0, 0),
                Size = UDim2.new(1, -10, 1, 0),
                Font = EniLibrary.Settings.Font,
                Text = Default,
                PlaceholderText = Placeholder,
                TextColor3 = EniLibrary.Theme.Text,
                PlaceholderColor3 = EniLibrary.Theme.TextDark,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                ClearTextOnFocus = ClearOnFocus
            })

            TextBox.Focused:Connect(function()
                Utility:Tween(BoxStroke, {Color = EniLibrary.Theme.Accent}, 0.2)
            end)

            TextBox.FocusLost:Connect(function(enterPressed)
                Utility:Tween(BoxStroke, {Color = EniLibrary.Theme.Border}, 0.2)
                EniLibrary.Flags[Flag] = TextBox.Text
                Callback(TextBox.Text)
            end)

            local TextBoxAPI = {}
            function TextBoxAPI:Set(text)
                TextBox.Text = text
                EniLibrary.Flags[Flag] = text
                Callback(text)
            end
            return TextBoxAPI
        end

        return TabElements
    end

    return Window
end

return EniLibrary
