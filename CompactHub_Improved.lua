--[[
    CompactHub GUI Library v2.1 - Improved Release
    A sleek, mobile-friendly GUI library for Roblox scripts
    
    NEW FEATURES IN v2.1:
    - Tabs positioned on the LEFT side (instead of right)
    - Rounded corners for softer, more relaxed appearance
    - Maximize/Minimize functionality with proper state management
    - Enhanced draggable functionality (works in all states)
    - Improved theme system that updates ALL elements
    - Better visual hierarchy and modern design
    
    Features:
    - Soft rounded design with customizable corner radius
    - Mobile-optimized portrait layout (320x480)
    - Easy loadstring API
    - Smooth animations with enhanced easing
    - Multiple themes with complete element coverage
    - Tabs positioned on the left side for better UX
    - Full window state management (normal/maximized/minimized)
    - Enhanced draggable functionality
    - Fixed LocalScript compatibility
    
    Usage:
    local CompactHub = loadstring(game:HttpGet("YOUR_URL_HERE"))()
]]

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

-- Local Player
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Library Information
local CompactHub = {
    Version = "2.1.0",
    Build = "CH210",
    Flags = {},
    Connections = {},
    Windows = {}
}

-- Configuration
local CONFIG = {
    FolderName = "CompactHub",
    ConfigExtension = ".chub",
    DefaultKeybind = Enum.KeyCode.Insert,
    AnimationSpeed = 0.25,
    DefaultSize = UDim2.new(0, 500, 0, 250), -- Mobile-friendly portrait
    MinimizedSize = UDim2.new(0, 50, 0, 50),
    TabWidth = 60 -- Width for left-side tabs
}

-- Themes with modern, relaxed colors
local Themes = {
    Cyber = {
        Background = Color3.fromRGB(15, 15, 20),
        Foreground = Color3.fromRGB(25, 25, 35),
        Accent = Color3.fromRGB(0, 255, 127), -- Neon green
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(180, 180, 190),
        Border = Color3.fromRGB(0, 200, 100),
        Success = Color3.fromRGB(0, 255, 127),
        Warning = Color3.fromRGB(255, 200, 0),
        Error = Color3.fromRGB(255, 50, 50)
    },
    Neon = {
        Background = Color3.fromRGB(10, 10, 15),
        Foreground = Color3.fromRGB(20, 20, 30),
        Accent = Color3.fromRGB(255, 0, 127), -- Hot pink
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(200, 180, 255),
        Border = Color3.fromRGB(200, 0, 100),
        Success = Color3.fromRGB(0, 255, 127),
        Warning = Color3.fromRGB(255, 200, 0),
        Error = Color3.fromRGB(255, 50, 50)
    },
    Matrix = {
        Background = Color3.fromRGB(0, 0, 0),
        Foreground = Color3.fromRGB(10, 20, 10),
        Accent = Color3.fromRGB(0, 255, 0), -- Classic green
        Text = Color3.fromRGB(0, 255, 0),
        TextSecondary = Color3.fromRGB(0, 180, 0),
        Border = Color3.fromRGB(0, 150, 0),
        Success = Color3.fromRGB(0, 255, 0),
        Warning = Color3.fromRGB(255, 255, 0),
        Error = Color3.fromRGB(255, 0, 0)
    },
    Synthwave = {
        Background = Color3.fromRGB(20, 5, 30),
        Foreground = Color3.fromRGB(40, 15, 50),
        Accent = Color3.fromRGB(255, 71, 255), -- Purple pink
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(255, 180, 255),
        Border = Color3.fromRGB(200, 50, 200),
        Success = Color3.fromRGB(0, 255, 127),
        Warning = Color3.fromRGB(255, 200, 0),
        Error = Color3.fromRGB(255, 50, 50)
    }
}

-- Utility Functions
local function CreateElement(elementType, properties)
    local element = Instance.new(elementType)
    for property, value in pairs(properties or {}) do
        element[property] = value
    end
    return element
end

