--[[
	DropdownModule.lua
	Modul utama untuk sistem dropdown yang modular
	
	Fitur:
	- Dropdown dengan animasi
	- Nested dropdown
	- Komponen UI (button, textbox, toggle, slider)
	- Event handling
]]

local DropdownModule = {}

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Konfigurasi default
DropdownModule.Config = {
	Colors = {
		Background = Color3.fromRGB(245, 245, 245),
		DropdownBackground = Color3.fromRGB(230, 230, 230),
		ButtonBackground = Color3.fromRGB(210, 210, 210),
		TextBoxBackground = Color3.fromRGB(220, 220, 255),
		SliderBackground = Color3.fromRGB(180, 180, 250),
		NestedBackground = Color3.fromRGB(250, 240, 220)
	},
	Sizes = {
		ButtonHeight = 36,
		Padding = 5,
		NestedWidth = 160
	},
	Animation = {
		Duration = 0.25,
		EasingStyle = Enum.EasingStyle.Quad,
		EasingDirection = Enum.EasingDirection.Out
	},
	Font = {
		Family = Enum.Font.SourceSans,
		Size = 18
	}
}

-- State management
local openSubmenus = {}

-- Utility functions
local function closeAllSubmenus()
	for _, menu in pairs(openSubmenus) do
		if menu and menu:IsA("Frame") then
			menu.Visible = false
		end
	end
	table.clear(openSubmenus)
end

-- Event handler untuk menutup submenu saat klik di luar
local function setupGlobalClickHandler()
	UserInputService.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			local mousePos = UserInputService:GetMouseLocation()
			local clickedInside = false
			
			for _, menu in pairs(openSubmenus) do
				if menu and menu:IsA("Frame") then
					local pos, size = menu.AbsolutePosition, menu.AbsoluteSize
					if mousePos.X > pos.X and mousePos.X < pos.X + size.X and
					   mousePos.Y > pos.Y and mousePos.Y < pos.Y + size.Y then
						clickedInside = true
						break
					end
				end
			end
			
			if not clickedInside then 
				closeAllSubmenus() 
			end
		end
	end)
end

-- Inisialisasi event handler
setupGlobalClickHandler()

-- Factory functions untuk komponen UI
function DropdownModule.createFrame(parent, name, color)
	local frame = Instance.new("Frame")
	frame.Name = name or "DropdownFrame"
	frame.Size = UDim2.new(1, 0, 0, 0)
	frame.AutomaticSize = Enum.AutomaticSize.Y
	frame.BackgroundColor3 = color or DropdownModule.Config.Colors.Background
	frame.BorderSizePixel = 0
	frame.ClipsDescendants = false
	frame.Parent = parent
	
	local layout = Instance.new("UIListLayout", frame)
	layout.Padding = UDim.new(0, DropdownModule.Config.Sizes.Padding)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	
	return frame
end

function DropdownModule.createButton(text, config)
	config = config or {}
	
	local btn = Instance.new("TextButton")
	btn.Text = text or "Button"
	btn.Size = UDim2.new(1, 0, 0, config.height or DropdownModule.Config.Sizes.ButtonHeight)
	btn.BackgroundColor3 = config.backgroundColor or DropdownModule.Config.Colors.ButtonBackground
	btn.Font = config.font or DropdownModule.Config.Font.Family
	btn.TextSize = config.textSize or DropdownModule.Config.Font.Size
	btn.TextXAlignment = config.textAlignment or Enum.TextXAlignment.Left
	btn.BorderSizePixel = 0
	
	-- Hover effect
	btn.MouseEnter:Connect(function()
		local hoverColor = Color3.new(
			math.min(btn.BackgroundColor3.R + 0.1, 1),
			math.min(btn.BackgroundColor3.G + 0.1, 1),
			math.min(btn.BackgroundColor3.B + 0.1, 1)
		)
		btn.BackgroundColor3 = hoverColor
	end)
	
	btn.MouseLeave:Connect(function()
		btn.BackgroundColor3 = config.backgroundColor or DropdownModule.Config.Colors.ButtonBackground
	end)
	
	return btn
end

