-- AstroHub GUI Library

local AstroHub = {}
local _logoAssetId = nil

-- Theme System (Moved to top for early definition)
local Themes = {
    Dark = {
        MainBackground = Color3.new(0.1, 0.1, 0.1),
        MainBackgroundTransparency = 0.1,
        TitleBar = Color3.new(0.15, 0.15, 0.15),
        TabContainer = Color3.new(0.12, 0.12, 0.12),
        TabContent = Color3.new(0.1, 0.1, 0.1),
        SectionBackground = Color3.new(0.15, 0.15, 0.15),
        ElementBackground = Color3.new(0.2, 0.2, 0.2),
        TextColor = Color3.new(1, 1, 1),
        AccentColor = Color3.new(0.2, 0.6, 0.8), -- Blue accent
        ToggleOff = Color3.new(0.8, 0.2, 0.2), -- Red
        ToggleOn = Color3.new(0.2, 0.8, 0.2), -- Green
        Divider = Color3.new(0.3, 0.3, 0.3),
        DropdownHover = Color3.new(0.25, 0.25, 0.25),
        NotificationBackground = Color3.new(0.1, 0.1, 0.1),
        NotificationText = Color3.new(0.8, 0.8, 0.8),
        InputPlaceholder = Color3.new(0.7, 0.7, 0.7),
    },
    Light = {
        MainBackground = Color3.new(0.9, 0.9, 0.9),
        MainBackgroundTransparency = 0.1,
        TitleBar = Color3.new(0.85, 0.85, 0.85),
        TabContainer = Color3.new(0.88, 0.88, 0.88),
        TabContent = Color3.new(0.9, 0.9, 0.9),
        SectionBackground = Color3.new(0.85, 0.85, 0.85),
        ElementBackground = Color3.new(0.7, 0.7, 0.7),
        TextColor = Color3.new(0, 0, 0),
        AccentColor = Color3.new(0.2, 0.6, 0.8), -- Blue accent
        ToggleOff = Color3.new(0.8, 0.2, 0.2), -- Red
        ToggleOn = Color3.new(0.2, 0.8, 0.2), -- Green
        Divider = Color3.new(0.7, 0.7, 0.7),
        DropdownHover = Color3.new(0.75, 0.75, 0.75),
        NotificationBackground = Color3.new(0.9, 0.9, 0.9),
        NotificationText = Color3.new(0.2, 0.2, 0.2),
        InputPlaceholder = Color3.new(0.3, 0.3, 0.3),
    },
    Manga = {
        MainBackground = Color3.new(1, 1, 1),
        MainBackgroundTransparency = 0.1,
        TitleBar = Color3.new(0.95, 0.95, 0.95),
        TabContainer = Color3.new(0.98, 0.98, 0.98),
        TabContent = Color3.new(1, 1, 1),
        SectionBackground = Color3.new(0.95, 0.95, 0.95),
        ElementBackground = Color3.new(0.9, 0.9, 0.9),
        TextColor = Color3.new(0, 0, 0),
        AccentColor = Color3.new(0.1, 0.1, 0.1), -- Dark accent
        ToggleOff = Color3.new(0.2, 0.2, 0.2), -- Dark grey
        ToggleOn = Color3.new(0.8, 0.8, 0.8), -- Light grey
        Divider = Color3.new(0.5, 0.5, 0.5),
        DropdownHover = Color3.new(0.92, 0.92, 0.92),
        NotificationBackground = Color3.new(1, 1, 1),
        NotificationText = Color3.new(0, 0, 0),
        InputPlaceholder = Color3.new(0.4, 0.4, 0.4),
    },
    Space = {
        MainBackground = Color3.new(0.05, 0.05, 0.1),
        MainBackgroundTransparency = 0.1,
        TitleBar = Color3.new(0.1, 0.1, 0.15),
        TabContainer = Color3.new(0.08, 0.08, 0.13),
        TabContent = Color3.new(0.05, 0.05, 0.1),
        SectionBackground = Color3.new(0.1, 0.1, 0.15),
        ElementBackground = Color3.new(0.15, 0.15, 0.2),
        TextColor = Color3.new(0.8, 0.9, 1), -- Light blue/white
        AccentColor = Color3.new(0.4, 0.6, 1), -- Bright blue
        ToggleOff = Color3.new(0.6, 0.2, 0.8), -- Purple
        ToggleOn = Color3.new(0.2, 0.8, 0.6), -- Teal
        Divider = Color3.new(0.2, 0.2, 0.3),
        DropdownHover = Color3.new(0.12, 0.12, 0.17),
        NotificationBackground = Color3.new(0.05, 0.05, 0.1),
        NotificationText = Color3.new(0.8, 0.9, 1),
        InputPlaceholder = Color3.new(0.5, 0.5, 0.6),
    }
}

local currentTheme = Themes.Dark -- Default theme

-- Function to set the current theme
function AstroHub:SetTheme(themeName)
    local theme = Themes[themeName]
    if theme then
        currentTheme = theme
        print("AstroHub: Theme set to " .. themeName)
        -- Optionally, re-apply theme to existing GUI elements if they are already created
        -- This would require iterating through existing elements and updating their colors
    else
        warn("AstroHub: Theme " .. themeName .. " not found.")
    end
end

-- Main window properties
local MainWindow = nil

-- Function to create the main window
function AstroHub:CreateWindow(title, sizeX, sizeY, posX, posY, logoAssetId)
    _logoAssetId = logoAssetId
    if MainWindow then
        warn("AstroHub: Window already created. Destroy it first to create a new one.")
        return MainWindow
    end

    MainWindow = Instance.new("ScreenGui")
    MainWindow.Name = "AstroHub_MainWindow"
    MainWindow.DisplayOrder = 999 -- Ensure it\"s on top
    MainWindow.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, sizeX, 0, sizeY)
    MainFrame.Position = UDim2.new(0, posX, 0, posY)
    MainFrame.BackgroundColor3 = currentTheme.MainBackground
    -- Add UICorner for rounded corners
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8) -- Adjust as needed
    UICorner.Parent = MainFrame

    -- Add UISizeGrip for resizing
    local SizeGrip = Instance.new("ImageLabel")
    SizeGrip.Name = "SizeGrip"
    SizeGrip.Size = UDim2.new(0, 20, 0, 20)
    SizeGrip.Position = UDim2.new(1, -20, 1, -20)
    SizeGrip.BackgroundTransparency = 1
    SizeGrip.Image = "rbxassetid://2769061889" -- Placeholder image for grip
    SizeGrip.Parent = MainFrame

    local resizing = false
    local resizeStartMouse
    local resizeStartSize

    SizeGrip.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            resizing = true
            resizeStartMouse = input.Position
            resizeStartSize = MainFrame.AbsoluteSize

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.Ended then
                    resizing = false
                end
            end)
        end
    end)

    SizeGrip.InputChanged:Connect(function(input)
        if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local deltaX = input.Position.X - resizeStartMouse.X
            local deltaY = input.Position.Y - resizeStartMouse.Y

            local newSizeX = resizeStartSize.X + deltaX
            local newSizeY = resizeStartSize.Y + deltaY

            -- Clamp size to minimums (e.g., 200x100)
            newSizeX = math.max(newSizeX, 200)
            newSizeY = math.max(newSizeY, 100)

            MainFrame.Size = UDim2.new(0, newSizeX, 0, newSizeY)
        end
    end)

    -- TitleBar needs to be defined before it\"s used in clampPosition and InputChanged
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 30)
    TitleBar.Position = UDim2.new(0, 0, 0, 0)
    TitleBar.BackgroundColor3 = currentTheme.TitleBar
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame

    local function clampPosition(frame, gui)
        local absPos = frame.AbsolutePosition
        local absSize = frame.AbsoluteSize
        local screenX = gui.AbsoluteSize.X
        local screenY = gui.AbsoluteSize.Y

        local newX = math.clamp(absPos.X, 0, screenX - absSize.X)
        local newY = math.clamp(absPos.Y, 0, screenY - absSize.Y)

        frame.Position = UDim2.new(0, newX, 0, newY)
    end

    TitleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                dragUpdate(input)
                clampPosition(MainFrame, MainWindow)
            end
        end
    end)

    MainFrame.Changed:Connect(function(property)
        if property == "AbsolutePosition" then
            clampPosition(MainFrame, MainWindow)
        end
    end)

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "TitleLabel"
    TitleLabel.Size = UDim2.new(1, -60, 1, 0)
    TitleLabel.Position = UDim2.new(0, 5, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title or "AstroHub"
    TitleLabel.TextColor3 = currentTheme.TextColor
    TitleLabel.Font = Enum.Font.SourceSansBold
    TitleLabel.TextSize = 18
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TitleBar

    if logoAssetId then
        local LogoImage = Instance.new("ImageLabel")
        LogoImage.Name = "LogoImage"
        LogoImage.Size = UDim2.new(0, 20, 0, 20)
        LogoImage.Position = UDim2.new(0, 5, 0, 5)
        LogoImage.BackgroundTransparency = 1
        LogoImage.Image = logoAssetId
        LogoImage.Parent = TitleBar

        TitleLabel.Position = UDim2.new(0, 30, 0, 0) -- Adjust position to make space for logo
        TitleLabel.Size = UDim2.new(1, -90, 1, 0) -- Adjust size
    end

    -- Close Button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, 30, 1, 0)
    CloseButton.Position = UDim2.new(1, -30, 0, 0)
    CloseButton.BackgroundColor3 = currentTheme.ToggleOff
    CloseButton.Text = "X"
    CloseButton.TextColor3 = currentTheme.TextColor
    CloseButton.Font = Enum.Font.SourceSansBold
    CloseButton.TextSize = 18
    CloseButton.Parent = TitleBar

    CloseButton.MouseButton1Click:Connect(function()
        MainWindow:Destroy()
        MainWindow = nil
    end)

    -- Draggable functionality
    local dragging
    local dragInput
    local dragStart
    local startPosition

    local function dragUpdate(input)
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
    end

    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPosition = MainFrame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.Ended then
                    dragging = false
                end
            end)
        end
    end)

    TitleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                dragUpdate(input)
            end
        end
    end)

    -- Minimize Button (Placeholder for now)
    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Name = "MinimizeButton"
    MinimizeButton.Size = UDim2.new(0, 30, 1, 0)
    MinimizeButton.Position = UDim2.new(1, -60, 0, 0)
    MinimizeButton.BackgroundColor3 = currentTheme.AccentColor
    MinimizeButton.Text = "_"
    MinimizeButton.TextColor3 = currentTheme.TextColor
    MinimizeButton.Font = Enum.Font.SourceSansBold
    MinimizeButton.TextSize = 18
    MinimizeButton.Parent = TitleBar

    MinimizeButton.MouseButton1Click:Connect(function()
        AstroHub:MinimizeGUI()
    end)
    MainWindow.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

    -- Initial fade-in animation
    MainFrame.BackgroundTransparency = 1
    TitleBar.BackgroundTransparency = 1
    TitleLabel.TextTransparency = 1
    CloseButton.BackgroundTransparency = 1
    CloseButton.TextTransparency = 1
    MinimizeButton.BackgroundTransparency = 1
    MinimizeButton.TextTransparency = 1

    local tweenService = game:GetService("TweenService")
    local fadeInInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local fadeInGoals = {BackgroundTransparency = currentTheme.MainBackgroundTransparency, TextTransparency = 0}

    tweenService:Create(MainFrame, fadeInInfo, fadeInGoals):Play()
    tweenService:Create(TitleBar, fadeInInfo, fadeInGoals):Play()
    tweenService:Create(TitleLabel, fadeInInfo, fadeInGoals):Play()
    tweenService:Create(CloseButton, fadeInInfo, fadeInGoals):Play()
    tweenService:Create(MinimizeButton, fadeInInfo, fadeInGoals):Play()

    return MainFrame
