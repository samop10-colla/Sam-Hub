--[[
    Sam's Hub - UI Library Framework
    Theme: Golden
    Description: A clean, modular, and animated UI framework for Roblox.
]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

-- Configuration
local Theme = {
    Background = Color3.fromRGB(20, 20, 20),
    Container = Color3.fromRGB(28, 28, 28),
    Element = Color3.fromRGB(35, 35, 35),
    ElementHover = Color3.fromRGB(45, 45, 45),
    Gold = Color3.fromRGB(255, 215, 0),
    DarkGold = Color3.fromRGB(180, 150, 0),
    Text = Color3.fromRGB(255, 255, 255),
    SubText = Color3.fromRGB(170, 170, 170)
}

local TweenSettings = {
    Fast = TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
    Medium = TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
    Slow = TweenInfo.new(0.8, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
}

-- Utility: Make UI Draggable
local function MakeDraggable(topbarObject, object)
    local dragging, dragInput, dragStart, startPos
    
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
            TweenService:Create(object, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
                Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            }):Play()
        end
    end)
end

-- Utility: Instance Creator
local function Create(className, properties, children)
    local inst = Instance.new(className)
    for k, v in pairs(properties or {}) do inst[k] = v end
    for _, child in pairs(children or {}) do child.Parent = inst end
    return inst
end

-- Library Object
local SamsHub = {}

