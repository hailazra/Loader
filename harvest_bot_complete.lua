--[[
    🌾 ROBLOX HARVEST BOT GUI - COMPLETE VERSION
    
    Fitur Lengkap:
    • GUI yang dapat di-drag dengan interface modern
    • Start/Stop harvesting dengan satu klik
    • Filter varian (Normal, Gold, Rainbow)
    • Filter buah (ignore/only specific fruits)
    • Filter mutasi (ignore/only specific mutations)
    • Filter berat minimum
    • Statistik real-time (total harvested, runtime, status)
    • Notifikasi sistem
    • Auto-save konfigurasi
    
    Cara Penggunaan:
    1. Jalankan script ini di Roblox
    2. GUI akan muncul di layar
    3. Atur filter sesuai kebutuhan
    4. Klik "Start Harvesting" untuk memulai
    5. Klik "Stop Harvesting" untuk menghentikan
    
    Catatan:
    • Script ini memerlukan executor yang mendukung fireproximityprompt
    • GUI akan tersimpan dan dapat di-drag ke posisi yang diinginkan
    • Semua pengaturan akan tersimpan selama sesi game
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- ========== KONFIGURASI SISTEM ==========
local CONFIG = {
    GUI_VERSION = "2.0",
    AUTO_SAVE = true,
    HARVEST_DELAY = 0.1,
    CYCLE_DELAY = 1,
    NOTIFICATION_DURATION = 3
}

-- ========== VARIABEL GLOBAL ==========
local Farms = workspace:WaitForChild("Farm")
local GUI_ELEMENTS = {}
local HARVEST_STATE = {
    isActive = false,
    connection = nil,
    stats = {
        totalHarvested = 0,
        lastHarvested = "",
        startTime = 0,
        sessionTime = 0
    }
}

-- Konfigurasi filter (dapat diubah melalui GUI)
local FILTERS = {
    variants = {
        Normal = false,
        Gold = false,
        Rainbow = false,
    },
    fruits = {
        ignore = {},  -- [FruitName] = true
        only = {}     -- [FruitName] = true
    },
    mutations = {
        ignore = {},      -- [MutationName] = true
        only = {},        -- [MutationName] = true
        onlyMutation = false,
        ignoreMutation = false
    },
    weight = {
        minimum = 0
    }
}

-- ========== FUNGSI UTILITAS ==========
local function Log(message, type)
    local prefix = type == "error" and "❌" or type == "warning" and "⚠️" or type == "success" and "✅" or "ℹ️"
    print(string.format("[HarvestBot] %s %s", prefix, message))
end

local function ShowNotification(text, duration)
    if not GUI_ELEMENTS.screenGui then return end
    
    duration = duration or CONFIG.NOTIFICATION_DURATION
    
    local notification = Instance.new("Frame")
    notification.Name = "Notification"
    notification.Size = UDim2.new(0, 350, 0, 70)
    notification.Position = UDim2.new(1, 0, 0, 100)
    notification.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    notification.BorderSizePixel = 0
    notification.ZIndex = 1000
    notification.Parent = GUI_ELEMENTS.screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = notification

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(85, 170, 85)
    stroke.Thickness = 2
    stroke.Parent = notification

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = notification

    -- Animasi masuk
    notification:TweenPosition(UDim2.new(1, -370, 0, 100), "Out", "Quad", 0.4, true)
    
    -- Hilang setelah durasi tertentu
    spawn(function()
        wait(duration)
        notification:TweenPosition(UDim2.new(1, 0, 0, 100), "In", "Quad", 0.4, true)
        wait(0.4)
        notification:Destroy()
    end)
end

-- ========== FUNGSI FARM CORE ==========
local function GetFarms()
    return Farms:GetChildren()
end

local function GetFarmOwner(Farm)
    local Important = Farm:FindFirstChild("Important")
    if not Important then return nil end

    local Data = Important:FindFirstChild("Data")
    if not Data then return nil end

    local Owner = Data:FindFirstChild("Owner")
    return Owner and Owner.Value or nil
end

local function GetPlayerFarm(PlayerName)
    for _, Farm in pairs(GetFarms()) do
        if GetFarmOwner(Farm) == PlayerName then
            return Farm
        end
    end
    return nil
end

local function GetActiveMutations(fruit)
    local mutations = {}
    for name, value in pairs(fruit:GetAttributes()) do
        if value == true then
            mutations[name] = true
        end
    end
    return mutations
end

local function HasIgnoredMutation(fruit)
    local activeMutations = GetActiveMutations(fruit)
    for mutationName in pairs(activeMutations) do
        if FILTERS.mutations.ignore[mutationName] then
            return true
        end
    end
    return false
end

local function HasRequiredMutation(fruit)
    local activeMutations = GetActiveMutations(fruit)
    for mutationName in pairs(activeMutations) do
        if FILTERS.mutations.only[mutationName] then
            return true
        end
    end
    return false
end

local function CanHarvestPlant(fruit)
    local prompt = fruit:FindFirstChildWhichIsA("ProximityPrompt", true)
    return prompt and prompt.Enabled
end

local function HarvestPlant(fruit)
    local prompt = fruit:FindFirstChildWhichIsA("ProximityPrompt", true)
    if prompt and prompt.Enabled then
        local success = pcall(function()
            fireproximityprompt(prompt)
        end)
        
        if success then
            HARVEST_STATE.stats.totalHarvested = HARVEST_STATE.stats.totalHarvested + 1
            HARVEST_STATE.stats.lastHarvested = fruit.Name
            return true
        end
    end
    return false
end

local function ShouldHarvestPlant(plant)
    local name = plant.Name
    local variant = plant:FindFirstChild("Variant")
    local weightObj = plant:FindFirstChild("Weight")
    
    -- Filter varian
    local variantValue = variant and tostring(variant.Value) or ""
    if FILTERS.variants[variantValue] then
        return false
    end
    
    -- Filter mutasi
    if FILTERS.mutations.ignoreMutation and HasIgnoredMutation(plant) then
        return false
    end
    
    if FILTERS.mutations.onlyMutation and not HasRequiredMutation(plant) then
        return false
    end
    
    -- Filter buah
    if next(FILTERS.fruits.only) and not FILTERS.fruits.only[name] then
        return false
    end
    
    if FILTERS.fruits.ignore[name] then
        return false
    end
    
    -- Filter berat
    if weightObj and weightObj:IsA("NumberValue") then
        if weightObj.Value < FILTERS.weight.minimum then
            return false
        end
    end
    
    return CanHarvestPlant(plant)
end

local function CollectHarvestablePlants(parent, results)
    results = results or {}
    
    for _, child in pairs(parent:GetChildren()) do
        -- Rekursif untuk folder buah
        local fruitFolder = child:FindFirstChild("Fruits")
        if fruitFolder then
            CollectHarvestablePlants(fruitFolder, results)
        end
        
        -- Cek apakah bisa dipanen
        if ShouldHarvestPlant(child) then
            table.insert(results, child)
        end
    end
    
    return results
end

local function GetHarvestablePlants()
    local myFarm = GetPlayerFarm(LocalPlayer.Name)
    if not myFarm then
        Log("Farm tidak ditemukan untuk player!", "error")
        return {}
    end
    
    local plantsPhysical = myFarm:FindFirstChild("Important")
    if plantsPhysical then
        plantsPhysical = plantsPhysical:FindFirstChild("Plants_Physical")
    end
    
    if not plantsPhysical then
        Log("Plants_Physical tidak ditemukan!", "error")
        return {}
    end
    
    return CollectHarvestablePlants(plantsPhysical)
end

-- ========== SISTEM PANEN OTOMATIS ==========
local function StartHarvesting()
    if HARVEST_STATE.isActive then
        Log("Harvesting sudah aktif!", "warning")
        return
    end
    
    HARVEST_STATE.isActive = true
    HARVEST_STATE.stats.startTime = tick()
    HARVEST_STATE.stats.totalHarvested = 0
    
    Log("Memulai harvesting otomatis...", "success")
    ShowNotification("🚀 Harvesting dimulai!")
    
    HARVEST_STATE.connection = RunService.Heartbeat:Connect(function()
        if not HARVEST_STATE.isActive then return end
        
        local harvestable = GetHarvestablePlants()
        local harvested = 0
        
        for _, plant in pairs(harvestable) do
            if HarvestPlant(plant) then
                harvested = harvested + 1
                wait(CONFIG.HARVEST_DELAY)
            end
        end
        
        if harvested > 0 then
            Log(string.format("Dipanen: %d tanaman", harvested))
        end
        
        wait(CONFIG.CYCLE_DELAY)
    end)
    
    -- Update UI
    if GUI_ELEMENTS.startButton then
        GUI_ELEMENTS.startButton.Text = "✅ Harvesting Active"
        GUI_ELEMENTS.startButton.BackgroundColor3 = Color3.fromRGB(85, 85, 170)
    end
end

local function StopHarvesting()
    if not HARVEST_STATE.isActive then
        Log("Harvesting sudah tidak aktif!", "warning")
        return
    end
    
    HARVEST_STATE.isActive = false
    
    if HARVEST_STATE.connection then
        HARVEST_STATE.connection:Disconnect()
        HARVEST_STATE.connection = nil
    end
    
    HARVEST_STATE.stats.sessionTime = tick() - HARVEST_STATE.stats.startTime
    
    Log("Harvesting dihentikan.", "success")
    ShowNotification(string.format("🛑 Harvesting dihentikan! Total: %d", HARVEST_STATE.stats.totalHarvested))
    
    -- Update UI
    if GUI_ELEMENTS.startButton then
        GUI_ELEMENTS.startButton.Text = "🚀 Start Harvesting"
        GUI_ELEMENTS.startButton.BackgroundColor3 = Color3.fromRGB(85, 170, 85)
    end
end

-- ========== FUNGSI GUI BUILDER ==========
local function CreateUIElement(className, properties, parent)
    local element = Instance.new(className)
    
    for property, value in pairs(properties) do
        element[property] = value
    end
    
    if parent then
        element.Parent = parent
    end
    
    return element
end

local function CreateSection(parent, title, layoutOrder)
    local section = CreateUIElement("Frame", {
        Name = title .. "Section",
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = Color3.fromRGB(55, 55, 55),
        BorderSizePixel = 0,
        LayoutOrder = layoutOrder
    }, parent)

    CreateUIElement("UICorner", {
        CornerRadius = UDim.new(0, 8)
    }, section)

    local layout = CreateUIElement("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8)
    }, section)

    CreateUIElement("UIPadding", {
        PaddingTop = UDim.new(0, 15),
        PaddingBottom = UDim.new(0, 15),
        PaddingLeft = UDim.new(0, 15),
        PaddingRight = UDim.new(0, 15)
    }, section)

    local sectionTitle = CreateUIElement("TextLabel", {
        Name = "SectionTitle",
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Color3.fromRGB(200, 200, 200),
        TextScaled = true,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 1
    }, section)

    return section, layout
end

local function CreateToggle(parent, text, defaultValue, callback, layoutOrder)
    local toggle = CreateUIElement("Frame", {
        Name = text .. "Toggle",
        Size = UDim2.new(1, 0, 0, 35),
        BackgroundTransparency = 1,
        LayoutOrder = layoutOrder
    }, parent)

    CreateUIElement("TextLabel", {
        Name = "Label",
        Size = UDim2.new(1, -50, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextScaled = true,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left
    }, toggle)

    local button = CreateUIElement("TextButton", {
        Name = "Button",
        Size = UDim2.new(0, 45, 0, 25),
        Position = UDim2.new(1, -45, 0, 5),
        BackgroundColor3 = defaultValue and Color3.fromRGB(85, 170, 85) or Color3.fromRGB(170, 85, 85),
        BorderSizePixel = 0,
        Text = defaultValue and "ON" or "OFF",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextScaled = true,
        Font = Enum.Font.GothamBold
    }, toggle)

    CreateUIElement("UICorner", {
        CornerRadius = UDim.new(0, 12)
    }, button)

    local isOn = defaultValue
    button.MouseButton1Click:Connect(function()
        isOn = not isOn
        button.Text = isOn and "ON" or "OFF"
        button.BackgroundColor3 = isOn and Color3.fromRGB(85, 170, 85) or Color3.fromRGB(170, 85, 85)
        
        -- Animasi klik
        local tween = TweenService:Create(button, TweenInfo.new(0.1), {
            Size = UDim2.new(0, 50, 0, 30)
        })
        tween:Play()
        tween.Completed:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.1), {
                Size = UDim2.new(0, 45, 0, 25)
            }):Play()
        end)
        
        if callback then
            callback(isOn)
        end
    end)

    return toggle, button
