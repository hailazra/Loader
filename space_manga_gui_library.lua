--[[
	Space Manga GUI Library
	Based on Rayfield Interface Suite
	Theme: Space/Langit dan Manga dengan dominan putih dan aksen hitam
	Features: Minimize to icon, Draggable window
]]

local function getService(name)
	local service = game:GetService(name)
	return if cloneref then cloneref(service) else service
end

local Players = getService("Players")
local UserInputService = getService("UserInputService")
local TweenService = getService("TweenService")
local RunService = getService("RunService")
local CoreGui = getService("CoreGui")
local HttpService = getService("HttpService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Color Palette (Space/Manga Theme)
local Colors = {
	Primary = Color3.fromRGB(230, 230, 250), -- Light Lavender (almost white)
	Secondary = Color3.fromRGB(180, 150, 220), -- Soft Purple
	TextDark = Color3.fromRGB(20, 0, 40), -- Deep Indigo
	TextLight = Color3.fromRGB(200, 180, 240), -- Light Purple
	AccentSpace = Color3.fromRGB(70, 0, 100), -- Dark Purple (Nebula base)
	AccentManga = Color3.fromRGB(120, 80, 160), -- Medium Purple (Nebula accent)
	Highlight = Color3.fromRGB(150, 100, 200), -- Vibrant Purple (Highlight)
	Border = Color3.fromRGB(100, 70, 130), -- Muted Purple (Border)
	Shadow = Color3.fromRGB(0, 0, 0), -- Black for shadow
}

-- Animation Settings
local AnimationSpeed = 0.3
local EasingStyle = Enum.EasingStyle.Quart
local EasingDirection = Enum.EasingDirection.Out

-- Library Object
local SpaceMangaLib = {}
SpaceMangaLib.__index = SpaceMangaLib

-- Utility Functions
local function CreateTween(object, properties, duration, easingStyle, easingDirection)
	duration = duration or AnimationSpeed
	easingStyle = easingStyle or EasingStyle
	easingDirection = easingDirection or EasingDirection
	
	local tweenInfo = TweenInfo.new(duration, easingStyle, easingDirection)
	local tween = TweenService:Create(object, tweenInfo, properties)
	return tween
end

local function CreateShadow(parent, size, position)
	local shadow = Instance.new("Frame")
	shadow.Name = "Shadow"
	shadow.BackgroundColor3 = Colors.Shadow
	shadow.BackgroundTransparency = 0.8
	shadow.BorderSizePixel = 0
	shadow.Size = size or UDim2.new(1, 4, 1, 4)
	shadow.Position = position or UDim2.new(0, 2, 0, 2)
	shadow.ZIndex = parent.ZIndex - 1
	shadow.Parent = parent.Parent
	
	-- Rounded corners for shadow
	local shadowCorner = Instance.new("UICorner")
	shadowCorner.CornerRadius = UDim.new(0, 8)
	shadowCorner.Parent = shadow
	
	return shadow
end

local function CreateCorner(parent, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 8)
	corner.Parent = parent
	return corner
end

local function CreateStroke(parent, color, thickness)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color or Colors.Border
	stroke.Thickness = thickness or 1
	stroke.Parent = parent
	return stroke
end

-- Main Library Functions
function SpaceMangaLib:CreateWindow(config)
	config = config or {}
	
	local windowConfig = {
		Name = config.Name or "Space Manga GUI",
		Icon = config.Icon or "",
		LoadingTitle = config.LoadingTitle or "Space Manga Library",
		LoadingSubtitle = config.LoadingSubtitle or "by Manus",
		Theme = config.Theme or "SpaceManga",
		ToggleUIKeybind = config.ToggleUIKeybind or Enum.KeyCode.K,
		MinimizeKeybind = config.MinimizeKeybind or Enum.KeyCode.M,
		Size = config.Size or UDim2.new(0, 500, 0, 250),
		Position = config.Position or UDim2.new(0.5, -300, 0.5, -200),
	}
	
	-- Create ScreenGui
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "SpaceMangaGUI"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.IgnoreGuiInset = true
	
	-- Try to parent to CoreGui, fallback to PlayerGui
	local success = pcall(function()
		screenGui.Parent = CoreGui
	end)
	if not success then
		screenGui.Parent = PlayerGui
	end
	
	-- Main Window Frame
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainWindow"
	mainFrame.BackgroundColor3 = Colors.Primary
	mainFrame.BorderSizePixel = 0
	mainFrame.Size = windowConfig.Size
	mainFrame.Position = windowConfig.Position
	mainFrame.ClipsDescendants = true
	mainFrame.Active = true
	mainFrame.Draggable = true -- Enable dragging
	mainFrame.Parent = screenGui
	
	local blurEffect = Instance.new("UIBlur")
	blurEffect.Name = "BackgroundBlur"
	blurEffect.Size = 10 -- Adjust blur intensity as needed
	blurEffect.Parent = mainFrame
	
	-- Create shadow and corner for main frame
	CreateShadow(mainFrame)
	CreateCorner(mainFrame, 12)
	CreateStroke(mainFrame, Colors.Border, 2)
	
	-- Header/Topbar
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.BackgroundColor3 = Colors.Secondary
	header.BorderSizePixel = 0
	header.Size = UDim2.new(1, 0, 0, 50)
	header.Position = UDim2.new(0, 0, 0, 0)
	header.Parent = mainFrame
	
	CreateCorner(header, 12)
	CreateStroke(header, Colors.Border, 1)
	
	-- Header gradient for space theme
	local headerGradient = Instance.new("UIGradient")
	headerGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Colors.AccentSpace),
		ColorSequenceKeypoint.new(0.5, Colors.AccentManga),
		ColorSequenceKeypoint.new(1, Colors.Secondary)
	}
	headerGradient.Rotation = 90
	headerGradient.Parent = header
	
	-- Title Label
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.BackgroundTransparency = 1
	titleLabel.Size = UDim2.new(1, -120, 1, 0)
	titleLabel.Position = UDim2.new(0, 15, 0, 0)
	titleLabel.Text = windowConfig.Name
	titleLabel.TextColor3 = Colors.TextDark
	titleLabel.TextScaled = true
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Font = Enum.Font.SourceSansProBold
	titleLabel.Parent = header
	
	-- Control Buttons Container
	local controlsFrame = Instance.new("Frame")
	controlsFrame.Name = "Controls"
	controlsFrame.BackgroundTransparency = 1
	controlsFrame.Size = UDim2.new(0, 100, 1, 0)
	controlsFrame.Position = UDim2.new(1, -110, 0, 0)
	controlsFrame.Parent = header
	
	-- Minimize Button
	local minimizeBtn = Instance.new("TextButton")
	minimizeBtn.Name = "MinimizeButton"
	minimizeBtn.BackgroundColor3 = Colors.AccentSpace
	minimizeBtn.BorderSizePixel = 0
	minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
	minimizeBtn.Position = UDim2.new(0, 10, 0.5, -15)
	minimizeBtn.Text = "−"
	minimizeBtn.TextColor3 = Colors.Primary
	minimizeBtn.TextScaled = true
	minimizeBtn.Font = Enum.Font.SourceSansProBold
	minimizeBtn.TextSize = 24
	minimizeBtn.TextYAlignment = Enum.TextYAlignment.Center
	minimizeBtn.Parent = controlsFrame
	
	CreateCorner(minimizeBtn, 6)
	
	-- Close Button
	local closeBtn = Instance.new("TextButton")
	closeBtn.Name = "CloseButton"
	closeBtn.BackgroundColor3 = Color3.fromRGB(220, 53, 69)
	closeBtn.BorderSizePixel = 0
	closeBtn.Size = UDim2.new(0, 30, 0, 30)
	closeBtn.Position = UDim2.new(0, 50, 0.5, -15)
	closeBtn.Text = "×"
	closeBtn.TextColor3 = Colors.Primary
	closeBtn.TextScaled = true
	closeBtn.Font = Enum.Font.SourceSansProBold
	closeBtn.TextSize = 24
	closeBtn.TextYAlignment = Enum.TextYAlignment.Center
	closeBtn.Parent = controlsFrame
	
	CreateCorner(closeBtn, 6)
	
	-- Minimize Icon (when minimized)
	local minimizeIcon = Instance.new("TextButton")
	minimizeIcon.Name = "MinimizeIcon"
	minimizeIcon.BackgroundColor3 = Colors.AccentSpace
	minimizeIcon.BorderSizePixel = 0
	minimizeIcon.Size = UDim2.new(0, 60, 0, 60)
	minimizeIcon.Position = UDim2.new(0, 50, 0, 50)
	minimizeIcon.Text = "🌌" -- Space emoji
	minimizeIcon.TextColor3 = Colors.Primary
	minimizeIcon.TextScaled = true
	minimizeIcon.Font = Enum.Font.SourceSansProBold
	minimizeIcon.Visible = false
	minimizeIcon.Active = true
	minimizeIcon.Draggable = true -- Make icon draggable too
	minimizeIcon.Parent = screenGui
	
	CreateCorner(minimizeIcon, 30)
	CreateShadow(minimizeIcon)
	
	-- Content Container
	local contentFrame = Instance.new("Frame")
	contentFrame.Name = "Content"
	contentFrame.BackgroundTransparency = 1
	contentFrame.Size = UDim2.new(1, 0, 1, -50)
	contentFrame.Position = UDim2.new(0, 0, 0, 50)
	contentFrame.Parent = mainFrame
	
	-- Sidebar
	local sidebar = Instance.new("Frame")
	sidebar.Name = "Sidebar"
	sidebar.BackgroundColor3 = Colors.Secondary
	sidebar.BorderSizePixel = 0
	sidebar.Size = UDim2.new(0, 200, 1, 0)
	sidebar.Position = UDim2.new(0, 0, 0, 0)
	sidebar.Parent = contentFrame
	
	CreateStroke(sidebar, Colors.Border, 1)
	
	-- Sidebar gradient
	local sidebarGradient = Instance.new("UIGradient")
	sidebarGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Colors.AccentSpace),
		ColorSequenceKeypoint.new(0.5, Colors.AccentManga),
		ColorSequenceKeypoint.new(1, Colors.Secondary)
	}
	sidebarGradient.Rotation = 180
	sidebarGradient.Parent = sidebar
	
	-- Sidebar ScrollingFrame
	local sidebarScroll = Instance.new("ScrollingFrame")
	sidebarScroll.Name = "SidebarScroll"
	sidebarScroll.BackgroundTransparency = 1
	sidebarScroll.Size = UDim2.new(1, -10, 1, -10)
	sidebarScroll.Position = UDim2.new(0, 5, 0, 5)
	sidebarScroll.ScrollBarThickness = 4
	sidebarScroll.ScrollBarImageColor3 = Colors.AccentSpace
	sidebarScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	sidebarScroll.Parent = sidebar
	
	-- Sidebar Layout
	local sidebarLayout = Instance.new("UIListLayout")
	sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
	sidebarLayout.Padding = UDim.new(0, 5)
	sidebarLayout.Parent = sidebarScroll
	
	-- Main Content Area
	local mainContent = Instance.new("Frame")
	mainContent.Name = "MainContent"
	mainContent.BackgroundColor3 = Colors.Primary
	mainContent.BorderSizePixel = 0
	mainContent.Size = UDim2.new(1, -200, 1, 0)
	mainContent.Position = UDim2.new(0, 200, 0, 0)
	mainContent.Parent = contentFrame
	
	-- Window Object
	local Window = {}
	Window.GUI = screenGui
	Window.MainFrame = mainFrame
	Window.MinimizeIcon = minimizeIcon
	Window.Sidebar = sidebarScroll
	Window.Content = mainContent
	Window.IsMinimized = false
	Window.Tabs = {}
	Window.CurrentTab = nil
	
	-- Minimize/Restore functionality
	local function toggleMinimize()
		if Window.IsMinimized then
			-- Restore window
			minimizeIcon.Visible = false
			mainFrame.Visible = true
			Window.IsMinimized = false
		else
			-- Minimize window
			mainFrame.Visible = false
			minimizeIcon.Visible = true
			Window.IsMinimized = true
		end
	end
	
	-- Button connections
	minimizeBtn.MouseButton1Click:Connect(toggleMinimize)
	minimizeIcon.MouseButton1Click:Connect(toggleMinimize)
	
	closeBtn.MouseButton1Click:Connect(function()
		screenGui:Destroy()
	end)
	
	-- Keybind connections
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		
		if input.KeyCode == windowConfig.ToggleUIKeybind then
			screenGui.Enabled = not screenGui.Enabled
		elseif input.KeyCode == windowConfig.MinimizeKeybind then
			toggleMinimize()
		end
	end)
	
	-- Hover effects for buttons
	local function addHoverEffect(button, hoverColor, normalColor)
		button.MouseEnter:Connect(function()
			CreateTween(button, {BackgroundColor3 = hoverColor}, 0.2):Play()
		end)
		
		button.MouseLeave:Connect(function()
			CreateTween(button, {BackgroundColor3 = normalColor}, 0.2):Play()
		end)
	end
	
	addHoverEffect(minimizeBtn, Color3.fromRGB(94, 55, 110), Colors.AccentSpace)
	addHoverEffect(closeBtn, Color3.fromRGB(240, 73, 89), Color3.fromRGB(220, 53, 69))
	addHoverEffect(minimizeIcon, Color3.fromRGB(94, 55, 110), Colors.AccentSpace)
	
	-- Update sidebar canvas size
	local function updateSidebarCanvas()
		sidebarScroll.CanvasSize = UDim2.new(0, 0, 0, sidebarLayout.AbsoluteContentSize.Y + 10)
	end
	
	sidebarLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateSidebarCanvas)
	
	-- Window methods
	function Window:CreateTab(name, icon)
		local Tab = {}
		Tab.Name = name
		Tab.Icon = icon or ""
		Tab.Elements = {}
		Tab.Sections = {}
		
		-- Tab Button
		local tabButton = Instance.new("TextButton")
		tabButton.Name = "Tab_" .. name
		tabButton.BackgroundColor3 = Colors.Primary
		tabButton.BorderSizePixel = 0
		tabButton.Size = UDim2.new(1, -10, 0, 40)
		tabButton.Text = ""
		tabButton.Parent = self.Sidebar
		
		CreateCorner(tabButton, 6)
		CreateStroke(tabButton, Colors.Border, 1)
		
		-- Tab Icon (if provided)
		local tabIcon = Instance.new("TextLabel")
		tabIcon.Name = "Icon"
		tabIcon.BackgroundTransparency = 1
		tabIcon.Size = UDim2.new(0, 30, 0, 30)
		tabIcon.Position = UDim2.new(0, 10, 0.5, -15)
		tabIcon.Text = icon or "📄"
		tabIcon.TextColor3 = Colors.TextDark
		tabIcon.TextScaled = true
		tabIcon.Font = Enum.Font.SourceSansPro
		tabIcon.Parent = tabButton
		
		-- Tab Label
		local tabLabel = Instance.new("TextLabel")
		tabLabel.Name = "Label"
		tabLabel.BackgroundTransparency = 1
		tabLabel.Size = UDim2.new(1, -50, 1, 0)
		tabLabel.Position = UDim2.new(0, 45, 0, 0)
		tabLabel.Text = name
		tabLabel.TextColor3 = Colors.TextDark
		tabLabel.TextScaled = true
		tabLabel.TextXAlignment = Enum.TextXAlignment.Left
		tabLabel.Font = Enum.Font.SourceSansPro
		tabLabel.Parent = tabButton
		
		-- Tab Content Frame
		local tabContent = Instance.new("ScrollingFrame")
		tabContent.Name = "TabContent_" .. name
		tabContent.BackgroundTransparency = 1
		tabContent.Size = UDim2.new(1, -20, 1, -20)
		tabContent.Position = UDim2.new(0, 10, 0, 10)
		tabContent.ScrollBarThickness = 6
		tabContent.ScrollBarImageColor3 = Colors.AccentSpace
		tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
		tabContent.Visible = false
		tabContent.Parent = self.Content
		
		-- Tab Content Layout
		local tabLayout = Instance.new("UIListLayout")
		tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
		tabLayout.Padding = UDim.new(0, 10)
		tabLayout.Parent = tabContent
		
		-- Update canvas size
		local function updateTabCanvas()
			tabContent.CanvasSize = UDim2.new(0, 0, 0, tabLayout.AbsoluteContentSize.Y + 20)
		end
		
		tabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateTabCanvas)
		
		Tab.Button = tabButton
		Tab.Content = tabContent
		Tab.Layout = tabLayout
		
		-- Tab selection
		local function selectTab()
			-- Hide all tabs
			for _, tab in pairs(self.Tabs) do
				tab.Content.Visible = false
				tab.Button.BackgroundColor3 = Colors.Primary
			end
			
			-- Show selected tab
			tabContent.Visible = true
			tabButton.BackgroundColor3 = Colors.Highlight
			self.CurrentTab = Tab
		end
		
		tabButton.MouseButton1Click:Connect(selectTab)
		
		-- Hover effect for tab
		addHoverEffect(tabButton, Colors.Secondary, Colors.Primary)
		
		-- Auto-select first tab
		if #self.Tabs == 0 then
			selectTab()
		end
		
		self.Tabs[#self.Tabs + 1] = Tab
		
		-- Tab methods
		function Tab:CreateSection(name)
			local Section = {}
			Section.Name = name
			Section.Elements = {}
			
			-- Section Frame
			local sectionFrame = Instance.new("Frame")
			sectionFrame.Name = "Section_" .. name
			sectionFrame.BackgroundColor3 = Colors.Secondary
			sectionFrame.BorderSizePixel = 0
			sectionFrame.Size = UDim2.new(1, 0, 0, 50) -- Initial size, will be resized
			sectionFrame.Parent = self.Content
			sectionFrame.ClipsDescendants = true -- Important for sliding effect
			
			CreateCorner(sectionFrame, 8)
			CreateStroke(sectionFrame, Colors.Border, 1)
			
			-- Section Header (clickable for slide)
			local sectionHeader = Instance.new("TextButton")
			sectionHeader.Name = "Header"
			sectionHeader.BackgroundTransparency = 1
			sectionHeader.Size = UDim2.new(1, 0, 0, 40)
			sectionHeader.Position = UDim2.new(0, 0, 0, 0)
			sectionHeader.Text = ""
			sectionHeader.Parent = sectionFrame
			
			-- Section Title
			local sectionTitle = Instance.new("TextLabel")
			sectionTitle.Name = "Title"
			sectionTitle.BackgroundTransparency = 1
			sectionTitle.Size = UDim2.new(1, -40, 1, 0)
			sectionTitle.Position = UDim2.new(0, 10, 0, 0)
			sectionTitle.Text = name
			sectionTitle.TextColor3 = Colors.TextDark
			sectionTitle.TextScaled = true
			sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
			sectionTitle.Font = Enum.Font.SourceSansProBold
			sectionTitle.Parent = sectionHeader
			
			-- Toggle Arrow
			local toggleArrow = Instance.new("TextLabel")
			toggleArrow.Name = "ToggleArrow"
			toggleArrow.BackgroundTransparency = 1
			toggleArrow.Size = UDim2.new(0, 30, 1, 0)
			toggleArrow.Position = UDim2.new(1, -40, 0, 0)
			toggleArrow.Text = "▼"
			toggleArrow.TextColor3 = Colors.TextDark
			toggleArrow.TextScaled = true
			toggleArrow.Font = Enum.Font.SourceSansProBold
			toggleArrow.Parent = sectionHeader
			
			-- Section Content
			local sectionContent = Instance.new("Frame")
			sectionContent.Name = "Content"
			sectionContent.BackgroundTransparency = 1
			sectionContent.Size = UDim2.new(1, -20, 0, 0) -- Initial height 0
			sectionContent.Position = UDim2.new(0, 10, 0, 40)
			sectionContent.Parent = sectionFrame
			
			-- Section Layout
			local sectionLayout = Instance.new("UIListLayout")
			sectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
			sectionLayout.Padding = UDim.new(0, 8)
			sectionLayout.Parent = sectionContent
			
			Section.Frame = sectionFrame
			Section.Content = sectionContent
			Section.Layout = sectionLayout
			Section.IsExpanded = false -- Default to collapsed
			
			local initialContentHeight = 0
			
			-- Function to update section size and animate
			local function updateSectionSize(expanded)
				local targetContentHeight = sectionLayout.AbsoluteContentSize.Y
				local targetFrameHeight = (expanded and targetContentHeight + 60) or 50
				
				CreateTween(sectionFrame, {Size = UDim2.new(1, 0, 0, targetFrameHeight)}, AnimationSpeed):Play()
				CreateTween(sectionContent, {Size = UDim2.new(1, -20, 0, (expanded and targetContentHeight) or 0)}, AnimationSpeed):Play()
				toggleArrow.Text = expanded and "▼" or "►"
				Section.IsExpanded = expanded
			end
			
			-- Connect to layout changes to get content size
			sectionLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				if Section.IsExpanded then
					updateSectionSize(true)
				end
			end)
			
			-- Toggle section on header click
			sectionHeader.MouseButton1Click:Connect(function()
				updateSectionSize(not Section.IsExpanded)
				end)
			
			-- Initial update to set correct size if content already exists
			RunService.Heartbeat:Wait()
			updateSectionSize(false) -- Start collapsed
			
			self.Sections[#self.Sections + 1] = Section
			
			-- Section methods will be added here (CreateButton, CreateToggle, etc.)
			function Section:CreateButton(config)
				config = config or {}
				local buttonConfig = {
					Name = config.Name or "Button",
					Callback = config.Callback or function() end
				}
				
				local button = Instance.new("TextButton")
				button.Name = "Button_" .. buttonConfig.Name
				button.BackgroundColor3 = Colors.AccentSpace
				button.BorderSizePixel = 0
				button.Size = UDim2.new(1, 0, 0, 35)
				button.Text = buttonConfig.Name
				button.TextColor3 = Colors.Primary
				button.TextScaled = true
				button.Font = Enum.Font.SourceSansPro
				button.Parent = self.Content
				
				CreateCorner(button, 6)
				
				button.MouseButton1Click:Connect(buttonConfig.Callback)
				addHoverEffect(button, Color3.fromRGB(94, 55, 110), Colors.AccentSpace)
				
				return button
			end
			
			function Section:CreateToggle(config)
				config = config or {}
				local toggleConfig = {
					Name = config.Name or "Toggle",
					Default = config.Default or false,
					Callback = config.Callback or function() end
				}
				
				local toggleFrame = Instance.new("Frame")
				toggleFrame.Name = "Toggle_" .. toggleConfig.Name
				toggleFrame.BackgroundColor3 = Colors.Primary
				toggleFrame.BorderSizePixel = 0
				toggleFrame.Size = UDim2.new(1, 0, 0, 35)
				toggleFrame.Parent = self.Content
				
				CreateCorner(toggleFrame, 6)
				CreateStroke(toggleFrame, Colors.Border, 1)
				
				local toggleLabel = Instance.new("TextLabel")
				toggleLabel.BackgroundTransparency = 1
				toggleLabel.Size = UDim2.new(1, -50, 1, 0)
				toggleLabel.Position = UDim2.new(0, 10, 0, 0)
				toggleLabel.Text = toggleConfig.Name
				toggleLabel.TextColor3 = Colors.TextDark
				toggleLabel.TextScaled = true
				toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
				toggleLabel.Font = Enum.Font.SourceSansPro
				toggleLabel.Parent = toggleFrame
				
				local toggleButton = Instance.new("TextButton")
				toggleButton.BackgroundColor3 = toggleConfig.Default and Colors.Highlight or Colors.AccentManga
				toggleButton.BorderSizePixel = 0
				toggleButton.Size = UDim2.new(0, 40, 0, 20)
				toggleButton.Position = UDim2.new(1, -50, 0.5, -10)
				toggleButton.Text = ""
				toggleButton.Parent = toggleFrame
				
				CreateCorner(toggleButton, 10)
				
				local toggleIndicator = Instance.new("Frame")
				toggleIndicator.BackgroundColor3 = Colors.Primary
				toggleIndicator.BorderSizePixel = 0
				toggleIndicator.Size = UDim2.new(0, 16, 0, 16)
				toggleIndicator.Position = toggleConfig.Default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
				toggleIndicator.Parent = toggleButton
				
				CreateCorner(toggleIndicator, 8)
				
				local isToggled = toggleConfig.Default
				
				local function updateToggle()
					local newColor = isToggled and Colors.Highlight or Colors.AccentManga
					local newPosition = isToggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
					
					CreateTween(toggleButton, {BackgroundColor3 = newColor}):Play()
					CreateTween(toggleIndicator, {Position = newPosition}):Play()
					
					toggleConfig.Callback(isToggled)
				end
				
				toggleButton.MouseButton1Click:Connect(function()
					isToggled = not isToggled
					updateToggle()
				end)
				
				return {
					Set = function(value)
						isToggled = value
						updateToggle()
					end
				}
			end
			
			return Section
		end
		
		return Tab
	end
	
	return Window
end

return SpaceMangaLib



			function Section:CreateDropdown(config)
				config = config or {}
				local dropdownConfig = {
					Name = config.Name or "Dropdown",
					Options = config.Options or {}, -- Table of strings
					Default = config.Default or nil,
					Callback = config.Callback or function() end
				}
				
				local dropdownFrame = Instance.new("Frame")
				dropdownFrame.Name = "Dropdown_" .. dropdownConfig.Name
				dropdownFrame.BackgroundColor3 = Colors.Primary
				dropdownFrame.BorderSizePixel = 0
				dropdownFrame.Size = UDim2.new(1, 0, 0, 40) -- Initial size (header only)
				dropdownFrame.Parent = self.Content
				dropdownFrame.ClipsDescendants = true
				
				CreateCorner(dropdownFrame, 6)
				CreateStroke(dropdownFrame, Colors.Border, 1)
				
				local dropdownHeader = Instance.new("TextButton")
				dropdownHeader.Name = "Header"
				dropdownHeader.BackgroundTransparency = 1
				dropdownHeader.Size = UDim2.new(1, 0, 0, 40)
				dropdownHeader.Position = UDim2.new(0, 0, 0, 0)
				dropdownHeader.Text = ""
				dropdownHeader.Parent = dropdownFrame
				
				local dropdownLabel = Instance.new("TextLabel")
				dropdownLabel.Name = "Label"
				dropdownLabel.BackgroundTransparency = 1
				dropdownLabel.Size = UDim2.new(1, -50, 1, 0)
				dropdownLabel.Position = UDim2.new(0, 10, 0, 0)
				dropdownLabel.Text = dropdownConfig.Name .. ": " .. (dropdownConfig.Default or "Select Option")
				dropdownLabel.TextColor3 = Colors.TextDark
				dropdownLabel.TextScaled = true
				dropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
				dropdownLabel.Font = Enum.Font.SourceSansPro
				dropdownLabel.Parent = dropdownHeader
				
				local dropdownArrow = Instance.new("TextLabel")
				dropdownArrow.Name = "Arrow"
				dropdownArrow.BackgroundTransparency = 1
				dropdownArrow.Size = UDim2.new(0, 30, 1, 0)
				dropdownArrow.Position = UDim2.new(1, -40, 0, 0)
				dropdownArrow.Text = "▼"
				dropdownArrow.TextColor3 = Colors.TextDark
				dropdownArrow.TextScaled = true
				dropdownArrow.Font = Enum.Font.SourceSansProBold
				dropdownArrow.Parent = dropdownHeader
				
				local optionsFrame = Instance.new("Frame")
				optionsFrame.Name = "Options"
				optionsFrame.BackgroundTransparency = 1
				optionsFrame.Size = UDim2.new(1, 0, 0, 0) -- Starts collapsed
				optionsFrame.Position = UDim2.new(0, 0, 0, 40)
				optionsFrame.Parent = dropdownFrame
				
				local optionsLayout = Instance.new("UIListLayout")
				optionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
				optionsLayout.Padding = UDim.new(0, 2)
				optionsLayout.Parent = optionsFrame
				
				local isExpanded = false
				local currentSelection = dropdownConfig.Default
				
				local function updateDropdownSize()
					local targetOptionsHeight = optionsLayout.AbsoluteContentSize.Y
					local targetFrameHeight = (isExpanded and targetOptionsHeight + 40) or 40
					
					CreateTween(dropdownFrame, {Size = UDim2.new(1, 0, 0, targetFrameHeight)}, AnimationSpeed):Play()
					CreateTween(optionsFrame, {Size = UDim2.new(1, 0, 0, (isExpanded and targetOptionsHeight) or 0)}, AnimationSpeed):Play()
					dropdownArrow.Text = isExpanded and "▲" or "▼"
				end
				
				optionsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateDropdownSize)
				
				for i, optionText in ipairs(dropdownConfig.Options) do
					local optionButton = Instance.new("TextButton")
					optionButton.Name = "Option_" .. optionText
					optionButton.BackgroundColor3 = Colors.Secondary
					optionButton.BorderSizePixel = 0
					optionButton.Size = UDim2.new(1, 0, 0, 30)
					optionButton.Text = optionText
					optionButton.TextColor3 = Colors.TextDark
					optionButton.TextScaled = true
					optionButton.Font = Enum.Font.SourceSansPro
					optionButton.Parent = optionsFrame
					
					CreateCorner(optionButton, 4)
					
					optionButton.MouseButton1Click:Connect(function()
						currentSelection = optionText
						dropdownLabel.Text = dropdownConfig.Name .. ": " .. currentSelection
						isExpanded = false
						updateDropdownSize()
						dropdownConfig.Callback(currentSelection)
					end)
					
					addHoverEffect(optionButton, Colors.Highlight, Colors.Secondary)
				end
				
				dropdownHeader.MouseButton1Click:Connect(function()
					isExpanded = not isExpanded
					updateDropdownSize()
				end)
				
				return {
					GetSelection = function() return currentSelection end,
					SetSelection = function(value)
						currentSelection = value
						dropdownLabel.Text = dropdownConfig.Name .. ": " .. currentSelection
					end
				}
				end




