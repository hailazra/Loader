--[[
    AstroHubV3 - GUI Library untuk Roblox
    Versi: 1.0.0
    Dibuat dengan inspirasi dari Rayfield
    Tema: Manga (Hitam/Putih) dan Space/Langit
]]

local AstroHubV3 = {}
AstroHubV3.__index = AstroHubV3

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- Variables
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Tema
local Themes = {
    Manga = {
        Background = Color3.fromRGB(255, 255, 255),
        Secondary = Color3.fromRGB(240, 240, 240),
        Accent = Color3.fromRGB(0, 0, 0),
        Text = Color3.fromRGB(0, 0, 0),
        TextSecondary = Color3.fromRGB(100, 100, 100),
        Border = Color3.fromRGB(200, 200, 200),
        Toggle = Color3.fromRGB(50, 50, 50),
        ToggleActive = Color3.fromRGB(0, 0, 0)
    },
    Space = {
        Background = Color3.fromRGB(15, 15, 25),
        Secondary = Color3.fromRGB(25, 25, 40),
        Accent = Color3.fromRGB(100, 150, 255),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(180, 180, 180),
        Border = Color3.fromRGB(50, 50, 80),
        Toggle = Color3.fromRGB(60, 60, 100),
        ToggleActive = Color3.fromRGB(100, 150, 255)
    }
}

-- Utility Functions
local function CreateTween(object, properties, duration, easingStyle, easingDirection)
    local tweenInfo = TweenInfo.new(
        duration or 0.3,
        easingStyle or Enum.EasingStyle.Quad,
        easingDirection or Enum.EasingDirection.Out
    )
    return TweenService:Create(object, tweenInfo, properties)
end

local function CreateCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = parent
    return corner
end

local function CreateStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Color3.fromRGB(200, 200, 200)
    stroke.Thickness = thickness or 1
    stroke.Parent = parent
    return stroke
end

-- Main Library Functions
function AstroHubV3:CreateWindow(config)
    local Window = {}
    Window.Tabs = {}
    Window.CurrentTab = nil
    Window.Theme = Themes[config.Theme] or Themes.Manga
    Window.IsMinimized = false
    
    -- Main ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AstroHubV3"
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 500, 0, 250)
    MainFrame.Position = UDim2.new(0.5, -250, 0.5, -125)
    MainFrame.BackgroundColor3 = Window.Theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    CreateCorner(MainFrame, 12)
    CreateStroke(MainFrame, Window.Theme.Border, 2)
    
    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 35)
    TitleBar.Position = UDim2.new(0, 0, 0, 0)
    TitleBar.BackgroundColor3 = Window.Theme.Secondary
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    CreateCorner(TitleBar, 12)
    
    -- Title Text
    local TitleText = Instance.new("TextLabel")
    TitleText.Name = "TitleText"
    TitleText.Size = UDim2.new(1, -70, 1, 0)
    TitleText.Position = UDim2.new(0, 10, 0, 0)
    TitleText.BackgroundTransparency = 1
    TitleText.Text = config.Name or "AstroHubV3"
    TitleText.TextColor3 = Window.Theme.Text
    TitleText.TextSize = 14
    TitleText.Font = Enum.Font.GothamBold
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.Parent = TitleBar
    
    -- Minimize Button
    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Name = "MinimizeButton"
    MinimizeButton.Size = UDim2.new(0, 25, 0, 25)
    MinimizeButton.Position = UDim2.new(1, -60, 0, 5)
    MinimizeButton.BackgroundColor3 = Window.Theme.Toggle
    MinimizeButton.Text = "-"
    MinimizeButton.TextColor3 = Window.Theme.Text
    MinimizeButton.TextSize = 16
    MinimizeButton.Font = Enum.Font.GothamBold
    MinimizeButton.BorderSizePixel = 0
    MinimizeButton.Parent = TitleBar
    CreateCorner(MinimizeButton, 4)
    
    -- Close Button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, 25, 0, 25)
    CloseButton.Position = UDim2.new(1, -30, 0, 5)
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 12
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.BorderSizePixel = 0
    CloseButton.Parent = TitleBar
    CreateCorner(CloseButton, 4)
    
    -- Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 150, 1, -35)
    Sidebar.Position = UDim2.new(0, 0, 0, 35)
    Sidebar.BackgroundColor3 = Window.Theme.Secondary
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame
    
    local SidebarList = Instance.new("UIListLayout")
    SidebarList.SortOrder = Enum.SortOrder.LayoutOrder
    SidebarList.Padding = UDim.new(0, 2)
    SidebarList.Parent = Sidebar
    
    -- Content Area
    local ContentArea = Instance.new("Frame")
    ContentArea.Name = "ContentArea"
    ContentArea.Size = UDim2.new(1, -150, 1, -35)
    ContentArea.Position = UDim2.new(0, 150, 0, 35)
    ContentArea.BackgroundColor3 = Window.Theme.Background
    ContentArea.BorderSizePixel = 0
    ContentArea.Parent = MainFrame
    
    -- Dragging functionality
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    -- Minimize functionality
    MinimizeButton.MouseButton1Click:Connect(function()
        Window.IsMinimized = not Window.IsMinimized
        if Window.IsMinimized then
            CreateTween(MainFrame, {Size = UDim2.new(0, 200, 0, 35)}, 0.3):Play()
            MinimizeButton.Text = "+"
        else
            CreateTween(MainFrame, {Size = UDim2.new(0, 500, 0, 250)}, 0.3):Play()
            MinimizeButton.Text = "-"
        end
    end)
    
    -- Close functionality
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    -- Window methods
    function Window:CreateTab(config)
        local Tab = {}
        Tab.Name = config.Name or "Tab"
        Tab.Icon = config.Icon or ""
        Tab.Elements = {}
        Tab.Active = false
        
        -- Tab Button
        local TabButton = Instance.new("TextButton")
        TabButton.Name = Tab.Name .. "Button"
        TabButton.Size = UDim2.new(1, 0, 0, 35)
        TabButton.BackgroundColor3 = Window.Theme.Secondary
        TabButton.Text = Tab.Icon .. " " .. Tab.Name
        TabButton.TextColor3 = Window.Theme.TextSecondary
        TabButton.TextSize = 12
        TabButton.Font = Enum.Font.Gotham
        TabButton.TextXAlignment = Enum.TextXAlignment.Left
        TabButton.BorderSizePixel = 0
        TabButton.Parent = Sidebar
        CreateCorner(TabButton, 6)
        
        local TabPadding = Instance.new("UIPadding")
        TabPadding.PaddingLeft = UDim.new(0, 10)
        TabPadding.Parent = TabButton
        
        -- Tab Content
        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Name = Tab.Name .. "Content"
        TabContent.Size = UDim2.new(1, -10, 1, -10)
        TabContent.Position = UDim2.new(0, 5, 0, 5)
        TabContent.BackgroundTransparency = 1
        TabContent.BorderSizePixel = 0
        TabContent.ScrollBarThickness = 4
        TabContent.ScrollBarImageColor3 = Window.Theme.Border
        TabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabContent.Visible = false
        TabContent.Parent = ContentArea
        
        local ContentList = Instance.new("UIListLayout")
        ContentList.SortOrder = Enum.SortOrder.LayoutOrder
        ContentList.Padding = UDim.new(0, 5)
        ContentList.Parent = TabContent
        
        ContentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentList.AbsoluteContentSize.Y + 10)
        end)
        
        -- Tab activation
        TabButton.MouseButton1Click:Connect(function()
            if Window.CurrentTab then
                Window.CurrentTab.TabButton.BackgroundColor3 = Window.Theme.Secondary
                Window.CurrentTab.TabButton.TextColor3 = Window.Theme.TextSecondary
                Window.CurrentTab.TabContent.Visible = false
            end
            
            Tab.Active = true
            TabButton.BackgroundColor3 = Window.Theme.Toggle
            TabButton.TextColor3 = Window.Theme.Text
            TabContent.Visible = true
            Window.CurrentTab = {TabButton = TabButton, TabContent = TabContent}
        end)
        
        -- Set first tab as active
        if #Window.Tabs == 0 then
            TabButton.BackgroundColor3 = Window.Theme.Toggle
            TabButton.TextColor3 = Window.Theme.Text
            TabContent.Visible = true
            Window.CurrentTab = {TabButton = TabButton, TabContent = TabContent}
        end
        
        Tab.TabButton = TabButton
        Tab.TabContent = TabContent
        Tab.ContentList = ContentList
        
        table.insert(Window.Tabs, Tab)
        return Tab
    end
    
    Window.ScreenGui = ScreenGui
    Window.MainFrame = MainFrame
    return Window
