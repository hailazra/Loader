-- AuroraUI - Modern Roblox GUI Library
-- by Aurora Studios

local AuroraUI = {}
AuroraUI.__index = AuroraUI

-- Themes
local Themes = {
    Aurora = {
        Primary = Color3.fromRGB(0, 150, 255),
        Secondary = Color3.fromRGB(0, 120, 215),
        Background = Color3.fromRGB(25, 25, 35),
        Header = Color3.fromRGB(30, 30, 45),
        Element = Color3.fromRGB(40, 40, 55),
        Text = Color3.fromRGB(240, 240, 240),
        Accent = Color3.fromRGB(180, 80, 220)
    },
    Midnight = {
        Primary = Color3.fromRGB(100, 70, 200),
        Secondary = Color3.fromRGB(80, 50, 180),
        Background = Color3.fromRGB(15, 15, 25),
        Header = Color3.fromRGB(20, 20, 35),
        Element = Color3.fromRGB(30, 30, 45),
        Text = Color3.fromRGB(230, 230, 240),
        Accent = Color3.fromRGB(220, 100, 100)
    },
    Forest = {
        Primary = Color3.fromRGB(65, 180, 65),
        Secondary = Color3.fromRGB(45, 160, 45),
        Background = Color3.fromRGB(20, 30, 25),
        Header = Color3.fromRGB(25, 40, 30),
        Element = Color3.fromRGB(35, 50, 40),
        Text = Color3.fromRGB(230, 240, 230),
        Accent = Color3.fromRGB(220, 180, 60)
    }
}

-- Utility functions
local function Create(class, props)
    local instance = Instance.new(class)
    for prop, value in pairs(props) do
        if prop == "Parent" then
            value = value
        else
            instance[prop] = value
        end
    end
    return instance
end