end

-- Tab management
local Tabs = {}
local TabContainer
local TabContentContainer

function AstroHub:CreateTab(tabName)
    if not MainWindow then
        warn("AstroHub: CreateTab requires a window to be created first.")
        return nil
    end

    local MainFrame = MainWindow:FindFirstChild("MainFrame")
    if not MainFrame then
        warn("AstroHub: MainFrame not found.")
        return nil
    end

    if not TabContainer then
        TabContainer = Instance.new("ScrollingFrame")
        TabContainer.Name = "TabContainer"
        TabContainer.Size = UDim2.new(0.2, 0, 1, -30) -- 20% width, height of MainFrame minus title bar
        TabContainer.Position = UDim2.new(0, 0, 0, 30)
        TabContainer.BackgroundColor3 = currentTheme.TabContainer
        TabContainer.BorderSizePixel = 0
        TabContainer.CanvasSize = UDim2.new(0, 0, 0, 0) -- Will be updated by UIListLayout
        TabContainer.ScrollBarImageColor3 = currentTheme.Divider
        TabContainer.ScrollBarThickness = 6
        TabContainer.Parent = MainFrame

        local TabListLayout = Instance.new("UIListLayout")
        TabListLayout.FillDirection = Enum.FillDirection.Vertical
        TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        TabListLayout.Padding = UDim.new(0, 5)
        TabListLayout.Parent = TabContainer

        TabListLayout.Changed:Connect(function(property)
            if property == "AbsoluteContentSize" then
                TabContainer.CanvasSize = UDim2.new(0, 0, 0, TabListLayout.AbsoluteContentSize.Y)
            end
        end)

        TabContentContainer = Instance.new("Frame")
        TabContentContainer.Name = "TabContentContainer"
        TabContentContainer.Size = UDim2.new(0.8, 0, 1, -30) -- 80% width, height of MainFrame minus title bar
        TabContentContainer.Position = UDim2.new(0.2, 0, 0, 30)
        TabContentContainer.BackgroundColor3 = currentTheme.TabContent
        TabContentContainer.BorderSizePixel = 0
        TabContentContainer.Parent = MainFrame
    end

    local TabButton = Instance.new("TextButton")
    TabButton.Name = tabName .. "_TabButton"
    TabButton.Size = UDim2.new(1, -10, 0, 30)
    TabButton.BackgroundTransparency = 1
    TabButton.Text = tabName
    TabButton.TextColor3 = currentTheme.TextColor
    TabButton.Font = Enum.Font.SourceSans
    TabButton.TextSize = 16
    TabButton.TextXAlignment = Enum.TextXAlignment.Left
    TabButton.Parent = TabContainer

    local TabContentFrame = Instance.new("Frame")
    TabContentFrame.Name = tabName .. "_TabContent"
    TabContentFrame.Size = UDim2.new(1, 0, 1, 0)
    TabContentFrame.BackgroundTransparency = 1
    TabContentFrame.BorderSizePixel = 0
    TabContentFrame.Parent = TabContentContainer
    TabContentFrame.Visible = false -- Hidden by default

    TabButton.MouseButton1Click:Connect(function()
        for _, tab in pairs(Tabs) do
            tab.Content.Visible = false
            tab.Button.BackgroundColor3 = currentTheme.TabContainer
        end
        TabContentFrame.Visible = true
        TabButton.BackgroundColor3 = currentTheme.ElementBackground -- Highlight active tab
    end)
    Tabs[tabName] = {
        Button = TabButton,
        Content = TabContentFrame
    }

    -- Automatically select the first tab created
    if #Tabs == 1 then
        TabButton.MouseButton1Click:Fire()
    end

    return TabContentFrame
end




-- Section management
function AstroHub:CreateSection(parentTabContent, sectionName)
    if not parentTabContent or not parentTabContent:IsA("Frame") then
        warn("AstroHub: CreateSection requires a valid parent tab content frame.")
        return nil
    end

    local SectionFrame = Instance.new("Frame")
    SectionFrame.Name = sectionName .. "_Section"
    SectionFrame.Size = UDim2.new(1, 0, 0, 50) -- Placeholder size, will adjust with content
    SectionFrame.AutomaticSize = Enum.AutomaticSize.Y -- Automatically adjust height based on content
    SectionFrame.BackgroundColor3 = currentTheme.SectionBackground
    SectionFrame.BorderSizePixel = 0
    SectionFrame.Parent = parentTabContent

    local SectionListLayout = Instance.new("UIListLayout")
    SectionListLayout.FillDirection = Enum.FillDirection.Vertical
    SectionListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    SectionListLayout.Padding = UDim.new(0, 5)
    SectionListLayout.Parent = SectionFrame

    local SectionTitle = Instance.new("TextLabel")
    SectionTitle.Name = "SectionTitle"
    SectionTitle.Size = UDim2.new(1, 0, 0, 25)
    SectionTitle.BackgroundTransparency = 1
    SectionTitle.Text = sectionName
    SectionTitle.TextColor3 = currentTheme.TextColor
    SectionTitle.Font = Enum.Font.SourceSansBold
    SectionTitle.TextSize = 16
    SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
    SectionTitle.Position = UDim2.new(0, 5, 0, 0)
    SectionTitle.Parent = SectionFrame

    -- Add UICorner for rounded corners
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 5) -- Adjust as needed
    UICorner.Parent = SectionFrame

    return SectionFrame
end




-- Function to destroy the entire GUI
function AstroHub:DestroyGUI()
    if MainWindow then
        MainWindow:Destroy()
        MainWindow = nil
        Tabs = {} -- Clear tabs table
        TabContainer = nil
        TabContentContainer = nil
        print("AstroHub: GUI destroyed.")
    else
        warn("AstroHub: No GUI to destroy.")
    end
end




-- Minimize to Icon/logo hub
local isMinimized = false
local originalSize
local originalPosition

function AstroHub:MinimizeGUI()
    if not MainWindow then return end
    local MainFrame = MainWindow:FindFirstChild("MainFrame")
    if not MainFrame then return end

    local tweenService = game:GetService("TweenService")
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    if not isMinimized then
        originalSize = MainFrame.Size
        originalPosition = MainFrame.Position

        -- Minimize to a small icon/logo with tween
        local minimizeGoals = {Size = UDim2.new(0, 50, 0, 50), Position = UDim2.new(0, 10, 0, 10)}
        local minimizeTween = tweenService:Create(MainFrame, tweenInfo, minimizeGoals)
        minimizeTween:Play()

        -- Hide internal elements and show only a logo/icon
        for _, child in ipairs(MainFrame:GetChildren()) do
            if child.Name ~= "TitleBar" then -- Keep title bar for unminimize click
                child.Visible = false
            end
        end
        -- Update title bar to show only logo or a small indicator
        local TitleLabel = MainFrame.TitleBar:FindFirstChild("TitleLabel")
        if TitleLabel then TitleLabel.Text = "" end -- Clear text
        local MinimizeButton = MainFrame.TitleBar:FindFirstChild("MinimizeButton")
        if MinimizeButton then MinimizeButton.Text = "+" end -- Change to maximize icon
        local CloseButton = MainFrame.TitleBar:FindFirstChild("CloseButton")
        if CloseButton then CloseButton.Visible = false end -- Hide close button when minimized

        -- Add a simple logo (placeholder for now)
        local Logo = Instance.new("ImageLabel")
        Logo.Name = "MinimizedLogo"
        Logo.Size = UDim2.new(1, 0, 1, 0)
        Logo.BackgroundTransparency = 1
        Logo.Image = _logoAssetId or "rbxassetid://YOUR_DEFAULT_LOGO_ASSET_ID" -- Use provided logo or a default one
        Logo.Parent = MainFrame

        isMinimized = true
    else
        -- Restore to original size and position with tween
        local restoreGoals = {Size = originalSize, Position = originalPosition}
        local restoreTween = tweenService:Create(MainFrame, tweenInfo, restoreGoals)
        restoreTween:Play()

        -- Show internal elements
        for _, child in ipairs(MainFrame:GetChildren()) do
            child.Visible = true
        end
        -- Restore title bar
        local TitleLabel = MainFrame.TitleBar:FindFirstChild("TitleLabel")
        if TitleLabel then TitleLabel.Text = "AstroHub" end -- Restore original title
        local MinimizeButton = MainFrame.TitleBar:FindFirstChild("MinimizeButton")
        if MinimizeButton then MinimizeButton.Text = "_" end -- Change back to minimize icon
        local CloseButton = MainFrame.TitleBar:FindFirstChild("CloseButton")
        if CloseButton then CloseButton.Visible = true end -- Show close button

        local Logo = MainFrame:FindFirstChild("MinimizedLogo")
        if Logo then Logo:Destroy() end

        isMinimized = false
    end
end

-- Update MinimizeButton click event in CreateWindow
-- (This part needs to be manually inserted into the CreateWindow function or handled carefully)
-- For now, I\"ll add a note to update it.
-- NOTE: The MinimizeButton.MouseButton1Click function in CreateWindow needs to call AstroHub:MinimizeGUI()

-- Example of how to update the MinimizeButton in CreateWindow (conceptual, not executable here)
--[[ In CreateWindow function, replace:
    MinimizeButton.MouseButton1Click:Connect(function()
        warn("Minimize functionality not yet implemented.")
    end)
With:
    MinimizeButton.MouseButton1Click:Connect(function()
        AstroHub:MinimizeGUI()
    end)
]]




