
--[[
    Cosmic UI Library for Roblox
    A comprehensive space-themed GUI library with modern design and smooth animations
    
    Features:
    - Space/sky themed interface with cosmic colors
    - Draggable windows with minimize functionality
    - Smooth animations and transitions
    - Complete component set (buttons, toggles, sliders, advanced dropdowns, inputs)
    - Multi-select nested dropdown support with search
    - Configuration saving and loading
    - Error handling throughout
    - Responsive design
    - Loadstring compatible
    - Scrollable sidebar
    - rbxassetid icon support
    
    Author: Cosmic UI Team
    Version: 1.2.0
]]

local CosmicUI = {}
CosmicUI.__index = CosmicUI
CosmicUI.Flags = {}

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TextService = game:GetService("TextService")
local HttpService = game:GetService("HttpService")

-- Local Player
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Constants
local WINDOW_SIZE = UDim2.new(0, 500, 0, 250)
local SIDEBAR_WIDTH = 100
local MINIMIZE_ICON_SIZE = UDim2.new(0, 40, 0, 40)

-- Global dropdown management
local openDropdowns = {}
local openNestedDropdowns = {}
local selectedItems = {}

-- Theme Configuration (Purple Space Theme)
local Theme = {
    -- Main Colors (Purple Space Theme)
    Background = Color3.fromRGB(13, 13, 20),
    BackgroundTransparency = 0.2,
    Secondary = Color3.fromRGB(25, 23, 35),
    SecondaryTransparency = 0.2,
    Accent = Color3.fromRGB(88, 82, 185),
    AccentHover = Color3.fromRGB(107, 99, 212),
    AccentActive = Color3.fromRGB(139, 92, 246),
    
    -- UI Colors
    Text = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(180, 180, 190),
    TextDisabled = Color3.fromRGB(120, 120, 130),
    
    -- Component Colors
    Surface = Color3.fromRGB(30, 28, 45),
    SurfaceHover = Color3.fromRGB(40, 38, 55),
    Button = Color3.fromRGB(45, 42, 65),
    ButtonHover = Color3.fromRGB(55, 52, 75),
    Toggle = Color3.fromRGB(35, 33, 50),
    ToggleActive = Color3.fromRGB(139, 92, 246),
    
    -- Border Colors
    Border = Color3.fromRGB(45, 42, 60),
    BorderLight = Color3.fromRGB(60, 57, 80),
    BorderAccent = Color3.fromRGB(139, 92, 246),
    
    -- Status Colors
    Success = Color3.fromRGB(34, 197, 94),
    Warning = Color3.fromRGB(251, 191, 36),
    Error = Color3.fromRGB(239, 68, 68),
    
    -- Selection Colors
    Selected = Color3.fromRGB(76, 175, 80),
    SelectedHover = Color3.fromRGB(102, 187, 106),
    
    -- Gradients
    WindowGradient = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 18, 35)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 9, 18))
    }),
    
    SidebarGradient = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(22, 20, 38)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(13, 12, 22))
    }),
    
    AccentGradient = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(139, 92, 246)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(167, 139, 250))
    })
}

-- Animation Settings
local AnimationSettings = {
    Duration = 0.25,
    EasingStyle = Enum.EasingStyle.Quart,
    EasingDirection = Enum.EasingDirection.Out,
    Fast = 0.15,
    Slow = 0.4
}

-- Utility Functions
local function CreateTween(instance, properties, duration, easingStyle, easingDirection)
    duration = duration or AnimationSettings.Duration
    easingStyle = easingStyle or AnimationSettings.EasingStyle
    easingDirection = easingDirection or AnimationSettings.EasingDirection
    
    local tweenInfo = TweenInfo.new(duration, easingStyle, easingDirection)
    local tween = TweenService:Create(instance, tweenInfo, properties)
    return tween
end

local function CreateCorner(parent, radius)
    radius = radius or UDim.new(0, 8)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = radius
    corner.Parent = parent
    return corner
end

local function CreateStroke(parent, color, thickness, transparency)
    color = color or Theme.Border
    thickness = thickness or 1
    transparency = transparency or 0
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = thickness
    stroke.Transparency = transparency
    stroke.Parent = parent
    return stroke
end

local function CreateGradient(parent, colorSequence, rotation)
    rotation = rotation or 90
    local gradient = Instance.new("UIGradient")
    gradient.Color = colorSequence
    gradient.Rotation = rotation
    gradient.Parent = parent
    return gradient
end

local function CreatePadding(parent, padding)
    padding = padding or UDim.new(0, 6)
    local paddingInstance = Instance.new("UIPadding")
    paddingInstance.PaddingTop = padding
    paddingInstance.PaddingBottom = padding
    paddingInstance.PaddingLeft = padding
    paddingInstance.PaddingRight = padding
    paddingInstance.Parent = parent
    return paddingInstance
end

local function CreateListLayout(parent, direction, padding, horizontalAlignment, verticalAlignment)
    direction = direction or Enum.FillDirection.Vertical
    padding = padding or UDim.new(0, 4)
    horizontalAlignment = horizontalAlignment or Enum.HorizontalAlignment.Center
    verticalAlignment = verticalAlignment or Enum.VerticalAlignment.Top
    
    local layout = Instance.new("UIListLayout")
    layout.FillDirection = direction
    layout.Padding = padding
    layout.HorizontalAlignment = horizontalAlignment
    layout.VerticalAlignment = verticalAlignment
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = parent
    return layout
end

local function CreateDropShadow(parent, offset, blur, transparency)
    blur = blur or 8
    transparency = transparency or 0.85
    offset = offset or Vector2.new(0, 2)

    local shadow = Instance.new("ImageLabel")
    shadow.Name = "DropShadow"
    shadow.Size = UDim2.new(1, blur, 1, blur)
    shadow.Position = UDim2.new(0, -blur/2 + offset.X, 0, -blur/2 + offset.Y)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://8992231241"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = transparency
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.ZIndex = parent.ZIndex - 1
    shadow.Parent = parent.Parent
    return shadow
end

-- Global dropdown management functions
local function closeAllDropdowns()
    for _, dropdown in pairs(openDropdowns) do
        if dropdown and dropdown.Parent then
            dropdown.Visible = false
        end
    end
    table.clear(openDropdowns)
end

local function closeAllNestedDropdowns()
    for _, nestedGroup in pairs(openNestedDropdowns) do
        for _, nested in pairs(nestedGroup) do
            if nested and nested.Parent then
                nested.Visible = false
            end
        end
    end
    table.clear(openNestedDropdowns)
end

-- Setup global click detection
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local mousePos = UserInputService:GetMouseLocation()
        local clickedInside = false
        
        -- Check main dropdowns
        for _, dropdown in pairs(openDropdowns) do
            if dropdown and dropdown.Parent then
                local pos, size = dropdown.AbsolutePosition, dropdown.AbsoluteSize
                if mousePos.X > pos.X and mousePos.X < pos.X + size.X and
                   mousePos.Y > pos.Y and mousePos.Y < pos.Y + size.Y then
                    clickedInside = true
                    break
                end
            end
        end
        
        -- Check nested dropdowns
        if not clickedInside then
            for _, nestedGroup in pairs(openNestedDropdowns) do
                for _, nested in pairs(nestedGroup) do
                    if nested and nested.Parent then
                        local pos, size = nested.AbsolutePosition, nested.AbsoluteSize
                        if mousePos.X > pos.X and mousePos.X < pos.X + size.X and
                           mousePos.Y > pos.Y and mousePos.Y < pos.Y + size.Y then
                            clickedInside = true
                            break
                        end
                    end
                end
                if clickedInside then break end
            end
        end
        
        if not clickedInside then 
            closeAllDropdowns()
            closeAllNestedDropdowns()
        end
    end
end)

-- Error Handling
local function SafeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        warn("🌌 CosmicUI Error: " .. tostring(result))
        return false, result
    end
    return true, result
end

-- Configuration System
local function SaveConfiguration(data, fileName)
    SafeCall(function()
        if not fileName then fileName = "CosmicUI_Config" end
        local success, encoded = pcall(HttpService.JSONEncode, HttpService, data)
        if success then
            writefile(fileName .. ".json", encoded)
        end
    end)
end

local function LoadConfiguration(fileName)
    return SafeCall(function()
        if not fileName then fileName = "CosmicUI_Config" end
        if isfile(fileName .. ".json") then
            local content = readfile(fileName .. ".json")
            local success, decoded = pcall(HttpService.JSONDecode, HttpService, content)
            if success then
                return decoded
            end
        end
        return {}
    end)
end

-- Notification System
local NotificationHolder = nil

