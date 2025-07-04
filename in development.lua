--[[
    CompactHub GUI Library v2.0 - Fixed Release
    A sleek, mobile-friendly GUI library for Roblox scripts
    
    Features:
    - Sharp angular design (no rounded corners)
    - Mobile-optimized portrait layout (320x480)
    - Easy loadstring API
    - Smooth animations
    - Multiple themes
    - Tabs positioned on the right side
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
    Version = "2.0.1",
    Build = "CH201",
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
    DefaultSize = UDim2.new(0, 320, 0, 480), -- Mobile-friendly portrait
    MinimizedSize = UDim2.new(0, 50, 0, 50),
    TabWidth = 60 -- Width for right-side tabs
}

-- Themes with sharp, modern colors
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
        if property ~= "CornerRadius" then -- Skip corner radius for sharp design
            element[property] = value
        end
    end
    return element
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
    self.IsVisible = true
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
    
    -- Main Frame (Sharp corners, no rounding)
    self.MainFrame = CreateElement("Frame", {
        Name = "MainFrame",
        Parent = self.ScreenGui,
        Size = self.Size,
        Position = UDim2.new(0.5, -self.Size.X.Offset/2, 0.5, -self.Size.Y.Offset/2),
        BackgroundColor3 = self.Theme.Background,
        BorderSizePixel = 0
    })
    
    -- Sharp border
    AddBorder(self.MainFrame, self.Theme.Border, 2)
    
    -- Title Bar
    self.TitleBar = CreateElement("Frame", {
        Name = "TitleBar",
        Parent = self.MainFrame,
        Size = UDim2.new(1, 0, 0, 35),
        BackgroundColor3 = self.Theme.Foreground,
        BorderSizePixel = 0
    })
    
    AddBorder(self.TitleBar, self.Theme.Border, 1)
    
    -- Title Text
    self.TitleLabel = CreateElement("TextLabel", {
        Name = "Title",
        Parent = self.TitleBar,
        Size = UDim2.new(1, -60, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = self.Title,
        TextColor3 = self.Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.Code
    })
    
    -- Minimize Button (Sharp square)
    self.MinimizeButton = CreateElement("TextButton", {
        Name = "MinimizeButton",
        Parent = self.TitleBar,
        Size = UDim2.new(0, 25, 0, 25),
        Position = UDim2.new(1, -30, 0, 5),
        BackgroundColor3 = self.Theme.Accent,
        BorderSizePixel = 0,
        Text = "â€”",
        TextColor3 = Color3.fromRGB(0, 0, 0),
        TextSize = 16,
        Font = Enum.Font.Code
    })
    
    AddBorder(self.MinimizeButton, self.Theme.Border, 1)
    
    -- Tab Container (Right side, vertical)
    self.TabContainer = CreateElement("Frame", {
        Name = "TabContainer",
        Parent = self.MainFrame,
        Size = UDim2.new(0, CONFIG.TabWidth, 1, -35),
        Position = UDim2.new(1, -CONFIG.TabWidth, 0, 35),
        BackgroundColor3 = self.Theme.Foreground,
        BorderSizePixel = 0
    })
    
    AddBorder(self.TabContainer, self.Theme.Border, 1)
    
    CreateElement("UIListLayout", {
        Parent = self.TabContainer,
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        Padding = UDim.new(0, 2)
    })
    
    -- Content Area (Adjusted for right-side tabs)
    self.ContentFrame = CreateElement("ScrollingFrame", {
        Name = "Content",
        Parent = self.MainFrame,
        Size = UDim2.new(1, -CONFIG.TabWidth, 1, -35),
        Position = UDim2.new(0, 0, 0, 35),
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
    
    -- Logo Frame (for minimized state) - Sharp square
    self.LogoFrame = CreateElement("Frame", {
        Name = "LogoFrame",
        Parent = self.ScreenGui,
        Size = CONFIG.MinimizedSize,
        Position = UDim2.new(1, -60, 0, 10),
        BackgroundColor3 = self.Theme.Accent,
        BorderSizePixel = 0,
        Visible = false
    })
    
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
    
    self.LogoFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self:ToggleMinimize()
        end
    end)
    
    -- Dragging functionality
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    self.TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.MainFrame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            self.MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
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
            TweenElement(self.MainFrame, {Size = self.Size}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
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
    
    -- Update colors
    self.MainFrame.BackgroundColor3 = theme.Background
    self.TitleBar.BackgroundColor3 = theme.Foreground
    self.TabContainer.BackgroundColor3 = theme.Foreground
    self.TitleLabel.TextColor3 = theme.Text
    self.MinimizeButton.BackgroundColor3 = theme.Accent
    self.LogoFrame.BackgroundColor3 = theme.Accent
    self.ContentFrame.ScrollBarImageColor3 = theme.Accent
    
    -- Update borders
    for _, element in pairs({self.MainFrame, self.TitleBar, self.TabContainer, self.MinimizeButton, self.LogoFrame}) do
        local border = element:FindFirstChild("UIStroke")
        if border then
            border.Color = theme.Border
        end
    end
    
    -- Update tab colors
    for _, tab in pairs(self.Tabs) do
        tab:UpdateTheme(theme)
    end
end

function Window:CreateTab(options)
    local tab = {}
    tab.Title = options.Title or "Tab"
    tab.Icon = options.Icon or "T"
    tab.Window = self
    tab.Components = {}
    tab.IsActive = false
    
    -- Create Tab Button (Square for sharp design)
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
        
        AddBorder(toggle, self.Window.Theme.Border, 1)
        
        local isToggled = options.Default or false
        self.Window.Flags[options.Flag or options.Text] = isToggled
        
        toggle.MouseButton1Click:Connect(function()
            isToggled = not isToggled
            self.Window.Flags[options.Flag or options.Text] = isT