end

return AstroHubV3


-- Tab methods untuk membuat komponen UI
function Tab:CreateToggle(config)
    local Toggle = {}
    Toggle.Name = config.Name or "Toggle"
    Toggle.Description = config.Description or ""
    Toggle.Default = config.Default or false
    Toggle.Callback = config.Callback or function() end
    Toggle.Value = Toggle.Default
    
    -- Toggle Container
    local ToggleContainer = Instance.new("Frame")
    ToggleContainer.Name = Toggle.Name .. "Container"
    ToggleContainer.Size = UDim2.new(1, 0, 0, 45)
    ToggleContainer.BackgroundColor3 = Window.Theme.Secondary
    ToggleContainer.BorderSizePixel = 0
    ToggleContainer.Parent = self.TabContent
    CreateCorner(ToggleContainer, 8)
    
    -- Toggle Label
    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Name = "Label"
    ToggleLabel.Size = UDim2.new(1, -60, 0, 20)
    ToggleLabel.Position = UDim2.new(0, 10, 0, 5)
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Text = Toggle.Name
    ToggleLabel.TextColor3 = Window.Theme.Text
    ToggleLabel.TextSize = 14
    ToggleLabel.Font = Enum.Font.GothamBold
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    ToggleLabel.Parent = ToggleContainer
    
    -- Toggle Description
    if Toggle.Description ~= "" then
        local ToggleDesc = Instance.new("TextLabel")
        ToggleDesc.Name = "Description"
        ToggleDesc.Size = UDim2.new(1, -60, 0, 15)
        ToggleDesc.Position = UDim2.new(0, 10, 0, 25)
        ToggleDesc.BackgroundTransparency = 1
        ToggleDesc.Text = Toggle.Description
        ToggleDesc.TextColor3 = Window.Theme.TextSecondary
        ToggleDesc.TextSize = 11
        ToggleDesc.Font = Enum.Font.Gotham
        ToggleDesc.TextXAlignment = Enum.TextXAlignment.Left
        ToggleDesc.Parent = ToggleContainer
    end
    
    -- Toggle Switch Background
    local ToggleBG = Instance.new("Frame")
    ToggleBG.Name = "ToggleBG"
    ToggleBG.Size = UDim2.new(0, 40, 0, 20)
    ToggleBG.Position = UDim2.new(1, -50, 0, 12)
    ToggleBG.BackgroundColor3 = Window.Theme.Toggle
    ToggleBG.BorderSizePixel = 0
    ToggleBG.Parent = ToggleContainer
    CreateCorner(ToggleBG, 10)
    
    -- Toggle Switch Circle
    local ToggleCircle = Instance.new("Frame")
    ToggleCircle.Name = "ToggleCircle"
    ToggleCircle.Size = UDim2.new(0, 16, 0, 16)
    ToggleCircle.Position = UDim2.new(0, 2, 0, 2)
    ToggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ToggleCircle.BorderSizePixel = 0
    ToggleCircle.Parent = ToggleBG
    CreateCorner(ToggleCircle, 8)
    
    -- Toggle Button (Invisible)
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "ToggleButton"
    ToggleButton.Size = UDim2.new(1, 0, 1, 0)
    ToggleButton.BackgroundTransparency = 1
    ToggleButton.Text = ""
    ToggleButton.Parent = ToggleContainer
    
    -- Toggle Function
    local function UpdateToggle()
        if Toggle.Value then
            CreateTween(ToggleBG, {BackgroundColor3 = Window.Theme.ToggleActive}, 0.2):Play()
            CreateTween(ToggleCircle, {Position = UDim2.new(0, 22, 0, 2)}, 0.2):Play()
        else
            CreateTween(ToggleBG, {BackgroundColor3 = Window.Theme.Toggle}, 0.2):Play()
            CreateTween(ToggleCircle, {Position = UDim2.new(0, 2, 0, 2)}, 0.2):Play()
        end
        Toggle.Callback(Toggle.Value)
    end
    
    ToggleButton.MouseButton1Click:Connect(function()
        Toggle.Value = not Toggle.Value
        UpdateToggle()
    end)
    
    -- Set default state
    if Toggle.Default then
        Toggle.Value = true
        UpdateToggle()
    end
    
    function Toggle:Set(value)
        Toggle.Value = value
        UpdateToggle()
    end
    
    table.insert(self.Elements, Toggle)
    return Toggle
