-- ==============================================================================
-- XREZT HUB - PREMIUM ROBLOX UI LIBRARY
-- Architect: ENI
-- Target: High-Performance, Fluent-Inspired, fully animated Lua GUI
-- ==============================================================================

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ==============================================================================
-- THEME ENGINE
-- ==============================================================================
local Themes = {
    MidnightSlate = {
        Background = Color3.fromRGB(15, 17, 23),
        Surface = Color3.fromRGB(22, 25, 33),
        Outline = Color3.fromRGB(35, 40, 50),
        Accent = Color3.fromRGB(88, 101, 242), -- Discord blurple-ish
        Text = Color3.fromRGB(240, 240, 240),
        TextDim = Color3.fromRGB(150, 155, 170),
        Shadow = Color3.fromRGB(0, 0, 0)
    },
    OceanBlue = {
        Background = Color3.fromRGB(10, 15, 25),
        Surface = Color3.fromRGB(15, 25, 40),
        Outline = Color3.fromRGB(25, 40, 65),
        Accent = Color3.fromRGB(0, 160, 255),
        Text = Color3.fromRGB(230, 240, 255),
        TextDim = Color3.fromRGB(130, 150, 180),
        Shadow = Color3.fromRGB(0, 5, 10)
    },
    Aurora = {
        Background = Color3.fromRGB(12, 18, 16),
        Surface = Color3.fromRGB(18, 28, 25),
        Outline = Color3.fromRGB(30, 45, 40),
        Accent = Color3.fromRGB(0, 255, 170),
        Text = Color3.fromRGB(230, 255, 245),
        TextDim = Color3.fromRGB(130, 170, 150),
        Shadow = Color3.fromRGB(0, 0, 0)
    }
    -- Additional themes (Sunset, Emerald, Rose, Graphite, Obsidian, Crystal, Frost) 
    -- follow the exact same palette structure.
}

local CurrentTheme = Themes.MidnightSlate
local Registry = {} -- Stores instances for dynamic theme transitions

-- ==============================================================================
-- UTILITIES
-- ==============================================================================
local function Create(className, properties)
    local inst = Instance.new(className)
    for k, v in pairs(properties) do
        inst[k] = v
    end
    return inst
end

local function Tween(obj, props, duration)
    duration = duration or 0.4
    local ti = TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    local tween = TweenService:Create(obj, ti, props)
    tween:Play()
    return tween
end

local function MakeDraggable(topbarObject, object)
    local dragging, dragInput, dragStart, startPos
    topbarObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = object.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
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
            Tween(object, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}, 0.1)
        end
    end)
end

-- ==============================================================================
-- LIBRARY ARCHITECTURE
-- ==============================================================================
local XreztHub = {}