local function CreateNotificationHolder()
    if NotificationHolder then return NotificationHolder end
    
    NotificationHolder = Instance.new("Frame")
    NotificationHolder.Name = "CosmicUI_Notifications"
    NotificationHolder.Size = UDim2.new(0, 250, 1, 0)
    NotificationHolder.Position = UDim2.new(1, -260, 0, 10)
    NotificationHolder.BackgroundTransparency = 1
    NotificationHolder.Parent = PlayerGui
    
    CreateListLayout(NotificationHolder, Enum.FillDirection.Vertical, UDim.new(0, 10))
    
    return NotificationHolder
end

-- Modular Dropdown Components
local DropdownComponents = {}

function DropdownComponents.CreateButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Text = text
    btn.Size = UDim2.new(1, 0, 0, 28)
    btn.BackgroundColor3 = Theme.Button
    btn.BackgroundTransparency = 0.5
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.TextColor3 = Theme.Text
    btn.TextXAlignment = Enum.TextXAlignment.Left
    
    CreateCorner(btn, UDim.new(0, 6))
    CreateStroke(btn, Theme.Border, 0.5)
    CreatePadding(btn, UDim.new(0, 8))
    
    btn.MouseButton1Click:Connect(function()
        SafeCall(callback or function() end)
    end)
    
    -- Hover effects
    btn.MouseEnter:Connect(function()
        CreateTween(btn, {BackgroundColor3 = Theme.ButtonHover, BackgroundTransparency = 0.3}):Play()
    end)
    
    btn.MouseLeave:Connect(function()
        CreateTween(btn, {BackgroundColor3 = Theme.Button, BackgroundTransparency = 0.5}):Play()
    end)
    
    return btn
end

function DropdownComponents.CreateTextBox(placeholder, callback)
    local box = Instance.new("TextBox")
    box.PlaceholderText = placeholder
    box.Size = UDim2.new(1, 0, 0, 28)
    box.BackgroundColor3 = Theme.Surface
    box.BackgroundTransparency = 0.5
    box.BorderSizePixel = 0
    box.Font = Enum.Font.GothamBold
    box.TextSize = 11
    box.TextColor3 = Theme.Text
    box.PlaceholderColor3 = Theme.TextDisabled
    box.TextXAlignment = Enum.TextXAlignment.Left
    box.Text = ""
    box.ClearTextOnFocus = false
    
    CreateCorner(box, UDim.new(0, 6))
    CreateStroke(box, Theme.Border, 0.5)
    CreatePadding(box, UDim.new(0, 8))
    
    box.FocusLost:Connect(function(enterPressed)
        SafeCall(callback or function() end, box.Text)
    end)
    
    -- Focus effects
    box.Focused:Connect(function()
        CreateTween(box, {BackgroundColor3 = Theme.SurfaceHover}):Play()
        CreateStroke(box, Theme.AccentActive, 0.5)
    end)
    
    box.FocusLost:Connect(function()
        CreateTween(box, {BackgroundColor3 = Theme.Surface}):Play()
        CreateStroke(box, Theme.Border, 0.5)
    end)
    
    return box
end

function DropdownComponents.CreateToggle(text, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, 0, 0, 30)
    toggleFrame.BackgroundColor3 = Theme.Surface
    toggleFrame.BackgroundTransparency = 0.5
    toggleFrame.BorderSizePixel = 0
    
    CreateCorner(toggleFrame, UDim.new(0, 6))
    CreateStroke(toggleFrame, Theme.Border, 0.5)
    CreatePadding(toggleFrame, UDim.new(0, 8))
    
    local toggleLabel = Instance.new("TextLabel")
    toggleLabel.Size = UDim2.new(1, -40, 1, 0)
    toggleLabel.Position = UDim2.new(0, 0, 0, 0)
    toggleLabel.BackgroundTransparency = 1
    toggleLabel.Text = text
    toggleLabel.TextColor3 = Theme.Text
    toggleLabel.TextSize = 11
    toggleLabel.Font = Enum.Font.GothamBold
    toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    toggleLabel.Parent = toggleFrame
    
    local toggleSwitch = Instance.new("Frame")
    toggleSwitch.Size = UDim2.new(0, 34, 0, 16)
    toggleSwitch.Position = UDim2.new(1, -34, 0.5, -8)
    toggleSwitch.BackgroundColor3 = Theme.Toggle
    toggleSwitch.BackgroundTransparency = 0.5
    toggleSwitch.BorderSizePixel = 0
    toggleSwitch.Parent = toggleFrame
    
    CreateCorner(toggleSwitch, UDim.new(0, 8))
    CreateStroke(toggleSwitch, Theme.Border, 0.5)
    
    local toggleIndicator = Instance.new("Frame")
    toggleIndicator.Size = UDim2.new(0, 12, 0, 12)
    toggleIndicator.Position = UDim2.new(0, 2, 0, 2)
    toggleIndicator.BackgroundColor3 = Theme.TextSecondary
    toggleIndicator.BorderSizePixel = 0
    toggleIndicator.Parent = toggleSwitch
    
    CreateCorner(toggleIndicator, UDim.new(0, 6))
    
    local toggled = false
    
    local function updateToggle(state)
        toggled = state
        if toggled then
            CreateTween(toggleSwitch, {BackgroundColor3 = Theme.ToggleActive}):Play()
            CreateTween(toggleIndicator, {
                Position = UDim2.new(0, 20, 0, 2),
                BackgroundColor3 = Theme.Text
            }):Play()
        else
            CreateTween(toggleSwitch, {BackgroundColor3 = Theme.Toggle}):Play()
            CreateTween(toggleIndicator, {
                Position = UDim2.new(0, 2, 0, 2),
                BackgroundColor3 = Theme.TextSecondary
            }):Play()
        end
        SafeCall(callback or function() end, toggled)
    end
    
    local clickDetector = Instance.new("TextButton")
    clickDetector.Size = UDim2.new(1, 0, 1, 0)
    clickDetector.BackgroundTransparency = 1
    clickDetector.Text = ""
    clickDetector.Parent = toggleFrame
    
    clickDetector.MouseButton1Click:Connect(function()
        updateToggle(not toggled)
    end)
    
    -- Hover effects
    clickDetector.MouseEnter:Connect(function()
        CreateTween(toggleFrame, {BackgroundColor3 = Theme.SurfaceHover}):Play()
    end)
    
    clickDetector.MouseLeave:Connect(function()
        CreateTween(toggleFrame, {BackgroundColor3 = Theme.Surface}):Play()
    end)
    
    return toggleFrame, updateToggle
end