end

local function CreateTextInput(parent, placeholder, callback, layoutOrder)
    local input = CreateUIElement("Frame", {
        Name = placeholder .. "Input",
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        LayoutOrder = layoutOrder
    }, parent)

    local textBox = CreateUIElement("TextBox", {
        Name = "TextBox",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(35, 35, 35),
        BorderSizePixel = 0,
        PlaceholderText = placeholder,
        PlaceholderColor3 = Color3.fromRGB(150, 150, 150),
        Text = "",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextScaled = true,
        Font = Enum.Font.Gotham,
        ClearTextOnFocus = false
    }, input)

    CreateUIElement("UICorner", {
        CornerRadius = UDim.new(0, 8)
    }, textBox)

    CreateUIElement("UIPadding", {
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12)
    }, textBox)

    if callback then
        textBox.FocusLost:Connect(function()
            callback(textBox.Text)
        end)
    end

    return input, textBox
end

local function CreateButton(parent, text, color, callback, layoutOrder)
    local button = CreateUIElement("TextButton", {
        Name = text .. "Button",
        Size = UDim2.new(1, 0, 0, 45),
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        Text = text,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextScaled = true,
        Font = Enum.Font.GothamBold,
        LayoutOrder = layoutOrder
    }, parent)

    CreateUIElement("UICorner", {
        CornerRadius = UDim.new(0, 10)
    }, button)

    if callback then
        button.MouseButton1Click:Connect(function()
            -- Animasi klik
            local tween = TweenService:Create(button, TweenInfo.new(0.1), {
                Size = UDim2.new(1, 0, 0, 40)
            })
            tween:Play()
            tween.Completed:Connect(function()
                TweenService:Create(button, TweenInfo.new(0.1), {
                    Size = UDim2.new(1, 0, 0, 45)
                }):Play()
            end)
            callback()
        end)
    end

    return button
