--[[
    OG GUI Library for Roblox
    Version: 1.0.0
    Author: Custom OG Design
    
    A modular, original GUI library for Roblox that can be loaded via loadstring()
    Features: Modern design, responsive layout, theme support, and comprehensive UI elements
--]]

local OGLib = {}
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

-- Library Configuration
local Config = {
    MainSize = UDim2.new(0, 700, 0, 450), -- Adjusted for wider layout based on reference
    MinimizedSize = UDim2.new(0, 50, 0, 50),
    AnimationSpeed = 0.2, -- Slightly faster for smoother feel
    DefaultTheme = "manga"
}

-- Theme System
local Themes = {
    dark = {
        Primary = Color3.fromRGB(25, 25, 30),
        Secondary = Color3.fromRGB(35, 35, 40),
        Accent = Color3.fromRGB(0, 162, 255),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(200, 200, 200),
        Border = Color3.fromRGB(60, 60, 70),
        Success = Color3.fromRGB(46, 204, 113),
        Warning = Color3.fromRGB(241, 196, 15),
        Error = Color3.fromRGB(231, 76, 60)
    },
    light = {
        Primary = Color3.fromRGB(245, 245, 250),
        Secondary = Color3.fromRGB(255, 255, 255),
        Accent = Color3.fromRGB(0, 122, 255),
        Text = Color3.fromRGB(0, 0, 0),
        TextSecondary = Color3.fromRGB(100, 100, 100),
        Border = Color3.fromRGB(220, 220, 230),
        Success = Color3.fromRGB(52, 199, 89),
        Warning = Color3.fromRGB(255, 149, 0),
        Error = Color3.fromRGB(255, 59, 48)
    },
    manga = {
        Primary = Color3.fromRGB(15, 15, 18),
        Secondary = Color3.fromRGB(25, 25, 28),
        Accent = Color3.fromRGB(255, 255, 255),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(200, 200, 200),
        Border = Color3.fromRGB(45, 45, 50),
        Success = Color3.fromRGB(255, 255, 255),
        Warning = Color3.fromRGB(255, 204, 0),
        Error = Color3.fromRGB(255, 80, 80),
        Transparent = 0.15 -- Special transparency for manga theme
    }
}

-- Global Variables
local Library = {}
Library.Flags = {}
Library.Connections = {}
local CurrentTheme = Themes[Config.DefaultTheme]

-- Utility Functions
local function CreateTween(object, properties, duration, easingStyle, easingDirection)
    local info = TweenInfo.new(
        duration or Config.AnimationSpeed,
        easingStyle or Enum.EasingStyle.Quad,
        easingDirection or Enum.EasingDirection.Out
    )
    return TweenService:Create(object, info, properties)
end

local function CreateUIElement(className, properties)
    local element = Instance.new(className)
    for property, value in pairs(properties) do
        element[property] = value
    end
    return element
end

local function ApplyTheme(element, themeProperty)
    if themeProperty and CurrentTheme[themeProperty] then
        element.BackgroundColor3 = CurrentTheme[themeProperty]
    end
end

local function CreateCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 6)
    corner.Parent = parent
    return corner
end

local function CreateStroke(parent, thickness, color)
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = thickness or 1
    stroke.Color = color or CurrentTheme.Border
    stroke.Parent = parent
    return stroke
}

local function CreatePadding(parent, padding)
    local uiPadding = Instance.new("UIPadding")
    if typeof(padding) == "number" then
        uiPadding.PaddingTop = UDim.new(0, padding)
        uiPadding.PaddingBottom = UDim.new(0, padding)
        uiPadding.PaddingLeft = UDim.new(0, padding)
        uiPadding.PaddingRight = UDim.new(0, padding)
    elseif typeof(padding) == "table" then
        uiPadding.PaddingTop = UDim.new(0, padding.Top or 0)
        uiPadding.PaddingBottom = UDim.new(0, padding.Bottom or 0)
        uiPadding.PaddingLeft = UDim.new(0, padding.Left or 0)
        uiPadding.PaddingRight = UDim.new(0, padding.Right or 0)
    end
    uiPadding.Parent = parent
    return uiPadding
end

