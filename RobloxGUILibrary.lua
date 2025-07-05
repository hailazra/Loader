-- Roblox GUI Library
-- Modern, Full-Featured GUI Library for Roblox
-- Created by: Custom Library
-- Version: 1.0.0

local Library = {}
Library.Flags = {}
Library.Windows = {}
Library.Notifications = {}

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- Variables
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Themes
Library.Themes = {
    Dark = {
        Background = Color3.fromRGB(25, 25, 25),
        Secondary = Color3.fromRGB(35, 35, 35),
        Tertiary = Color3.fromRGB(45, 45, 45),
        Accent = Color3.fromRGB(0, 162, 255),
        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(180, 180, 180),
        Border = Color3.fromRGB(60, 60, 60),
        Success = Color3.fromRGB(46, 204, 113),
        Warning = Color3.fromRGB(241, 196, 15),
        Error = Color3.fromRGB(231, 76, 60)
    },
    Light = {
        Background = Color3.fromRGB(245, 245, 245),
        Secondary = Color3.fromRGB(255, 255, 255),
        Tertiary = Color3.fromRGB(250, 250, 250),
        Accent = Color3.fromRGB(0, 122, 255),
        Text = Color3.fromRGB(0, 0, 0),
        TextDark = Color3.fromRGB(100, 100, 100),
        Border = Color3.fromRGB(220, 220, 220),
        Success = Color3.fromRGB(39, 174, 96),
        Warning = Color3.fromRGB(243, 156, 18),
        Error = Color3.fromRGB(192, 57, 43)
    }
}

Library.CurrentTheme = Library.Themes.Dark

-- Utility Functions
local function CreateTween(object, properties, duration, easingStyle, easingDirection)
    duration = duration or 0.3
    easingStyle = easingStyle or Enum.EasingStyle.Quad
    easingDirection = easingDirection or Enum.EasingDirection.Out
    
    local tweenInfo = TweenInfo.new(duration, easingStyle, easingDirection)
    local tween = TweenService:Create(object, tweenInfo, properties)
    return tween
end

local function CreateCorner(parent, radius)
    radius = radius or 8
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = parent
    return corner
end

local function CreateStroke(parent, color, thickness, transparency)
    thickness = thickness or 1
    transparency = transparency or 0.8
    color = color or Library.CurrentTheme.Border
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = thickness
    stroke.Transparency = transparency
    stroke.Parent = parent
    return stroke
end

local function CreatePadding(parent, padding)
    padding = padding or 8
    local uiPadding = Instance.new("UIPadding")
    uiPadding.PaddingTop = UDim.new(0, padding)
    uiPadding.PaddingBottom = UDim.new(0, padding)
    uiPadding.PaddingLeft = UDim.new(0, padding)
    uiPadding.PaddingRight = UDim.new(0, padding)
    uiPadding.Parent = parent
    return uiPadding
end

local function CreateListLayout(parent, direction, padding)
    direction = direction or Enum.FillDirection.Vertical
    padding = padding or 4
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.FillDirection = direction
    listLayout.Padding = UDim.new(0, padding)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = parent
    return listLayout
end

-- Notification System
function Library:Notify(options)
    options = options or {}
    local title = options.Title or "Notification"
    local content = options.Content or "No content provided"
    local duration = options.Duration or 3
    local notifType = options.Type or "Info"
    
    -- Create notification GUI
    local notifGui = Instance.new("ScreenGui")
    notifGui.Name = "NotificationGui"
    notifGui.Parent = CoreGui
    
    local notifFrame = Instance.new("Frame")
    notifFrame.Name = "NotificationFrame"
    notifFrame.Size = UDim2.new(0, 300, 0, 80)
    notifFrame.Position = UDim2.new(1, -320, 1, -100)
    notifFrame.BackgroundColor3 = Library.CurrentTheme.Secondary
    notifFrame.BackgroundTransparency = 0.05
    notifFrame.BorderSizePixel = 0
    notifFrame.Parent = notifGui
    
    CreateCorner(notifFrame, 8)
    CreateStroke(notifFrame, Library.CurrentTheme.Border, 1, 0.8)
    CreatePadding(notifFrame, 12)
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, 0, 0, 20)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Library.CurrentTheme.Text
    titleLabel.TextSize = 14
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = notifFrame
    
    -- Content
    local contentLabel = Instance.new("TextLabel")
    contentLabel.Name = "Content"
    contentLabel.Size = UDim2.new(1, 0, 0, 16)
    contentLabel.Position = UDim2.new(0, 0, 0, 24)
    contentLabel.BackgroundTransparency = 1
    contentLabel.Text = content
    contentLabel.TextColor3 = Library.CurrentTheme.TextDark
    contentLabel.TextSize = 12
    contentLabel.Font = Enum.Font.Gotham
    contentLabel.TextXAlignment = Enum.TextXAlignment.Left
    contentLabel.TextWrapped = true
    contentLabel.Parent = notifFrame
    
    -- Type indicator
    local typeIndicator = Instance.new("Frame")
    typeIndicator.Name = "TypeIndicator"
    typeIndicator.Size = UDim2.new(0, 4, 1, 0)
    typeIndicator.Position = UDim2.new(0, -12, 0, 0)
    typeIndicator.BorderSizePixel = 0
    typeIndicator.Parent = notifFrame
    
    if notifType == "Success" then
        typeIndicator.BackgroundColor3 = Library.CurrentTheme.Success
    elseif notifType == "Warning" then
        typeIndicator.BackgroundColor3 = Library.CurrentTheme.Warning
    elseif notifType == "Error" then
        typeIndicator.BackgroundColor3 = Library.CurrentTheme.Error
    else
        typeIndicator.BackgroundColor3 = Library.CurrentTheme.Accent
    end
    
    CreateCorner(typeIndicator, 2)
    
    -- Animation
    notifFrame.Position = UDim2.new(1, 0, 1, -100)
    local slideIn = CreateTween(notifFrame, {Position = UDim2.new(1, -320, 1, -100)}, 0.5, Enum.EasingStyle.Back)
    slideIn:Play()
    
    -- Auto remove
    wait(duration)
    local slideOut = CreateTween(notifFrame, {Position = UDim2.new(1, 0, 1, -100)}, 0.3)
    slideOut:Play()
    slideOut.Completed:Connect(function()
        notifGui:Destroy()
    end)
end

-- Window Class
local Window = {}
Window.__index = Window