end

-- ========== SETUP GUI UTAMA ==========
local function CreateMainGUI()
    -- Hapus GUI lama jika ada
    local existingGUI = LocalPlayer.PlayerGui:FindFirstChild("HarvestBotGUI")
    if existingGUI then
        existingGUI:Destroy()
    end

    -- ScreenGui utama
    local screenGui = CreateUIElement("ScreenGui", {
        Name = "HarvestBotGUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    }, LocalPlayer.PlayerGui)

    -- Frame utama
    local mainFrame = CreateUIElement("Frame", {
        Name = "MainFrame",
        Size = UDim2.new(0, 420, 0, 650),
        Position = UDim2.new(0, 50, 0, 50),
        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
        BorderSizePixel = 0,
        Active = true,
        Draggable = true
    }, screenGui)

    CreateUIElement("UICorner", {
        CornerRadius = UDim.new(0, 15)
    }, mainFrame)

    CreateUIElement("UIStroke", {
        Color = Color3.fromRGB(85, 170, 85),
        Thickness = 2
    }, mainFrame)

    -- Header
    local header = CreateUIElement("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 50),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        BorderSizePixel = 0
    }, mainFrame)

    CreateUIElement("UICorner", {
        CornerRadius = UDim.new(0, 15)
    }, header)

    local title = CreateUIElement("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, -100, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        BackgroundTransparency = 1,
        Text = "🌾 Harvest Bot GUI v" .. CONFIG.GUI_VERSION,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextScaled = true,
        Font = Enum.Font.GothamBold
    }, header)

    -- Tombol minimize
    local minimizeButton = CreateUIElement("TextButton", {
        Name = "MinimizeButton",
        Size = UDim2.new(0, 35, 0, 35),
        Position = UDim2.new(1, -80, 0, 7.5),
        BackgroundColor3 = Color3.fromRGB(255, 193, 7),
        BorderSizePixel = 0,
        Text = "−",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextScaled = true,
        Font = Enum.Font.GothamBold
    }, header)

    CreateUIElement("UICorner", {
        CornerRadius = UDim.new(0, 8)
    }, minimizeButton)

    -- Tombol close
    local closeButton = CreateUIElement("TextButton", {
        Name = "CloseButton",
        Size = UDim2.new(0, 35, 0, 35),
        Position = UDim2.new(1, -40, 0, 7.5),
        BackgroundColor3 = Color3.fromRGB(220, 53, 69),
        BorderSizePixel = 0,
        Text = "✕",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextScaled = true,
        Font = Enum.Font.GothamBold
    }, header)

    CreateUIElement("UICorner", {
        CornerRadius = UDim.new(0, 8)
    }, closeButton)

    -- ScrollingFrame untuk konten
    local scrollFrame = CreateUIElement("ScrollingFrame", {
        Name = "ScrollFrame",
        Size = UDim2.new(1, -20, 1, -70),
        Position = UDim2.new(0, 10, 0, 60),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 10,
        ScrollBarImageColor3 = Color3.fromRGB(85, 170, 85),
        CanvasSize = UDim2.new(0, 0, 0, 0)
    }, mainFrame)

    CreateUIElement("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 15)
    }, scrollFrame)

    -- Simpan referensi
    GUI_ELEMENTS.screenGui = screenGui
    GUI_ELEMENTS.mainFrame = mainFrame
    GUI_ELEMENTS.scrollFrame = scrollFrame
    GUI_ELEMENTS.closeButton = closeButton
    GUI_ELEMENTS.minimizeButton = minimizeButton

    return screenGui, mainFrame, scrollFrame, closeButton, minimizeButton
