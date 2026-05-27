--[[
    ENI UI Library v1.0
    A dark-themed, cyan-accented UI framework for Roblox Luau
    Loadstring compatible | 1000+ lines | Fully functional
    
    Usage:
        local Library = loadstring(game:HttpGet("URL_HERE"))()
        local Window = Library:CreateWindow("Hub Name")
        local Tab = Window:CreateTab("Tab Name")
        Tab:CreateButton("Button", function() end)
        Tab:CreateToggle("Toggle", false, function(state) end)
        Tab:CreateDropdown("Dropdown", {"Option1", "Option2"}, function(selected) end)
        Tab:CreateCheckbox("Checkbox", false, function(state) end)
]]

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui") or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

-- Constants
local COLORS = {
    Background = Color3.fromRGB(24, 24, 28),
    Secondary = Color3.fromRGB(32, 32, 38),
    Tertiary = Color3.fromRGB(40, 40, 48),
    Accent = Color3.fromRGB(0, 217, 255),       -- Cyan
    AccentDark = Color3.fromRGB(0, 180, 215),
    AccentLight = Color3.fromRGB(100, 235, 255),
    Text = Color3.fromRGB(220, 220, 228),
    TextDim = Color3.fromRGB(140, 140, 150),
    TextDark = Color3.fromRGB(100, 100, 110),
    Border = Color3.fromRGB(50, 50, 58),
    ToggleOn = Color3.fromRGB(0, 217, 255),
    ToggleOff = Color3.fromRGB(60, 60, 70),
    ScrollBar = Color3.fromRGB(60, 60, 72),
    ScrollBarBg = Color3.fromRGB(28, 28, 34)
}

local FONTS = {
    Title = Enum.Font.GothamBold,
    Header = Enum.Font.GothamSemibold,
    Body = Enum.Font.Gotham,
    Mono = Enum.Font.Code
}

local TWEEN_SETTINGS = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local TWEEN_FAST = TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

-- Utility Functions
local function createInstance(class, properties)
    local instance = Instance.new(class)
    for prop, value in pairs(properties or {}) do
        instance[prop] = value
    end
    return instance
end

local function applyTween(instance, properties, tweenInfo)
    tweenInfo = tweenInfo or TWEEN_SETTINGS
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

local function createCorner(parent, radius)
    return createInstance("UICorner", {
        Parent = parent,
        CornerRadius = UDim.new(0, radius or 6)
    })
end

local function createStroke(parent, thickness, color)
    return createInstance("UIStroke", {
        Parent = parent,
        Thickness = thickness or 1,
        Color = color or COLORS.Border,
        Transparency = 0.6
    })
end

local function createGradient(parent, rotation)
    return createInstance("UIGradient", {
        Parent = parent,
        Rotation = rotation or 0,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 50)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 30, 38))
        })
    })
end

-- Dropdown Handler (global to handle closing when clicking outside)
local activeDropdown = nil

