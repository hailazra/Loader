--[[
	DropdownManager.lua
	Manager untuk mengelola multiple dropdown instances
	
	Fitur:
	- Global state management
	- Event coordination
	- Bulk operations
	- Theme management
]]

local DropdownManager = {}

-- Import modules
local DropdownModule = require(script.Parent.DropdownModule)
local DropdownFactory = require(script.Parent.DropdownFactory)
local NestedDropdownModule = require(script.Parent.NestedDropdownModule)

-- Services
local UserInputService = game:GetService("UserInputService")

-- Global state
local registeredDropdowns = {}
local globalConfig = {}
local isInitialized = false

-- Initialize manager
function DropdownManager.initialize(config)
	if isInitialized then
		return
	end
	
	config = config or {}
	
	-- Merge dengan konfigurasi default
	globalConfig = {
		autoCloseOnOutsideClick = config.autoCloseOnOutsideClick ~= false,
		maxOpenDropdowns = config.maxOpenDropdowns or math.huge,
		globalTheme = config.globalTheme or "default",
		animationSpeed = config.animationSpeed or 1.0
	}
	
	-- Setup global event handlers
	if globalConfig.autoCloseOnOutsideClick then
		setupGlobalClickHandler()
	end
	
	isInitialized = true
end

-- Global click handler untuk menutup dropdown saat klik di luar
function setupGlobalClickHandler()
	UserInputService.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			local mousePos = UserInputService:GetMouseLocation()
			local clickedInside = false
			
			-- Check semua dropdown yang terdaftar
			for _, dropdownData in pairs(registeredDropdowns) do
				if dropdownData.dropdown.isExpanded() then
					local content = dropdownData.dropdown.content
					local pos, size = content.AbsolutePosition, content.AbsoluteSize
					
					if mousePos.X > pos.X and mousePos.X < pos.X + size.X and
					   mousePos.Y > pos.Y and mousePos.Y < pos.Y + size.Y then
						clickedInside = true
						break
					end
				end
			end
			
			if not clickedInside then
				DropdownManager.collapseAll()
				NestedDropdownModule.closeAllNestedDropdowns()
			end
		end
	end)
end

-- Register dropdown ke manager
function DropdownManager.register(id, dropdown, metadata)
	if not isInitialized then
		DropdownManager.initialize()
	end
	
	metadata = metadata or {}
	
	registeredDropdowns[id] = {
		dropdown = dropdown,
		metadata = metadata,
		registeredAt = tick()
	}
	
	-- Apply global theme jika ada
	if globalConfig.globalTheme and globalConfig.globalTheme ~= "default" then
		DropdownManager.applyTheme(id, globalConfig.globalTheme)
	end
end

-- Unregister dropdown
function DropdownManager.unregister(id)
	registeredDropdowns[id] = nil
end

-- Get dropdown by ID
function DropdownManager.get(id)
	local data = registeredDropdowns[id]
	return data and data.dropdown or nil
end

-- Get all registered dropdowns
function DropdownManager.getAll()
	local dropdowns = {}
	for id, data in pairs(registeredDropdowns) do
		dropdowns[id] = data.dropdown
	end
	return dropdowns
end

-- Collapse all dropdowns
function DropdownManager.collapseAll(except)
	except = except or {}
	local exceptSet = {}
	
	if type(except) == "string" then
		exceptSet[except] = true
	elseif type(except) == "table" then
		for _, id in ipairs(except) do
			exceptSet[id] = true
		end
	end
	
	for id, data in pairs(registeredDropdowns) do
		if not exceptSet[id] and data.dropdown.isExpanded() then
			data.dropdown.collapse()
		end
	end
end

-- Expand specific dropdowns
function DropdownManager.expand(ids)
	if type(ids) == "string" then
		ids = {ids}
	end
	
	for _, id in ipairs(ids) do
		local data = registeredDropdowns[id]
		if data and not data.dropdown.isExpanded() then
			data.dropdown.expand()
		end
	end
