--[[
	NestedDropdownModule.lua
	Modul untuk nested dropdown functionality
	
	Fitur:
	- Nested dropdown dengan positioning otomatis
	- Support untuk multiple levels
	- Event handling untuk submenu
]]

local NestedDropdownModule = {}

-- Import modul utama
local DropdownModule = require(script.Parent.DropdownModule)

-- State management untuk nested dropdowns
local openSubmenus = {}

function NestedDropdownModule.createNestedDropdown(parentBtn, items, config)
	config = config or {}
	
	local dropdown = Instance.new("Frame")
	dropdown.Size = UDim2.new(0, config.width or DropdownModule.Config.Sizes.NestedWidth, 0, 0)
	dropdown.AutomaticSize = Enum.AutomaticSize.Y
	dropdown.Position = UDim2.new(0, parentBtn.AbsoluteSize.X + 4, 0, 0)
	dropdown.BackgroundColor3 = config.backgroundColor or DropdownModule.Config.Colors.NestedBackground
	dropdown.BorderSizePixel = 0
	dropdown.Visible = false
	dropdown.Parent = parentBtn
	dropdown.ClipsDescendants = true
	dropdown.ZIndex = 10
	
	-- Rounded corners
	local corner = Instance.new("UICorner", dropdown)
	corner.CornerRadius = UDim.new(0, 6)
	
	-- Drop shadow effect
	local shadow = Instance.new("Frame", dropdown)
	shadow.Size = UDim2.new(1, 4, 1, 4)
	shadow.Position = UDim2.new(0, 2, 0, 2)
	shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	shadow.BackgroundTransparency = 0.8
	shadow.ZIndex = dropdown.ZIndex - 1
	
	local shadowCorner = Instance.new("UICorner", shadow)
	shadowCorner.CornerRadius = UDim.new(0, 6)
	
	local layout = Instance.new("UIListLayout", dropdown)
	layout.Padding = UDim.new(0, 2)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	
	-- Membuat opsi-opsi dalam nested dropdown
	for i, item in ipairs(items) do
		local option
		
		if type(item) == "string" then
			-- Simple text option
			option = DropdownModule.createButton(item, {
				backgroundColor = Color3.fromRGB(240, 230, 210),
				height = 32
			})
		elseif type(item) == "table" then
			-- Complex option dengan callback atau nested items
			option = DropdownModule.createButton(item.text or "Option", {
				backgroundColor = Color3.fromRGB(240, 230, 210),
				height = 32
			})
			
			if item.callback then
				option.MouseButton1Click:Connect(function()
					item.callback()
					dropdown.Visible = false
				end)
			end
			
			-- Support untuk nested items (multi-level)
			if item.items then
				option.Text = option.Text .. " >"
				NestedDropdownModule.createNestedDropdown(option, item.items, config)
			end
		end
		
		option.Parent = dropdown
		option.LayoutOrder = i
	end
	
	-- Toggle functionality
	parentBtn.MouseButton1Click:Connect(function()
		dropdown.Visible = not dropdown.Visible
		
		if dropdown.Visible then
			-- Tambahkan ke daftar submenu yang terbuka
			table.insert(openSubmenus, dropdown)
			
			-- Positioning logic untuk memastikan tidak keluar dari screen
			local screenSize = workspace.CurrentCamera.ViewportSize
			local btnPos = parentBtn.AbsolutePosition
			local dropdownSize = dropdown.AbsoluteSize
			
			-- Adjust horizontal position jika keluar dari screen
			if btnPos.X + parentBtn.AbsoluteSize.X + dropdownSize.X > screenSize.X then
				dropdown.Position = UDim2.new(0, -dropdownSize.X - 4, 0, 0)
			end
			
			-- Adjust vertical position jika keluar dari screen
			if btnPos.Y + dropdownSize.Y > screenSize.Y then
				dropdown.Position = UDim2.new(
					dropdown.Position.X.Scale, 
					dropdown.Position.X.Offset,
					0, 
					-dropdownSize.Y + parentBtn.AbsoluteSize.Y
				)
			end
			
			-- Animasi fade in
			dropdown.BackgroundTransparency = 1
			local tween = game:GetService("TweenService"):Create(
				dropdown,
				TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{BackgroundTransparency = 0}
			)
			tween:Play()
		else
			-- Remove dari daftar submenu yang terbuka
			for i, menu in ipairs(openSubmenus) do
				if menu == dropdown then
					table.remove(openSubmenus, i)
					break
				end
			end
		end
	end)
	
	return dropdown
end

-- Function untuk menutup semua nested dropdowns
function NestedDropdownModule.closeAllNestedDropdowns()
	for _, menu in pairs(openSubmenus) do
		if menu and menu:IsA("Frame") then
			menu.Visible = false
		end
	end
	table.clear(openSubmenus)
end

-- Function untuk membuat nested dropdown dengan data hierarkis
function NestedDropdownModule.createHierarchicalDropdown(parentBtn, data, config)
	config = config or {}
	
	local function processItems(items)
		local processedItems = {}
		
		for _, item in ipairs(items) do
			if type(item) == "string" then
				table.insert(processedItems, item)
			elseif type(item) == "table" then
				local processedItem = {
					text = item.text or item.name or "Item",
					callback = item.callback
				}
				
				if item.children and #item.children > 0 then
					processedItem.items = processItems(item.children)
				end
				
				table.insert(processedItems, processedItem)
			end
		end
		
		return processedItems
	end
	
	local processedData = processItems(data)
	return NestedDropdownModule.createNestedDropdown(parentBtn, processedData, config)
end

return NestedDropdownModule