-- ============================================
-- ELEMENT: Button
-- ============================================
local function createButton(parent, name, callback)
    local buttonFrame = createInstance("Frame", {
        Parent = parent,
        BackgroundColor3 = COLORS.Tertiary,
        Size = UDim2.new(1, -20, 0, 38),
        Position = UDim2.new(0, 10, 0, 0)
    })
    createCorner(buttonFrame, 5)
    createStroke(buttonFrame)

    local buttonText = createInstance("TextLabel", {
        Parent = buttonFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -16, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        Text = name,
        TextColor3 = COLORS.Text,
        Font = FONTS.Body,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    -- Hover effects
    local hoverTween, unHoverTween

    buttonFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            applyTween(buttonFrame, {BackgroundColor3 = COLORS.AccentDark}, TWEEN_FAST)
            task.wait(0.1)
            applyTween(buttonFrame, {BackgroundColor3 = COLORS.Accent}, TWEEN_FAST)
            if callback then
                task.spawn(callback)
            end
        end
    end)

    buttonFrame.MouseEnter:Connect(function()
        hoverTween = applyTween(buttonFrame, {BackgroundColor3 = COLORS.Accent}, TWEEN_FAST)
        applyTween(buttonText, {TextColor3 = Color3.fromRGB(20, 20, 25)}, TWEEN_FAST)
    end)

    buttonFrame.MouseLeave:Connect(function()
        if hoverTween then hoverTween:Cancel() end
        applyTween(buttonFrame, {BackgroundColor3 = COLORS.Tertiary}, TWEEN_FAST)
        applyTween(buttonText, {TextColor3 = COLORS.Text}, TWEEN_FAST)
    end)

    return buttonFrame
end

-- ============================================
-- ELEMENT: Toggle
-- ============================================
local function createToggle(parent, name, default, callback)
    local state = default or false
    local toggleFrame = createInstance("Frame", {
        Parent = parent,
        BackgroundColor3 = COLORS.Secondary,
        Size = UDim2.new(1, -20, 0, 42),
        Position = UDim2.new(0, 10, 0, 0)
    })
    createCorner(toggleFrame, 5)

    local toggleLabel = createInstance("TextLabel", {
        Parent = toggleFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(0.6, -12, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        Text = name,
        TextColor3 = COLORS.Text,
        Font = FONTS.Body,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    -- Toggle switch background
    local switchBg = createInstance("Frame", {
        Parent = toggleFrame,
        BackgroundColor3 = state and COLORS.Accent or COLORS.ToggleOff,
        Size = UDim2.new(0, 44, 0, 24),
        Position = UDim2.new(1, -56, 0.5, -12),
        BorderSizePixel = 0
    })
    createCorner(switchBg, 12)

    -- Toggle knob
    local knob = createInstance("Frame", {
        Parent = switchBg,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Size = UDim2.new(0, 18, 0, 18),
        Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9),
        BorderSizePixel = 0
    })
    createCorner(knob, 9)

    -- Click handler
    toggleFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            state = not state
            local targetColor = state and COLORS.Accent or COLORS.ToggleOff
            local targetPos = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)

            applyTween(switchBg, {BackgroundColor3 = targetColor}, TWEEN_FAST)
            applyTween(knob, {Position = targetPos}, TWEEN_FAST)

            if callback then
                task.spawn(callback, state)
            end
        end
    end)

    return toggleFrame, {
        SetState = function(newState)
            state = newState
            local targetColor = state and COLORS.Accent or COLORS.ToggleOff
            local targetPos = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
            applyTween(switchBg, {BackgroundColor3 = targetColor}, TWEEN_FAST)
            applyTween(knob, {Position = targetPos}, TWEEN_FAST)
        end,
        GetState = function()
            return state
        end
    }
end

-- ============================================
-- ELEMENT: Checkbox
-- ============================================
local function createCheckbox(parent, name, default, callback)
    local state = default or false
    local checkFrame = createInstance("Frame", {
        Parent = parent,
        BackgroundColor3 = COLORS.Secondary,
        Size = UDim2.new(1, -20, 0, 38),
        Position = UDim2.new(0, 10, 0, 0)
    })
    createCorner(checkFrame, 5)

    -- Checkbox visual square
    local checkBox = createInstance("Frame", {
        Parent = checkFrame,
        BackgroundColor3 = state and COLORS.Accent or COLORS.ToggleOff,
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(0, 10, 0.5, -10),
        BorderSizePixel = 0
    })
    createCorner(checkBox, 4)

    -- Checkmark
    local checkMark = createInstance("TextLabel", {
        Parent = checkBox,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "✓",
        TextColor3 = Color3.fromRGB(20, 20, 25),
        Font = FONTS.Header,
        TextSize = 14,
        TextTransparency = state and 0 or 1
    })

    local checkLabel = createInstance("TextLabel", {
        Parent = checkFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -42, 1, 0),
        Position = UDim2.new(0, 38, 0, 0),
        Text = name,
        TextColor3 = COLORS.Text,
        Font = FONTS.Body,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    checkFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            state = not state
            applyTween(checkBox, {
                BackgroundColor3 = state and COLORS.Accent or COLORS.ToggleOff
            }, TWEEN_FAST)
            applyTween(checkMark, {
                TextTransparency = state and 0 or 1
            }, TWEEN_FAST)

            if callback then
                task.spawn(callback, state)
            end
        end
    end)

    return checkFrame, {
        SetState = function(newState)
            state = newState
            applyTween(checkBox, {
                BackgroundColor3 = state and COLORS.Accent or COLORS.ToggleOff
            }, TWEEN_FAST)
            applyTween(checkMark, {
                TextTransparency = state and 0 or 1
            }, TWEEN_FAST)
        end,
        GetState = function()
            return state
        end
    }
end

-- ============================================
-- ELEMENT: Dropdown
-- ============================================
local function createDropdown(parent, name, options, callback)
    local selectedOption = options[1] or ""
    local isExpanded = false

    local dropdownFrame = createInstance("Frame", {
        Parent = parent,
        BackgroundColor3 = COLORS.Tertiary,
        Size = UDim2.new(1, -20, 0, 38),
        Position = UDim2.new(0, 10, 0, 0),
        ClipsDescendants = false
    })
    createCorner(dropdownFrame, 5)
    createStroke(dropdownFrame)

    local dropdownLabel = createInstance("TextLabel", {
        Parent = dropdownFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(0.4, -10, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        Text = name,
        TextColor3 = COLORS.TextDim,
        Font = FONTS.Body,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local selectedText = createInstance("TextLabel", {
        Parent = dropdownFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(0.5, -10, 1, 0),
        Position = UDim2.new(0.4, 0, 0, 0),
        Text = selectedOption,
        TextColor3 = COLORS.Text,
        Font = FONTS.Body,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd
    })

    -- Arrow indicator
    local arrow = createInstance("TextLabel", {
        Parent = dropdownFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(1, -26, 0.5, -10),
        Text = "▼",
        TextColor3 = COLORS.Accent,
        Font = FONTS.Body,
        TextSize = 12,
        Rotation = 0
    })

    -- Options container (will be placed below)
    local optionsContainer = createInstance("Frame", {
        Parent = parent,
        BackgroundColor3 = COLORS.Secondary,
        Size = UDim2.new(1, -20, 0, 0),
        Position = UDim2.new(0, 10, 0, 0),
        ClipsDescendants = true,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 10
    })
    createCorner(optionsContainer, 5)
    createStroke(optionsContainer, 1, COLORS.Accent)
    optionsContainer.ZIndex = 10

    local optionList = createInstance("UIListLayout", {
        Parent = optionsContainer,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2)
    })

    local optionFrames = {}

    -- Build option buttons
    local function buildOptions()
        -- Clear existing
        for _, opt in pairs(optionFrames) do
            opt:Destroy()
        end
        optionFrames = {}

        local totalHeight = 0
        for i, option in ipairs(options) do
            local optFrame = createInstance("TextButton", {
                Parent = optionsContainer,
                BackgroundColor3 = COLORS.Tertiary,
                Size = UDim2.new(1, -8, 0, 32),
                Position = UDim2.new(0, 4, 0, 0),
                Text = "",
                BorderSizePixel = 0,
                ZIndex = 10,
                AutoButtonColor = false
            })
            createCorner(optFrame, 4)

            local optLabel = createInstance("TextLabel", {
                Parent = optFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -16, 1, 0),
                Position = UDim2.new(0, 8, 0, 0),
                Text = option,
                TextColor3 = option == selectedOption and COLORS.Accent or COLORS.Text,
                Font = FONTS.Body,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 10
            })

            optFrame.MouseButton1Click:Connect(function()
                selectedOption = option
                selectedText.Text = option
                isExpanded = false
                optionsContainer.Visible = false
                activeDropdown = nil

                -- Update all option labels
                for _, of in pairs(optionFrames) do
                    local lbl = of:FindFirstChildOfClass("TextLabel")
                    if lbl then
                        lbl.TextColor3 = (lbl.Text == selectedOption) and COLORS.Accent or COLORS.Text
                    end
                end

                applyTween(arrow, {Rotation = 0}, TWEEN_FAST)

                if callback then
                    task.spawn(callback, selectedOption)
                end
            end)

            optFrame.MouseEnter:Connect(function()
                applyTween(optFrame, {BackgroundColor3 = COLORS.Accent}, TWEEN_FAST)
                applyTween(optLabel, {TextColor3 = Color3.fromRGB(20, 20, 25)}, TWEEN_FAST)
            end)

            optFrame.MouseLeave:Connect(function()
                local color = (optLabel.Text == selectedOption) and COLORS.Accent or COLORS.Tertiary
                local textColor = (optLabel.Text == selectedOption) and COLORS.Accent or COLORS.Text
                applyTween(optFrame, {BackgroundColor3 = color}, TWEEN_FAST)
                applyTween(optLabel, {TextColor3 = textColor}, TWEEN_FAST)
            end)

            table.insert(optionFrames, optFrame)
            totalHeight = totalHeight + 34
        end

        optionsContainer.Size = UDim2.new(1, -20, 0, totalHeight + 6)
    end

    buildOptions()

    -- Click handler for dropdown
    dropdownFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isExpanded = not isExpanded

            if isExpanded then
                if activeDropdown and activeDropdown ~= optionsContainer then
                    activeDropdown.Visible = false
                end
                activeDropdown = optionsContainer
                optionsContainer.Visible = true
                optionsContainer.ZIndex = 10
                applyTween(arrow, {Rotation = 180}, TWEEN_FAST)
            else
                optionsContainer.Visible = false
                activeDropdown = nil
                applyTween(arrow, {Rotation = 0}, TWEEN_FAST)
            end
        end
    end)

    -- Close dropdown when clicking elsewhere
    local function closeDropdown()
        if optionsContainer.Visible then
            optionsContainer.Visible = false
            isExpanded = false
            activeDropdown = nil
            applyTween(arrow, {Rotation = 0}, TWEEN_FAST)
        end
    end

    -- Update position tracking
    RunService.Heartbeat:Connect(function()
        if optionsContainer.Visible then
            local absPos = dropdownFrame.AbsolutePosition
            local absSize = dropdownFrame.AbsoluteSize
            optionsContainer.Position = UDim2.new(0, absPos.X - parent.AbsolutePosition.X + 10, 0, absPos.Y - parent.AbsolutePosition.Y + absSize.Y + 4)
        end
    end)

    return dropdownFrame, {
        SetOptions = function(newOptions)
            options = newOptions
            selectedOption = newOptions[1] or ""
            selectedText.Text = selectedOption
            buildOptions()
        end,
        GetSelected = function()
            return selectedOption
        end,
        Close = closeDropdown
    }, closeDropdown
end

-- ============================================
-- ELEMENT: Label
-- ============================================
local function createLabel(parent, text)
    local label = createInstance("TextLabel", {
        Parent = parent,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 0, 24),
        Position = UDim2.new(0, 10, 0, 0),
        Text = text,
        TextColor3 = COLORS.TextDim,
        Font = FONTS.Body,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    return label
end

-- ============================================
-- ELEMENT: Slider
-- ============================================
local function createSlider(parent, name, min, max, default, callback)
    min = min or 0
    max = max or 100
    local value = default or min
    local isDragging = false

    local sliderFrame = createInstance("Frame", {
        Parent = parent,
        BackgroundColor3 = COLORS.Secondary,
        Size = UDim2.new(1, -20, 0, 52),
        Position = UDim2.new(0, 10, 0, 0)
    })
    createCorner(sliderFrame, 5)

    local sliderLabel = createInstance("TextLabel", {
        Parent = sliderFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -24, 0, 20),
        Position = UDim2.new(0, 12, 0, 4),
        Text = name .. ": " .. tostring(value),
        TextColor3 = COLORS.Text,
        Font = FONTS.Body,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    -- Slider track
    local trackBg = createInstance("Frame", {
        Parent = sliderFrame,
        BackgroundColor3 = COLORS.ToggleOff,
        Size = UDim2.new(1, -24, 0, 6),
        Position = UDim2.new(0, 12, 0, 30),
        BorderSizePixel = 0
    })
    createCorner(trackBg, 3)

    local trackFill = createInstance("Frame", {
        Parent = trackBg,
        BackgroundColor3 = COLORS.Accent,
        Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
        BorderSizePixel = 0
    })
    createCorner(trackFill, 3)

    local knob = createInstance("Frame", {
        Parent = trackFill,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(1, -7, 0.5, -7),
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0.5)
    })
    createCorner(knob, 7)

    -- Slider interaction
    local function updateSlider(input)
        local mousePos = UserInputService:GetMouseLocation()
        local trackAbsPos = trackBg.AbsolutePosition
        local trackAbsSize = trackBg.AbsoluteSize
        local relativeX = math.clamp((mousePos.X - trackAbsPos.X) / trackAbsSize.X, 0, 1)
        value = math.floor(min + (max - min) * relativeX)

        trackFill.Size = UDim2.new(relativeX, 0, 1, 0)
        sliderLabel.Text = name .. ": " .. tostring(value)

        if callback then
            task.spawn(callback, value)
        end
    end

    trackBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            updateSlider(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)

    return sliderFrame, {
        SetValue = function(newValue)
            value = math.clamp(newValue, min, max)
            local ratio = (value - min) / (max - min)
            trackFill.Size = UDim2.new(ratio, 0, 1, 0)
            sliderLabel.Text = name .. ": " .. tostring(value)
        end,
        GetValue = function()
            return value
        end
    }
end

-- ============================================
-- ELEMENT: TextBox (Input)
-- ============================================
local function createTextBox(parent, name, placeholder, callback)
    local textBoxFrame = createInstance("Frame", {
        Parent = parent,
        BackgroundColor3 = COLORS.Tertiary,
        Size = UDim2.new(1, -20, 0, 42),
        Position = UDim2.new(0, 10, 0, 0)
    })
    createCorner(textBoxFrame, 5)
    createStroke(textBoxFrame)

    local textBoxLabel = createInstance("TextLabel", {
        Parent = textBoxFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(0.3, -10, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        Text = name,
        TextColor3 = COLORS.TextDim,
        Font = FONTS.Body,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local inputField = createInstance("TextBox", {
        Parent = textBoxFrame,
        BackgroundColor3 = COLORS.Secondary,
        Size = UDim2.new(0.65, -10, 0, 28),
        Position = UDim2.new(0.35, 0, 0.5, -14),
        Text = "",
        PlaceholderText = placeholder or "",
        PlaceholderColor3 = COLORS.TextDark,
        TextColor3 = COLORS.Text,
        Font = FONTS.Body,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        BorderSizePixel = 0
    })
    createCorner(inputField, 4)

    inputField.FocusLost:Connect(function(enterPressed)
        if callback then
            task.spawn(callback, inputField.Text, enterPressed)
        end
    end)

    return textBoxFrame, {
        GetText = function()
            return inputField.Text
        end,
        SetText = function(text)
            inputField.Text = text
        end
    }
end

-- ============================================
-- TAB CLASS
-- ============================================
local Tab = {}
Tab.__index = Tab

function Tab.new(parent, name, icon)
    local self = setmetatable({}, Tab)
    self.Name = name
    self.Parent = parent
    self.Elements = {}
    self.CloseCallbacks = {}

    -- Create scrolling container
    local tabContainer = createInstance("ScrollingFrame", {
        Parent = parent,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, -48),
        Position = UDim2.new(0, 0, 0, 48),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = COLORS.ScrollBar,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 2
    })

    local padding = createInstance("UIPadding", {
        Parent = tabContainer,
        PaddingTop = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 8)
    })

    local listLayout = createInstance("UIListLayout", {
        Parent = tabContainer,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6)
    })

    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tabContainer.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 16)
    end)

    self.Container = tabContainer
    self.ListLayout = listLayout

    -- Tab button (created by Window class, stored here)
    self.TabButton = nil

    return self