end

-- Toggle specific dropdowns
function DropdownManager.toggle(ids)
	if type(ids) == "string" then
		ids = {ids}
	end
	
	for _, id in ipairs(ids) do
		local data = registeredDropdowns[id]
		if data then
			data.dropdown.toggle()
		end
	end
end

-- Apply theme ke dropdown
function DropdownManager.applyTheme(id, themeName)
	local data = registeredDropdowns[id]
	if not data then
		return false
	end
	
	local themes = {
		dark = {
			buttonColor = Color3.fromRGB(60, 60, 60),
			dropdownColor = Color3.fromRGB(45, 45, 45),
			textColor = Color3.fromRGB(255, 255, 255)
		},
		light = {
			buttonColor = Color3.fromRGB(240, 240, 240),
			dropdownColor = Color3.fromRGB(250, 250, 250),
			textColor = Color3.fromRGB(50, 50, 50)
		},
		blue = {
			buttonColor = Color3.fromRGB(70, 130, 180),
			dropdownColor = Color3.fromRGB(100, 149, 237),
			textColor = Color3.fromRGB(255, 255, 255)
		}
	}
	
	local theme = themes[themeName]
	if not theme then
		return false
	end
	
	-- Apply theme ke button
	data.dropdown.button.BackgroundColor3 = theme.buttonColor
	data.dropdown.button.TextColor3 = theme.textColor
	
	-- Apply theme ke content
	data.dropdown.content.BackgroundColor3 = theme.dropdownColor
	
	-- Apply theme ke children
	for _, child in ipairs(data.dropdown.content:GetChildren()) do
		if child:IsA("TextButton") then
			child.TextColor3 = theme.textColor
		end
	end
	
	return true
end

-- Apply theme ke semua dropdown
function DropdownManager.applyGlobalTheme(themeName)
	globalConfig.globalTheme = themeName
	
	for id, _ in pairs(registeredDropdowns) do
		DropdownManager.applyTheme(id, themeName)
	end
end

-- Get statistics
function DropdownManager.getStats()
	local stats = {
		totalRegistered = 0,
		currentlyExpanded = 0,
		registeredIds = {}
	}
	
	for id, data in pairs(registeredDropdowns) do
		stats.totalRegistered = stats.totalRegistered + 1
		table.insert(stats.registeredIds, id)
		
		if data.dropdown.isExpanded() then
			stats.currentlyExpanded = stats.currentlyExpanded + 1
		end
	end
	
	return stats
end

-- Cleanup function
function DropdownManager.cleanup()
	for id, data in pairs(registeredDropdowns) do
		if data.dropdown.button then
			data.dropdown.button:Destroy()
		end
		if data.dropdown.content then
			data.dropdown.content:Destroy()
		end
	end
	
	table.clear(registeredDropdowns)
	isInitialized = false
end

-- Helper function untuk membuat dan register dropdown sekaligus
function DropdownManager.createAndRegister(id, parent, title, contentBuilder, config)
	local dropdown = DropdownFactory.createDropdown(parent, title, contentBuilder, config)
	DropdownManager.register(id, dropdown, {
		title = title,
		parent = parent
	})
	return dropdown
end

-- Helper function untuk membuat settings dropdown dan register
function DropdownManager.createSettingsAndRegister(id, parent, title, settings, config)
	local dropdown = DropdownFactory.createSettingsDropdown(parent, title, settings, config)
	DropdownManager.register(id, dropdown, {
		title = title,
		parent = parent,
		type = "settings"
	})
	return dropdown
end

-- Helper function untuk membuat menu dropdown dan register
function DropdownManager.createMenuAndRegister(id, parent, title, menuItems, config)
	local dropdown = DropdownFactory.createMenuDropdown(parent, title, menuItems, config)
	DropdownManager.register(id, dropdown, {
		title = title,
		parent = parent,
		type = "menu"
	})
	return dropdown
end

return DropdownManager