-- Main Library Object
function OGLib:CreateWindow(options)
    local Window = {}
    Window.Tabs = {}
    Window.CurrentTab = nil
    Window.IsMinimized = false
    
    -- Default options
    options = options or {}
    options.Title = options.Title or "OG GUI Library"
    options.Theme = options.Theme or Config.DefaultTheme
    options.Logo = options.Logo or nil
    
    -- Set theme
    if Themes[options.Theme] then
        CurrentTheme = Themes[options.Theme]
    end
    
    -- Create Main GUI
    local ScreenGui = CreateUIElement("ScreenGui", {
        Name = "OGLibrary_" .. HttpService:GenerateGUID(false),
        Parent = Players.LocalPlayer:WaitForChild("PlayerGui"),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    
    -- Main Frame
    local MainFrame = CreateUIElement("Frame", {
        Name = "MainFrame",
        Parent = ScreenGui,
        Size = Config.MainSize,
        Position = UDim2.new(0.5, -Config.MainSize.X.Offset / 2, 0.5, -Config.MainSize.Y.Offset / 2), -- Center the frame
        BackgroundColor3 = CurrentTheme.Primary,
        BackgroundTransparency = CurrentTheme.Transparent or 0,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Active = true,
        Draggable = false -- We'll handle dragging manually
    })
    
    CreateCorner(MainFrame, 8)
    CreateStroke(MainFrame, 2, CurrentTheme.Border)
    
    -- Make draggable function that works for any frame
    local function MakeDraggable(frame, dragArea)
        local dragging = false
        local dragStart = nil
        local startPos = nil
        local dragConnection = nil
        
        local function Update(input)
            if dragging then
                local delta = input.Position - dragStart
                frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end
        
        local function StartDrag(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = frame.Position
                
                -- Connect to UserInputService for global mouse tracking
                dragConnection = UserInputService.InputChanged:Connect(function(inputObject)
                    if inputObject.UserInputType == Enum.UserInputType.MouseMovement or inputObject.UserInputType == Enum.UserInputType.Touch then
                        Update(inputObject)
                    end
                end)
            end
        end
        
        local function EndDrag()
            dragging = false
            if dragConnection then
                dragConnection:Disconnect()
                dragConnection = nil
            end
        end
        
        -- Connect drag to the specified area
        dragArea.InputBegan:Connect(StartDrag)
        
        -- Global input end to stop dragging
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                EndDrag()
            end
        end)
    end
    
    -- Header
    local Header = CreateUIElement("Frame", {
        Name = "Header",
        Parent = MainFrame,
        Size = UDim2.new(1, 0, 0, 45),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = CurrentTheme.Secondary,
        BackgroundTransparency = CurrentTheme.Transparent and (CurrentTheme.Transparent / 2) or 0,
        BorderSizePixel = 0,
        Active = true
    })
    
    CreateCorner(Header, 8)
    CreateStroke(Header, 1, CurrentTheme.Border)
    
    -- Make the window draggable by the header
    MakeDraggable(MainFrame, Header)
    
    -- Logo (if provided)
    local LogoFrame = nil
    local MinimizedLogo = nil
    if options.Logo then
        LogoFrame = CreateUIElement("ImageLabel", {
            Name = "Logo",
            Parent = Header,
            Size = UDim2.new(0, 32, 0, 32),
            Position = UDim2.new(0, 8, 0, 6),
            BackgroundTransparency = 1,
            Image = options.Logo,
            ScaleType = Enum.ScaleType.Fit
        })
        CreateCorner(LogoFrame, 4)
        
        -- Create minimized logo
        MinimizedLogo = CreateUIElement("ImageButton", {
            Name = "MinimizedLogo",
            Parent = ScreenGui,
            Size = UDim2.new(0, 50, 0, 50),
            Position = UDim2.new(1, -60, 0, 10),
            BackgroundColor3 = CurrentTheme.Secondary,
            BackgroundTransparency = CurrentTheme.Transparent or 0,
            Image = options.Logo,
            ScaleType = Enum.ScaleType.Fit,
            Visible = false,
            Active = true
        })
        CreateCorner(MinimizedLogo, 8)
        CreateStroke(MinimizedLogo, 2, CurrentTheme.Border)
        
        -- Make minimized logo draggable
        MakeDraggable(MinimizedLogo, MinimizedLogo)
    end
    
    -- Title
    local Title = CreateUIElement("TextLabel", {
        Name = "Title",
        Parent = Header,
        Size = UDim2.new(1, LogoFrame and -90 or -50, 1, 0),
        Position = UDim2.new(0, LogoFrame and 48 or 12, 0, 0),
        BackgroundTransparency = 1,
        Text = options.Title,
        TextColor3 = CurrentTheme.Text,
        TextScaled = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamBold
    })
    
    -- Minimize Button
    local MinimizeButton = CreateUIElement("TextButton", {
        Name = "MinimizeButton",
        Parent = Header,
        Size = UDim2.new(0, 35, 0, 35),
        Position = UDim2.new(1, -40, 0, 5),
        BackgroundColor3 = CurrentTheme.Secondary,
        BackgroundTransparency = CurrentTheme.Transparent and (CurrentTheme.Transparent / 2) or 0,
        BorderSizePixel = 0,
        Text = "−",
        TextColor3 = CurrentTheme.Text,
        TextScaled = true,
        Font = Enum.Font.GothamBold,
        ZIndex = 2
    })
    
    CreateCorner(MinimizeButton, 4)
    CreateStroke(MinimizeButton, 1, CurrentTheme.Border)
    
    -- Tab Container
    local TabContainer = CreateUIElement("Frame", {
        Name = "TabContainer",
        Parent = MainFrame,
        Size = UDim2.new(0, 140, 1, -45),
        Position = UDim2.new(0, 0, 0, 45),
        BackgroundColor3 = CurrentTheme.Secondary,
        BackgroundTransparency = CurrentTheme.Transparent and (CurrentTheme.Transparent / 2) or 0,
        BorderSizePixel = 0
    })
    
    CreateStroke(TabContainer, 1, CurrentTheme.Border)
    
    local TabList = CreateUIElement("ScrollingFrame", {
        Name = "TabList",
        Parent = TabContainer,
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = CurrentTheme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y
    })
    
    local TabListLayout = CreateUIElement("UIListLayout", {
        Parent = TabList,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2)
    })
    
    CreatePadding(TabList, 8)
    
    -- Content Container
    local ContentContainer = CreateUIElement("Frame", {
        Name = "ContentContainer",
        Parent = MainFrame,
        Size = UDim2.new(1, -140, 1, -45),
        Position = UDim2.new(0, 140, 0, 45),
        BackgroundColor3 = CurrentTheme.Primary,
        BackgroundTransparency = CurrentTheme.Transparent or 0,
        BorderSizePixel = 0
    })
    
    -- Minimize functionality
    local minimizeToLogo = options.Logo ~= nil
    
    MinimizeButton.MouseButton1Click:Connect(function()
        Window.IsMinimized = not Window.IsMinimized
        
        if Window.IsMinimized then
            if minimizeToLogo and MinimizedLogo then
                -- Hide main window and show minimized logo
                MainFrame.Visible = false
                MinimizedLogo.Visible = true
            else
                -- Default minimize behavior
                CreateTween(MainFrame, {
                    Size = Config.MinimizedSize,
                    Position = UDim2.new(1, -60, 0, 10)
                }):Play()
                MinimizeButton.Text = "+"
                TabContainer.Visible = false
                ContentContainer.Visible = false
                Title.Visible = false
                if LogoFrame then LogoFrame.Visible = false end
            end
        else
            -- Restore window
            if minimizeToLogo and MinimizedLogo then
                MainFrame.Visible = true
                MinimizedLogo.Visible = false
            else
                CreateTween(MainFrame, {
                    Size = Config.MainSize,
                    Position = UDim2.new(0.5, -Config.MainSize.X.Offset / 2, 0.5, -Config.MainSize.Y.Offset / 2)
                }):Play()
                MinimizeButton.Text = "−"
                TabContainer.Visible = true
                ContentContainer.Visible = true
                Title.Visible = true
                if LogoFrame then LogoFrame.Visible = true end
            end
        end
    end)
    
    -- Click minimized logo to restore
    if MinimizedLogo then
        MinimizedLogo.MouseButton1Click:Connect(function()
            Window.IsMinimized = false
            MainFrame.Visible = true
            MinimizedLogo.Visible = false
        end)
    end
    
    -- Hover effects for minimize button
    MinimizeButton.MouseEnter:Connect(function()
        CreateTween(MinimizeButton, {BackgroundColor3 = CurrentTheme.Accent}, Config.AnimationSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out):Play()
    end)
    
    MinimizeButton.MouseLeave:Connect(function()
        CreateTween(MinimizeButton, {BackgroundColor3 = CurrentTheme.Secondary}, Config.AnimationSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out):Play()
    end)
    
    -- Window Methods
    function Window:CreateTab(name)
        local Tab = {}
        Tab.Name = name
        Tab.Elements = {}
        Tab.Active = false
        
        -- Tab Button
        local TabButton = CreateUIElement("TextButton", {
            Name = "TabButton_" .. name,
            Parent = TabList,
            Size = UDim2.new(1, -10, 0, 35),
            BackgroundColor3 = CurrentTheme.Primary,
            BackgroundTransparency = CurrentTheme.Transparent and (CurrentTheme.Transparent / 3) or 0,
            BorderSizePixel = 0,
            Text = name,
            TextColor3 = CurrentTheme.TextSecondary,
            TextScaled = true,
            Font = Enum.Font.Gotham,
            LayoutOrder = #Window.Tabs + 1,
            AutoButtonColor = false
        })
        
        CreateCorner(TabButton, 4)
        CreateStroke(TabButton, 1, CurrentTheme.Border)
        
        -- Tab Content
        local TabContent = CreateUIElement("ScrollingFrame", {
            Name = "TabContent_" .. name,
            Parent = ContentContainer,
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 6,
            ScrollBarImageColor3 = CurrentTheme.Accent,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollingDirection = Enum.ScrollingDirection.Y,
            VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
            Visible = false
        })
        
        local ContentLayout = CreateUIElement("UIListLayout", {
            Parent = TabContent,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8)
        })
        
        CreatePadding(TabContent, 12)
        
        -- Tab activation
        local function ActivateTab()
            -- Deactivate all tabs
            for _, tab in pairs(Window.Tabs) do
                tab.Button.BackgroundColor3 = CurrentTheme.Primary
                tab.Button.TextColor3 = CurrentTheme.TextSecondary
                tab.Content.Visible = false
                tab.Active = false
            end
            
            -- Activate this tab
            TabButton.BackgroundColor3 = CurrentTheme.Accent
            TabButton.TextColor3 = CurrentTheme.Text
            TabContent.Visible = true
            Tab.Active = true
            Window.CurrentTab = Tab
        end
        
        TabButton.MouseButton1Click:Connect(ActivateTab)
        
        -- Hover effects
        TabButton.MouseEnter:Connect(function()
            if not Tab.Active then
                CreateTween(TabButton, {BackgroundColor3 = CurrentTheme.Secondary}, Config.AnimationSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out):Play()
            end
        end)
        
        TabButton.MouseLeave:Connect(function()
            if not Tab.Active then
                CreateTween(TabButton, {BackgroundColor3 = CurrentTheme.Primary}, Config.AnimationSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out):Play()
            end
        end)
        
        Tab.Button = TabButton
        Tab.Content = TabContent
        
        -- If this is the first tab, activate it
        if #Window.Tabs == 0 then
            ActivateTab()
        end
        
        table.insert(Window.Tabs, Tab)
        
        -- Tab UI Elements
        function Tab:CreateSection(name)
            local Section = CreateUIElement("Frame", {
                Name = "Section_" .. name,
                Parent = TabContent,
                Size = UDim2.new(1, 0, 0, 35),
                BackgroundColor3 = CurrentTheme.Accent,
                BorderSizePixel = 0,
                LayoutOrder = #Tab.Elements + 1
            })
            
            CreateCorner(Section, 4)
            
            local SectionLabel = CreateUIElement("TextLabel", {
                Name = "SectionLabel",
                Parent = Section,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = name,
                TextColor3 = CurrentTheme.Text,
                TextScaled = true,
                TextXAlignment = Enum.TextXAlignment.Center,
                Font = Enum.Font.GothamBold
            })
            
            CreatePadding(Section, 8)
            table.insert(Tab.Elements, Section)
            return Section
        end
        
        function Tab:CreateToggle(options)
            options = options or {}
            local name = options.Name or "Toggle"
            local flag = options.Flag or name
            local default = options.Default or false
            local callback = options.Callback or function() end
            
            Library.Flags[flag] = default
            
            local Toggle = CreateUIElement("Frame", {
                Name = "Toggle_" .. name,
                Parent = TabContent,
                Size = UDim2.new(1, 0, 0, 40),
                BackgroundColor3 = CurrentTheme.Secondary,
                BorderSizePixel = 0,
                LayoutOrder = #Tab.Elements + 1
            })
            
            CreateCorner(Toggle, 4)
            CreateStroke(Toggle, 1, CurrentTheme.Border)
            
            local ToggleLabel = CreateUIElement("TextLabel", {
                Name = "ToggleLabel",
                Parent = Toggle,
                Size = UDim2.new(1, -50, 1, 0),
                Position = UDim2.new(0, 12, 0, 0),
                BackgroundTransparency = 1,
                Text = name,
                TextColor3 = CurrentTheme.Text,
                TextScaled = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = Enum.Font.Gotham
            })
            
            local ToggleButton = CreateUIElement("TextButton", {
                Name = "ToggleButton",
                Parent = Toggle,
                Size = UDim2.new(0, 35, 0, 20),
                Position = UDim2.new(1, -42, 0.5, -10),
                BackgroundColor3 = default and CurrentTheme.Success or CurrentTheme.Border,
                BorderSizePixel = 0,
                Text = "",
                AutoButtonColor = false
            })
            
            CreateCorner(ToggleButton, 10)
            
            local ToggleIndicator = CreateUIElement("Frame", {
                Name = "ToggleIndicator",
                Parent = ToggleButton,
                Size = UDim2.new(0, 16, 0, 16),
                Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
                BackgroundColor3 = CurrentTheme.Text,
                BorderSizePixel = 0
            })
            
            CreateCorner(ToggleIndicator, 8)
            
            local function UpdateToggle(state)
                Library.Flags[flag] = state
                
                local buttonColor = state and CurrentTheme.Success or CurrentTheme.Border
                local indicatorPos = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
                
                CreateTween(ToggleButton, {BackgroundColor3 = buttonColor}, Config.AnimationSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out):Play()
                CreateTween(ToggleIndicator, {Position = indicatorPos}, Config.AnimationSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out):Play()
                
                callback(state)
            end
            
            ToggleButton.MouseButton1Click:Connect(function()
                UpdateToggle(not Library.Flags[flag])
            end)
            
            -- Hover effects
            Toggle.MouseEnter:Connect(function()
                CreateTween(Toggle, {BackgroundColor3 = CurrentTheme.Primary}, Config.AnimationSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out):Play()
            end)
            
            Toggle.MouseLeave:Connect(function()
                CreateTween(Toggle, {BackgroundColor3 = CurrentTheme.Secondary}, Config.AnimationSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out):Play()
            end)
            
            table.insert(Tab.Elements, Toggle)
            return Toggle
        end
        
        function Tab:CreateSlider(options)
            options = options or {}
            local name = options.Name or "Slider"
            local flag = options.Flag or name
            local min = options.Min or 0
            local max = options.Max or 100
            local default = options.Default or min
            local increment = options.Increment or 1
            local callback = options.Callback or function() end
            
            Library.Flags[flag] = default
            
            local Slider = CreateUIElement("Frame", {
                Name = "Slider_" .. name,
                Parent = TabContent,
                Size = UDim2.new(1, 0, 0, 50),
                BackgroundColor3 = CurrentTheme.Secondary,
                BorderSizePixel = 0,
                LayoutOrder = #Tab.Elements + 1
            })
            
            CreateCorner(Slider, 4)
            CreateStroke(Slider, 1, CurrentTheme.Border)
            
            local SliderLabel = CreateUIElement("TextLabel", {
                Name = "SliderLabel",
                Parent = Slider,
                Size = UDim2.new(1, -60, 0, 20),
                Position = UDim2.new(0, 12, 0, 5),
                BackgroundTransparency = 1,
                Text = name,
                TextColor3 = CurrentTheme.Text,
                TextScaled = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = Enum.Font.Gotham
            })
            
            local SliderValue = CreateUIElement("TextLabel", {
                Name = "SliderValue",
                Parent = Slider,
                Size = UDim2.new(0, 50, 0, 20),
                Position = UDim2.new(1, -55, 0, 5),
                BackgroundTransparency = 1,
                Text = tostring(default),
                TextColor3 = CurrentTheme.Accent,
                TextScaled = true,
                TextXAlignment = Enum.TextXAlignment.Right,
                Font = Enum.Font.GothamBold
            })
            
            local SliderTrack = CreateUIElement("Frame", {
                Name = "SliderTrack",
                Parent = Slider,
                Size = UDim2.new(1, -24, 0, 4),
                Position = UDim2.new(0, 12, 1, -15),
                BackgroundColor3 = CurrentTheme.Border,
                BorderSizePixel = 0
            })
            
            CreateCorner(SliderTrack, 2)
            
            local SliderFill = CreateUIElement("Frame", {
                Name = "SliderFill",
                Parent = SliderTrack,
                Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
                Position = UDim2.new(0, 0, 0, 0),
                BackgroundColor3 = CurrentTheme.Accent,
                BorderSizePixel = 0
            })
            
            CreateCorner(SliderFill, 2)
            
            local SliderHandle = CreateUIElement("Frame", {
                Name = "SliderHandle",
                Parent = SliderTrack,
                Size = UDim2.new(0, 12, 0, 12),
                Position = UDim2.new((default - min) / (max - min), -6, 0.5, -6),
                BackgroundColor3 = CurrentTheme.Text,
                BorderSizePixel = 0
            })
            
            CreateCorner(SliderHandle, 6)
            
            local dragging = false
            
            local function UpdateSlider(value)
                value = math.clamp(value, min, max)
                value = math.floor(value / increment) * increment
                
                Library.Flags[flag] = value
                SliderValue.Text = tostring(value)
                
                local percentage = (value - min) / (max - min)
                CreateTween(SliderFill, {Size = UDim2.new(percentage, 0, 1, 0)}, Config.AnimationSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out):Play()
                CreateTween(SliderHandle, {Position = UDim2.new(percentage, -6, 0.5, -6)}, Config.AnimationSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out):Play()
                
                callback(value)
            end
            
            SliderTrack.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    local function Update()
                        local mouse = Players.LocalPlayer:GetMouse()
                        local percentage = math.clamp((mouse.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X, 0, 1)
                        local value = min + (max - min) * percentage
                        UpdateSlider(value)
                    end
                    
                    Update()
                    
                    local connection
                    connection = mouse.Move:Connect(function()
                        if dragging then
                            Update()
                        else
                            connection:Disconnect()
                        end
                    end)
                    table.insert(Library.Connections, connection)
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            
            table.insert(Tab.Elements, Slider)
            return Slider
        end
        
        function Tab:CreateButton(options)
            options = options or {}
            local name = options.Name or "Button"
            local callback = options.Callback or function() end
            
            local Button = CreateUIElement("TextButton", {
                Name = "Button_" .. name,
                Parent = TabContent,
                Size = UDim2.new(1, 0, 0, 35),
                BackgroundColor3 = CurrentTheme.Accent,
                BorderSizePixel = 0,
                Text = name,
                TextColor3 = CurrentTheme.Text,
                TextScaled = true,
                Font = Enum.Font.GothamBold,
                LayoutOrder = #Tab.Elements + 1
            })
            
            CreateCorner(Button, 4)
            CreateStroke(Button, 1, CurrentTheme.Border)
            
            Button.MouseButton1Click:Connect(callback)
            
            -- Hover effects
            Button.MouseEnter:Connect(function()
                CreateTween(Button, {BackgroundColor3 = CurrentTheme.Success}, Config.AnimationSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out):Play()
            end)
            
            Button.MouseLeave:Connect(function()
                CreateTween(Button, {BackgroundColor3 = CurrentTheme.Accent}, Config.AnimationSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out):Play()
            end)
            
            table.insert(Tab.Elements, Button)
            return Button
        end
        
        function Tab:CreateTextBox(options)
            options = options or {}
            local name = options.Name or "TextBox"
            local flag = options.Flag or name
            local default = options.Default or ""
            local placeholder = options.Placeholder or "Enter text..."
            local callback = options.Callback or function() end
            
            Library.Flags[flag] = default
            
            local TextBox = CreateUIElement("Frame", {
                Name = "TextBox_" .. name,
                Parent = TabContent,
                Size = UDim2.new(1, 0, 0, 50),
                BackgroundColor3 = CurrentTheme.Secondary,
                BorderSizePixel = 0,
                LayoutOrder = #Tab.Elements + 1
            })
            
            CreateCorner(TextBox, 4)
            CreateStroke(TextBox, 1, CurrentTheme.Border)
            
            local TextBoxLabel = CreateUIElement("TextLabel", {
                Name = "TextBoxLabel",
                Parent = TextBox,
                Size = UDim2.new(1, 0, 0, 20),
                Position = UDim2.new(0, 12, 0, 5),
                BackgroundTransparency = 1,
                Text = name,
                TextColor3 = CurrentTheme.Text,
                TextScaled = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = Enum.Font.Gotham
            })
            
            local TextInput = CreateUIElement("TextBox", {
                Name = "TextInput",
                Parent = TextBox,
                Size = UDim2.new(1, -24, 0, 20),
                Position = UDim2.new(0, 12, 1, -25),
                BackgroundColor3 = CurrentTheme.Primary,
                BorderSizePixel = 0,
                Text = default,
                PlaceholderText = placeholder,
                TextColor3 = CurrentTheme.Text,
                PlaceholderColor3 = CurrentTheme.TextSecondary,
                TextScaled = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = Enum.Font.Gotham,
                ClearTextOnFocus = false
            })
            
            CreateCorner(TextInput, 2)
            CreatePadding(TextInput, 6)
            
            TextInput.FocusLost:Connect(function()
                Library.Flags[flag] = TextInput.Text
                callback(TextInput.Text)
            end)
            
            table.insert(Tab.Elements, TextBox)
            return TextBox
        end
        
        function Tab:CreateDropdown(options)
            options = options or {}
            local name = options.Name or "Dropdown"
            local flag = options.Flag or name
            local items = options.Items or {}
            local default = options.Default or (items[1] or "")
            local callback = options.Callback or function() end
            
            Library.Flags[flag] = default
            
            local Dropdown = CreateUIElement("Frame", {
                Name = "Dropdown_" .. name,
                Parent = TabContent,
                Size = UDim2.new(1, 0, 0, 50),
                BackgroundColor3 = CurrentTheme.Secondary,
                BorderSizePixel = 0,
                LayoutOrder = #Tab.Elements + 1
            })
            
            CreateCorner(Dropdown, 4)
            CreateStroke(Dropdown, 1, CurrentTheme.Border)
            
            local DropdownLabel = CreateUIElement("TextLabel", {
                Name = "DropdownLabel",
                Parent = Dropdown,
                Size = UDim2.new(1, 0, 0, 20),
                Position = UDim2.new(0, 12, 0, 5),
                BackgroundTransparency = 1,
                Text = name,
                TextColor3 = CurrentTheme.Text,
                TextScaled = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = Enum.Font.Gotham
            })
            
            local DropdownButton = CreateUIElement("TextButton", {
                Name = "DropdownButton",
                Parent = Dropdown,
                Size = UDim2.new(1, -24, 0, 20),
                Position = UDim2.new(0, 12, 1, -25),
                BackgroundColor3 = CurrentTheme.Primary,
                BorderSizePixel = 0,
                Text = default .. " ▼",
                TextColor3 = CurrentTheme.Text,
                TextScaled = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = Enum.Font.Gotham
            })
            
            CreateCorner(DropdownButton, 2)
            CreatePadding(DropdownButton, 6)
            
            -- Create dropdown container as child of MainFrame for proper layering within the GUI
            local DropdownContainer = CreateUIElement("Frame", {
                Name = "DropdownContainer_" .. name,
                Parent = MainFrame, -- Changed parent to MainFrame
                Size = UDim2.new(0, 0, 0, 0),
                Position = UDim2.new(0, 0, 0, 0),
                BackgroundTransparency = 1,
                ZIndex = 100, -- Ensure it's above other elements in MainFrame
                Visible = false
            })
            
            local DropdownList = CreateUIElement("ScrollingFrame", {
                Name = "DropdownList",
                Parent = DropdownContainer,
                Size = UDim2.new(0, 0, 0, math.min(#items * 25 + 8, 150)),
                Position = UDim2.new(0, 0, 0, 0),
                BackgroundColor3 = CurrentTheme.Secondary,
                BackgroundTransparency = CurrentTheme.Transparent and (CurrentTheme.Transparent / 2) or 0,
                BorderSizePixel = 0,
                ScrollBarThickness = 4,
                ScrollBarImageColor3 = CurrentTheme.Accent,
                CanvasSize = UDim2.new(0, 0, 0, #items * 25 + 8),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ScrollingDirection = Enum.ScrollingDirection.Y,
                ZIndex = 101
            })
            
            CreateCorner(DropdownList, 4)
            CreateStroke(DropdownList, 1, CurrentTheme.Border)
            
            local ListLayout = CreateUIElement("UIListLayout", {
                Parent = DropdownList,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 2)
            })
            
            CreatePadding(DropdownList, 4)
            
            local isOpen = false
            
            for i, item in ipairs(items) do
                local ItemButton = CreateUIElement("TextButton", {
                    Name = "Item_" .. item,
                    Parent = DropdownList,
                    Size = UDim2.new(1, 0, 0, 20),
                    BackgroundColor3 = CurrentTheme.Primary,
                    BackgroundTransparency = CurrentTheme.Transparent and (CurrentTheme.Transparent / 3) or 0,
                    BorderSizePixel = 0,
                    Text = item,
                    TextColor3 = CurrentTheme.Text,
                    TextScaled = true,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Font = Enum.Font.Gotham,
                    LayoutOrder = i,
                    ZIndex = 102
                })
                
                CreateCorner(ItemButton, 2)
                CreatePadding(ItemButton, 4)
                
                ItemButton.MouseButton1Click:Connect(function()
                    Library.Flags[flag] = item
                    DropdownButton.Text = item .. " ▼"
                    DropdownContainer.Visible = false
                    isOpen = false
                    callback(item)
                end)
                
                ItemButton.MouseEnter:Connect(function()
                    CreateTween(ItemButton, {BackgroundColor3 = CurrentTheme.Accent}, Config.AnimationSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out):Play()
                end)
                
                ItemButton.MouseLeave:Connect(function()
                    CreateTween(ItemButton, {BackgroundColor3 = CurrentTheme.Primary}, Config.AnimationSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out):Play()
                end)
            end
            
            -- Function to update dropdown position
            local function UpdateDropdownPosition()
                if DropdownContainer.Visible then
                    local buttonAbsolutePos = DropdownButton.AbsolutePosition
                    local buttonAbsoluteSize = DropdownButton.AbsoluteSize
                    local mainFrameAbsolutePos = MainFrame.AbsolutePosition

                    -- Calculate relative position to MainFrame
                    local relativeX = buttonAbsolutePos.X - mainFrameAbsolutePos.X
                    local relativeY = buttonAbsolutePos.Y - mainFrameAbsolutePos.Y
                    
                    DropdownContainer.Position = UDim2.new(0, relativeX, 0, relativeY + buttonAbsoluteSize.Y + 5)
                    DropdownContainer.Size = UDim2.new(0, buttonAbsoluteSize.X, 0, math.min(#items * 25 + 8, 150))
                    DropdownList.Size = UDim2.new(1, 0, 1, 0)
                end
            end
            
            DropdownButton.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                DropdownContainer.Visible = isOpen
                DropdownButton.Text = Library.Flags[flag] .. " " .. (isOpen and "▲" or "▼")
                
                if isOpen then
                    UpdateDropdownPosition()
                    -- Update position on frame movement
                    local updateConnection
                    updateConnection = RunService.Heartbeat:Connect(function()
                        if DropdownContainer.Visible then
                            UpdateDropdownPosition()
                        else
                            updateConnection:Disconnect()
                        end
                    end)
                    table.insert(Library.Connections, updateConnection)
                end
            end)
            
            -- Close dropdown when clicking elsewhere
            UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    local mousePos = input.Position
                    local dropdownPos = DropdownContainer.AbsolutePosition
                    local dropdownSize = DropdownContainer.AbsoluteSize
                    
                    if not (mousePos.X >= dropdownPos.X and mousePos.X <= dropdownPos.X + dropdownSize.X and
                            mousePos.Y >= dropdownPos.Y and mousePos.Y <= dropdownPos.Y + dropdownSize.Y) and
                       not (mousePos.X >= DropdownButton.AbsolutePosition.X and 
                            mousePos.X <= DropdownButton.AbsolutePosition.X + DropdownButton.AbsoluteSize.X and
                            mousePos.Y >= DropdownButton.AbsolutePosition.Y and 
                            mousePos.Y <= DropdownButton.AbsolutePosition.Y + DropdownButton.AbsoluteSize.Y) then
                        
                        if isOpen then
                            isOpen = false
                            DropdownContainer.Visible = false
                            DropdownButton.Text = Library.Flags[flag] .. " ▼"
                        end
                    end
                end
            end)
            
            table.insert(Tab.Elements, Dropdown)
            return Dropdown
        end
        
        function Tab:CreateLabel(options)
            options = options or {}
            local text = options.Text or "Label"
            local color = options.Color or CurrentTheme.Text
            
            local Label = CreateUIElement("TextLabel", {
                Name = "Label_" .. text,
                Parent = TabContent,
                Size = UDim2.new(1, 0, 0, 25),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = color,
                TextScaled = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = Enum.Font.Gotham,
                LayoutOrder = #Tab.Elements + 1
            })
            
            CreatePadding(Label, 12)
            
            table.insert(Tab.Elements, Label)
            return Label
        end
        
        function Tab:CreateCopyButton(options)
            options = options or {}
            local name = options.Name or "Copy"
            local text = options.Text or ""
            local callback = options.Callback or function() end
            
            local CopyButton = CreateUIElement("Frame", {
                Name = "CopyButton_" .. name,
                Parent = TabContent,
                Size = UDim2.new(1, 0, 0, 35),
                BackgroundColor3 = CurrentTheme.Secondary,
                BackgroundTransparency = CurrentTheme.Transparent and (CurrentTheme.Transparent / 2) or 0,
                BorderSizePixel = 0,
                LayoutOrder = #Tab.Elements + 1
            })
            
            CreateCorner(CopyButton, 4)
            CreateStroke(CopyButton, 1, CurrentTheme.Border)
            
            local ButtonLabel = CreateUIElement("TextLabel", {
                Name = "ButtonLabel",
                Parent = CopyButton,
                Size = UDim2.new(1, -40, 1, 0),
                Position = UDim2.new(0, 12, 0, 0),
                BackgroundTransparency = 1,
                Text = name,
                TextColor3 = CurrentTheme.Text,
                TextScaled = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = Enum.Font.Gotham
            })
            
            local CopyIcon = CreateUIElement("TextButton", {
                Name = "CopyIcon",
                Parent = CopyButton,
                Size = UDim2.new(0, 30, 0, 25),
                Position = UDim2.new(1, -35, 0.5, -12.5),
                BackgroundColor3 = CurrentTheme.Accent,
                BorderSizePixel = 0,
                Text = "📋",
                TextColor3 = CurrentTheme.Text,
                TextScaled = true,
                Font = Enum.Font.Gotham,
                AutoButtonColor = false
            })
            
            CreateCorner(CopyIcon, 4)
            
            local function CopyToClipboard()
                if setclipboard then
                    setclipboard(text)
                    callback(text)
                    
                    -- Visual feedback
                    local originalText = CopyIcon.Text
                    local originalColor = CopyIcon.BackgroundColor3
                    
                    CopyIcon.Text = "✓"
                    CreateTween(CopyIcon, {BackgroundColor3 = CurrentTheme.Success}, 0.2):Play()
                    
                    task.wait(1)
                    
                    CopyIcon.Text = originalText
                    CreateTween(CopyIcon, {BackgroundColor3 = originalColor}, 0.2):Play()
                    
                    Window:Notify({
                        Text = "Copied to clipboard!",
                        Duration = 2,
                        Type = "success"
                    })
                else
                    Window:Notify({
                        Text = "Clipboard not supported!",
                        Duration = 2,
                        Type = "error"
                    })
                end
            end
            
            CopyIcon.MouseButton1Click:Connect(CopyToClipboard)
            
            -- Hover effects
            CopyButton.MouseEnter:Connect(function()
                CreateTween(CopyButton, {BackgroundColor3 = CurrentTheme.Primary}, Config.AnimationSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out):Play()
            end)
            
            CopyButton.MouseLeave:Connect(function()
                CreateTween(CopyButton, {BackgroundColor3 = CurrentTheme.Secondary}, Config.AnimationSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out):Play()
            end)
            
            table.insert(Tab.Elements, CopyButton)
            return CopyButton
        end
        
        return Tab
    end
    
    function Window:SetTheme(themeName)
        if Themes[themeName] then
            CurrentTheme = Themes[themeName]
            -- Update all UI elements with new theme
            MainFrame.BackgroundColor3 = CurrentTheme.Primary
            Header.BackgroundColor3 = CurrentTheme.Secondary
            Title.TextColor3 = CurrentTheme.Text
            TabContainer.BackgroundColor3 = CurrentTheme.Secondary
            ContentContainer.BackgroundColor3 = CurrentTheme.Primary
            
            -- Update tabs
            for _, tab in pairs(Window.Tabs) do
                if tab.Active then
                    tab.Button.BackgroundColor3 = CurrentTheme.Accent
                    tab.Button.TextColor3 = CurrentTheme.Text
                else
                    tab.Button.BackgroundColor3 = CurrentTheme.Primary
                    tab.Button.TextColor3 = CurrentTheme.TextSecondary
                end
            end
        end
    end
    
    function Window:Notify(options)
        options = options or {}
        local text = options.Text or "Notification"
        local duration = options.Duration or 3
        local type = options.Type or "info" -- info, success, warning, error
        
        local colors = {
            info = CurrentTheme.Accent,
            success = CurrentTheme.Success,
            warning = CurrentTheme.Warning,
            error = CurrentTheme.Error
        }
        
        local Notification = CreateUIElement("Frame", {
            Name = "Notification",
            Parent = ScreenGui,
            Size = UDim2.new(0, 300, 0, 60),
            Position = UDim2.new(1, 320, 1, -80), -- Start off-screen bottom right
            BackgroundColor3 = CurrentTheme.Secondary,
            BackgroundTransparency = CurrentTheme.Transparent or 0,
            BorderSizePixel = 0
        })
        
        CreateCorner(Notification, 6)
        CreateStroke(Notification, 2, colors[type])
        
        local NotificationText = CreateUIElement("TextLabel", {
            Name = "NotificationText",
            Parent = Notification,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = CurrentTheme.Text,
            TextScaled = true,
            TextXAlignment = Enum.TextXAlignment.Center,
            Font = Enum.Font.Gotham
        })
        
        CreatePadding(NotificationText, 12)
        
        -- Slide in animation (from bottom right to visible position)
        CreateTween(Notification, {Position = UDim2.new(1, -320, 1, -80)}, Config.AnimationSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out):Play()
        
        -- Auto dismiss
        task.wait(duration)
        CreateTween(Notification, {Position = UDim2.new(1, 320, 1, -80)}, Config.AnimationSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.In):Play()
        
        task.wait(Config.AnimationSpeed)
        Notification:Destroy()
    end
    
    function Window:Destroy()
        for _, connection in pairs(Library.Connections) do
            connection:Disconnect()
        end
        ScreenGui:Destroy()
        Library.Flags = {}
        Library.Connections = {}
    end
    
    Library.Window = Window
    return Window
end

-- Export the library
return OGLib