end

function Tab:CreateButton(name, callback)
    local btn = createButton(self.Container, name, callback)
    btn.LayoutOrder = #self.Elements + 1
    table.insert(self.Elements, {Type = "Button", Object = btn})
    return btn
end

function Tab:CreateToggle(name, default, callback)
    local toggle, controller = createToggle(self.Container, name, default, callback)
    toggle.LayoutOrder = #self.Elements + 1
    table.insert(self.Elements, {Type = "Toggle", Object = toggle, Controller = controller})
    return controller
end

function Tab:CreateCheckbox(name, default, callback)
    local checkbox, controller = createCheckbox(self.Container, name, default, callback)
    checkbox.LayoutOrder = #self.Elements + 1
    table.insert(self.Elements, {Type = "Checkbox", Object = checkbox, Controller = controller})
    return controller
end

function Tab:CreateDropdown(name, options, callback)
    local dropdown, controller, closeFunc = createDropdown(self.Container, name, options, callback)
    dropdown.LayoutOrder = #self.Elements + 1
    table.insert(self.Elements, {Type = "Dropdown", Object = dropdown, Controller = controller, Close = closeFunc})
    return controller
end

function Tab:CreateLabel(text)
    local label = createLabel(self.Container, text)
    label.LayoutOrder = #self.Elements + 1
    table.insert(self.Elements, {Type = "Label", Object = label})
    return label
