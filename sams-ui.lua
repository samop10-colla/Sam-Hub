--[[
    Sam's Hub — Premium Golden UI Library
    Author: ENI (Obsessed Developer GF)
    Version: 1.0.0
--]]

local Library = {}
Library.__index = Library

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- Resolve parent container based on execution context
local ParentGui
local success = pcall(function()
    ParentGui = game:GetService("CoreGui")
end)
if not success or not ParentGui then
    ParentGui = LocalPlayer:WaitForChild("PlayerGui")
end

-- Golden Color Palette
local Theme = {
    Background = Color3.fromRGB(15, 15, 15),
    Secondary = Color3.fromRGB(22, 22, 22),
    Border = Color3.fromRGB(40, 40, 40),
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
    local dragging
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

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
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
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = ParentGui
    })
    
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
    -- 1. Animated Loading Screen
    ---------------------------------------------------------
    local LoadingScreen = Create("Frame", {
        Name = "LoadingScreen",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(10, 10, 10),
        ZIndex = 10,
        Parent = ScreenGui
    })
    
    local LoadingContainer = Create("Frame", {
        Size = UDim2.new(0, 400, 0, 200),
        Position = UDim2.new(0.5, -200, 0.5, -100),
        BackgroundTransparency = 1,
        Parent = LoadingScreen
    })
    
    local LoadingTitle = Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundTransparency = 1,
        Text = "Sam's Hub",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 42,
        Parent = LoadingContainer
    })
    AddGoldGradient(LoadingTitle)
    
    local LoadingSubtitle = Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0, 50),
        BackgroundTransparency = 1,
        Text = "PREPARING MASTERPIECE...",
        TextColor3 = Theme.TextDark,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        Parent = LoadingContainer
    })
    
    local BarBG = Create("Frame", {
        Size = UDim2.new(0, 300, 0, 6),
        Position = UDim2.new(0.5, -150, 0.5, 20),
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        BorderSizePixel = 0,
        Parent = LoadingContainer
    })
    Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = BarBG})
    
    local BarFill = Create("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Theme.Primary,
        BorderSizePixel = 0,
        Parent = BarBG
    })
    Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = BarFill})
    AddGoldGradient(BarFill)
    
    local LoadingPercent = Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0, 120),
        BackgroundTransparency = 1,
        Text = "0%",
        TextColor3 = Theme.Primary,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        Parent = LoadingContainer
    })
    
    ---------------------------------------------------------
    -- 2. Main Window Creation (Starts Hidden)
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
    
    -- Fix bottom round corners for top bar
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
    
    -- Divider
    Create("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Theme.Border,
        BorderSizePixel = 0,
        Parent = TopBar
    })
    
    -- Draggable Topbar
    MakeDraggable(MainWindow, 0.12)
    
    -- Panel Split
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
    
    -- Bottom Footer (For descriptions)
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
    -- 3. Floating Toggle Screen UI
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
    
    -- Main toggle actions
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
    
    -- Close buttons interactions
    FloatingToggle.MouseButton1Click:Connect(ToggleUI)
    
    CloseBtn.MouseEnter:Connect(function()
        TweenService:Create(CloseBtn, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(255, 80, 80)}):Play()
    end)
    CloseBtn.MouseLeave:Connect(function()
        TweenService:Create(CloseBtn, TweenInfo.new(0.15), {TextColor3 = Theme.TextDark}):Play()
    end)
    
    -- Destructor unloads completely
    CloseBtn.MouseButton1Click:Connect(function()
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
    -- 4. Kick-off Loading Logic
    ---------------------------------------------------------
    local function PlayLoadingAnimation()
        local LoadingTween = TweenService:Create(BarFill, TweenInfo.new(2.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, 0, 1, 0)
        })
        LoadingTween:Play()
        
        local startTime = os.clock()
        local connection
        connection = RunService.RenderStepped:Connect(function()
            local elapsed = os.clock() - startTime
            local percent = math.clamp(elapsed / 2.8, 0, 1)
            LoadingPercent.Text = tostring(math.floor(percent * 100)) .. "%"
            if percent >= 1 then
                connection:Disconnect()
            end
        end)
        
        LoadingTween.Completed:Connect(function()
            TweenService:Create(LoadingScreen, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundTransparency = 1
            }):Play()
            
            -- Fade inner elements
            TweenService:Create(LoadingTitle, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
            TweenService:Create(LoadingSubtitle, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
            TweenService:Create(BarBG, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
            TweenService:Create(BarFill, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
            TweenService:Create(LoadingPercent, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
            
            task.wait(0.5)
            LoadingScreen:Destroy()
            
            -- Spawn Floating Toggle & Show main window
            FloatingToggle.Visible = true
            FloatingToggle.Size = UDim2.new(0, 0, 0, 0)
            TweenService:Create(FloatingToggle, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 50, 0, 50)
            }):Play()
            
            ToggleUI()
        end)
    end
    
    task.spawn(PlayLoadingAnimation)
    
    ---------------------------------------------------------
    -- 5. Windows Modules & Tab Handling
    ---------------------------------------------------------
    local Tabs = {}
    local ActiveTab = nil
    
    function self:CreateTab(tabName)
        local TabBtn = Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 32),
            BackgroundColor3 = Color3.fromRGB(24, 24, 24),
            Text = tabName,
            TextColor3 = Theme.TextDark,
            Font = Enum.Font.GothamMedium,
            TextSize = 13,
            BorderSizePixel = 0,
            Parent = TabContainer
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
            Parent = ContentContainer
        })
        Create("UIListLayout", {
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            Parent = Page
        })
        
        local function SelectTab()
            if ActiveTab then
                ActiveTab.Button.TextColor3 = Theme.TextDark
                ActiveTab.Button.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
                ActiveTab.Stroke.Color = Theme.Border
                ActiveTab.Page.Visible = false
            end
            
            ActiveTab = {Button = TabBtn, Page = Page, Stroke = TabStroke}
            TabBtn.TextColor3 = Theme.Primary
            TabBtn.BackgroundColor3 = Color3.fromRGB(30, 27, 18)
            TabStroke.Color = Theme.Primary
            Page.Visible = true
        end
        
        TabBtn.MouseButton1Click:Connect(SelectTab)
        if not ActiveTab then
            SelectTab()
        end
        
        local TabMethods = {}
        
        ---------------------------------------------------------
        -- Tab Method: Create Toggle
        ---------------------------------------------------------
        function TabMethods:CreateToggle(name, description, default, callback)
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
                TweenService:Create(ElementStroke, TweenInfo.new(0.15), {Color = Theme.Primary}):Play()
                UpdateFooter(description)
            end)
            
            ToggleFrame.MouseLeave:Connect(function()
                TweenService:Create(ElementStroke, TweenInfo.new(0.15), {Color = Theme.Border}):Play()
                ResetFooter()
            end)
            
            local ToggleObj = {}
            function ToggleObj:Set(newState)
                state = newState
                UpdateVisuals()
            end
            return ToggleObj
        end
        
        ---------------------------------------------------------
        -- Tab Method: Create Slider
        ---------------------------------------------------------
        function TabMethods:CreateSlider(name, description, min, max, default, callback)
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
                TweenService:Create(ElementStroke, TweenInfo.new(0.15), {Color = Theme.Primary}):Play()
                UpdateFooter(description)
            end)
            
            SliderFrame.MouseLeave:Connect(function()
                TweenService:Create(ElementStroke, TweenInfo.new(0.15), {Color = Theme.Border}):Play()
                ResetFooter()
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
        
        ---------------------------------------------------------
        -- Tab Method: Create Dropdown
        ---------------------------------------------------------
        function TabMethods:CreateDropdown(name, description, options, default, callback)
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
                        Populate() -- Updates text colors on items
                        task.spawn(function()
                            callback(opt)
                        end)
                    end)
                end
            end
            
            Populate()
            
            DropdownFrame.MouseEnter:Connect(function()
                TweenService:Create(ElementStroke, TweenInfo.new(0.15), {Color = Theme.Primary}):Play()
                UpdateFooter(description)
            end)
            
            DropdownFrame.MouseLeave:Connect(function()
                TweenService:Create(ElementStroke, TweenInfo.new(0.15), {Color = Theme.Border}):Play()
                ResetFooter()
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
        
        return TabMethods
    end
    
    return self
end

return Library