function SamsHub:CreateWindow(config)
    config = config or {}
    local WindowName = config.Name or "Sam's Hub"
    
    -- Main GUI Setup
    local ScreenGui = Create("ScreenGui", {
        Name = "SamsHub_Framework",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })
    
    -- Protect GUI (Fallback to PlayerGui if CoreGui is restricted)
    local success = pcall(function() ScreenGui.Parent = CoreGui end)
    if not success then ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end

    -- ==========================================
    -- 1. LOADING SCREEN
    -- ==========================================
    local LoadingFrame = Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Theme.Background,
        ZIndex = 100,
        Parent = ScreenGui
    }, {
        Create("TextLabel", {
            Text = WindowName,
            Font = Enum.Font.GothamBold,
            TextSize = 40,
            TextColor3 = Theme.Gold,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 50),
            Position = UDim2.new(0, 0, 0.4, 0),
            ZIndex = 101
        }),
        Create("Frame", {
            Name = "BarBackground",
            Size = UDim2.new(0, 300, 0, 6),
            Position = UDim2.new(0.5, -150, 0.5, 20),
            BackgroundColor3 = Theme.Container,
            ZIndex = 101
        }, {
            Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
            Create("Frame", {
                Name = "BarFill",
                Size = UDim2.new(0, 0, 1, 0),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                ZIndex = 102
            }, {
                Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
                Create("UIGradient", {
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Theme.DarkGold),
                        ColorSequenceKeypoint.new(1, Theme.Gold)
                    })
                })
            })
        })
    })

    -- Loading Animation Sequence
    local BarFill = LoadingFrame.BarBackground.BarFill
    TweenService:Create(BarFill, TweenInfo.new(2.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 1, 0)}):Play()
    task.wait(2.7)
    
    TweenService:Create(LoadingFrame, TweenSettings.Medium, {BackgroundTransparency = 1}):Play()
    for _, child in pairs(LoadingFrame:GetChildren()) do
        if child:IsA("GuiObject") then
            TweenService:Create(child, TweenSettings.Medium, {BackgroundTransparency = 1}):Play()
            if child:IsA("TextLabel") then
                TweenService:Create(child, TweenSettings.Medium, {TextTransparency = 1}):Play()
            end
        end
    end
    task.wait(0.5)
    LoadingFrame:Destroy()

    -- ==========================================
    -- 2. MAIN WINDOW & TOGGLE
    -- ==========================================
    local MainUI = Create("Frame", {
        Name = "MainUI",
        Size = UDim2.new(0, 550, 0, 350),
        Position = UDim2.new(0.5, -275, 0.5, -175),
        BackgroundColor3 = Theme.Background,
        ClipsDescendants = true,
        Parent = ScreenGui
    }, {
        Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
        Create("UIStroke", { Color = Theme.Gold, Thickness = 1 }),
        
        -- Top Bar
        Create("Frame", {
            Name = "TopBar",
            Size = UDim2.new(1, 0, 0, 40),
            BackgroundTransparency = 1
        }, {
            Create("TextLabel", {
                Text = WindowName,
                Font = Enum.Font.GothamBold,
                TextSize = 16,
                TextColor3 = Theme.Gold,
                Size = UDim2.new(1, -50, 1, 0),
                Position = UDim2.new(0, 15, 0, 0),
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1
            }),
            Create("TextButton", { -- Close Button
                Name = "CloseBtn",
                Text = "X",
                Font = Enum.Font.GothamBold,
                TextSize = 18,
                TextColor3 = Theme.Text,
                Size = UDim2.new(0, 40, 0, 40),
                Position = UDim2.new(1, -40, 0, 0),
                BackgroundTransparency = 1
            })
        }),

        -- Left Tab Container
        Create("Frame", {
            Name = "Sidebar",
            Size = UDim2.new(0, 140, 1, -40),
            Position = UDim2.new(0, 0, 0, 40),
            BackgroundColor3 = Theme.Container,
            BorderSizePixel = 0
        }, {
            Create("ScrollingFrame", {
                Name = "TabList",
                Size = UDim2.new(1, 0, 1, -10),
                Position = UDim2.new(0, 0, 0, 5),
                BackgroundTransparency = 1,
                ScrollBarThickness = 0,
                CanvasSize = UDim2.new(0, 0, 0, 0)
            }, {
                Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5) }),
                Create("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) })
            })
        }),

        -- Right Element Container
        Create("Frame", {
            Name = "ElementContainer",
            Size = UDim2.new(1, -140, 1, -40),
            Position = UDim2.new(0, 140, 0, 40),
            BackgroundTransparency = 1
        })
    })

    MakeDraggable(MainUI.TopBar, MainUI)

    -- "S" Draggable Toggle Button
    local ToggleUI = Create("TextButton", {
        Name = "ToggleUI",
        Text = "S",
        Font = Enum.Font.GothamBold,
        TextSize = 24,
        TextColor3 = Theme.Background,
        BackgroundColor3 = Theme.Gold,
        Size = UDim2.new(0, 50, 0, 50),
        Position = UDim2.new(0, 20, 0.5, -25),
        Parent = ScreenGui
    }, {
        Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
        Create("UIStroke", { Color = Theme.DarkGold, Thickness = 2 })
    })

    MakeDraggable(ToggleUI, ToggleUI)

    -- Toggle Logic
    local uiOpen = true
    ToggleUI.MouseButton1Click:Connect(function()
        uiOpen = not uiOpen
        if uiOpen then
            MainUI.Visible = true
            TweenService:Create(MainUI, TweenSettings.Fast, {Size = UDim2.new(0, 550, 0, 350)}):Play()
        else
            local closeTween = TweenService:Create(MainUI, TweenSettings.Fast, {Size = UDim2.new(0, 550, 0, 0)})
            closeTween:Play()
            closeTween.Completed:Connect(function()
                if not uiOpen then MainUI.Visible = false end
            end)
        end
    end)

    -- Unload Logic
    MainUI.TopBar.CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    -- ==========================================
    -- 3. TAB & ELEMENT SYSTEM
    -- ==========================================
    local WindowAPI = {}
    local FirstTab = true

    function WindowAPI:CreateTab(tabName)
        local TabButton = Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundColor3 = Theme.Element,
            Text = tabName,
            Font = Enum.Font.GothamSemibold,
            TextSize = 14,
            TextColor3 = Theme.SubText,
            Parent = MainUI.Sidebar.TabList
        }, { Create("UICorner", { CornerRadius = UDim.new(0, 6) }) })

        local TabContainer = Create("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Theme.Gold,
            Visible = FirstTab,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Parent = MainUI.ElementContainer
        }, {
            Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8) }),
            Create("UIPadding", { PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) })
        })

        if FirstTab then
            TabButton.TextColor3 = Theme.Gold
            TabButton.BackgroundColor3 = Theme.ElementHover
            FirstTab = false
        end

        TabButton.MouseButton1Click:Connect(function()
            for _, frame in pairs(MainUI.ElementContainer:GetChildren()) do
                if frame:IsA("ScrollingFrame") then frame.Visible = false end
            end
            for _, btn in pairs(MainUI.Sidebar.TabList:GetChildren()) do
                if btn:IsA("TextButton") then
                    TweenService:Create(btn, TweenSettings.Fast, {BackgroundColor3 = Theme.Element, TextColor3 = Theme.SubText}):Play()
                end
            end
            TabContainer.Visible = true
            TweenService:Create(TabButton, TweenSettings.Fast, {BackgroundColor3 = Theme.ElementHover, TextColor3 = Theme.Gold}):Play()
        end)

        TabContainer.ChildAdded:Connect(function()
            local layout = TabContainer:FindFirstChildOfClass("UIListLayout")
            TabContainer.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
        end)

        local TabAPI = {}

        function TabAPI:CreateDescription(text)
            Create("TextLabel", {
                Size = UDim2.new(1, 0, 0, 20),
                BackgroundTransparency = 1,
                Text = text,
                Font = Enum.Font.Gotham,
                TextSize = 13,
                TextColor3 = Theme.SubText,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = TabContainer
            })
        end

        function TabAPI:CreateButton(name, callback)
            local Btn = Create("TextButton", {
                Size = UDim2.new(1, 0, 0, 35),
                BackgroundColor3 = Theme.Element,
                Text = "  " .. name,
                Font = Enum.Font.GothamSemibold,
                TextSize = 14,
                TextColor3 = Theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = TabContainer
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
                Create("UIStroke", { Color = Theme.Container, Thickness = 1 })
            })

            Btn.MouseButton1Click:Connect(function()
                TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.Gold}):Play()
                task.wait(0.1)
                TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.ElementHover}):Play()
                if callback then callback() end
            end)

            Btn.MouseEnter:Connect(function() TweenService:Create(Btn, TweenSettings.Fast, {BackgroundColor3 = Theme.ElementHover}):Play() end)
            Btn.MouseLeave:Connect(function() TweenService:Create(Btn, TweenSettings.Fast, {BackgroundColor3 = Theme.Element}):Play() end)
        end

        function TabAPI:CreateToggle(name, default, callback)
            local state = default or false
            
            local ToggleFrame = Create("TextButton", {
                Size = UDim2.new(1, 0, 0, 35),
                BackgroundColor3 = Theme.Element,
                Text = "  " .. name,
                Font = Enum.Font.GothamSemibold,
                TextSize = 14,
                TextColor3 = Theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = TabContainer
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
                Create("Frame", {
                    Name = "IndicatorBg",
                    Size = UDim2.new(0, 40, 0, 20),
                    Position = UDim2.new(1, -50, 0.5, -10),
                    BackgroundColor3 = state and Theme.Gold or Theme.Container,
                }, {
                    Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
                    Create("Frame", {
                        Name = "Circle",
                        Size = UDim2.new(0, 16, 0, 16),
                        Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    }, { Create("UICorner", { CornerRadius = UDim.new(1, 0) }) })
                })
            })

            local function Fire()
                state = not state
                local bg = ToggleFrame.IndicatorBg
                TweenService:Create(bg, TweenSettings.Fast, {BackgroundColor3 = state and Theme.Gold or Theme.Container}):Play()
                TweenService:Create(bg.Circle, TweenSettings.Fast, {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
                if callback then callback(state) end
            end

            ToggleFrame.MouseButton1Click:Connect(Fire)
        end

        function TabAPI:CreateSlider(name, min, max, default, callback)
            local val = default or min
            
            local SliderFrame = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 50),
                BackgroundColor3 = Theme.Element,
                Parent = TabContainer
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
                Create("TextLabel", {
                    Text = "  " .. name,
                    Font = Enum.Font.GothamSemibold,
                    TextSize = 14,
                    TextColor3 = Theme.Text,
                    Size = UDim2.new(1, 0, 0, 25),
                    BackgroundTransparency = 1,
                    TextXAlignment = Enum.TextXAlignment.Left
                }),
                Create("TextLabel", {
                    Name = "ValueLabel",
                    Text = tostring(val),
                    Font = Enum.Font.Gotham,
                    TextSize = 14,
                    TextColor3 = Theme.Gold,
                    Size = UDim2.new(0, 50, 0, 25),
                    Position = UDim2.new(1, -60, 0, 0),
                    BackgroundTransparency = 1,
                    TextXAlignment = Enum.TextXAlignment.Right
                }),
                Create("TextButton", {
                    Name = "BarArea",
                    Size = UDim2.new(1, -20, 0, 6),
                    Position = UDim2.new(0, 10, 0, 35),
                    BackgroundColor3 = Theme.Container,
                    Text = ""
                }, {
                    Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
                    Create("Frame", {
                        Name = "Fill",
                        Size = UDim2.new((val - min) / (max - min), 0, 1, 0),
                        BackgroundColor3 = Theme.Gold
                    }, { Create("UICorner", { CornerRadius = UDim.new(1, 0) }) })
                })
            })

            local dragging = false
            local bar = SliderFrame.BarArea
            local fill = bar.Fill
            local valLabel = SliderFrame.ValueLabel

            local function Update(input)
                local mathHelper = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                local trueVal = math.floor(min + ((max - min) * mathHelper))
                TweenService:Create(fill, TweenInfo.new(0.05), {Size = UDim2.new(mathHelper, 0, 1, 0)}):Play()
                valLabel.Text = tostring(trueVal)
                if callback then callback(trueVal) end
            end

            bar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    Update(input)
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    Update(input)
                end
            end)
        end

        function TabAPI:CreateDropdown(name, options, default, callback)
            local isOpen = false
            
            local DropdownBtn = Create("TextButton", {
                Size = UDim2.new(1, 0, 0, 35),
                BackgroundColor3 = Theme.Element,
                Text = "  " .. name .. " : " .. (default or "None"),
                Font = Enum.Font.GothamSemibold,
                TextSize = 14,
                TextColor3 = Theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                ClipsDescendants = true,
                Parent = TabContainer
            }, {
                Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
                Create("TextLabel", {
                    Name = "Arrow",
                    Text = "+",
                    Font = Enum.Font.GothamBold,
                    TextSize = 18,
                    TextColor3 = Theme.Gold,
                    Size = UDim2.new(0, 35, 0, 35),
                    Position = UDim2.new(1, -35, 0, 0),
                    BackgroundTransparency = 1
                }),
                Create("Frame", {
                    Name = "ListContainer",
                    Size = UDim2.new(1, 0, 0, 0), -- Updated dynamically
                    Position = UDim2.new(0, 0, 0, 35),
                    BackgroundTransparency = 1
                }, {
                    Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder })
                })
            })

            local List = DropdownBtn.ListContainer

            for _, opt in pairs(options) do
                local OptBtn = Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundColor3 = Theme.Container,
                    Text = opt,
                    Font = Enum.Font.Gotham,
                    TextSize = 13,
                    TextColor3 = Theme.SubText
                }, { Create("UIStroke", { Color = Theme.Element, Thickness = 1 }) })
                
                OptBtn.Parent = List

                OptBtn.MouseButton1Click:Connect(function()
                    DropdownBtn.Text = "  " .. name .. " : " .. opt
                    isOpen = false
                    TweenService:Create(DropdownBtn, TweenSettings.Fast, {Size = UDim2.new(1, 0, 0, 35)}):Play()
                    DropdownBtn.Arrow.Text = "+"
                    if callback then callback(opt) end
                end)
                
                OptBtn.MouseEnter:Connect(function() TweenService:Create(OptBtn, TweenSettings.Fast, {TextColor3 = Theme.Gold}):Play() end)
                OptBtn.MouseLeave:Connect(function() TweenService:Create(OptBtn, TweenSettings.Fast, {TextColor3 = Theme.SubText}):Play() end)
            end

            DropdownBtn.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                local totalHeight = 35 + (#options * 30)
                
                if isOpen then
                    DropdownBtn.Arrow.Text = "-"
                    TweenService:Create(DropdownBtn, TweenSettings.Fast, {Size = UDim2.new(1, 0, 0, totalHeight)}):Play()
                else
                    DropdownBtn.Arrow.Text = "+"
                    TweenService:Create(DropdownBtn, TweenSettings.Fast, {Size = UDim2.new(1, 0, 0, 35)}):Play()
                end
            end)
        end

        return TabAPI
    end

    return WindowAPI
end

return SamsHub

--[[ 
    -- EXAMPE USAGE (Copy and paste in your executor / local script) :
    
    local SamsHub = loadstring(...) -- Assuming you hosted the file
    
    local Window = SamsHub:CreateWindow({ Name = "Sam's Hub" })
    
    local MainTab = Window:CreateTab("Main")
    MainTab:CreateDescription("Welcome to the finest Golden UI!")
    
    MainTab:CreateButton("Print Hello", function()
        print("Hello World!")
    end)
    
    MainTab:CreateToggle("Aimbot", false, function(state)
        print("Aimbot is:", state)
    end)
    
    MainTab:CreateSlider("FOV", 10, 120, 70, function(val)
        print("FOV set to:", val)
    end)
    
    MainTab:CreateDropdown("Select Player", {"Player1", "Player2", "Player3"}, "Player1", function(selected)
        print("Selected:", selected)
    end)
]]