local function Round(num, decimalPlaces)
    local mult = 10^(decimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

-- Window creation
function AuroraUI:CreateWindow(options)
    options = options or {}
    local window = setmetatable({}, AuroraUI)
    
    -- Default options
    window.Title = options.Title or "AuroraUI"
    window.Size = options.Size or UDim2.new(0, 500, 0, 500)
    window.Position = options.Position or UDim2.new(0.5, -250, 0.5, -250)
    window.Theme = options.Theme or "Aurora"
    window.Visible = false
    window.Tabs = {}
    window.Elements = {}
    
    -- Create UI
    window.Gui = Create("ScreenGui", {
        Name = "AuroraUI",
        Parent = game:GetService("CoreGui")
    })
    
    window.Main = Create("Frame", {
        Name = "Main",
        Size = window.Size,
        Position = window.Position,
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Themes[window.Theme].Background,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = window.Gui
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = window.Main
    })
    
    Create("UIStroke", {
        Color = Themes[window.Theme].Primary,
        Thickness = 2,
        Transparency = 0.7,
        Parent = window.Main
    })
    
    window.Header = Create("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Themes[window.Theme].Header,
        BorderSizePixel = 0,
        Parent = window.Main
    })
    
    Create("UIStroke", {
        Color = Themes[window.Theme].Primary,
        Thickness = 1,
        Transparency = 0.8,
        Parent = window.Header
    })
    
    window.Title = Create("TextLabel", {
        Name = "Title",
        Text = window.Title,
        TextColor3 = Themes[window.Theme].Text,
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 0),
        Size = UDim2.new(0.5, 0, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = window.Header
    })
    
    window.CloseBtn = Create("TextButton", {
        Name = "CloseBtn",
        Text = "×",
        TextColor3 = Themes[window.Theme].Text,
        TextSize = 24,
        Font = Enum.Font.GothamBold,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -35, 0, 0),
        Size = UDim2.new(0, 30, 0, 40),
        Parent = window.Header,
        ZIndex = 2
    })
    
    window.TabContainer = Create("Frame", {
        Name = "TabContainer",
        Size = UDim2.new(1, -20, 0, 40),
        Position = UDim2.new(0, 10, 0, 45),
        BackgroundTransparency = 1,
        Parent = window.Main
    })
    
    window.TabListLayout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = window.TabContainer
    })
    
    window.Content = Create("ScrollingFrame", {
        Name = "Content",
        Size = UDim2.new(1, 0, 1, -90),
        Position = UDim2.new(0, 0, 0, 85),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 5,
        ScrollBarImageColor3 = Themes[window.Theme].Primary,
        Parent = window.Main
    })
    
    window.ContentLayout = Create("UIListLayout", {
        Padding = UDim.new(0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = window.Content
    })
    
    window.ContentPadding = Create("UIPadding", {
        PaddingLeft = UDim.new(0, 15),
        PaddingRight = UDim.new(0, 15),
        PaddingTop = UDim.new(0, 5),
        PaddingBottom = UDim.new(0, 15),
        Parent = window.Content
    })
    
    -- Events
    window.CloseBtn.MouseButton1Click:Connect(function()
        window:SetVisible(false)
    end)
    
    -- Dragging functionality
    local dragging
    local dragInput
    local dragStart
    local startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        window.Main.Position = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X,
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
    end
    
    window.Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = window.Main.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    window.Header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
    
    return window
end

function AuroraUI:SetVisible(visible)
    self.Visible = visible
    self.Gui.Enabled = visible
end

function AuroraUI:Toggle()
    self:SetVisible(not self.Visible)
end

-- Tab creation
function AuroraUI:CreateTab(name)
    local tab = {
        Name = name,
        Window = self,
        Elements = {}
    }
    
    local tabButton = Create("TextButton", {
        Name = name,
        Text = name,
        TextColor3 = Themes[self.Theme].Text,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        BackgroundColor3 = Themes[self.Theme].Element,
        BackgroundTransparency = 0.5,
        Size = UDim2.new(0, 80, 1, 0),
        Parent = self.TabContainer,
        AutoButtonColor = false
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = tabButton
    })
    
    tab.Content = Create("Frame", {
        Name = name,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Visible = false,
        Parent = self.Content
    })
    
    tab.Layout = Create("UIListLayout", {
        Padding = UDim.new(0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = tab.Content
    })
    
    tab.Padding = Create("UIPadding", {
        PaddingTop = UDim.new(0, 5),
        Parent = tab.Content
    })
    
    tabButton.MouseButton1Click:Connect(function()
        for _, t in ipairs(self.Tabs) do
            t.Content.Visible = false
            t.Button.BackgroundTransparency = 0.5
        end
        tab.Content.Visible = true
        tabButton.BackgroundTransparency = 0.2
    end)
    
    table.insert(self.Tabs, tab)
    
    -- Select first tab by default
    if #self.Tabs == 1 then
        tab.Content.Visible = true
        tabButton.BackgroundTransparency = 0.2
    end
    
    return tab
end

-- Section creation
function AuroraUI:CreateSection(title)
    local section = {}
    
    section.Container = Create("Frame", {
        Name = "Section_"..title,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        LayoutOrder = #self.Elements + 1,
        Parent = self.Content
    })
    
    section.Title = Create("TextLabel", {
        Name = "Title",
        Text = title,
        TextColor3 = Themes[self.Window.Theme].Text,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 25),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = section.Container
    })
    
    section.Divider = Create("Frame", {
        Name = "Divider",
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = Themes[self.Window.Theme].Primary,
        BackgroundTransparency = 0.7,
        BorderSizePixel = 0,
        LayoutOrder = 1,
        Parent = section.Container
    })
    
    section.Content = Create("Frame", {
        Name = "Content",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        LayoutOrder = 2,
        Parent = section.Container
    })
    
    section.Layout = Create("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = section.Content
    })
    
    function section:Resize()
        local height = section.Layout.AbsoluteContentSize.Y
        section.Container.Size = UDim2.new(1, 0, 0, height + 30)
        section.Content.Size = UDim2.new(1, 0, 0, height)
    end
    
    section.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        section:Resize()
    end)
    
    table.insert(self.Elements, section)
    return section
end