-- Function to clear all children from a given UI element (Tab or Section)
function AstroHub:ClearStructure(uiElement)
    if not uiElement then
        warn("AstroHub: ClearStructure requires a valid UI element.")
        return
    end
    for _, child in ipairs(uiElement:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextButton") or child:IsA("TextLabel") or child:IsA("TextBox") or child:IsA("ImageLabel") then
            child:Destroy()
        end
    end
    print("AstroHub: Cleared structure for " .. uiElement.Name)
end




-- Modular (loadstring support - conceptual, as loadstring is often restricted)
-- For better modularity in Roblox, users typically require well-defined APIs
-- to interact with the GUI elements rather than direct loadstring execution.
-- This library aims to provide such APIs.

-- Easy Integration & No Hardcoding
-- The library is designed to be a single script that can be required or loaded.
-- All internal configurations and styling will be managed within the library
-- or through exposed configuration functions, avoiding external hardcoded values.

-- getgenv() support (conceptual, depends on execution environment)
-- If the environment supports `getgenv()`, users can access the library via:
-- `_G.AstroHub = require(path.to.AstroHub)`
-- Or if injected:
-- `getgenv().AstroHub = require(path.to.AstroHub)`
-- The library itself does not directly use getgenv() to avoid assumptions about the environment.

-- Expose AstroHub globally if getgenv() is available (for convenience in some executors)
-- This part should ideally be handled by the user\"s executor script, not the library itself.
-- However, for demonstration purposes or specific use cases, one might add:
--[[
    pcall(function()
        if getgenv() then
            getgenv().AstroHub = AstroHub
        end
    end)
]]




-- UI Elements

-- Toggle
function AstroHub:CreateToggle(parentSection, text, defaultValue, callback)
    if not parentSection or not parentSection:IsA("Frame") then
        warn("AstroHub: CreateToggle requires a valid parent section frame.")
        return nil
    end

    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Name = text .. "_ToggleFrame"
    ToggleFrame.Size = UDim2.new(1, 0, 0, 30)
    ToggleFrame.BackgroundTransparency = 1
    ToggleFrame.Parent = parentSection

    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "ToggleButton"
    ToggleButton.Size = UDim2.new(0, 50, 0, 20)
    ToggleButton.Position = UDim2.new(1, -55, 0, 5)
    ToggleButton.BackgroundColor3 = currentTheme.ToggleOff -- Off color
    ToggleButton.Text = ""
    ToggleButton.Parent = ToggleFrame

    local ToggleUICorner = Instance.new("UICorner")
    ToggleUICorner.CornerRadius = UDim.new(0, 10)
    ToggleUICorner.Parent = ToggleButton

    local ToggleCircle = Instance.new("Frame")
    ToggleCircle.Name = "ToggleCircle"
    ToggleCircle.Size = UDim2.new(0, 18, 0, 18)
    ToggleCircle.Position = UDim2.new(0, 2, 0, 1)
    ToggleCircle.BackgroundColor3 = currentTheme.TextColor
    ToggleCircle.Parent = ToggleButton

    local ToggleCircleUICorner = Instance.new("UICorner")
    ToggleCircleUICorner.CornerRadius = UDim.new(0, 9)
    ToggleCircleUICorner.Parent = ToggleCircle

    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Name = "ToggleLabel"
    ToggleLabel.Size = UDim2.new(1, -60, 1, 0)
    ToggleLabel.Position = UDim2.new(0, 5, 0, 0)
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Text = text
    ToggleLabel.TextColor3 = currentTheme.TextColor
    ToggleLabel.Font = Enum.Font.SourceSans
    ToggleLabel.TextSize = 16
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    ToggleLabel.Parent = ToggleFrame

    local isOn = defaultValue or false

    local function updateToggleVisual()
        if isOn then
            ToggleButton.BackgroundColor3 = currentTheme.ToggleOn -- On color
            ToggleCircle:TweenPosition(UDim2.new(1, -20, 0, 1), "Out", "Quad", 0.2, true)
        else
            ToggleButton.BackgroundColor3 = currentTheme.ToggleOff -- Off color
            ToggleCircle:TweenPosition(UDim2.new(0, 2, 0, 1), "Out", "Quad", 0.2, true)
        end
    end

    updateToggleVisual()

    local element = {
        Instance = ToggleFrame,
        Set = function(newValue)
            isOn = newValue
            updateToggleVisual()
            if callback then
                callback(isOn)
            end
        end,
        Get = function() return isOn end
    }

    ToggleButton.MouseEnter:Connect(function()
        ToggleButton.BackgroundTransparency = 0.1
    end)

    ToggleButton.MouseLeave:Connect(function()
        ToggleButton.BackgroundTransparency = 0
    end)

    ToggleButton.MouseButton1Click:Connect(function()
        element:Set(not isOn)
    end)
    return element
end




-- Button
function AstroHub:CreateButton(parentSection, text, callback)
    if not parentSection or not parentSection:IsA("Frame") then
        warn("AstroHub: CreateButton requires a valid parent section frame.")
        return nil
    end

    local Button = Instance.new("TextButton")
    Button.Name = text .. "_Button"
    Button.Size = UDim2.new(1, -10, 0, 30)
    Button.BackgroundColor3 = currentTheme.ElementBackground
    Button.Text = text
    Button.TextColor3 = currentTheme.TextColor
    Button.Font = Enum.Font.SourceSans
    Button.TextSize = 16
    Button.Parent = parentSection

    local ButtonUICorner = Instance.new("UICorner")
    ButtonUICorner.CornerRadius = UDim.new(0, 5)
    ButtonUICorner.Parent = Button

    Button.MouseEnter:Connect(function()
        Button.BackgroundTransparency = 0.1
    end)

    Button.MouseLeave:Connect(function()
        Button.BackgroundTransparency = 0
    end)

    Button.MouseButton1Click:Connect(function()
        if callback then
            callback()
        end
    end)
    return Button
end




-- Slider
function AstroHub:CreateSlider(parentSection, text, minValue, maxValue, defaultValue, callback)
    if not parentSection or not parentSection:IsA("Frame") then
        warn("AstroHub: CreateSlider requires a valid parent section frame.")
        return nil
    end

    local SliderFrame = Instance.new("Frame")
    SliderFrame.Name = text .. "_SliderFrame"
    SliderFrame.Size = UDim2.new(1, 0, 0, 40)
    SliderFrame.BackgroundTransparency = 1
    SliderFrame.Parent = parentSection

    local SliderLabel = Instance.new("TextLabel")
    SliderLabel.Name = "SliderLabel"
    SliderLabel.Size = UDim2.new(1, -60, 0, 20)
    SliderLabel.Position = UDim2.new(0, 5, 0, 0)
    SliderLabel.BackgroundTransparency = 1
    SliderLabel.Text = text .. ": " .. tostring(defaultValue)
    SliderLabel.TextColor3 = currentTheme.TextColor
    SliderLabel.Font = Enum.Font.SourceSans
    SliderLabel.TextSize = 16
    SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    SliderLabel.Parent = SliderFrame

    local SliderBar = Instance.new("Frame")
    SliderBar.Name = "SliderBar"
    SliderBar.Size = UDim2.new(1, -10, 0, 5)
    SliderBar.Position = UDim2.new(0, 5, 0, 25)
    SliderBar.BackgroundColor3 = currentTheme.Divider
    SliderBar.BorderSizePixel = 0
    SliderBar.Parent = SliderFrame

    local SliderBarUICorner = Instance.new("UICorner")
    SliderBarUICorner.CornerRadius = UDim.new(0, 2.5)
    SliderBarUICorner.Parent = SliderBar

    local SliderFill = Instance.new("Frame")
    SliderFill.Name = "SliderFill"
    SliderFill.Size = UDim2.new(0, 0, 1, 0)
    SliderFill.Position = UDim2.new(0, 0, 0, 0)
    SliderFill.BackgroundColor3 = currentTheme.AccentColor
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderBar

    local SliderFillUICorner = Instance.new("UICorner")
    SliderFillUICorner.CornerRadius = UDim.new(0, 2.5)
    SliderFillUICorner.Parent = SliderFill

    local SliderHandle = Instance.new("ImageLabel")
    SliderHandle.Name = "SliderHandle"
    SliderHandle.Size = UDim2.new(0, 15, 0, 15)
    SliderHandle.Image = "rbxassetid://2769061889" -- Circle image asset ID
    SliderHandle.BackgroundTransparency = 1
    SliderHandle.ZIndex = 2
    SliderHandle.Parent = SliderBar

    local SliderHandleUICorner = Instance.new("UICorner")
    SliderHandleUICorner.CornerRadius = UDim.new(0, 7.5)
    SliderHandleUICorner.Parent = SliderHandle

    local currentValue = defaultValue or minValue
    local dragging = false

    local function updateSliderVisual(value)
        local percentage = (value - minValue) / (maxValue - minValue)
        SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
        SliderHandle.Position = UDim2.new(percentage, -SliderHandle.Size.X.Offset / 2, 0, -5)
        SliderLabel.Text = text .. ": " .. math.floor(value + 0.5) -- Round to nearest integer
    end

    updateSliderVisual(currentValue)

    local element = {
        Instance = SliderFrame,
        Set = function(newValue)
            currentValue = math.clamp(newValue, minValue, maxValue)
            updateSliderVisual(currentValue)
            if callback then
                callback(currentValue)
            end
        end,
        Get = function() return currentValue end
    }

    local function onInputChanged(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local mouseX = input.Position.X - SliderBar.AbsolutePosition.X
            local barWidth = SliderBar.AbsoluteSize.X
            local newPercentage = math.clamp(mouseX / barWidth, 0, 1)
            element:Set(minValue + (maxValue - minValue) * newPercentage)
        end
    end

    SliderHandle.MouseEnter:Connect(function()
        SliderHandle.BackgroundTransparency = 0.1
    end)

    SliderHandle.MouseLeave:Connect(function()
        SliderHandle.BackgroundTransparency = 0
    end)

    SliderBar.MouseEnter:Connect(function()
        SliderBar.BackgroundTransparency = 0.1
    end)

    SliderBar.MouseLeave:Connect(function()
        SliderBar.BackgroundTransparency = 0
    end)

    SliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            onInputChanged(input)
        end
    end)
    SliderBar.InputChanged:Connect(onInputChanged)

    SliderBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    return element
end




-- Dropdown (static options)
function AstroHub:CreateDropdown(parentSection, text, options, callback)
    if not parentSection or not parentSection:IsA("Frame") then
        warn("AstroHub: CreateDropdown requires a valid parent section frame.")
        return nil
    end

    local DropdownFrame = Instance.new("Frame")
    DropdownFrame.Name = text .. "_DropdownFrame"
    DropdownFrame.Size = UDim2.new(1, 0, 0, 30)
    DropdownFrame.BackgroundTransparency = 1
    DropdownFrame.Parent = parentSection

    local DropdownLabel = Instance.new("TextLabel")
    DropdownLabel.Name = "DropdownLabel"
    DropdownLabel.Size = UDim2.new(0.5, 0, 1, 0)
    DropdownLabel.Position = UDim2.new(0, 5, 0, 0)
    DropdownLabel.BackgroundTransparency = 1
    DropdownLabel.Text = text
    DropdownLabel.TextColor3 = currentTheme.TextColor
    DropdownLabel.Font = Enum.Font.SourceSans
    DropdownLabel.TextSize = 16
    DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
    DropdownLabel.Parent = DropdownFrame

    local DropdownButton = Instance.new("TextButton")
    DropdownButton.Name = "DropdownButton"
    DropdownButton.Size = UDim2.new(0.5, -10, 1, 0)
    DropdownButton.Position = UDim2.new(0.5, 5, 0, 0)
    DropdownButton.BackgroundColor3 = currentTheme.ElementBackground
    DropdownButton.Text = "Select Option"
    DropdownButton.TextColor3 = currentTheme.TextColor
    DropdownButton.Font = Enum.Font.SourceSans
    DropdownButton.TextSize = 16
    DropdownButton.Parent = DropdownFrame

    local DropdownButtonUICorner = Instance.new("UICorner")
    DropdownButtonUICorner.CornerRadius = UDim.new(0, 5)
    DropdownButtonUICorner.Parent = DropdownButton

    local DropdownOptionsFrame = Instance.new("Frame")
    DropdownOptionsFrame.Name = "DropdownOptionsFrame"
    DropdownOptionsFrame.Size = UDim2.new(1, 0, 0, 0) -- Height will be set dynamically
    DropdownOptionsFrame.Position = UDim2.new(0, 0, 1, 0)
    DropdownOptionsFrame.BackgroundColor3 = currentTheme.SectionBackground
    DropdownOptionsFrame.BorderSizePixel = 0
    DropdownOptionsFrame.Visible = false
    DropdownOptionsFrame.ZIndex = 3 -- Ensure it\"s above other elements
    DropdownOptionsFrame.Parent = DropdownFrame

    local DropdownOptionsUICorner = Instance.new("UICorner")
    DropdownOptionsUICorner.CornerRadius = UDim.new(0, 5)
    DropdownOptionsUICorner.Parent = DropdownOptionsFrame

    local DropdownListLayout = Instance.new("UIListLayout")
    DropdownListLayout.FillDirection = Enum.FillDirection.Vertical
    DropdownListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    DropdownListLayout.Padding = UDim.new(0, 2)
    DropdownListLayout.Parent = DropdownOptionsFrame

    local ScrollingFrame = Instance.new("ScrollingFrame")
    ScrollingFrame.Name = "ScrollingFrame"
    ScrollingFrame.Size = UDim2.new(1, 0, 1, 0)
    ScrollingFrame.BackgroundTransparency = 1
    ScrollingFrame.BorderSizePixel = 0
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0) -- Will be updated by UIListLayout
    ScrollingFrame.ScrollBarImageColor3 = currentTheme.Divider
    ScrollingFrame.ScrollBarThickness = 6
    ScrollingFrame.Parent = DropdownOptionsFrame

    local currentSelection = nil

    local element = {
        Instance = DropdownFrame,
        Set = function(newValue)
            if table.find(options, newValue) then
                currentSelection = newValue
                DropdownButton.Text = newValue
                if callback then
                    callback(newValue)
                end
            else
                warn("AstroHub: Invalid option for Dropdown.Set: " .. tostring(newValue))
            end
        end,
        Get = function() return currentSelection end
    }

    for i, optionText in ipairs(options) do
        local OptionButton = Instance.new("TextButton")
        OptionButton.Name = optionText .. "_OptionButton"
        OptionButton.Size = UDim2.new(1, 0, 0, 25)
        OptionButton.BackgroundTransparency = 1
        OptionButton.Text = optionText
        OptionButton.TextColor3 = currentTheme.TextColor
        OptionButton.Font = Enum.Font.SourceSans
        OptionButton.TextSize = 14
        OptionButton.TextXAlignment = Enum.TextXAlignment.Left
        OptionButton.TextScaled = true
        OptionButton.Parent = ScrollingFrame

        OptionButton.MouseEnter:Connect(function()
            OptionButton.BackgroundColor3 = currentTheme.DropdownHover
            OptionButton.BackgroundTransparency = 0
        end)

        OptionButton.MouseLeave:Connect(function()
            OptionButton.BackgroundTransparency = 1
        end)

        OptionButton.MouseButton1Click:Connect(function()
            element:Set(optionText)
            DropdownOptionsFrame.Visible = false
        end)
    end

    DropdownButton.MouseEnter:Connect(function()
        DropdownButton.BackgroundTransparency = 0.1
    end)

    DropdownButton.MouseLeave:Connect(function()
        DropdownButton.BackgroundTransparency = 0
    end)

    DropdownButton.MouseButton1Click:Connect(function()
        DropdownOptionsFrame.Visible = not DropdownOptionsFrame.Visible
        if DropdownOptionsFrame.Visible then
            -- Adjust height of options frame based on number of options
            local totalHeight = #options * (DropdownListLayout.AbsoluteContentSize.Y / #options) + DropdownListLayout.Padding.Offset * (#options - 1)
            DropdownOptionsFrame.Size = UDim2.new(1, 0, 0, math.min(totalHeight, 150)) -- Max height 150, then scroll
            ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
        end
    end)
    return element
