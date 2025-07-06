--[[
	Space Manga GUI Library - Improved Version 2.0
	Based on Rayfield Interface Suite
	
	New Features:
	- Dual Theme System (Space & Manga)
	- Slider Component
	- Dropdown Component
	- Notification System
	- Improved Animations
	- Better Font and Element Sizing
	- Fixed Black Screen Bug
	- MainTab Transparency
	- Proper Window Size (500x250)
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

-- Theme System
local Themes = {
	Space = {
		Primary = Color3.new(1, 1, 1), -- Putih murni
		Secondary = Color3.new(0.941, 0.941, 0.941), -- Putih keabu-abuan
		TextDark = Color3.new(0.102, 0.102, 0.102), -- Hitam pekat
		TextLight = Color3.new(0.878, 0.878, 0.878), -- Abu-abu terang
		AccentPrimary = Color3.new(0.290, 0.137, 0.353), -- Ungu gelap
		AccentSecondary = Color3.new(0.2, 0.2, 0.2), -- Abu-abu gelap
		Highlight = Color3.new(0.416, 0.353, 0.804), -- Ungu medium
		Border = Color3.new(0.784, 0.784, 0.784), -- Border abu-abu
		Shadow = Color3.new(0, 0, 0), -- Hitam untuk shadow
		BackgroundTransparency = 0.15
	},
	Manga = {
		Primary = Color3.new(0.973, 0.973, 0.973), -- Putih sangat terang
		Secondary = Color3.new(0.910, 0.910, 0.910), -- Abu-abu terang
		TextDark = Color3.new(0.039, 0.039, 0.039), -- Hitam pekat
		TextLight = Color3.new(0.753, 0.753, 0.753), -- Abu-abu sangat terang
		AccentPrimary = Color3.new(0.267, 0.267, 0.267), -- Abu-abu gelap
		AccentSecondary = Color3.new(0.133, 0.133, 0.133), -- Abu-abu sangat gelap
		Highlight = Color3.new(1, 0.420, 0.420), -- Merah muda cerah
		Border = Color3.new(0.627, 0.627, 0.627), -- Abu-abu medium
		Shadow = Color3.new(0, 0, 0), -- Hitam
		BackgroundTransparency = 0.1
	}
}

-- Current Theme
local CurrentTheme = "Space"
local Colors = Themes[CurrentTheme]

-- Improved Animation Settings
local AnimationSpeed = 0.2
local EasingStyle = Enum.EasingStyle.Quint
local EasingDirection = Enum.EasingDirection.Out

-- Cache for tweens
local activeTweens = {}

-- Library Object
local SpaceMangaLib = {}
SpaceMangaLib.__index = SpaceMangaLib

-- Utility Functions
local function CreateTween(object, properties, duration, easingStyle, easingDirection)
	if activeTweens[object] then
		activeTweens[object]:Cancel()
	end
	
	duration = duration or AnimationSpeed
	easingStyle = easingStyle or EasingStyle
	easingDirection = easingDirection or EasingDirection
	
	local tweenInfo = TweenInfo.new(duration, easingStyle, easingDirection)
	local tween = TweenService:Create(object, tweenInfo, properties)
	
	activeTweens[object] = tween
	
	tween.Completed:Connect(function()
		activeTweens[object] = nil
	end)
	
	return tween
end

local function CreateCorner(parent, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 6)
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

local function CreateShadow(parent)
	local shadow = Instance.new("ImageLabel")
	shadow.Name = "Shadow"
	shadow.BackgroundTransparency = 1
	shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
	shadow.ImageColor3 = Colors.Shadow
	shadow.ImageTransparency = 0.85
	shadow.Size = UDim2.new(1, 4, 1, 4)
	shadow.Position = UDim2.new(0, 2, 0, 2)
	shadow.ZIndex = parent.ZIndex - 1
	shadow.Parent = parent.Parent
	
	CreateCorner(shadow, 6)
	return shadow
end

-- Notification System
local NotificationContainer = nil

local function CreateNotification(title, message, duration)
	duration = duration or 3
	
	if not NotificationContainer then
		NotificationContainer = Instance.new("Frame")
		NotificationContainer.Name = "NotificationContainer"
		NotificationContainer.BackgroundTransparency = 1
		NotificationContainer.Size = UDim2.new(0, 300, 1, 0)
		NotificationContainer.Position = UDim2.new(1, -310, 0, 10)
		NotificationContainer.Parent = PlayerGui
		
		local layout = Instance.new("UIListLayout")
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.Padding = UDim.new(0, 5)
		layout.Parent = NotificationContainer
	end
	
	local notification = Instance.new("Frame")
	notification.BackgroundColor3 = Colors.AccentPrimary
	notification.BackgroundTransparency = 0.1
	notification.Size = UDim2.new(1, 0, 0, 60)
	notification.Position = UDim2.new(1, 0, 0, 0)
	notification.Parent = NotificationContainer
	
	CreateCorner(notification, 8)
	CreateStroke(notification, Colors.Border, 1)
	
	local titleLabel = Instance.new("TextLabel")
	titleLabel.BackgroundTransparency = 1
	titleLabel.Size = UDim2.new(1, -16, 0, 20)
	titleLabel.Position = UDim2.new(0, 8, 0, 5)
	titleLabel.Text = title
	titleLabel.TextColor3 = Colors.Primary
	titleLabel.TextScaled = true
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.Parent = notification
	
	local messageLabel = Instance.new("TextLabel")
	messageLabel.BackgroundTransparency = 1
	messageLabel.Size = UDim2.new(1, -16, 0, 25)
	messageLabel.Position = UDim2.new(0, 8, 0, 25)
	messageLabel.Text = message
	messageLabel.TextColor3 = Colors.Primary
	messageLabel.TextScaled = true
	messageLabel.TextXAlignment = Enum.TextXAlignment.Left
	messageLabel.Font = Enum.Font.Gotham
	messageLabel.Parent = notification
	
	-- Slide in animation
	CreateTween(notification, {Position = UDim2.new(0, 0, 0, 0)}, 0.3):Play()
	
	-- Auto remove after duration
	task.wait(duration)
	CreateTween(notification, {Position = UDim2.new(1, 0, 0, 0)}, 0.3).Completed:Connect(function()
		notification:Destroy()
	end)
	CreateTween(notification, {Position = UDim2.new(1, 0, 0, 0)}, 0.3):Play()
end

-- Theme Functions
function SpaceMangaLib:SetTheme(themeName)
	if Themes[themeName] then
		CurrentTheme = themeName
		Colors = Themes[CurrentTheme]
		
		-- Update existing GUI elements if any
		-- This part needs to iterate through existing windows and update their colors
		-- For now, we'll just notify the user.
		CreateNotification("Theme Changed", "Switched to " .. themeName .. " theme", 2)
	end
end

function SpaceMangaLib:GetCurrentTheme()
	return CurrentTheme
end

-- Main Library Functions
function SpaceMangaLib:CreateWindow(config)
	config = config or {}
	
	local windowConfig = {
		Name = config.Name or "Space Manga GUI",
		Icon = config.Icon or "🌌",
		LoadingTitle = config.LoadingTitle or "Space Manga Library",
		LoadingSubtitle = config.LoadingSubtitle or "by Manus",
		Theme = config.Theme or CurrentTheme,
		ToggleUIKeybind = config.ToggleUIKeybind or Enum.KeyCode.K,
		MinimizeKeybind = config.MinimizeKeybind or Enum.KeyCode.M,
		Size = config.Size or UDim2.new(0, 500, 0, 250), -- Updated default size
		Position = config.Position or UDim2.new(0.5, -250, 0.5, -125),
	}
	
	-- Set theme if specified
	if config.Theme and Themes[config.Theme] then
		SpaceMangaLib:SetTheme(config.Theme)
	end
	
	-- Create ScreenGui
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "SpaceMangaGUI_" .. HttpService:GenerateGUID(false):sub(1, 8)
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
	
	-- Main Window Frame with transparency
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainWindow"
	mainFrame.BackgroundColor3 = Colors.Primary
	mainFrame.BackgroundTransparency = Colors.BackgroundTransparency -- Corrected transparency application
	mainFrame.BorderSizePixel = 0
	mainFrame.Size = windowConfig.Size
	mainFrame.Position = windowConfig.Position
	mainFrame.ClipsDescendants = true
	mainFrame.Active = true
	mainFrame.Draggable = true
	mainFrame.Parent = screenGui
	
	CreateShadow(mainFrame)
	CreateCorner(mainFrame, 10)
	CreateStroke(mainFrame, Colors.Border, 1.5)
	
	-- Improved Header (smaller)
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.BackgroundColor3 = Colors.Secondary
	header.BackgroundTransparency = 0.05
	header.BorderSizePixel = 0
	header.Size = UDim2.new(1, 0, 0, 35) -- Reduced from 45 to 35
	header.Position = UDim2.new(0, 0, 0, 0)
	header.Parent = mainFrame
	
	CreateCorner(header, 10)
	CreateStroke(header, Colors.Border, 1)
	
	-- Improved Title (better font sizing)
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.BackgroundTransparency = 1
	titleLabel.Size = UDim2.new(1, -80, 1, 0)
	titleLabel.Position = UDim2.new(0, 12, 0, 0)
	titleLabel.Text = windowConfig.Name
	titleLabel.TextColor3 = Colors.TextDark
	titleLabel.TextSize = 14 -- Fixed text size instead of scaled
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.Parent = header
	
	-- Improved Control Buttons (smaller)
	local controlsFrame = Instance.new("Frame")
	controlsFrame.Name = "Controls"
	controlsFrame.BackgroundTransparency = 1
	controlsFrame.Size = UDim2.new(0, 70, 1, 0)
	controlsFrame.Position = UDim2.new(1, -75, 0, 0)
	controlsFrame.Parent = header
	
	-- Minimize Button (smaller)
	local minimizeBtn = Instance.new("TextButton")
	minimizeBtn.Name = "MinimizeButton"
	minimizeBtn.BackgroundColor3 = Colors.AccentPrimary
	minimizeBtn.BorderSizePixel = 0
	minimizeBtn.Size = UDim2.new(0, 24, 0, 24) -- Reduced from 28
	minimizeBtn.Position = UDim2.new(0, 5, 0.5, -12)
	minimizeBtn.Text = "−"
	minimizeBtn.TextColor3 = Colors.Primary
	minimizeBtn.TextSize = 16
	minimizeBtn.Font = Enum.Font.GothamBold
	minimizeBtn.Parent = controlsFrame
	
	CreateCorner(minimizeBtn, 4)
	
	-- Close Button (smaller)
	local closeBtn = Instance.new("TextButton")
	closeBtn.Name = "CloseButton"
	closeBtn.BackgroundColor3 = Color3.new(0.863, 0.208, 0.271)
	closeBtn.BorderSizePixel = 0
	closeBtn.Size = UDim2.new(0, 24, 0, 24) -- Reduced from 28
	closeBtn.Position = UDim2.new(0, 35, 0.5, -12)
	closeBtn.Text = "×"
	closeBtn.TextColor3 = Colors.Primary
	closeBtn.TextSize = 16
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.Parent = controlsFrame
	
	CreateCorner(closeBtn, 4)
	
	-- Original Minimize Icon (re-implemented for proper logo and draggable)
	local minimizeIcon = Instance.new("TextButton")
	minimizeIcon.Name = "MinimizeIcon"
	minimizeIcon.BackgroundColor3 = Colors.AccentPrimary
	minimizeIcon.BorderSizePixel = 0
	minimizeIcon.Size = UDim2.new(0, 55, 0, 55) -- Reverted to original size for better visibility
	minimizeIcon.Position = UDim2.new(0, 50, 0, 50)
	minimizeIcon.Text = windowConfig.Icon
	minimizeIcon.TextColor3 = Colors.Primary
	minimizeIcon.TextSize = 24 -- Increased text size for icon
	minimizeIcon.Font = Enum.Font.GothamBold
	minimizeIcon.Visible = false
	minimizeIcon.Active = true
	minimizeIcon.Draggable = true
	minimizeIcon.Parent = screenGui
	
	CreateCorner(minimizeIcon, 27) -- Adjusted corner radius
	CreateShadow(minimizeIcon)
	
	-- Content Container (adjusted for smaller header)
	local contentFrame = Instance.new("Frame")
	contentFrame.Name = "Content"
	contentFrame.BackgroundTransparency = 1
	contentFrame.Size = UDim2.new(1, 0, 1, -35) -- Adjusted for smaller header
	contentFrame.Position = UDim2.new(0, 0, 0, 35)
	contentFrame.Parent = mainFrame
	
	-- Improved Sidebar (smaller)
	local sidebar = Instance.new("Frame")
	sidebar.Name = "Sidebar"
	sidebar.BackgroundColor3 = Colors.Secondary
	sidebar.BackgroundTransparency = 0.1
	sidebar.BorderSizePixel = 0
	sidebar.Size = UDim2.new(0, 150, 1, 0) -- Reduced from 180
	sidebar.Position = UDim2.new(0, 0, 0, 0)
	sidebar.Parent = contentFrame
	
	CreateStroke(sidebar, Colors.Border, 1)
	
	-- Sidebar ScrollingFrame (improved)
	local sidebarScroll = Instance.new("ScrollingFrame")
	sidebarScroll.Name = "SidebarScroll"
	sidebarScroll.BackgroundTransparency = 1
	sidebarScroll.Size = UDim2.new(1, -6, 1, -6)
	sidebarScroll.Position = UDim2.new(0, 3, 0, 3)
	sidebarScroll.ScrollBarThickness = 2
	sidebarScroll.ScrollBarImageColor3 = Colors.AccentPrimary
	sidebarScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	sidebarScroll.ScrollingDirection = Enum.ScrollingDirection.Y
	sidebarScroll.Parent = sidebar
	
	-- Sidebar Layout (tighter spacing)
	local sidebarLayout = Instance.new("UIListLayout")
	sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
	sidebarLayout.Padding = UDim.new(0, 3) -- Reduced from 4
	sidebarLayout.Parent = sidebarScroll
	
	-- Main Content Area (adjusted)
	local mainContent = Instance.new("Frame")
	mainContent.Name = "MainContent"
	mainContent.BackgroundColor3 = Colors.Primary
	mainContent.BackgroundTransparency = 0.05
	mainContent.BorderSizePixel = 0
	mainContent.Size = UDim2.new(1, -150, 1, 0) -- Adjusted for smaller sidebar
	mainContent.Position = UDim2.new(0, 150, 0, 0)
	mainContent.Parent = contentFrame
	
	-- Window Object
	local Window = {
		GUI = screenGui,
		MainFrame = mainFrame,
		MinimizeIcon = minimizeIcon,
		Sidebar = sidebarScroll,
		Content = mainContent,
		IsMinimized = false,
		Tabs = {},
		CurrentTab = nil,
		_connections = {}
	}
	
	-- Fixed minimize/restore functionality (no more black screen)
	local function toggleMinimize()
		if Window.IsMinimized then
			-- Restore with smooth animation
			minimizeIcon.Visible = false
			mainFrame.Visible = true
			CreateTween(mainFrame, {Size = windowConfig.Size, Position = windowConfig.Position}, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out):Play()
			Window.IsMinimized = false
		else
			-- Minimize with smooth animation
			CreateTween(mainFrame, {Size = UDim2.new(0, 0, 0, 0), Position = minimizeIcon.Position}, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In).Completed:Connect(function()
				mainFrame.Visible = false
				minimizeIcon.Visible = true
			end)
			CreateTween(mainFrame, {Size = UDim2.new(0, 0, 0, 0), Position = minimizeIcon.Position}, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In):Play()
			Window.IsMinimized = true
		end
	end
	
	-- Button connections
	Window._connections[#Window._connections + 1] = minimizeBtn.MouseButton1Click:Connect(toggleMinimize)
	Window._connections[#Window._connections + 1] = minimizeIcon.MouseButton1Click:Connect(toggleMinimize)
	
	Window._connections[#Window._connections + 1] = closeBtn.MouseButton1Click:Connect(function()
		-- Smooth close animation
		CreateTween(mainFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.2).Completed:Connect(function()
			for _, connection in pairs(Window._connections) do
				connection:Disconnect()
			end
			for object, tween in pairs(activeTweens) do
				tween:Cancel()
			end
			screenGui:Destroy()
		end)
		CreateTween(mainFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.2):Play()
	end)
	
	-- Keybind handling
	Window._connections[#Window._connections + 1] = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		
		if input.KeyCode == windowConfig.ToggleUIKeybind then
			if screenGui.Enabled then
				CreateTween(mainFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.15).Completed:Connect(function()
					screenGui.Enabled = false
				end)
				CreateTween(mainFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.15):Play()
			else
				screenGui.Enabled = true
				mainFrame.Size = UDim2.new(0, 0, 0, 0)
				CreateTween(mainFrame, {Size = windowConfig.Size}, 0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out):Play()
			end
		elseif input.KeyCode == windowConfig.MinimizeKeybind then
			toggleMinimize()
		end
	end)
	
	-- Improved hover effects
	local function addHoverEffect(button, hoverColor, normalColor, scale)
		scale = scale or 1.05
		Window._connections[#Window._connections + 1] = button.MouseEnter:Connect(function()
			CreateTween(button, {BackgroundColor3 = hoverColor, Size = button.Size * scale}, 0.1):Play()
		end)
		
		Window._connections[#Window._connections + 1] = button.MouseLeave:Connect(function()
			CreateTween(button, {BackgroundColor3 = normalColor, Size = button.Size / scale}, 0.1):Play()
		end)
	end
	
	addHoverEffect(minimizeBtn, Color3.new(0.369, 0.216, 0.431), Colors.AccentPrimary, 1.1)
	addHoverEffect(closeBtn, Color3.new(0.941, 0.286, 0.349), Color3.new(0.863, 0.208, 0.271), 1.1)
	addHoverEffect(minimizeIcon, Color3.new(0.369, 0.216, 0.431), Colors.AccentPrimary, 1.05)
	
	-- Sidebar canvas size update
	local function updateSidebarCanvas()
		sidebarScroll.CanvasSize = UDim2.new(0, 0, 0, sidebarLayout.AbsoluteContentSize.Y + 6)
	end
	
	Window._connections[#Window._connections + 1] = sidebarLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateSidebarCanvas)
	
	-- Window methods
	function Window:CreateTab(name, icon)
		local Tab = {
			Name = name,
			Icon = icon or "📄",
			Elements = {},
			Sections = {},
			_connections = {}
		}
		
		-- Improved Tab Button (smaller)
		local tabButton = Instance.new("TextButton")
		tabButton.Name = "Tab_" .. name
		tabButton.BackgroundColor3 = Colors.Primary
		tabButton.BackgroundTransparency = 0.1
		tabButton.BorderSizePixel = 0
		tabButton.Size = UDim2.new(1, -6, 0, 30) -- Reduced from 36
		tabButton.Text = ""
		tabButton.Parent = self.Sidebar
		
		CreateCorner(tabButton, 5)
		CreateStroke(tabButton, Colors.Border, 1)
		
		-- Tab Icon (smaller)
		local tabIcon = Instance.new("TextLabel")
		tabIcon.BackgroundTransparency = 1
		tabIcon.Size = UDim2.new(0, 18, 0, 18) -- Reduced from 24
		tabIcon.Position = UDim2.new(0, 6, 0.5, -9)
		tabIcon.Text = icon or "📄"
		tabIcon.TextColor3 = Colors.TextDark
		tabIcon.TextSize = 12
		tabIcon.Font = Enum.Font.Gotham
		tabIcon.Parent = tabButton
		
		-- Tab Label (smaller)
		local tabLabel = Instance.new("TextLabel")
		tabLabel.BackgroundTransparency = 1
		tabLabel.Size = UDim2.new(1, -30, 1, 0)
		tabLabel.Position = UDim2.new(0, 28, 0, 0)
		tabLabel.Text = name
		tabLabel.TextColor3 = Colors.TextDark
		tabLabel.TextSize = 11 -- Fixed size
		tabLabel.TextXAlignment = Enum.TextXAlignment.Left
		tabLabel.Font = Enum.Font.GothamMedium
		tabLabel.Parent = tabButton
		
		-- Tab Content Frame
		local tabContentFrame = Instance.new("ScrollingFrame")
		tabContentFrame.Name = "TabContent_" .. name
		tabContentFrame.BackgroundTransparency = 1
	tabContentFrame.Size = UDim2.new(1, -12, 1, -12)
	tabContentFrame.Position = UDim2.new(0, 6, 0, 6)
	tabContentFrame.ScrollBarThickness = 3
	tabContentFrame.ScrollBarImageColor3 = Colors.AccentPrimary
	tabContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	tabContentFrame.Visible = false
	tabContentFrame.ScrollingDirection = Enum.ScrollingDirection.Y
	tabContentFrame.Parent = self.Content
		
		-- Tab Layout (tighter spacing)
		local tabLayout = Instance.new("UIListLayout")
		tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
		tabLayout.Padding = UDim.new(0, 6) -- Reduced from 8
		tabLayout.Parent = tabContentFrame
		
		Tab.Button = tabButton
		Tab.Content = tabContentFrame
		Tab.Layout = tabLayout
		
		-- Tab selection with animation
		local function selectTab()
			for _, tab in pairs(self.Tabs) do
				tab.Content.Visible = false
				CreateTween(tab.Button, {BackgroundColor3 = Colors.Primary}, 0.15):Play()
			end
			
			tabContentFrame.Visible = true
			CreateTween(tabButton, {BackgroundColor3 = Colors.Highlight}, 0.15):Play()
			self.CurrentTab = Tab
		end
		
		Tab._connections[#Tab._connections + 1] = tabButton.MouseButton1Click:Connect(selectTab)
		
		-- Improved hover effect for tab
		addHoverEffect(tabButton, Colors.Secondary, Colors.Primary, 1.02)
		
		-- Auto-select first tab
		if #self.Tabs == 0 then
			selectTab()
		end
		
		self.Tabs[#self.Tabs + 1] = Tab
		
		-- Canvas size update
		local function updateTabCanvas()
			tabContentFrame.CanvasSize = UDim2.new(0, 0, 0, tabLayout.AbsoluteContentSize.Y + 12)
		end
		
		Tab._connections[#Tab._connections + 1] = tabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateTabCanvas)
		
		-- Tab methods
		function Tab:CreateSection(name)
			local Section = {
				Name = name,
				Elements = {},
				_connections = {}
			}
			
			-- Improved Section Frame (smaller)
			local sectionFrame = Instance.new("Frame")
			sectionFrame.Name = "Section_" .. name
			sectionFrame.BackgroundColor3 = Colors.Secondary
			sectionFrame.BackgroundTransparency = 0.2
			sectionFrame.BorderSizePixel = 0
			sectionFrame.Size = UDim2.new(1, 0, 0, 40) -- Reduced initial size
			sectionFrame.Parent = self.Content
			
			CreateCorner(sectionFrame, 6)
			CreateStroke(sectionFrame, Colors.Border, 1)
			
			-- Improved Section Title (smaller)
			local sectionTitle = Instance.new("TextLabel")
			sectionTitle.BackgroundTransparency = 1
			sectionTitle.Size = UDim2.new(1, -12, 0, 22) -- Reduced from 28
			sectionTitle.Position = UDim2.new(0, 6, 0, 6)
			sectionTitle.Text = name
			sectionTitle.TextColor3 = Colors.TextDark
			sectionTitle.TextSize = 12 -- Fixed size
			sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
			sectionTitle.Font = Enum.Font.GothamBold
			sectionTitle.Parent = sectionFrame
			
			-- Section Content (adjusted)
			local sectionContent = Instance.new("Frame")
			sectionContent.BackgroundTransparency = 1
			sectionContent.Size = UDim2.new(1, -12, 1, -34) -- Adjusted
			sectionContent.Position = UDim2.new(0, 6, 0, 28)
			sectionContent.Parent = sectionFrame
			
			-- Section Layout (tighter spacing)
			local sectionLayout = Instance.new("UIListLayout")
			sectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
			sectionLayout.Padding = UDim.new(0, 4) -- Reduced from 6
			sectionLayout.Parent = sectionContent
			
			Section.Frame = sectionFrame
			Section.Content = sectionContent
			Section.Layout = sectionLayout
			
			-- Section size update
			local function updateSectionSize()
				local contentSize = sectionLayout.AbsoluteContentSize.Y
				sectionFrame.Size = UDim2.new(1, 0, 0, contentSize + 40) -- Adjusted
			end
			
			Section._connections[#Section._connections + 1] = sectionLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateSectionSize)
			
			self.Sections[#self.Sections + 1] = Section
			
			-- Section methods
			function Section:CreateButton(config)
				config = config or {}
				local buttonConfig = {
					Name = config.Name or "Button",
					Callback = config.Callback or function() end
				}
				
				local button = Instance.new("TextButton")
				button.Name = "Button_" .. buttonConfig.Name
				button.BackgroundColor3 = Colors.AccentPrimary
				button.BorderSizePixel = 0
				button.Size = UDim2.new(1, 0, 0, 26) -- Reduced from 32
				button.Text = buttonConfig.Name
				button.TextColor3 = Colors.Primary
				button.TextSize = 11 -- Fixed size
				button.Font = Enum.Font.GothamMedium
				button.Parent = self.Content
				
				CreateCorner(button, 5)
				
				self._connections[#self._connections + 1] = button.MouseButton1Click:Connect(buttonConfig.Callback)
				addHoverEffect(button, Color3.new(0.369, 0.216, 0.431), Colors.AccentPrimary, 1.02)
				
				return button
			end
			
			function Section:CreateToggle(config)
				config = config or {}
				local toggleConfig = {
					Name = config.Name or "Toggle",
					Default = config.Default or false,
					Callback = config.Callback or function() end
				}
				
				-- Improved Toggle Frame (smaller)
				local toggleFrame = Instance.new("Frame")
				toggleFrame.Name = "Toggle_" .. toggleConfig.Name
				toggleFrame.BackgroundColor3 = Colors.Primary
				toggleFrame.BackgroundTransparency = 0.1
				toggleFrame.BorderSizePixel = 0
				toggleFrame.Size = UDim2.new(1, 0, 0, 26) -- Reduced from 32
				toggleFrame.Parent = self.Content
				
				CreateCorner(toggleFrame, 5)
				CreateStroke(toggleFrame, Colors.Border, 1)
				
				-- Toggle Label (smaller)
				local toggleLabel = Instance.new("TextLabel")
				toggleLabel.BackgroundTransparency = 1
				toggleLabel.Size = UDim2.new(1, -40, 1, 0)
				toggleLabel.Position = UDim2.new(0, 6, 0, 0)
				toggleLabel.Text = toggleConfig.Name
				toggleLabel.TextColor3 = Colors.TextDark
				toggleLabel.TextSize = 10 -- Fixed size
				toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
				toggleLabel.Font = Enum.Font.GothamMedium
				toggleLabel.Parent = toggleFrame
				
				-- Toggle Button (smaller)
				local toggleButton = Instance.new("TextButton")
				toggleButton.BackgroundColor3 = toggleConfig.Default and Colors.Highlight or Colors.AccentSecondary
				toggleButton.BorderSizePixel = 0
				toggleButton.Size = UDim2.new(0, 30, 0, 14) -- Reduced
				toggleButton.Position = UDim2.new(1, -36, 0.5, -7)
				toggleButton.Text = ""
				toggleButton.Parent = toggleFrame
				
				CreateCorner(toggleButton, 7)
				
				-- Toggle Indicator (smaller)
				local toggleIndicator = Instance.new("Frame")
				toggleIndicator.BackgroundColor3 = Colors.Primary
				toggleIndicator.BorderSizePixel = 0
				toggleIndicator.Size = UDim2.new(0, 10, 0, 10) -- Reduced
				toggleIndicator.Position = toggleConfig.Default and UDim2.new(1, -12, 0.5, -5) or UDim2.new(0, 2, 0.5, -5)
				toggleIndicator.Text = ""
				toggleIndicator.Parent = toggleButton
				
				CreateCorner(toggleIndicator, 5)
				
				local isToggled = toggleConfig.Default
				
				-- Improved toggle update with animation
				local function updateToggle()
					local newColor = isToggled and Colors.Highlight or Colors.AccentSecondary
					local newPosition = isToggled and UDim2.new(1, -12, 0.5, -5) or UDim2.new(0, 2, 0.5, -5)
					
					CreateTween(toggleButton, {BackgroundColor3 = newColor}, 0.15):Play()
					CreateTween(toggleIndicator, {Position = newPosition}, 0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out):Play()
					
					toggleConfig.Callback(isToggled)
				end
				
				self._connections[#self._connections + 1] = toggleButton.MouseButton1Click:Connect(function()
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
			
			-- New Slider Component
			function Section:CreateSlider(config)
				config = config or {}
				local sliderConfig = {
					Name = config.Name or "Slider",
					Min = config.Min or 0,
					Max = config.Max or 100,
					Default = config.Default or 50,
					Callback = config.Callback or function() end
				}
				
				local sliderFrame = Instance.new("Frame")
				sliderFrame.Name = "Slider_" .. sliderConfig.Name
				sliderFrame.BackgroundColor3 = Colors.Primary
				sliderFrame.BackgroundTransparency = 0.1
				sliderFrame.BorderSizePixel = 0
				sliderFrame.Size = UDim2.new(1, 0, 0, 40) -- Slightly taller for slider
				sliderFrame.Parent = self.Content
				
				CreateCorner(sliderFrame, 5)
				CreateStroke(sliderFrame, Colors.Border, 1)
				
				-- Slider Label
				local sliderLabel = Instance.new("TextLabel")
				sliderLabel.BackgroundTransparency = 1
				sliderLabel.Size = UDim2.new(0.7, 0, 0, 16)
				sliderLabel.Position = UDim2.new(0, 6, 0, 4)
				sliderLabel.Text = sliderConfig.Name
				sliderLabel.TextColor3 = Colors.TextDark
				sliderLabel.TextSize = 10
				sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
				sliderLabel.Font = Enum.Font.GothamMedium
				sliderLabel.Parent = sliderFrame
				
				-- Value Label
				local valueLabel = Instance.new("TextLabel")
				valueLabel.BackgroundTransparency = 1
				valueLabel.Size = UDim2.new(0.3, 0, 0, 16)
				valueLabel.Position = UDim2.new(0.7, 0, 0, 4)
				valueLabel.Text = tostring(sliderConfig.Default)
				valueLabel.TextColor3 = Colors.TextDark
				valueLabel.TextSize = 10
				valueLabel.TextXAlignment = Enum.TextXAlignment.Right
				valueLabel.Font = Enum.Font.GothamMedium
				valueLabel.Parent = sliderFrame
				
				-- Slider Track
				local sliderTrack = Instance.new("Frame")
				sliderTrack.BackgroundColor3 = Colors.AccentSecondary
				sliderTrack.BorderSizePixel = 0
				sliderTrack.Size = UDim2.new(1, -12, 0, 4)
				sliderTrack.Position = UDim2.new(0, 6, 1, -12)
				sliderTrack.Parent = sliderFrame
				
				CreateCorner(sliderTrack, 2)
				
				-- Slider Fill
				local sliderFill = Instance.new("Frame")
				sliderFill.BackgroundColor3 = Colors.Highlight
				sliderFill.BorderSizePixel = 0
				sliderFill.Size = UDim2.new((sliderConfig.Default - sliderConfig.Min) / (sliderConfig.Max - sliderConfig.Min), 0, 1, 0)
				sliderFill.Position = UDim2.new(0, 0, 0, 0)
				sliderFill.Parent = sliderTrack
				
				CreateCorner(sliderFill, 2)
				
				-- Slider Handle
				local sliderHandle = Instance.new("TextButton")
				sliderHandle.BackgroundColor3 = Colors.Primary
				sliderHandle.BorderSizePixel = 0
				sliderHandle.Size = UDim2.new(0, 12, 0, 12)
				sliderHandle.Position = UDim2.new((sliderConfig.Default - sliderConfig.Min) / (sliderConfig.Max - sliderConfig.Min), -6, 0.5, -6)
				sliderHandle.Text = ""
				sliderHandle.Parent = sliderTrack
				
				CreateCorner(sliderHandle, 6)
				CreateStroke(sliderHandle, Colors.Border, 1)
				
				local currentValue = sliderConfig.Default
				local dragging = false
				
				local function updateSlider(value)
					currentValue = math.clamp(value, sliderConfig.Min, sliderConfig.Max)
					local percentage = (currentValue - sliderConfig.Min) / (sliderConfig.Max - sliderConfig.Min)
					
					CreateTween(sliderFill, {Size = UDim2.new(percentage, 0, 1, 0)}, 0.1):Play()
					CreateTween(sliderHandle, {Position = UDim2.new(percentage, -6, 0.5, -6)}, 0.1):Play()
					
					valueLabel.Text = tostring(math.floor(currentValue))
					sliderConfig.Callback(currentValue)
				end
				
				sliderHandle.MouseButton1Down:Connect(function()
					dragging = true
					-- Capture mouse position relative to handle for smooth dragging
					local mouseX = UserInputService:GetMouseLocation().X
					local handleX = sliderHandle.AbsolutePosition.X
					local offset = mouseX - handleX
					
					local connection
					connection = RunService.RenderStepped:Connect(function()
						if dragging then
							local mousePos = UserInputService:GetMouseLocation()
							local trackPos = sliderTrack.AbsolutePosition
							local trackSize = sliderTrack.AbsoluteSize
							
							local percentage = math.clamp((mousePos.X - trackPos.X - offset + (sliderHandle.AbsoluteSize.X / 2)) / trackSize.X, 0, 1)
							local newValue = sliderConfig.Min + (percentage * (sliderConfig.Max - sliderConfig.Min))
							
							updateSlider(newValue)
						else
							connection:Disconnect()
						end
					end)
					end)
				
				UserInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = false
					end
					end)
				
				return {
					Set = function(value)
						updateSlider(value)
					end,
					Get = function()
						return currentValue
					end
				}
			end
			
			-- New Dropdown Component
			function Section:CreateDropdown(config)
				config = config or {}
				local dropdownConfig = {
					Name = config.Name or "Dropdown",
					Options = config.Options or {"Option 1", "Option 2", "Option 3"},
					Default = config.Default or config.Options[1],
					Callback = config.Callback or function() end
				}
				
				local dropdownFrame = Instance.new("Frame")
				dropdownFrame.Name = "Dropdown_" .. dropdownConfig.Name
				dropdownFrame.BackgroundColor3 = Colors.Primary
				dropdownFrame.BackgroundTransparency = 0.1
				dropdownFrame.BorderSizePixel = 0
				dropdownFrame.Size = UDim2.new(1, 0, 0, 26)
				dropdownFrame.Parent = self.Content
				
				CreateCorner(dropdownFrame, 5)
				CreateStroke(dropdownFrame, Colors.Border, 1)
				
				-- Dropdown Label
				local dropdownLabel = Instance.new("TextLabel")
				dropdownLabel.BackgroundTransparency = 1
				dropdownLabel.Size = UDim2.new(0.4, 0, 1, 0)
				dropdownLabel.Position = UDim2.new(0, 6, 0, 0)
				dropdownLabel.Text = dropdownConfig.Name
				dropdownLabel.TextColor3 = Colors.TextDark
				dropdownLabel.TextSize = 10
				dropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
				dropdownLabel.Font = Enum.Font.GothamMedium
				dropdownLabel.Parent = dropdownFrame
				
				-- Dropdown Button
				local dropdownButton = Instance.new("TextButton")
				dropdownButton.BackgroundColor3 = Colors.Secondary
				dropdownButton.BorderSizePixel = 0
				dropdownButton.Size = UDim2.new(0.55, 0, 0, 20)
				dropdownButton.Position = UDim2.new(0.42, 0, 0.5, -10)
				dropdownButton.Text = dropdownConfig.Default .. " ▼"
				dropdownButton.TextColor3 = Colors.TextDark
				dropdownButton.TextSize = 9
				dropdownButton.Font = Enum.Font.GothamMedium
				dropdownButton.Parent = dropdownFrame
				
				CreateCorner(dropdownButton, 4)
				CreateStroke(dropdownButton, Colors.Border, 1)
				
				-- Dropdown List (now a ScrollingFrame)
				local dropdownList = Instance.new("ScrollingFrame")
				dropdownList.BackgroundColor3 = Colors.Primary
				dropdownList.BorderSizePixel = 0
				dropdownList.Size = UDim2.new(0.55, 0, 0, math.min(#dropdownConfig.Options, 5) * 22) -- Limit visible options to 5
				dropdownList.Position = UDim2.new(0.42, 0, 1, 2)
				dropdownList.Visible = false
				dropdownList.ZIndex = 10
				dropdownList.Parent = dropdownFrame
				dropdownList.ScrollBarThickness = 3
				dropdownList.ScrollBarImageColor3 = Colors.AccentPrimary
				dropdownList.ScrollingDirection = Enum.ScrollingDirection.Y
				
				CreateCorner(dropdownList, 4)
				CreateStroke(dropdownList, Colors.Border, 1)
				
				-- Dropdown Layout
				local dropdownLayout = Instance.new("UIListLayout")
				dropdownLayout.SortOrder = Enum.SortOrder.LayoutOrder
				dropdownLayout.Padding = UDim.new(0, 1)
				dropdownLayout.Parent = dropdownList
				
				local currentValue = dropdownConfig.Default
				local isOpen = false
				
				-- Create option buttons
				for i, option in ipairs(dropdownConfig.Options) do
					local optionButton = Instance.new("TextButton")
					optionButton.BackgroundColor3 = Colors.Secondary
					optionButton.BackgroundTransparency = 0.2
					optionButton.BorderSizePixel = 0
					optionButton.Size = UDim2.new(1, 0, 0, 20)
					optionButton.Text = option
					optionButton.TextColor3 = Colors.TextDark
					optionButton.TextSize = 9
					optionButton.Font = Enum.Font.GothamMedium
					optionButton.Parent = dropdownList
					
					optionButton.MouseButton1Click:Connect(function()
						currentValue = option
						dropdownButton.Text = option .. " ▼"
						dropdownList.Visible = false
						isOpen = false
						dropdownConfig.Callback(option)
					end)
					
					addHoverEffect(optionButton, Colors.Highlight, Colors.Secondary, 1.01)
				end
				
				dropdownButton.MouseButton1Click:Connect(function()
					isOpen = not isOpen
					dropdownList.Visible = isOpen
					dropdownButton.Text = currentValue .. (isOpen and " ▲" or " ▼")
					
					-- Update CanvasSize for dropdownList
					dropdownList.CanvasSize = UDim2.new(0, 0, 0, dropdownLayout.AbsoluteContentSize.Y)
				end)
				
				return {
					Set = function(value)
						if table.find(dropdownConfig.Options, value) then
							currentValue = value
							dropdownButton.Text = value .. " ▼"
							dropdownConfig.Callback(value)
						end
					end,
					Get = function()
						return currentValue
						end
				}
			end
			
			return Section
		end
		
		return Tab
	end
	
	-- Notification method for window
	function Window:Notify(title, message, duration)
		spawn(function()
			CreateNotification(title, message, duration)
		end)
	end
	
	return Window
end

-- Cleanup function
function SpaceMangaLib:Cleanup()
	for object, tween in pairs(activeTweens) do
		tween:Cancel()
	end
	activeTweens = {}
end

return SpaceMangaLib