end

function Tab:CreateButton(config)
    local Button = {}
    Button.Name = config.Name or "Button"
    Button.Description = config.Description or ""
    Button.Callback = config.Callback or function() end
    
    -- Button Container
    local ButtonContainer = Instance.new("Frame")
    ButtonContainer.Name = Button.Name .. "Container"
    ButtonContainer.Size = UDim2.new(1, 0, 0, 35)
    ButtonContainer.BackgroundColor3 = Window.Theme.Secondary
    ButtonContainer.BorderSizePixel = 0
    ButtonContainer.Parent = self.TabContent
    CreateCorner(ButtonContainer, 8)
    
    -- Button
    local ButtonFrame = Instance.new("TextButton")
    ButtonFrame.Name = "Button"
    ButtonFrame.Size = UDim2.new(1, -10, 1, -10)
    ButtonFrame.Position = UDim2.new(0, 5, 0, 5)
    ButtonFrame.BackgroundColor3 = Window.Theme.Toggle
    ButtonFrame.Text = Button.Name
    ButtonFrame.TextColor3 = Window.Theme.Text
    ButtonFrame.TextSize = 12
    ButtonFrame.Font = Enum.Font.GothamBold
    ButtonFrame.BorderSizePixel = 0
    ButtonFrame.Parent = ButtonContainer
    CreateCorner(ButtonFrame, 6)
    
    -- Button hover effect
    ButtonFrame.MouseEnter:Connect(function()
        CreateTween(ButtonFrame, {BackgroundColor3 = Window.Theme.ToggleActive}, 0.2):Play()
    end)
    
    ButtonFrame.MouseLeave:Connect(function()
        CreateTween(ButtonFrame, {BackgroundColor3 = Window.Theme.Toggle}, 0.2):Play()
    end)
    
    ButtonFrame.MouseButton1Click:Connect(function()
        Button.Callback()
    end)
    
    table.insert(self.Elements, Button)
    return Button
end