-- Button element
function AuroraUI:CreateButton(options)
    local button = {}
    
    button.Container = Create("Frame", {
        Name = "Button_"..options.Title,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 40),
        LayoutOrder = #self.Elements + 1,
        Parent = self.Content
    })
    
    button.Button = Create("TextButton", {
        Name = "Button",
        Text = options.Title,
        TextColor3 = Themes[self.Window.Theme].Text,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        BackgroundColor3 = Themes[self.Window.Theme].Element,
        BackgroundTransparency = 0.3,
        Size = UDim2.new(1, 0, 1, 0),
        AutoButtonColor = false,
        Parent = button.Container
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = button.Button
    })
    
    Create("UIStroke", {
        Color = Themes[self.Window.Theme].Primary,
        Thickness = 1,
        Transparency = 0.7,
        Parent = button.Button
    })
    
    -- Hover effects
    button.Button.MouseEnter:Connect(function()
        button.Button.BackgroundColor3 = Themes[self.Window.Theme].Primary
        button.Button.BackgroundTransparency = 0.7
    end)
    
    button.Button.MouseLeave:Connect(function()
        button.Button.BackgroundColor3 = Themes[self.Window.Theme].Element
        button.Button.BackgroundTransparency = 0.3
    end)
    
    button.Button.MouseButton1Click:Connect(function()
        if options.Callback then
            pcall(options.Callback)
        end
    end)
    
    if options.Icon then
        button.Icon = Create("ImageLabel", {
            Name = "Icon",
            Image = options.Icon,
            Size = UDim2.new(0, 20, 0, 20),
            Position = UDim2.new(0, 10, 0.5, -10),
            BackgroundTransparency = 1,
            Parent = button.Button
        })
        
        button.Button.TextXAlignment = Enum.TextXAlignment.Left
        button.Button.PaddingLeft = UDim.new(0, 40)
    end
    
    function button:SetText(text)
        button.Button.Text = text
    end
    
    table.insert(self.Elements, button)
    return button
end