end




-- Multi-Dropdown (static options)
function AstroHub:CreateMultiDropdown(parentSection, text, options, callback)
    if not parentSection or not parentSection:IsA("Frame") then
        warn("AstroHub: CreateMultiDropdown requires a valid parent section frame.")
        return nil
    end

    local MultiDropdownFrame = Instance.new("Frame")
    MultiDropdownFrame.Name = text .. "_MultiDropdownFrame"
    MultiDropdownFrame.Size = UDim2.new(1, 0, 0, 30)
    MultiDropdownFrame.BackgroundTransparency = 1
    MultiDropdownFrame.Parent = parentSection

    local MultiDropdownLabel = Instance.new("TextLabel")
    MultiDropdownLabel.Name = "MultiDropdownLabel"
    MultiDropdownLabel.Size = UDim2.new(0.5, 0, 1, 0)
    MultiDropdownLabel.Position = UDim2.new(0, 5, 0, 0)
    MultiDropdownLabel.BackgroundTransparency = 1
    MultiDropdownLabel.Text = text
    MultiDropdownLabel.TextColor3 = currentTheme.TextColor
    MultiDropdownLabel.Font = Enum.Font.SourceSans
    MultiDropdownLabel.TextSize = 16
    MultiDropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
    MultiDropdownLabel.Parent = MultiDropdownFrame

    local MultiDropdownButton = Instance.new("TextButton")
    MultiDropdownButton.Name = "MultiDropdownButton"
    MultiDropdownButton.Size = UDim2.new(0.5, -10, 1, 0)
    MultiDropdownButton.Position = UDim2.new(0.5, 5, 0, 0)
    MultiDropdownButton.BackgroundColor3 = currentTheme.ElementBackground
    MultiDropdownButton.Text = "Select Options"
    MultiDropdownButton.TextColor3 = currentTheme.TextColor
    MultiDropdownButton.Font = Enum.Font.SourceSans
    MultiDropdownButton.TextSize = 16
    MultiDropdownButton.Parent = MultiDropdownFrame

    local MultiDropdownButtonUICorner = Instance.new("UICorner")
    MultiDropdownButtonUICorner.CornerRadius = UDim.new(0, 5)
    MultiDropdownButtonUICorner.Parent = MultiDropdownButton

    local MultiDropdownOptionsFrame = Instance.new("Frame")
    MultiDropdownOptionsFrame.Name = "MultiDropdownOptionsFrame"
    MultiDropdownOptionsFrame.Size = UDim2.new(1, 0, 0, 0) -- Height will be set dynamically
    MultiDropdownOptionsFrame.Position = UDim2.new(0, 0, 1, 0)
    MultiDropdownOptionsFrame.BackgroundColor3 = currentTheme.SectionBackground
    MultiDropdownOptionsFrame.BorderSizePixel = 0
    MultiDropdownOptionsFrame.Visible = false
    MultiDropdownOptionsFrame.ZIndex = 3 -- Ensure it\"s above other elements
    MultiDropdownOptionsFrame.Parent = MultiDropdownFrame

    local MultiDropdownOptionsUICorner = Instance.new("UICorner")
    MultiDropdownOptionsUICorner.CornerRadius = UDim.new(0, 5)
    MultiDropdownOptionsUICorner.Parent = MultiDropdownOptionsFrame

    local MultiDropdownListLayout = Instance.new("UIListLayout")
    MultiDropdownListLayout.FillDirection = Enum.FillDirection.Vertical
    MultiDropdownListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    MultiDropdownListLayout.Padding = UDim.new(0, 2)
    MultiDropdownListLayout.Parent = MultiDropdownOptionsFrame

    local ScrollingFrame = Instance.new("ScrollingFrame")
    ScrollingFrame.Name = "ScrollingFrame"
    ScrollingFrame.Size = UDim2.new(1, 0, 1, 0)
    ScrollingFrame.BackgroundTransparency = 1
    ScrollingFrame.BorderSizePixel = 0
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0) -- Will be updated by UIListLayout
    ScrollingFrame.ScrollBarImageColor3 = currentTheme.Divider
    ScrollingFrame.ScrollBarThickness = 6
    ScrollingFrame.Parent = MultiDropdownOptionsFrame

    local selectedOptions = {}

    local function updateButtonText()
        local count = 0
        for _, v in pairs(selectedOptions) do
            if v then count = count + 1 end
        end
        if count == 0 then
            MultiDropdownButton.Text = "Select Options"
        else
            MultiDropdownButton.Text = count .. " selected"
        end
    end

    local element = {
        Instance = MultiDropdownFrame,
        Set = function(newValues)
            -- Clear current selections
            for k in pairs(selectedOptions) do
                selectedOptions[k] = false
            end
            -- Set new selections
            for _, val in ipairs(newValues) do
                if table.find(options, val) then
                    selectedOptions[val] = true
                else
                    warn("AstroHub: Invalid option for MultiDropdown.Set: " .. tostring(val))
                end
            end
            updateButtonText()
            -- Update checkboxes visually
            for _, optionText in ipairs(options) do
                local checkbox = ScrollingFrame:FindFirstChild(optionText .. "_OptionFrame"):FindFirstChild("Checkbox")
                if checkbox then
                    if selectedOptions[optionText] then
                        checkbox.Image = "rbxassetid://2769061889" -- Checkmark image (placeholder)
                        checkbox.ImageColor3 = currentTheme.ToggleOn
                    else
                        checkbox.Image = ""
                        checkbox.ImageColor3 = currentTheme.TextColor
                    end
                end
            end
            if callback then
                local currentSelections = {}
                for k, v in pairs(selectedOptions) do
                    if v then table.insert(currentSelections, k) end
                end
                callback(currentSelections)
            end
        end,
        Get = function() return currentSelections end
    }

    for i, optionText in ipairs(options) do
        local OptionFrame = Instance.new("Frame")
        OptionFrame.Name = optionText .. "_OptionFrame"
        OptionFrame.Size = UDim2.new(1, 0, 0, 25)
        OptionFrame.BackgroundTransparency = 1
        OptionFrame.Parent = ScrollingFrame

        local OptionLabel = Instance.new("TextLabel")
        OptionLabel.Name = "OptionLabel"
        OptionLabel.Size = UDim2.new(1, -30, 1, 0)
        OptionLabel.Position = UDim2.new(0, 0, 0, 0)
        OptionLabel.BackgroundTransparency = 1
        OptionLabel.Text = optionText
        OptionLabel.TextColor3 = currentTheme.TextColor
        OptionLabel.Font = Enum.Font.SourceSans
        OptionLabel.TextSize = 14
        OptionLabel.TextXAlignment = Enum.TextXAlignment.Left
        OptionLabel.TextScaled = true
        OptionLabel.Parent = OptionFrame

        local Checkbox = Instance.new("ImageButton")
        Checkbox.Name = "Checkbox"
        Checkbox.Size = UDim2.new(0, 20, 0, 20)
        Checkbox.Position = UDim2.new(1, -25, 0, 2.5)
        Checkbox.BackgroundColor3 = currentTheme.Divider
        Checkbox.Image = "" -- No image initially
        Checkbox.Parent = OptionFrame

        local CheckboxUICorner = Instance.new("UICorner")
        CheckboxUICorner.CornerRadius = UDim.new(0, 3)
        CheckboxUICorner.Parent = Checkbox

        selectedOptions[optionText] = false

        local function updateCheckboxVisual()
            if selectedOptions[optionText] then
                Checkbox.Image = "rbxassetid://2769061889" -- Checkmark image (placeholder)
                Checkbox.ImageColor3 = currentTheme.ToggleOn
            else
                checkbox.Image = ""
                checkbox.ImageColor3 = currentTheme.TextColor
            end
        end

        updateCheckboxVisual()

        Checkbox.MouseButton1Click:Connect(function()
            selectedOptions[optionText] = not selectedOptions[optionText]
            updateCheckboxVisual()
            updateButtonText()
            if callback then
                local currentSelections = {}
                for k, v in pairs(selectedOptions) do
                    if v then table.insert(currentSelections, k) end
                end
                callback(currentSelections)
            end
        end)

        OptionFrame.MouseEnter:Connect(function()
            OptionFrame.BackgroundColor3 = currentTheme.DropdownHover
            OptionFrame.BackgroundTransparency = 0
        end)

        OptionFrame.MouseLeave:Connect(function()
            OptionFrame.BackgroundTransparency = 1
        end)
    end

    MultiDropdownButton.MouseEnter:Connect(function()
        MultiDropdownButton.BackgroundTransparency = 0.1
    end)

    MultiDropdownButton.MouseLeave:Connect(function()
        MultiDropdownButton.BackgroundTransparency = 0
    end)

    MultiDropdownButton.MouseButton1Click:Connect(function()
        MultiDropdownOptionsFrame.Visible = not MultiDropdownOptionsFrame.Visible
        if MultiDropdownOptionsFrame.Visible then
            local totalHeight = #options * (MultiDropdownListLayout.AbsoluteContentSize.Y / #options) + MultiDropdownListLayout.Padding.Offset * (#options - 1)
            MultiDropdownOptionsFrame.Size = UDim2.new(1, 0, 0, math.min(totalHeight, 150)) -- Max height 150, then scroll
            ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
        end
    end)
    return element