function DropdownComponents.CreateSlider(min, max, callback)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, 0, 0, 45)
    sliderFrame.BackgroundColor3 = Theme.Surface
    sliderFrame.BackgroundTransparency = 0.5
    sliderFrame.BorderSizePixel = 0
    
    CreateCorner(sliderFrame, UDim.new(0, 6))
    CreateStroke(sliderFrame, Theme.Border, 0.5)
    CreatePadding(sliderFrame, UDim.new(0, 8))
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(1, 0, 0, 16)
    valueLabel.Position = UDim2.new(0, 0, 0, 2)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = "Value: " .. tostring(min)
    valueLabel.TextColor3 = Theme.Text
    valueLabel.TextSize = 11
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Left
    valueLabel.Parent = sliderFrame
    
    local sliderTrack = Instance.new("Frame")
    sliderTrack.Size = UDim2.new(1, 0, 0, 4)
    sliderTrack.Position = UDim2.new(0, 0, 1, -12)
    sliderTrack.BackgroundColor3 = Theme.Toggle
    sliderTrack.BackgroundTransparency = 0.5
    sliderTrack.BorderSizePixel = 0
    sliderTrack.Parent = sliderFrame
    
    CreateCorner(sliderTrack, UDim.new(0, 3))
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new(0.5, 0, 1, 0)
    sliderFill.BackgroundColor3 = Theme.AccentActive
    sliderFill.BackgroundTransparency = 0.5
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderTrack
    
    CreateCorner(sliderFill, UDim.new(0, 3))
    
    local sliderHandle = Instance.new("Frame")
    sliderHandle.Size = UDim2.new(0, 12, 0, 12)
    sliderHandle.Position = UDim2.new(0.5, -6, 0, -4)
    sliderHandle.BackgroundColor3 = Theme.Text
    sliderHandle.BackgroundTransparency = 0.5
    sliderHandle.BorderSizePixel = 0
    sliderHandle.Parent = sliderTrack
    
    CreateCorner(sliderHandle, UDim.new(0, 6))
    CreateStroke(sliderHandle, Theme.AccentActive, 1.5)
    
    local dragging = false
    local currentValue = min
    
    local function updateSlider(value)
        value = math.clamp(value, min, max)
        currentValue = math.floor(value)
        valueLabel.Text = "Value: " .. tostring(currentValue)
        
        local percentage = (currentValue - min) / (max - min)
        CreateTween(sliderFill, {Size = UDim2.new(percentage, 0, 1, 0)}):Play()
        CreateTween(sliderHandle, {Position = UDim2.new(percentage, -6, 0, -4)}):Play()
        
        SafeCall(callback or function() end, currentValue)
    end
    
    -- Fixed slider dragging
    local function handleSliderInput(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            local percentage = math.clamp((input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
            local value = min + (max - min) * percentage
            updateSlider(value)
        end
    end
    
    sliderTrack.InputBegan:Connect(handleSliderInput)
    sliderHandle.InputBegan:Connect(handleSliderInput)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local percentage = math.clamp((input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
            local value = min + (max - min) * percentage
            updateSlider(value)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    -- Initialize
    updateSlider(min)
    
    return sliderFrame, updateSlider
end

-- Improved Nested Dropdown with Multi-Select and proper Z-Index management
function DropdownComponents.CreateNestedDropdown(parentBtn, items, callback, dropdownId, parentMainFrame)
    dropdownId = dropdownId or tostring(math.random(1000000, 9999999))
    
    -- Create container that will be parented to the main frame for proper layering
    local nestedContainer = Instance.new("Frame")
    nestedContainer.Name = "NestedContainer_" .. dropdownId
    nestedContainer.Size = UDim2.new(0, 300, 0, 0)
    nestedContainer.AutomaticSize = Enum.AutomaticSize.Y
    nestedContainer.BackgroundTransparency = 1
    nestedContainer.BorderSizePixel = 0
    nestedContainer.Visible = false
    nestedContainer.ClipsDescendants = false
    nestedContainer.ZIndex = 1000
    nestedContainer.Parent = parentMainFrame or PlayerGui
    
    local dropdown = Instance.new("Frame")
    dropdown.Size = UDim2.new(1, 0, 0, 0)
    dropdown.AutomaticSize = Enum.AutomaticSize.Y
    dropdown.BackgroundColor3 = Theme.Surface
    dropdown.BackgroundTransparency = 0.15
    dropdown.BorderSizePixel = 0
    dropdown.ClipsDescendants = false
    dropdown.ZIndex = 1001
    dropdown.Parent = nestedContainer
    
    CreateCorner(dropdown, UDim.new(0, 6))
    CreateStroke(dropdown, Theme.BorderAccent, 1)
    CreateDropShadow(dropdown, Vector2.new(0, 2), 8, 0.3)
    
    local layout = Instance.new("UIListLayout", dropdown)
    layout.Padding = UDim.new(0, 2)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    
    CreatePadding(dropdown, UDim.new(0, 4))

    -- Initialize selected items for this dropdown
    if not selectedItems[dropdownId] then
        selectedItems[dropdownId] = {}
    end

    -- Create search box
    local searchContainer = Instance.new("Frame")
    searchContainer.Size = UDim2.new(1, -8, 0, 30)
    searchContainer.BackgroundColor3 = Theme.Button
    searchContainer.BackgroundTransparency = 0.2
    searchContainer.BorderSizePixel = 0
    searchContainer.LayoutOrder = 1
    searchContainer.ZIndex = 1002
    searchContainer.Parent = dropdown
    
    CreateCorner(searchContainer, UDim.new(0, 4))
    CreateStroke(searchContainer, Theme.BorderAccent, 1)
    
    local searchBox = Instance.new("TextBox")
    searchBox.Size = UDim2.new(1, -20, 1, -4)
    searchBox.Position = UDim2.new(0, 10, 0, 2)
    searchBox.BackgroundTransparency = 1
    searchBox.Font = Enum.Font.GothamBold
    searchBox.PlaceholderText = "Search..."
    searchBox.PlaceholderColor3 = Theme.TextDisabled
    searchBox.Text = ""
    searchBox.TextColor3 = Theme.Text
    searchBox.TextSize = 11
    searchBox.TextXAlignment = Enum.TextXAlignment.Left
    searchBox.ClearTextOnFocus = false
    searchBox.ZIndex = 1003
    searchBox.Parent = searchContainer
    
    -- Add search icon
    local searchIcon = Instance.new("TextLabel")
    searchIcon.Size = UDim2.new(0, 16, 0, 16)
    searchIcon.Position = UDim2.new(1, -20, 0.5, -8)
    searchIcon.BackgroundTransparency = 1
    searchIcon.Text = "🔍"
    searchIcon.TextColor3 = Theme.TextDisabled
    searchIcon.TextSize = 12
    searchIcon.TextXAlignment = Enum.TextXAlignment.Center
    searchIcon.TextYAlignment = Enum.TextYAlignment.Center
    searchIcon.ZIndex = 1003
    searchIcon.Parent = searchContainer
    
    -- Container for dropdown items
    local itemsContainer = Instance.new("ScrollingFrame")
    itemsContainer.Size = UDim2.new(1, 0, 0, 0)
    itemsContainer.AutomaticSize = Enum.AutomaticSize.Y
    itemsContainer.BackgroundTransparency = 1
    itemsContainer.LayoutOrder = 2
    itemsContainer.ScrollBarThickness = 4
    itemsContainer.ScrollBarImageColor3 = Theme.Accent
    itemsContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    itemsContainer.ZIndex = 1002
    itemsContainer.Parent = dropdown
    
    -- Limit height to prevent overflow
    local maxHeight = 250
    local itemsLayout = Instance.new("UIListLayout", itemsContainer)
    itemsLayout.Padding = UDim.new(0, 2)
    itemsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    -- Update canvas size when content changes
    itemsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        local contentHeight = itemsLayout.AbsoluteContentSize.Y
        if contentHeight > maxHeight then
            itemsContainer.Size = UDim2.new(1, 0, 0, maxHeight)
            itemsContainer.AutomaticSize = Enum.AutomaticSize.None
        else
            itemsContainer.Size = UDim2.new(1, 0, 0, 0)
            itemsContainer.AutomaticSize = Enum.AutomaticSize.Y
        end
        itemsContainer.CanvasSize = UDim2.new(0, 0, 0, contentHeight)
    end)
    
    -- Store original items and create buttons
    local originalItems = items
    local itemButtons = {}
    
    -- Function to create multi-select item button
    local function createMultiSelectButton(item, index)
        local button = Instance.new("TextButton")
        button.Text = tostring(item)
        button.Size = UDim2.new(1, 0, 0, 28)
        button.BackgroundColor3 = Theme.Button
        button.BackgroundTransparency = 0.5
        button.BorderSizePixel = 0
        button.Font = Enum.Font.GothamBold
        button.TextSize = 11
        button.TextColor3 = Theme.Text
        button.TextXAlignment = Enum.TextXAlignment.Left
        button.ZIndex = 1003
        
        CreateCorner(button, UDim.new(0, 6))
        CreateStroke(button, Theme.Border, 0.5)
        CreatePadding(button, UDim.new(0, 8))
        
        -- Selection indicator
        local selectionIndicator = Instance.new("Frame")
        selectionIndicator.Size = UDim2.new(0, 8, 0, 8)
        selectionIndicator.Position = UDim2.new(1, -14, 0.5, -4)
        selectionIndicator.BackgroundColor3 = Theme.Selected
        selectionIndicator.BorderSizePixel = 0
        selectionIndicator.Visible = false
        selectionIndicator.ZIndex = 1004
        selectionIndicator.Parent = button
        
        CreateCorner(selectionIndicator, UDim.new(0.5, 0))
        
        -- Function to update selection state
        local function updateSelectionState()
            local isSelected = false
            for _, selectedItem in ipairs(selectedItems[dropdownId] or {}) do
                if selectedItem == item then
                    isSelected = true
                    break
                end
            end
            
            -- Update visual state
            if isSelected then
                button.BackgroundColor3 = Theme.Selected
                button.BackgroundTransparency = 0.3
                button.TextColor3 = Theme.Text
                selectionIndicator.Visible = true
                CreateStroke(button, Theme.Selected, 1)
            else
                button.BackgroundColor3 = Theme.Button
                button.BackgroundTransparency = 0.5
                button.TextColor3 = Theme.Text
                selectionIndicator.Visible = false
                CreateStroke(button, Theme.Border, 0.5)
            end
        end
        
        -- Handle multi-select
        button.MouseButton1Click:Connect(function()
            if not selectedItems[dropdownId] then
                selectedItems[dropdownId] = {}
            end
            
            local isSelected = false
            local selectedIndex = -1
            
            -- Check if item is already selected
            for i, selectedItem in ipairs(selectedItems[dropdownId]) do
                if selectedItem == item then
                    isSelected = true
                    selectedIndex = i
                    break
                end
            end
            
            -- Toggle selection
            if isSelected then
                -- Remove from selection
                table.remove(selectedItems[dropdownId], selectedIndex)
            else
                -- Add to selection
                table.insert(selectedItems[dropdownId], item)
            end
            
            updateSelectionState()
            
            -- Call callback with current selection
            if callback then
                SafeCall(callback, selectedItems[dropdownId], item, not isSelected)
            end
        end)
        
        -- Hover effects
        button.MouseEnter:Connect(function()
            local isSelected = false
            for _, selectedItem in ipairs(selectedItems[dropdownId] or {}) do
                if selectedItem == item then
                    isSelected = true
                    break
                end
            end
            
            if isSelected then
                CreateTween(button, {BackgroundColor3 = Theme.SelectedHover}):Play()
            else
                CreateTween(button, {BackgroundColor3 = Theme.ButtonHover, BackgroundTransparency = 0.3}):Play()
            end
        end)
        
        button.MouseLeave:Connect(function()
            updateSelectionState()
        end)
        
        -- Initialize state
        updateSelectionState()
        
        return button
    end
    
    -- Create buttons for items
    for i, item in ipairs(originalItems) do
        local button = createMultiSelectButton(item, i)
        button.LayoutOrder = i
        button.Parent = itemsContainer
        itemButtons[tostring(item)] = button
    end
    
    -- Search functionality
    local function filterItems(searchText)
        searchText = searchText:lower()
        
        for item, button in pairs(itemButtons) do
            if searchText == "" then
                button.Visible = true
            else
                button.Visible = tostring(item):lower():find(searchText, 1, true) ~= nil
            end
        end
    end
    
    -- Connect search box events
    searchBox.Changed:Connect(function(property)
        if property == "Text" then
            filterItems(searchBox.Text)
        end
    end)
    
    -- Function to position dropdown correctly
    local function positionDropdown()
        local parentPos = parentBtn.AbsolutePosition
        local parentSize = parentBtn.AbsoluteSize
        
        -- Position to the right of parent button
        nestedContainer.Position = UDim2.new(0, parentPos.X + parentSize.X + 5, 0, parentPos.Y)
        
        -- Check if dropdown would go off screen and adjust
        local screenSize = workspace.CurrentCamera.ViewportSize
        local dropdownSize = nestedContainer.AbsoluteSize
        
        -- Adjust horizontal position if necessary
        if parentPos.X + parentSize.X + dropdownSize.X + 10 > screenSize.X then
            nestedContainer.Position = UDim2.new(0, parentPos.X - dropdownSize.X - 5, 0, parentPos.Y)
        end
        
        -- Adjust vertical position if necessary
        if parentPos.Y + dropdownSize.Y > screenSize.Y then
            nestedContainer.Position = UDim2.new(0, nestedContainer.Position.X.Offset, 0, screenSize.Y - dropdownSize.Y - 10)
        end
    end
    
    -- Handle dropdown visibility
    parentBtn.MouseButton1Click:Connect(function()
        local sectionId = parentBtn:FindFirstAncestor("Frame")
        if sectionId then sectionId = sectionId.Name else sectionId = "default" end
        
        -- Close other nested dropdowns in the same section
        if openNestedDropdowns[sectionId] then
            for id, dropdown in pairs(openNestedDropdowns[sectionId]) do
                if id ~= dropdownId then
                    dropdown.Visible = false
                end
            end
        else
            openNestedDropdowns[sectionId] = {}
        end
        
        -- Toggle current dropdown
        nestedContainer.Visible = not nestedContainer.Visible
        
        if nestedContainer.Visible then
            positionDropdown()
            searchBox.Text = ""
            filterItems("")
            openNestedDropdowns[sectionId][dropdownId] = nestedContainer
            -- Focus on search box when opened
            searchBox:CaptureFocus()
        else
            openNestedDropdowns[sectionId][dropdownId] = nil
        end
    end)
    
    return nestedContainer
end

-- Function to get selected items for a specific dropdown
function DropdownComponents.GetSelectedItems(dropdownId)
    return selectedItems[dropdownId] or {}
end

-- Function to clear selected items for a specific dropdown
function DropdownComponents.ClearSelectedItems(dropdownId)
    selectedItems[dropdownId] = {}
end

-- Function to set selected items for a specific dropdown
function DropdownComponents.SetSelectedItems(dropdownId, items)
    selectedItems[dropdownId] = items or {}
end

-- Window Class
local Window = {}
Window.__index = Window

function CosmicUI:CreateWindow(config)
    config = config or {}
    
    local window = {
        Name = config.Name or "Cosmic UI",
        Tabs = {},
        CurrentTab = nil,
        IsMinimized = false,
        Flags = {},
        ConfigurationSaving = config.ConfigurationSaving or {Enabled = false},
        LoadingTitle = config.LoadingTitle or "Loading...",
        LoadingSubtitle = config.LoadingSubtitle or "Please wait",
        
        -- UI References
        ScreenGui = nil,
        MainFrame = nil,
        TitleBar = nil,
        Sidebar = nil,
        Content = nil,
        MinimizeIcon = nil
    }
    
    setmetatable(window, Window)
    
    -- Create main ScreenGui
    window.ScreenGui = Instance.new("ScreenGui")
    window.ScreenGui.Name = "CosmicUI_" .. window.Name:gsub("%s+", "")
    window.ScreenGui.ResetOnSpawn = false
    window.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    window.ScreenGui.Parent = PlayerGui
    
    -- Main Frame
    window.MainFrame = Instance.new("Frame")
    window.MainFrame.Name = "MainFrame"
    window.MainFrame.Size = WINDOW_SIZE
    window.MainFrame.Position = UDim2.new(0.5, -WINDOW_SIZE.X.Offset/2, 0.5, -WINDOW_SIZE.Y.Offset/2)
    window.MainFrame.BackgroundTransparency = 0.1
    window.MainFrame.BorderSizePixel = 0
    window.MainFrame.ClipsDescendants = false
    window.MainFrame.Parent = window.ScreenGui
    
    CreateCorner(window.MainFrame, UDim.new(0, 12))
    CreateStroke(window.MainFrame, Theme.BorderLight, 1)
    CreateGradient(window.MainFrame, Theme.WindowGradient)
    CreateDropShadow(window.MainFrame, Vector2.new(0, 8), 24, 0.3)
    
    -- Title Bar
    window.TitleBar = Instance.new("Frame")
    window.TitleBar.Name = "TitleBar"
    window.TitleBar.Size = UDim2.new(1, 0, 0, 35)
    window.TitleBar.Position = UDim2.new(0, 0, 0, 0)
    window.TitleBar.BackgroundColor3 = Theme.Secondary
    window.TitleBar.BackgroundTransparency = 1
    window.TitleBar.BorderSizePixel = 0
    window.TitleBar.Parent = window.MainFrame
    
    CreateCorner(window.TitleBar, UDim.new(0, 8))
    CreateStroke(window.TitleBar, Theme.BorderLight, 1, 0.5)
    CreateGradient(window.TitleBar, Theme.WindowGradient)

    -- Title Text
    local titleText = Instance.new("TextLabel")
    titleText.Name = "TitleText"
    titleText.Size = UDim2.new(1, -80, 1, 0)
    titleText.Position = UDim2.new(0, 10, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = "🌌 " .. window.Name
    titleText.TextColor3 = Theme.Text
    titleText.TextSize = 12
    titleText.Font = Enum.Font.GothamBold
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = window.TitleBar
    
    -- Minimize Button
    local minimizeButton = Instance.new("TextButton")
    minimizeButton.Name = "MinimizeButton"
    minimizeButton.Size = UDim2.new(0, 25, 0, 25)
    minimizeButton.Position = UDim2.new(1, -60, 0.5, -12.5)
    minimizeButton.BackgroundColor3 = Theme.Button
    minimizeButton.BorderSizePixel = 0
    minimizeButton.Text = "−"
    minimizeButton.TextColor3 = Theme.Text
    minimizeButton.TextSize = 14
    minimizeButton.Font = Enum.Font.GothamBold
    minimizeButton.Parent = window.TitleBar
    
    CreateCorner(minimizeButton, UDim.new(0, 4))
    
    -- Close Button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 25, 0, 25)
    closeButton.Position = UDim2.new(1, -30, 0.5, -12.5)
    closeButton.BackgroundColor3 = Theme.Error
    closeButton.BorderSizePixel = 0
    closeButton.Text = "×"
    closeButton.TextColor3 = Theme.Text
    closeButton.TextSize = 14
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = window.TitleBar
    
    CreateCorner(closeButton, UDim.new(0, 4))
    
    -- Scrollable Sidebar
    window.Sidebar = Instance.new("ScrollingFrame")
    window.Sidebar.Name = "Sidebar"
    window.Sidebar.Size = UDim2.new(0, SIDEBAR_WIDTH, 1, -35)
    window.Sidebar.Position = UDim2.new(0, 0, 0, 35)
    window.Sidebar.BackgroundTransparency = 1
    window.Sidebar.BorderSizePixel = 0
    window.Sidebar.ScrollBarThickness = 4
    window.Sidebar.ScrollBarImageColor3 = Theme.Accent
    window.Sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
    window.Sidebar.Parent = window.MainFrame
    
    CreateGradient(window.Sidebar, Theme.SidebarGradient)
    CreateStroke(window.Sidebar, Theme.BorderLight, 1, 0.5)
    CreateGradient(window.Sidebar, Theme.WindowGradient)
    CreatePadding(window.Sidebar, UDim.new(0, 8))
    local sidebarLayout = CreateListLayout(window.Sidebar, Enum.FillDirection.Vertical, UDim.new(0, 4))
    
    -- Auto-resize sidebar canvas
    sidebarLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        window.Sidebar.CanvasSize = UDim2.new(0, 0, 0, sidebarLayout.AbsoluteContentSize.Y + 20)
    end)
    
    -- Content Area
    window.Content = Instance.new("Frame")
    window.Content.Name = "Content"
    window.Content.Size = UDim2.new(1, -SIDEBAR_WIDTH, 1, -35)
    window.Content.Position = UDim2.new(0, SIDEBAR_WIDTH, 0, 35)
    window.Content.BackgroundTransparency = 1
    window.Content.BorderSizePixel = 0
    window.Content.Parent = window.MainFrame
    
    -- Make window draggable
    window:MakeDraggable()
    
    -- Minimize functionality
    minimizeButton.MouseButton1Click:Connect(function()
        window:ToggleMinimize()
    end)
    
    -- Close functionality
    closeButton.MouseButton1Click:Connect(function()
        window:Destroy()
    end)
    
    -- Button hover effects
    minimizeButton.MouseEnter:Connect(function()
        CreateTween(minimizeButton, {BackgroundColor3 = Theme.ButtonHover}):Play()
    end)
    minimizeButton.MouseLeave:Connect(function()
        CreateTween(minimizeButton, {BackgroundColor3 = Theme.Button}):Play()
    end)
    
    closeButton.MouseEnter:Connect(function()
        CreateTween(closeButton, {BackgroundColor3 = Color3.fromRGB(220, 53, 69)}):Play()
    end)
    closeButton.MouseLeave:Connect(function()
        CreateTween(closeButton, {BackgroundColor3 = Theme.Error}):Play()
    end)
    
    CosmicUI.Flags = window.Flags
    
    return window
end

function Window:MakeDraggable()
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    self.TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.MainFrame.Position
            
            -- Bring to front
            self.ScreenGui.DisplayOrder = 999
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            local newPos = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
            CreateTween(self.MainFrame, {Position = newPos}, AnimationSettings.Fast):Play()
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            self.ScreenGui.DisplayOrder = 1
        end
    end)
end

function Window:ToggleMinimize()
    if self.IsMinimized then
        -- Restore
        self.MainFrame.Visible = true
        if self.MinimizeIcon then
            self.MinimizeIcon:Destroy()
            self.MinimizeIcon = nil
        end
        
        CreateTween(self.MainFrame, {
            Size = WINDOW_SIZE,
            Position = UDim2.new(0.5, -WINDOW_SIZE.X.Offset/2, 0.5, -WINDOW_SIZE.Y.Offset/2)
        }, AnimationSettings.Duration):Play()
        
        self.IsMinimized = false
    else
        -- Minimize
        CreateTween(self.MainFrame, {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }, AnimationSettings.Duration):Play()
        
        task.wait(AnimationSettings.Duration)
        self.MainFrame.Visible = false
        
        -- Create minimize icon
        self.MinimizeIcon = Instance.new("TextButton")
        self.MinimizeIcon.Name = "MinimizeIcon"
        self.MinimizeIcon.Size = MINIMIZE_ICON_SIZE
        self.MinimizeIcon.Position = UDim2.new(0, 20, 1, -70)
        self.MinimizeIcon.BackgroundColor3 = Theme.Accent
        self.MinimizeIcon.BorderSizePixel = 0
        self.MinimizeIcon.Text = "🌌"
        self.MinimizeIcon.TextColor3 = Theme.Text
        self.MinimizeIcon.TextSize = 20
        self.MinimizeIcon.Font = Enum.Font.GothamBold
        self.MinimizeIcon.Parent = self.ScreenGui
        
        CreateCorner(self.MinimizeIcon, UDim.new(0, 25))
        CreateDropShadow(self.MinimizeIcon, Vector2.new(0, 4), 12, 0.4)
        
        self.MinimizeIcon.MouseButton1Click:Connect(function()
            self:ToggleMinimize()
        end)
        
        self.MinimizeIcon.MouseEnter:Connect(function()
            CreateTween(self.MinimizeIcon, {
                Size = UDim2.new(0, 55, 0, 55),
                BackgroundColor3 = Theme.AccentHover
            }):Play()
        end)
        
        self.MinimizeIcon.MouseLeave:Connect(function()
            CreateTween(self.MinimizeIcon, {
                Size = MINIMIZE_ICON_SIZE,
                BackgroundColor3 = Theme.Accent
            }):Play()
        end)
        
        self.IsMinimized = true
    end
end

function Window:CreateTab(name, icon)
    local tab = {
        Name = name,
        Icon = icon or "📋",
        Elements = {},
        Frame = nil,
        Button = nil,
        Active = false,
        Window = self
    }
    
    -- Create tab button
    local tabButton = Instance.new("TextButton")
    tabButton.Name = name .. "Tab"
    tabButton.Size = UDim2.new(1, 0, 0, 35)
    tabButton.BackgroundColor3 = Color3.new(0, 0, 0)
    tabButton.BackgroundTransparency = 0.5
    tabButton.BorderSizePixel = 0
    tabButton.Text = ""
    tabButton.TextColor3 = Theme.TextSecondary
    tabButton.TextSize = 12
    tabButton.Font = Enum.Font.GothamBold
    tabButton.TextXAlignment = Enum.TextXAlignment.Left
    tabButton.LayoutOrder = #self.Tabs + 1
    tabButton.Parent = self.Sidebar

    CreateCorner(tabButton, UDim.new(0, 8))
    CreatePadding(tabButton, UDim.new(0, 8))
    
    -- Create icon - Updated to support rbxassetid
    local iconElement
    if icon and (string.find(icon, "rbxassetid://") or tonumber(icon)) then
        iconElement = Instance.new("ImageLabel")
        if tonumber(icon) then
            iconElement.Image = "rbxassetid://" .. icon
        else
            iconElement.Image = icon
        end
        iconElement.Size = UDim2.new(0, 16, 0, 16)
        iconElement.Position = UDim2.new(0, 0, 0.5, -8)
        iconElement.BackgroundTransparency = 1
        iconElement.ImageColor3 = Theme.TextSecondary
        iconElement.Parent = tabButton
    else
        iconElement = Instance.new("TextLabel")
        iconElement.Text = icon or "📋"
        iconElement.Size = UDim2.new(0, 16, 0, 16)
        iconElement.Position = UDim2.new(0, 0, 0.5, -8)
        iconElement.BackgroundTransparency = 1
        iconElement.TextColor3 = Theme.TextSecondary
        iconElement.TextSize = 12
        iconElement.Font = Enum.Font.GothamBold
        iconElement.TextXAlignment = Enum.TextXAlignment.Center
        iconElement.Parent = tabButton
    end
    
    -- Create text label
    local textLabel = Instance.new("TextLabel")
    textLabel.Text = name
    textLabel.Size = UDim2.new(1, -24, 1, 0)
    textLabel.Position = UDim2.new(0, 24, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Theme.TextSecondary
    textLabel.TextSize = 12
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.Parent = tabButton
    
    -- Store references
    tab.IconElement = iconElement
    tab.TextElement = textLabel
    
    -- Create tab content frame
    local tabFrame = Instance.new("ScrollingFrame")
    tabFrame.Name = name .. "Frame"
    tabFrame.Size = UDim2.new(1, 0, 1, 0)
    tabFrame.Position = UDim2.new(0, 0, 0, 0)
    tabFrame.BackgroundTransparency = 1
    tabFrame.BorderSizePixel = 0
    tabFrame.ScrollBarThickness = 4
    tabFrame.ScrollBarImageColor3 = Theme.Accent
    tabFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabFrame.Visible = false
    tabFrame.Parent = self.Content
    
    CreatePadding(tabFrame, UDim.new(0, 8))
    local layout = CreateListLayout(tabFrame, Enum.FillDirection.Vertical, UDim.new(0, 6))
    
    -- Auto-resize canvas
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tabFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 40)
    end)
    
    tab.Frame = tabFrame
    tab.Button = tabButton
    
    -- Tab button click
    tabButton.MouseButton1Click:Connect(function()
        SafeCall(function()
            self:SelectTab(tab)
        end)
    end)
    
    -- Hover effects
    tabButton.MouseEnter:Connect(function()
        if not tab.Active then
            CreateTween(tabButton, {BackgroundTransparency = 0.9}):Play()
        end
    end)
    
    tabButton.MouseLeave:Connect(function()
        if not tab.Active then
            CreateTween(tabButton, {BackgroundTransparency = 1}):Play()
        end
    end)
    
    table.insert(self.Tabs, tab)
    
    -- Auto-select first tab
    if #self.Tabs == 1 then
        self:SelectTab(tab)
    end
    
    return setmetatable(tab, {__index = self:GetTabMethods()})
end

function Window:SelectTab(targetTab)
    for _, tab in pairs(self.Tabs) do
        tab.Active = false
        tab.Frame.Visible = false
        CreateTween(tab.Button, {BackgroundTransparency = 1}):Play()
        
        -- Update icon dan text color
        if tab.IconElement:IsA("ImageLabel") then
            tab.IconElement.ImageColor3 = Theme.TextSecondary
        else
            tab.IconElement.TextColor3 = Theme.TextSecondary
        end
        tab.TextElement.TextColor3 = Theme.TextSecondary
    end
    
    targetTab.Active = true
    targetTab.Frame.Visible = true
    CreateTween(targetTab.Button, {BackgroundTransparency = 1}):Play()
    
    -- Update active icon dan text color
    if targetTab.IconElement:IsA("ImageLabel") then
        targetTab.IconElement.ImageColor3 = Theme.Text
    else
        targetTab.IconElement.TextColor3 = Theme.Text
    end
    targetTab.TextElement.TextColor3 = Theme.Text
    
    self.CurrentTab = targetTab
end

function Window:GetTabMethods()
    return {
        CreateSection = function(self, name)
            local section = Instance.new("TextLabel")
            section.Name = name .. "Section"
            section.Size = UDim2.new(1, 0, 0, 20)
            section.BackgroundTransparency = 1
            section.Text = name
            section.TextColor3 = Theme.Text
            section.TextSize = 12
            section.Font = Enum.Font.GothamBold
            section.TextXAlignment = Enum.TextXAlignment.Left
            section.LayoutOrder = #self.Elements + 1
            section.Parent = self.Frame
            
            table.insert(self.Elements, section)
            return section
        end,
        
        CreateButton = function(self, config)
            config = config or {}
            
            local button = Instance.new("TextButton")
            button.Name = (config.Name or "Button") .. "Btn"
            button.Size = UDim2.new(1, 0, 0, 28)
            button.BackgroundColor3 = Theme.Button
            button.BackgroundTransparency = 0.5
            button.BorderSizePixel = 0
            button.Text = config.Name or "Button"
            button.TextColor3 = Theme.Text
            button.TextSize = 11
            button.Font = Enum.Font.GothamBold
            button.LayoutOrder = #self.Elements + 1
            button.Parent = self.Frame
            
            CreateCorner(button, UDim.new(0, 6))
            CreateStroke(button, Theme.Border, 0.5)
            
            -- Click event
            button.MouseButton1Click:Connect(function()
                SafeCall(config.Callback or function() end)
                
                -- Visual feedback
                CreateTween(button, {BackgroundColor3 = Theme.AccentActive, BackgroundTransparency = 0.3}, AnimationSettings.Fast):Play()
                task.wait(AnimationSettings.Fast)
                CreateTween(button, {BackgroundColor3 = Theme.ButtonHover}, AnimationSettings.Fast):Play()
            end)
            
            -- Hover effects
            button.MouseEnter:Connect(function()
                CreateTween(button, {BackgroundColor3 = Theme.ButtonHover, BackgroundTransparency = 0.3}):Play()
            end)
            
            button.MouseLeave:Connect(function()
                CreateTween(button, {BackgroundColor3 = Theme.Button, BackgroundTransparency = 0.5}):Play()
            end)
            
            table.insert(self.Elements, button)
            return button
        end,
        
        CreateToggle = function(self, config)
            config = config or {}
            
            local toggleFrame = Instance.new("Frame")
            toggleFrame.Name = (config.Name or "Toggle") .. "Frame"
            toggleFrame.Size = UDim2.new(1, 0, 0, 30)
            toggleFrame.BackgroundColor3 = Theme.Surface
            toggleFrame.BackgroundTransparency = 0.5
            toggleFrame.BorderSizePixel = 0
            toggleFrame.LayoutOrder = #self.Elements + 1
            toggleFrame.Parent = self.Frame
            
            CreateCorner(toggleFrame, UDim.new(0, 6))
            CreateStroke(toggleFrame, Theme.Border, 0.5)
            CreatePadding(toggleFrame, UDim.new(0, 8))
            
            local toggleLabel = Instance.new("TextLabel")
            toggleLabel.Name = "Label"
            toggleLabel.Size = UDim2.new(1, -40, 1, 0)
            toggleLabel.Position = UDim2.new(0, 0, 0, 0)
            toggleLabel.BackgroundTransparency = 1
            toggleLabel.Text = config.Name or "Toggle"
            toggleLabel.TextColor3 = Theme.Text
            toggleLabel.TextSize = 11
            toggleLabel.Font = Enum.Font.GothamBold
            toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
            toggleLabel.TextYAlignment = Enum.TextYAlignment.Center
            toggleLabel.Parent = toggleFrame
            
            local toggleSwitch = Instance.new("Frame")
            toggleSwitch.Name = "ToggleSwitch"
            toggleSwitch.Size = UDim2.new(0, 34, 0, 16)
            toggleSwitch.Position = UDim2.new(1, -34, 0.5, -8)
            toggleSwitch.BackgroundColor3 = Theme.Toggle
            toggleSwitch.BackgroundTransparency = 0.5
            toggleSwitch.BorderSizePixel = 0
            toggleSwitch.Parent = toggleFrame
            
            CreateCorner(toggleSwitch, UDim.new(0, 8))
            CreateStroke(toggleSwitch, Theme.Border, 0.5)
            
            local toggleIndicator = Instance.new("Frame")
            toggleIndicator.Name = "Indicator"
            toggleIndicator.Size = UDim2.new(0, 12, 0, 12)
            toggleIndicator.Position = UDim2.new(0, 2, 0, 2)
            toggleIndicator.BackgroundColor3 = Theme.TextSecondary
            toggleIndicator.BorderSizePixel = 0
            toggleIndicator.Parent = toggleSwitch
            
            CreateCorner(toggleIndicator, UDim.new(0, 6))
            
            local currentValue = config.CurrentValue or false
            local flag = config.Flag
            
            local function UpdateToggle(value, animate)
                animate = animate ~= false
                currentValue = value
                
                if animate then
                    if value then
                        CreateTween(toggleSwitch, {BackgroundColor3 = Theme.ToggleActive}):Play()
                        CreateTween(toggleIndicator, {
                            Position = UDim2.new(0, 20, 0, 2),
                            BackgroundColor3 = Theme.Text
                        }):Play()
                    else
                        CreateTween(toggleSwitch, {BackgroundColor3 = Theme.Toggle}):Play()
                        CreateTween(toggleIndicator, {
                            Position = UDim2.new(0, 2, 0, 2),
                            BackgroundColor3 = Theme.TextSecondary
                        }):Play()
                    end
                else
                    toggleSwitch.BackgroundColor3 = value and Theme.ToggleActive or Theme.Toggle
                    toggleIndicator.Position = value and UDim2.new(0, 20, 0, 2) or UDim2.new(0, 2, 0, 2)
                    toggleIndicator.BackgroundColor3 = value and Theme.Text or Theme.TextSecondary
                end
                
                SafeCall(config.Callback or function() end, value)
                
                if flag and self.Window.Flags then
                    self.Window.Flags[flag] = {CurrentValue = value}
                end
            end
            
            -- Click event
            local clickDetector = Instance.new("TextButton")
            clickDetector.Size = UDim2.new(1, 0, 1, 0)
            clickDetector.BackgroundTransparency = 1
            clickDetector.Text = ""
            clickDetector.Parent = toggleFrame
            
            clickDetector.MouseButton1Click:Connect(function()
                UpdateToggle(not currentValue)
            end)
            
            -- Hover effects
            clickDetector.MouseEnter:Connect(function()
                CreateTween(toggleFrame, {BackgroundColor3 = Theme.SurfaceHover}):Play()
            end)
            
            clickDetector.MouseLeave:Connect(function()
                CreateTween(toggleFrame, {BackgroundColor3 = Theme.Surface}):Play()
            end)
            
            -- Initialize
            UpdateToggle(currentValue, false)
            
            -- Store reference
            local toggleObj = {
                CurrentValue = currentValue,
                Set = function(value) UpdateToggle(value) end
            }
            
            if flag and self.Window.Flags then
                self.Window.Flags[flag] = toggleObj
            end
            
            table.insert(self.Elements, toggleFrame)
            return toggleObj
        end,
        
        CreateSlider = function(self, config)
            config = config or {}
            
            local sliderFrame = Instance.new("Frame")
            sliderFrame.Name = (config.Name or "Slider") .. "Frame"
            sliderFrame.Size = UDim2.new(1, 0, 0, 45)
            sliderFrame.BackgroundColor3 = Theme.Surface
            sliderFrame.BackgroundTransparency = 0.5
            sliderFrame.BorderSizePixel = 0
            sliderFrame.LayoutOrder = #self.Elements + 1
            sliderFrame.Parent = self.Frame
            
            CreateCorner(sliderFrame, UDim.new(0, 6))
            CreateStroke(sliderFrame, Theme.Border, 0.5)
            CreatePadding(sliderFrame, UDim.new(0, 8))
            
            local sliderLabel = Instance.new("TextLabel")
            sliderLabel.Name = "Label"
            sliderLabel.Size = UDim2.new(1, -60, 0, 16)
            sliderLabel.Position = UDim2.new(0, 0, 0, 2)
            sliderLabel.BackgroundTransparency = 1
            sliderLabel.Text = config.Name or "Slider"
            sliderLabel.TextColor3 = Theme.Text
            sliderLabel.TextSize = 11
            sliderLabel.Font = Enum.Font.GothamBold
            sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
            sliderLabel.Parent = sliderFrame
            
            local valueLabel = Instance.new("TextLabel")
            valueLabel.Name = "ValueLabel"
            valueLabel.Size = UDim2.new(0, 60, 0, 16)
            valueLabel.Position = UDim2.new(1, -60, 0, 2)
            valueLabel.BackgroundTransparency = 1
            valueLabel.Text = tostring(config.CurrentValue or 50)
            valueLabel.TextColor3 = Theme.AccentActive
            valueLabel.TextSize = 11
            valueLabel.Font = Enum.Font.GothamBold
            valueLabel.TextXAlignment = Enum.TextXAlignment.Right
            valueLabel.Parent = sliderFrame
            
            local sliderTrack = Instance.new("Frame")
            sliderTrack.Name = "Track"
            sliderTrack.Size = UDim2.new(1, 0, 0, 4)
            sliderTrack.Position = UDim2.new(0, 0, 1, -12)
            sliderTrack.BackgroundColor3 = Theme.Toggle
            sliderTrack.BackgroundTransparency = 0.5
            sliderTrack.BorderSizePixel = 0
            sliderTrack.Parent = sliderFrame
            
            CreateCorner(sliderTrack, UDim.new(0, 3))
            
            local sliderFill = Instance.new("Frame")
            sliderFill.Name = "Fill"
            sliderFill.Size = UDim2.new(0.5, 0, 1, 0)
            sliderFill.Position = UDim2.new(0, 0, 0, 0)
            sliderFill.BackgroundColor3 = Theme.AccentActive
            sliderFill.BackgroundTransparency = 0.5
            sliderFill.BorderSizePixel = 0
            sliderFill.Parent = sliderTrack
            
            CreateCorner(sliderFill, UDim.new(0, 3))
            
            local sliderHandle = Instance.new("Frame")
            sliderHandle.Name = "Handle"
            sliderHandle.Size = UDim2.new(0, 12, 0, 12)
            sliderHandle.Position = UDim2.new(0.5, -6, 0, -4)
            sliderHandle.BackgroundColor3 = Theme.Text
            sliderHandle.BackgroundTransparency = 0.5
            sliderHandle.BorderSizePixel = 0
            sliderHandle.Parent = sliderTrack
            
            CreateCorner(sliderHandle, UDim.new(0, 6))
            CreateStroke(sliderHandle, Theme.AccentActive, 1.5)
            
            local minValue = config.Range and config.Range[1] or 0
            local maxValue = config.Range and config.Range[2] or 100
            local increment = config.Increment or 1
            local suffix = config.Suffix or ""
            local currentValue = config.CurrentValue or minValue
            local flag = config.Flag
            local dragging = false
            
            local function UpdateSlider(value, updatePosition)
                updatePosition = updatePosition ~= false
                value = math.clamp(value, minValue, maxValue)
                value = math.floor((value - minValue) / increment + 0.5) * increment + minValue
                value = math.clamp(value, minValue, maxValue)
                currentValue = value
                
                valueLabel.Text = tostring(value) .. suffix
                
                if updatePosition then
                    local percentage = (value - minValue) / (maxValue - minValue)
                    CreateTween(sliderFill, {Size = UDim2.new(percentage, 0, 1, 0)}):Play()
                    CreateTween(sliderHandle, {Position = UDim2.new(percentage, -6, 0, -4)}):Play()
                end
                
                SafeCall(config.Callback or function() end, value)
                
                if flag and self.Window.Flags then
                    self.Window.Flags[flag] = {CurrentValue = value}
                end
            end
            
            -- Fixed slider dragging - Improved click handling
            local function handleSliderInput(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    local percentage = math.clamp((input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
                    local value = minValue + (maxValue - minValue) * percentage
                    UpdateSlider(value)
                end
            end
            
            sliderTrack.InputBegan:Connect(handleSliderInput)
            sliderHandle.InputBegan:Connect(handleSliderInput)
            sliderFill.InputBegan:Connect(handleSliderInput)
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local percentage = math.clamp((input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
                    local value = minValue + (maxValue - minValue) * percentage
                    UpdateSlider(value)
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            
            -- Hover effects
            sliderTrack.MouseEnter:Connect(function()
                CreateTween(sliderHandle, {Size = UDim2.new(0, 14, 0, 14)}):Play()
            end)
            
            sliderTrack.MouseLeave:Connect(function()
                if not dragging then
                    CreateTween(sliderHandle, {Size = UDim2.new(0, 12, 0, 12)}):Play()
                end
            end)
            
            -- Initialize
            UpdateSlider(currentValue, false)
            
            -- Store reference
            local sliderObj = {
                CurrentValue = currentValue,
                Set = function(value) UpdateSlider(value) end
            }
            
            if flag and self.Window.Flags then
                self.Window.Flags[flag] = sliderObj
            end
            
            table.insert(self.Elements, sliderFrame)
            return sliderObj
        end,
        
        CreateDropdown = function(self, config)
            config = config or {}
            
            local dropdownFrame = Instance.new("Frame")
            dropdownFrame.Name = (config.Name or "Dropdown") .. "Frame"
            dropdownFrame.Size = UDim2.new(1, 0, 0, 0)
            dropdownFrame.AutomaticSize = Enum.AutomaticSize.Y
            dropdownFrame.BackgroundColor3 = Theme.Surface
            dropdownFrame.BackgroundTransparency = 0.5
            dropdownFrame.BorderSizePixel = 0
            dropdownFrame.LayoutOrder = #self.Elements + 1
            dropdownFrame.ClipsDescendants = false
            dropdownFrame.Parent = self.Frame
            
            CreateCorner(dropdownFrame, UDim.new(0, 6))
            CreateStroke(dropdownFrame, Theme.Border, 0.5)
            
            local layout = CreateListLayout(dropdownFrame, Enum.FillDirection.Vertical, UDim.new(0, 2))
            CreatePadding(dropdownFrame, UDim.new(0, 4))
            
            -- Create main dropdown button
            local btn = DropdownComponents.CreateButton("> " .. (config.Name or "Dropdown"), function() end)
            btn.Parent = dropdownFrame
            btn.LayoutOrder = 1
            
            -- Create content frame
            local content = Instance.new("Frame")
            content.Name = (config.Name or "Dropdown") .. "Content"
            content.Size = UDim2.new(1, 0, 0, 0)
            content.AutomaticSize = Enum.AutomaticSize.Y
            content.BackgroundColor3 = Theme.Secondary
            content.BackgroundTransparency = 0.5
            content.BorderSizePixel = 0
            content.Visible = false
            content.ClipsDescendants = false
            content.LayoutOrder = 2
            content.Parent = dropdownFrame

            CreateCorner(content, UDim.new(0, 6))
            CreateStroke(content, Theme.BorderLight, 0.5)

            local contentLayout = CreateListLayout(content, Enum.FillDirection.Vertical, UDim.new(0, 2))
            CreatePadding(content, UDim.new(0, 4))
            
            -- Button click handler
            btn.MouseButton1Click:Connect(function()
                local isOpen = content.Visible
                if isOpen then
                    local tween = CreateTween(content, {Size = UDim2.new(1, 0, 0, 0)})
                    tween:Play()
                    tween.Completed:Wait()
                    content.Visible = false
                    btn.Text = "> " .. (config.Name or "Dropdown")
                else
                    content.Visible = true
                    content.Size = UDim2.new(1, 0, 0, 0)
                    task.wait()
                    local height = content.AbsoluteSize.Y
                    content.Size = UDim2.new(1, 0, 0, 0)
                    local tween = CreateTween(content, {Size = UDim2.new(1, 0, 0, height)})
                    tween:Play()
                    btn.Text = "⌄ " .. (config.Name or "Dropdown")
                end
            end)
            
            -- Content builder function
            if config.ContentBuilder then
                SafeCall(config.ContentBuilder, content, DropdownComponents, self.Window.MainFrame)
            end
            
            table.insert(self.Elements, dropdownFrame)
            return {
                Frame = dropdownFrame,
                Content = content,
                AddButton = function(text, callback)
                    local button = DropdownComponents.CreateButton(text, callback)
                    button.Parent = content
                    return button
                end,
                AddTextBox = function(placeholder, callback)
                    local textbox = DropdownComponents.CreateTextBox(placeholder, callback)
                    textbox.Parent = content
                    return textbox
                end,
                AddToggle = function(text, callback)
                    local toggle = DropdownComponents.CreateToggle(text, callback)
                    toggle.Parent = content
                    return toggle
                end,
                AddSlider = function(min, max, callback)
                    local slider = DropdownComponents.CreateSlider(min, max, callback)
                    slider.Parent = content
                    return slider
                end,
                AddNestedDropdown = function(button, items, callback, dropdownId)
                    return DropdownComponents.CreateNestedDropdown(button, items, callback, dropdownId, self.Window.MainFrame)
                end
            }
        end,
        
        CreateInput = function(self, config)
            config = config or {}
            
            local inputFrame = Instance.new("Frame")
            inputFrame.Name = (config.Name or "Input") .. "Frame"
            inputFrame.Size = UDim2.new(1, 0, 0, 30)
            inputFrame.BackgroundColor3 = Theme.Surface
            inputFrame.BackgroundTransparency = 0.5
            inputFrame.BorderSizePixel = 0
            inputFrame.LayoutOrder = #self.Elements + 1
            inputFrame.Parent = self.Frame

            CreateCorner(inputFrame, UDim.new(0, 6))
            CreateStroke(inputFrame, Theme.Border, 0.5)
            CreatePadding(inputFrame, UDim.new(0, 8))
            
            local inputBox = Instance.new("TextBox")
            inputBox.Name = "InputBox"
            inputBox.Size = UDim2.new(1, 0, 1, 0)
            inputBox.Position = UDim2.new(0, 0, 0, 0)
            inputBox.BackgroundTransparency = 1
            inputBox.Text = config.CurrentValue or ""
            inputBox.PlaceholderText = config.PlaceholderText or (config.Name or "Enter text...")
            inputBox.TextColor3 = Theme.Text
            inputBox.PlaceholderColor3 = Theme.TextDisabled
            inputBox.TextSize = 11
            inputBox.Font = Enum.Font.GothamBold
            inputBox.TextXAlignment = Enum.TextXAlignment.Left
            inputBox.ClearTextOnFocus = false
            inputBox.Parent = inputFrame
            
            local currentValue = config.CurrentValue or ""
            local flag = config.Flag
            
            -- Text changed event
            inputBox.FocusLost:Connect(function(enterPressed)
                currentValue = inputBox.Text
                
                SafeCall(config.Callback or function() end, inputBox.Text)
                
                if flag and self.Window.Flags then
                    self.Window.Flags[flag] = {CurrentValue = inputBox.Text}
                end
                
                if config.RemoveTextAfterFocusLost then
                    inputBox.Text = ""
                end
            end)
            
            -- Focus effects
            inputBox.Focused:Connect(function()
                CreateTween(inputFrame, {BackgroundColor3 = Theme.SurfaceHover}):Play()
                CreateStroke(inputFrame, Theme.AccentActive, 0.5)
            end)
            
            inputBox.FocusLost:Connect(function()
                CreateTween(inputFrame, {BackgroundColor3 = Theme.Surface}):Play()
                CreateStroke(inputFrame, Theme.Border, 0.5)
            end)
            
            -- Store reference
            local inputObj = {
                CurrentValue = currentValue,
                Set = function(value) 
                    currentValue = value
                    inputBox.Text = value
                end
            }
            
            if flag and self.Window.Flags then
                self.Window.Flags[flag] = inputObj
            end
            
            table.insert(self.Elements, inputFrame)
            return inputObj
        end
    }
end

function Window:Destroy()
    if self.ConfigurationSaving and self.ConfigurationSaving.Enabled then
        local configData = {}
        for flag, data in pairs(self.Flags) do
            if data.CurrentValue ~= nil then
                configData[flag] = data.CurrentValue
            elseif data.CurrentOption ~= nil then
                configData[flag] = data.CurrentOption
            end
        end
        SaveConfiguration(configData, self.ConfigurationSaving.FileName)
    end
    
    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end
end

function Window:LoadConfiguration()
    if self.ConfigurationSaving and self.ConfigurationSaving.Enabled then
        local success, configData = LoadConfiguration(self.ConfigurationSaving.FileName)
        if success and configData then
            for flag, value in pairs(configData) do
                if self.Flags[flag] then
                    if self.Flags[flag].Set then
                        self.Flags[flag].Set(value)
                    elseif self.Flags[flag].CurrentValue ~= nil then
                        self.Flags[flag].CurrentValue = value
                    elseif self.Flags[flag].CurrentOption ~= nil then
                        self.Flags[flag].CurrentOption = value
                    end
                end
            end
        end
    end
end

-- Notification System
function CosmicUI:Notify(config)
    config = config or {}
    
    local notificationHolder = CreateNotificationHolder()
    
    local notification = Instance.new("Frame")
    notification.Name = "Notification"
    notification.Size = UDim2.new(1, 0, 0, 80)
    notification.BackgroundColor3 = Theme.Surface
    notification.BorderSizePixel = 0
    notification.Parent = notificationHolder
    
    CreateCorner(notification, UDim.new(0, 8))
    CreateStroke(notification, Theme.BorderAccent, 1)
    CreateDropShadow(notification, Vector2.new(0, 4), 12, 0.4)
    CreatePadding(notification, UDim.new(0, 15))
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, 0, 0, 20)
    titleLabel.Position = UDim2.new(0, 0, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = config.Title or "Notification"
    titleLabel.TextColor3 = Theme.Text
    titleLabel.TextSize = 14
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = notification
    
    local contentLabel = Instance.new("TextLabel")
    contentLabel.Name = "Content"
    contentLabel.Size = UDim2.new(1, 0, 0, 35)
    contentLabel.Position = UDim2.new(0, 0, 0, 25)
    contentLabel.BackgroundTransparency = 1
    contentLabel.Text = config.Content or "Notification content"
    contentLabel.TextColor3 = Theme.TextSecondary
    contentLabel.TextSize = 12
    contentLabel.Font = Enum.Font.GothamBold
    contentLabel.TextXAlignment = Enum.TextXAlignment.Left
    contentLabel.TextWrapped = true
    contentLabel.Parent = notification
    
    -- Slide in animation
    notification.Position = UDim2.new(1, 0, 0, 0)
    CreateTween(notification, {Position = UDim2.new(0, 0, 0, 0)}):Play()
    
    -- Auto-dismiss
    local duration = config.Duration or 5
    spawn(function()
        task.wait(duration)
        CreateTween(notification, {
            Position = UDim2.new(1, 0, 0, 0),
            BackgroundTransparency = 1
        }):Play()
        CreateTween(titleLabel, {TextTransparency = 1}):Play()
        CreateTween(contentLabel, {TextTransparency = 1}):Play()
        task.wait(AnimationSettings.Duration)
        notification:Destroy()
    end)
end

-- Return the module
return CosmicUI