function DropdownModule.createTextBox(placeholder, config)
	config = config or {}
	
	local box = Instance.new("TextBox")
	box.PlaceholderText = placeholder or "Enter text..."
	box.Size = UDim2.new(1, 0, 0, config.height or DropdownModule.Config.Sizes.ButtonHeight)
	box.BackgroundColor3 = config.backgroundColor or DropdownModule.Config.Colors.TextBoxBackground
	box.Font = config.font or DropdownModule.Config.Font.Family
	box.TextSize = config.textSize or DropdownModule.Config.Font.Size
	box.Text = config.defaultText or ""
	box.BorderSizePixel = 0
	
	-- Rounded corners
	local corner = Instance.new("UICorner", box)
	corner.CornerRadius = UDim.new(0, 4)
	
	return box
end

function DropdownModule.createToggle(text, config)
	config = config or {}
	
	local btn = DropdownModule.createButton("[ ] " .. text, config)
	local toggled = config.defaultState or false
	
	if toggled then
		btn.Text = "[✓] " .. text
	end
	
	btn.MouseButton1Click:Connect(function()
		toggled = not toggled
		btn.Text = (toggled and "[✓] " or "[ ] ") .. text
		
		if config.onToggle then
			config.onToggle(toggled)
		end
	end)
	
	-- Method untuk mendapatkan state
	btn.GetToggleState = function()
		return toggled
	end
	
	return btn
end

function DropdownModule.createSlider(min, max, config)
	config = config or {}
	min = min or 0
	max = max or 100
	
	local currentValue = config.defaultValue or min
	
	local slider = Instance.new("Frame")
	slider.Size = UDim2.new(1, 0, 0, config.height or DropdownModule.Config.Sizes.ButtonHeight)
	slider.BackgroundColor3 = config.backgroundColor or DropdownModule.Config.Colors.SliderBackground
	slider.BorderSizePixel = 0
	
	-- Rounded corners
	local corner = Instance.new("UICorner", slider)
	corner.CornerRadius = UDim.new(0, 4)
	
	local label = Instance.new("TextLabel", slider)
	label.Text = (config.prefix or "Value: ") .. tostring(currentValue)
	label.Size = UDim2.new(0.3, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Font = DropdownModule.Config.Font.Family
	label.TextSize = DropdownModule.Config.Font.Size - 2
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextColor3 = Color3.fromRGB(50, 50, 50)
	
	local bar = Instance.new("Frame", slider)
	bar.Size = UDim2.new(0.7, -10, 0.6, 0)
	bar.Position = UDim2.new(0.3, 5, 0.2, 0)
	bar.BackgroundColor3 = Color3.fromRGB(120, 120, 200)
	
	local barCorner = Instance.new("UICorner", bar)
	barCorner.CornerRadius = UDim.new(0, 2)
	
	local fill = Instance.new("Frame", bar)
	local initialPercent = (currentValue - min) / (max - min)
	fill.Size = UDim2.new(initialPercent, 0, 1, 0)
	fill.BackgroundColor3 = Color3.fromRGB(80, 80, 180)
	
	local fillCorner = Instance.new("UICorner", fill)
	fillCorner.CornerRadius = UDim.new(0, 2)
	
	bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			local moveConn
			moveConn = UserInputService.InputChanged:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseMovement then
					local relX = math.clamp((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
					fill.Size = UDim2.new(relX, 0, 1, 0)
					currentValue = math.floor(relX * (max - min) + min)
					label.Text = (config.prefix or "Value: ") .. tostring(currentValue)
					
					if config.onValueChanged then
						config.onValueChanged(currentValue)
					end
				end
			end)
			
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					moveConn:Disconnect()
				end
			end)
		end
	end)
	
	-- Method untuk mendapatkan nilai
	slider.GetValue = function()
		return currentValue
	end
	
	-- Method untuk set nilai
	slider.SetValue = function(value)
		value = math.clamp(value, min, max)
		currentValue = value
		local percent = (value - min) / (max - min)
		fill.Size = UDim2.new(percent, 0, 1, 0)
		label.Text = (config.prefix or "Value: ") .. tostring(value)
	end
	
	return slider
end

return DropdownModule