end




-- Input / TextBox
function AstroHub:CreateInput(parentSection, text, defaultValue, callback)
    if not parentSection or not parentSection:IsA("Frame") then
        warn("AstroHub: CreateInput requires a valid parent section frame.")
        return nil
    end

    local InputFrame = Instance.new("Frame")
    InputFrame.Name = text .. "_InputFrame"
    InputFrame.Size = UDim2.new(1, 0, 0, 30)
    InputFrame.BackgroundTransparency = 1
    InputFrame.Parent = parentSection

    local InputLabel = Instance.new("TextLabel")
    InputLabel.Name = "InputLabel"
    InputLabel.Size = UDim2.new(0.3, 0, 1, 0)
    InputLabel.Position = UDim2.new(0, 5, 0, 0)
    InputLabel.BackgroundTransparency = 1
    InputLabel.Text = text
    InputLabel.TextColor3 = currentTheme.TextColor
    InputLabel.Font = Enum.Font.SourceSans
    InputLabel.TextSize = 16
    InputLabel.TextXAlignment = Enum.TextXAlignment.Left
    InputLabel.Parent = InputFrame

    local InputBox = Instance.new("TextBox")
    InputBox.Name = "InputBox"
    InputBox.Size = UDim2.new(0.7, -10, 1, 0)
    InputLabel.TextColor3 = currentTheme.TextColor
    InputBox.BackgroundColor3 = currentTheme.ElementBackground
    InputBox.Text = defaultValue or ""
    InputBox.TextColor3 = currentTheme.TextColor
    InputBox.Font = Enum.Font.SourceSans
    InputBox.TextSize = 16
    InputBox.TextXAlignment = Enum.TextXAlignment.Left
    InputBox.ClearTextOnFocus = false
    InputBox.Parent = InputFrame

    local InputBoxUICorner = Instance.new("UICorner")
    InputBoxUICorner.CornerRadius = UDim.new(0, 5)
    InputBoxUICorner.Parent = InputBox

    local currentValue = defaultValue or ""

    local element = {
        Instance = InputFrame,
        Set = function(newValue)
            currentValue = tostring(newValue)
            InputBox.Text = currentValue
            if callback then
                callback(currentValue)
            end
        end,
        Get = function() return currentValue end
    }

    InputBox.MouseEnter:Connect(function()
        InputBox.BackgroundTransparency = 0.1
    end)

    InputBox.MouseLeave:Connect(function()
        InputBox.BackgroundTransparency = 0
    end)

    InputBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            element:Set(InputBox.Text)
        end
    end)
    return element
end




-- Label
function AstroHub:CreateLabel(parentSection, text, textSize, textColor)
    if not parentSection or not parentSection:IsA("Frame") then
        warn("AstroHub: CreateLabel requires a valid parent section frame.")
        return nil
    end

    local Label = Instance.new("TextLabel")
    Label.Name = text .. "_Label"
    Label.Size = UDim2.new(1, 0, 0, textSize or 20)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = textColor or currentTheme.TextColor
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = textSize or 16
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = parentSection

    return Label
end




-- Divider
function AstroHub:CreateDivider(parentSection)
    if not parentSection or not parentSection:IsA("Frame") then
        warn("AstroHub: CreateDivider requires a valid parent section frame.")
        return nil
    end

    local DividerFrame = Instance.new("Frame")
    DividerFrame.Name = "Divider"
    DividerFrame.Size = UDim2.new(1, -10, 0, 2) -- Thin horizontal line
    DividerFrame.Position = UDim2.new(0, 5, 0, 0)
    DividerFrame.BackgroundColor3 = currentTheme.Divider
    DividerFrame.BorderSizePixel = 0
    DividerFrame.Parent = parentSection

    return DividerFrame
end




-- LinkButton
function AstroHub:CreateLinkButton(parentSection, text, url)
    if not parentSection or not parentSection:IsA("Frame") then
        warn("AstroHub: CreateLinkButton requires a valid parent section frame.")
        return nil
    end

    local LinkButton = Instance.new("TextButton")
    LinkButton.Name = text .. "_LinkButton"
    LinkButton.Size = UDim2.new(1, -10, 0, 25)
    LinkButton.BackgroundColor3 = currentTheme.ElementBackground
    LinkButton.BackgroundTransparency = 1
    LinkButton.Text = text
    LinkButton.TextColor3 = currentTheme.AccentColor -- Link color
    LinkButton.Font = Enum.Font.SourceSans
    LinkButton.TextSize = 16
    LinkButton.TextXAlignment = Enum.TextXAlignment.Left
    LinkButton.Parent = parentSection

    LinkButton.MouseButton1Click:Connect(function()
        if url then
            -- This will only work in certain Roblox environments (e.g., in-game browser for some games)
            -- For most exploits, this would require a specific function provided by the exploit.
            -- Example for a hypothetical exploit function:
            -- game:GetService("CoreGui").AstroHubBrowser:Open(url)
            warn("AstroHub: Attempting to open URL: " .. url .. ". Note: This functionality depends on the Roblox environment and executor capabilities.")
        end
    end)

    LinkButton.MouseEnter:Connect(function()
        LinkButton.BackgroundTransparency = 0.1
    end)

    LinkButton.MouseLeave:Connect(function()
        LinkButton.BackgroundTransparency = 0
    end)

    return LinkButton
end