function Tab:CreateSlider(config)
    local Slider = {}
    Slider.Name = config.Name or "Slider"
    Slider.Description = config.Description or ""
    Slider.Min = config.Min or 0
    Slider.Max = config.Max or 100
    Slider.Default = config.Default or Slider.Min
    Slider.Increment = config.Increment or 1
    Slider.Callback = config.Callback or function() end
    Slider.Value = Slider.Default
    
    -- Slider Container
    local SliderContainer = Instance.new("Frame")
    SliderContainer.Name = Slider.Name .. "Container"
    SliderContainer.Size = UDim2.new(1, 0, 0, 50)
    SliderContainer.BackgroundColor3 = Window.Theme.Secondary
    SliderContainer.BorderSizePixel = 0
    SliderContainer.Parent = self.TabContent
    CreateCorner(SliderContainer, 8)
    
    -- Slider Label
    local SliderLabel = Instance.new("TextLabel")
    SliderLabel.Name = "Label"
    SliderLabel.Size = UDim2.new(1, -60, 0, 20)
    SliderLabel.Position = UDim2.new(0, 10, 0, 5)
    SliderLabel.BackgroundTransparency = 1
    SliderLabel.Text = Slider.Name
    SliderLabel.TextColor3 = Window.Theme.Text
    SliderLabel.TextSize = 14
    SliderLabel.Font = Enum.Font.GothamBold
    SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    SliderLabel.Parent = SliderContainer
    
    -- Slider Value Label
    local SliderValueLabel = Instance.new("TextLabel")
    SliderValueLabel.Name = "ValueLabel"
    SliderValueLabel.Size = UDim2.new(0, 50, 0, 20)
    SliderValueLabel.Position = UDim2.new(1, -60, 0, 5)
    SliderValueLabel.BackgroundTransparency = 1
    SliderValueLabel.Text = tostring(Slider.Value)
    SliderValueLabel.TextColor3 = Window.Theme.Text
    SliderValueLabel.TextSize = 12
    SliderValueLabel.Font = Enum.Font.Gotham
    SliderValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    SliderValueLabel.Parent = SliderContainer
    
    -- Slider Track
    local SliderTrack = Instance.new("Frame")
    SliderTrack.Name = "SliderTrack"
    SliderTrack.Size = UDim2.new(1, -20, 0, 6)
    SliderTrack.Position = UDim2.new(0, 10, 0, 30)
    SliderTrack.BackgroundColor3 = Window.Theme.Toggle
    SliderTrack.BorderSizePixel = 0
    SliderTrack.Parent = SliderContainer
    CreateCorner(SliderTrack, 3)
    
    -- Slider Fill
    local SliderFill = Instance.new("Frame")
    SliderFill.Name = "SliderFill"
    SliderFill.Size = UDim2.new(0, 0, 1, 0)
    SliderFill.Position = UDim2.new(0, 0, 0, 0)
    SliderFill.BackgroundColor3 = Window.Theme.ToggleActive
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderTrack
    CreateCorner(SliderFill, 3)
    
    -- Slider Handle
    local SliderHandle = Instance.new("Frame")
    SliderHandle.Name = "SliderHandle"
    SliderHandle.Size = UDim2.new(0, 12, 0, 12)
    SliderHandle.Position = UDim2.new(0, -6, 0, -3)
    SliderHandle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SliderHandle.BorderSizePixel = 0
    SliderHandle.Parent = SliderFill
    CreateCorner(SliderHandle, 6)
    CreateStroke(SliderHandle, Window.Theme.Border, 2)
    
    -- Slider functionality
    local dragging = false
    
    local function UpdateSlider(percentage)
        percentage = math.clamp(percentage, 0, 1)
        local value = Slider.Min + (Slider.Max - Slider.Min) * percentage
        value = math.floor(value / Slider.Increment + 0.5) * Slider.Increment
        value = math.clamp(value, Slider.Min, Slider.Max)
        
        Slider.Value = value
        SliderValueLabel.Text = tostring(value)
        
        CreateTween(SliderFill, {Size = UDim2.new(percentage, 0, 1, 0)}, 0.1):Play()
        CreateTween(SliderHandle, {Position = UDim2.new(percentage, -6, 0, -3)}, 0.1):Play()
        
        Slider.Callback(value)
    end
    
    SliderTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            local percentage = (input.Position.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X
            UpdateSlider(percentage)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local percentage = (input.Position.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X
            UpdateSlider(percentage)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    -- Set default value
    local defaultPercentage = (Slider.Default - Slider.Min) / (Slider.Max - Slider.Min)
    UpdateSlider(defaultPercentage)
    
    function Slider:Set(value)
        local percentage = (value - Slider.Min) / (Slider.Max - Slider.Min)
        UpdateSlider(percentage)
    end
    
    table.insert(self.Elements, Slider)
    return Slider
end

function Tab:CreateTextbox(config)
    local Textbox = {}
    Textbox.Name = config.Name or "Textbox"
    Textbox.Description = config.Description or ""
    Textbox.Default = config.Default or ""
    Textbox.PlaceholderText = config.PlaceholderText or "Enter text..."
    Textbox.Callback = config.Callback or function() end
    Textbox.Value = Textbox.Default
    
    -- Textbox Container
    local TextboxContainer = Instance.new("Frame")
    TextboxContainer.Name = Textbox.Name .. "Container"
    TextboxContainer.Size = UDim2.new(1, 0, 0, 50)
    TextboxContainer.BackgroundColor3 = Window.Theme.Secondary
    TextboxContainer.BorderSizePixel = 0
    TextboxContainer.Parent = self.TabContent
    CreateCorner(TextboxContainer, 8)
    
    -- Textbox Label
    local TextboxLabel = Instance.new("TextLabel")
    TextboxLabel.Name = "Label"
    TextboxLabel.Size = UDim2.new(1, 0, 0, 20)
    TextboxLabel.Position = UDim2.new(0, 10, 0, 5)
    TextboxLabel.BackgroundTransparency = 1
    TextboxLabel.Text = Textbox.Name
    TextboxLabel.TextColor3 = Window.Theme.Text
    TextboxLabel.TextSize = 14
    TextboxLabel.Font = Enum.Font.GothamBold
    TextboxLabel.TextXAlignment = Enum.TextXAlignment.Left
    TextboxLabel.Parent = TextboxContainer
    
    -- Textbox Input
    local TextboxInput = Instance.new("TextBox")
    TextboxInput.Name = "Input"
    TextboxInput.Size = UDim2.new(1, -20, 0, 20)
    TextboxInput.Position = UDim2.new(0, 10, 0, 25)
    TextboxInput.BackgroundColor3 = Window.Theme.Background
    TextboxInput.Text = Textbox.Default
    TextboxInput.PlaceholderText = Textbox.PlaceholderText
    TextboxInput.TextColor3 = Window.Theme.Text
    TextboxInput.PlaceholderColor3 = Window.Theme.TextSecondary
    TextboxInput.TextSize = 12
    TextboxInput.Font = Enum.Font.Gotham
    TextboxInput.TextXAlignment = Enum.TextXAlignment.Left
    TextboxInput.BorderSizePixel = 0
    TextboxInput.Parent = TextboxContainer
    CreateCorner(TextboxInput, 4)
    CreateStroke(TextboxInput, Window.Theme.Border, 1)
    
    local TextboxPadding = Instance.new("UIPadding")
    TextboxPadding.PaddingLeft = UDim.new(0, 8)
    TextboxPadding.PaddingRight = UDim.new(0, 8)
    TextboxPadding.Parent = TextboxInput
    
    TextboxInput.FocusLost:Connect(function()
        Textbox.Value = TextboxInput.Text
        Textbox.Callback(Textbox.Value)
    end)
    
    function Textbox:Set(text)
        Textbox.Value = text
        TextboxInput.Text = text
    end
    
    table.insert(self.Elements, Textbox)
    return Textbox
end

function Tab:CreateDropdown(config)
    local Dropdown = {}
    Dropdown.Name = config.Name or "Dropdown"
    Dropdown.Description = config.Description or ""
    Dropdown.Options = config.Options or {}
    Dropdown.Default = config.Default or (Dropdown.Options[1] or "")
    Dropdown.Callback = config.Callback or function() end
    Dropdown.Value = Dropdown.Default
    Dropdown.IsOpen = false
    
    -- Dropdown Container
    local DropdownContainer = Instance.new("Frame")
    DropdownContainer.Name = Dropdown.Name .. "Container"
    DropdownContainer.Size = UDim2.new(1, 0, 0, 50)
    DropdownContainer.BackgroundColor3 = Window.Theme.Secondary
    DropdownContainer.BorderSizePixel = 0
    DropdownContainer.Parent = self.TabContent
    CreateCorner(DropdownContainer, 8)
    
    -- Dropdown Label
    local DropdownLabel = Instance.new("TextLabel")
    DropdownLabel.Name = "Label"
    DropdownLabel.Size = UDim2.new(1, 0, 0, 20)
    DropdownLabel.Position = UDim2.new(0, 10, 0, 5)
    DropdownLabel.BackgroundTransparency = 1
    DropdownLabel.Text = Dropdown.Name
    DropdownLabel.TextColor3 = Window.Theme.Text
    DropdownLabel.TextSize = 14
    DropdownLabel.Font = Enum.Font.GothamBold
    DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
    DropdownLabel.Parent = DropdownContainer
    
    -- Dropdown Button
    local DropdownButton = Instance.new("TextButton")
    DropdownButton.Name = "DropdownButton"
    DropdownButton.Size = UDim2.new(1, -20, 0, 20)
    DropdownButton.Position = UDim2.new(0, 10, 0, 25)
    DropdownButton.BackgroundColor3 = Window.Theme.Background
    DropdownButton.Text = Dropdown.Default
    DropdownButton.TextColor3 = Window.Theme.Text
    DropdownButton.TextSize = 12
    DropdownButton.Font = Enum.Font.Gotham
    DropdownButton.TextXAlignment = Enum.TextXAlignment.Left
    DropdownButton.BorderSizePixel = 0
    DropdownButton.Parent = DropdownContainer
    CreateCorner(DropdownButton, 4)
    CreateStroke(DropdownButton, Window.Theme.Border, 1)
    
    local DropdownPadding = Instance.new("UIPadding")
    DropdownPadding.PaddingLeft = UDim.new(0, 8)
    DropdownPadding.PaddingRight = UDim.new(0, 25)
    DropdownPadding.Parent = DropdownButton
    
    -- Dropdown Arrow
    local DropdownArrow = Instance.new("TextLabel")
    DropdownArrow.Name = "Arrow"
    DropdownArrow.Size = UDim2.new(0, 20, 1, 0)
    DropdownArrow.Position = UDim2.new(1, -20, 0, 0)
    DropdownArrow.BackgroundTransparency = 1
    DropdownArrow.Text = "▼"
    DropdownArrow.TextColor3 = Window.Theme.TextSecondary
    DropdownArrow.TextSize = 10
    DropdownArrow.Font = Enum.Font.Gotham
    DropdownArrow.Parent = DropdownButton
    
    -- Dropdown List
    local DropdownList = Instance.new("Frame")
    DropdownList.Name = "DropdownList"
    DropdownList.Size = UDim2.new(1, -20, 0, 0)
    DropdownList.Position = UDim2.new(0, 10, 0, 50)
    DropdownList.BackgroundColor3 = Window.Theme.Background
    DropdownList.BorderSizePixel = 0
    DropdownList.Visible = false
    DropdownList.Parent = DropdownContainer
    CreateCorner(DropdownList, 4)
    CreateStroke(DropdownList, Window.Theme.Border, 1)
    
    local ListLayout = Instance.new("UIListLayout")
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Parent = DropdownList
    
    -- Create option buttons
    for i, option in ipairs(Dropdown.Options) do
        local OptionButton = Instance.new("TextButton")
        OptionButton.Name = "Option" .. i
        OptionButton.Size = UDim2.new(1, 0, 0, 25)
        OptionButton.BackgroundColor3 = Window.Theme.Background
        OptionButton.Text = option
        OptionButton.TextColor3 = Window.Theme.Text
        OptionButton.TextSize = 11
        OptionButton.Font = Enum.Font.Gotham
        OptionButton.TextXAlignment = Enum.TextXAlignment.Left
        OptionButton.BorderSizePixel = 0
        OptionButton.Parent = DropdownList
        
        local OptionPadding = Instance.new("UIPadding")
        OptionPadding.PaddingLeft = UDim.new(0, 8)
        OptionPadding.Parent = OptionButton
        
        OptionButton.MouseEnter:Connect(function()
            OptionButton.BackgroundColor3 = Window.Theme.Secondary
        end)
        
        OptionButton.MouseLeave:Connect(function()
            OptionButton.BackgroundColor3 = Window.Theme.Background
        end)
        
        OptionButton.MouseButton1Click:Connect(function()
            Dropdown.Value = option
            DropdownButton.Text = option
            Dropdown.IsOpen = false
            DropdownList.Visible = false
            DropdownContainer.Size = UDim2.new(1, 0, 0, 50)
            DropdownArrow.Text = "▼"
            Dropdown.Callback(option)
        end)
    end
    
    -- Update list size
    ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        DropdownList.Size = UDim2.new(1, -20, 0, ListLayout.AbsoluteContentSize.Y)
    end)
    
    -- Toggle dropdown
    DropdownButton.MouseButton1Click:Connect(function()
        Dropdown.IsOpen = not Dropdown.IsOpen
        if Dropdown.IsOpen then
            DropdownList.Visible = true
            DropdownContainer.Size = UDim2.new(1, 0, 0, 50 + ListLayout.AbsoluteContentSize.Y + 5)
            DropdownArrow.Text = "▲"
        else
            DropdownList.Visible = false
            DropdownContainer.Size = UDim2.new(1, 0, 0, 50)
            DropdownArrow.Text = "▼"
        end
    end)
    
    function Dropdown:Set(option)
        if table.find(Dropdown.Options, option) then
            Dropdown.Value = option
            DropdownButton.Text = option
        end
    end
    
    table.insert(self.Elements, Dropdown)
    return Dropdown
end

-- Notification System
function AstroHubV3:CreateNotification(config)
    local Notification = {}
    Notification.Title = config.Title or "Notification"
    Notification.Content = config.Content or ""
    Notification.Duration = config.Duration or 3
    Notification.Image = config.Image or ""
    
    -- Notification ScreenGui
    local NotificationGui = Instance.new("ScreenGui")
    NotificationGui.Name = "AstroNotification"
    NotificationGui.Parent = CoreGui
    
    -- Notification Frame
    local NotificationFrame = Instance.new("Frame")
    NotificationFrame.Name = "NotificationFrame"
    NotificationFrame.Size = UDim2.new(0, 300, 0, 80)
    NotificationFrame.Position = UDim2.new(1, 320, 0, 50)
    NotificationFrame.BackgroundColor3 = Themes.Space.Background
    NotificationFrame.BorderSizePixel = 0
    NotificationFrame.Parent = NotificationGui
    CreateCorner(NotificationFrame, 8)
    CreateStroke(NotificationFrame, Themes.Space.Border, 2)
    
    -- Notification Title
    local NotificationTitle = Instance.new("TextLabel")
    NotificationTitle.Name = "Title"
    NotificationTitle.Size = UDim2.new(1, -10, 0, 25)
    NotificationTitle.Position = UDim2.new(0, 10, 0, 5)
    NotificationTitle.BackgroundTransparency = 1
    NotificationTitle.Text = Notification.Title
    NotificationTitle.TextColor3 = Themes.Space.Text
    NotificationTitle.TextSize = 14
    NotificationTitle.Font = Enum.Font.GothamBold
    NotificationTitle.TextXAlignment = Enum.TextXAlignment.Left
    NotificationTitle.Parent = NotificationFrame
    
    -- Notification Content
    local NotificationContent = Instance.new("TextLabel")
    NotificationContent.Name = "Content"
    NotificationContent.Size = UDim2.new(1, -10, 0, 45)
    NotificationContent.Position = UDim2.new(0, 10, 0, 25)
    NotificationContent.BackgroundTransparency = 1
    NotificationContent.Text = Notification.Content
    NotificationContent.TextColor3 = Themes.Space.TextSecondary
    NotificationContent.TextSize = 11
    NotificationContent.Font = Enum.Font.Gotham
    NotificationContent.TextXAlignment = Enum.TextXAlignment.Left
    NotificationContent.TextYAlignment = Enum.TextYAlignment.Top
    NotificationContent.TextWrapped = true
    NotificationContent.Parent = NotificationFrame
    
    -- Animate in
    CreateTween(NotificationFrame, {Position = UDim2.new(1, -310, 0, 50)}, 0.5, Enum.EasingStyle.Back):Play()
    
    -- Auto dismiss
    wait(Notification.Duration)
    CreateTween(NotificationFrame, {Position = UDim2.new(1, 320, 0, 50)}, 0.3):Play()
    wait(0.3)
    NotificationGui:Destroy()
    
    return Notification
end

-- Loadstring function
function AstroHubV3:Init()
    return AstroHubV3
end


-- Keybind Component
function Tab:CreateKeybind(config)
    local Keybind = {}
    Keybind.Name = config.Name or "Keybind"
    Keybind.Description = config.Description or ""
    Keybind.Default = config.Default or Enum.KeyCode.E
    Keybind.Callback = config.Callback or function() end
    Keybind.CurrentKey = Keybind.Default
    Keybind.Binding = false
    
    -- Keybind Container
    local KeybindContainer = Instance.new("Frame")
    KeybindContainer.Name = Keybind.Name .. "Container"
    KeybindContainer.Size = UDim2.new(1, 0, 0, 45)
    KeybindContainer.BackgroundColor3 = Window.Theme.Secondary
    KeybindContainer.BorderSizePixel = 0
    KeybindContainer.Parent = self.TabContent
    CreateCorner(KeybindContainer, 8)
    
    -- Keybind Label
    local KeybindLabel = Instance.new("TextLabel")
    KeybindLabel.Name = "Label"
    KeybindLabel.Size = UDim2.new(1, -80, 0, 20)
    KeybindLabel.Position = UDim2.new(0, 10, 0, 5)
    KeybindLabel.BackgroundTransparency = 1
    KeybindLabel.Text = Keybind.Name
    KeybindLabel.TextColor3 = Window.Theme.Text
    KeybindLabel.TextSize = 14
    KeybindLabel.Font = Enum.Font.GothamBold
    KeybindLabel.TextXAlignment = Enum.TextXAlignment.Left
    KeybindLabel.Parent = KeybindContainer
    
    -- Keybind Description
    if Keybind.Description ~= "" then
        local KeybindDesc = Instance.new("TextLabel")
        KeybindDesc.Name = "Description"
        KeybindDesc.Size = UDim2.new(1, -80, 0, 15)
        KeybindDesc.Position = UDim2.new(0, 10, 0, 25)
        KeybindDesc.BackgroundTransparency = 1
        KeybindDesc.Text = Keybind.Description
        KeybindDesc.TextColor3 = Window.Theme.TextSecondary
        KeybindDesc.TextSize = 11
        KeybindDesc.Font = Enum.Font.Gotham
        KeybindDesc.TextXAlignment = Enum.TextXAlignment.Left
        KeybindDesc.Parent = KeybindContainer
    end
    
    -- Keybind Button
    local KeybindButton = Instance.new("TextButton")
    KeybindButton.Name = "KeybindButton"
    KeybindButton.Size = UDim2.new(0, 60, 0, 25)
    KeybindButton.Position = UDim2.new(1, -70, 0, 10)
    KeybindButton.BackgroundColor3 = Window.Theme.Toggle
    KeybindButton.Text = Keybind.CurrentKey.Name
    KeybindButton.TextColor3 = Window.Theme.Text
    KeybindButton.TextSize = 11
    KeybindButton.Font = Enum.Font.Gotham
    KeybindButton.BorderSizePixel = 0
    KeybindButton.Parent = KeybindContainer
    CreateCorner(KeybindButton, 4)
    
    -- Keybind functionality
    KeybindButton.MouseButton1Click:Connect(function()
        if not Keybind.Binding then
            Keybind.Binding = true
            KeybindButton.Text = "..."
            KeybindButton.BackgroundColor3 = Window.Theme.ToggleActive
        end
    end)
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and Keybind.Binding then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                Keybind.CurrentKey = input.KeyCode
                KeybindButton.Text = input.KeyCode.Name
                KeybindButton.BackgroundColor3 = Window.Theme.Toggle
                Keybind.Binding = false
            end
        elseif not gameProcessed and input.KeyCode == Keybind.CurrentKey then
            Keybind.Callback()
        end
    end)
    
    function Keybind:Set(keycode)
        Keybind.CurrentKey = keycode
        KeybindButton.Text = keycode.Name
    end
    
    table.insert(self.Elements, Keybind)
    return Keybind
