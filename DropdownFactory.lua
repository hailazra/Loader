--[[
	DropdownFactory.lua
	Factory untuk membuat dropdown dengan animasi dan konfigurasi yang fleksibel
	
	Fitur:
	- Dropdown dengan animasi smooth
	- Konfigurasi yang dapat disesuaikan
	- Support untuk berbagai jenis konten
	- Event callbacks
]]

local DropdownFactory = {}

-- Import modules
local DropdownModule = require(script.Parent.DropdownModule)
local NestedDropdownModule = require(script.Parent.NestedDropdownModule)

-- Services
local TweenService = game:GetService("TweenService")

function DropdownFactory.createDropdown(parent, title, contentBuilder, config)
	config = config or {}
	
	-- Merge dengan konfigurasi default
	local finalConfig = {
		animationDuration = config.animationDuration or DropdownModule.Config.Animation.Duration,
		easingStyle = config.easingStyle or DropdownModule.Config.Animation.EasingStyle,
		easingDirection = config.easingDirection or DropdownModule.Config.Animation.EasingDirection,
		buttonColor = config.buttonColor or DropdownModule.Config.Colors.ButtonBackground,
		dropdownColor = config.dropdownColor or DropdownModule.Config.Colors.DropdownBackground,
		startExpanded = config.startExpanded or false,
		onToggle = config.onToggle,
		customIcons = config.customIcons or {
			collapsed = "> ",
			expanded = "⌄ "
		}
	}
	
	-- Membuat button utama
	local btn = DropdownModule.createButton(finalConfig.customIcons.collapsed .. title, {
		backgroundColor = finalConfig.buttonColor
	})
	btn.Parent = parent
	
	-- Membuat container untuk konten dropdown
	local dropdown = DropdownModule.createFrame(parent, title.."Content", finalConfig.dropdownColor)
	dropdown.Visible = finalConfig.startExpanded
	
	-- State tracking
	local isExpanded = finalConfig.startExpanded
	
	-- Update button text berdasarkan state
	if isExpanded then
		btn.Text = finalConfig.customIcons.expanded .. title
	end
	
	-- Build konten menggunakan contentBuilder
	if contentBuilder and type(contentBuilder) == "function" then
		contentBuilder(dropdown, DropdownModule, NestedDropdownModule)
	end
	
	-- Animation function
	local function animateDropdown(expand)
		if expand then
			-- Expanding animation
			dropdown.Visible = true
			dropdown.Size = UDim2.new(1, 0, 0, 0)
			
			-- Wait satu frame untuk layout calculation
			task.wait()
			
			local targetHeight = dropdown.AbsoluteSize.Y
			dropdown.Size = UDim2.new(1, 0, 0, 0)
			
			local tween = TweenService:Create(
				dropdown,
				TweenInfo.new(
					finalConfig.animationDuration,
					finalConfig.easingStyle,
					finalConfig.easingDirection
				),
				{Size = UDim2.new(1, 0, 0, targetHeight)}
			)
			
			tween:Play()
			btn.Text = finalConfig.customIcons.expanded .. title
			
		else
			-- Collapsing animation
			local tween = TweenService:Create(
				dropdown,
				TweenInfo.new(
					finalConfig.animationDuration,
					finalConfig.easingStyle,
					finalConfig.easingDirection
				),
				{Size = UDim2.new(1, 0, 0, 0)}
			)
			
			tween:Play()
			tween.Completed:Connect(function()
				dropdown.Visible = false
			end)
			
			btn.Text = finalConfig.customIcons.collapsed .. title
		end
	end
	
	-- Toggle function
	local function toggle()
		isExpanded = not isExpanded
		animateDropdown(isExpanded)
		
		-- Call callback jika ada
		if finalConfig.onToggle then
			finalConfig.onToggle(isExpanded, dropdown)
		end
	end
	
	-- Connect button click
	btn.MouseButton1Click:Connect(toggle)
	
	-- Return object dengan methods
	local dropdownObject = {
		button = btn,
		content = dropdown,
		isExpanded = function() return isExpanded end,
		expand = function() 
			if not isExpanded then toggle() end 
		end,
		collapse = function() 
			if isExpanded then toggle() end 
		end,
		toggle = toggle,
		setTitle = function(newTitle)
			title = newTitle
			btn.Text = (isExpanded and finalConfig.customIcons.expanded or finalConfig.customIcons.collapsed) .. title
		end,
		addContent = function(element)
			element.Parent = dropdown
		end,
		removeContent = function(element)
			if element and element.Parent == dropdown then
				element:Destroy()
			end
		end,
		clearContent = function()
			for _, child in ipairs(dropdown:GetChildren()) do
				if not child:IsA("UIListLayout") then
					child:Destroy()
				end
			end
		end
	}
	
	return dropdownObject
end

-- Preset factory functions untuk use cases umum
function DropdownFactory.createSettingsDropdown(parent, title, settings, config)
	return DropdownFactory.createDropdown(parent, title, function(dropdown, DropdownModule, NestedDropdownModule)
		for _, setting in ipairs(settings) do
			if setting.type == "toggle" then
				local toggle = DropdownModule.createToggle(setting.text, {
					defaultState = setting.defaultValue,
					onToggle = setting.callback
				})
				toggle.Parent = dropdown
				
			elseif setting.type == "slider" then
				local slider = DropdownModule.createSlider(setting.min, setting.max, {
					defaultValue = setting.defaultValue,
					prefix = setting.prefix,
					onValueChanged = setting.callback
				})
				slider.Parent = dropdown
				
			elseif setting.type == "textbox" then
				local textbox = DropdownModule.createTextBox(setting.placeholder, {
					defaultText = setting.defaultValue
				})
				textbox.Parent = dropdown
				
				if setting.callback then
					textbox.FocusLost:Connect(function()
						setting.callback(textbox.Text)
					end)
				end
				
			elseif setting.type == "button" then
				local button = DropdownModule.createButton(setting.text)
				button.Parent = dropdown
				
				if setting.callback then
					button.MouseButton1Click:Connect(setting.callback)
				end
			end
		end
	end, config)
end

function DropdownFactory.createMenuDropdown(parent, title, menuItems, config)
	return DropdownFactory.createDropdown(parent, title, function(dropdown, DropdownModule, NestedDropdownModule)
		for _, item in ipairs(menuItems) do
			if item.type == "nested" then
				local btn = DropdownModule.createButton(item.text .. " >")
				btn.Parent = dropdown
				NestedDropdownModule.createNestedDropdown(btn, item.items, config)
				
			elseif item.type == "button" then
				local btn = DropdownModule.createButton(item.text)
				btn.Parent = dropdown
				
				if item.callback then
					btn.MouseButton1Click:Connect(item.callback)
				end
				
			elseif item.type == "separator" then
				local separator = Instance.new("Frame")
				separator.Size = UDim2.new(1, 0, 0, 1)
				separator.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
				separator.BorderSizePixel = 0
				separator.Parent = dropdown
			end
		end
	end, config)
end

return DropdownFactory