local function AddCornerRadius(element, radius)
    local corner = CreateElement("UICorner", {
        Parent = element,
        CornerRadius = UDim.new(0, radius or 8)
    })
    return corner
end

local function TweenElement(element, properties, duration, easingStyle, easingDirection, callback)
    duration = duration or CONFIG.AnimationSpeed
    easingStyle = easingStyle or Enum.EasingStyle.Quart
    easingDirection = easingDirection or Enum.EasingDirection.Out
    
    local tween = TweenService:Create(element, TweenInfo.new(duration, easingStyle, easingDirection), properties)
    tween:Play()
    
    if callback then
        tween.Completed:Connect(callback)
    end
    
    return tween
end

local function AddBorder(element, color, thickness)
    local border = CreateElement("UIStroke", {
        Parent = element,
        Color = color or Color3.fromRGB(0, 255, 127),
        Thickness = thickness or 1,
        Transparency = 0
    })
    return border
end

local function SaveConfig(windowTitle, config)
    local success, err = pcall(function()
        if writefile and makefolder then
            if not isfolder(CONFIG.FolderName) then
                makefolder(CONFIG.FolderName)
            end
            
            local configPath = CONFIG.FolderName .. "/" .. windowTitle .. CONFIG.ConfigExtension
            writefile(configPath, HttpService:JSONEncode(config))
        end
    end)
    
    if not success then
        warn("CompactHub: Failed to save config - " .. tostring(err))
    end
end

local function LoadConfig(windowTitle)
    local success, result = pcall(function()
        if readfile and isfile then
            local configPath = CONFIG.FolderName .. "/" .. windowTitle .. CONFIG.ConfigExtension
            if isfile(configPath) then
                return HttpService:JSONDecode(readfile(configPath))
            end
        end
        return {}
    end)
    
    return success and result or {}
end

-- Main Window Class
local Window = {}
Window.__index = Window

function Window.new(options)
    local self = setmetatable({}, Window)
    
    -- Properties
    self.Title = options.Title or "CompactHub"
    self.Theme = Themes[options.Theme] or Themes.Cyber
    self.Keybind = options.Keybind or CONFIG.DefaultKeybind
    self.Logo = options.Logo or "CH"
    self.Size = options.Size or CONFIG.DefaultSize
    self.IsMinimized = false
    self.IsMaximized = false
    self.IsVisible = true
    self.OriginalSize = self.Size
    self.OriginalPosition = UDim2.new(0.5, -self.Size.X.Offset/2, 0.5, -self.Size.Y.Offset/2)
    self.MaximizedSize = UDim2.new(0.9, 0, 0.9, 0) -- 90% of screen
    self.MaximizedPosition = UDim2.new(0.05, 0, 0.05, 0) -- Centered with 5% margin
    self.Tabs = {}
    self.CurrentTab = nil
    self.Config = LoadConfig(self.Title)
    self.Flags = {}
    
    -- Create GUI
    self:CreateGUI()
    self:SetupKeybind()
    
    -- Store reference
    CompactHub.Windows[self.Title] = self
    
    return self
end