end

-- ColorPicker Component
function Tab:CreateColorPicker(config)
    local ColorPicker = {}
    ColorPicker.Name = config.Name or "ColorPicker"
    ColorPicker.Description = config.Description or ""
    ColorPicker.Default = config.Default or Color3.fromRGB(255, 255, 255)
    ColorPicker.Callback = config.Callback or function() end
    ColorPicker.Value = ColorPicker.Default
    
    -- ColorPicker Container
    local ColorPickerContainer = Instance.new("Frame")
    ColorPickerContainer.Name = ColorPicker.Name .. "Container"
    ColorPickerContainer.Size = UDim2.new(1, 0, 0, 45)
    ColorPickerContainer.BackgroundColor3 = Window.Theme.Secondary
    ColorPickerContainer.BorderSizePixel = 0
    ColorPickerContainer.Parent = self.TabContent
    CreateCorner(ColorPickerContainer, 8)
    
    -- ColorPicker Label
    local ColorPickerLabel = Instance.new("TextLabel")
    ColorPickerLabel.Name = "Label"
    ColorPickerLabel.Size = UDim2.new(1, -60, 0, 20)
    ColorPickerLabel.Position = UDim2.new(0, 10, 0, 5)
    ColorPickerLabel.BackgroundTransparency = 1
    ColorPickerLabel.Text = ColorPicker.Name
    ColorPickerLabel.TextColor3 = Window.Theme.Text
    ColorPickerLabel.TextSize = 14
    ColorPickerLabel.Font = Enum.Font.GothamBold
    ColorPickerLabel.TextXAlignment = Enum.TextXAlignment.Left
    ColorPickerLabel.Parent = ColorPickerContainer
    
    -- ColorPicker Preview
    local ColorPreview = Instance.new("Frame")
    ColorPreview.Name = "ColorPreview"
    ColorPreview.Size = UDim2.new(0, 40, 0, 25)
    ColorPreview.Position = UDim2.new(1, -50, 0, 10)
    ColorPreview.BackgroundColor3 = ColorPicker.Default
    ColorPreview.BorderSizePixel = 0
    ColorPreview.Parent = ColorPickerContainer
    CreateCorner(ColorPreview, 4)
    CreateStroke(ColorPreview, Window.Theme.Border, 2)
    
    -- Simple color picker (basic implementation)
    local ColorButton = Instance.new("TextButton")
    ColorButton.Name = "ColorButton"
    ColorButton.Size = UDim2.new(1, 0, 1, 0)
    ColorButton.BackgroundTransparency = 1
    ColorButton.Text = ""
    ColorButton.Parent = ColorPreview
    
    ColorButton.MouseButton1Click:Connect(function()
        -- Simple random color for demo (in real implementation, you'd want a proper color picker)
        local newColor = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
        ColorPicker.Value = newColor
        ColorPreview.BackgroundColor3 = newColor
        ColorPicker.Callback(newColor)
    end)
    
    function ColorPicker:Set(color)
        ColorPicker.Value = color
        ColorPreview.BackgroundColor3 = color
    end
    
    table.insert(self.Elements, ColorPicker)
    return ColorPicker
end

-- Section Component (untuk mengorganisir elemen)
function Tab:CreateSection(config)
    local Section = {}
    Section.Name = config.Name or "Section"
    
    -- Section Container
    local SectionContainer = Instance.new("Frame")
    SectionContainer.Name = Section.Name .. "Container"
    SectionContainer.Size = UDim2.new(1, 0, 0, 30)
    SectionContainer.BackgroundTransparency = 1
    SectionContainer.BorderSizePixel = 0
    SectionContainer.Parent = self.TabContent
    
    -- Section Label
    local SectionLabel = Instance.new("TextLabel")
    SectionLabel.Name = "Label"
    SectionLabel.Size = UDim2.new(1, 0, 1, 0)
    SectionLabel.Position = UDim2.new(0, 0, 0, 0)
    SectionLabel.BackgroundTransparency = 1
    SectionLabel.Text = Section.Name
    SectionLabel.TextColor3 = Window.Theme.Accent
    SectionLabel.TextSize = 16
    SectionLabel.Font = Enum.Font.GothamBold
    SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
    SectionLabel.Parent = SectionContainer
    
    -- Section Line
    local SectionLine = Instance.new("Frame")
    SectionLine.Name = "Line"
    SectionLine.Size = UDim2.new(1, -10, 0, 1)
    SectionLine.Position = UDim2.new(0, 5, 1, -5)
    SectionLine.BackgroundColor3 = Window.Theme.Border
    SectionLine.BorderSizePixel = 0
    SectionLine.Parent = SectionContainer
    
    table.insert(self.Elements, Section)
    return Section
end

-- Configuration System
local ConfigSystem = {}
ConfigSystem.ConfigFolder = "AstroHubV3_Configs"

function ConfigSystem:SaveConfig(window, configName)
    local config = {
        Theme = window.Theme == Themes.Manga and "Manga" or "Space",
        Elements = {}
    }
    
    for _, tab in pairs(window.Tabs) do
        for _, element in pairs(tab.Elements) do
            if element.Value ~= nil then
                table.insert(config.Elements, {
                    Name = element.Name,
                    Value = element.Value
                })
            end
        end
    end
    
    -- In a real implementation, you'd save this to a file
    -- For now, we'll just store it in a global variable
    _G.AstroHubV3_Config = config
    
    AstroHubV3:CreateNotification({
        Title = "Config Saved",
        Content = "Configuration '" .. configName .. "' has been saved successfully!",
        Duration = 2
    })
end

function ConfigSystem:LoadConfig(window, configName)
    local config = _G.AstroHubV3_Config
    if not config then
        AstroHubV3:CreateNotification({
            Title = "Config Error",
            Content = "No configuration found to load!",
            Duration = 2
        })
        return
    end
    
    -- Apply theme
    if config.Theme then
        window.Theme = Themes[config.Theme] or Themes.Manga
        -- Update UI colors (simplified)
        window.MainFrame.BackgroundColor3 = window.Theme.Background
    end
    
    -- Apply element values
    for _, savedElement in pairs(config.Elements) do
        for _, tab in pairs(window.Tabs) do
            for _, element in pairs(tab.Elements) do
                if element.Name == savedElement.Name and element.Set then
                    element:Set(savedElement.Value)
                end
            end
        end
    end
    
    AstroHubV3:CreateNotification({
        Title = "Config Loaded",
        Content = "Configuration '" .. configName .. "' has been loaded successfully!",
        Duration = 2
    })
end

-- Add config methods to Window
function Window:SaveConfig(configName)
    ConfigSystem:SaveConfig(self, configName or "default")
end

function Window:LoadConfig(configName)
    ConfigSystem:LoadConfig(self, configName or "default")
end

-- Theme switching
function Window:SetTheme(themeName)
    if Themes[themeName] then
        self.Theme = Themes[themeName]
        
        -- Update main UI colors
        self.MainFrame.BackgroundColor3 = self.Theme.Background
        
        -- Update all tabs and elements (simplified)
        for _, tab in pairs(self.Tabs) do
            if tab.TabButton then
                tab.TabButton.BackgroundColor3 = self.Theme.Secondary
                tab.TabButton.TextColor3 = self.Theme.TextSecondary
            end
        end
        
        AstroHubV3:CreateNotification({
            Title = "Theme Changed",
            Content = "Theme switched to " .. themeName,
            Duration = 2
        })
    end
end

-- Utility function untuk mendapatkan player
function AstroHubV3:GetPlayer()
    return Players.LocalPlayer
end

-- Utility function untuk mendapatkan mouse
function AstroHubV3:GetMouse()
    return Players.LocalPlayer:GetMouse()
end