-- Tooltip / Info
function AstroHub:CreateTooltip(targetElement, tooltipText)
    if not targetElement then
        warn("AstroHub: CreateTooltip requires a valid target element.")
        return nil
    end

    local TooltipFrame = Instance.new("Frame")
    TooltipFrame.Name = "TooltipFrame"
    TooltipFrame.Size = UDim2.new(0, 150, 0, 30) -- Default size, will adjust
    TooltipFrame.BackgroundTransparency = 0.1
    TooltipFrame.BackgroundColor3 = currentTheme.NotificationBackground
    TooltipFrame.BorderSizePixel = 0
    TooltipFrame.Visible = false
    TooltipFrame.ZIndex = 10 -- Ensure it\"s on top of most UI
    TooltipFrame.Parent = targetElement.Parent.Parent -- Parent to the main frame to avoid clipping

    local TooltipLabel = Instance.new("TextLabel")
    TooltipLabel.Name = "TooltipLabel"
    TooltipLabel.Size = UDim2.new(1, -10, 1, -10)
    TooltipLabel.Position = UDim2.new(0, 5, 0, 5)
    TooltipLabel.BackgroundTransparency = 1
    TooltipLabel.Text = tooltipText
    TooltipLabel.TextColor3 = currentTheme.NotificationText
    TooltipLabel.Font = Enum.Font.SourceSans
    TooltipLabel.TextSize = 14
    TooltipLabel.TextWrapped = true
    TooltipLabel.TextXAlignment = Enum.TextXAlignment.Center
    TooltipLabel.TextYAlignment = Enum.TextYAlignment.Center
    TooltipLabel.Parent = TooltipFrame

    local TooltipUICorner = Instance.new("UICorner")
    TooltipUICorner.CornerRadius = UDim.new(0, 5)
    TooltipUICorner.Parent = TooltipFrame

    targetElement.MouseEnter:Connect(function()
        TooltipFrame.Visible = true
        -- Position tooltip relative to mouse cursor
        local mouse = game.Players.LocalPlayer:GetMouse()
        TooltipFrame.Position = UDim2.new(0, mouse.X + 10, 0, mouse.Y + 10)
        -- Adjust size based on text content
        local textSize = game:GetService("TextService"):GetTextSize(tooltipText, TooltipLabel.TextSize, TooltipLabel.Font, Vector2.new(TooltipFrame.Size.X.Offset, 1000))
        TooltipFrame.Size = UDim2.new(0, textSize.X + 10, 0, textSize.Y + 10)
    end)

    targetElement.MouseLeave:Connect(function()
        TooltipFrame.Visible = false
    end)

    return TooltipFrame
end




-- Textbox with Copy
function AstroHub:CreateTextboxWithCopy(parentSection, text, defaultValue)
    if not parentSection or not parentSection:IsA("Frame") then
        warn("AstroHub: CreateTextboxWithCopy requires a valid parent section frame.")
        return nil
    end

    local TextboxCopyFrame = Instance.new("Frame")
    TextboxCopyFrame.Name = text .. "_TextboxCopyFrame"
    TextboxCopyFrame.Size = UDim2.new(1, 0, 0, 30)
    TextboxCopyFrame.BackgroundTransparency = 1
    TextboxCopyFrame.Parent = parentSection

    local Textbox = Instance.new("TextBox")
    Textbox.Name = "Textbox"
    Textbox.Size = UDim2.new(0.7, -10, 1, 0)
    Textbox.Position = UDim2.new(0, 5, 0, 0)
    Textbox.BackgroundColor3 = currentTheme.ElementBackground
    Textbox.Text = defaultValue or ""
    Textbox.TextColor3 = currentTheme.TextColor
    Textbox.Font = Enum.Font.SourceSans
    Textbox.TextSize = 16
    Textbox.TextXAlignment = Enum.TextXAlignment.Left
    Textbox.ClearTextOnFocus = false
    Textbox.Parent = TextboxCopyFrame

    local TextboxUICorner = Instance.new("UICorner")
    TextboxUICorner.CornerRadius = UDim.new(0, 5)
    TextboxUICorner.Parent = Textbox

    local CopyButton = Instance.new("TextButton")
    CopyButton.Name = "CopyButton"
    CopyButton.Size = UDim2.new(0.3, -10, 1, 0)
    CopyButton.Position = UDim2.new(0.7, 5, 0, 0)
    CopyButton.BackgroundColor3 = currentTheme.AccentColor
    CopyButton.Text = "Copy"
    CopyButton.TextColor3 = currentTheme.TextColor
    CopyButton.Font = Enum.Font.SourceSansBold
    CopyButton.TextSize = 16
    CopyButton.Parent = TextboxCopyFrame

    local CopyButtonUICorner = Instance.new("UICorner")
    CopyButtonUICorner.CornerRadius = UDim.new(0, 5)
    CopyButtonUICorner.Parent = CopyButton

    Textbox.MouseEnter:Connect(function()
        Textbox.BackgroundTransparency = 0.1
    end)

    Textbox.MouseLeave:Connect(function()
        Textbox.BackgroundTransparency = 0
    end)

    local element = {
        Instance = TextboxCopyFrame,
        Set = function(newValue)
            Textbox.Text = tostring(newValue)
        end,
        Get = function() return Textbox.Text end
    }

    CopyButton.MouseEnter:Connect(function()
        CopyButton.BackgroundTransparency = 0.1
    end)

    CopyButton.MouseLeave:Connect(function()
        CopyButton.BackgroundTransparency = 0
    end)

    CopyButton.MouseButton1Click:Connect(function()
        pcall(function()
            setclipboard(element:Get())
            warn("AstroHub: Copied to clipboard: " .. element:Get())
        end)
    end)
    return element
end




-- Progress Bar
function AstroHub:CreateProgressBar(parentSection, text, initialPercentage)
    if not parentSection or not parentSection:IsA("Frame") then
        warn("AstroHub: CreateProgressBar requires a valid parent section frame.")
        return nil
    end

    local ProgressBarFrame = Instance.new("Frame")
    ProgressBarFrame.Name = text .. "_ProgressBarFrame"
    ProgressBarFrame.Size = UDim2.new(1, 0, 0, 30)
    ProgressBarFrame.BackgroundTransparency = 1
    ProgressBarFrame.Parent = parentSection

    local ProgressBarLabel = Instance.new("TextLabel")
    ProgressBarLabel.Name = "ProgressBarLabel"
    ProgressBarLabel.Size = UDim2.new(1, -10, 0, 20)
    ProgressBarLabel.Position = UDim2.new(0, 5, 0, 0)
    ProgressBarLabel.BackgroundTransparency = 1
    ProgressBarLabel.Text = text .. ": " .. tostring(initialPercentage or 0) .. "%"
    ProgressBarLabel.TextColor3 = currentTheme.TextColor
    ProgressBarLabel.Font = Enum.Font.SourceSans
    ProgressBarLabel.TextSize = 16
    ProgressBarLabel.TextXAlignment = Enum.TextXAlignment.Left
    ProgressBarLabel.Parent = ProgressBarFrame

    local ProgressBarBackground = Instance.new("Frame")
    ProgressBarBackground.Name = "ProgressBarBackground"
    ProgressBarBackground.Size = UDim2.new(1, -10, 0, 5)
    ProgressBarBackground.Position = UDim2.new(0, 5, 0, 25)
    ProgressBarBackground.BackgroundColor3 = currentTheme.Divider
    ProgressBarBackground.BorderSizePixel = 0
    ProgressBarBackground.Parent = ProgressBarFrame

    local ProgressBarBackgroundUICorner = Instance.new("UICorner")
    ProgressBarBackgroundUICorner.CornerRadius = UDim.new(0, 2.5)
    ProgressBarBackgroundUICorner.Parent = ProgressBarBackground

    local ProgressBarFill = Instance.new("Frame")
    ProgressBarFill.Name = "ProgressBarFill"
    ProgressBarFill.Size = UDim2.new(initialPercentage / 100, 0, 1, 0)
    ProgressBarFill.Position = UDim2.new(0, 0, 0, 0)
    ProgressBarFill.BackgroundColor3 = currentTheme.AccentColor
    ProgressBarFill.BorderSizePixel = 0
    ProgressBarFill.Parent = ProgressBarBackground

    local ProgressBarFillUICorner = Instance.new("UICorner")
    ProgressBarFillUICorner.CornerRadius = UDim.new(0, 2.5)
    ProgressBarFillUICorner.Parent = ProgressBarFill

    ProgressBarBackground.MouseEnter:Connect(function()
        ProgressBarBackground.BackgroundTransparency = 0.1
    end)

    ProgressBarBackground.MouseLeave:Connect(function()
        ProgressBarBackground.BackgroundTransparency = 0
    end)

    ProgressBarFill.MouseEnter:Connect(function()
        ProgressBarFill.BackgroundTransparency = 0.1
    end)

    ProgressBarFill.MouseLeave:Connect(function()
        ProgressBarFill.BackgroundTransparency = 0
    end)

    local currentPercentage = initialPercentage or 0

    local element = {
        Instance = ProgressBarFrame,
        Set = function(percentage)
            currentPercentage = math.clamp(percentage, 0, 100)
            ProgressBarFill:TweenSize(UDim2.new(currentPercentage / 100, 0, 1, 0), "Out", "Quad", 0.2, true)
            ProgressBarLabel.Text = text .. ": " .. tostring(math.floor(currentPercentage + 0.5)) .. "%"
        end,
        Get = function() return currentPercentage end
    }

    element:Set(currentPercentage)

    return element
end