function Window:CreateTab(options)
    options = options or {}
    local name = options.Name or "Tab"
    local icon = options.Icon
    local order = options.Order or #self.Tabs + 1
    
    -- Create tab button
    local tabButton = Instance.new("TextButton")
    tabButton.Name = name .. "Button"
    tabButton.Size = UDim2.new(0, 120, 0, 32)
    tabButton.BackgroundColor3 = Library.CurrentTheme.Secondary
    tabButton.BackgroundTransparency = 0.3
    tabButton.BorderSizePixel = 0
    tabButton.Text = name
    tabButton.TextColor3 = Library.CurrentTheme.TextDark
    tabButton.TextSize = 12
    tabButton.Font = Enum.Font.Gotham
    tabButton.LayoutOrder = order
    tabButton.Parent = self.TabContainer
    
    CreateCorner(tabButton, 6)
    
    -- Create tab content
    local tabContent = Instance.new("ScrollingFrame")
    tabContent.Name = name .. "Content"
    tabContent.Size = UDim2.new(1, 0, 1, 0)
    tabContent.Position = UDim2.new(0, 0, 0, 0)
    tabContent.BackgroundTransparency = 1
    tabContent.BorderSizePixel = 0
    tabContent.ScrollBarThickness = 4
    tabContent.ScrollBarImageColor3 = Library.CurrentTheme.Accent
    tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabContent.Visible = false
    tabContent.Parent = self.ContentContainer
    
    CreatePadding(tabContent, 8)
    local contentLayout = CreateListLayout(tabContent, Enum.FillDirection.Vertical, 6)
    
    -- Auto resize canvas
    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tabContent.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 16)
    end)
    
    -- Tab object
    local tab = {
        Name = name,
        Button = tabButton,
        Content = tabContent,
        Window = self,
        Elements = {}
    }
    
    -- Tab switching
    tabButton.MouseButton1Click:Connect(function()
        self:SwitchTab(tab)
    end)
    
    -- Hover effects
    tabButton.MouseEnter:Connect(function()
        if self.ActiveTab ~= tab then
            CreateTween(tabButton, {BackgroundTransparency = 0.1}):Play()
        end
    end)
    
    tabButton.MouseLeave:Connect(function()
        if self.ActiveTab ~= tab then
            CreateTween(tabButton, {BackgroundTransparency = 0.3}):Play()
        end
    end)
    
    table.insert(self.Tabs, tab)
    
    -- Set as active if first tab
    if #self.Tabs == 1 then
        self:SwitchTab(tab)
    end
    
    setmetatable(tab, {__index = self:CreateTabMethods()})
    return tab
end

function Window:SwitchTab(tab)
    -- Hide all tabs
    for _, t in pairs(self.Tabs) do
        t.Content.Visible = false
        CreateTween(t.Button, {
            BackgroundTransparency = 0.3,
            TextColor3 = Library.CurrentTheme.TextDark
        }):Play()
    end
    
    -- Show selected tab
    tab.Content.Visible = true
    CreateTween(tab.Button, {
        BackgroundTransparency = 0,
        TextColor3 = Library.CurrentTheme.Text
    }):Play()
    
    self.ActiveTab = tab
end