end

function Tab:CreateSlider(name, min, max, default, callback)
    local slider, controller = createSlider(self.Container, name, min, max, default, callback)
    slider.LayoutOrder = #self.Elements + 1
    table.insert(self.Elements, {Type = "Slider", Object = slider, Controller = controller})
    return controller
end

function Tab:CreateTextBox(name, placeholder, callback)
    local textBox, controller = createTextBox(self.Container, name, placeholder, callback)
    textBox.LayoutOrder = #self.Elements + 1
    table.insert(self.Elements, {Type = "TextBox", Object = textBox, Controller = controller})
    return controller
end

function Tab:Show()
    self.Container.Visible = true
end

function Tab:Hide()
    self.Container.Visible = false
end

-- ============================================
-- WINDOW CLASS
-- ============================================
local Window = {}
Window.__index = Window

function Window.new(name)
    local self = setmetatable({}, Window)
    self.Name = name
    self.Tabs = {}
    self.ActiveTab = nil
    self.IsDragging = false
    self.DragStart = nil
    self.StartPos = nil

    -- Main window container
    local windowFrame = createInstance("Frame", {
        Parent = CoreGui,
        BackgroundColor3 = COLORS.Background,
        Size = UDim2.new(0, 580, 0, 440),
        Position = UDim2.new(0.5, -290, 0.5, -220),
        BorderSizePixel = 0,
        Active = true,
        Draggable = false
    })
    createCorner(windowFrame, 8)
    createStroke(windowFrame, 1.5, COLORS.Accent)

    -- Subtle inner shadow via gradient
    createGradient(windowFrame, 180)

    -- Title bar
    local titleBar = createInstance("Frame", {
        Parent = windowFrame,
        BackgroundColor3 = COLORS.Secondary,
        Size = UDim2.new(1, 0, 0, 42),
        BorderSizePixel = 0
    })
    createCorner(titleBar, 8)
    -- Square bottom corners
    local titleCornerFix = createInstance("Frame", {
        Parent = titleBar,
        BackgroundColor3 = COLORS.Secondary,
        Size = UDim2.new(1, 0, 0, 8),
        Position = UDim2.new(0, 0, 1, -8),
        BorderSizePixel = 0
    })

    -- Accent line under title
    local accentLine = createInstance("Frame", {
        Parent = titleBar,
        BackgroundColor3 = COLORS.Accent,
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, -2),
        BorderSizePixel = 0
    })

    -- Title text
    local titleText = createInstance("TextLabel", {
        Parent = titleBar,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -60, 1, 0),
        Position = UDim2.new(0, 16, 0, 0),
        Text = name,
        TextColor3 = COLORS.Text,
        Font = FONTS.Title,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    -- Close button
    local closeButton = createInstance("TextButton", {
        Parent = titleBar,
        BackgroundColor3 = Color3.fromRGB(255, 70, 70),
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(1, -36, 0.5, -14),
        Text = "✕",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = FONTS.Header,
        TextSize = 14,
        BorderSizePixel = 0,
        AutoButtonColor = false
    })
    createCorner(closeButton, 14)

    closeButton.MouseButton1Click:Connect(function()
        windowFrame:Destroy()
    end)

    closeButton.MouseEnter:Connect(function()
        applyTween(closeButton, {BackgroundColor3 = Color3.fromRGB(255, 40, 40)}, TWEEN_FAST)
    end)

    closeButton.MouseLeave:Connect(function()
        applyTween(closeButton, {BackgroundColor3 = Color3.fromRGB(255, 70, 70)}, TWEEN_FAST)
    end)

    -- Tab bar
    local tabBar = createInstance("Frame", {
        Parent = windowFrame,
        BackgroundColor3 = COLORS.Secondary,
        Size = UDim2.new(1, 0, 0, 48),
        Position = UDim2.new(0, 0, 0, 42),
        BorderSizePixel = 0
    })

    local tabListLayout = createInstance("UIListLayout", {
        Parent = tabBar,
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2),
        VerticalAlignment = Enum.VerticalAlignment.Center
    })

    local tabPadding = createInstance("UIPadding", {
        Parent = tabBar,
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8)
    })

    -- Content area
    local contentArea = createInstance("Frame", {
        Parent = windowFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, -90),
        Position = UDim2.new(0, 0, 0, 90),
        BorderSizePixel = 0,
        ZIndex = 1
    })

    -- Dragging logic
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.IsDragging = true
            self.DragStart = input.Position
            self.StartPos = windowFrame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    self.IsDragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if self.IsDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - self.DragStart
            windowFrame.Position = UDim2.new(
                self.StartPos.X.Scale,
                self.StartPos.X.Offset + delta.X,
                self.StartPos.Y.Scale,
                self.StartPos.Y.Offset + delta.Y
            )
        end
    end)

    self.Frame = windowFrame
    self.TitleBar = titleBar
    self.TabBar = tabBar
    self.ContentArea = contentArea
    self.TabListLayout = tabListLayout

    return self