function Window:CreateGUI()
    -- Main ScreenGui
    self.ScreenGui = CreateElement("ScreenGui", {
        Name = "CompactHub_" .. self.Title,
        Parent = PlayerGui, -- Use PlayerGui instead of CoreGui for better compatibility
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    
    -- Main Frame (Rounded corners for softer look)
    self.MainFrame = CreateElement("Frame", {
        Name = "MainFrame",
        Parent = self.ScreenGui,
        Size = self.Size,
        Position = UDim2.new(0.5, -self.Size.X.Offset/2, 0.5, -self.Size.Y.Offset/2),
        BackgroundColor3 = self.Theme.Background,
        BorderSizePixel = 0
    })
    
    -- Add rounded corners for softer appearance
    AddCornerRadius(self.MainFrame, 12)
    
    -- Soft border
    AddBorder(self.MainFrame, self.Theme.Border, 2)
    
    -- Title Bar
    self.TitleBar = CreateElement("Frame", {
        Name = "TitleBar",
        Parent = self.MainFrame,
        Size = UDim2.new(1, 0, 0, 35),
        BackgroundColor3 = self.Theme.Foreground,
        BorderSizePixel = 0
    })
    
    AddCornerRadius(self.TitleBar, 8)
    AddBorder(self.TitleBar, self.Theme.Border, 1)
    
    -- Title Text
    self.TitleLabel = CreateElement("TextLabel", {
        Name = "Title",
        Parent = self.TitleBar,
        Size = UDim2.new(1, -80, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = self.Title,
        TextColor3 = self.Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.Code
    })
    
    -- Minimize Button (Rounded for softer look)
    self.MinimizeButton = CreateElement("TextButton", {
        Name = "MinimizeButton",
        Parent = self.TitleBar,
        Size = UDim2.new(0, 25, 0, 25),
        Position = UDim2.new(1, -55, 0, 5),
        BackgroundColor3 = self.Theme.Accent,
        BorderSizePixel = 0,
        Text = "—",
        TextColor3 = Color3.fromRGB(0, 0, 0),
        TextSize = 16,
        Font = Enum.Font.Code
    })
    
    AddCornerRadius(self.MinimizeButton, 6)
    AddBorder(self.MinimizeButton, self.Theme.Border, 1)
    
    -- Maximize Button (Rounded for softer look)
    self.MaximizeButton = CreateElement("TextButton", {
        Name = "MaximizeButton",
        Parent = self.TitleBar,
        Size = UDim2.new(0, 25, 0, 25),
        Position = UDim2.new(1, -30, 0, 5),
        BackgroundColor3 = self.Theme.Accent,
        BorderSizePixel = 0,
        Text = "□",
        TextColor3 = Color3.fromRGB(0, 0, 0),
        TextSize = 16,
        Font = Enum.Font.Code
    })
    
    AddCornerRadius(self.MaximizeButton, 6)
    AddBorder(self.MaximizeButton, self.Theme.Border, 1)
    
    -- Tab Container (Left side, vertical)
    self.TabContainer = CreateElement("Frame", {
        Name = "TabContainer",
        Parent = self.MainFrame,
        Size = UDim2.new(0, CONFIG.TabWidth, 1, -35),
        Position = UDim2.new(0, 0, 0, 35),
        BackgroundColor3 = self.Theme.Foreground,
        BorderSizePixel = 0
    })
    
    AddCornerRadius(self.TabContainer, 8)
    AddBorder(self.TabContainer, self.Theme.Border, 1)
    
    CreateElement("UIListLayout", {
        Parent = self.TabContainer,
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        Padding = UDim.new(0, 2)
    })
    
    -- Content Area (Adjusted for left-side tabs)
    self.ContentFrame = CreateElement("ScrollingFrame", {
        Name = "Content",
        Parent = self.MainFrame,
        Size = UDim2.new(1, -CONFIG.TabWidth, 1, -35),
        Position = UDim2.new(0, CONFIG.TabWidth, 0, 35),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = self.Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0)
    })
    
    CreateElement("UIListLayout", {
        Parent = self.ContentFrame,
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        Padding = UDim.new(0, 8)
    })
    
    -- Logo Frame (for minimized state) - Rounded for softer look
    self.LogoFrame = CreateElement("Frame", {
        Name = "LogoFrame",
        Parent = self.ScreenGui,
        Size = CONFIG.MinimizedSize,
        Position = UDim2.new(1, -60, 0, 10),
        BackgroundColor3 = self.Theme.Accent,
        BorderSizePixel = 0,
        Visible = false
    })
    
    AddCornerRadius(self.LogoFrame, 10)
    AddBorder(self.LogoFrame, self.Theme.Border, 2)
    
    -- Logo Text
    self.LogoLabel = CreateElement("TextLabel", {
        Name = "Logo",
        Parent = self.LogoFrame,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = self.Logo,
        TextColor3 = Color3.fromRGB(0, 0, 0),
        TextSize = 16,
        Font = Enum.Font.Code,
        TextScaled = true
    })
    
    -- Setup Events
    self:SetupEvents()
end

function Window:SetupEvents()
    -- Minimize/Maximize functionality
    self.MinimizeButton.MouseButton1Click:Connect(function()
        self:ToggleMinimize()
    end)
    
    self.MaximizeButton.MouseButton1Click:Connect(function()
        self:ToggleMaximize()
    end)
    
    self.LogoFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self:ToggleMinimize()
        end
    end)
    
    -- Dragging functionality (works for both normal and maximized state)
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    self.TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and not self.IsMinimized then
            dragging = true
            dragStart = input.Position
            startPos = self.MainFrame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement and not self.IsMinimized then
            local delta = input.Position - dragStart
            local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            self.MainFrame.Position = newPos
            
            -- Update original position if not maximized
            if not self.IsMaximized then
                self.OriginalPosition = newPos
            end
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    -- Logo frame dragging when minimized
    local logoDragging = false
    local logoDragStart = nil
    local logoStartPos = nil
    
    self.LogoFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and self.IsMinimized then
            logoDragging = true
            logoDragStart = input.Position
            logoStartPos = self.LogoFrame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if logoDragging and input.UserInputType == Enum.UserInputType.MouseMovement and self.IsMinimized then
            local delta = input.Position - logoDragStart
            self.LogoFrame.Position = UDim2.new(logoStartPos.X.Scale, logoStartPos.X.Offset + delta.X, logoStartPos.Y.Scale, logoStartPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            logoDragging = false
        end
    end)
end

function Window:SetupKeybind()
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == self.Keybind then
            self:Toggle()
        end
    end)