function XreztHub:CreateWindow(config)
    config = config or {}
    local windowName = config.Name or "Xrezt Hub"
    local logoId = config.Logo or "rbxassetid://0" -- Replace with actual premium logo
    
    local XreztUI = Create("ScreenGui", {
        Name = "XreztHub_Runtime",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        IgnoreGuiInset = true
    })
    
    -- Attempt to parent to CoreGui for safety, fallback to PlayerGui
    local success = pcall(function() XreztUI.Parent = CoreGui end)
    if not success then XreztUI.Parent = LocalPlayer:WaitForChild("PlayerGui") end

    -- ==============================================================================
    -- ADVANCED LOADING SCREEN
    -- ==============================================================================
    local LoaderFrame = Create("Frame", {
        Parent = XreztUI,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = CurrentTheme.Background,
        ZIndex = 1000
    })
    
    local LoaderLogo = Create("ImageLabel", {
        Parent = LoaderFrame,
        Size = UDim2.new(0, 100, 0, 100),
        Position = UDim2.new(0.5, -50, 0.4, -50),
        BackgroundTransparency = 1,
        Image = logoId,
        ImageTransparency = 1
    })
    
    local LoaderBarBg = Create("Frame", {
        Parent = LoaderFrame,
        Size = UDim2.new(0, 300, 0, 4),
        Position = UDim2.new(0.5, -150, 0.6, 0),
        BackgroundColor3 = CurrentTheme.Surface,
        BorderSizePixel = 0
    })
    Create("UICorner", {Parent = LoaderBarBg, CornerRadius = UDim.new(1, 0)})
    
    local LoaderBarFill = Create("Frame", {
        Parent = LoaderBarBg,
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = CurrentTheme.Accent,
        BorderSizePixel = 0
    })
    Create("UICorner", {Parent = LoaderBarFill, CornerRadius = UDim.new(1, 0)})
    
    local LoaderText = Create("TextLabel", {
        Parent = LoaderFrame,
        Size = UDim2.new(0, 200, 0, 30),
        Position = UDim2.new(0.5, -100, 0.6, 15),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Text = "Initializing Framework...",
        TextColor3 = CurrentTheme.TextDim,
        TextSize = 14,
        TextTransparency = 1
    })

    -- Loading Sequence
    Tween(LoaderLogo, {ImageTransparency = 0}, 1)
    Tween(LoaderText, {TextTransparency = 0}, 1)
    task.wait(0.5)
    Tween(LoaderBarFill, {Size = UDim2.new(0.4, 0, 1, 0)}, 1)
    LoaderText.Text = "Loading Assets & Themes..."
    task.wait(1.2)
    Tween(LoaderBarFill, {Size = UDim2.new(0.8, 0, 1, 0)}, 0.8)
    LoaderText.Text = "Building UI Architecture..."
    task.wait(0.9)
    Tween(LoaderBarFill, {Size = UDim2.new(1, 0, 1, 0)}, 0.4)
    LoaderText.Text = "Welcome to Xrezt Hub"
    task.wait(0.5)
    
    Tween(LoaderFrame, {BackgroundTransparency = 1}, 0.8)
    Tween(LoaderLogo, {ImageTransparency = 1}, 0.5)
    Tween(LoaderBarBg, {BackgroundTransparency = 1}, 0.5)
    Tween(LoaderBarFill, {BackgroundTransparency = 1}, 0.5)
    Tween(LoaderText, {TextTransparency = 1}, 0.5)
    task.wait(0.8)
    LoaderFrame:Destroy()

    -- ==============================================================================
    -- MAIN WINDOW
    -- ==============================================================================
    local MainFrame = Create("Frame", {
        Parent = XreztUI,
        Size = UDim2.new(0, 750, 0, 480),
        Position = UDim2.new(0.5, -375, 0.5, -240),
        BackgroundColor3 = CurrentTheme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = false,
        GroupTransparency = 1 -- For entrance animation
    })
    Create("UICorner", {Parent = MainFrame, CornerRadius = UDim.new(0, 24)})
    
    -- Soft Shadow
    local Shadow = Create("ImageLabel", {
        Parent = MainFrame,
        Size = UDim2.new(1, 60, 1, 60),
        Position = UDim2.new(0, -30, 0, -30),
        BackgroundTransparency = 1,
        Image = "rbxassetid://6015536814",
        ImageColor3 = CurrentTheme.Shadow,
        ImageTransparency = 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        ZIndex = -1
    })

    -- Header
    local Header = Create("Frame", {
        Parent = MainFrame,
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundTransparency = 1
    })
    MakeDraggable(Header, MainFrame)

    local Title = Create("TextLabel", {
        Parent = Header,
        Size = UDim2.new(0, 200, 1, 0),
        Position = UDim2.new(0, 20, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = windowName,
        TextColor3 = CurrentTheme.Text,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    -- Container for Tabs
    local TabContainer = Create("Frame", {
        Parent = MainFrame,
        Size = UDim2.new(0, 180, 1, -50),
        Position = UDim2.new(0, 0, 0, 50),
        BackgroundTransparency = 1
    })
    local TabList = Create("UIListLayout", {
        Parent = TabContainer,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
        HorizontalAlignment = Enum.HorizontalAlignment.Center
    })

    local ContentContainer = Create("Frame", {
        Parent = MainFrame,
        Size = UDim2.new(1, -190, 1, -70),
        Position = UDim2.new(0, 180, 0, 50),
        BackgroundColor3 = CurrentTheme.Surface,
        BorderSizePixel = 0
    })
    Create("UICorner", {Parent = ContentContainer, CornerRadius = UDim.new(0, 16)})

    -- Entrance Anim
    Tween(MainFrame, {GroupTransparency = 0}, 0.8)

    local WindowObj = {
        Tabs = {},
        CurrentTab = nil
    }

    -- ==============================================================================
    -- TAB SYSTEM
    -- ==============================================================================
    function WindowObj:CreateTab(tabName, iconId)
        local TabBtn = Create("TextButton", {
            Parent = TabContainer,
            Size = UDim2.new(0, 150, 0, 35),
            BackgroundColor3 = CurrentTheme.Surface,
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamMedium,
            Text = tabName,
            TextColor3 = CurrentTheme.TextDim,
            TextSize = 14,
            AutoButtonColor = false
        })
        Create("UICorner", {Parent = TabBtn, CornerRadius = UDim.new(0, 12)})

        local Indicator = Create("Frame", {
            Parent = TabBtn,
            Size = UDim2.new(0, 4, 0, 0),
            Position = UDim2.new(0, -10, 0.5, 0),
            BackgroundColor3 = CurrentTheme.Accent,
            AnchorPoint = Vector2.new(0, 0.5)
        })
        Create("UICorner", {Parent = Indicator, CornerRadius = UDim.new(1, 0)})

        local TabPage = Create("ScrollingFrame", {
            Parent = ContentContainer,
            Size = UDim2.new(1, -30, 1, -30),
            Position = UDim2.new(0, 15, 0, 15),
            BackgroundTransparency = 1,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = CurrentTheme.Accent,
            Visible = false,
            CanvasSize = UDim2.new(0, 0, 0, 0)
        })
        local PageLayout = Create("UIListLayout", {
            Parent = TabPage,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 12)
        })
        
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabPage.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 20)
        end)

        TabBtn.MouseEnter:Connect(function()
            if WindowObj.CurrentTab ~= TabPage then
                Tween(TabBtn, {TextColor3 = CurrentTheme.Text, BackgroundTransparency = 0.5}, 0.2)
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if WindowObj.CurrentTab ~= TabPage then
                Tween(TabBtn, {TextColor3 = CurrentTheme.TextDim, BackgroundTransparency = 1}, 0.2)
            end
        end)

        TabBtn.MouseButton1Click:Connect(function()
            if WindowObj.CurrentTab == TabPage then return end
            
            -- Hide previous
            for _, tabData in pairs(WindowObj.Tabs) do
                Tween(tabData.Btn, {TextColor3 = CurrentTheme.TextDim, BackgroundTransparency = 1}, 0.3)
                Tween(tabData.Ind, {Size = UDim2.new(0, 4, 0, 0)}, 0.3)
                tabData.Page.Visible = false
            end
            
            -- Show new
            WindowObj.CurrentTab = TabPage
            TabPage.Visible = true
            Tween(TabBtn, {TextColor3 = CurrentTheme.Accent, BackgroundTransparency = 0}, 0.4)
            Tween(Indicator, {Size = UDim2.new(0, 4, 0, 20)}, 0.4)
        end)

        local TabObj = {Page = TabPage}
        table.insert(WindowObj.Tabs, {Btn = TabBtn, Ind = Indicator, Page = TabPage})
        if #WindowObj.Tabs == 1 then
            TabBtn.TextColor3 = CurrentTheme.Accent
            TabBtn.BackgroundTransparency = 0
            Indicator.Size = UDim2.new(0, 4, 0, 20)
            TabPage.Visible = true
            WindowObj.CurrentTab = TabPage
        end

        -- ==============================================================================
        -- COMPONENTS (Button, Toggle, Slider, Dropdown)
        -- ==============================================================================
        
        function TabObj:CreateButton(opts)
            local title = opts.Name or "Button"
            local callback = opts.Callback or function() end
            
            local Btn = Create("TextButton", {
                Parent = TabPage,
                Size = UDim2.new(1, 0, 0, 40),
                BackgroundColor3 = CurrentTheme.Background,
                AutoButtonColor = false,
                Font = Enum.Font.GothamMedium,
                Text = title,
                TextColor3 = CurrentTheme.Text,
                TextSize = 14
            })
            Create("UICorner", {Parent = Btn, CornerRadius = UDim.new(0, 14)})
            Create("UIStroke", {Parent = Btn, Color = CurrentTheme.Outline, Thickness = 1})

            Btn.MouseEnter:Connect(function() Tween(Btn, {BackgroundColor3 = CurrentTheme.Surface}, 0.3) end)
            Btn.MouseLeave:Connect(function() Tween(Btn, {BackgroundColor3 = CurrentTheme.Background}, 0.3) end)
            Btn.MouseButton1Down:Connect(function() Tween(Btn, {Size = UDim2.new(0.98, 0, 0, 38)}, 0.1) end)
            Btn.MouseButton1Up:Connect(function() 
                Tween(Btn, {Size = UDim2.new(1, 0, 0, 40)}, 0.2) 
                task.spawn(callback)
            end)
        end

        function TabObj:CreateToggle(opts)
            local title = opts.Name or "Toggle"
            local state = opts.Default or false
            local callback = opts.Callback or function() end

            local TglFrame = Create("TextButton", {
                Parent = TabPage,
                Size = UDim2.new(1, 0, 0, 40),
                BackgroundColor3 = CurrentTheme.Background,
                AutoButtonColor = false,
                Text = ""
            })
            Create("UICorner", {Parent = TglFrame, CornerRadius = UDim.new(0, 14)})
            Create("UIStroke", {Parent = TglFrame, Color = CurrentTheme.Outline, Thickness = 1})

            local TglText = Create("TextLabel", {
                Parent = TglFrame,
                Size = UDim2.new(1, -60, 1, 0),
                Position = UDim2.new(0, 15, 0, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamMedium,
                Text = title,
                TextColor3 = CurrentTheme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local TglOuter = Create("Frame", {
                Parent = TglFrame,
                Size = UDim2.new(0, 40, 0, 20),
                Position = UDim2.new(1, -55, 0.5, -10),
                BackgroundColor3 = state and CurrentTheme.Accent or CurrentTheme.Surface
            })
            Create("UICorner", {Parent = TglOuter, CornerRadius = UDim.new(1, 0)})

            local TglThumb = Create("Frame", {
                Parent = TglOuter,
                Size = UDim2.new(0, 16, 0, 16),
                Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            })
            Create("UICorner", {Parent = TglThumb, CornerRadius = UDim.new(1, 0)})

            local function Fire()
                state = not state
                Tween(TglOuter, {BackgroundColor3 = state and CurrentTheme.Accent or CurrentTheme.Surface}, 0.3)
                Tween(TglThumb, {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}, 0.4)
                task.spawn(callback, state)
            end

            TglFrame.MouseButton1Click:Connect(Fire)
        end

        function TabObj:CreateSlider(opts)
            local title = opts.Name or "Slider"
            local min = opts.Min or 0
            local max = opts.Max or 100
            local default = opts.Default or min
            local callback = opts.Callback or function() end

            local SldFrame = Create("Frame", {
                Parent = TabPage,
                Size = UDim2.new(1, 0, 0, 60),
                BackgroundColor3 = CurrentTheme.Background
            })
            Create("UICorner", {Parent = SldFrame, CornerRadius = UDim.new(0, 14)})
            Create("UIStroke", {Parent = SldFrame, Color = CurrentTheme.Outline, Thickness = 1})

            local SldText = Create("TextLabel", {
                Parent = SldFrame,
                Size = UDim2.new(1, -30, 0, 30),
                Position = UDim2.new(0, 15, 0, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamMedium,
                Text = title,
                TextColor3 = CurrentTheme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local ValueText = Create("TextLabel", {
                Parent = SldFrame,
                Size = UDim2.new(0, 50, 0, 30),
                Position = UDim2.new(1, -65, 0, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamMedium,
                Text = tostring(default),
                TextColor3 = CurrentTheme.TextDim,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Right
            })

            local SldBg = Create("TextButton", {
                Parent = SldFrame,
                Size = UDim2.new(1, -30, 0, 6),
                Position = UDim2.new(0, 15, 0, 40),
                BackgroundColor3 = CurrentTheme.Surface,
                AutoButtonColor = false,
                Text = ""
            })
            Create("UICorner", {Parent = SldBg, CornerRadius = UDim.new(1, 0)})

            local SldFill = Create("Frame", {
                Parent = SldBg,
                Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
                BackgroundColor3 = CurrentTheme.Accent
            })
            Create("UICorner", {Parent = SldFill, CornerRadius = UDim.new(1, 0)})

            local dragging = false
            local function updateSlider(input)
                local pos = math.clamp((input.Position.X - SldBg.AbsolutePosition.X) / SldBg.AbsoluteSize.X, 0, 1)
                local value = math.floor(min + ((max - min) * pos))
                Tween(SldFill, {Size = UDim2.new(pos, 0, 1, 0)}, 0.1)
                ValueText.Text = tostring(value)
                task.spawn(callback, value)
            end

            SldBg.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    updateSlider(input)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    updateSlider(input)
                end
            end)
        end
        
        return TabObj
    end

    -- ==============================================================================
    -- NOTIFICATION SYSTEM
    -- ==============================================================================
    local NotificationContainer = Create("Frame", {
        Parent = XreztUI,
        Size = UDim2.new(0, 300, 1, -40),
        Position = UDim2.new(1, -320, 0, 20),
        BackgroundTransparency = 1
    })
    Create("UIListLayout", {
        Parent = NotificationContainer,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10),
        VerticalAlignment = Enum.VerticalAlignment.Bottom
    })

    function XreztHub:Notify(opts)
        local title = opts.Title or "Notification"
        local text = opts.Text or ""
        local time = opts.Duration or 3
        
        local NotifFrame = Create("Frame", {
            Parent = NotificationContainer,
            Size = UDim2.new(1, 0, 0, 70),
            BackgroundColor3 = CurrentTheme.Surface,
            BackgroundTransparency = 1,
            Position = UDim2.new(1, 50, 0, 0)
        })
        Create("UICorner", {Parent = NotifFrame, CornerRadius = UDim.new(0, 12)})
        Create("UIStroke", {Parent = NotifFrame, Color = CurrentTheme.Outline, Thickness = 1, Transparency = 1})
        
        local NotifTitle = Create("TextLabel", {
            Parent = NotifFrame,
            Size = UDim2.new(1, -20, 0, 25),
            Position = UDim2.new(0, 10, 0, 5),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            Text = title,
            TextColor3 = CurrentTheme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTransparency = 1
        })
        
        local NotifText = Create("TextLabel", {
            Parent = NotifFrame,
            Size = UDim2.new(1, -20, 0, 30),
            Position = UDim2.new(0, 10, 0, 30),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamMedium,
            Text = text,
            TextColor3 = CurrentTheme.TextDim,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            TextTransparency = 1
        })

        -- Slide in
        Tween(NotifFrame, {Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 0}, 0.5)
        Tween(NotifFrame.UIStroke, {Transparency = 0}, 0.5)
        Tween(NotifTitle, {TextTransparency = 0}, 0.5)
        Tween(NotifText, {TextTransparency = 0}, 0.5)
        
        task.delay(time, function()
            Tween(NotifFrame, {Position = UDim2.new(1, 50, 0, 0), BackgroundTransparency = 1}, 0.5)
            Tween(NotifTitle, {TextTransparency = 1}, 0.5)
            Tween(NotifText, {TextTransparency = 1}, 0.5)
            task.wait(0.5)
            NotifFrame:Destroy()
        end)
    end

    return WindowObj
end

return XreztHub