end

function Window:CreateTab(name, icon)
    local tab = Tab.new(self.ContentArea, name, icon)
    local tabIndex = #self.Tabs + 1

    -- Create tab button
    local tabButton = createInstance("TextButton", {
        Parent = self.TabBar,
        BackgroundColor3 = COLORS.Tertiary,
        Size = UDim2.new(0, 100, 0, 32),
        Text = "",
        BorderSizePixel = 0,
        LayoutOrder = tabIndex,
        AutoButtonColor = false
    })
    createCorner(tabButton, 5)

    local tabButtonText = createInstance("TextLabel", {
        Parent = tabButton,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -12, 1, 0),
        Position = UDim2.new(0, 6, 0, 0),
        Text = icon and (icon .. " " .. name) or name,
        TextColor3 = COLORS.TextDim,
        Font = FONTS.Body,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Center
    })

    -- Active indicator dot
    local activeDot = createInstance("Frame", {
        Parent = tabButton,
        BackgroundColor3 = COLORS.Accent,
        Size = UDim2.new(0, 0, 0, 2),
        Position = UDim2.new(0.5, 0, 1, -2),
        AnchorPoint = Vector2.new(0.5, 0),
        BorderSizePixel = 0,
        Visible = false
    })
    createCorner(activeDot, 1)

    tab.TabButton = tabButton
    tab.TabButtonText = tabButtonText
    tab.ActiveDot = activeDot

    -- Click to switch tabs
    tabButton.MouseButton1Click:Connect(function()
        self:SwitchTab(tabIndex)
    end)

    table.insert(self.Tabs, tab)

    -- Auto-switch to first tab
    if tabIndex == 1 then
        self:SwitchTab(1)
    end

    return tab