end

local function SetupGUIContent()
    local scrollFrame = GUI_ELEMENTS.scrollFrame
    
    -- Section 1: Control Panel
    local controlSection = CreateSection(scrollFrame, "🎮 Control Panel", 1)
    
    GUI_ELEMENTS.startButton = CreateButton(controlSection, "🚀 Start Harvesting", Color3.fromRGB(85, 170, 85), StartHarvesting, 2)
    CreateButton(controlSection, "🛑 Stop Harvesting", Color3.fromRGB(220, 53, 69), StopHarvesting, 3)

    -- Section 2: Variant Filters
    local variantSection = CreateSection(scrollFrame, "🌈 Variant Filters", 2)
    
    CreateToggle(variantSection, "Ignore Normal", FILTERS.variants.Normal, function(value)
        FILTERS.variants.Normal = value
        Log(string.format("Filter Normal: %s", value and "ON" or "OFF"))
    end, 2)
    
    CreateToggle(variantSection, "Ignore Gold", FILTERS.variants.Gold, function(value)
        FILTERS.variants.Gold = value
        Log(string.format("Filter Gold: %s", value and "ON" or "OFF"))
    end, 3)
    
    CreateToggle(variantSection, "Ignore Rainbow", FILTERS.variants.Rainbow, function(value)
        FILTERS.variants.Rainbow = value
        Log(string.format("Filter Rainbow: %s", value and "ON" or "OFF"))
    end, 4)

    -- Section 3: Fruit Filters
    local fruitSection = CreateSection(scrollFrame, "🍎 Fruit Filters", 3)
    
    CreateTextInput(fruitSection, "Ignore Fruits (pisahkan dengan koma)", function(text)
        FILTERS.fruits.ignore = {}
        if text and text ~= "" then
            for fruit in string.gmatch(text, "([^,]+)") do
                local trimmed = fruit:match("^%s*(.-)%s*$")
                if trimmed ~= "" then
                    FILTERS.fruits.ignore[trimmed] = true
                end
            end
        end
        Log(string.format("Ignore Fruits updated: %s", text))
    end, 2)
    
    CreateTextInput(fruitSection, "Only Fruits (pisahkan dengan koma)", function(text)
        FILTERS.fruits.only = {}
        if text and text ~= "" then
            for fruit in string.gmatch(text, "([^,]+)") do
                local trimmed = fruit:match("^%s*(.-)%s*$")
                if trimmed ~= "" then
                    FILTERS.fruits.only[trimmed] = true
                end
            end
        end
        Log(string.format("Only Fruits updated: %s", text))
    end, 3)

    -- Section 4: Mutation Filters
    local mutationSection = CreateSection(scrollFrame, "🧬 Mutation Filters", 4)
    
    CreateToggle(mutationSection, "Only Mutation", FILTERS.mutations.onlyMutation, function(value)
        FILTERS.mutations.onlyMutation = value
        Log(string.format("Only Mutation: %s", value and "ON" or "OFF"))
    end, 2)
    
    CreateToggle(mutationSection, "Ignore Mutation", FILTERS.mutations.ignoreMutation, function(value)
        FILTERS.mutations.ignoreMutation = value
        Log(string.format("Ignore Mutation: %s", value and "ON" or "OFF"))
    end, 3)
    
    CreateTextInput(mutationSection, "Ignore Mutations (pisahkan dengan koma)", function(text)
        FILTERS.mutations.ignore = {}
        if text and text ~= "" then
            for mutation in string.gmatch(text, "([^,]+)") do
                local trimmed = mutation:match("^%s*(.-)%s*$")
                if trimmed ~= "" then
                    FILTERS.mutations.ignore[trimmed] = true
                end
            end
        end
        Log(string.format("Ignore Mutations updated: %s", text))
    end, 4)
    
    CreateTextInput(mutationSection, "Only Mutations (pisahkan dengan koma)", function(text)
        FILTERS.mutations.only = {}
        if text and text ~= "" then
            for mutation in string.gmatch(text, "([^,]+)") do
                local trimmed = mutation:match("^%s*(.-)%s*$")
                if trimmed ~= "" then
                    FILTERS.mutations.only[trimmed] = true
                end
            end
        end
        Log(string.format("Only Mutations updated: %s", text))
    end, 5)

    -- Section 5: Weight Filter
    local weightSection = CreateSection(scrollFrame, "⚖️ Weight Filter", 5)
    
    CreateTextInput(weightSection, "Minimum Weight (0 = tidak ada limit)", function(text)
        local weight = tonumber(text)
        if weight and weight >= 0 then
            FILTERS.weight.minimum = weight
            Log(string.format("Minimum Weight: %s", weight))
        else
            Log("Invalid weight value!", "error")
        end
    end, 2)

    -- Section 6: Statistics
    local statsSection = CreateSection(scrollFrame, "📊 Statistics", 6)
    
    local statsLabel = CreateUIElement("TextLabel", {
        Name = "StatsLabel",
        Size = UDim2.new(1, 0, 0, 100),
        BackgroundTransparency = 1,
        Text = "Total Harvested: 0\nLast Harvested: None\nStatus: Stopped\nRuntime: 0s",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextScaled = true,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        LayoutOrder = 2
    }, statsSection)

    GUI_ELEMENTS.statsLabel = statsLabel