function SpaceMangaLib:CreateNotification(config)
	config = config or {}
	local notificationConfig = {
		Title = config.Title or "Notification",
		Text = config.Text or "This is a notification.",
		Duration = config.Duration or 3, -- seconds
		Icon = config.Icon or "🔔"
	}
	
	local notificationFrame = Instance.new("Frame")
	notificationFrame.Name = "Notification"
	notificationFrame.BackgroundColor3 = Colors.AccentSpace
	notificationFrame.BackgroundTransparency = 0.1
	notificationFrame.BorderSizePixel = 0
	notificationFrame.Size = UDim2.new(0, 250, 0, 70)
	notificationFrame.Position = UDim2.new(1, -260, 0, 10) -- Top right corner
	notificationFrame.ZIndex = 10 -- Ensure it's on top
	notificationFrame.Parent = self.GUI
	
	CreateCorner(notificationFrame, 8)
	CreateShadow(notificationFrame, UDim2.new(1, 2, 1, 2), UDim2.new(0, 1, 0, 1))
	
	local iconLabel = Instance.new("TextLabel")
	iconLabel.Name = "Icon"
	iconLabel.BackgroundTransparency = 1
	iconLabel.Size = UDim2.new(0, 40, 1, 0)
	iconLabel.Position = UDim2.new(0, 10, 0, 0)
	iconLabel.Text = notificationConfig.Icon
	iconLabel.TextColor3 = Colors.Primary
	iconLabel.TextScaled = true
	iconLabel.Font = Enum.Font.SourceSansProBold
	iconLabel.Parent = notificationFrame
	
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.BackgroundTransparency = 1
	titleLabel.Size = UDim2.new(1, -60, 0.5, 0)
	titleLabel.Position = UDim2.new(0, 50, 0, 0)
	titleLabel.Text = notificationConfig.Title
	titleLabel.TextColor3 = Colors.Primary
	titleLabel.TextScaled = true
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Font = Enum.Font.SourceSansProBold
	titleLabel.Parent = notificationFrame
	
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "Text"
	textLabel.BackgroundTransparency = 1
	textLabel.Size = UDim2.new(1, -60, 0.5, 0)
	textLabel.Position = UDim2.new(0, 50, 0.5, 0)
	textLabel.Text = notificationConfig.Text
	textLabel.TextColor3 = Colors.Primary
	textLabel.TextScaled = true
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.Font = Enum.Font.SourceSansPro
	textLabel.Parent = notificationFrame
	
	-- Animation
	notificationFrame.BackgroundTransparency = 1 -- Start fully transparent
	CreateTween(notificationFrame, {BackgroundTransparency = 0.1}, 0.5):Play()
	CreateTween(notificationFrame, {Position = UDim2.new(1, -260, 0, 10)}, 0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out):Play()
	
	-- Fade out and destroy after duration
	delay(notificationConfig.Duration, function()
		CreateTween(notificationFrame, {BackgroundTransparency = 1}, 0.5):Play()
		CreateTween(notificationFrame, {Position = UDim2.new(1, -260, 0, -80)}, 0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In):Play()
		wait(0.5)
		notificationFrame:Destroy()
	end)
end