-- Player List Dropdown (auto-refreshing via Players:GetPlayers())
function AstroHub:CreatePlayerListDropdown(parentSection, text, callback)
    if not parentSection or not parentSection:IsA("Frame") then
        warn("AstroHub: CreatePlayerListDropdown requires a valid parent section frame.")
        return nil
    end

    local PlayerListDropdownFrame = Instance.new("Frame")
    PlayerListDropdownFrame.Name = text .. "_PlayerListDropdownFrame"
    PlayerListDropdownFrame.Size = UDim2.new(1, 0, 0, 30)
    PlayerListDropdownFrame.BackgroundTransparency = 1
    PlayerListDropdownFrame.Parent = parentSection

    local PlayerListDropdownLabel = Instance.new("TextLabel")
    PlayerListDropdownLabel.Name = "PlayerListDropdownLabel"
    PlayerListDropdownLabel.Size = UDim2.new(0.5, 0, 1, 0)
    PlayerListDropdownLabel.Position = UDim2.new(0, 5, 0, 0)
    PlayerListDropdownLabel.BackgroundTransparency = 1
    PlayerListDropdownLabel.Text = text
    PlayerListDropdownLabel.TextColor3 = currentTheme.TextColor
    PlayerListDropdownLabel.Font = Enum.Font.SourceSans
    PlayerListDropdownLabel.TextSize = 16
    PlayerListDropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
    PlayerListDropdownLabel.Parent = PlayerListDropdownFrame

    local PlayerListDropdownButton = Instance.new("TextButton")
    PlayerListDropdownButton.Name = "PlayerListDropdownButton"
    PlayerListDropdownButton.Size = UDim2.new(0.5, -10, 1, 0)
    PlayerListDropdownButton.BackgroundColor3 = currentTheme.ElementBackground
    PlayerListDropdownButton.Text = "Select Player"
    PlayerListDropdownButton.TextColor3 = currentTheme.TextColor
    PlayerListDropdownButton.Font = Enum.Font.SourceSans
    PlayerListDropdownButton.TextSize = 16
    PlayerListDropdownButton.Parent = PlayerListDropdownFrame

    local PlayerListDropdownButtonUICorner = Instance.new("UICorner")
    PlayerListDropdownButtonUICorner.CornerRadius = UDim.new(0, 5)
    PlayerListDropdownButtonUICorner.Parent = PlayerListDropdownButton

    local PlayerListDropdownOptionsFrame = Instance.new("Frame")
    PlayerListDropdownOptionsFrame.Name = "PlayerListDropdownOptionsFrame"
    PlayerListDropdownOptionsFrame.Size = UDim2.new(1, 0, 0, 0) -- Height will be set dynamically
    PlayerListDropdownOptionsFrame.Position = UDim2.new(0, 0, 1, 0)
    PlayerListDropdownOptionsFrame.BackgroundColor3 = currentTheme.SectionBackground
    PlayerListDropdownOptionsFrame.BorderSizePixel = 0
    PlayerListDropdownOptionsFrame.Visible = false
    PlayerListDropdownOptionsFrame.ZIndex = 3 -- Ensure it\"s above other elements
    PlayerListDropdownOptionsFrame.Parent = PlayerListDropdownFrame

    local PlayerListDropdownOptionsUICorner = Instance.new("UICorner")
    PlayerListDropdownOptionsUICorner.CornerRadius = UDim.new(0, 5)
    PlayerListDropdownOptionsUICorner.Parent = PlayerListDropdownOptionsFrame

    local PlayerListDropdownListLayout = Instance.new("UIListLayout")
    PlayerListDropdownListLayout.FillDirection = Enum.FillDirection.Vertical
    PlayerListDropdownListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    PlayerListDropdownListLayout.Padding = UDim.new(0, 2)
    PlayerListDropdownListLayout.Parent = PlayerListDropdownOptionsFrame

    local ScrollingFrame = Instance.new("ScrollingFrame")
    ScrollingFrame.Name = "ScrollingFrame"
    ScrollingFrame.Size = UDim2.new(1, 0, 1, 0)
    ScrollingFrame.BackgroundTransparency = 1
    ScrollingFrame.BorderSizePixel = 0
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0) -- Will be updated by UIListLayout
    ScrollingFrame.ScrollBarImageColor3 = currentTheme.Divider
    ScrollingFrame.ScrollBarThickness = 6
    ScrollingFrame.Parent = PlayerListDropdownOptionsFrame

    local function updatePlayerList()
        -- Clear existing options
        for _, child in ipairs(ScrollingFrame:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end

        local players = game.Players:GetPlayers()
        local totalHeight = 0
        for _, player in ipairs(players) do
            local OptionButton = Instance.new("TextButton")
            OptionButton.Name = player.Name .. "_OptionButton"
            OptionButton.Size = UDim2.new(1, 0, 0, 25)
            OptionButton.BackgroundTransparency = 1
            OptionButton.Text = player.Name
            OptionButton.TextColor3 = currentTheme.TextColor
            OptionButton.Font = Enum.Font.SourceSans
            OptionButton.TextSize = 14
            OptionButton.TextXAlignment = Enum.TextXAlignment.Left
            OptionButton.TextScaled = true
            OptionButton.Parent = ScrollingFrame

            OptionButton.MouseEnter:Connect(function()
                OptionButton.BackgroundColor3 = Color3.new(0.25, 0.25, 0.25)
                OptionButton.BackgroundTransparency = 0
            end)

            OptionButton.MouseLeave:Connect(function()
                OptionButton.BackgroundTransparency = 1
            end)

            OptionButton.MouseButton1Click:Connect(function()
                PlayerListDropdownButton.Text = player.Name
                PlayerListDropdownOptionsFrame.Visible = false
                if callback then
                    callback(player)
                end
            end)
            totalHeight = totalHeight + OptionButton.Size.Y.Offset + PlayerListDropdownListLayout.Padding.Offset
        end
        ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
        PlayerListDropdownOptionsFrame.Size = UDim2.new(1, 0, 0, math.min(totalHeight, 150)) -- Max height 150, then scroll
    end

    -- Initial player list update
    updatePlayerList()

    -- Auto-refreshing via Players:GetPlayers()
    game.Players.PlayerAdded:Connect(updatePlayerList)
    game.Players.PlayerRemoving:Connect(updatePlayerList)

    PlayerListDropdownButton.MouseButton1Click:Connect(function()
        PlayerListDropdownOptionsFrame.Visible = not PlayerListDropdownOptionsFrame.Visible
        if PlayerListDropdownOptionsFrame.Visible then
            updatePlayerList() -- Refresh list when opened
        end
    end)

    return PlayerListDropdownFrame
end




-- Flag System
local Flags = {}

function AstroHub:SetFlag(flagName, value)
    Flags[flagName] = value
    print("AstroHub: Flag \"" .. flagName .. "\" set to " .. tostring(value))
end

function AstroHub:GetFlag(flagName)
    return Flags[flagName]
end




-- Callback System
local Callbacks = {}

function AstroHub:RegisterCallback(eventName, callbackFunction)
    if not Callbacks[eventName] then
        Callbacks[eventName] = {}
    end
    table.insert(Callbacks[eventName], callbackFunction)
    print("AstroHub: Registered callback for event: " .. eventName)
}

function AstroHub:TriggerCallback(eventName, ...)
    if Callbacks[eventName] then
        for _, callbackFunction in ipairs(Callbacks[eventName]) do
            pcall(callbackFunction, ...)
        end
        print("AstroHub: Triggered callback for event: " .. eventName)
    else
        warn("AstroHub: No callbacks registered for event: " .. eventName)
    end
end




-- Notification Popup
function AstroHub:CreateNotification(title, message, duration)
    local PlayerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")

    local NotificationFrame = Instance.new("Frame")
    NotificationFrame.Name = "AstroHub_Notification"
    NotificationFrame.Size = UDim2.new(0, 250, 0, 80)
    NotificationFrame.Position = UDim2.new(1, -260, 1, -90) -- Bottom right corner
    NotificationFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    NotificationFrame.BorderSizePixel = 0
    NotificationFrame.ZIndex = 100 -- Ensure it\"s on top
    NotificationFrame.Parent = PlayerGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = NotificationFrame

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "TitleLabel"
    TitleLabel.Size = UDim2.new(1, -10, 0, 20)
    TitleLabel.Position = UDim2.new(0, 5, 0, 5)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title or "Notification"
    TitleLabel.TextColor3 = Color3.new(1, 1, 1)
    TitleLabel.Font = Enum.Font.SourceSansBold
    TitleLabel.TextSize = 18
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = NotificationFrame

    local MessageLabel = Instance.new("TextLabel")
    MessageLabel.Name = "MessageLabel"
    MessageLabel.Size = UDim2.new(1, -10, 0, 40)
    MessageLabel.Position = UDim2.new(0, 5, 0, 30)
    MessageLabel.BackgroundTransparency = 1
    MessageLabel.Text = message or ""
    MessageLabel.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    MessageLabel.Font = Enum.Font.SourceSans
    MessageLabel.TextSize = 14
    MessageLabel.TextWrapped = true
    MessageLabel.TextXAlignment = Enum.TextXAlignment.Left
    MessageLabel.TextYAlignment = Enum.TextYAlignment.Top
    MessageLabel.Parent = NotificationFrame

    -- Fade out and destroy after duration
    local tweenService = game:GetService("TweenService")
    local info = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, duration or 3)
    local goals = {BackgroundTransparency = 1, TextTransparency = 1}

    local fadeTween = tweenService:Create(NotificationFrame, info, goals)
    fadeTween:Play()
    fadeTween.Completed:Connect(function()
        NotificationFrame:Destroy()
    end)

    -- Initial slide-in animation
    NotificationFrame.Position = UDim2.new(1, -260, 1, -90)
    local slideInInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local slideInGoals = {Position = UDim2.new(1, -260, 1, -90)}
    local slideInTween = tweenService:Create(NotificationFrame, slideInInfo, slideInGoals)
    slideInTween:Play()
end