-- Toggle element
function AuroraUI:CreateToggle(options)
    local toggle = {}
    toggle.Value = options.Default or false
    
    toggle.Container = Create("Frame", {
        Name = "Toggle_"..options.Title,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 30),
        LayoutOrder = #self.Elements + 1,
        Parent = self.Content
    })
    
    toggle.Label = Create("TextLabel", {
        Name = "Label",
        Text = options.Title,
        TextColor3 = Themes[self.Window.Theme].Text,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        BackgroundTransparency = 1,
        Size = UDim2.new(0.7, 0, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = toggle.Container
    })
    
    toggle.Button = Create("TextButton", {
        Name = "Toggle",
        BackgroundColor3 = Themes[self.Window.Theme].Element,
        BackgroundTransparency = 0.3,
        Size = UDim2.new(0, 50, 0, 25),
        Position = UDim2.new(1, -55, 0.5, -12.5),
        AutoButtonColor = false,
        Parent = toggle.Container
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = toggle.Button
    })
    
    toggle.Indicator = Create("Frame", {
        Name = "Indicator",
        BackgroundColor3 = Themes[self.Window.Theme].Text,
        Size = UDim2.new(0, 17, 0, 17),
        Position = UDim2.new(0, 4, 0.5, -8.5),
        Parent = toggle.Button
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = toggle.Indicator
    })
    
    function toggle:Update()
        if toggle.Value then
            toggle.Button.BackgroundColor3 = Themes[self.Window.Theme].Primary
            toggle.Indicator.Position = UDim2.new(1, -21, 0.5, -8.5)
        else
            toggle.Button.BackgroundColor3 = Themes[self.Window.Theme].Element
            toggle.Indicator.Position = UDim2.new(0, 4, 0.5, -8.5)
        end
    end
    
    toggle:Update()
    
    toggle.Button.MouseButton1Click:Connect(function()
        toggle.Value = not toggle.Value
        toggle:Update()
        
        if options.Callback then
            pcall(options.Callback, toggle.Value)
        end
    end)
    
    function toggle:SetValue(value)
        toggle.Value = value
        toggle:Update()
    end
    
    table.insert(self.Elements, toggle)
    return toggle
end

-- Slider element
function AuroraUI:CreateSlider(options)
    local slider = {}
    slider.Value = options.Default or options.Min
    
    slider.Container = Create("Frame", {
        Name = "Slider_"..options.Title,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 60),
        LayoutOrder = #self.Elements + 1,
        Parent = self.Content
    })
    
    slider.Label = Create("TextLabel", {
        Name = "Label",
        Text = options.Title,
        TextColor3 = Themes[self.Window.Theme].Text,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 20),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = slider.Container
    })
    
    slider.ValueLabel = Create("TextLabel", {
        Name = "ValueLabel",
        Text = tostring(slider.Value),
        TextColor3 = Themes[self.Window.Theme].Text,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        BackgroundTransparency = 1,
        Size = UDim2.new(0.2, 0, 0, 20),
        Position = UDim2.new(1, -50, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = slider.Container
    })
    
    slider.Track = Create("Frame", {
        Name = "Track",
        BackgroundColor3 = Themes[self.Window.Theme].Element,
        BackgroundTransparency = 0.3,
        Size = UDim2.new(1, 0, 0, 6),
        Position = UDim2.new(0, 0, 0, 30),
        Parent = slider.Container
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = slider.Track
    })
    
    slider.Fill = Create("Frame", {
        Name = "Fill",
        BackgroundColor3 = Themes[self.Window.Theme].Primary,
        Size = UDim2.new(0, 0, 1, 0),
        Parent = slider.Track
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = slider.Fill
    })
    
    slider.Handle = Create("Frame", {
        Name = "Handle",
        BackgroundColor3 = Themes[self.Window.Theme].Text,
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0, -8, 0.5, -8),
        Parent = slider.Track
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = slider.Handle
    })
    
    Create("UIStroke", {
        Color = Themes[self.Window.Theme].Primary,
        Thickness = 2,
        Parent = slider.Handle
    })
    
    function slider:Update()
        local min = options.Min or 0
        local max = options.Max or 100
        local ratio = (slider.Value - min) / (max - min)
        
        slider.Fill.Size = UDim2.new(ratio, 0, 1, 0)
        slider.Handle.Position = UDim2.new(ratio, -8, 0.5, -8)
        
        if options.Precision then
            slider.ValueLabel.Text = tostring(Round(slider.Value, options.Precision))
        else
            slider.ValueLabel.Text = tostring(math.floor(slider.Value))
        end
    end
    
    slider:Update()
    
    local dragging = false
    
    slider.Track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            
            local min = options.Min or 0
            local max = options.Max or 100
            local position = input.Position.X
            local ratio = math.clamp(position / slider.Track.AbsoluteSize.X, 0, 1)
            slider.Value = min + (max - min) * ratio
            slider:Update()
            
            if options.Callback then
                pcall(options.Callback, slider.Value)
            end
        end
    end)
    
    slider.Track.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local min = options.Min or 0
            local max = options.Max or 100
            local position = input.Position.X - slider.Track.AbsolutePosition.X
            local ratio = math.clamp(position / slider.Track.AbsoluteSize.X, 0, 1)
            slider.Value = min + (max - min) * ratio
            slider:Update()
            
            if options.Callback then
                pcall(options.Callback, slider.Value)
            end
        end
    end)
    
    function slider:SetValue(value)
        slider.Value = math.clamp(value, options.Min, options.Max)
        slider:Update()
    end
    
    table.insert(self.Elements, slider)
    return slider
end