end

function Window:ToggleMaximize()
    if self.IsMinimized then return end -- Can't maximize when minimized
    
    self.IsMaximized = not self.IsMaximized
    
    if self.IsMaximized then
        -- Store current position and size before maximizing
        if not self.IsMaximized then
            self.OriginalSize = self.MainFrame.Size
            self.OriginalPosition = self.MainFrame.Position
        end
        
        -- Maximize
        TweenElement(self.MainFrame, {
            Size = self.MaximizedSize,
            Position = self.MaximizedPosition
        }, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        
        self.MaximizeButton.Text = "❐" -- Restore icon
    else
        -- Restore to original size and position
        TweenElement(self.MainFrame, {
            Size = self.OriginalSize,
            Position = self.OriginalPosition
        }, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        
        self.MaximizeButton.Text = "□" -- Maximize icon
    end
end

function Window:ToggleMinimize()
    self.IsMinimized = not self.IsMinimized
    
    if self.IsMinimized then
        TweenElement(self.MainFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In, function()
            self.MainFrame.Visible = false
            self.LogoFrame.Visible = true
            TweenElement(self.LogoFrame, {Size = CONFIG.MinimizedSize}, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        end)
    else
        TweenElement(self.LogoFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In, function()
            self.LogoFrame.Visible = false
            self.MainFrame.Visible = true
            
            -- Restore to appropriate size (maximized or original)
            local targetSize = self.IsMaximized and self.MaximizedSize or self.OriginalSize
            local targetPosition = self.IsMaximized and self.MaximizedPosition or self.OriginalPosition
            
            TweenElement(self.MainFrame, {
                Size = targetSize,
                Position = targetPosition
            }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        end)
    end
end

function Window:Toggle()
    self.IsVisible = not self.IsVisible
    
    if self.IsVisible then
        self.ScreenGui.Enabled = true
        TweenElement(self.MainFrame, {Size = self.Size}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    else
        TweenElement(self.MainFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In, function()
            self.ScreenGui.Enabled = false
        end)
    end
end

function Window:SetTheme(themeName)
    local theme = Themes[themeName]
    if not theme then return end
    
    self.Theme = theme
    
    -- Update main window colors
    self.MainFrame.BackgroundColor3 = theme.Background
    self.TitleBar.BackgroundColor3 = theme.Foreground
    self.TabContainer.BackgroundColor3 = theme.Foreground
    self.TitleLabel.TextColor3 = theme.Text
    self.MinimizeButton.BackgroundColor3 = theme.Accent
    self.MaximizeButton.BackgroundColor3 = theme.Accent
    self.LogoFrame.BackgroundColor3 = theme.Accent
    self.ContentFrame.ScrollBarImageColor3 = theme.Accent
    
    -- Update borders for all main elements
    for _, element in pairs({self.MainFrame, self.TitleBar, self.TabContainer, self.MinimizeButton, self.MaximizeButton, self.LogoFrame}) do
        local border = element:FindFirstChild("UIStroke")
        if border then
            border.Color = theme.Border
        end
    end
    
    -- Update tab colors and their components
    for _, tab in pairs(self.Tabs) do
        tab:UpdateTheme(theme)
        
        -- Update all components in the tab
        for _, component in pairs(tab.Content:GetChildren()) do
            if component:IsA("Frame") or component:IsA("TextButton") then
                -- Update component colors based on type
                if component.Name == "ToggleContainer" or component.Name == "SliderContainer" or component.Name == "InputContainer" then
                    component.BackgroundColor3 = theme.Foreground
                    
                    -- Update borders
                    local border = component:FindFirstChild("UIStroke")
                    if border then
                        border.Color = theme.Border
                    end
                    
                    -- Update child elements
                    for _, child in pairs(component:GetChildren()) do
                        if child:IsA("TextLabel") and child.Name == "Label" then
                            child.TextColor3 = theme.Text
                        elseif child:IsA("TextLabel") and child.Name == "ValueLabel" then
                            child.TextColor3 = theme.Accent
                        elseif child:IsA("TextButton") and child.Name == "Toggle" then
                            local border = child:FindFirstChild("UIStroke")
                            if border then
                                border.Color = theme.Border
                            end
                        elseif child:IsA("Frame") and child.Name == "SliderFrame" then
                            child.BackgroundColor3 = theme.Background
                            local border = child:FindFirstChild("UIStroke")
                            if border then
                                border.Color = theme.Border
                            end
                            
                            -- Update slider button
                            local sliderButton = child:FindFirstChild("SliderButton")
                            if sliderButton then
                                sliderButton.BackgroundColor3 = theme.Accent
                                local buttonBorder = sliderButton:FindFirstChild("UIStroke")
                                if buttonBorder then
                                    buttonBorder.Color = theme.Border
                                end
                            end
                        elseif child:IsA("TextBox") then
                            child.BackgroundColor3 = theme.Background
                            child.TextColor3 = theme.Text
                            child.PlaceholderColor3 = theme.TextSecondary
                            local border = child:FindFirstChild("UIStroke")
                            if border then
                                border.Color = theme.Border
                            end
                        end
                    end
                elseif component.Name == "Button" then
                    component.BackgroundColor3 = theme.Accent
                    local border = component:FindFirstChild("UIStroke")
                    if border then
                        border.Color = theme.Border
                    end
                elseif component:IsA("TextLabel") then
                    component.TextColor3 = theme.Text
                end
            end
        end
    end
end

function Window:CreateTab(options)
    local tab = {}
    tab.Title = options.Title or "Tab"
    tab.Icon = options.Icon or "T"
    tab.Window = self
    tab.Components = {}
    tab.IsActive = false
    
    -- Create Tab Button (Rounded for softer design)
    tab.Button = CreateElement("TextButton", {
        Name = "TabButton",
        Parent = self.TabContainer,
        Size = UDim2.new(1, -4, 0, 40),
        BackgroundColor3 = self.Theme.Foreground,
        BorderSizePixel = 0,
        Text = tab.Icon,
        TextColor3 = self.Theme.TextSecondary,
        TextSize = 14,
        Font = Enum.Font.Code
    })
    
    AddCornerRadius(tab.Button, 6)
    AddBorder(tab.Button, self.Theme.Border, 1)
    
    -- Create Tab Content
    tab.Content = CreateElement("Frame", {
        Name = "TabContent",
        Parent = self.ContentFrame,
        Size = UDim2.new(1, -10, 1, 0),
        BackgroundTransparency = 1,
        Visible = false
    })
    
    CreateElement("UIListLayout", {
        Parent = tab.Content,
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        Padding = UDim.new(0, 5)
    })
    
    -- Tab functionality
    tab.Button.MouseButton1Click:Connect(function()
        self:SelectTab(tab)
    end)
    
    -- Hover effects
    tab.Button.MouseEnter:Connect(function()
        if not tab.IsActive then
            TweenElement(tab.Button, {BackgroundColor3 = self.Theme.Accent}, 0.1)
            TweenElement(tab.Button, {TextColor3 = Color3.fromRGB(0, 0, 0)}, 0.1)
        end
    end)
    
    tab.Button.MouseLeave:Connect(function()
        if not tab.IsActive then
            TweenElement(tab.Button, {BackgroundColor3 = self.Theme.Foreground}, 0.1)
            TweenElement(tab.Button, {TextColor3 = self.Theme.TextSecondary}, 0.1)
        end
    end)
    
    -- Tab methods
    function tab:UpdateTheme(theme)
        if self.IsActive then
            self.Button.BackgroundColor3 = theme.Accent
            self.Button.TextColor3 = Color3.fromRGB(0, 0, 0)
        else
            self.Button.BackgroundColor3 = theme.Foreground
            self.Button.TextColor3 = theme.TextSecondary
        end
        
        local border = self.Button:FindFirstChild("UIStroke")
        if border then
            border.Color = theme.Border
        end
    end
    
    function tab:CreateLabel(options)
        local label = CreateElement("TextLabel", {
            Name = "Label",
            Parent = self.Content,
            Size = UDim2.new(1, -20, 0, 25),
            BackgroundTransparency = 1,
            Text = options.Text or "Label",
            TextColor3 = self.Window.Theme.Text,
            TextSize = options.TextSize or 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = Enum.Font.Code
        })
        
        return label
    end
    
    function tab:CreateButton(options)
        local button = CreateElement("TextButton", {
            Name = "Button",
            Parent = self.Content,
            Size = UDim2.new(1, -20, 0, 35),
            BackgroundColor3 = self.Window.Theme.Accent,
            BorderSizePixel = 0,
            Text = options.Text or "Button",
            TextColor3 = Color3.fromRGB(0, 0, 0),
            TextSize = 14,
            Font = Enum.Font.Code
        })
        
        AddCornerRadius(button, 8)
        AddBorder(button, self.Window.Theme.Border, 1)
        
        -- Hover effects
        button.MouseEnter:Connect(function()
            TweenElement(button, {BackgroundColor3 = Color3.fromRGB(
                math.min(255, self.Window.Theme.Accent.R * 255 + 20),
                math.min(255, self.Window.Theme.Accent.G * 255 + 20),
                math.min(255, self.Window.Theme.Accent.B * 255 + 20)
            )}, 0.1)
        end)
        
        button.MouseLeave:Connect(function()
            TweenElement(button, {BackgroundColor3 = self.Window.Theme.Accent}, 0.1)
        end)
        
        if options.Callback then
            button.MouseButton1Click:Connect(options.Callback)
        end
        
        return button
    end
    
    function tab:CreateToggle(options)
        local container = CreateElement("Frame", {
            Name = "ToggleContainer",
            Parent = self.Content,
            Size = UDim2.new(1, -20, 0, 35),
            BackgroundColor3 = self.Window.Theme.Foreground,
            BorderSizePixel = 0
        })
        
        AddCornerRadius(container, 8)
        AddBorder(container, self.Window.Theme.Border, 1)
        
        local label = CreateElement("TextLabel", {
            Name = "Label",
            Parent = container,
            Size = UDim2.new(1, -60, 1, 0),
            Position = UDim2.new(0, 10, 0, 0),
            BackgroundTransparency = 1,
            Text = options.Text or "Toggle",
            TextColor3 = self.Window.Theme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = Enum.Font.Code
        })
        
        local toggle = CreateElement("TextButton", {
            Name = "Toggle",
            Parent = container,
            Size = UDim2.new(0, 40, 0, 20),
            Position = UDim2.new(1, -45, 0.5, -10),
            BackgroundColor3 = options.Default and self.Window.Theme.Accent or self.Window.Theme.Background,
            BorderSizePixel = 0,
            Text = options.Default and "ON" or "OFF",
            TextColor3 = options.Default and Color3.fromRGB(0, 0, 0) or self.Window.Theme.Text,
            TextSize = 12,
            Font = Enum.Font.Code
        })
        
        AddCornerRadius(toggle, 10)
        AddBorder(toggle, self.Window.Theme.Border, 1)
        
        local isToggled = options.Default or false
        self.Window.Flags[options.Flag or options.Text] = isToggled
        
        toggle.MouseButton1Click:Connect(function()
            isToggled = not isToggled
            self.Window.Flags[options.Flag or options.Text] = isToggled
            
            if isToggled then
                TweenElement(toggle, {BackgroundColor3 = self.Window.Theme.Accent}, 0.2)
                TweenElement(toggle, {TextColor3 = Color3.fromRGB(0, 0, 0)}, 0.2)
                toggle.Text = "ON"
            else
                TweenElement(toggle, {BackgroundColor3 = self.Window.Theme.Background}, 0.2)
                TweenElement(toggle, {TextColor3 = self.Window.Theme.Text}, 0.2)
                toggle.Text = "OFF"
            end
            
            if options.Callback then
                options.Callback(isToggled)
            end
        end)
        
        return container
    end
    
    function tab:CreateSlider(options)
        local container = CreateElement("Frame", {
            Name = "SliderContainer",
            Parent = self.Content,
            Size = UDim2.new(1, -20, 0, 50),
            BackgroundColor3 = self.Window.Theme.Foreground,
            BorderSizePixel = 0
        })
        
        AddCornerRadius(container, 8)
        AddBorder(container, self.Window.Theme.Border, 1)
        
        local label = CreateElement("TextLabel", {
            Name = "Label",
            Parent = container,
            Size = UDim2.new(1, -60, 0, 20),
            Position = UDim2.new(0, 10, 0, 5),
            BackgroundTransparency = 1,
            Text = options.Text or "Slider",
            TextColor3 = self.Window.Theme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = Enum.Font.Code
        })
        
        local valueLabel = CreateElement("TextLabel", {
            Name = "ValueLabel",
            Parent = container,
            Size = UDim2.new(0, 50, 0, 20),
            Position = UDim2.new(1, -55, 0, 5),
            BackgroundTransparency = 1,
            Text = tostring(options.Default or options.Min or 0),
            TextColor3 = self.Window.Theme.Accent,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Right,
            Font = Enum.Font.Code
        })
        
        local sliderFrame = CreateElement("Frame", {
            Name = "SliderFrame",
            Parent = container,
            Size = UDim2.new(1, -20, 0, 6),
            Position = UDim2.new(0, 10, 1, -15),
            BackgroundColor3 = self.Window.Theme.Background,
            BorderSizePixel = 0
        })
        
        AddCornerRadius(sliderFrame, 3)
        AddBorder(sliderFrame, self.Window.Theme.Border, 1)
        
        local sliderButton = CreateElement("TextButton", {
            Name = "SliderButton",
            Parent = sliderFrame,
            Size = UDim2.new(0, 20, 0, 20),
            Position = UDim2.new(0, -10, 0, -7),
            BackgroundColor3 = self.Window.Theme.Accent,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false
        })
        
        AddCornerRadius(sliderButton, 10)
        AddBorder(sliderButton, self.Window.Theme.Border, 1)
        
        local min = options.Min or 0
        local max = options.Max or 100
        local current = options.Default or min
        self.Window.Flags[options.Flag or options.Text] = current
        
        local function updateSlider(value)
            current = math.clamp(value, min, max)
            self.Window.Flags[options.Flag or options.Text] = current
            valueLabel.Text = tostring(current)
            
            local percentage = (current - min) / (max - min)
            sliderButton.Position = UDim2.new(percentage, -10, 0, -7)
            
            if options.Callback then
                options.Callback(current)
            end
        end
        
        local dragging = false
        sliderButton.MouseButton1Down:Connect(function()
            dragging = true
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local relativePos = math.clamp((input.Position.X - sliderFrame.AbsolutePosition.X) / sliderFrame.AbsoluteSize.X, 0, 1)
                local value = min + (max - min) * relativePos
                updateSlider(math.floor(value))
            end
        end)
        
        updateSlider(current)
        
        return container
    end
    
    function tab:CreateInput(options)
        local container = CreateElement("Frame", {
            Name = "InputContainer",
            Parent = self.Content,
            Size = UDim2.new(1, -20, 0, 50),
            BackgroundColor3 = self.Window.Theme.Foreground,
            BorderSizePixel = 0
        })
        
        AddCornerRadius(container, 8)
        AddBorder(container, self.Window.Theme.Border, 1)
        
        local label = CreateElement("TextLabel", {
            Name = "Label",
            Parent = container,
            Size = UDim2.new(1, -10, 0, 20),
            Position = UDim2.new(0, 10, 0, 5),
            BackgroundTransparency = 1,
            Text = options.Text or "Input",
            TextColor3 = self.Window.Theme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = Enum.Font.Code
        })
        
        local textBox = CreateElement("TextBox", {
            Name = "TextBox",
            Parent = container,
            Size = UDim2.new(1, -20, 0, 20),
            Position = UDim2.new(0, 10, 1, -25),
            BackgroundColor3 = self.Window.Theme.Background,
            BorderSizePixel = 0,
            Text = options.Default or "",
            TextColor3 = self.Window.Theme.Text,
            TextSize = 12,
            PlaceholderText = options.Placeholder or "Enter text...",
            PlaceholderColor3 = self.Window.Theme.TextSecondary,
            Font = Enum.Font.Code,
            ClearTextOnFocus = false
        })
        
        AddCornerRadius(textBox, 6)
        AddBorder(textBox, self.Window.Theme.Border, 1)
        
        self.Window.Flags[options.Flag or options.Text] = options.Default or ""
        
        textBox.FocusLost:Connect(function()
            self.Window.Flags[options.Flag or options.Text] = textBox.Text
            if options.Callback then
                options.Callback(textBox.Text)
            end
        end)
        
        return container
    end
    
    -- Add to tabs
    table.insert(self.Tabs, tab)
    
    -- Select first tab automatically
    if #self.Tabs == 1 then
        self:SelectTab(tab)
    end
    
    return tab
end

function Window:SelectTab(selectedTab)
    for _, tab in pairs(self.Tabs) do
        if tab == selectedTab then
            tab.IsActive = true
            tab.Content.Visible = true
            tab.Button.BackgroundColor3 = self.Theme.Accent
            tab.Button.TextColor3 = Color3.fromRGB(0, 0, 0)
        else
            tab.IsActive = false
            tab.Content.Visible = false
            tab.Button.BackgroundColor3 = self.Theme.Foreground
            tab.Button.TextColor3 = self.Theme.TextSecondary
        end
    end
    
    self.CurrentTab = selectedTab
end

function Window:SaveFlags()
    SaveConfig(self.Title, self.Flags)
end

function Window:LoadFlags()
    local config = LoadConfig(self.Title)
    for flag, value in pairs(config) do
        self.Flags[flag] = value
    end
end

function Window:Destroy()
    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end
    
    CompactHub.Windows[self.Title] = nil
end

-- Main Library Functions
function CompactHub:CreateWindow(options)
    return Window.new(options)
end

function CompactHub:GetFlag(flag)
    for _, window in pairs(self.Windows) do
        if window.Flags[flag] then
            return window.Flags[flag]
        end
    end
    return nil
end

function CompactHub:SetFlag(flag, value)
    for _, window in pairs(self.Windows) do
        if window.Flags[flag] ~= nil then
            window.Flags[flag] = value
            break
        end
    end
end

function CompactHub:Destroy()
    for _, window in pairs(self.Windows) do
        window:Destroy()
    end
    
    self.Windows = {}
    self.Flags = {}
    self.Connections = {}
end

-- Return the library
return CompactHub