-- Toggle Group (Radio Style)
function AstroHub:CreateToggleGroup(parentSection, text, options, defaultSelection, callback)
    if not parentSection or not parentSection:IsA("Frame") then
        warn("AstroHub: CreateToggleGroup requires a valid parent section frame.")
        return nil
    end

    local ToggleGroupFrame = Instance.new("Frame")
    ToggleGroupFrame.Name = text .. "_ToggleGroupFrame"
    ToggleGroupFrame.Size = UDim2.new(1, 0, 0, 30 + (#options * 25)) -- Base height + height per option
    ToggleGroupFrame.AutomaticSize = Enum.AutomaticSize.Y
    ToggleGroupFrame.BackgroundTransparency = 1
    ToggleGroupFrame.Parent = parentSection

    local GroupLabel = Instance.new("TextLabel")
    GroupLabel.Name = "GroupLabel"
    GroupLabel.Size = UDim2.new(1, 0, 0, 20)
    GroupLabel.Position = UDim2.new(0, 5, 0, 0)
    GroupLabel.BackgroundTransparency = 1
    GroupLabel.Text = text
    GroupLabel.TextColor3 = Color3.new(1, 1, 1)
    GroupLabel.Font = Enum.Font.SourceSansBold
    GroupLabel.TextSize = 16
    GroupLabel.TextXAlignment = Enum.TextXAlignment.Left
    GroupLabel.Parent = ToggleGroupFrame

    local OptionsContainer = Instance.new("Frame")
    OptionsContainer.Name = "OptionsContainer"
    OptionsContainer.Size = UDim2.new(1, 0, 1, -20)
    OptionsContainer.Position = UDim2.new(0, 0, 0, 20)
    OptionsContainer.BackgroundTransparency = 1
    OptionsContainer.Parent = ToggleGroupFrame

    local OptionsListLayout = Instance.new("UIListLayout")
    OptionsListLayout.FillDirection = Enum.FillDirection.Vertical
    OptionsListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    OptionsListLayout.Padding = UDim.new(0, 5)
    OptionsListLayout.Parent = OptionsContainer

    local currentSelection = defaultSelection or options[1]
    local radioButtons = {}

    local function updateSelection(selectedOption)
        currentSelection = selectedOption
        for optionName, button in pairs(radioButtons) do
            if optionName == selectedOption then
                button.Image = "rbxassetid://2769061889" -- Filled circle (placeholder)
            else
                button.Image = "rbxassetid://" -- Empty circle (placeholder)
            end
        end
        if callback then
            callback(currentSelection)
        end
    end

    for _, optionText in ipairs(options) do
        local OptionFrame = Instance.new("Frame")
        OptionFrame.Name = optionText .. "_OptionFrame"
        OptionFrame.Size = UDim2.new(1, 0, 0, 20)
        OptionFrame.BackgroundTransparency = 1
        OptionFrame.Parent = OptionsContainer

        local RadioButton = Instance.new("ImageButton")
        RadioButton.Name = "RadioButton"
        RadioButton.Size = UDim2.new(0, 15, 0, 15)
        RadioButton.Position = UDim2.new(0, 5, 0, 2.5)
        RadioButton.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
        RadioButton.BackgroundTransparency = 1
        RadioButton.Image = "rbxassetid://" -- Empty circle (placeholder)
        RadioButton.Parent = OptionFrame

        local RadioButtonUICorner = Instance.new("UICorner")
        RadioButtonUICorner.CornerRadius = UDim.new(0, 7.5) -- Makes it a circle
        RadioButtonUICorner.Parent = RadioButton

        local OptionLabel = Instance.new("TextLabel")
        OptionLabel.Name = "OptionLabel"
        OptionLabel.Size = UDim2.new(1, -25, 1, 0)
        OptionLabel.Position = UDim2.new(0, 25, 0, 0)
        OptionLabel.BackgroundTransparency = 1
        OptionLabel.Text = optionText
        OptionLabel.TextColor3 = Color3.new(1, 1, 1)
        OptionLabel.Font = Enum.Font.SourceSans
        OptionLabel.TextSize = 14
        OptionLabel.TextXAlignment = Enum.TextXAlignment.Left
        OptionLabel.Parent = OptionFrame

        radioButtons[optionText] = RadioButton

        RadioButton.MouseButton1Click:Connect(function()
            updateSelection(optionText)
        end)
    end

    updateSelection(currentSelection)

    return ToggleGroupFrame
end




-- Search Bar (for tabs/elements)
function AstroHub:CreateSearchBar(parentSection, placeholderText, callback)
    if not parentSection or not parentSection:IsA("Frame") then
        warn("AstroHub: CreateSearchBar requires a valid parent section frame.")
        return nil
    end

    local SearchFrame = Instance.new("Frame")
    SearchFrame.Name = "SearchBarFrame"
    SearchFrame.Size = UDim2.new(1, 0, 0, 30)
    SearchFrame.BackgroundTransparency = 1
    SearchFrame.Parent = parentSection

    local SearchBox = Instance.new("TextBox")
    SearchBox.Name = "SearchBox"
    SearchBox.Size = UDim2.new(1, -10, 1, 0)
    SearchBox.Position = UDim2.new(0, 5, 0, 0)
    SearchBox.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    SearchBox.Text = placeholderText or "Search..."
    SearchBox.TextColor3 = Color3.new(0.7, 0.7, 0.7)
    SearchBox.Font = Enum.Font.SourceSans
    SearchBox.TextSize = 16
    SearchBox.TextXAlignment = Enum.TextXAlignment.Left
    SearchBox.ClearTextOnFocus = true
    SearchBox.Parent = SearchFrame

    local SearchBoxUICorner = Instance.new("UICorner")
    SearchBoxUICorner.CornerRadius = UDim.new(0, 5)
    SearchBoxUICorner.Parent = SearchBox

    SearchBox.Changed:Connect(function(property)
        if property == "Text" then
            if callback then
                callback(SearchBox.Text)
            end
        end
    end)

    return SearchFrame
end




-- Loading Overlay (ex: spinner/loading frame)
function AstroHub:CreateLoadingOverlay(message)
    local PlayerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")

    local LoadingFrame = Instance.new("Frame")
    LoadingFrame.Name = "AstroHub_LoadingOverlay"
    LoadingFrame.Size = UDim2.new(1, 0, 1, 0)
    LoadingFrame.BackgroundTransparency = 0.7
    LoadingFrame.BackgroundColor3 = Color3.new(0, 0, 0)
    LoadingFrame.ZIndex = 1000 -- Ensure it\"s on top of everything
    LoadingFrame.Parent = PlayerGui

    local LoadingText = Instance.new("TextLabel")
    LoadingText.Name = "LoadingText"
    LoadingText.Size = UDim2.new(1, 0, 0, 30)
    LoadingText.Position = UDim2.new(0, 0, 0.5, -15)
    LoadingText.BackgroundTransparency = 1
    LoadingText.Text = message or "Loading..."
    LoadingText.TextColor3 = Color3.new(1, 1, 1)
    LoadingText.Font = Enum.Font.SourceSansBold
    LoadingText.TextSize = 24
    LoadingText.TextXAlignment = Enum.TextXAlignment.Center
    LoadingText.Parent = LoadingFrame

    -- Simple spinner (can be replaced with an ImageLabel for a more complex spinner animation)
    local Spinner = Instance.new("Frame")
    Spinner.Name = "Spinner"
    Spinner.Size = UDim2.new(0, 30, 0, 30)
    Spinner.Position = UDim2.new(0.5, -15, 0.5, -50)
    Spinner.BackgroundColor3 = Color3.new(0.2, 0.6, 0.8)
    Spinner.BorderSizePixel = 0
    Spinner.Parent = LoadingFrame

    local SpinnerUICorner = Instance.new("UICorner")
    SpinnerUICorner.CornerRadius = UDim.new(0, 15)
    SpinnerUICorner.Parent = Spinner

    -- Basic rotation animation for the spinner
    local tweenService = game:GetService("TweenService")
    local rotationInfo = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1, true, 0)
    local rotationGoals = {Rotation = 360}
    local rotationTween = tweenService:Create(Spinner, rotationInfo, rotationGoals)
    rotationTween:Play()

    local function hideLoadingOverlay()
        LoadingFrame:Destroy()
    end

    return LoadingFrame, hideLoadingOverlay
end




-- Hotkey to Open/Close GUI
local UserInputService = game:GetService("UserInputService")
local isGuiVisible = true

function AstroHub:ToggleVisibility()
    if MainWindow then
        isGuiVisible = not isGuiVisible
        MainWindow.Enabled = isGuiVisible
        print("AstroHub: GUI visibility toggled to " .. tostring(isGuiVisible))
    else
        warn("AstroHub: No GUI window to toggle visibility.")
    end
end

function AstroHub:SetHotkey(keyCode, callback)
    UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
        if not gameProcessedEvent and input.KeyCode == keyCode then
            if callback then
                callback()
            else
                AstroHub:ToggleVisibility()
            end
        end
    end)
    print("AstroHub: Hotkey set for " .. tostring(keyCode.Name))
end




-- Element Visibility (:Hide(), :Show())
-- This functionality will be directly on the UI elements returned by the creation functions.
-- For example, if AstroHub:CreateToggle returns `toggleElement`,
-- `toggleElement.Visible = false` would hide it.
-- To provide a more consistent API, we can wrap this in helper functions.

function AstroHub:HideElement(uiElement)
    if uiElement and uiElement:IsA("GuiObject") then
        uiElement.Visible = false
        print("AstroHub: Hidden element " .. uiElement.Name)
    else
        warn("AstroHub: Invalid UI element provided to HideElement.")
    end
end

function AstroHub:ShowElement(uiElement)
    if uiElement and uiElement:IsA("GuiObject") then
        uiElement.Visible = true
        print("AstroHub: Shown element " .. uiElement.Name)
    else
        warn("AstroHub: Invalid UI element provided to ShowElement.")
    end
end




-- Section Collapse/Expand
function AstroHub:CreateCollapsibleSection(parentTabContent, sectionName)
    if not parentTabContent or not parentTabContent:IsA("Frame") then
        warn("AstroHub: CreateCollapsibleSection requires a valid parent tab content frame.")
        return nil
    end

    local SectionFrame = Instance.new("Frame")
    SectionFrame.Name = sectionName .. "_CollapsibleSection"
    SectionFrame.Size = UDim2.new(1, 0, 0, 30) -- Initial size for header
    SectionFrame.AutomaticSize = Enum.AutomaticSize.Y -- Automatically adjust height
    SectionFrame.BackgroundTransparency = 1
    SectionFrame.Parent = parentTabContent

    local HeaderFrame = Instance.new("TextButton")
    HeaderFrame.Name = "HeaderFrame"
    HeaderFrame.Size = UDim2.new(1, 0, 0, 25)
    HeaderFrame.BackgroundColor3 = Color3.new(0.18, 0.18, 0.18)
    HeaderFrame.Text = sectionName .. " [V]"
    HeaderFrame.TextColor3 = Color3.new(1, 1, 1)
    HeaderFrame.Font = Enum.Font.SourceSansBold
    HeaderFrame.TextSize = 16
    HeaderFrame.TextXAlignment = Enum.TextXAlignment.Left
    HeaderFrame.Parent = SectionFrame

    local HeaderUICorner = Instance.new("UICorner")
    HeaderUICorner.CornerRadius = UDim.new(0, 5)
    HeaderUICorner.Parent = HeaderFrame

    local ContentFrame = Instance.new("Frame")
    ContentFrame.Name = "ContentFrame"
    ContentFrame.Size = UDim2.new(1, 0, 0, 0) -- Starts collapsed
    ContentFrame.AutomaticSize = Enum.AutomaticSize.Y
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Parent = SectionFrame
    ContentFrame.Visible = false

    local ContentListLayout = Instance.new("UIListLayout")
    ContentListLayout.FillDirection = Enum.FillDirection.Vertical
    ContentListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ContentListLayout.Padding = UDim.new(0, 5)
    ContentListLayout.Parent = ContentFrame

    local isCollapsed = true

    HeaderFrame.MouseButton1Click:Connect(function()
        isCollapsed = not isCollapsed
        ContentFrame.Visible = not isCollapsed
        if isCollapsed then
            HeaderFrame.Text = sectionName .. " [V]"
            ContentFrame.Size = UDim2.new(1, 0, 0, 0)
        else
            HeaderFrame.Text = sectionName .. " [^]"
            ContentFrame.Size = UDim2.new(1, 0, 0, ContentListLayout.AbsoluteContentSize.Y)
        end
    end)

    return ContentFrame
end




-- Live Update (:Set(), :Get())
-- This requires each UI element to have a way to store and retrieve its value.
-- We will modify the creation functions to return a table with Set and Get methods.

-- Generic Set and Get functions (will be implemented within each element\"s creation function)
-- Example usage: element.Set(newValue), element.Get()

-- Helper to generate unique IDs for elements if needed
local elementCounter = 0
local function generateElementId()
    elementCounter = elementCounter + 1
    return "AstroHubElement_" .. elementCounter
end

-- Modifications to existing elements will be done in the next steps.
-- For now, adding placeholder for the concept.

-- Example of how an element\"s creation function might be modified:
-- function AstroHub:CreateToggle(parentSection, text, defaultValue, callback)
--     -- ... existing code ...
--     local value = defaultValue or false
--     local element = {
--         Instance = ToggleFrame,
--         Set = function(newValue)
--             value = newValue
--             updateToggleVisual()
--             if callback then
--                 callback(value)
--             end
--         end,
--         Get = function() return value end
--     }
--     return element
-- end

return AstroHub