dropdown.Label = Create("TextLabel", {
        Name = "Label",
        Text = options.Title,
        TextColor3 = Themes[self.Window.Theme].Text,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        BackgroundTransparency = 1,
        Size = UDim2.new(0.7, 0, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = dropdown.Container
    })
    
    dropdown.Button = Create("TextButton", {
        Name = "DropdownButton",
        Text = dropdown.Value,
        TextColor3 = Themes[self.Window.Theme].Text,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        BackgroundColor3 = Themes[self.Window.Theme].Element,
        BackgroundTransparency = 0.3,
        Size = UDim2.new(0.3, 0, 1, 0),
        Position = UDim2.new(0.7, 5, 0, 0),
        AutoButtonColor = false,
        Parent = dropdown.Container
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = dropdown.Button
    })
    
    dropdown.Arrow = Create("ImageLabel", {
        Name = "Arrow",
        Image = "rbxassetid://10709791437", -- Down arrow icon
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(1, -20, 0.5, -8),
        BackgroundTransparency = 1,
        Parent = dropdown.Button
    })
    
    dropdown.OptionContainer = Create("Frame", {
        Name = "OptionContainer",
        BackgroundColor3 = Themes[self.Window.Theme].Element,
        BackgroundTransparency = 0.1,
        Size = UDim2.new(0.3, 0, 0, 0),
        Position = UDim2.new(0.7, 5, 0, 30),
        Visible = false,
        Parent = dropdown.Container
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = dropdown.OptionContainer
    })
    
    Create("UIStroke", {
        Color = Themes[self.Window.Theme].Primary,
        Thickness = 1,
        Transparency = 0.7,
        Parent = dropdown.OptionContainer
    })
    
    dropdown.OptionLayout = Create("UIListLayout", {
        Padding = UDim.new(0, 2),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = dropdown.OptionContainer
    })
    
    dropdown.OptionPadding = Create("UIPadding", {
        PaddingTop = UDim.new(0, 5),
        PaddingBottom = UDim.new(0, 5),
        Parent = dropdown.OptionContainer
    })
    
    function dropdown:Toggle()
        dropdown.Open = not dropdown.Open
        dropdown.OptionContainer.Visible = dropdown.Open
        
        if dropdown.Open then
            dropdown.Arrow.Rotation = 180
        else
            dropdown.Arrow.Rotation = 0
        end
    end
    
    function dropdown:Update()
        dropdown.Button.Text = dropdown.Value
    end
    
    dropdown:Update()
    
    -- Create options
    for i, option in ipairs(options.Options) do
        local optionButton = Create("TextButton", {
            Name = option,
            Text = option,
            TextColor3 = Themes[self.Window.Theme].Text,
            TextSize = 14,
            Font = Enum.Font.Gotham,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -10, 0, 25),
            Position = UDim2.new(0, 5, 0, 0),
            LayoutOrder = i,
            AutoButtonColor = false,
            Parent = dropdown.OptionContainer
        })
        
        optionButton.MouseButton1Click:Connect(function()
            dropdown.Value = option
            dropdown:Update()
            dropdown:Toggle()
            
            if options.Callback then
                pcall(options.Callback, dropdown.Value)
            end
        end)
        
        optionButton.MouseEnter:Connect(function()
            optionButton.BackgroundColor3 = Themes[self.Window.Theme].Primary
            optionButton.BackgroundTransparency = 0.7
        end)
        
        optionButton.MouseLeave:Connect(function()
            optionButton.BackgroundTransparency = 1
        end)
    end
    
    dropdown.OptionLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        dropdown.OptionContainer.Size = UDim2.new(0.3, 0, 0, dropdown.OptionLayout.AbsoluteContentSize.Y + 10)
    end)
    
    dropdown.Button.MouseButton1Click:Connect(function()
        dropdown:Toggle()
    end)
    
    function dropdown:SetValue(value)
        dropdown.Value = value
        dropdown:Update()
    end
    
    table.insert(self.Elements, dropdown)
    return dropdown
end

-- Label element
function AuroraUI:CreateLabel(text)
    local label = {}
    
    label.Container = Create("Frame", {
        Name = "Label",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 20),
        LayoutOrder = #self.Elements + 1,
        Parent = self.Content
    })
    
    label.Text = Create("TextLabel", {
        Text = text,
        TextColor3 = Themes[self.Window.Theme].Text,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = label.Container
    })
    
    function label:SetText(newText)
        label.Text.Text = newText
    end
    
    table.insert(self.Elements, label)
    return label
end

return AuroraUI