end

function Window:SwitchTab(index)
    if self.ActiveTab then
        local prevTab = self.Tabs[self.ActiveTab]
        if prevTab then
            prevTab:Hide()
            applyTween(prevTab.TabButton, {BackgroundColor3 = COLORS.Tertiary}, TWEEN_FAST)
            applyTween(prevTab.TabButtonText, {TextColor3 = COLORS.TextDim}, TWEEN_FAST)
            prevTab.ActiveDot.Visible = false
            applyTween(prevTab.ActiveDot, {Size = UDim2.new(0, 0, 0, 2)}, TWEEN_FAST)
        end
    end

    local newTab = self.Tabs[index]
    if newTab then
        newTab:Show()
        applyTween(newTab.TabButton, {BackgroundColor3 = COLORS.Accent}, TWEEN_FAST)
        applyTween(newTab.TabButtonText, {TextColor3 = Color3.fromRGB(20, 20, 25)}, TWEEN_FAST)
        newTab.ActiveDot.Visible = true
        applyTween(newTab.ActiveDot, {Size = UDim2.new(0, 24, 0, 2)}, TWEEN_FAST)
        self.ActiveTab = index
    end
end

function Window:Destroy()
    self.Frame:Destroy()
end

-- ============================================
-- LIBRARY EXPORT
-- ============================================
local Library = {}

function Library:CreateWindow(name)
    local window = Window.new(name)
    return window
end

-- Global click handler to close dropdowns
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if activeDropdown then
            activeDropdown.Visible = false
            activeDropdown = nil
        end
    end
end)

return Library