function Window:CreateTabMethods()
    local methods = {}
    
    function methods:CreateToggle(options)
        options = options or {}
        local name = options.Name or "Toggle"
        local description = options.Description
        local default = options.Default or false
        local flag = options.Flag
        local callback = options.Callback or function() end
        
        -- Create toggle container
        local toggleContainer = Instance.new("Frame")
        toggleContainer.Name = name .. "Container"
        toggleContainer.Size = UDim2.new(1, 0, 0, description and 60 or 40)
        toggleContainer.BackgroundColor3 = Library.CurrentTheme.Secondary
        toggleContainer.BackgroundTransparency = 0.1
        toggleContainer.BorderSizePixel = 0
        toggleContainer.Parent = self.Content
        
        CreateCorner(toggleContainer, 6)
        CreateStroke(toggleContainer, Library.CurrentTheme.Border, 1, 0.9)
        CreatePadding(toggleContainer, 12)
        
        -- Toggle button
        local toggleButton = Instance.new("TextButton")
        toggleButton.Name = "ToggleButton"
        toggleButton.Size = UDim2.new(0, 40, 0, 20)
        toggleButton.Position = UDim2.new(1, -40, 0, 0)
        toggleButton.BackgroundColor3 = default and Library.CurrentTheme.Accent or Library.CurrentTheme.Border
        toggleButton.BorderSizePixel = 0
        toggleButton.Text = ""
        toggleButton.Parent = toggleContainer
        
        CreateCorner(toggleButton, 10)
        
        -- Toggle indicator
        local toggleIndicator = Instance.new("Frame")
        toggleIndicator.Name = "Indicator"
        toggleIndicator.Size = UDim2.new(0, 16, 0, 16)
        toggleIndicator.Position = default and UDim2.new(0, 22, 0, 2) or UDim2.new(0, 2, 0, 2)
        toggleIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        toggleIndicator.BorderSizePixel = 0
        toggleIndicator.Parent = toggleButton
        
        CreateCorner(toggleIndicator, 8)
        
        -- Label
        local toggleLabel = Instance.new("TextLabel")
        toggleLabel.Name = "Label"
        toggleLabel.Size = UDim2.new(1, -50, 0, 20)
        toggleLabel.Position = UDim2.new(0, 0, 0, 0)
        toggleLabel.BackgroundTransparency = 1
        toggleLabel.Text = name
        toggleLabel.TextColor3 = Library.CurrentTheme.Text
        toggleLabel.TextSize = 13
        toggleLabel.Font = Enum.Font.GothamMedium
        toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
        toggleLabel.Parent = toggleContainer
        
        -- Description
        if description then
            local descLabel = Instance.new("TextLabel")
            descLabel.Name = "Description"
            descLabel.Size = UDim2.new(1, -50, 0, 16)
            descLabel.Position = UDim2.new(0, 0, 0, 22)
            descLabel.BackgroundTransparency = 1
            descLabel.Text = description
            descLabel.TextColor3 = Library.CurrentTheme.TextDark
            descLabel.TextSize = 11
            descLabel.Font = Enum.Font.Gotham
            descLabel.TextXAlignment = Enum.TextXAlignment.Left
            descLabel.TextWrapped = true
            descLabel.Parent = toggleContainer
        end
        
        -- State
        local state = default
        if flag then
            Library.Flags[flag] = state
        end
        
        -- Toggle function
        local function toggle()
            state = not state
            if flag then
                Library.Flags[flag] = state
            end
            
            -- Animation
            local buttonColor = state and Library.CurrentTheme.Accent or Library.CurrentTheme.Border
            local indicatorPos = state and UDim2.new(0, 22, 0, 2) or UDim2.new(0, 2, 0, 2)
            
            CreateTween(toggleButton, {BackgroundColor3 = buttonColor}):Play()
            CreateTween(toggleIndicator, {Position = indicatorPos}):Play()
            
            callback(state)
        end
        
        -- Events
        toggleButton.MouseButton1Click:Connect(toggle)
        
        -- Hover effects
        toggleContainer.MouseEnter:Connect(function()
            CreateTween(toggleContainer, {BackgroundTransparency = 0.05}):Play()
        end)
        
        toggleContainer.MouseLeave:Connect(function()
            CreateTween(toggleContainer, {BackgroundTransparency = 0.1}):Play()
        end)
        
        local toggleObject = {
            Container = toggleContainer,
            Button = toggleButton,
            State = state,
            Toggle = toggle
        }
        
        table.insert(self.Elements, toggleObject)
        return toggleObject
    end
    
    function methods:CreateDropdown(options)
        options = options or {}
        local name = options.Name or "Dropdown"
        local description = options.Description
        local dropdownOptions = options.Options or {"Option 1", "Option 2"}
        local default = options.Default or dropdownOptions[1]
        local flag = options.Flag
        local callback = options.Callback or function() end
        
        -- Create dropdown container
        local dropdownContainer = Instance.new("Frame")
        dropdownContainer.Name = name .. "Container"
        dropdownContainer.Size = UDim2.new(1, 0, 0, description and 70 or 50)
        dropdownContainer.BackgroundColor3 = Library.CurrentTheme.Secondary
        dropdownContainer.BackgroundTransparency = 0.1
        dropdownContainer.BorderSizePixel = 0
        dropdownContainer.Parent = self.Content
        
        CreateCorner(dropdownContainer, 6)
        CreateStroke(dropdownContainer, Library.CurrentTheme.Border, 1, 0.9)
        CreatePadding(dropdownContainer, 12)
        
        -- Label
        local dropdownLabel = Instance.new("TextLabel")
        dropdownLabel.Name = "Label"
        dropdownLabel.Size = UDim2.new(1, 0, 0, 16)
        dropdownLabel.Position = UDim2.new(0, 0, 0, 0)
        dropdownLabel.BackgroundTransparency = 1
        dropdownLabel.Text = name
        dropdownLabel.TextColor3 = Library.CurrentTheme.Text
        dropdownLabel.TextSize = 13
        dropdownLabel.Font = Enum.Font.GothamMedium
        dropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
        dropdownLabel.Parent = dropdownContainer
        
        -- Description
        local yOffset = 18
        if description then
            local descLabel = Instance.new("TextLabel")
            descLabel.Name = "Description"
            descLabel.Size = UDim2.new(1, 0, 0, 14)
            descLabel.Position = UDim2.new(0, 0, 0, 16)
            descLabel.BackgroundTransparency = 1
            descLabel.Text = description
            descLabel.TextColor3 = Library.CurrentTheme.TextDark
            descLabel.TextSize = 11
            descLabel.Font = Enum.Font.Gotham
            descLabel.TextXAlignment = Enum.TextXAlignment.Left
            descLabel.Parent = dropdownContainer
            yOffset = 32
        end
        
        -- Dropdown button
        local dropdownButton = Instance.new("TextButton")
        dropdownButton.Name = "DropdownButton"
        dropdownButton.Size = UDim2.new(1, 0, 0, 24)
        dropdownButton.Position = UDim2.new(0, 0, 0, yOffset)
        dropdownButton.BackgroundColor3 = Library.CurrentTheme.Tertiary
        dropdownButton.BorderSizePixel = 0
        dropdownButton.Text = default
        dropdownButton.TextColor3 = Library.CurrentTheme.Text
        dropdownButton.TextSize = 12
        dropdownButton.Font = Enum.Font.Gotham
        dropdownButton.TextXAlignment = Enum.TextXAlignment.Left
        dropdownButton.Parent = dropdownContainer
        
        CreateCorner(dropdownButton, 4)
        CreateStroke(dropdownButton, Library.CurrentTheme.Border, 1, 0.9)
        CreatePadding(dropdownButton, 8)
        
        -- Dropdown arrow
        local dropdownArrow = Instance.new("TextLabel")
        dropdownArrow.Name = "Arrow"
        dropdownArrow.Size = UDim2.new(0, 16, 0, 16)
        dropdownArrow.Position = UDim2.new(1, -20, 0, 4)
        dropdownArrow.BackgroundTransparency = 1
        dropdownArrow.Text = "▼"
        dropdownArrow.TextColor3 = Library.CurrentTheme.TextDark
        dropdownArrow.TextSize = 10
        dropdownArrow.Font = Enum.Font.Gotham
        dropdownArrow.Parent = dropdownButton
        
        -- State
        local currentValue = default
        local isOpen = false
        if flag then
            Library.Flags[flag] = currentValue
        end
        
        -- Dropdown list (will be created when opened)
        local dropdownList = nil
        
        -- Toggle dropdown
        local function toggleDropdown()
            if isOpen then
                -- Close dropdown
                isOpen = false
                CreateTween(dropdownArrow, {Rotation = 0}):Play()
                if dropdownList then
                    CreateTween(dropdownList, {
                        Size = UDim2.new(1, 0, 0, 0),
                        BackgroundTransparency = 1
                    }):Play()
                    wait(0.2)
                    dropdownList:Destroy()
                    dropdownList = nil
                end
            else
                -- Open dropdown
                isOpen = true
                CreateTween(dropdownArrow, {Rotation = 180}):Play()
                
                -- Create dropdown list
                dropdownList = Instance.new("Frame")
                dropdownList.Name = "DropdownList"
                dropdownList.Size = UDim2.new(1, 0, 0, 0)
                dropdownList.Position = UDim2.new(0, 0, 0, yOffset + 26)
                dropdownList.BackgroundColor3 = Library.CurrentTheme.Tertiary
                dropdownList.BackgroundTransparency = 1
                dropdownList.BorderSizePixel = 0
                dropdownList.ClipsDescendants = true
                dropdownList.Parent = dropdownContainer
                
                CreateCorner(dropdownList, 4)
                CreateStroke(dropdownList, Library.CurrentTheme.Border, 1, 0.9)
                
                local listLayout = CreateListLayout(dropdownList, Enum.FillDirection.Vertical, 0)
                
                -- Create option buttons
                for i, option in ipairs(dropdownOptions) do
                    local optionButton = Instance.new("TextButton")
                    optionButton.Name = "Option" .. i
                    optionButton.Size = UDim2.new(1, 0, 0, 24)
                    optionButton.BackgroundColor3 = Library.CurrentTheme.Tertiary
                    optionButton.BackgroundTransparency = option == currentValue and 0.3 or 1
                    optionButton.BorderSizePixel = 0
                    optionButton.Text = option
                    optionButton.TextColor3 = Library.CurrentTheme.Text
                    optionButton.TextSize = 11
                    optionButton.Font = Enum.Font.Gotham
                    optionButton.TextXAlignment = Enum.TextXAlignment.Left
                    optionButton.Parent = dropdownList
                    
                    CreatePadding(optionButton, 8)
                    
                    -- Option selection
                    optionButton.MouseButton1Click:Connect(function()
                        currentValue = option
                        dropdownButton.Text = option
                        if flag then
                            Library.Flags[flag] = currentValue
                        end
                        callback(currentValue)
                        toggleDropdown()
                    end)
                    
                    -- Hover effects
                    optionButton.MouseEnter:Connect(function()
                        if option ~= currentValue then
                            CreateTween(optionButton, {BackgroundTransparency = 0.7}):Play()
                        end
                    end)
                    
                    optionButton.MouseLeave:Connect(function()
                        if option ~= currentValue then
                            CreateTween(optionButton, {BackgroundTransparency = 1}):Play()
                        end
                    end)
                end
                
                -- Animate dropdown open
                local targetHeight = #dropdownOptions * 24
                CreateTween(dropdownList, {
                    Size = UDim2.new(1, 0, 0, targetHeight),
                    BackgroundTransparency = 0
                }):Play()
                
                -- Resize container
                local newContainerHeight = (description and 70 or 50) + targetHeight + 4
                CreateTween(dropdownContainer, {Size = UDim2.new(1, 0, 0, newContainerHeight)}):Play()
            end
        end
        
        -- Events
        dropdownButton.MouseButton1Click:Connect(toggleDropdown)
        
        -- Hover effects
        dropdownContainer.MouseEnter:Connect(function()
            CreateTween(dropdownContainer, {BackgroundTransparency = 0.05}):Play()
        end)
        
        dropdownContainer.MouseLeave:Connect(function()
            CreateTween(dropdownContainer, {BackgroundTransparency = 0.1}):Play()
        end)
        
        local dropdownObject = {
            Container = dropdownContainer,
            Button = dropdownButton,
            Value = currentValue,
            Options = dropdownOptions,
            SetValue = function(self, value)
                if table.find(dropdownOptions, value) then
                    currentValue = value
                    dropdownButton.Text = value
                    if flag then
                        Library.Flags[flag] = currentValue
                    end
                    callback(currentValue)
                end
            end
        }
        
        table.insert(self.Elements, dropdownObject)
        return dropdownObject
    end
    
    function methods:CreateSlider(options)
        options = options or {}
        local name = options.Name or "Slider"
        local description = options.Description
        local min = options.Min or 0
        local max = options.Max or 100
        local default = options.Default or min
        local unit = options.Unit or ""
        local flag = options.Flag
        local callback = options.Callback or function() end
        
        -- Create slider container
        local sliderContainer = Instance.new("Frame")
        sliderContainer.Name = name .. "Container"
        sliderContainer.Size = UDim2.new(1, 0, 0, description and 70 or 50)
        sliderContainer.BackgroundColor3 = Library.CurrentTheme.Secondary
        sliderContainer.BackgroundTransparency = 0.1
        sliderContainer.BorderSizePixel = 0
        sliderContainer.Parent = self.Content
        
        CreateCorner(sliderContainer, 6)
        CreateStroke(sliderContainer, Library.CurrentTheme.Border, 1, 0.9)
        CreatePadding(sliderContainer, 12)
        
        -- Label
        local sliderLabel = Instance.new("TextLabel")
        sliderLabel.Name = "Label"
        sliderLabel.Size = UDim2.new(0.7, 0, 0, 16)
        sliderLabel.Position = UDim2.new(0, 0, 0, 0)
        sliderLabel.BackgroundTransparency = 1
        sliderLabel.Text = name
        sliderLabel.TextColor3 = Library.CurrentTheme.Text
        sliderLabel.TextSize = 13
        sliderLabel.Font = Enum.Font.GothamMedium
        sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
        sliderLabel.Parent = sliderContainer
        
        -- Value label
        local valueLabel = Instance.new("TextLabel")
        valueLabel.Name = "ValueLabel"
        valueLabel.Size = UDim2.new(0.3, 0, 0, 16)
        valueLabel.Position = UDim2.new(0.7, 0, 0, 0)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Text = tostring(default) .. (unit ~= "" and " " .. unit or "")
        valueLabel.TextColor3 = Library.CurrentTheme.Accent
        valueLabel.TextSize = 12
        valueLabel.Font = Enum.Font.GothamMedium
        valueLabel.TextXAlignment = Enum.TextXAlignment.Right
        valueLabel.Parent = sliderContainer
        
        -- Description
        local yOffset = 18
        if description then
            local descLabel = Instance.new("TextLabel")
            descLabel.Name = "Description"
            descLabel.Size = UDim2.new(1, 0, 0, 14)
            descLabel.Position = UDim2.new(0, 0, 0, 16)
            descLabel.BackgroundTransparency = 1
            descLabel.Text = description
            descLabel.TextColor3 = Library.CurrentTheme.TextDark
            descLabel.TextSize = 11
            descLabel.Font = Enum.Font.Gotham
            descLabel.TextXAlignment = Enum.TextXAlignment.Left
            descLabel.Parent = sliderContainer
            yOffset = 32
        end
        
        -- Slider track
        local sliderTrack = Instance.new("Frame")
        sliderTrack.Name = "SliderTrack"
        sliderTrack.Size = UDim2.new(1, 0, 0, 4)
        sliderTrack.Position = UDim2.new(0, 0, 0, yOffset + 8)
        sliderTrack.BackgroundColor3 = Library.CurrentTheme.Border
        sliderTrack.BorderSizePixel = 0
        sliderTrack.Parent = sliderContainer
        
        CreateCorner(sliderTrack, 2)
        
        -- Slider fill
        local sliderFill = Instance.new("Frame")
        sliderFill.Name = "SliderFill"
        sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        sliderFill.Position = UDim2.new(0, 0, 0, 0)
        sliderFill.BackgroundColor3 = Library.CurrentTheme.Accent
        sliderFill.BorderSizePixel = 0
        sliderFill.Parent = sliderTrack
        
        CreateCorner(sliderFill, 2)
        
        -- Slider handle
        local sliderHandle = Instance.new("Frame")
        sliderHandle.Name = "SliderHandle"
        sliderHandle.Size = UDim2.new(0, 12, 0, 12)
        sliderHandle.Position = UDim2.new((default - min) / (max - min), -6, 0, -4)
        sliderHandle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        sliderHandle.BorderSizePixel = 0
        sliderHandle.Parent = sliderTrack
        
        CreateCorner(sliderHandle, 6)
        CreateStroke(sliderHandle, Library.CurrentTheme.Accent, 2, 0)
        
        -- State
        local currentValue = default
        local isDragging = false
        if flag then
            Library.Flags[flag] = currentValue
        end
        
        -- Update slider
        local function updateSlider(value)
            value = math.clamp(value, min, max)
            currentValue = value
            
            local percentage = (value - min) / (max - min)
            sliderFill.Size = UDim2.new(percentage, 0, 1, 0)
            sliderHandle.Position = UDim2.new(percentage, -6, 0, -4)
            valueLabel.Text = tostring(math.floor(value)) .. (unit ~= "" and " " .. unit or "")
            
            if flag then
                Library.Flags[flag] = currentValue
            end
            callback(currentValue)
        end
        
        -- Mouse events
        local function onInputBegan(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                isDragging = true
                
                local function onMouseMove()
                    if isDragging then
                        local mouseX = Mouse.X
                        local trackX = sliderTrack.AbsolutePosition.X
                        local trackWidth = sliderTrack.AbsoluteSize.X
                        local percentage = math.clamp((mouseX - trackX) / trackWidth, 0, 1)
                        local value = min + (max - min) * percentage
                        updateSlider(value)
                    end
                end
                
                local mouseMoveConnection
                mouseMoveConnection = Mouse.Move:Connect(onMouseMove)
                
                local function onInputEnded(endInput)
                    if endInput.UserInputType == Enum.UserInputType.MouseButton1 then
                        isDragging = false
                        mouseMoveConnection:Disconnect()
                    end
                end
                
                UserInputService.InputEnded:Connect(onInputEnded)
            end
        end
        
        sliderTrack.InputBegan:Connect(onInputBegan)
        sliderHandle.InputBegan:Connect(onInputBegan)
        
        -- Hover effects
        sliderContainer.MouseEnter:Connect(function()
            CreateTween(sliderContainer, {BackgroundTransparency = 0.05}):Play()
            CreateTween(sliderHandle, {Size = UDim2.new(0, 14, 0, 14)}):Play()
        end)
        
        sliderContainer.MouseLeave:Connect(function()
            if not isDragging then
                CreateTween(sliderContainer, {BackgroundTransparency = 0.1}):Play()
                CreateTween(sliderHandle, {Size = UDim2.new(0, 12, 0, 12)}):Play()
            end
        end)
        
        local sliderObject = {
            Container = sliderContainer,
            Track = sliderTrack,
            Fill = sliderFill,
            Handle = sliderHandle,
            Value = currentValue,
            Min = min,
            Max = max,
            SetValue = updateSlider
        }
        
        table.insert(self.Elements, sliderObject)
        return sliderObject
    end
    
    function methods:CreateInput(options)
        options = options or {}
        local name = options.Name or "Input"
        local description = options.Description
        local placeholder = options.Placeholder or "Enter text..."
        local default = options.Default or ""
        local flag = options.Flag
        local callback = options.Callback or function() end
        
        -- Create input container
        local inputContainer = Instance.new("Frame")
        inputContainer.Name = name .. "Container"
        inputContainer.Size = UDim2.new(1, 0, 0, description and 70 or 50)
        inputContainer.BackgroundColor3 = Library.CurrentTheme.Secondary
        inputContainer.BackgroundTransparency = 0.1
        inputContainer.BorderSizePixel = 0
        inputContainer.Parent = self.Content
        
        CreateCorner(inputContainer, 6)
        CreateStroke(inputContainer, Library.CurrentTheme.Border, 1, 0.9)
        CreatePadding(inputContainer, 12)
        
        -- Label
        local inputLabel = Instance.new("TextLabel")
        inputLabel.Name = "Label"
        inputLabel.Size = UDim2.new(1, 0, 0, 16)
        inputLabel.Position = UDim2.new(0, 0, 0, 0)
        inputLabel.BackgroundTransparency = 1
        inputLabel.Text = name
        inputLabel.TextColor3 = Library.CurrentTheme.Text
        inputLabel.TextSize = 13
        inputLabel.Font = Enum.Font.GothamMedium
        inputLabel.TextXAlignment = Enum.TextXAlignment.Left
        inputLabel.Parent = inputContainer
        
        -- Description
        local yOffset = 18
        if description then
            local descLabel = Instance.new("TextLabel")
            descLabel.Name = "Description"
            descLabel.Size = UDim2.new(1, 0, 0, 14)
            descLabel.Position = UDim2.new(0, 0, 0, 16)
            descLabel.BackgroundTransparency = 1
            descLabel.Text = description
            descLabel.TextColor3 = Library.CurrentTheme.TextDark
            descLabel.TextSize = 11
            descLabel.Font = Enum.Font.Gotham
            descLabel.TextXAlignment = Enum.TextXAlignment.Left
            descLabel.Parent = inputContainer
            yOffset = 32
        end
        
        -- Input box
        local inputBox = Instance.new("TextBox")
        inputBox.Name = "InputBox"
        inputBox.Size = UDim2.new(1, 0, 0, 24)
        inputBox.Position = UDim2.new(0, 0, 0, yOffset)
        inputBox.BackgroundColor3 = Library.CurrentTheme.Tertiary
        inputBox.BorderSizePixel = 0
        inputBox.Text = default
        inputBox.PlaceholderText = placeholder
        inputBox.TextColor3 = Library.CurrentTheme.Text
        inputBox.PlaceholderColor3 = Library.CurrentTheme.TextDark
        inputBox.TextSize = 12
        inputBox.Font = Enum.Font.Gotham
        inputBox.TextXAlignment = Enum.TextXAlignment.Left
        inputBox.ClearTextOnFocus = false
        inputBox.Parent = inputContainer
        
        CreateCorner(inputBox, 4)
        CreateStroke(inputBox, Library.CurrentTheme.Border, 1, 0.9)
        CreatePadding(inputBox, 8)
        
        -- State
        local currentValue = default
        if flag then
            Library.Flags[flag] = currentValue
        end
        
        -- Events
        inputBox.FocusLost:Connect(function(enterPressed)
            currentValue = inputBox.Text
            if flag then
                Library.Flags[flag] = currentValue
            end
            callback(currentValue)
        end)
        
        inputBox.Focused:Connect(function()
            CreateTween(inputBox, {
                BackgroundColor3 = Library.CurrentTheme.Secondary
            }):Play()
            CreateStroke(inputBox, Library.CurrentTheme.Accent, 1, 0.5)
        end)
        
        inputBox.FocusLost:Connect(function()
            CreateTween(inputBox, {
                BackgroundColor3 = Library.CurrentTheme.Tertiary
            }):Play()
            CreateStroke(inputBox, Library.CurrentTheme.Border, 1, 0.9)
        end)
        
        -- Hover effects
        inputContainer.MouseEnter:Connect(function()
            CreateTween(inputContainer, {BackgroundTransparency = 0.05}):Play()
        end)
        
        inputContainer.MouseLeave:Connect(function()
            CreateTween(inputContainer, {BackgroundTransparency = 0.1}):Play()
        end)
        
        local inputObject = {
            Container = inputContainer,
            InputBox = inputBox,
            Value = currentValue,
            SetValue = function(self, value)
                inputBox.Text = value
                currentValue = value
                if flag then
                    Library.Flags[flag] = currentValue
                end
                callback(currentValue)
            end
        }
        
        table.insert(self.Elements, inputObject)
        return inputObject
    end
    
    function methods:CreateButton(options)
        options = options or {}
        local name = options.Name or "Button"
        local description = options.Description
        local callback = options.Callback or function() end
        
        -- Create button container
        local buttonContainer = Instance.new("Frame")
        buttonContainer.Name = name .. "Container"
        buttonContainer.Size = UDim2.new(1, 0, 0, description and 60 or 40)
        buttonContainer.BackgroundTransparency = 1
        buttonContainer.BorderSizePixel = 0
        buttonContainer.Parent = self.Content
        
        -- Button
        local button = Instance.new("TextButton")
        button.Name = "Button"
        button.Size = UDim2.new(1, 0, 0, 32)
        button.Position = UDim2.new(0, 0, 0, description and 24 or 4)
        button.BackgroundColor3 = Library.CurrentTheme.Accent
        button.BorderSizePixel = 0
        button.Text = name
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextSize = 13
        button.Font = Enum.Font.GothamMedium
        button.Parent = buttonContainer
        
        CreateCorner(button, 6)
        
        -- Description
        if description then
            local descLabel = Instance.new("TextLabel")
            descLabel.Name = "Description"
            descLabel.Size = UDim2.new(1, 0, 0, 16)
            descLabel.Position = UDim2.new(0, 0, 0, 4)
            descLabel.BackgroundTransparency = 1
            descLabel.Text = description
            descLabel.TextColor3 = Library.CurrentTheme.TextDark
            descLabel.TextSize = 11
            descLabel.Font = Enum.Font.Gotham
            descLabel.TextXAlignment = Enum.TextXAlignment.Left
            descLabel.Parent = buttonContainer
        end
        
        -- Events
        button.MouseButton1Click:Connect(function()
            -- Click animation
            CreateTween(button, {Size = UDim2.new(1, -4, 0, 30)}, 0.1):Play()
            wait(0.1)
            CreateTween(button, {Size = UDim2.new(1, 0, 0, 32)}, 0.1):Play()
            
            callback()
        end)
        
        -- Hover effects
        button.MouseEnter:Connect(function()
            CreateTween(button, {
                BackgroundColor3 = Color3.fromRGB(
                    math.min(255, Library.CurrentTheme.Accent.R * 255 + 20),
                    math.min(255, Library.CurrentTheme.Accent.G * 255 + 20),
                    math.min(255, Library.CurrentTheme.Accent.B * 255 + 20)
                )
            }):Play()
        end)
        
        button.MouseLeave:Connect(function()
            CreateTween(button, {BackgroundColor3 = Library.CurrentTheme.Accent}):Play()
        end)
        
        local buttonObject = {
            Container = buttonContainer,
            Button = button,
            Click = function()
                callback()
            end
        }
        
        table.insert(self.Elements, buttonObject)
        return buttonObject
    end
    
    function methods:CreateLinkButton(options)
        options = options or {}
        local name = options.Name or "Link"
        local description = options.Description
        local url = options.URL or "https://example.com"
        local icon = options.Icon
        
        -- Create link container
        local linkContainer = Instance.new("Frame")
        linkContainer.Name = name .. "Container"
        linkContainer.Size = UDim2.new(1, 0, 0, description and 60 or 40)
        linkContainer.BackgroundTransparency = 1
        linkContainer.BorderSizePixel = 0
        linkContainer.Parent = self.Content
        
        -- Link button
        local linkButton = Instance.new("TextButton")
        linkButton.Name = "LinkButton"
        linkButton.Size = UDim2.new(1, 0, 0, 32)
        linkButton.Position = UDim2.new(0, 0, 0, description and 24 or 4)
        linkButton.BackgroundColor3 = Library.CurrentTheme.Secondary
        linkButton.BackgroundTransparency = 0.1
        linkButton.BorderSizePixel = 0
        linkButton.Text = name .. " 🔗"
        linkButton.TextColor3 = Library.CurrentTheme.Accent
        linkButton.TextSize = 13
        linkButton.Font = Enum.Font.GothamMedium
        linkButton.Parent = linkContainer
        
        CreateCorner(linkButton, 6)
        CreateStroke(linkButton, Library.CurrentTheme.Accent, 1, 0.7)
        
        -- Description
        if description then
            local descLabel = Instance.new("TextLabel")
            descLabel.Name = "Description"
            descLabel.Size = UDim2.new(1, 0, 0, 16)
            descLabel.Position = UDim2.new(0, 0, 0, 4)
            descLabel.BackgroundTransparency = 1
            descLabel.Text = description
            descLabel.TextColor3 = Library.CurrentTheme.TextDark
            descLabel.TextSize = 11
            descLabel.Font = Enum.Font.Gotham
            descLabel.TextXAlignment = Enum.TextXAlignment.Left
            descLabel.Parent = linkContainer
        end
        
        -- Events
        linkButton.MouseButton1Click:Connect(function()
            -- Copy URL to clipboard (Roblox limitation - can't open external links)
            setclipboard(url)
            Library:Notify({
                Title = "Link Copied",
                Content = "URL copied to clipboard: " .. url,
                Duration = 3,
                Type = "Info"
            })
        end)
        
        -- Hover effects
        linkButton.MouseEnter:Connect(function()
            CreateTween(linkButton, {BackgroundTransparency = 0.05}):Play()
        end)
        
        linkButton.MouseLeave:Connect(function()
            CreateTween(linkButton, {BackgroundTransparency = 0.1}):Play()
        end)
        
        local linkObject = {
            Container = linkContainer,
            Button = linkButton,
            URL = url
        }
        
        table.insert(self.Elements, linkObject)
        return linkObject
    end
    
    function methods:CreateSection(options)
        options = options or {}
        local name = options.Name or "Section"
        local description = options.Description
        
        -- Create section container
        local sectionContainer = Instance.new("Frame")
        sectionContainer.Name = name .. "Section"
        sectionContainer.Size = UDim2.new(1, 0, 0, description and 50 or 35)
        sectionContainer.BackgroundTransparency = 1
        sectionContainer.BorderSizePixel = 0
        sectionContainer.Parent = self.Content
        
        -- Section title
        local sectionTitle = Instance.new("TextLabel")
        sectionTitle.Name = "Title"
        sectionTitle.Size = UDim2.new(1, 0, 0, 20)
        sectionTitle.Position = UDim2.new(0, 0, 0, 8)
        sectionTitle.BackgroundTransparency = 1
        sectionTitle.Text = name
        sectionTitle.TextColor3 = Library.CurrentTheme.Text
        sectionTitle.TextSize = 14
        sectionTitle.Font = Enum.Font.GothamBold
        sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
        sectionTitle.Parent = sectionContainer
        
        -- Section line
        local sectionLine = Instance.new("Frame")
        sectionLine.Name = "Line"
        sectionLine.Size = UDim2.new(1, 0, 0, 1)
        sectionLine.Position = UDim2.new(0, 0, 0, 30)
        sectionLine.BackgroundColor3 = Library.CurrentTheme.Border
        sectionLine.BorderSizePixel = 0
        sectionLine.Parent = sectionContainer
        
        -- Description
        if description then
            local descLabel = Instance.new("TextLabel")
            descLabel.Name = "Description"
            descLabel.Size = UDim2.new(1, 0, 0, 14)
            descLabel.Position = UDim2.new(0, 0, 0, 32)
            descLabel.BackgroundTransparency = 1
            descLabel.Text = description
            descLabel.TextColor3 = Library.CurrentTheme.TextDark
            descLabel.TextSize = 11
            descLabel.Font = Enum.Font.Gotham
            descLabel.TextXAlignment = Enum.TextXAlignment.Left
            descLabel.Parent = sectionContainer
        end
        
        -- Section methods (same as tab methods)
        local section = {
            Name = name,
            Container = sectionContainer,
            Content = self.Content, -- Use same content as parent tab
            Elements = {}
        }
        
        setmetatable(section, {__index = methods})
        table.insert(self.Elements, section)
        return section
    end
    
    return methods
end

-- Main Library Functions
function Library:CreateWindow(options)
    options = options or {}
    local title = options.Title or "GUI Library"
    local logo = options.Logo
    local theme = options.Theme or "Dark"
    local size = options.Size or UDim2.new(0, 500, 0, 400)
    local minSize = options.MinSize or UDim2.new(0, 400, 0, 300)
    local draggable = options.Draggable ~= false
    local minimizable = options.Minimizable ~= false
    
    -- Set theme
    if type(theme) == "string" and Library.Themes[theme] then
        Library.CurrentTheme = Library.Themes[theme]
    elseif type(theme) == "table" then
        Library.CurrentTheme = theme
    end
    
    -- Create ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = title .. "GUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = CoreGui
    
    -- Main window frame
    local windowFrame = Instance.new("Frame")
    windowFrame.Name = "WindowFrame"
    windowFrame.Size = size
    windowFrame.Position = UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2)
    windowFrame.BackgroundColor3 = Library.CurrentTheme.Background
    windowFrame.BackgroundTransparency = 0.05
    windowFrame.BorderSizePixel = 0
    windowFrame.ClipsDescendants = true
    windowFrame.Parent = screenGui
    
    CreateCorner(windowFrame, 10)
    CreateStroke(windowFrame, Library.CurrentTheme.Border, 2, 0.7)
    
    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = Library.CurrentTheme.Secondary
    titleBar.BackgroundTransparency = 0.1
    titleBar.BorderSizePixel = 0
    titleBar.Parent = windowFrame
    
    CreateCorner(titleBar, 10)
    CreatePadding(titleBar, 12)
    
    -- Title bar bottom line
    local titleLine = Instance.new("Frame")
    titleLine.Name = "TitleLine"
    titleLine.Size = UDim2.new(1, 0, 0, 1)
    titleLine.Position = UDim2.new(0, 0, 1, -1)
    titleLine.BackgroundColor3 = Library.CurrentTheme.Border
    titleLine.BorderSizePixel = 0
    titleLine.Parent = titleBar
    
    -- Logo (if provided)
    local logoImage = nil
    if logo then
        logoImage = Instance.new("ImageLabel")
        logoImage.Name = "Logo"
        logoImage.Size = UDim2.new(0, 24, 0, 24)
        logoImage.Position = UDim2.new(0, 0, 0, 0)
        logoImage.BackgroundTransparency = 1
        logoImage.Image = logo
        logoImage.Parent = titleBar
    end
    
    -- Title label
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, logoImage and -100 or -70, 0, 24)
    titleLabel.Position = UDim2.new(0, logoImage and 32 or 0, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Library.CurrentTheme.Text
    titleLabel.TextSize = 14
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar
    
    -- Executor info
    local executorLabel = Instance.new("TextLabel")
    executorLabel.Name = "Executor"
    executorLabel.Size = UDim2.new(0, 150, 0, 12)
    executorLabel.Position = UDim2.new(1, -150, 1, -16)
    executorLabel.BackgroundTransparency = 1
    executorLabel.Text = "User: " .. LocalPlayer.Name
    executorLabel.TextColor3 = Library.CurrentTheme.TextDark
    executorLabel.TextSize = 10
    executorLabel.Font = Enum.Font.Gotham
    executorLabel.TextXAlignment = Enum.TextXAlignment.Right
    executorLabel.Parent = titleBar
    
    -- Control buttons
    local controlsFrame = Instance.new("Frame")
    controlsFrame.Name = "Controls"
    controlsFrame.Size = UDim2.new(0, 60, 0, 24)
    controlsFrame.Position = UDim2.new(1, -60, 0, 0)
    controlsFrame.BackgroundTransparency = 1
    controlsFrame.Parent = titleBar
    
    local controlsLayout = CreateListLayout(controlsFrame, Enum.FillDirection.Horizontal, 4)
    
    -- Minimize button
    local minimizeButton = nil
    if minimizable then
        minimizeButton = Instance.new("TextButton")
        minimizeButton.Name = "MinimizeButton"
        minimizeButton.Size = UDim2.new(0, 24, 0, 24)
        minimizeButton.BackgroundColor3 = Library.CurrentTheme.Tertiary
        minimizeButton.BackgroundTransparency = 0.3
        minimizeButton.BorderSizePixel = 0
        minimizeButton.Text = "−"
        minimizeButton.TextColor3 = Library.CurrentTheme.Text
        minimizeButton.TextSize = 16
        minimizeButton.Font = Enum.Font.GothamBold
        minimizeButton.Parent = controlsFrame
        
        CreateCorner(minimizeButton, 4)
    end
    
    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 24, 0, 24)
    closeButton.BackgroundColor3 = Library.CurrentTheme.Error
    closeButton.BackgroundTransparency = 0.3
    closeButton.BorderSizePixel = 0
    closeButton.Text = "×"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 16
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = controlsFrame
    
    CreateCorner(closeButton, 4)
    
    -- Tab container
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(0, 140, 1, -40)
    tabContainer.Position = UDim2.new(0, 0, 0, 40)
    tabContainer.BackgroundColor3 = Library.CurrentTheme.Secondary
    tabContainer.BackgroundTransparency = 0.2
    tabContainer.BorderSizePixel = 0
    tabContainer.Parent = windowFrame
    
    CreatePadding(tabContainer, 8)
    CreateListLayout(tabContainer, Enum.FillDirection.Vertical, 4)
    
    -- Tab separator
    local tabSeparator = Instance.new("Frame")
    tabSeparator.Name = "TabSeparator"
    tabSeparator.Size = UDim2.new(0, 1, 1, -40)
    tabSeparator.Position = UDim2.new(0, 140, 0, 40)
    tabSeparator.BackgroundColor3 = Library.CurrentTheme.Border
    tabSeparator.BorderSizePixel = 0
    tabSeparator.Parent = windowFrame
    
    -- Content container
    local contentContainer = Instance.new("Frame")
    contentContainer.Name = "ContentContainer"
    contentContainer.Size = UDim2.new(1, -141, 1, -40)
    contentContainer.Position = UDim2.new(0, 141, 0, 40)
    contentContainer.BackgroundTransparency = 1
    contentContainer.BorderSizePixel = 0
    contentContainer.Parent = windowFrame
    
    -- Window object
    local window = {
        ScreenGui = screenGui,
        Frame = windowFrame,
        TitleBar = titleBar,
        TabContainer = tabContainer,
        ContentContainer = contentContainer,
        Tabs = {},
        ActiveTab = nil,
        IsMinimized = false,
        OriginalSize = size
    }
    
    -- Draggable functionality
    if draggable then
        local dragging = false
        local dragStart = nil
        local startPos = nil
        
        titleBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = windowFrame.Position
            end
        end)
        
        titleBar.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - dragStart
                windowFrame.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
    end
    
    -- Minimize functionality
    if minimizeButton then
        minimizeButton.MouseButton1Click:Connect(function()
            if window.IsMinimized then
                -- Restore
                CreateTween(windowFrame, {Size = window.OriginalSize}):Play()
                tabContainer.Visible = true
                tabSeparator.Visible = true
                contentContainer.Visible = true
                minimizeButton.Text = "−"
                window.IsMinimized = false
            else
                -- Minimize
                CreateTween(windowFrame, {Size = UDim2.new(0, window.OriginalSize.X.Offset, 0, 40)}):Play()
                tabContainer.Visible = false
                tabSeparator.Visible = false
                contentContainer.Visible = false
                minimizeButton.Text = "□"
                window.IsMinimized = true
            end
        end)
        
        -- Hover effects
        minimizeButton.MouseEnter:Connect(function()
            CreateTween(minimizeButton, {BackgroundTransparency = 0.1}):Play()
        end)
        
        minimizeButton.MouseLeave:Connect(function()
            CreateTween(minimizeButton, {BackgroundTransparency = 0.3}):Play()
        end)
    end
    
    -- Close functionality
    closeButton.MouseButton1Click:Connect(function()
        CreateTween(windowFrame, {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }):Play()
        wait(0.3)
        screenGui:Destroy()
    end)
    
    -- Hover effects
    closeButton.MouseEnter:Connect(function()
        CreateTween(closeButton, {BackgroundTransparency = 0.1}):Play()
    end)
    
    closeButton.MouseLeave:Connect(function()
        CreateTween(closeButton, {BackgroundTransparency = 0.3}):Play()
    end)
    
    -- Window animation
    windowFrame.Size = UDim2.new(0, 0, 0, 0)
    windowFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    CreateTween(windowFrame, {
        Size = size,
        Position = UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2)
    }, 0.5, Enum.EasingStyle.Back):Play()
    
    setmetatable(window, {__index = Window})
    table.insert(Library.Windows, window)
    return window
end

function Library:SetTheme(theme)
    if type(theme) == "string" and Library.Themes[theme] then
        Library.CurrentTheme = Library.Themes[theme]
    elseif type(theme) == "table" then
        Library.CurrentTheme = theme
    end
    
    -- Update all existing windows (basic implementation)
    -- In a full implementation, you'd recursively update all UI elements
    Library:Notify({
        Title = "Theme Changed",
        Content = "Theme has been updated successfully",
        Duration = 2,
        Type = "Success"
    })
end

function Library:SetCustomTheme(customTheme)
    Library.CurrentTheme = customTheme
    Library:Notify({
        Title = "Custom Theme Applied",
        Content = "Custom theme has been applied successfully",
        Duration = 2,
        Type = "Success"
    })
end

-- Return the library
return Library