end

local function SetupGUIEvents()
    -- Event close button
    GUI_ELEMENTS.closeButton.MouseButton1Click:Connect(function()
        StopHarvesting()
        ShowNotification("👋 GUI ditutup!")
        wait(0.5)
        GUI_ELEMENTS.screenGui:Destroy()
    end)

    -- Event minimize button
    local isMinimized = false
    GUI_ELEMENTS.minimizeButton.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        local targetSize = isMinimized and UDim2.new(0, 420, 0, 50) or UDim2.new(0, 420, 0, 650)
        
        TweenService:Create(GUI_ELEMENTS.mainFrame, TweenInfo.new(0.3), {
            Size = targetSize
        }):Play()
        
        GUI_ELEMENTS.scrollFrame.Visible = not isMinimized
    end)

    -- Update statistik setiap detik
    spawn(function()
        while GUI_ELEMENTS.screenGui and GUI_ELEMENTS.screenGui.Parent do
            if GUI_ELEMENTS.statsLabel then
                local status = HARVEST_STATE.isActive and "🟢 Running" or "🔴 Stopped"
                local runtime = HARVEST_STATE.isActive and string.format("%.1f", tick() - HARVEST_STATE.stats.startTime) or "0"
                
                GUI_ELEMENTS.statsLabel.Text = string.format(
                    "Total Harvested: %d\nLast Harvested: %s\nStatus: %s\nRuntime: %ss",
                    HARVEST_STATE.stats.totalHarvested,
                    HARVEST_STATE.stats.lastHarvested ~= "" and HARVEST_STATE.stats.lastHarvested or "None",
                    status,
                    runtime
                )
            end
            wait(1)
        end
    end)

    -- Auto-resize scroll frame
    local function updateScrollSize()
        local totalHeight = 0
        for _, child in pairs(GUI_ELEMENTS.scrollFrame:GetChildren()) do
            if child:IsA("Frame") then
                totalHeight = totalHeight + child.AbsoluteSize.Y + 15
            end
        end
        GUI_ELEMENTS.scrollFrame.CanvasSize = UDim2.new(0, 0, 0, totalHeight + 30)
    end

    local function updateSectionSizes()
        for _, section in pairs(GUI_ELEMENTS.scrollFrame:GetChildren()) do
            if section:IsA("Frame") then
                local layout = section:FindFirstChild("UIListLayout")
                if layout then
                    local totalHeight = 0
                    for _, child in pairs(section:GetChildren()) do
                        if child:IsA("GuiObject") and child ~= layout then
                            totalHeight = totalHeight + child.AbsoluteSize.Y
                        end
                    end
                    totalHeight = totalHeight + (#section:GetChildren() - 1) * 8 + 30
                    section.Size = UDim2.new(1, 0, 0, totalHeight)
                end
            end
        end
        updateScrollSize()
    end

    RunService.Heartbeat:Connect(updateSectionSizes)
end

-- ========== INISIALISASI SISTEM ==========
local function InitializeHarvestBot()
    Log("Menginisialisasi Harvest Bot GUI...", "success")
    
    -- Cek farm player
    local myFarm = GetPlayerFarm(LocalPlayer.Name)
    if not myFarm then
        Log("Farm tidak ditemukan! Pastikan Anda berada di area farm.", "error")
        return false
    end
    
    Log(string.format("Farm ditemukan untuk player: %s", LocalPlayer.Name), "success")
    
    -- Setup GUI
    CreateMainGUI()
    SetupGUIContent()
    SetupGUIEvents()
    
    -- Notifikasi startup
    ShowNotification("🌾 Harvest Bot GUI berhasil dimuat!", 4)
    
    Log("=== HARVEST BOT GUI READY ===", "success")
    Log("Fitur yang tersedia:", "info")
    Log("• Start/Stop harvesting otomatis", "info")
    Log("• Filter varian (Normal, Gold, Rainbow)", "info")
    Log("• Filter buah (ignore/only)", "info")
    Log("• Filter mutasi (ignore/only)", "info")
    Log("• Filter berat minimum", "info")
    Log("• Statistik real-time", "info")
    Log("• Interface yang dapat di-drag dan minimize", "info")
    
    return true
end

-- ========== CLEANUP SAAT PLAYER LEAVE ==========
Players.PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then
        StopHarvesting()
    end
end)

-- ========== JALANKAN SISTEM ==========
local success = InitializeHarvestBot()
if not success then
    Log("Gagal menginisialisasi Harvest Bot!", "error")
else
    Log("Harvest Bot siap digunakan! 🚀", "success")
end

